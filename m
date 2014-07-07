Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD9F900003
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 14:56:02 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id r20so16538121wiv.2
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 11:56:01 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id r10si42443336wiw.102.2014.07.07.11.56.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 11:56:01 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: use page lists for uncharge batching
Date: Mon,  7 Jul 2014 14:55:58 -0400
Message-Id: <1404759358-29331-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Pages are now uncharged at release time, and all sources of batched
uncharges operate on lists of pages.  Directly use those lists, and
get rid of the per-task batching state.

This also batches statistics accounting, in addition to the res
counter charges, to reduce IRQ-disabling and re-enabling.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  12 +--
 include/linux/sched.h      |   6 --
 kernel/fork.c              |   4 -
 mm/memcontrol.c            | 209 +++++++++++++++++++++++----------------------
 mm/swap.c                  |   6 +-
 mm/vmscan.c                |  12 ++-
 6 files changed, 115 insertions(+), 134 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 806b8fa15c5f..e0752d204d9e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -59,12 +59,8 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 			      bool lrucare);
 void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg);
-
 void mem_cgroup_uncharge(struct page *page);
-
-/* Batched uncharging */
-void mem_cgroup_uncharge_start(void);
-void mem_cgroup_uncharge_end(void);
+void mem_cgroup_uncharge_list(struct list_head *page_list);
 
 void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 			bool lrucare);
@@ -233,11 +229,7 @@ static inline void mem_cgroup_uncharge(struct page *page)
 {
 }
 
-static inline void mem_cgroup_uncharge_start(void)
-{
-}
-
-static inline void mem_cgroup_uncharge_end(void)
+static inline void mem_cgroup_uncharge_list(struct list_head *page_list)
 {
 }
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 306f4f0c987a..4cbf9346c771 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1634,12 +1634,6 @@ struct task_struct {
 	unsigned long trace_recursion;
 #endif /* CONFIG_TRACING */
 #ifdef CONFIG_MEMCG /* memcg uses this to do batch job */
-	struct memcg_batch_info {
-		int do_batch;	/* incremented when batch uncharge started */
-		struct mem_cgroup *memcg; /* target memcg of uncharge */
-		unsigned long nr_pages;	/* uncharged usage */
-		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
-	} memcg_batch;
 	unsigned int memcg_kmem_skip_account;
 	struct memcg_oom_info {
 		struct mem_cgroup *memcg;
diff --git a/kernel/fork.c b/kernel/fork.c
index 6a13c46cd87d..ec25e2b67781 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1307,10 +1307,6 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 #ifdef CONFIG_DEBUG_MUTEXES
 	p->blocked_on = NULL; /* not blocked yet */
 #endif
-#ifdef CONFIG_MEMCG
-	p->memcg_batch.do_batch = 0;
-	p->memcg_batch.memcg = NULL;
-#endif
 #ifdef CONFIG_BCACHE
 	p->sequential_io	= 0;
 	p->sequential_io_avg	= 0;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e4afdbdda0a7..0a6e03519b90 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3608,53 +3608,6 @@ out:
 	return ret;
 }
 
-/*
- * Batch_start/batch_end is called in unmap_page_range/invlidate/trucate.
- * In that cases, pages are freed continuously and we can expect pages
- * are in the same memcg. All these calls itself limits the number of
- * pages freed at once, then uncharge_start/end() is called properly.
- * This may be called prural(2) times in a context,
- */
-
-void mem_cgroup_uncharge_start(void)
-{
-	unsigned long flags;
-
-	local_irq_save(flags);
-	current->memcg_batch.do_batch++;
-	/* We can do nest. */
-	if (current->memcg_batch.do_batch == 1) {
-		current->memcg_batch.memcg = NULL;
-		current->memcg_batch.nr_pages = 0;
-		current->memcg_batch.memsw_nr_pages = 0;
-	}
-	local_irq_restore(flags);
-}
-
-void mem_cgroup_uncharge_end(void)
-{
-	struct memcg_batch_info *batch = &current->memcg_batch;
-	unsigned long flags;
-
-	local_irq_save(flags);
-	VM_BUG_ON(!batch->do_batch);
-	if (--batch->do_batch) /* If stacked, do nothing */
-		goto out;
-	/*
-	 * This "batch->memcg" is valid without any css_get/put etc...
-	 * bacause we hide charges behind us.
-	 */
-	if (batch->nr_pages)
-		res_counter_uncharge(&batch->memcg->res,
-				     batch->nr_pages * PAGE_SIZE);
-	if (batch->memsw_nr_pages)
-		res_counter_uncharge(&batch->memcg->memsw,
-				     batch->memsw_nr_pages * PAGE_SIZE);
-	memcg_oom_recover(batch->memcg);
-out:
-	local_irq_restore(flags);
-}
-
 #ifdef CONFIG_MEMCG_SWAP
 static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
 					 bool charge)
