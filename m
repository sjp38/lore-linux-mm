Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 7880B6B0070
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 03:18:18 -0500 (EST)
Received: by pdno5 with SMTP id o5so31752767pdn.8
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 00:18:18 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id bf5si42566674pbd.252.2015.02.24.00.18.16
        for <linux-mm@kvack.org>;
        Tue, 24 Feb 2015 00:18:17 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH RFC 3/4] mm: move lazy free pages to inactive list
Date: Tue, 24 Feb 2015 17:18:16 +0900
Message-Id: <1424765897-27377-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1424765897-27377-1-git-send-email-minchan@kernel.org>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Minchan Kim <minchan@kernel.org>

MADV_FREE is hint that it's okay to discard pages if memory is
pressure and we uses reclaimers(ie, kswapd and direct reclaim)
to free them so there is no worth to remain them in active
anonymous LRU list so this patch moves them to inactive LRU list.

A arguable issue for the approach is whether we should put it
head or tail in inactive list and selected it as head because
kernel cannot make sure it's really cold or warm for every usecase
but at least we know it's not hot so landing of inactive head
would be comprimise if it stayed in active LRU.
As well, if we put recent hinted pages to inactive's tail,
VM could discard cache hot pages, which would be bad.

As a bonus, we don't need to move them back and forth in inactive
list whenever MADV_SYSCALL syscall is called.

As drawback, VM should scan more pages in inactive anonymous LRU
to discard but it has happened all the time if recent reference
happens on those pages in inactive LRU list so I don't think
it's not a main drawback.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h |  1 +
 mm/madvise.c         |  2 ++
 mm/swap.c            | 35 +++++++++++++++++++++++++++++++++++
 3 files changed, 38 insertions(+)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index cee108cbe2d5..0428e4c84e1d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -308,6 +308,7 @@ extern void lru_add_drain_cpu(int cpu);
 extern void lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_file_page(struct page *page);
+extern void deactivate_page(struct page *page);
 extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
diff --git a/mm/madvise.c b/mm/madvise.c
index 81bb26ecf064..6176039c69e4 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -324,6 +324,8 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 		ptent = pte_mkold(ptent);
 		ptent = pte_mkclean(ptent);
 		set_pte_at(mm, addr, pte, ptent);
+		if (PageActive(page))
+			deactivate_page(page);
 		tlb_remove_tlb_entry(tlb, pte, addr);
 	}
 	arch_leave_lazy_mmu_mode();
diff --git a/mm/swap.c b/mm/swap.c
index 5b2a60578f9c..393968c33667 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -43,6 +43,7 @@ int page_cluster;
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -789,6 +790,23 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 	update_page_reclaim_stat(lruvec, file, 0);
 }
 
+
+static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
+			    void *arg)
+{
+	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
+		int file = page_is_file_cache(page);
+		int lru = page_lru_base_type(page);
+
+		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
+		ClearPageActive(page);
+		add_page_to_lru_list(page, lruvec, lru);
+
+		__count_vm_event(PGDEACTIVATE);
+		update_page_reclaim_stat(lruvec, file, 0);
+	}
+}
+
 /*
  * Drain pages out of the cpu's pagevecs.
  * Either "cpu" is the current CPU, and preemption has already been
@@ -815,6 +833,10 @@ void lru_add_drain_cpu(int cpu)
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
 
+	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	if (pagevec_count(pvec))
+		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+
 	activate_page_drain(cpu);
 }
 
@@ -844,6 +866,18 @@ void deactivate_file_page(struct page *page)
 	}
 }
 
+void deactivate_page(struct page *page)
+{
+	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
+		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
+
+		page_cache_get(page);
+		if (!pagevec_add(pvec, page))
+			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+		put_cpu_var(lru_deactivate_pvecs);
+	}
+}
+
 void lru_add_drain(void)
 {
 	lru_add_drain_cpu(get_cpu());
@@ -873,6 +907,7 @@ void lru_add_drain_all(void)
 		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
 		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
+		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			schedule_work_on(cpu, work);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
