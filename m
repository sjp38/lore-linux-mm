Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5AEE06B0047
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 09:40:07 -0500 (EST)
Date: Tue, 20 Jan 2009 15:40:03 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] lockdep: annotate reclaim context (__GFP_NOFS)
Message-ID: <20090120144003.GJ19505@wotan.suse.de>
References: <20090120083906.GA19505@wotan.suse.de> <1232447354.4886.47.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1232447354.4886.47.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, Jan 20, 2009 at 11:29:14AM +0100, Peter Zijlstra wrote:
> On Tue, 2009-01-20 at 09:39 +0100, Nick Piggin wrote:

Hey, thanks for the review. I've attached a patch to improve the immediate
problems you noticed. Automating code generation shouldn't be a bad idea,
but would be a seperate patch.

I'm not sure if I got the check_prev_add_irq bit right...

---
 include/linux/lockdep.h |   13 +++++++-----
 include/linux/sched.h   |    2 -
 kernel/lockdep.c        |   50 ++++++++++++++++++++++++++++++++++++++++++------
 mm/page_alloc.c         |   16 +++------------
 4 files changed, 57 insertions(+), 24 deletions(-)

Index: linux-2.6/include/linux/lockdep.h
===================================================================
--- linux-2.6.orig/include/linux/lockdep.h
+++ linux-2.6/include/linux/lockdep.h
@@ -66,9 +66,6 @@ enum lock_usage_bit
 #define LOCKF_USED_IN_IRQ_READ \
 		(LOCKF_USED_IN_HARDIRQ_READ | LOCKF_USED_IN_SOFTIRQ_READ)
 
-#define LOCKDEP_PF_RECLAIM_FS_BIT	1	/* Process is with a GFP_FS
-						 * allocation context */
-
 #define MAX_LOCKDEP_SUBCLASSES		8UL
 
 /*
@@ -335,7 +332,11 @@ static inline void lock_set_subclass(str
 	lock_set_class(lock, lock->name, lock->key, subclass, ip);
 }
 
-# define INIT_LOCKDEP				.lockdep_recursion = 0, .lockdep_flags = 0,
+extern void lockdep_set_current_reclaim_state(gfp_t gfp_mask);
+extern void lockdep_clear_current_reclaim_state(void);
+extern void lockdep_trace_alloc(gfp_t mask);
+
+# define INIT_LOCKDEP				.lockdep_recursion = 0, .lockdep_reclaim_gfp = 0,
 
 #define lockdep_depth(tsk)	(debug_locks ? (tsk)->lockdep_depth : 0)
 
@@ -353,6 +354,9 @@ static inline void lockdep_on(void)
 # define lock_release(l, n, i)			do { } while (0)
 # define lock_set_class(l, n, k, s, i)		do { } while (0)
 # define lock_set_subclass(l, s, i)		do { } while (0)
+# define lockdep_set_current_reclaim_state(g)	do { } while (0)
+# define lockdep_clear_current_reclaim_state()	do { } while (0)
+# define lockdep_trace_alloc(g)			do { } while (0)
 # define lockdep_init()				do { } while (0)
 # define lockdep_info()				do { } while (0)
 # define lockdep_init_map(lock, name, key, sub) \
@@ -413,7 +417,6 @@ static inline void early_init_irq_lock_c
 extern void early_boot_irqs_off(void);
 extern void early_boot_irqs_on(void);
 extern void print_irqtrace_events(struct task_struct *curr);
-extern void trace_reclaim_fs(void);
 #else
 static inline void early_boot_irqs_off(void)
 {
Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -1307,7 +1307,7 @@ struct task_struct {
 	int lockdep_depth;
 	unsigned int lockdep_recursion;
 	struct held_lock held_locks[MAX_LOCK_DEPTH];
-	unsigned long lockdep_flags;
+	gfp_t lockdep_reclaim_gfp;
 #endif
 
 /* journalling filesystem info */