@@ -6552,6 +6505,98 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg)
 	cancel_charge(memcg, nr_pages);
 }
 
+static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
+			   unsigned long nr_mem, unsigned long nr_memsw,
+			   unsigned long nr_anon, unsigned long nr_file,
+			   unsigned long nr_huge, struct page *dummy_page)
+{
+	unsigned long flags;
+
+	if (nr_mem)
+		res_counter_uncharge(&memcg->res, nr_mem * PAGE_SIZE);
+	if (nr_memsw)
+		res_counter_uncharge(&memcg->memsw, nr_memsw * PAGE_SIZE);
+
+	memcg_oom_recover(memcg);
+
+	local_irq_save(flags);
+	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS], nr_anon);
+	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_CACHE], nr_file);
+	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE], nr_huge);
+	__this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT], pgpgout);
+	__this_cpu_add(memcg->stat->nr_page_events, nr_anon + nr_file);
+	memcg_check_events(memcg, dummy_page);
+	local_irq_restore(flags);
+}
+
+static void uncharge_list(struct list_head *page_list)
+{
+	struct mem_cgroup *memcg = NULL;
+	unsigned long nr_memsw = 0;
+	unsigned long nr_anon = 0;
+	unsigned long nr_file = 0;
+	unsigned long nr_huge = 0;
+	unsigned long pgpgout = 0;
+	unsigned long nr_mem = 0;
+	struct list_head *next;
+	struct page *page;
+
+	next = page_list->next;
+	do {
+		unsigned int nr_pages = 1;
+		struct page_cgroup *pc;
+
+		page = list_entry(next, struct page, lru);
+		next = page->lru.next;
+
+		VM_BUG_ON_PAGE(PageLRU(page), page);
+		VM_BUG_ON_PAGE(page_count(page), page);
+
+		pc = lookup_page_cgroup(page);
+		if (!PageCgroupUsed(pc))
+			continue;
+
+		/*
+		 * Nobody should be changing or seriously looking at
+		 * pc->mem_cgroup and pc->flags at this point, we have
+		 * fully exclusive access to the page.
+		 */
+
+		if (memcg != pc->mem_cgroup) {
+			if (memcg) {
+				uncharge_batch(memcg, pgpgout, nr_mem, nr_memsw,
+					       nr_anon, nr_file, nr_huge, page);
+				pgpgout = nr_mem = nr_memsw = 0;
+				nr_anon = nr_file = nr_huge = 0;
+			}
+			memcg = pc->mem_cgroup;
+		}
+
+		if (PageTransHuge(page)) {
+			nr_pages <<= compound_order(page);
+			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
+			nr_huge += nr_pages;
+		}
+
+		if (PageAnon(page))
+			nr_anon += nr_pages;
+		else
+			nr_file += nr_pages;
+
+		if (pc->flags & PCG_MEM)
+			nr_mem += nr_pages;
+		if (pc->flags & PCG_MEMSW)
+			nr_memsw += nr_pages;
+		pc->flags = 0;
+
+		pgpgout++;
+	} while (next != page_list);
+
+	if (memcg)
+		uncharge_batch(memcg, pgpgout, nr_mem, nr_memsw,
+			       nr_anon, nr_file, nr_huge, page);
+}
+
 /**
  * mem_cgroup_uncharge - uncharge a page
  * @page: page to uncharge
@@ -6561,67 +6606,27 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg)
  */
 void mem_cgroup_uncharge(struct page *page)
 {
-	struct memcg_batch_info *batch;
-	unsigned int nr_pages = 1;
-	struct mem_cgroup *memcg;
-	struct page_cgroup *pc;
-	unsigned long pc_flags;
-	unsigned long flags;
-
-	VM_BUG_ON_PAGE(PageLRU(page), page);
-	VM_BUG_ON_PAGE(page_count(page), page);
-
 	if (mem_cgroup_disabled())
 		return;
 
-	pc = lookup_page_cgroup(page);
+	INIT_LIST_HEAD(&page->lru);
+	uncharge_list(&page->lru);
+}
 
