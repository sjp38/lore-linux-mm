Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2AA828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 10:15:12 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id 65so15351900pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 07:15:12 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ta9si9845307pab.92.2016.02.03.07.15.11
        for <linux-mm@kvack.org>;
        Wed, 03 Feb 2016 07:15:11 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/4] mm: make remove_migration_ptes() beyond mm/migration.c
Date: Wed,  3 Feb 2016 18:14:18 +0300
Message-Id: <1454512459-94334-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1454512459-94334-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch makes remove_migration_ptes() available to be used in
split_huge_page().

New parameter 'locked' added: as with try_to_umap() we need a way to
indicate that caller holds rmap lock.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h |  2 ++
 mm/migrate.c         | 13 ++++++++-----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 1fdde1ee7042..675b070f489a 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -257,6 +257,8 @@ int page_mkclean(struct page *);
  */
 int try_to_munlock(struct page *);
 
+void remove_migration_ptes(struct page *old, struct page *new, bool locked);
+
 /*
  * Called by memory-failure.c to kill processes.
  */
diff --git a/mm/migrate.c b/mm/migrate.c
index b1034f9c77e7..244a267fdb61 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -186,14 +186,17 @@ out:
  * Get rid of all migration entries and replace them by
  * references to the indicated page.
  */
-static void remove_migration_ptes(struct page *old, struct page *new)
+void remove_migration_ptes(struct page *old, struct page *new, bool locked)
 {
 	struct rmap_walk_control rwc = {
 		.rmap_one = remove_migration_pte,
 		.arg = old,
 	};
 
-	rmap_walk(new, &rwc);
+	if (locked)
+		rmap_walk_locked(new, &rwc);
+	else
+		rmap_walk(new, &rwc);
 }
 
 /*
@@ -698,7 +701,7 @@ static int writeout(struct address_space *mapping, struct page *page)
 	 * At this point we know that the migration attempt cannot
 	 * be successful.
 	 */
-	remove_migration_ptes(page, page);
+	remove_migration_ptes(page, page, false);
 
 	rc = mapping->a_ops->writepage(page, &wbc);
 
@@ -897,7 +900,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 
 	if (page_was_mapped)
 		remove_migration_ptes(page,
-			rc == MIGRATEPAGE_SUCCESS ? newpage : page);
+			rc == MIGRATEPAGE_SUCCESS ? newpage : page, false);
 
 out_unlock_both:
 	unlock_page(newpage);
@@ -1065,7 +1068,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
 
 	if (page_was_mapped)
 		remove_migration_ptes(hpage,
-			rc == MIGRATEPAGE_SUCCESS ? new_hpage : hpage);
+			rc == MIGRATEPAGE_SUCCESS ? new_hpage : hpage, false);
 
 	unlock_page(new_hpage);
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