Index: linux-2.6/kernel/lockdep.c
===================================================================
--- linux-2.6.orig/kernel/lockdep.c
+++ linux-2.6/kernel/lockdep.c
@@ -509,7 +509,7 @@ get_usage_chars(struct lock_class *class
 
 	if (class->usage_mask & LOCKF_HELD_OVER_RECLAIM_FS_READ)
 		*c6 = '-';
-	if (class->usage_mask & LOCKF_USED_IN_SOFTIRQ_READ) {
+	if (class->usage_mask & LOCKF_USED_IN_RECLAIM_FS_READ) {
 		*c6 = '+';
 		if (class->usage_mask & LOCKF_HELD_OVER_RECLAIM_FS_READ)
 			*c6 = '?';
@@ -1328,6 +1328,26 @@ check_prev_add_irq(struct task_struct *c
 					LOCK_ENABLED_SOFTIRQS, "soft"))
 		return 0;
 
+	/*
+	 * Prove that the new dependency does not connect a reclaim-fs-safe
+	 * lock with a reclaim-fs-unsafe lock - to achieve this we search
+	 * the backwards-subgraph starting at <prev>, and the
+	 * forwards-subgraph starting at <next>:
+	 */
+	if (!check_usage(curr, prev, next, LOCK_USED_IN_RECLAIM_FS,
+					LOCK_HELD_OVER_RECLAIM_FS, "reclaim-fs"))
+		return 0;
+
+	/*
+	 * Prove that the new dependency does not connect a reclaim-fs-safe-read
+	 * lock with a reclaim-fs-unsafe lock - to achieve this we search
+	 * the backwards-subgraph starting at <prev>, and the
+	 * forwards-subgraph starting at <next>:
+	 */
+	if (!check_usage(curr, prev, next, LOCK_USED_IN_RECLAIM_FS_READ,
+					LOCK_HELD_OVER_RECLAIM_FS, "reclaim-fs-read"))
+		return 0;
+
 	return 1;
 }
 
@@ -2447,10 +2467,18 @@ void trace_softirqs_off(unsigned long ip
 		debug_atomic_inc(&redundant_softirqs_off);
 }
 
-void trace_reclaim_fs(void)
+void lockdep_trace_alloc(gfp_t gfp_mask)
 {
 	struct task_struct *curr = current;
 
+	/* this guy won't enter reclaim */
+	if (curr->flags & PF_MEMALLOC)
+		return;
+
+	/* We're only interested __GFP_FS allocations for now */
+	if (!(gfp_mask & __GFP_FS))
+		return;
+
 	if (unlikely(!debug_locks))
 		return;
 	if (DEBUG_LOCKS_WARN_ON(irqs_disabled()))
@@ -2510,14 +2538,14 @@ static int mark_irqflags(struct task_str
 	 * during reclaim for a GFP_FS allocation is held over a GFP_FS
 	 * allocation).
 	 */
-	if (!hlock->trylock && test_bit(LOCKDEP_PF_RECLAIM_FS_BIT,
-							&curr->lockdep_flags)) {
-		if (hlock->read)
+	if (!hlock->trylock && (curr->lockdep_reclaim_gfp & __GFP_FS)) {
+		if (hlock->read) {
 			if (!mark_lock(curr, hlock, LOCK_USED_IN_RECLAIM_FS_READ))
 					return 0;
-		else
+		} else {
 			if (!mark_lock(curr, hlock, LOCK_USED_IN_RECLAIM_FS))
 					return 0;
+		}
 	}
 
 	return 1;
@@ -3128,6 +3156,16 @@ void lock_release(struct lockdep_map *lo
 }
 EXPORT_SYMBOL_GPL(lock_release);
 
+void lockdep_set_current_reclaim_state(gfp_t gfp_mask)
+{
+	current->lockdep_reclaim_gfp = gfp_mask;
+}
+
+void lockdep_clear_current_reclaim_state(void)
+{
+	current->lockdep_reclaim_gfp = 0;
+}
+
 #ifdef CONFIG_LOCK_STAT
 static int
 print_lock_contention_bug(struct task_struct *curr, struct lockdep_map *lock,
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -1479,10 +1479,7 @@ __alloc_pages_internal(gfp_t gfp_mask, u
 	unsigned long did_some_progress;
 	unsigned long pages_reclaimed = 0;
 
-#ifdef CONFIG_LOCKDEP
-	if ((gfp_mask & (__GFP_WAIT|__GFP_FS)) == (__GFP_WAIT|__GFP_FS) && !(p->flags & PF_MEMALLOC))
-		trace_reclaim_fs();
-#endif
+	lockdep_trace_alloc(gfp_mask);
 
 	might_sleep_if(wait);
 
@@ -1583,20 +1580,15 @@ nofail_alloc:
 	 */
 	cpuset_update_task_memory_state();
 	p->flags |= PF_MEMALLOC;
-#ifdef CONFIG_LOCKDEP
-	if ((gfp_mask & (__GFP_WAIT|__GFP_FS)) == (__GFP_WAIT|__GFP_FS))
-		set_bit(LOCKDEP_PF_RECLAIM_FS_BIT, &p->lockdep_flags);
-#endif
+
+	lockdep_set_current_reclaim_state(gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
 	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
 
 	p->reclaim_state = NULL;
-#ifdef CONFIG_LOCKDEP
-	if ((gfp_mask & (__GFP_WAIT|__GFP_FS)) == (__GFP_WAIT|__GFP_FS))
-		clear_bit(LOCKDEP_PF_RECLAIM_FS_BIT, &p->lockdep_flags);
-#endif
+	lockdep_clear_current_reclaim_state();
 	p->flags &= ~PF_MEMALLOC;
 
 	cond_resched();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
