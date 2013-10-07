Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8AC289C0012
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:10 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so6946028pdj.32
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:10 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 27/63] mm: numa: Scan pages with elevated page_mapcount
Date: Mon,  7 Oct 2013 11:29:05 +0100
Message-Id: <1381141781-10992-28-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Currently automatic NUMA balancing is unable to distinguish between false
shared versus private pages except by ignoring pages with an elevated
page_mapcount entirely. This avoids shared pages bouncing between the
nodes whose task is using them but that is ignored quite a lot of data.

This patch kicks away the training wheels in preparation for adding support
for identifying shared/private pages is now in place. The ordering is so
that the impact of the shared/private detection can be easily measured. Note
that the patch does not migrate shared, file-backed within vmas marked
VM_EXEC as these are generally shared library pages. Migrating such pages
is not beneficial as there is an expectation they are read-shared between
caches and iTLB and iCache pressure is generally low.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/migrate.h |  7 ++++---
 mm/huge_memory.c        | 12 +++++-------
 mm/memory.c             |  7 ++-----
 mm/migrate.c            | 17 ++++++-----------
 mm/mprotect.c           |  4 +---
 5 files changed, 18 insertions(+), 29 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 8d3c57f..f5096b5 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -90,11 +90,12 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 #endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_NUMA_BALANCING
-extern int migrate_misplaced_page(struct page *page, int node);
-extern int migrate_misplaced_page(struct page *page, int node);
+extern int migrate_misplaced_page(struct page *page,
+				  struct vm_area_struct *vma, int node);
 extern bool migrate_ratelimited(int node);
 #else
-static inline int migrate_misplaced_page(struct page *page, int node)
+static inline int migrate_misplaced_page(struct page *page,
+					 struct vm_area_struct *vma, int node)
 {
 	return -EAGAIN; /* can't migrate now */
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9142167..2a28c2c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1484,14 +1484,12 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			struct page *page = pmd_page(*pmd);
 
 			/*
-			 * Only check non-shared pages. Do not trap faults
-			 * against the zero page. The read-only data is likely
-			 * to be read-cached on the local CPU cache and it is
-			 * less useful to know about local vs remote hits on
-			 * the zero page.
+			 * Do not trap faults against the zero page. The
+			 * read-only data is likely to be read-cached on the
+			 * local CPU cache and it is less useful to know about
+			 * local vs remote hits on the zero page.
 			 */
-			if (page_mapcount(page) == 1 &&
-			    !is_huge_zero_page(page) &&
+			if (!is_huge_zero_page(page) &&
 			    !pmd_numa(*pmd)) {
 				entry = pmdp_get_and_clear(mm, addr, pmd);
 				entry = pmd_mknuma(entry);
diff --git a/mm/memory.c b/mm/memory.c
index 24bc9b8..3e3b4b8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3577,7 +3577,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	/* Migrate to the requested node */
-	migrated = migrate_misplaced_page(page, target_nid);
+	migrated = migrate_misplaced_page(page, vma, target_nid);
 	if (migrated)
 		page_nid = target_nid;
 
@@ -3642,16 +3642,13 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		page = vm_normal_page(vma, addr, pteval);
 		if (unlikely(!page))
 			continue;
-		/* only check non-shared pages */
-		if (unlikely(page_mapcount(page) != 1))
-			continue;
 
 		last_nid = page_nid_last(page);
 		page_nid = page_to_nid(page);
 		target_nid = numa_migrate_prep(page, vma, addr, page_nid);
 		pte_unmap_unlock(pte, ptl);
 		if (target_nid != -1) {
-			migrated = migrate_misplaced_page(page, target_nid);
+			migrated = migrate_misplaced_page(page, vma, target_nid);
 			if (migrated)
 				page_nid = target_nid;
 		} else {
diff --git a/mm/migrate.c b/mm/migrate.c
index ce8c3a0..f212944 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1599,7 +1599,8 @@ int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
  * node. Caller is expected to have an elevated reference count on
  * the page that will be dropped by this function before returning.
  */
-int migrate_misplaced_page(struct page *page, int node)
+int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
+			   int node)
 {
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated;
@@ -1607,10 +1608,11 @@ int migrate_misplaced_page(struct page *page, int node)
 	LIST_HEAD(migratepages);
 
 	/*
-	 * Don't migrate pages that are mapped in multiple processes.
-	 * TODO: Handle false sharing detection instead of this hammer
+	 * Don't migrate file pages that are mapped in multiple processes
+	 * with execute permissions as they are probably shared libraries.
 	 */
-	if (page_mapcount(page) != 1)
+	if (page_mapcount(page) != 1 && page_is_file_cache(page) &&
+	    (vma->vm_flags & VM_EXEC))
 		goto out;
 
 	/*
@@ -1661,13 +1663,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	int page_lru = page_is_file_cache(page);
 
 	/*
-	 * Don't migrate pages that are mapped in multiple processes.
-	 * TODO: Handle false sharing detection instead of this hammer
-	 */
-	if (page_mapcount(page) != 1)
-		goto out_dropref;
-
-	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
 	 * Optimal placement is no good if the memory bus is saturated and
 	 * all the time is being spent migrating!
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 2da33dc..41e0292 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -69,9 +69,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 					if (last_nid != this_nid)
 						all_same_node = false;
 
-					/* only check non-shared pages */
-					if (!pte_numa(oldpte) &&
-					    page_mapcount(page) == 1) {
+					if (!pte_numa(oldpte)) {
 						ptent = pte_mknuma(ptent);
 						updated = true;
 					}
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
