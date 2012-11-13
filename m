Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id B038A6B0089
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:13:23 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 17/31] mm: numa: Avoid double faulting after migrating misplaced page
Date: Tue, 13 Nov 2012 11:12:46 +0000
Message-Id: <1352805180-1607-18-git-send-email-mgorman@suse.de>
In-Reply-To: <1352805180-1607-1-git-send-email-mgorman@suse.de>
References: <1352805180-1607-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The pte_same check after a misplaced page is successfully migrated will
never succeed and force a double fault to fix it up as pointed out by Rik
van Riel. This was the "safe" option but it's expensive.

This patch uses the migration allocation callback to record the location
of the newly migrated page. If the page is the same when the PTE lock is
reacquired it is assumed that it is safe to complete the pte_numa fault
without incurring a double fault.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/migrate.h |    4 ++--
 mm/memory.c             |   28 +++++++++++++++++-----------
 mm/migrate.c            |   27 ++++++++++++++++++---------
 3 files changed, 37 insertions(+), 22 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 69f60b5..e5ab5db 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -40,7 +40,7 @@ extern int migrate_vmas(struct mm_struct *mm,
 extern void migrate_page_copy(struct page *newpage, struct page *page);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
-extern int migrate_misplaced_page(struct page *page, int node);
+extern struct page *migrate_misplaced_page(struct page *page, int node);
 #else
 
 static inline void putback_lru_pages(struct list_head *l) {}
@@ -75,7 +75,7 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 #define fail_migrate_page NULL
 
 static inline
-int migrate_misplaced_page(struct page *page, int node)
+struct page *migrate_misplaced_page(struct page *page, int node)
 {
 	return -EAGAIN; /* can't migrate now */
 }
diff --git a/mm/memory.c b/mm/memory.c
index ab9fbcf..73fa203 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3437,7 +3437,7 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
 {
-	struct page *page = NULL;
+	struct page *page = NULL, *newpage = NULL;
 	spinlock_t *ptl;
 	int current_nid = -1;
 	int target_nid;
@@ -3476,19 +3476,26 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	pte_unmap_unlock(ptep, ptl);
 
 	/* Migrate to the requested node */
-	if (migrate_misplaced_page(page, target_nid)) {
-		/*
-		 * If the page was migrated then the pte_same check below is
-		 * guaranteed to fail so just retry the entire fault.
-		 */
+	newpage = migrate_misplaced_page(page, target_nid);
+	if (newpage)
 		current_nid = target_nid;
-		goto out;
-	}
 	page = NULL;
 
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
-	if (!pte_same(*ptep, pte))
-		goto out_unlock;
+
+	/*
+	 * If we failed to migrate, we have to check the PTE has not changed during
+	 * the migration attempt. If it has, retry the fault. If it has migrated,
+	 * relookup the ptep and confirm it's the same page to avoid double faulting.
+	 */
+	if (!newpage) {
+		if (!pte_same(*ptep, pte))
+			goto out_unlock;
+	} else {
+		pte = *ptep;
+		if (!pte_numa(pte) || vm_normal_page(vma, addr, pte) != newpage)
+			goto out_unlock;
+	}
 
 clear_pmdnuma:
 	pte = pte_mknonnuma(pte);
@@ -3499,7 +3506,6 @@ out_unlock:
 	pte_unmap_unlock(ptep, ptl);
 	if (page)
 		put_page(page);
-out:
 	task_numa_fault(current_nid, 1, misplaced);
 	return 0;
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index 4a92808..631b2c5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1444,19 +1444,23 @@ static bool migrate_balanced_pgdat(struct pglist_data *pgdat,
 	return false;
 }
 
+struct misplaced_request
+{
+	int nid;		/* Node to migrate to */
+	struct page *newpage;	/* New location of page */
+};
+
 static struct page *alloc_misplaced_dst_page(struct page *page,
 					   unsigned long data,
 					   int **result)
 {
-	int nid = (int) data;
-	struct page *newpage;
-
-	newpage = alloc_pages_exact_node(nid,
+	struct misplaced_request *req = (struct misplaced_request *)data;
+	req->newpage = alloc_pages_exact_node(req->nid,
 					 (GFP_HIGHUSER_MOVABLE | GFP_THISNODE |
 					  __GFP_NOMEMALLOC | __GFP_NORETRY |
 					  __GFP_NOWARN) &
 					 ~GFP_IOFS, 0);
-	return newpage;
+	return req->newpage;
 }
 
 /*
@@ -1464,8 +1468,12 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
  * node. Caller is expected to have an elevated reference count on
  * the page that will be dropped by this function before returning.
  */
-int migrate_misplaced_page(struct page *page, int node)
+struct page *migrate_misplaced_page(struct page *page, int node)
 {
+	struct misplaced_request req = {
+		.nid = node,
+		.newpage = NULL,
+	};
 	int isolated = 0;
 	LIST_HEAD(migratepages);
 
@@ -1503,16 +1511,17 @@ int migrate_misplaced_page(struct page *page, int node)
 
 		nr_remaining = migrate_pages(&migratepages,
 				alloc_misplaced_dst_page,
-				node, false, MIGRATE_ASYNC,
+				(unsigned long)&req,
+				false, MIGRATE_ASYNC,
 				MR_NUMA_MISPLACED);
 		if (nr_remaining) {
 			putback_lru_pages(&migratepages);
-			isolated = 0;
+			req.newpage = NULL;
 		}
 	}
 	BUG_ON(!list_empty(&migratepages));
 out:
-	return isolated;
+	return req.newpage;
 }
 
 #endif /* CONFIG_NUMA */
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
