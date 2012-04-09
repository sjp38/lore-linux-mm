Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 350BC6B004D
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 11:32:14 -0400 (EDT)
Date: Mon, 9 Apr 2012 11:32:01 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] remove swap token code
Message-ID: <20120409113201.6dff571a@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

The swap token code no longer fits in with the current VM model.
It does not play well with cgroups or the better NUMA placement
code in development, since we have only one swap token globally.

It also has the potential to mess with scalability of the system,
by increasing the number of non-reclaimable pages on the active
and inactive anon LRU lists.

Last but not least, the swap token code has been broken for a
year without complaints.  This suggests we no longer have much
use for it.

The days of sub-1G memory systems with heavy use of swap are
over. If we ever need thrashing reducing code in the future,
we will have to implement something that does scale.

Signed-off-by: Rik van Riel <riel@redhat.com>
--- 
 b/include/linux/mm_types.h      |   12 ---
 b/include/linux/swap.h          |   69 -----------------
 b/include/trace/events/vmscan.h |   82 ---------------------
 b/kernel/fork.c                 |   10 --
 b/mm/Makefile                   |    2 
 b/mm/memcontrol.c               |    1 
 b/mm/memory.c                   |   13 ---
 b/mm/rmap.c                     |    5 -
 b/mm/vmscan.c                   |    6 -
 mm/thrash.c                     |  155 ----------------------------------------
 10 files changed, 1 insertion(+), 354 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index a87eefb..dad95bd 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -345,18 +345,6 @@ struct mm_struct {
 	/* Architecture-specific MM context */
 	mm_context_t context;
 
-	/* Swap token stuff */
-	/*
-	 * Last value of global fault stamp as seen by this process.
-	 * In other words, this value gives an indication of how long
-	 * it has been since this task got the token.
-	 * Look at mm/thrash.c
-	 */
-	unsigned int faultstamp;
-	unsigned int token_priority;
-	unsigned int last_interval;
-	atomic_t active_swap_token;
-
 	unsigned long flags; /* Must use atomic bitops to access the bits */
 
 	struct core_state *core_state; /* coredumping support */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 6bc6768..77e7d68 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -354,43 +354,6 @@ extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
 
-/* linux/mm/thrash.c */
-extern struct mm_struct *swap_token_mm;
-extern void grab_swap_token(struct mm_struct *);
-extern void __put_swap_token(struct mm_struct *);
-extern void disable_swap_token(struct mem_cgroup *memcg);
-
-static inline int has_swap_token(struct mm_struct *mm)
-{
-	return (mm == swap_token_mm);
-}
-
-static inline void put_swap_token(struct mm_struct *mm)
-{
-	if (has_swap_token(mm))
-		__put_swap_token(mm);
-}
-
-static inline bool has_active_swap_token(struct mm_struct *mm)
-{
-	return has_swap_token(mm) && atomic_read(&mm->active_swap_token);
-}
-
-static inline bool activate_swap_token(struct mm_struct *mm)
-{
-	if (has_swap_token(mm)) {
-		atomic_inc(&mm->active_swap_token);
-		return true;
-	}
-	return false;
-}
-
-static inline void deactivate_swap_token(struct mm_struct *mm, bool swap_token)
-{
-	if (swap_token)
-		atomic_dec(&mm->active_swap_token);
-}
-
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout);
@@ -501,38 +464,6 @@ static inline swp_entry_t get_swap_page(void)
 	return entry;
 }
 
-/* linux/mm/thrash.c */
-static inline void put_swap_token(struct mm_struct *mm)
-{
-}
-
-static inline void grab_swap_token(struct mm_struct *mm)
-{
-}
-
-static inline int has_swap_token(struct mm_struct *mm)
-{
-	return 0;
-}
-
-static inline bool has_active_swap_token(struct mm_struct *mm)
-{
-	return false;
-}
-
-static inline bool activate_swap_token(struct mm_struct *mm)
-{
-	return false;
-}
-
-static inline void deactivate_swap_token(struct mm_struct *mm, bool swap_token)
-{
-}
-
-static inline void disable_swap_token(struct mem_cgroup *memcg)
-{
-}
-
 static inline void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 {
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index f64560e..5721954 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -395,88 +395,6 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 		show_reclaim_flags(__entry->reclaim_flags))
 );
 
