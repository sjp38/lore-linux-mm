Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D71B6B0290
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 00:51:26 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z67so443569396pgb.0
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:26 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u84si7717838pgb.258.2017.01.29.21.51.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 21:51:25 -0800 (PST)
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U5oDlQ027754
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:24 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 288r78dnkm-3
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:24 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 21b984d0e6b011e6ac470002c99293a0-721f6a50 for <linux-mm@kvack.org>;	Sun, 29
 Jan 2017 21:51:23 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 4/6] mm: move MADV_FREE pages into LRU_LAZYFREE list
Date: Sun, 29 Jan 2017 21:51:21 -0800
Message-ID: <5d54eafab07025a126914c48aa2166cde4afa71e.1485748619.git.shli@fb.com>
In-Reply-To: <cover.1485748619.git.shli@fb.com>
References: <cover.1485748619.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net

Move the MADV_FREE pages into LRU_LAZYFREE list. The reason why we need
to do this is described in last patch. Next patch will reclaim the
pages.

The patch is based on Minchan's previous patch.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/linux/swap.h |  2 +-
 mm/huge_memory.c     |  5 ++---
 mm/madvise.c         |  3 +--
 mm/swap.c            | 51 +++++++++++++++++++++++++++++----------------------
 4 files changed, 33 insertions(+), 28 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 45e91dd..e35bef5 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -279,7 +279,7 @@ extern void lru_add_drain_cpu(int cpu);
 extern void lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_file_page(struct page *page);
-extern void deactivate_page(struct page *page);
+extern void move_page_to_lazyfree_list(struct page *page);
 extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index ffa7ed5..57daef7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1391,9 +1391,6 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		ClearPageDirty(page);
 	unlock_page(page);
 
-	if (PageActive(page))
-		deactivate_page(page);
-
 	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
 		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
 			tlb->fullmm);
@@ -1404,6 +1401,8 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		set_pmd_at(mm, addr, pmd, orig_pmd);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 	}
+
+	move_page_to_lazyfree_list(page);
 	ret = true;
 out:
 	spin_unlock(ptl);
diff --git a/mm/madvise.c b/mm/madvise.c
index c867d88..78b4b02 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -378,10 +378,9 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 			ptent = pte_mkclean(ptent);
 			ptent = pte_wrprotect(ptent);
 			set_pte_at(mm, addr, pte, ptent);
-			if (PageActive(page))
-				deactivate_page(page);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 		}
+		move_page_to_lazyfree_list(page);
 	}
 out:
 	if (nr_swap) {
diff --git a/mm/swap.c b/mm/swap.c
index c4910f1..f9e70e8 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -46,7 +46,7 @@ int page_cluster;
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
-static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_lazyfree_pvecs);
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
 #endif
@@ -268,6 +268,10 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 		int lru = page_lru_base_type(page);
 
 		del_page_from_lru_list(page, lruvec, lru);
+		if (lru == LRU_LAZYFREE) {
+			ClearPageLazyFree(page);
+			lru = LRU_INACTIVE_ANON;
+		}
 		SetPageActive(page);
 		lru += LRU_ACTIVE;
 		add_page_to_lru_list(page, lruvec, lru);
@@ -455,6 +459,8 @@ void add_page_to_unevictable_list(struct page *page)
 	ClearPageActive(page);
 	SetPageUnevictable(page);
 	SetPageLRU(page);
+	if (page_is_lazyfree(page))
+		ClearPageLazyFree(page);
 	add_page_to_lru_list(page, lruvec, LRU_UNEVICTABLE);
 	spin_unlock_irq(&pgdat->lru_lock);
 }
@@ -561,20 +567,21 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 }
 
 
-static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
+static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
 			    void *arg)
 {
-	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
-		int file = page_is_file_cache(page);
-		int lru = page_lru_base_type(page);
+	if (PageLRU(page) && PageSwapBacked(page) && !PageLazyFree(page) &&
+	    !PageUnevictable(page)) {
+		unsigned int nr_pages = PageTransHuge(page) ? HPAGE_PMD_NR : 1;
+		bool active = PageActive(page);
 
-		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
+		del_page_from_lru_list(page, lruvec, LRU_INACTIVE_ANON + active);
 		ClearPageActive(page);
 		ClearPageReferenced(page);
-		add_page_to_lru_list(page, lruvec, lru);
+		SetPageLazyFree(page);
+		add_page_to_lru_list(page, lruvec, LRU_LAZYFREE);
 
-		__count_vm_event(PGDEACTIVATE);
-		update_page_reclaim_stat(lruvec, file, 0);
+		count_vm_events(PGLAZYFREE, nr_pages);
 	}
 }
 
@@ -604,9 +611,9 @@ void lru_add_drain_cpu(int cpu)
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
 
-	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	pvec = &per_cpu(lru_lazyfree_pvecs, cpu);
 	if (pagevec_count(pvec))
-		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+		pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
 
 	activate_page_drain(cpu);
 }
@@ -638,22 +645,22 @@ void deactivate_file_page(struct page *page)
 }
 
 /**
- * deactivate_page - deactivate a page
- * @page: page to deactivate
+ * move_page_to_lazyfree_list - move anon page to lazyfree list
+ * @page: page to move
  *
- * deactivate_page() moves @page to the inactive list if @page was on the active
- * list and was not an unevictable page.  This is done to accelerate the reclaim
- * of @page.
+ * This function moves @page to the lazyfree list after the page is the target
+ * of a MADV_FREE syscall. This is to accelerate the reclaim of the @page
  */
-void deactivate_page(struct page *page)
+void move_page_to_lazyfree_list(struct page *page)
 {
-	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
-		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
+	if (PageLRU(page) && PageSwapBacked(page) && !PageLazyFree(page) &&
+	    !PageUnevictable(page)) {
+		struct pagevec *pvec = &get_cpu_var(lru_lazyfree_pvecs);
 
 		get_page(page);
 		if (!pagevec_add(pvec, page) || PageCompound(page))
-			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
-		put_cpu_var(lru_deactivate_pvecs);
+			pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
+		put_cpu_var(lru_lazyfree_pvecs);
 	}
 }
 
@@ -704,7 +711,7 @@ void lru_add_drain_all(void)
 		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
 		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
+		    pagevec_count(&per_cpu(lru_lazyfree_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			queue_work_on(cpu, lru_add_drain_wq, work);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
