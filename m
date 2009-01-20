Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5CE996B0044
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 03:39:11 -0500 (EST)
Date: Tue, 20 Jan 2009 09:39:06 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] lockdep: annotate reclaim context (__GFP_NOFS)
Message-ID: <20090120083906.GA19505@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, peterz@infradead.org, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

I took a bit of time to clean this up since I posted the RFC.

I don't really know the lockdep code much, so this is about as
far as I get without asking for review. I don't know if this is
considered useful, but if it is, then maybe we can merge it and
then fill in the bits for annotating other reclaim contexts.

The only problem is the lock usage character string won't scale
well with more lock contexts. Why not just print out the hex
value of the flags? Simple and easy to decode and extend.

---

After noticing some code in mm/filemap.c accidentally perform a __GFP_FS
allocation when it should not have been, I thought it might be a good idea to
try to catch this kind of thing with lockdep.

I coded up a little idea that seems to work. It reuses the interrupt context
discovery and annotation mechanism to reclaim contexts in order to discover
possible deadlocks without having to actually hit them. If a lock is held
while performing a __GFP_FS allocation, then that lock must not be taken
during __GFP_FS reclaim. And vice versa.

Further possibilities: __GFP_IO, and __GFP_WAIT (without IO or FS). But
filesystems are probably the most complicated with tricky locking, so let's
start here first.

Example output:
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

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 include/linux/lockdep.h |   14 +++
 include/linux/sched.h   |    1 
 kernel/lockdep.c        |  186 ++++++++++++++++++++++++++++++++++++++++++++----
 mm/page_alloc.c         |   13 +++
 4 files changed, 201 insertions(+), 13 deletions(-)

Index: linux-2.6/include/linux/lockdep.h
===================================================================
--- linux-2.6.orig/include/linux/lockdep.h	2009-01-20 18:36:58.000000000 +1100
+++ linux-2.6/include/linux/lockdep.h	2009-01-20 18:44:41.000000000 +1100
@@ -27,12 +27,16 @@ enum lock_usage_bit
 	LOCK_USED = 0,
 	LOCK_USED_IN_HARDIRQ,
 	LOCK_USED_IN_SOFTIRQ,
+	LOCK_USED_IN_RECLAIM_FS,
 	LOCK_ENABLED_SOFTIRQS,
 	LOCK_ENABLED_HARDIRQS,
+	LOCK_HELD_OVER_RECLAIM_FS,
 	LOCK_USED_IN_HARDIRQ_READ,
 	LOCK_USED_IN_SOFTIRQ_READ,
+	LOCK_USED_IN_RECLAIM_FS_READ,
 	LOCK_ENABLED_SOFTIRQS_READ,
 	LOCK_ENABLED_HARDIRQS_READ,
+	LOCK_HELD_OVER_RECLAIM_FS_READ,
 	LOCK_USAGE_STATES
 };
 
@@ -42,22 +46,29 @@ enum lock_usage_bit
 #define LOCKF_USED			(1 << LOCK_USED)
 #define LOCKF_USED_IN_HARDIRQ		(1 << LOCK_USED_IN_HARDIRQ)
 #define LOCKF_USED_IN_SOFTIRQ		(1 << LOCK_USED_IN_SOFTIRQ)
+#define LOCKF_USED_IN_RECLAIM_FS	(1 << LOCK_USED_IN_RECLAIM_FS)
 #define LOCKF_ENABLED_HARDIRQS		(1 << LOCK_ENABLED_HARDIRQS)
 #define LOCKF_ENABLED_SOFTIRQS		(1 << LOCK_ENABLED_SOFTIRQS)
