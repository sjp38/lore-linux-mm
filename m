Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C95886B029C
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:29:14 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id e128so18535432pfe.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:29:14 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id kv12si10044887pab.194.2016.04.05.14.29.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:29:13 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id c20so18581639pfc.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:29:13 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:29:11 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 11/31] huge tmpfs: disband split huge pmds on race or memory
 failure
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051425400.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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
 mm/memory-failure.c |    7 ++++++-
 mm/shmem.c          |   30 +++++++++++++++++++++++++++++-
 2 files changed, 35 insertions(+), 2 deletions(-)

--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -45,6 +45,7 @@
 #include <linux/rmap.h>
 #include <linux/export.h>
 #include <linux/pagemap.h>
+#include <linux/pageteam.h>
 #include <linux/swap.h>
 #include <linux/backing-dev.h>
 #include <linux/migrate.h>
@@ -902,6 +903,7 @@ static int hwpoison_user_mappings(struct
 	enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
 	struct address_space *mapping;
 	LIST_HEAD(tokill);
+	bool mapped;
 	int ret;
 	int kill = 1, forcekill;
 	struct page *hpage = *hpagep;
@@ -919,7 +921,10 @@ static int hwpoison_user_mappings(struct
 	 * This check implies we don't kill processes if their pages
 	 * are in the swap cache early. Those are always late kills.
 	 */
-	if (!page_mapped(hpage))
+	mapped = page_mapped(hpage);
+	if (PageTeam(p) && team_pmd_mapped(team_head(p)))
+		mapped = true;
+	if (!mapped)
 		return SWAP_SUCCESS;
 
 	if (PageKsm(p)) {
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -605,6 +605,19 @@ static void shmem_disband_hugeteam(struc
 	}
 
 	/*
+	 * truncate_inode_page() will unmap page if page_mapped(page),
+	 * but there's a race by which the team could be hugely mapped,
+	 * with page_mapped(page) saying false.  So check here if the
+	 * head is hugely mapped, and if so unmap page to remap team.
+	 * Use a loop because there is no good locking against a
+	 * concurrent remap_team_by_ptes().
+	 */
+	while (team_pmd_mapped(head)) {
+		unmap_mapping_range(page->mapping,
+			(loff_t)page->index << PAGE_SHIFT, PAGE_SIZE, 0);
+	}
+
+	/*
 	 * Disable preemption because truncation may end up spinning until a
 	 * tail PageTeam has been cleared: we hold the lock as briefly as we
 	 * can (splitting disband in two stages), but better not be preempted.
@@ -1305,6 +1318,21 @@ static int shmem_getattr(struct vfsmount
 	return 0;
 }
 
+static int shmem_error_remove_page(struct address_space *mapping,
+				   struct page *page)
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
 	struct inode *inode = d_inode(dentry);
@@ -4088,7 +4116,7 @@ static const struct address_space_operat
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
