Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id F203A6B0258
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 03:02:56 -0500 (EST)
Received: by pacej9 with SMTP id ej9so109220619pac.2
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 00:02:56 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id eo5si17978500pbb.133.2015.11.20.00.02.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 00:02:48 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 05/16] mm: move lazily freed pages to inactive list
Date: Fri, 20 Nov 2015 17:02:37 +0900
Message-Id: <1448006568-16031-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1448006568-16031-1-git-send-email-minchan@kernel.org>
References: <1448006568-16031-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>, "Wang, Yalin" <Yalin.Wang@sonymobile.com>

MADV_FREE is a hint that it's okay to discard pages if there is memory
pressure and we use reclaimers(ie, kswapd and direct reclaim) to free them
so there is no value keeping them in the active anonymous LRU so this
patch moves them to inactive LRU list's head.

This means that MADV_FREE-ed pages which were living on the inactive list
are reclaimed first because they are more likely to be cold rather than
recently active pages.

An arguable issue for the approach would be whether we should put the page
to the head or tail of the inactive list.  I chose head because the kernel
cannot make sure it's really cold or warm for every MADV_FREE usecase but
at least we know it's not *hot*, so landing of inactive head would be a
comprimise for various usecases.

This fixes suboptimal behavior of MADV_FREE when pages living on the
active list will sit there for a long time even under memory pressure
while the inactive list is reclaimed heavily.  This basically breaks the
whole purpose of using MADV_FREE to help the system to free memory which
is might not be used.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Wang, Yalin <Yalin.Wang@sonymobile.com>
Acked-by: Hugh Dickins <hughd@google.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h |  1 +
 mm/madvise.c         |  2 ++
 mm/swap.c            | 44 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 47 insertions(+)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7ba7dccaf0e7..f629df4cc13d 100644
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
index c8e23102fc99..60e4d7f8ea16 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -340,6 +340,8 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 			ptent = pte_mkold(ptent);
 			ptent = pte_mkclean(ptent);
 			set_pte_at(mm, addr, pte, ptent);
+			if (PageActive(page))
+				deactivate_page(page);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 		}
 	}
diff --git a/mm/swap.c b/mm/swap.c
index 983f692a47fd..4a6aec976ab1 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -45,6 +45,7 @@ int page_cluster;
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -799,6 +800,24 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
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
+		ClearPageReferenced(page);
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
@@ -825,6 +844,10 @@ void lru_add_drain_cpu(int cpu)
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
 
+	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	if (pagevec_count(pvec))
+		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+
 	activate_page_drain(cpu);
 }
 
@@ -854,6 +877,26 @@ void deactivate_file_page(struct page *page)
 	}
 }
 
+/**
+ * deactivate_page - deactivate a page
+ * @page: page to deactivate
+ *
+ * deactivate_page() moves @page to the inactive list if @page was on the active
+ * list and was not an unevictable page.  This is done to accelerate the reclaim
+ * of @page.
+ */
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
@@ -883,6 +926,7 @@ void lru_add_drain_all(void)
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