+#define LOCKF_HELD_OVER_RECLAIM_FS	(1 << LOCK_HELD_OVER_RECLAIM_FS)
 
 #define LOCKF_ENABLED_IRQS (LOCKF_ENABLED_HARDIRQS | LOCKF_ENABLED_SOFTIRQS)
 #define LOCKF_USED_IN_IRQ (LOCKF_USED_IN_HARDIRQ | LOCKF_USED_IN_SOFTIRQ)
 
 #define LOCKF_USED_IN_HARDIRQ_READ	(1 << LOCK_USED_IN_HARDIRQ_READ)
 #define LOCKF_USED_IN_SOFTIRQ_READ	(1 << LOCK_USED_IN_SOFTIRQ_READ)
+#define LOCKF_USED_IN_RECLAIM_FS_READ	(1 << LOCK_USED_IN_RECLAIM_FS_READ)
 #define LOCKF_ENABLED_HARDIRQS_READ	(1 << LOCK_ENABLED_HARDIRQS_READ)
 #define LOCKF_ENABLED_SOFTIRQS_READ	(1 << LOCK_ENABLED_SOFTIRQS_READ)
+#define LOCKF_HELD_OVER_RECLAIM_FS_READ	(1 << LOCK_HELD_OVER_RECLAIM_FS_READ)
 
 #define LOCKF_ENABLED_IRQS_READ \
 		(LOCKF_ENABLED_HARDIRQS_READ | LOCKF_ENABLED_SOFTIRQS_READ)
 #define LOCKF_USED_IN_IRQ_READ \
 		(LOCKF_USED_IN_HARDIRQ_READ | LOCKF_USED_IN_SOFTIRQ_READ)
 
+#define LOCKDEP_PF_RECLAIM_FS_BIT	1	/* Process is with a GFP_FS
+						 * allocation context */
+
 #define MAX_LOCKDEP_SUBCLASSES		8UL
 
 /*
@@ -324,7 +335,7 @@ static inline void lock_set_subclass(str
 	lock_set_class(lock, lock->name, lock->key, subclass, ip);
 }
 
-# define INIT_LOCKDEP				.lockdep_recursion = 0,
+# define INIT_LOCKDEP				.lockdep_recursion = 0, .lockdep_flags = 0,
 
 #define lockdep_depth(tsk)	(debug_locks ? (tsk)->lockdep_depth : 0)
 
@@ -402,6 +413,7 @@ static inline void early_init_irq_lock_c
 extern void early_boot_irqs_off(void);
 extern void early_boot_irqs_on(void);
 extern void print_irqtrace_events(struct task_struct *curr);
+extern void trace_reclaim_fs(void);
 #else
 static inline void early_boot_irqs_off(void)
 {
Index: linux-2.6/kernel/lockdep.c
===================================================================
--- linux-2.6.orig/kernel/lockdep.c	2009-01-20 18:36:58.000000000 +1100
+++ linux-2.6/kernel/lockdep.c	2009-01-20 19:19:59.000000000 +1100
@@ -310,12 +310,14 @@ EXPORT_SYMBOL(lockdep_on);
 #if VERBOSE
 # define HARDIRQ_VERBOSE	1
 # define SOFTIRQ_VERBOSE	1
+# define RECLAIM_VERBOSE	1
 #else
 # define HARDIRQ_VERBOSE	0
 # define SOFTIRQ_VERBOSE	0
+# define RECLAIM_VERBOSE	0
 #endif
 
-#if VERBOSE || HARDIRQ_VERBOSE || SOFTIRQ_VERBOSE
+#if VERBOSE || HARDIRQ_VERBOSE || SOFTIRQ_VERBOSE || RECLAIM_VERBOSE
 /*
  * Quick filtering for interesting events:
  */
@@ -454,6 +456,10 @@ static const char *usage_str[] =
 	[LOCK_USED_IN_SOFTIRQ_READ] =	"in-softirq-R",
 	[LOCK_ENABLED_SOFTIRQS_READ] =	"softirq-on-R",
 	[LOCK_ENABLED_HARDIRQS_READ] =	"hardirq-on-R",
