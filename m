Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 604746B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:22:24 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so12931727pab.4
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:22:24 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id a4si27342921pdn.18.2015.02.20.20.22.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:22:23 -0800 (PST)
Received: by padbj1 with SMTP id bj1so12934004pad.5
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:22:23 -0800 (PST)
Date: Fri, 20 Feb 2015 20:22:21 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 19/24] huge tmpfs: disband split huge pmds on race or memory
 failure
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202020580.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Andres L-C has pointed out that the single-page unmap_mapping_range()
fallback in truncate_inode_page() cannot protect against the case when
a huge page was faulted in after the full-range unmap_mapping_range():
because page_mapped(page) checks tail page's mapcount, not the head's.

So, there's a danger that hole-punching (and maybe even truncation)
can free pages while they are mapped into userspace with a huge pmd.
And I don't believe that the CVE-2014-4171 protection in shmem_fault()
can fully protect from this, although it does make it much harder.

Fix that by adding a duplicate single-page unmap_mapping_range()
into shmem_disband_hugeteam() (called when punching or truncating
a PageTeam), at the point when we also hold the head's page lock
(without which there would still be races): which will then split
all huge pmd mappings covering the page into team pte mappings.

This is also just what's needed to handle memory_failure() correctly:
provide custom shmem_error_remove_page(), call shmem_disband_hugeteam()
from that before proceeding to generic_error_remove_page(), then this
additional unmap_mapping_range() will remap team by ptes as needed.

(There is an unlikely case that we're racing with another disbander,
or disband didn't get trylock on head page at first: memory_failure()
has almost finished with the page, so it's safe to unlock and relock
before retrying.)

But there is one further change needed in hwpoison_user_mappings():
it must recognize a hugely mapped team before concluding that the
page is not mapped.  (And still no support for soft_offline(),
which will have to wait for page migration of teams.)

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/memory-failure.c |    8 +++++++-
 mm/shmem.c          |   27 ++++++++++++++++++++++++++-
 2 files changed, 33 insertions(+), 2 deletions(-)

--- thpfs.orig/mm/memory-failure.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/memory-failure.c	2015-02-20 19:34:59.047883965 -0800
@@ -44,6 +44,7 @@
 #include <linux/rmap.h>
 #include <linux/export.h>
 #include <linux/pagemap.h>
+#include <linux/pageteam.h>
 #include <linux/swap.h>
 #include <linux/backing-dev.h>
 #include <linux/migrate.h>
@@ -889,6 +890,7 @@ static int hwpoison_user_mappings(struct
 	int kill = 1, forcekill;
 	struct page *hpage = *hpagep;
 	struct page *ppage;
+	bool mapped;
 
 	/*
 	 * Here we are interested only in user-mapped pages, so skip any
@@ -903,7 +905,11 @@ static int hwpoison_user_mappings(struct
 	 * This check implies we don't kill processes if their pages
 	 * are in the swap cache early. Those are always late kills.
 	 */
-	if (!page_mapped(hpage))
+	mapped = page_mapped(hpage);
+	if (PageTeam(p) && !PageAnon(p) &&
+	    team_hugely_mapped(team_head(p)))
+		mapped = true;
+	if (!mapped)
 		return SWAP_SUCCESS;
 
 	if (PageKsm(p)) {
--- thpfs.orig/mm/shmem.c	2015-02-20 19:34:21.603969581 -0800
+++ thpfs/mm/shmem.c	2015-02-20 19:34:59.051883956 -0800
@@ -603,6 +603,17 @@ static void shmem_disband_hugeteam(struc
 			page_cache_release(head);
 			return;
 		}
+		/*
+		 * truncate_inode_page() will unmap page if page_mapped(page),
+		 * but there's a race by which the team could be hugely mapped,
+		 * with page_mapped(page) saying false.  So check here if the
+		 * head is hugely mapped, and if so unmap page to remap team.
+		 */
+		if (team_hugely_mapped(head)) {
+			unmap_mapping_range(page->mapping,
+				(loff_t)page->index << PAGE_CACHE_SHIFT,
+				PAGE_CACHE_SIZE, 0);
+		}
 	}
 
 	/*
@@ -1216,6 +1227,20 @@ void shmem_truncate_range(struct inode *
 }
 EXPORT_SYMBOL_GPL(shmem_truncate_range);
 
+int shmem_error_remove_page(struct address_space *mapping, struct page *page)
+{
+	if (PageTeam(page)) {
+		shmem_disband_hugeteam(page);
+		while (unlikely(PageTeam(page))) {
+			unlock_page(page);
+			cond_resched();
+			lock_page(page);
+			shmem_disband_hugeteam(page);
+		}
+	}
+	return generic_error_remove_page(mapping, page);
+}
+
 static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = dentry->d_inode;
@@ -4031,7 +4056,7 @@ static const struct address_space_operat
 #ifdef CONFIG_MIGRATION
 	.migratepage	= migrate_page,
 #endif
-	.error_remove_page = generic_error_remove_page,
+	.error_remove_page = shmem_error_remove_page,
 };
 
 static const struct file_operations shmem_file_operations = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
