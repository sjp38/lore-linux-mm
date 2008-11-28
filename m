Date: Fri, 28 Nov 2008 13:05:48 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc] lockdep: check fs reclaim recursion
Message-ID: <20081128120548.GB13786@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Hi,

After yesterday noticing some code in mm/filemap.c accidentally perform a
__GFP_FS allocation when it should not have been, I thought it might be a
good idea to try to catch this kind of thing with lockdep.

I coded up a little idea that seems to work. Unfortunately the system has to
actually be in __GFP_FS page reclaim, then take the lock, before it will mark
it. But at least that might still be some orders of magnitude more common
(and more debuggable) than an actual deadlock condition, so we have some
improvement I hope.

I guess we could do the same thing with __GFP_IO and even GFP_NOIO locks
too, but I don't know how expensive it is to add these annotations to lockdep.
Filesystems will have the most locks and fiddly code paths... Also, I've just
stolen a process flag for this first attempt, but actually I should be using
a CONFIG_LOCKDEP specific flag for this (rather than add stuff to pf flags).

I've also not added the last few bits for reader/writer lock support, or
added all the user output stuff. I just wanted to get comments on the idea.

It *seems* to work. I did a quick test.

=================================
[ INFO: inconsistent lock state ]
2.6.28-rc6-00007-ged31348-dirty #26
---------------------------------
inconsistent {in-reclaim-W} -> {ov-reclaim-W} usage.
modprobe/8526 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (testlock){--..}, at: [<ffffffffa0020055>] brd_init+0x55/0x216 [brd]
{in-reclaim-W} state was registered at:
  [<ffffffff80267bdb>] __lock_acquire+0x75b/0x1a60
  [<ffffffff80268f71>] lock_acquire+0x91/0xc0
  [<ffffffff8070f0e1>] mutex_lock_nested+0xb1/0x310
  [<ffffffffa002002b>] brd_init+0x2b/0x216 [brd]
  [<ffffffff8020903b>] _stext+0x3b/0x170
  [<ffffffff80272ebf>] sys_init_module+0xaf/0x1e0
  [<ffffffff8020c3fb>] system_call_fastpath+0x16/0x1b
  [<ffffffffffffffff>] 0xffffffffffffffff
irq event stamp: 3929
hardirqs last  enabled at (3929): [<ffffffff8070f2b5>] mutex_lock_nested+0x285/0x310
hardirqs last disabled at (3928): [<ffffffff8070f089>] mutex_lock_nested+0x59/0x310
softirqs last  enabled at (3732): [<ffffffff8061f623>] sk_filter+0x83/0xe0
softirqs last disabled at (3730): [<ffffffff8061f5b6>] sk_filter+0x16/0xe0

other info that might help us debug this:
1 lock held by modprobe/8526:
 #0:  (testlock){--..}, at: [<ffffffffa0020055>] brd_init+0x55/0x216 [brd]

stack backtrace:
Pid: 8526, comm: modprobe Not tainted 2.6.28-rc6-00007-ged31348-dirty #26
Call Trace:
 [<ffffffff80265483>] print_usage_bug+0x193/0x1d0
 [<ffffffff80266530>] mark_lock+0xaf0/0xca0
 [<ffffffff80266735>] mark_held_locks+0x55/0xc0
 [<ffffffffa0020000>] ? brd_init+0x0/0x216 [brd]
 [<ffffffff802667ca>] trace_reclaim_fs+0x2a/0x60
 [<ffffffff80285005>] __alloc_pages_internal+0x475/0x580
 [<ffffffff8070f29e>] ? mutex_lock_nested+0x26e/0x310
 [<ffffffffa0020000>] ? brd_init+0x0/0x216 [brd]
 [<ffffffffa002006a>] brd_init+0x6a/0x216 [brd]
 [<ffffffffa0020000>] ? brd_init+0x0/0x216 [brd]
 [<ffffffff8020903b>] _stext+0x3b/0x170
 [<ffffffff8070f8b9>] ? mutex_unlock+0x9/0x10
 [<ffffffff8070f83d>] ? __mutex_unlock_slowpath+0x10d/0x180
 [<ffffffff802669ec>] ? trace_hardirqs_on_caller+0x12c/0x190
 [<ffffffff80272ebf>] sys_init_module+0xaf/0x1e0
 [<ffffffff8020c3fb>] system_call_fastpath+0x16/0x1b

---
Index: linux-2.6/fs/nfsd/nfssvc.c
===================================================================
--- linux-2.6.orig/fs/nfsd/nfssvc.c
+++ linux-2.6/fs/nfsd/nfssvc.c
@@ -439,7 +439,6 @@ nfsd(void *vrqstp)
 	 * localhost doesn't cause nfsd to lock up due to all the client's
 	 * dirty pages.
 	 */