+	[LOCK_USED_IN_RECLAIM_FS] =	"in-reclaim-W",
+	[LOCK_USED_IN_RECLAIM_FS_READ] = "in-reclaim-R",
+	[LOCK_HELD_OVER_RECLAIM_FS] =	"ov-reclaim-W",
+	[LOCK_HELD_OVER_RECLAIM_FS_READ] = "ov-reclaim-R",
 };
 
 const char * __get_key_name(struct lockdep_subclass_key *key, char *str)
@@ -462,9 +468,10 @@ const char * __get_key_name(struct lockd
 }
 
 void
-get_usage_chars(struct lock_class *class, char *c1, char *c2, char *c3, char *c4)
+get_usage_chars(struct lock_class *class, char *c1, char *c2, char *c3,
+					char *c4, char *c5, char *c6)
 {
-	*c1 = '.', *c2 = '.', *c3 = '.', *c4 = '.';
+	*c1 = '.', *c2 = '.', *c3 = '.', *c4 = '.', *c5 = '.', *c6 = '.';
 
 	if (class->usage_mask & LOCKF_USED_IN_HARDIRQ)
 		*c1 = '+';
@@ -493,14 +500,29 @@ get_usage_chars(struct lock_class *class
 		if (class->usage_mask & LOCKF_ENABLED_SOFTIRQS_READ)
 			*c4 = '?';
 	}
+
+	if (class->usage_mask & LOCKF_USED_IN_RECLAIM_FS)
+		*c5 = '+';
+	else
+		if (class->usage_mask & LOCKF_HELD_OVER_RECLAIM_FS)
+			*c5 = '-';
+
+	if (class->usage_mask & LOCKF_HELD_OVER_RECLAIM_FS_READ)
+		*c6 = '-';
+	if (class->usage_mask & LOCKF_USED_IN_SOFTIRQ_READ) {
+		*c6 = '+';
+		if (class->usage_mask & LOCKF_HELD_OVER_RECLAIM_FS_READ)
+			*c6 = '?';
+	}
+
 }
 
 static void print_lock_name(struct lock_class *class)
 {
-	char str[KSYM_NAME_LEN], c1, c2, c3, c4;
+	char str[KSYM_NAME_LEN], c1, c2, c3, c4, c5, c6;
 	const char *name;
 
-	get_usage_chars(class, &c1, &c2, &c3, &c4);
+	get_usage_chars(class, &c1, &c2, &c3, &c4, &c5, &c6);
 
 	name = class->name;
 	if (!name) {
@@ -513,7 +535,7 @@ static void print_lock_name(struct lock_
 		if (class->subclass)
 			printk("/%d", class->subclass);
 	}
-	printk("){%c%c%c%c}", c1, c2, c3, c4);
+	printk("){%c%c%c%c%c%c}", c1, c2, c3, c4, c5, c6);
 }
 
 static void print_lockdep_cache(struct lockdep_map *lock)
@@ -1949,6 +1971,14 @@ static int softirq_verbose(struct lock_c
 	return 0;
 }
 
+static int reclaim_verbose(struct lock_class *class)
+{
+#if RECLAIM_VERBOSE
+	return class_filter(class);
+#endif
+	return 0;
+}
+
 #define STRICT_READ_CHECKS	1
 
 static int mark_lock_irq(struct task_struct *curr, struct held_lock *this,
@@ -2007,6 +2037,31 @@ static int mark_lock_irq(struct task_str
 		if (softirq_verbose(hlock_class(this)))
 			ret = 2;
 		break;
+	case LOCK_USED_IN_RECLAIM_FS:
+		if (!valid_state(curr, this, new_bit, LOCK_HELD_OVER_RECLAIM_FS))
+			return 0;
+		if (!valid_state(curr, this, new_bit,
+				 LOCK_HELD_OVER_RECLAIM_FS_READ))
+			return 0;
+		/*
+		 * just marked it reclaim-fs-safe, check that this lock
+		 * took no reclaim-fs-unsafe lock in the past:
+		 */
+		if (!check_usage_forwards(curr, this,
+					  LOCK_HELD_OVER_RECLAIM_FS, "reclaim-fs"))
+			return 0;
+#if STRICT_READ_CHECKS
+		/*
+		 * just marked it reclaim-fs-safe, check that this lock
+		 * took no reclaim-fs-unsafe-read lock in the past:
+		 */
+		if (!check_usage_forwards(curr, this,
+				LOCK_HELD_OVER_RECLAIM_FS_READ, "reclaim-fs-read"))
+			return 0;
+#endif
+		if (reclaim_verbose(hlock_class(this)))
+			ret = 2;
+		break;
 	case LOCK_USED_IN_HARDIRQ_READ:
 		if (!valid_state(curr, this, new_bit, LOCK_ENABLED_HARDIRQS))
 			return 0;
@@ -2033,6 +2088,19 @@ static int mark_lock_irq(struct task_str
 		if (softirq_verbose(hlock_class(this)))
 			ret = 2;
 		break;
+	case LOCK_USED_IN_RECLAIM_FS_READ:
+		if (!valid_state(curr, this, new_bit, LOCK_HELD_OVER_RECLAIM_FS))
+			return 0;
+		/*
+		 * just marked it reclaim-fs-read-safe, check that this lock
+		 * took no reclaim-fs-unsafe lock in the past:
+		 */
+		if (!check_usage_forwards(curr, this,
+					  LOCK_HELD_OVER_RECLAIM_FS, "reclaim-fs"))
+			return 0;
+		if (reclaim_verbose(hlock_class(this)))
+			ret = 2;
+		break;
 	case LOCK_ENABLED_HARDIRQS:
 		if (!valid_state(curr, this, new_bit, LOCK_USED_IN_HARDIRQ))
 			return 0;
@@ -2085,6 +2153,32 @@ static int mark_lock_irq(struct task_str
 		if (softirq_verbose(hlock_class(this)))
 			ret = 2;
 		break;
+	case LOCK_HELD_OVER_RECLAIM_FS:
+		if (!valid_state(curr, this, new_bit, LOCK_USED_IN_RECLAIM_FS))
+			return 0;
+		if (!valid_state(curr, this, new_bit,
+				 LOCK_USED_IN_RECLAIM_FS_READ))
+			return 0;
+		/*
+		 * just marked it reclaim-fs-unsafe, check that no reclaim-fs-safe
+		 * lock in the system ever took it in the past:
+		 */
+		if (!check_usage_backwards(curr, this,
+					   LOCK_USED_IN_RECLAIM_FS, "reclaim-fs"))
+			return 0;
+#if STRICT_READ_CHECKS
+		/*
+		 * just marked it softirq-unsafe, check that no
+		 * softirq-safe-read lock in the system ever took
+		 * it in the past:
+		 */
+		if (!check_usage_backwards(curr, this,
+				   LOCK_USED_IN_RECLAIM_FS_READ, "reclaim-fs-read"))
+			return 0;
+#endif
+		if (reclaim_verbose(hlock_class(this)))
+			ret = 2;
+		break;
 	case LOCK_ENABLED_HARDIRQS_READ:
 		if (!valid_state(curr, this, new_bit, LOCK_USED_IN_HARDIRQ))
 			return 0;
@@ -2115,6 +2209,21 @@ static int mark_lock_irq(struct task_str
 		if (softirq_verbose(hlock_class(this)))
 			ret = 2;
 		break;
+	case LOCK_HELD_OVER_RECLAIM_FS_READ:
+		if (!valid_state(curr, this, new_bit, LOCK_USED_IN_RECLAIM_FS))
+			return 0;
+#if STRICT_READ_CHECKS
+		/*
+		 * just marked it reclaim-fs-read-unsafe, check that no
+		 * reclaim-fs-safe lock in the system ever took it in the past:
+		 */
+		if (!check_usage_backwards(curr, this,
+					   LOCK_USED_IN_RECLAIM_FS, "reclaim-fs"))
+			return 0;
+#endif
+		if (reclaim_verbose(hlock_class(this)))
+			ret = 2;
+		break;
 	default:
 		WARN_ON(1);
 		break;
@@ -2123,11 +2232,17 @@ static int mark_lock_irq(struct task_str
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
@@ -2136,17 +2251,32 @@ mark_held_locks(struct task_struct *curr
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
+			if (hlock->read)
+				usage_bit = LOCK_HELD_OVER_RECLAIM_FS_READ;
+			else
+				usage_bit = LOCK_HELD_OVER_RECLAIM_FS;
+			break;
+
+		default:
+			BUG();
 		}
+
 		if (!mark_lock(curr, hlock, usage_bit))
 			return 0;
 	}
@@ -2200,7 +2330,7 @@ void trace_hardirqs_on_caller(unsigned l
 	 * We are going to turn hardirqs on, so set the
 	 * usage bit for all held locks:
 	 */
-	if (!mark_held_locks(curr, 1))
+	if (!mark_held_locks(curr, HARDIRQ))
 		return;
 	/*
 	 * If we have softirqs enabled, then set the usage
@@ -2208,7 +2338,7 @@ void trace_hardirqs_on_caller(unsigned l
 	 * this bit from being set before)
 	 */
 	if (curr->softirqs_enabled)
-		if (!mark_held_locks(curr, 0))
+		if (!mark_held_locks(curr, SOFTIRQ))
 			return;
 
 	curr->hardirq_enable_ip = ip;
@@ -2288,7 +2418,7 @@ void trace_softirqs_on(unsigned long ip)
 	 * enabled too:
 	 */
 	if (curr->hardirqs_enabled)
-		mark_held_locks(curr, 0);
+		mark_held_locks(curr, SOFTIRQ);
 }
 
 /*
@@ -2317,6 +2447,18 @@ void trace_softirqs_off(unsigned long ip
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
@@ -2362,6 +2504,22 @@ static int mark_irqflags(struct task_str
 		}
 	}
 
+	/*
+	 * We reuse the irq context infrastructure more broadly as a general
+	 * context checking code. This tests GFP_FS recursion (a lock taken
+	 * during reclaim for a GFP_FS allocation is held over a GFP_FS
+	 * allocation).
+	 */
+	if (!hlock->trylock && test_bit(LOCKDEP_PF_RECLAIM_FS_BIT,
+							&curr->lockdep_flags)) {
+		if (hlock->read)
+			if (!mark_lock(curr, hlock, LOCK_USED_IN_RECLAIM_FS_READ))
+					return 0;
+		else
+			if (!mark_lock(curr, hlock, LOCK_USED_IN_RECLAIM_FS))
+					return 0;
+	}
+
 	return 1;
 }
 
@@ -2453,6 +2611,10 @@ static int mark_lock(struct task_struct 
 	case LOCK_ENABLED_SOFTIRQS:
 	case LOCK_ENABLED_HARDIRQS_READ:
 	case LOCK_ENABLED_SOFTIRQS_READ:
+	case LOCK_USED_IN_RECLAIM_FS:
+	case LOCK_USED_IN_RECLAIM_FS_READ:
+	case LOCK_HELD_OVER_RECLAIM_FS:
+	case LOCK_HELD_OVER_RECLAIM_FS_READ:
 		ret = mark_lock_irq(curr, this, new_bit);
 		if (!ret)
 			return 0;
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2009-01-20 18:36:58.000000000 +1100
+++ linux-2.6/mm/page_alloc.c	2009-01-20 18:37:50.000000000 +1100
@@ -1479,6 +1479,11 @@ __alloc_pages_internal(gfp_t gfp_mask, u
 	unsigned long did_some_progress;
 	unsigned long pages_reclaimed = 0;
 
+#ifdef CONFIG_LOCKDEP
+	if ((gfp_mask & (__GFP_WAIT|__GFP_FS)) == (__GFP_WAIT|__GFP_FS) && !(p->flags & PF_MEMALLOC))
+		trace_reclaim_fs();
+#endif
+
 	might_sleep_if(wait);
 
 	if (should_fail_alloc_page(gfp_mask, order))
@@ -1578,12 +1583,20 @@ nofail_alloc:
 	 */
 	cpuset_update_task_memory_state();
 	p->flags |= PF_MEMALLOC;
+#ifdef CONFIG_LOCKDEP
+	if ((gfp_mask & (__GFP_WAIT|__GFP_FS)) == (__GFP_WAIT|__GFP_FS))
+		set_bit(LOCKDEP_PF_RECLAIM_FS_BIT, &p->lockdep_flags);
+#endif
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
 	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
 
 	p->reclaim_state = NULL;
+#ifdef CONFIG_LOCKDEP
+	if ((gfp_mask & (__GFP_WAIT|__GFP_FS)) == (__GFP_WAIT|__GFP_FS))
+		clear_bit(LOCKDEP_PF_RECLAIM_FS_BIT, &p->lockdep_flags);
+#endif
 	p->flags &= ~PF_MEMALLOC;
 
 	cond_resched();
Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h	2009-01-20 18:36:58.000000000 +1100
+++ linux-2.6/include/linux/sched.h	2009-01-20 18:37:50.000000000 +1100
@@ -1307,6 +1307,7 @@ struct task_struct {
 	int lockdep_depth;
 	unsigned int lockdep_recursion;
 	struct held_lock held_locks[MAX_LOCK_DEPTH];
+	unsigned long lockdep_flags;
 #endif
 
 /* journalling filesystem info */
Index: linux-2.6/kernel/lockdep_internals.h
===================================================================
--- linux-2.6.orig/kernel/lockdep_internals.h	2009-01-20 19:19:54.000000000 +1100
+++ linux-2.6/kernel/lockdep_internals.h	2009-01-20 19:19:59.000000000 +1100
@@ -32,7 +32,8 @@ extern struct list_head all_lock_classes
 extern struct lock_chain lock_chains[];
 
 extern void
-get_usage_chars(struct lock_class *class, char *c1, char *c2, char *c3, char *c4);
+get_usage_chars(struct lock_class *class, char *c1, char *c2, char *c3,
+					char *c4, char *c5, char *c6);
 
 extern const char * __get_key_name(struct lockdep_subclass_key *key, char *str);
 
Index: linux-2.6/kernel/lockdep_proc.c
===================================================================
--- linux-2.6.orig/kernel/lockdep_proc.c	2009-01-20 19:19:54.000000000 +1100
+++ linux-2.6/kernel/lockdep_proc.c	2009-01-20 19:19:59.000000000 +1100
@@ -84,7 +84,7 @@ static int l_show(struct seq_file *m, vo
 {
 	struct lock_class *class = v;
 	struct lock_list *entry;
-	char c1, c2, c3, c4;
+	char c1, c2, c3, c4, c5, c6;
 
 	if (v == SEQ_START_TOKEN) {
 		seq_printf(m, "all lock classes:\n");
@@ -100,8 +100,8 @@ static int l_show(struct seq_file *m, vo
 	seq_printf(m, " BD:%5ld", lockdep_count_backward_deps(class));
 #endif
 
-	get_usage_chars(class, &c1, &c2, &c3, &c4);
-	seq_printf(m, " %c%c%c%c", c1, c2, c3, c4);
+	get_usage_chars(class, &c1, &c2, &c3, &c4, &c5, &c6);
+	seq_printf(m, " %c%c%c%c%c%c", c1, c2, c3, c4, c5, c6);
 
 	seq_printf(m, ": ");
 	print_name(m, class);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
