Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 981C66B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 04:13:42 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 90so89441593ios.4
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 01:13:42 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id e16si1706373ita.117.2017.03.03.01.13.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 01:13:41 -0800 (PST)
Date: Fri, 3 Mar 2017 10:13:38 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170303091338.GH6536@twins.programming.kicks-ass.net>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228134018.GK5680@worktop>
 <20170301054323.GE11663@X58A-UD3R>
 <20170301122843.GF6515@twins.programming.kicks-ass.net>
 <20170302134031.GG6536@twins.programming.kicks-ass.net>
 <20170303001737.GF28562@X58A-UD3R>
 <20170303081416.GT6515@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303081416.GT6515@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com, Michal Hocko <mhocko@kernel.org>, Nikolay Borisov <nborisov@suse.com>, Mel Gorman <mgorman@suse.de>

On Fri, Mar 03, 2017 at 09:14:16AM +0100, Peter Zijlstra wrote:

> That said; I'd be fairly interested in numbers on how many links this
> avoids, I'll go make a check_redundant() version of the above and put a
> proper counter in so I can see what it does for a regular boot etc..

Two boots + a make defconfig, the first didn't have the redundant bit
in, the second did (full diff below still includes the reclaim rework,
because that was still in that kernel and I forgot to reset the tree).


 lock-classes:                         1168       1169 [max: 8191]
 direct dependencies:                  7688       5812 [max: 32768]
 indirect dependencies:               25492      25937
 all direct dependencies:            220113     217512
 dependency chains:                    9005       9008 [max: 65536]
 dependency chain hlocks:             34450      34366 [max: 327680]
 in-hardirq chains:                      55         51
 in-softirq chains:                     371        378
 in-process chains:                    8579       8579
 stack-trace entries:                108073      88474 [max: 524288]
 combined max dependencies:       178738560  169094640

 max locking depth:                      15         15
 max bfs queue depth:                   320        329

 cyclic checks:                        9123       9190

 redundant checks:                                5046
 redundant links:                                 1828

 find-mask forwards checks:            2564       2599
 find-mask backwards checks:          39521      39789


So it saves nearly 2k links and a fair chunk of stack-trace entries, but
as expected, makes no real difference on the indirect dependencies.

At the same time, you see the max BFS depth increase, which is also
expected, although it could easily be boot variance -- these numbers are
not entirely stable between boots.

Could you run something similar? Or I'll take a look on your next spin
of the patches.