-	current->flags |= PF_LESS_THROTTLE;
 	set_freezable();
 
 	/*
Index: linux-2.6/include/linux/lockdep.h
===================================================================
--- linux-2.6.orig/include/linux/lockdep.h
+++ linux-2.6/include/linux/lockdep.h
@@ -33,6 +33,8 @@ enum lock_usage_bit
 	LOCK_USED_IN_SOFTIRQ_READ,
 	LOCK_ENABLED_SOFTIRQS_READ,
 	LOCK_ENABLED_HARDIRQS_READ,
+	LOCK_USED_IN_RECLAIM_FS,
+	LOCK_HELD_OVER_RECLAIM_FS,
 	LOCK_USAGE_STATES
 };
 
@@ -53,6 +55,9 @@ enum lock_usage_bit
 #define LOCKF_ENABLED_HARDIRQS_READ	(1 << LOCK_ENABLED_HARDIRQS_READ)
 #define LOCKF_ENABLED_SOFTIRQS_READ	(1 << LOCK_ENABLED_SOFTIRQS_READ)
 
+#define LOCKF_USED_IN_RECLAIM_FS	(1 << LOCK_USED_IN_RECLAIM_FS)
+#define LOCKF_HELD_IN_RECLAIM_FS	(1 << LOCK_HELD_OVER_RECLAIM_FS)
+
 #define LOCKF_ENABLED_IRQS_READ \
 		(LOCKF_ENABLED_HARDIRQS_READ | LOCKF_ENABLED_SOFTIRQS_READ)
 #define LOCKF_USED_IN_IRQ_READ \
@@ -389,6 +394,7 @@ static inline void early_init_irq_lock_c
 extern void early_boot_irqs_off(void);
 extern void early_boot_irqs_on(void);
 extern void print_irqtrace_events(struct task_struct *curr);
+extern void trace_reclaim_fs(void);
 #else
 static inline void early_boot_irqs_off(void)
 {
Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -1551,7 +1551,7 @@ extern cputime_t task_gtime(struct task_
 #define PF_FSTRANS	0x00020000	/* inside a filesystem transaction */
 #define PF_KSWAPD	0x00040000	/* I am kswapd */
 #define PF_SWAPOFF	0x00080000	/* I am in swapoff */
-#define PF_LESS_THROTTLE 0x00100000	/* Throttle me less: I clean memory */
+#define PF_RECLAIM_FS	0x00100000	/* Throttle me less: I clean memory */
 #define PF_KTHREAD	0x00200000	/* I am a kernel thread */
 #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
 #define PF_SWAPWRITE	0x00800000	/* Allowed to write to swap */
Index: linux-2.6/kernel/lockdep.c
===================================================================
--- linux-2.6.orig/kernel/lockdep.c
+++ linux-2.6/kernel/lockdep.c
@@ -451,6 +451,8 @@ static const char *usage_str[] =
 	[LOCK_USED_IN_SOFTIRQ_READ] =	"in-softirq-R",
 	[LOCK_ENABLED_SOFTIRQS_READ] =	"softirq-on-R",
 	[LOCK_ENABLED_HARDIRQS_READ] =	"hardirq-on-R",
+	[LOCK_USED_IN_RECLAIM_FS] =	"in-reclaim-W",
+	[LOCK_HELD_OVER_RECLAIM_FS] =	"ov-reclaim-W",
 };
 
 const char * __get_key_name(struct lockdep_subclass_key *key, char *str)