-TRACE_EVENT(replace_swap_token,
-	TP_PROTO(struct mm_struct *old_mm,
-		 struct mm_struct *new_mm),
-
-	TP_ARGS(old_mm, new_mm),
-
-	TP_STRUCT__entry(
-		__field(struct mm_struct*,	old_mm)
-		__field(unsigned int,		old_prio)
-		__field(struct mm_struct*,	new_mm)
-		__field(unsigned int,		new_prio)
-	),
-
-	TP_fast_assign(
-		__entry->old_mm   = old_mm;
-		__entry->old_prio = old_mm ? old_mm->token_priority : 0;
-		__entry->new_mm   = new_mm;
-		__entry->new_prio = new_mm->token_priority;
-	),
-
-	TP_printk("old_token_mm=%p old_prio=%u new_token_mm=%p new_prio=%u",
-		  __entry->old_mm, __entry->old_prio,
-		  __entry->new_mm, __entry->new_prio)
-);
-
-DECLARE_EVENT_CLASS(put_swap_token_template,
-	TP_PROTO(struct mm_struct *swap_token_mm),
-
-	TP_ARGS(swap_token_mm),
-
-	TP_STRUCT__entry(
-		__field(struct mm_struct*, swap_token_mm)
-	),
-
-	TP_fast_assign(
-		__entry->swap_token_mm = swap_token_mm;
-	),
-
-	TP_printk("token_mm=%p", __entry->swap_token_mm)
-);
-
-DEFINE_EVENT(put_swap_token_template, put_swap_token,
-	TP_PROTO(struct mm_struct *swap_token_mm),
-	TP_ARGS(swap_token_mm)
-);
-
-DEFINE_EVENT_CONDITION(put_swap_token_template, disable_swap_token,
-	TP_PROTO(struct mm_struct *swap_token_mm),
-	TP_ARGS(swap_token_mm),
-	TP_CONDITION(swap_token_mm != NULL)
-);
-
-TRACE_EVENT_CONDITION(update_swap_token_priority,
-	TP_PROTO(struct mm_struct *mm,
-		 unsigned int old_prio,
-		 struct mm_struct *swap_token_mm),
-
-	TP_ARGS(mm, old_prio, swap_token_mm),
-
-	TP_CONDITION(mm->token_priority != old_prio),
-
-	TP_STRUCT__entry(
-		__field(struct mm_struct*, mm)
-		__field(unsigned int, old_prio)
-		__field(unsigned int, new_prio)
-		__field(struct mm_struct*, swap_token_mm)
-		__field(unsigned int, swap_token_prio)
-	),
-
-	TP_fast_assign(
-		__entry->mm		= mm;
-		__entry->old_prio	= old_prio;
-		__entry->new_prio	= mm->token_priority;
-		__entry->swap_token_mm	= swap_token_mm;
-		__entry->swap_token_prio = swap_token_mm ? swap_token_mm->token_priority : 0;
-	),
-
-	TP_printk("mm=%p old_prio=%u new_prio=%u swap_token_mm=%p token_prio=%u",
-		  __entry->mm, __entry->old_prio, __entry->new_prio,
-		  __entry->swap_token_mm, __entry->swap_token_prio)
-);
-
 #endif /* _TRACE_VMSCAN_H */
 
 /* This part must be outside protection */
diff --git a/kernel/fork.c b/kernel/fork.c
index f69154e..82abcfe 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -584,7 +584,6 @@ void mmput(struct mm_struct *mm)
 			list_del(&mm->mmlist);
 			spin_unlock(&mmlist_lock);
 		}
-		put_swap_token(mm);
 		if (mm->binfmt)
 			module_put(mm->binfmt->module);
 		mmdrop(mm);
@@ -801,11 +800,6 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 	memcpy(mm, oldmm, sizeof(*mm));
 	mm_init_cpumask(mm);
 
-	/* Initializing for Swap token stuff */
-	mm->token_priority = 0;
-	mm->last_interval = 0;
-	atomic_set(&mm->active_swap_token, 0);
-
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	mm->pmd_huge_pte = NULL;
 #endif
@@ -884,10 +878,6 @@ static int copy_mm(unsigned long clone_flags, struct task_struct *tsk)
 		goto fail_nomem;
 
 good_mm:
-	/* Initializing for Swap token stuff */
-	mm->token_priority = 0;
-	mm->last_interval = 0;
-
 	tsk->mm = mm;
 	tsk->active_mm = mm;
 	return 0;