-	/* Every final put_page() ends up here */
-	if (!PageCgroupUsed(pc))
+/**
+ * mem_cgroup_uncharge_list - uncharge a list of page
+ * @page_list: list of pages to uncharge
+ *
+ * Uncharge a list of pages previously charged with
+ * mem_cgroup_try_charge() and mem_cgroup_commit_charge().
+ */
+void mem_cgroup_uncharge_list(struct list_head *page_list)
+{
+	if (mem_cgroup_disabled())
 		return;
 
-	if (PageTransHuge(page)) {
-		nr_pages <<= compound_order(page);
-		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-	}
-	/*
-	 * Nobody should be changing or seriously looking at
-	 * pc->mem_cgroup and pc->flags at this point, we have fully
-	 * exclusive access to the page.
-	 */
-	memcg = pc->mem_cgroup;
-	pc_flags = pc->flags;
-	pc->flags = 0;
-
-	local_irq_save(flags);
-
-	if (nr_pages > 1)
-		goto direct;
-	if (unlikely(test_thread_flag(TIF_MEMDIE)))
-		goto direct;
-	batch = &current->memcg_batch;
-	if (!batch->do_batch)
-		goto direct;
-	if (batch->memcg && batch->memcg != memcg)
-		goto direct;
-	if (!batch->memcg)
-		batch->memcg = memcg;
-	if (pc_flags & PCG_MEM)
-		batch->nr_pages++;
-	if (pc_flags & PCG_MEMSW)
-		batch->memsw_nr_pages++;
-	goto out;
-direct:
-	if (pc_flags & PCG_MEM)
-		res_counter_uncharge(&memcg->res, nr_pages * PAGE_SIZE);
-	if (pc_flags & PCG_MEMSW)
-		res_counter_uncharge(&memcg->memsw, nr_pages * PAGE_SIZE);
-	memcg_oom_recover(memcg);
-out:
-	mem_cgroup_charge_statistics(memcg, page, -nr_pages);
-	memcg_check_events(memcg, page);
-
-	local_irq_restore(flags);
+	if (!list_empty(page_list))
+		uncharge_list(page_list);
 }
 
 /**
diff --git a/mm/swap.c b/mm/swap.c
index 3074210f245d..faff258ec630 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -916,8 +916,6 @@ void release_pages(struct page **pages, int nr, bool cold)
 	struct lruvec *lruvec;
 	unsigned long uninitialized_var(flags);
 
-	mem_cgroup_uncharge_start();
-
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
@@ -949,7 +947,6 @@ void release_pages(struct page **pages, int nr, bool cold)
 			__ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		}
-		mem_cgroup_uncharge(page);
 
 		/* Clear Active bit in case of parallel mark_page_accessed */
 		__ClearPageActive(page);
@@ -959,8 +956,7 @@ void release_pages(struct page **pages, int nr, bool cold)
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 
-	mem_cgroup_uncharge_end();
-
+	mem_cgroup_uncharge_list(&pages_to_free);
 	free_hot_cold_page_list(&pages_to_free, cold);
 }
 EXPORT_SYMBOL(release_pages);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 521f7eab1798..ab9eea7622c8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -816,7 +816,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 	cond_resched();
 
-	mem_cgroup_uncharge_start();
 	while (!list_empty(page_list)) {
 		struct address_space *mapping;
 		struct page *page;
@@ -1097,7 +1096,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		__clear_page_locked(page);
 free_it:
-		mem_cgroup_uncharge(page);
 		nr_reclaimed++;
 
 		/*
@@ -1127,8 +1125,8 @@ keep:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), page);
 	}
-	mem_cgroup_uncharge_end();
 
+	mem_cgroup_uncharge_list(&free_pages);
 	free_hot_cold_page_list(&free_pages, true);
 
 	list_splice(&ret_pages, page_list);
@@ -1431,10 +1429,9 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 			__ClearPageActive(page);
 			del_page_from_lru_list(page, lruvec, lru);
 
-			mem_cgroup_uncharge(page);
-
 			if (unlikely(PageCompound(page))) {
 				spin_unlock_irq(&zone->lru_lock);
+				mem_cgroup_uncharge(page);
 				(*get_compound_page_dtor(page))(page);
 				spin_lock_irq(&zone->lru_lock);
 			} else
@@ -1542,6 +1539,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	spin_unlock_irq(&zone->lru_lock);
 
+	mem_cgroup_uncharge_list(&page_list);
 	free_hot_cold_page_list(&page_list, true);
 
 	/*
@@ -1654,10 +1652,9 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
 			__ClearPageActive(page);
 			del_page_from_lru_list(page, lruvec, lru);
 
-			mem_cgroup_uncharge(page);
-
 			if (unlikely(PageCompound(page))) {
 				spin_unlock_irq(&zone->lru_lock);
+				mem_cgroup_uncharge(page);
 				(*get_compound_page_dtor(page))(page);
 				spin_lock_irq(&zone->lru_lock);
 			} else
@@ -1765,6 +1762,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
 
+	mem_cgroup_uncharge_list(&l_hold);
 	free_hot_cold_page_list(&l_hold, true);
 }
 
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
