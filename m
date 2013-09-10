Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id C521A6B0080
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:33:02 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 27/50] mm: numa: Scan pages with elevated page_mapcount
Date: Tue, 10 Sep 2013 10:32:07 +0100
Message-Id: <1378805550-29949-28-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
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
 mm/huge_memory.c        |  8 ++------
 mm/memory.c             |  7 ++-----
 mm/migrate.c            | 17 ++++++-----------
 mm/mprotect.c           |  4 +---
 5 files changed, 15 insertions(+), 28 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index a405d3dc..e7e26af 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -92,11 +92,12 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
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
index ca66a8a..a8e624e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1498,12 +1498,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 		} else {
 			struct page *page = pmd_page(*pmd);
 
-			/*
-			 * Only check non-shared pages. See change_pte_range
-			 * for comment on why the zero page is not modified
-			 */
-			if (page_mapcount(page) == 1 &&
-			    !is_huge_zero_page(page) &&
+			/* See change_pte_range about the zero page */
+			if (!is_huge_zero_page(page) &&
 			    !pmd_numa(*pmd)) {
 				entry = pmdp_get_and_clear(mm, addr, pmd);
 				entry = pmd_mknuma(entry);
diff --git a/mm/memory.c b/mm/memory.c
index bd016c2..e335ec0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3588,7 +3588,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	/* Migrate to the requested node */
-	migrated = migrate_misplaced_page(page, target_nid);
+	migrated = migrate_misplaced_page(page, vma, target_nid);
 	if (migrated)
 		page_nid = target_nid;
 
@@ -3653,16 +3653,13 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
index 6f0c244..08ac3ba 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1596,7 +1596,8 @@ int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
  * node. Caller is expected to have an elevated reference count on
  * the page that will be dropped by this function before returning.
  */
-int migrate_misplaced_page(struct page *page, int node)
+int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
+			   int node)
 {
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated;
@@ -1604,10 +1605,11 @@ int migrate_misplaced_page(struct page *page, int node)
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
@@ -1658,13 +1660,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
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
index 1e9cef0..4a21819 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -77,9 +77,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
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
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