diff --git a/mm/Makefile b/mm/Makefile
index 306742a..5736c81 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -25,7 +25,7 @@ endif
 obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
 
 obj-$(CONFIG_BOUNCE)	+= bounce.o
-obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
+obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o
 obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fa01106..4068ccb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5558,7 +5558,6 @@ static void mem_cgroup_move_task(struct cgroup *cont,
 	if (mm) {
 		if (mc.to)
 			mem_cgroup_move_charge(mm);
-		put_swap_token(mm);
 		mmput(mm);
 	}
 	if (mc.to)
diff --git a/mm/memory.c b/mm/memory.c
index cdc4b4c..3df0b44 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2892,7 +2892,6 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct mem_cgroup *ptr;
 	int exclusive = 0;
 	int ret = 0;
-	bool swap_token;
 
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
 		goto out;
@@ -2912,7 +2911,6 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
 	page = lookup_swap_cache(entry);
 	if (!page) {
-		grab_swap_token(mm); /* Contend for token _before_ read-in */
 		page = swapin_readahead(entry,
 					GFP_HIGHUSER_MOVABLE, vma, address);
 		if (!page) {
@@ -2941,12 +2939,8 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto out_release;
 	}
 
-	swap_token = activate_swap_token(mm);
-
 	locked = lock_page_or_retry(page, mm, flags);
 
-	deactivate_swap_token(mm, swap_token);
-
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 	if (!locked) {
 		ret |= VM_FAULT_RETRY;
@@ -3193,7 +3187,6 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct vm_fault vmf;
 	int ret;
 	int page_mkwrite = 0;
-	bool swap_token;
 
 	/*
 	 * If we do COW later, allocate page befor taking lock_page()
@@ -3215,8 +3208,6 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	} else
 		cow_page = NULL;
 
-	swap_token = activate_swap_token(mm);
-
 	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
 	vmf.pgoff = pgoff;
 	vmf.flags = flags;
@@ -3285,8 +3276,6 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	}
 
-	deactivate_swap_token(mm, swap_token);
-
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 
 	/*
@@ -3358,11 +3347,9 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return ret;
 
 unwritable_page:
-	deactivate_swap_token(mm, swap_token);
 	page_cache_release(page);
 	return ret;
 uncharge_out:
-	deactivate_swap_token(mm, swap_token);
 	/* fs's fault handler get error */
 	if (cow_page) {
 		mem_cgroup_uncharge_page(cow_page);
diff --git a/mm/rmap.c b/mm/rmap.c
index 36d01a2..0f3b7cd 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -755,11 +755,6 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		pte_unmap_unlock(pte, ptl);
 	}
 
-	/* Pretend the page is referenced if the task has the
-	   swap token and is in the middle of a page fault. */
-	if (mm != current->mm && has_active_swap_token(mm))
-		referenced++;
-
 	(*mapcount)--;
 
 	if (referenced)
diff --git a/mm/thrash.c b/mm/thrash.c
deleted file mode 100644
index 57ad495..0000000
--- a/mm/thrash.c
+++ /dev/null
@@ -1,155 +0,0 @@
-/*
- * mm/thrash.c
- *
- * Copyright (C) 2004, Red Hat, Inc.
- * Copyright (C) 2004, Rik van Riel <riel@redhat.com>
- * Released under the GPL, see the file COPYING for details.
- *
- * Simple token based thrashing protection, using the algorithm
- * described in: http://www.cse.ohio-state.edu/hpcs/WWW/HTML/publications/abs05-1.html
- *
- * Sep 2006, Ashwin Chaugule <ashwin.chaugule@celunite.com>
- * Improved algorithm to pass token:
- * Each task has a priority which is incremented if it contended
- * for the token in an interval less than its previous attempt.
- * If the token is acquired, that task's priority is boosted to prevent
- * the token from bouncing around too often and to let the task make
- * some progress in its execution.
- */
-
-#include <linux/jiffies.h>
-#include <linux/mm.h>
-#include <linux/sched.h>
-#include <linux/swap.h>
-#include <linux/memcontrol.h>
-
-#include <trace/events/vmscan.h>
-
-#define TOKEN_AGING_INTERVAL	(0xFF)
-
-static DEFINE_SPINLOCK(swap_token_lock);
-struct mm_struct *swap_token_mm;
-static struct mem_cgroup *swap_token_memcg;
-
-#ifdef CONFIG_CGROUP_MEM_RES_CTLR
-static struct mem_cgroup *swap_token_memcg_from_mm(struct mm_struct *mm)
-{
-	struct mem_cgroup *memcg;
-
-	memcg = try_get_mem_cgroup_from_mm(mm);
-	if (memcg)
-		css_put(mem_cgroup_css(memcg));
-
-	return memcg;
-}
-#else
-static struct mem_cgroup *swap_token_memcg_from_mm(struct mm_struct *mm)
-{
-	return NULL;
-}
-#endif
-
-void grab_swap_token(struct mm_struct *mm)
-{
-	int current_interval;
-	unsigned int old_prio = mm->token_priority;
-	static unsigned int global_faults;
-	static unsigned int last_aging;
-
-	global_faults++;
-
-	current_interval = global_faults - mm->faultstamp;
-
-	if (!spin_trylock(&swap_token_lock))
-		return;
-
-	/* First come first served */
-	if (!swap_token_mm)
-		goto replace_token;
-
-	/*
-	 * Usually, we don't need priority aging because long interval faults
-	 * makes priority decrease quickly. But there is one exception. If the
-	 * token owner task is sleeping, it never make long interval faults.
-	 * Thus, we need a priority aging mechanism instead. The requirements
-	 * of priority aging are
-	 *  1) An aging interval is reasonable enough long. Too short aging
-	 *     interval makes quick swap token lost and decrease performance.
-	 *  2) The swap token owner task have to get priority aging even if
-	 *     it's under sleep.
-	 */
-	if ((global_faults - last_aging) > TOKEN_AGING_INTERVAL) {
-		swap_token_mm->token_priority /= 2;
-		last_aging = global_faults;
-	}
-
-	if (mm == swap_token_mm) {
-		mm->token_priority += 2;
-		goto update_priority;
-	}
-
-	if (current_interval < mm->last_interval)
-		mm->token_priority++;
-	else {
-		if (likely(mm->token_priority > 0))
-			mm->token_priority--;
-	}
-
-	/* Check if we deserve the token */
-	if (mm->token_priority > swap_token_mm->token_priority)
-		goto replace_token;
-
-update_priority:
-	trace_update_swap_token_priority(mm, old_prio, swap_token_mm);
-
-out:
-	mm->faultstamp = global_faults;
-	mm->last_interval = current_interval;
-	spin_unlock(&swap_token_lock);
-	return;
-
-replace_token:
-	mm->token_priority += 2;
-	trace_replace_swap_token(swap_token_mm, mm);
-	swap_token_mm = mm;
-	swap_token_memcg = swap_token_memcg_from_mm(mm);
-	last_aging = global_faults;
-	goto out;
-}
-
-/* Called on process exit. */
-void __put_swap_token(struct mm_struct *mm)
-{
-	spin_lock(&swap_token_lock);
-	if (likely(mm == swap_token_mm)) {
-		trace_put_swap_token(swap_token_mm);
-		swap_token_mm = NULL;
-		swap_token_memcg = NULL;
-	}
-	spin_unlock(&swap_token_lock);
-}
-
-static bool match_memcg(struct mem_cgroup *a, struct mem_cgroup *b)
-{
-	if (!a)
-		return true;
-	if (!b)
-		return true;
-	if (a == b)
-		return true;
-	return false;
-}
-
-void disable_swap_token(struct mem_cgroup *memcg)
-{
-	/* memcg reclaim don't disable unrelated mm token. */
-	if (match_memcg(memcg, swap_token_memcg)) {
-		spin_lock(&swap_token_lock);
-		if (match_memcg(memcg, swap_token_memcg)) {
-			trace_disable_swap_token(swap_token_mm);
-			swap_token_mm = NULL;
-			swap_token_memcg = NULL;
-		}
-		spin_unlock(&swap_token_lock);
-	}
-}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 479bd7a..b42a8e4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2317,8 +2317,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc->nr_scanned = 0;
-		if (!priority)
-			disable_swap_token(sc->target_mem_cgroup);
 		aborted_reclaim = shrink_zones(priority, zonelist, sc);
 
 		/*
@@ -2669,10 +2667,6 @@ loop_again:
 		unsigned long lru_pages = 0;
 		int has_under_min_watermark_zone = 0;
 
-		/* The swap token gets in the way of swapout... */
-		if (!priority)
-			disable_swap_token(NULL);
-
 		all_zones_ok = 1;
 		balanced = 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