---
 include/linux/lockdep.h            |  11 +---
 include/linux/sched.h              |   1 -
 kernel/locking/lockdep.c           | 114 +++++++++----------------------------
 kernel/locking/lockdep_internals.h |   2 +
 kernel/locking/lockdep_proc.c      |   4 ++
 kernel/locking/lockdep_states.h    |   1 -
 mm/internal.h                      |  40 +++++++++++++
 mm/page_alloc.c                    |  13 ++++-
 mm/slab.h                          |   7 ++-
 mm/slob.c                          |   8 ++-
 mm/vmscan.c                        |  13 ++---
 11 files changed, 104 insertions(+), 110 deletions(-)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 1e327bb..6ba1a65 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -29,7 +29,7 @@ extern int lock_stat;
  * We'd rather not expose kernel/lockdep_states.h this wide, but we do need
  * the total number of states... :-(
  */
-#define XXX_LOCK_USAGE_STATES		(1+3*4)
+#define XXX_LOCK_USAGE_STATES		(1+2*4)
 
 /*
  * NR_LOCKDEP_CACHING_CLASSES ... Number of classes
@@ -361,10 +361,6 @@ static inline void lock_set_subclass(struct lockdep_map *lock,
 	lock_set_class(lock, lock->name, lock->key, subclass, ip);
 }
 
-extern void lockdep_set_current_reclaim_state(gfp_t gfp_mask);
-extern void lockdep_clear_current_reclaim_state(void);
-extern void lockdep_trace_alloc(gfp_t mask);
-
 struct pin_cookie { unsigned int val; };
 
 #define NIL_COOKIE (struct pin_cookie){ .val = 0U, }
@@ -373,7 +369,7 @@ extern struct pin_cookie lock_pin_lock(struct lockdep_map *lock);
 extern void lock_repin_lock(struct lockdep_map *lock, struct pin_cookie);
 extern void lock_unpin_lock(struct lockdep_map *lock, struct pin_cookie);
 
-# define INIT_LOCKDEP				.lockdep_recursion = 0, .lockdep_reclaim_gfp = 0,
+# define INIT_LOCKDEP				.lockdep_recursion = 0,
 
 #define lockdep_depth(tsk)	(debug_locks ? (tsk)->lockdep_depth : 0)
 
@@ -413,9 +409,6 @@ static inline void lockdep_on(void)
 # define lock_release(l, n, i)			do { } while (0)
 # define lock_set_class(l, n, k, s, i)		do { } while (0)
 # define lock_set_subclass(l, s, i)		do { } while (0)
-# define lockdep_set_current_reclaim_state(g)	do { } while (0)
-# define lockdep_clear_current_reclaim_state()	do { } while (0)
-# define lockdep_trace_alloc(g)			do { } while (0)
 # define lockdep_info()				do { } while (0)
 # define lockdep_init_map(lock, name, key, sub) \
 		do { (void)(name); (void)(key); } while (0)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index d67eee8..0fa8a8f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -806,7 +806,6 @@ struct task_struct {
 	int				lockdep_depth;
 	unsigned int			lockdep_recursion;
 	struct held_lock		held_locks[MAX_LOCK_DEPTH];
-	gfp_t				lockdep_reclaim_gfp;
 #endif
 
 #ifdef CONFIG_UBSAN
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index a95e5d1..e3cc398 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -343,14 +343,12 @@ EXPORT_SYMBOL(lockdep_on);
 #if VERBOSE
 # define HARDIRQ_VERBOSE	1
 # define SOFTIRQ_VERBOSE	1
-# define RECLAIM_VERBOSE	1
 #else
 # define HARDIRQ_VERBOSE	0
 # define SOFTIRQ_VERBOSE	0
-# define RECLAIM_VERBOSE	0
 #endif
 
-#if VERBOSE || HARDIRQ_VERBOSE || SOFTIRQ_VERBOSE || RECLAIM_VERBOSE
+#if VERBOSE || HARDIRQ_VERBOSE || SOFTIRQ_VERBOSE
 /*
  * Quick filtering for interesting events:
  */
@@ -1295,6 +1293,19 @@ check_noncircular(struct lock_list *root, struct lock_class *target,
 	return result;
 }
 
+static noinline int
+check_redundant(struct lock_list *root, struct lock_class *target,
+		struct lock_list **target_entry)
+{
+	int result;
+
+	debug_atomic_inc(nr_redundant_checks);
+
+	result = __bfs_forwards(root, target, class_equal, target_entry);
+
+	return result;
+}
+
 #if defined(CONFIG_TRACE_IRQFLAGS) && defined(CONFIG_PROVE_LOCKING)
 /*
  * Forwards and backwards subgraph searching, for the purposes of
@@ -1860,6 +1871,20 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
 		}
 	}
 
+	/*
+	 * Is the <prev> -> <next> link redundant?
+	 */
+	this.class = hlock_class(prev);
+	this.parent = NULL;
+	ret = check_redundant(&this, hlock_class(next), &target_entry);
+	if (!ret) {
+		debug_atomic_inc(nr_redundant);
+		return 2;
+	}
+	if (ret < 0)
+		return print_bfs_bug(ret);
+
+
 	if (!*stack_saved) {
 		if (!save_trace(&trace))
 			return 0;
@@ -2553,14 +2578,6 @@ static int SOFTIRQ_verbose(struct lock_class *class)
 	return 0;
 }
 
-static int RECLAIM_FS_verbose(struct lock_class *class)
-{
-#if RECLAIM_VERBOSE
-	return class_filter(class);
-#endif
-	return 0;
-}
-
 #define STRICT_READ_CHECKS	1
 
 static int (*state_verbose_f[])(struct lock_class *class) = {
@@ -2856,51 +2873,6 @@ void trace_softirqs_off(unsigned long ip)
 		debug_atomic_inc(redundant_softirqs_off);
 }
 
-static void __lockdep_trace_alloc(gfp_t gfp_mask, unsigned long flags)
-{
-	struct task_struct *curr = current;
-
-	if (unlikely(!debug_locks))
-		return;
-
-	/* no reclaim without waiting on it */
-	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
-		return;
-
-	/* this guy won't enter reclaim */
-	if ((curr->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
-		return;
-
-	/* We're only interested __GFP_FS allocations for now */
-	if (!(gfp_mask & __GFP_FS))
-		return;
-
-	/*
-	 * Oi! Can't be having __GFP_FS allocations with IRQs disabled.
-	 */
-	if (DEBUG_LOCKS_WARN_ON(irqs_disabled_flags(flags)))
-		return;
-
-	mark_held_locks(curr, RECLAIM_FS);
-}
-
-static void check_flags(unsigned long flags);
-
-void lockdep_trace_alloc(gfp_t gfp_mask)
-{
-	unsigned long flags;
-
-	if (unlikely(current->lockdep_recursion))
-		return;
-
-	raw_local_irq_save(flags);
-	check_flags(flags);
-	current->lockdep_recursion = 1;
-	__lockdep_trace_alloc(gfp_mask, flags);
-	current->lockdep_recursion = 0;
-	raw_local_irq_restore(flags);
-}
-
 static int mark_irqflags(struct task_struct *curr, struct held_lock *hlock)
 {
 	/*
@@ -2946,22 +2918,6 @@ static int mark_irqflags(struct task_struct *curr, struct held_lock *hlock)
 		}
 	}
 
-	/*
-	 * We reuse the irq context infrastructure more broadly as a general
-	 * context checking code. This tests GFP_FS recursion (a lock taken
-	 * during reclaim for a GFP_FS allocation is held over a GFP_FS
-	 * allocation).
-	 */
-	if (!hlock->trylock && (curr->lockdep_reclaim_gfp & __GFP_FS)) {
-		if (hlock->read) {
-			if (!mark_lock(curr, hlock, LOCK_USED_IN_RECLAIM_FS_READ))
-					return 0;
-		} else {
-			if (!mark_lock(curr, hlock, LOCK_USED_IN_RECLAIM_FS))
-					return 0;
-		}
-	}
-
 	return 1;
 }
 
@@ -3020,10 +2976,6 @@ static inline int separate_irq_context(struct task_struct *curr,
 	return 0;
 }
 
-void lockdep_trace_alloc(gfp_t gfp_mask)
-{
-}
-
 #endif /* defined(CONFIG_TRACE_IRQFLAGS) && defined(CONFIG_PROVE_LOCKING) */
 
 /*
@@ -3859,16 +3811,6 @@ void lock_unpin_lock(struct lockdep_map *lock, struct pin_cookie cookie)
 }
 EXPORT_SYMBOL_GPL(lock_unpin_lock);
 
-void lockdep_set_current_reclaim_state(gfp_t gfp_mask)
-{
-	current->lockdep_reclaim_gfp = gfp_mask;
-}
-
-void lockdep_clear_current_reclaim_state(void)
-{
-	current->lockdep_reclaim_gfp = 0;
-}
-
 #ifdef CONFIG_LOCK_STAT
 static int
 print_lock_contention_bug(struct task_struct *curr, struct lockdep_map *lock,
diff --git a/kernel/locking/lockdep_internals.h b/kernel/locking/lockdep_internals.h
index c2b8849..7809269 100644
--- a/kernel/locking/lockdep_internals.h
+++ b/kernel/locking/lockdep_internals.h
@@ -143,6 +143,8 @@ struct lockdep_stats {
 	int	redundant_softirqs_on;
 	int	redundant_softirqs_off;
 	int	nr_unused_locks;
+	int	nr_redundant_checks;
+	int	nr_redundant;
 	int	nr_cyclic_checks;
 	int	nr_cyclic_check_recursions;
 	int	nr_find_usage_forwards_checks;
diff --git a/kernel/locking/lockdep_proc.c b/kernel/locking/lockdep_proc.c
index 6d1fcc7..68d9e26 100644
--- a/kernel/locking/lockdep_proc.c
+++ b/kernel/locking/lockdep_proc.c
@@ -201,6 +201,10 @@ static void lockdep_stats_debug_show(struct seq_file *m)
 		debug_atomic_read(chain_lookup_hits));
 	seq_printf(m, " cyclic checks:                 %11llu\n",
 		debug_atomic_read(nr_cyclic_checks));
+	seq_printf(m, " redundant checks:              %11llu\n",
+		debug_atomic_read(nr_redundant_checks));
+	seq_printf(m, " redundant links:               %11llu\n",
+		debug_atomic_read(nr_redundant));
 	seq_printf(m, " find-mask forwards checks:     %11llu\n",
 		debug_atomic_read(nr_find_usage_forwards_checks));
 	seq_printf(m, " find-mask backwards checks:    %11llu\n",
diff --git a/kernel/locking/lockdep_states.h b/kernel/locking/lockdep_states.h
index 995b0cc..35ca09f 100644
--- a/kernel/locking/lockdep_states.h
+++ b/kernel/locking/lockdep_states.h
@@ -6,4 +6,3 @@
  */
 LOCKDEP_STATE(HARDIRQ)
 LOCKDEP_STATE(SOFTIRQ)
-LOCKDEP_STATE(RECLAIM_FS)
diff --git a/mm/internal.h b/mm/internal.h
index ccfc2a2..88b9107 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -15,6 +15,8 @@
 #include <linux/mm.h>
 #include <linux/pagemap.h>
 #include <linux/tracepoint-defs.h>
+#include <linux/lockdep.h>
+#include <linux/sched/mm.h>
 
 /*
  * The set of flags that only affect watermark checking and reclaim
@@ -498,4 +500,42 @@ extern const struct trace_print_flags pageflag_names[];
 extern const struct trace_print_flags vmaflag_names[];
 extern const struct trace_print_flags gfpflag_names[];
 
+
+#ifdef CONFIG_LOCKDEP
+extern struct lockdep_map __fs_reclaim_map;
+
+static inline bool __need_fs_reclaim(gfp_t gfp_mask)
+{
+	gfp_mask = memalloc_noio_flags(gfp_mask);
+
+	/* no reclaim without waiting on it */
+	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
+		return false;
+
+	/* this guy won't enter reclaim */
+	if ((current->flags & PF_MEMALLOC) && !(gfp_mask & __GFP_NOMEMALLOC))
+		return false;
+
+	/* We're only interested __GFP_FS allocations for now */
+	if (!(gfp_mask & __GFP_FS))
+		return false;
+
+	return true;
+}
+
+static inline void fs_reclaim_acquire(gfp_t gfp_mask)
+{
+	if (__need_fs_reclaim(gfp_mask))
+		lock_map_acquire(&__fs_reclaim_map);
+}
+static inline void fs_reclaim_release(gfp_t gfp_mask)
+{
+	if (__need_fs_reclaim(gfp_mask))
+		lock_map_release(&__fs_reclaim_map);
+}
+#else
+static inline void fs_reclaim_acquire(gfp_t gfp_mask) { }
+static inline void fs_reclaim_release(gfp_t gfp_mask) { }
+#endif
+
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eaa64d2..85ea8bf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3387,6 +3387,12 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
 }
 #endif /* CONFIG_COMPACTION */
 
+
+#ifdef CONFIG_LOCKDEP
+struct lockdep_map __fs_reclaim_map =
+	STATIC_LOCKDEP_MAP_INIT("fs_reclaim", &__fs_reclaim_map);
+#endif
+
 /* Perform direct synchronous page reclaim */
 static int
 __perform_reclaim(gfp_t gfp_mask, unsigned int order,
@@ -3400,7 +3406,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
 	current->flags |= PF_MEMALLOC;
-	lockdep_set_current_reclaim_state(gfp_mask);
+	fs_reclaim_acquire(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
@@ -3408,7 +3414,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 								ac->nodemask);
 
 	current->reclaim_state = NULL;
-	lockdep_clear_current_reclaim_state();
+	fs_reclaim_release(gfp_mask);
 	current->flags &= ~PF_MEMALLOC;
 
 	cond_resched();
@@ -3913,7 +3919,8 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 			*alloc_flags |= ALLOC_CPUSET;
 	}
 
-	lockdep_trace_alloc(gfp_mask);
+	fs_reclaim_acquire(gfp_mask);
+	fs_reclaim_release(gfp_mask);
 
 	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
 
diff --git a/mm/slab.h b/mm/slab.h
index 65e7c3f..753f552 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -44,6 +44,8 @@ struct kmem_cache {
 #include <linux/kmemleak.h>
 #include <linux/random.h>
 
+#include "internal.h"
+
 /*
  * State of the slab allocator.
  *
@@ -428,7 +430,10 @@ static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
 						     gfp_t flags)
 {
 	flags &= gfp_allowed_mask;
-	lockdep_trace_alloc(flags);
+
+	fs_reclaim_acquire(flags);
+	fs_reclaim_release(flags);
+
 	might_sleep_if(gfpflags_allow_blocking(flags));
 
 	if (should_failslab(s, flags))
diff --git a/mm/slob.c b/mm/slob.c
index eac04d43..3e32280 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -73,6 +73,8 @@
 #include <linux/atomic.h>
 
 #include "slab.h"
+#include "internal.h"
+
 /*
  * slob_block has a field 'units', which indicates size of block if +ve,
  * or offset of next block if -ve (in SLOB_UNITs).
@@ -432,7 +434,8 @@ __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 
 	gfp &= gfp_allowed_mask;
 
-	lockdep_trace_alloc(gfp);
+	fs_reclaim_acquire(gfp);
+	fs_reclaim_release(gfp);
 
 	if (size < PAGE_SIZE - align) {
 		if (!size)
@@ -538,7 +541,8 @@ static void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 
 	flags &= gfp_allowed_mask;
 
-	lockdep_trace_alloc(flags);
+	fs_reclaim_acquire(flags);
+	fs_reclaim_release(flags);
 
 	if (c->size < PAGE_SIZE) {
 		b = slob_alloc(c->size, flags, c->align, node);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bc8031e..2f57e36 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3418,8 +3418,6 @@ static int kswapd(void *p)
 	};
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 
-	lockdep_set_current_reclaim_state(GFP_KERNEL);
-
 	if (!cpumask_empty(cpumask))
 		set_cpus_allowed_ptr(tsk, cpumask);
 	current->reclaim_state = &reclaim_state;
@@ -3475,7 +3473,9 @@ static int kswapd(void *p)
 		 */
 		trace_mm_vmscan_kswapd_wake(pgdat->node_id, classzone_idx,
 						alloc_order);
+		fs_reclaim_acquire(GFP_KERNEL);
 		reclaim_order = balance_pgdat(pgdat, alloc_order, classzone_idx);
+		fs_reclaim_release(GFP_KERNEL);
 		if (reclaim_order < alloc_order)
 			goto kswapd_try_sleep;
 
@@ -3485,7 +3485,6 @@ static int kswapd(void *p)
 
 	tsk->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD);
 	current->reclaim_state = NULL;
-	lockdep_clear_current_reclaim_state();
 
 	return 0;
 }
@@ -3550,14 +3549,14 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 	unsigned long nr_reclaimed;
 
 	p->flags |= PF_MEMALLOC;
-	lockdep_set_current_reclaim_state(sc.gfp_mask);
+	fs_reclaim_acquire(sc.gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
 	p->reclaim_state = NULL;
-	lockdep_clear_current_reclaim_state();
+	fs_reclaim_release(sc.gfp_mask);
 	p->flags &= ~PF_MEMALLOC;
 
 	return nr_reclaimed;
@@ -3741,7 +3740,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	 * and RECLAIM_UNMAP.
 	 */
 	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
-	lockdep_set_current_reclaim_state(gfp_mask);
+	fs_reclaim_acquire(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
@@ -3756,8 +3755,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	}
 
 	p->reclaim_state = NULL;
+	fs_reclaim_release(gfp_mask);
 	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
-	lockdep_clear_current_reclaim_state();
 	return sc.nr_reclaimed >= nr_pages;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