@@ -2111,6 +2113,20 @@ static int mark_lock_irq(struct task_str
 		if (softirq_verbose(hlock_class(this)))
 			ret = 2;
 		break;
+	case LOCK_USED_IN_RECLAIM_FS:
+		if (!valid_state(curr, this, new_bit, LOCK_HELD_OVER_RECLAIM_FS))
+			return 0;
+		if (!check_usage_forwards(curr, this,
+					  LOCK_HELD_OVER_RECLAIM_FS, "reclaim"))
+			return 0;
+		break;
+	case LOCK_HELD_OVER_RECLAIM_FS:
+		if (!valid_state(curr, this, new_bit, LOCK_USED_IN_RECLAIM_FS))
+			return 0;
+		if (!check_usage_backwards(curr, this,
+					   LOCK_USED_IN_RECLAIM_FS, "reclaim"))
+			return 0;
+		break;
 	default:
 		WARN_ON(1);
 		break;
@@ -2119,11 +2135,17 @@ static int mark_lock_irq(struct task_str
 	return ret;
 }
 
+enum mark_type {
+	HARDIRQ,
+	SOFTIRQ,
+	RECLAIM_FS,
+};
+
 /*
  * Mark all held locks with a usage bit:
  */
 static int
-mark_held_locks(struct task_struct *curr, int hardirq)
+mark_held_locks(struct task_struct *curr, enum mark_type mark)
 {
 	enum lock_usage_bit usage_bit;
 	struct held_lock *hlock;
@@ -2132,17 +2154,29 @@ mark_held_locks(struct task_struct *curr
 	for (i = 0; i < curr->lockdep_depth; i++) {
 		hlock = curr->held_locks + i;
 
-		if (hardirq) {
+		switch (mark) {
+		case HARDIRQ:
 			if (hlock->read)
 				usage_bit = LOCK_ENABLED_HARDIRQS_READ;
 			else
 				usage_bit = LOCK_ENABLED_HARDIRQS;
-		} else {
+			break;
+
+		case SOFTIRQ:
 			if (hlock->read)
 				usage_bit = LOCK_ENABLED_SOFTIRQS_READ;
 			else
 				usage_bit = LOCK_ENABLED_SOFTIRQS;
+			break;
+
+		case RECLAIM_FS:
+			usage_bit = LOCK_HELD_OVER_RECLAIM_FS;
+			break;
+
+		default:
+			BUG();
 		}
+
 		if (!mark_lock(curr, hlock, usage_bit))
 			return 0;
 	}
@@ -2196,7 +2230,7 @@ void trace_hardirqs_on_caller(unsigned l
 	 * We are going to turn hardirqs on, so set the
 	 * usage bit for all held locks:
 	 */
-	if (!mark_held_locks(curr, 1))
+	if (!mark_held_locks(curr, HARDIRQ))
 		return;
 	/*
 	 * If we have softirqs enabled, then set the usage
@@ -2204,7 +2238,7 @@ void trace_hardirqs_on_caller(unsigned l
 	 * this bit from being set before)
 	 */
 	if (curr->softirqs_enabled)
-		if (!mark_held_locks(curr, 0))
+		if (!mark_held_locks(curr, SOFTIRQ))
 			return;
 
 	curr->hardirq_enable_ip = ip;
@@ -2284,7 +2318,7 @@ void trace_softirqs_on(unsigned long ip)
 	 * enabled too:
 	 */
 	if (curr->hardirqs_enabled)
-		mark_held_locks(curr, 0);
+		mark_held_locks(curr, SOFTIRQ);
 }
 
 /*
@@ -2313,6 +2347,18 @@ void trace_softirqs_off(unsigned long ip
 		debug_atomic_inc(&redundant_softirqs_off);
 }
 
+void trace_reclaim_fs(void)
+{
+	struct task_struct *curr = current;
+
+	if (unlikely(!debug_locks))
+		return;
+	if (DEBUG_LOCKS_WARN_ON(irqs_disabled()))
+		return;
+
+	mark_held_locks(curr, RECLAIM_FS);
+}
+
 static int mark_irqflags(struct task_struct *curr, struct held_lock *hlock)
 {
 	/*
@@ -2337,6 +2383,10 @@ static int mark_irqflags(struct task_str
 				if (!mark_lock(curr, hlock, LOCK_USED_IN_SOFTIRQ))
 					return 0;
 		}
+		if (curr->flags & PF_RECLAIM_FS) {
+			if (!mark_lock(curr, hlock, LOCK_USED_IN_RECLAIM_FS))
+				return 0;
+		}
 	}
 	if (!hlock->hardirqs_off) {
 		if (hlock->read) {
@@ -2449,6 +2499,8 @@ static int mark_lock(struct task_struct
 	case LOCK_ENABLED_SOFTIRQS:
 	case LOCK_ENABLED_HARDIRQS_READ:
 	case LOCK_ENABLED_SOFTIRQS_READ:
+	case LOCK_USED_IN_RECLAIM_FS:
+	case LOCK_HELD_OVER_RECLAIM_FS:
 		ret = mark_lock_irq(curr, this, new_bit);
 		if (!ret)
 			return 0;
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -383,7 +383,7 @@ get_dirty_limits(long *pbackground, long
 	background = (background_ratio * available_memory) / 100;
 	dirty = (dirty_ratio * available_memory) / 100;
 	tsk = current;
-	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
+	if (rt_task(tsk)) {
 		background += background / 4;
 		dirty += dirty / 4;
 	}
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -1467,6 +1467,9 @@ __alloc_pages_internal(gfp_t gfp_mask, u
 	unsigned long did_some_progress;
 	unsigned long pages_reclaimed = 0;
 
+	if ((gfp_mask & (__GFP_WAIT|__GFP_FS)) == (__GFP_WAIT|__GFP_FS) && !(p->flags & PF_MEMALLOC))
+		trace_reclaim_fs();
+
 	might_sleep_if(wait);
 
 	if (should_fail_alloc_page(gfp_mask, order))
@@ -1566,12 +1569,16 @@ nofail_alloc:
 	 */
 	cpuset_update_task_memory_state();
 	p->flags |= PF_MEMALLOC;
+	if ((gfp_mask & (__GFP_WAIT|__GFP_FS)) == (__GFP_WAIT|__GFP_FS))
+		p->flags |= PF_RECLAIM_FS;
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
 	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
 
 	p->reclaim_state = NULL;
+	if ((gfp_mask & (__GFP_WAIT|__GFP_FS)) == (__GFP_WAIT|__GFP_FS))
+		p->flags &= ~PF_RECLAIM_FS;
 	p->flags &= ~PF_MEMALLOC;
 
 	cond_resched();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
