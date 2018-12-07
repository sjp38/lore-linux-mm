Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 18B766B7FBC
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 04:20:07 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id a10so2285806plp.14
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 01:20:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j14si2680202pfn.277.2018.12.07.01.20.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Dec 2018 01:20:05 -0800 (PST)
Date: Fri, 7 Dec 2018 10:19:59 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 03/17] locking/lockdep: Add a new terminal lock type
Message-ID: <20181207091959.GD2237@hirez.programming.kicks-ass.net>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-4-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542653726-5655-4-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Nov 19, 2018 at 01:55:12PM -0500, Waiman Long wrote:
> A terminal lock is a lock where further locking or unlocking on another
> lock is not allowed. IOW, no forward dependency is permitted.
> 
> With such a restriction in place, we don't really need to do a full
> validation of the lock chain involving a terminal lock.  Instead,
> we just check if there is any further locking or unlocking on another
> lock when a terminal lock is being held.
> 
> Only spinlocks which are acquired by the _irq or _irqsave variants
> or in IRQ disabled context should be classified as terminal locks.
> 
> By adding this new lock type, we can save entries in lock_chains[],
> chain_hlocks[], list_entries[] and stack_trace[]. By marking suitable
> locks as terminal, we reduce the chance of overflowing those tables
> allowing them to focus on locks that can have both forward and backward
> dependencies.
> 
> Four bits are stolen from the pin_count of the held_lock structure
> to hold a new 4-bit flags field. The pin_count field is essentially a
> summation of 16-bit random cookie values. Removing 4 bits still allow
> the pin_count to accumulate up to almost 4096 of those cookie values.
> 
> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  include/linux/lockdep.h            | 29 ++++++++++++++++++++---
>  kernel/locking/lockdep.c           | 47 ++++++++++++++++++++++++++++++++------
>  kernel/locking/lockdep_internals.h |  5 ++++
>  kernel/locking/lockdep_proc.c      | 11 +++++++--
>  4 files changed, 80 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
> index 8fe5b4f..a146bca 100644
> --- a/include/linux/lockdep.h
> +++ b/include/linux/lockdep.h
> @@ -144,9 +144,20 @@ struct lock_class_stats {
>  
>  /*
>   * Lockdep class type flags
> + *
>   * 1) LOCKDEP_FLAG_NOVALIDATE: No full validation, just simple checks.
> + * 2) LOCKDEP_FLAG_TERMINAL: This is a terminal lock where lock/unlock on
> + *    another lock within its critical section is not allowed.
> + *
> + * Only the least significant 4 bits of the flags will be copied to the
> + * held_lock structure.
>   */
> -#define LOCKDEP_FLAG_NOVALIDATE 	(1 << 0)
> +#define LOCKDEP_FLAG_TERMINAL		(1 << 0)
> +#define LOCKDEP_FLAG_NOVALIDATE 	(1 << 4)

Just leave the novalidate thing along, then you don't get to do silly
things like this.


Also; I have a pending patch (that I never quite finished) that tests
lock nesting type (ie. raw_spinlock_t < spinlock_t < struct mutex) that
wanted to use many of these same holes you took.

I think we can easily fit the lot together in bitfields though, since
you really don't need that many flags.

I refreshed the below patch a number of months ago (no idea if it still
applies, I think it was before Paul munged all of RCU). You need to kill
printk and lift a few RT patches for the below to 'work' IIRC.

---
Subject: lockdep: Introduce wait-type checks
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 19 Nov 2013 21:45:48 +0100

This patch extends lockdep to validate lock wait-type context.

The current wait-types are:

	LD_WAIT_FREE,		/* wait free, rcu etc.. */
	LD_WAIT_SPIN,		/* spin loops, raw_spinlock_t etc.. */
	LD_WAIT_CONFIG,		/* CONFIG_PREEMPT_LOCK, spinlock_t etc.. */
	LD_WAIT_SLEEP,		/* sleeping locks, mutex_t etc.. */

Where lockdep validates that the current lock (the one being acquired)
fits in the current wait-context (as generated by the held stack).

This ensures that we do not try and acquire mutices while holding
spinlocks, do not attempt to acquire spinlocks while holding
raw_spinlocks and so on. In other words, its a more fancy
might_sleep().

Obviously RCU made the entire ordeal more complex than a simple single
value test because we can acquire RCU in (pretty much) any context and
while it presents a context to nested locks it is not the same as it
got acquired in.

Therefore we needed to split the wait_type into two values, one
representing the acquire (outer) and one representing the nested
context (inner). For most 'normal' locks these two are the same.

[ To make static initialization easier we have the rule that:
  .outer == INV means .outer == .inner; because INV == 0. ]

It further means that we need to find the minimal .inner of the held
stack to compare against the outer of the new lock; because while
'normal' RCU presents a CONFIG type to nested locks, if it is taken
while already holding a SPIN type it obviously doesn't relax the
rules.

Below is an example output; generated by the trivial example:

	raw_spin_lock(&foo);
	spin_lock(&bar);
	spin_unlock(&bar);
	raw_spin_unlock(&foo);

The way to read it is to look at the new -{n,m} part in the lock
description; -{3:3} for our attempted lock, and try and match that up
to the held locks, which in this case is the one: -{2,2}.

This tells us that the acquiring lock requires a more relaxed
environment that presented by the lock stack.

Currently only the normal locks and RCU are converted, the rest of the
lockdep users defaults to .inner = INV which is ignored. More
convertions can be done when desired.



Cc: Ingo Molnar <mingo@kernel.org>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
Requested-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/linux/irqflags.h        |    8 ++
 include/linux/lockdep.h         |   66 +++++++++++++++----
 include/linux/mutex.h           |    7 +-
 include/linux/rwlock_types.h    |    6 +
 include/linux/rwsem.h           |    6 +
 include/linux/sched.h           |    1 
 include/linux/spinlock.h        |   35 +++++++---
 include/linux/spinlock_types.h  |   24 +++++-
 kernel/irq/handle.c             |    7 ++
 kernel/locking/lockdep.c        |  138 ++++++++++++++++++++++++++++++++++++----
 kernel/locking/mutex-debug.c    |    2 
 kernel/locking/rwsem-spinlock.c |    2 
 kernel/locking/rwsem-xadd.c     |    2 
 kernel/locking/spinlock_debug.c |    6 -
 kernel/rcu/update.c             |   24 +++++-
 15 files changed, 280 insertions(+), 54 deletions(-)

--- a/include/linux/irqflags.h
+++ b/include/linux/irqflags.h
@@ -37,7 +37,12 @@
 # define trace_softirqs_enabled(p)	((p)->softirqs_enabled)
 # define trace_hardirq_enter()			\
 do {						\
-	current->hardirq_context++;		\
+	if (!current->hardirq_context++)	\
+		current->hardirq_threaded = 0;	\
+} while (0)
+# define trace_hardirq_threaded()		\
+do {						\
+	current->hardirq_threaded = 1;		\
 } while (0)
 # define trace_hardirq_exit()			\
 do {						\
@@ -59,6 +64,7 @@ do {						\
 # define trace_hardirqs_enabled(p)	0
 # define trace_softirqs_enabled(p)	0
 # define trace_hardirq_enter()		do { } while (0)
+# define trace_hardirq_threaded()	do { } while (0)
 # define trace_hardirq_exit()		do { } while (0)
 # define lockdep_softirq_enter()	do { } while (0)
 # define lockdep_softirq_exit()		do { } while (0)
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -107,6 +107,9 @@ struct lock_class {
 	const char			*name;
 	int				name_version;
 
+	short				wait_type_inner;
+	short				wait_type_outer;
+
 #ifdef CONFIG_LOCK_STAT
 	unsigned long			contention_point[LOCKSTAT_POINTS];
 	unsigned long			contending_point[LOCKSTAT_POINTS];
@@ -146,6 +149,17 @@ struct lock_class_stats lock_stats(struc
 void clear_lock_stats(struct lock_class *class);
 #endif
 
+enum lockdep_wait_type {
+	LD_WAIT_INV = 0,	/* not checked, catch all */
+
+	LD_WAIT_FREE,		/* wait free, rcu etc.. */
+	LD_WAIT_SPIN,		/* spin loops, raw_spinlock_t etc.. */
+	LD_WAIT_CONFIG,		/* CONFIG_PREEMPT_LOCK, spinlock_t etc.. */
+	LD_WAIT_SLEEP,		/* sleeping locks, mutex_t etc.. */
+
+	LD_WAIT_MAX,		/* must be last */
+};
+
 /*
  * Map the lock object (the lock instance) to the lock-class object.
  * This is embedded into specific lock instances:
@@ -154,6 +168,8 @@ struct lockdep_map {
 	struct lock_class_key		*key;
 	struct lock_class		*class_cache[NR_LOCKDEP_CACHING_CLASSES];
 	const char			*name;
+	short				wait_type_outer; /* can be taken in this context */
+	short				wait_type_inner; /* presents this context */
 #ifdef CONFIG_LOCK_STAT
 	int				cpu;
 	unsigned long			ip;
@@ -281,8 +297,21 @@ extern void lockdep_on(void);
  * to lockdep:
  */
 
-extern void lockdep_init_map(struct lockdep_map *lock, const char *name,
-			     struct lock_class_key *key, int subclass);
+extern void lockdep_init_map_waits(struct lockdep_map *lock, const char *name,
+	struct lock_class_key *key, int subclass, short inner, short outer);
+
+static inline void
+lockdep_init_map_wait(struct lockdep_map *lock, const char *name,
+		      struct lock_class_key *key, int subclass, short inner)
+{
+	lockdep_init_map_waits(lock, name, key, subclass, inner, LD_WAIT_INV);
+}
+
+static inline void lockdep_init_map(struct lockdep_map *lock, const char *name,
+			     struct lock_class_key *key, int subclass)
+{
+	lockdep_init_map_wait(lock, name, key, subclass, LD_WAIT_INV);
+}
 
 /*
  * Reinitialize a lock key - for cases where there is special locking or
@@ -290,18 +319,29 @@ extern void lockdep_init_map(struct lock
  * of dependencies wrong: they are either too broad (they need a class-split)
  * or they are too narrow (they suffer from a false class-split):
  */
-#define lockdep_set_class(lock, key) \
-		lockdep_init_map(&(lock)->dep_map, #key, key, 0)
-#define lockdep_set_class_and_name(lock, key, name) \
-		lockdep_init_map(&(lock)->dep_map, name, key, 0)
-#define lockdep_set_class_and_subclass(lock, key, sub) \
-		lockdep_init_map(&(lock)->dep_map, #key, key, sub)
-#define lockdep_set_subclass(lock, sub)	\
-		lockdep_init_map(&(lock)->dep_map, #lock, \
-				 (lock)->dep_map.key, sub)
+#define lockdep_set_class(lock, key)				\
+	lockdep_init_map_waits(&(lock)->dep_map, #key, key, 0,	\
+			       (lock)->dep_map.wait_type_inner,	\
+			       (lock)->dep_map.wait_type_outer)
+
+#define lockdep_set_class_and_name(lock, key, name)		\
+	lockdep_init_map_waits(&(lock)->dep_map, name, key, 0,	\
+			       (lock)->dep_map.wait_type_inner,	\
+			       (lock)->dep_map.wait_type_outer)
+
+#define lockdep_set_class_and_subclass(lock, key, sub)		\
+	lockdep_init_map_waits(&(lock)->dep_map, #key, key, sub,\
+			       (lock)->dep_map.wait_type_inner,	\
+			       (lock)->dep_map.wait_type_outer)
+
+#define lockdep_set_subclass(lock, sub)					\
+	lockdep_init_map_waits(&(lock)->dep_map, #lock, (lock)->dep_map.key, sub,\
+			       (lock)->dep_map.wait_type_inner,		\
+			       (lock)->dep_map.wait_type_outer)
 
 #define lockdep_set_novalidate_class(lock) \
 	lockdep_set_class_and_name(lock, &__lockdep_no_validate__, #lock)
+
 /*
  * Compare locking classes
  */
@@ -407,6 +447,10 @@ static inline void lockdep_on(void)
 # define lock_set_class(l, n, k, s, i)		do { } while (0)
 # define lock_set_subclass(l, s, i)		do { } while (0)
 # define lockdep_init()				do { } while (0)
+# define lockdep_init_map_waits(lock, name, key, sub, inner, outer) \
+		do { (void)(name); (void)(key); } while (0)
+# define lockdep_init_map_wait(lock, name, key, sub, inner) \
+		do { (void)(name); (void)(key); } while (0)
 # define lockdep_init_map(lock, name, key, sub) \
 		do { (void)(name); (void)(key); } while (0)
 # define lockdep_set_class(lock, key)		do { (void)(key); } while (0)
--- a/include/linux/mutex.h
+++ b/include/linux/mutex.h
@@ -119,8 +119,11 @@ do {									\
 } while (0)
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
-# define __DEP_MAP_MUTEX_INITIALIZER(lockname) \
-		, .dep_map = { .name = #lockname }
+# define __DEP_MAP_MUTEX_INITIALIZER(lockname)			\
+		, .dep_map = {					\
+			.name = #lockname,			\
+			.wait_type_inner = LD_WAIT_SLEEP,	\
+		}
 #else
 # define __DEP_MAP_MUTEX_INITIALIZER(lockname)
 #endif
--- a/include/linux/rwlock_types.h
+++ b/include/linux/rwlock_types.h
@@ -22,7 +22,11 @@ typedef struct {
 #define RWLOCK_MAGIC		0xdeaf1eed
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
-# define RW_DEP_MAP_INIT(lockname)	.dep_map = { .name = #lockname }
+# define RW_DEP_MAP_INIT(lockname)					\
+	.dep_map = {							\
+		.name = #lockname,					\
+		.wait_type_inner = LD_WAIT_CONFIG,			\
+	}
 #else
 # define RW_DEP_MAP_INIT(lockname)
 #endif
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -72,7 +72,11 @@ static inline int rwsem_is_locked(struct
 /* Common initializer macros and functions */
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
-# define __RWSEM_DEP_MAP_INIT(lockname) , .dep_map = { .name = #lockname }
+# define __RWSEM_DEP_MAP_INIT(lockname)			\
+	, .dep_map = {					\
+		.name = #lockname,			\
+		.wait_type_inner = LD_WAIT_SLEEP,	\
+	}
 #else
 # define __RWSEM_DEP_MAP_INIT(lockname)
 #endif
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -920,6 +920,7 @@ struct task_struct {
 
 #ifdef CONFIG_TRACE_IRQFLAGS
 	unsigned int			irq_events;
+	unsigned int			hardirq_threaded;
 	unsigned long			hardirq_enable_ip;
 	unsigned long			hardirq_disable_ip;
 	unsigned int			hardirq_enable_event;
--- a/include/linux/spinlock.h
+++ b/include/linux/spinlock.h
@@ -92,12 +92,13 @@
 
 #ifdef CONFIG_DEBUG_SPINLOCK
   extern void __raw_spin_lock_init(raw_spinlock_t *lock, const char *name,
-				   struct lock_class_key *key);
-# define raw_spin_lock_init(lock)				\
-do {								\
-	static struct lock_class_key __key;			\
-								\
-	__raw_spin_lock_init((lock), #lock, &__key);		\
+				   struct lock_class_key *key, short inner);
+
+# define raw_spin_lock_init(lock)					\
+do {									\
+	static struct lock_class_key __key;				\
+									\
+	__raw_spin_lock_init((lock), #lock, &__key, LD_WAIT_SPIN);	\
 } while (0)
 
 #else
@@ -318,12 +319,26 @@ static __always_inline raw_spinlock_t *s
 	return &lock->rlock;
 }
 
-#define spin_lock_init(_lock)				\
-do {							\
-	spinlock_check(_lock);				\
-	raw_spin_lock_init(&(_lock)->rlock);		\
+#ifdef CONFIG_DEBUG_SPINLOCK
+
+# define spin_lock_init(lock)					\
+do {								\
+	static struct lock_class_key __key;			\
+								\
+	__raw_spin_lock_init(spinlock_check(lock),		\
+			     #lock, &__key, LD_WAIT_CONFIG);	\
+} while (0)
+
+#else
+
+# define spin_lock_init(_lock)			\
+do {						\
+	spinlock_check(_lock);			\
+	*(lock) = __SPIN_LOCK_UNLOCKED(lock);	\
 } while (0)
 
+#endif
+
 static __always_inline void spin_lock(spinlock_t *lock)
 {
 	raw_spin_lock(&lock->rlock);
--- a/include/linux/spinlock_types.h
+++ b/include/linux/spinlock_types.h
@@ -33,8 +33,18 @@ typedef struct raw_spinlock {
 #define SPINLOCK_OWNER_INIT	((void *)-1L)
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
-# define SPIN_DEP_MAP_INIT(lockname)	.dep_map = { .name = #lockname }
+# define RAW_SPIN_DEP_MAP_INIT(lockname)		\
+	.dep_map = {					\
+		.name = #lockname,			\
+		.wait_type_inner = LD_WAIT_SPIN,	\
+	}
+# define SPIN_DEP_MAP_INIT(lockname)			\
+	.dep_map = {					\
+		.name = #lockname,			\
+		.wait_type_inner = LD_WAIT_CONFIG,	\
+	}
 #else
+# define RAW_SPIN_DEP_MAP_INIT(lockname)
 # define SPIN_DEP_MAP_INIT(lockname)
 #endif
 
@@ -51,7 +61,7 @@ typedef struct raw_spinlock {
 	{					\
 	.raw_lock = __ARCH_SPIN_LOCK_UNLOCKED,	\
 	SPIN_DEBUG_INIT(lockname)		\
-	SPIN_DEP_MAP_INIT(lockname) }
+	RAW_SPIN_DEP_MAP_INIT(lockname) }
 
 #define __RAW_SPIN_LOCK_UNLOCKED(lockname)	\
 	(raw_spinlock_t) __RAW_SPIN_LOCK_INITIALIZER(lockname)
@@ -72,11 +82,17 @@ typedef struct spinlock {
 	};
 } spinlock_t;
 
+#define ___SPIN_LOCK_INITIALIZER(lockname)	\
+	{					\
+	.raw_lock = __ARCH_SPIN_LOCK_UNLOCKED,	\
+	SPIN_DEBUG_INIT(lockname)		\
+	SPIN_DEP_MAP_INIT(lockname) }
+
 #define __SPIN_LOCK_INITIALIZER(lockname) \
-	{ { .rlock = __RAW_SPIN_LOCK_INITIALIZER(lockname) } }
+	{ { .rlock = ___SPIN_LOCK_INITIALIZER(lockname) } }
 
 #define __SPIN_LOCK_UNLOCKED(lockname) \
-	(spinlock_t ) __SPIN_LOCK_INITIALIZER(lockname)
+	(spinlock_t) __SPIN_LOCK_INITIALIZER(lockname)
 
 #define DEFINE_SPINLOCK(x)	spinlock_t x = __SPIN_LOCK_UNLOCKED(x)
 
--- a/kernel/irq/handle.c
+++ b/kernel/irq/handle.c
@@ -145,6 +145,13 @@ irqreturn_t __handle_irq_event_percpu(st
 	for_each_action_of_desc(desc, action) {
 		irqreturn_t res;
 
+		/*
+		 * If this IRQ would be threaded under force_irqthreads, mark it so.
+		 */
+		if (irq_settings_can_thread(desc) &&
+		    !(action->flags & (IRQF_NO_THREAD | IRQF_PERCPU | IRQF_ONESHOT)))
+			trace_hardirq_threaded();
+
 		trace_irq_handler_entry(irq, action);
 		res = action->handler(irq, action->dev_id);
 		trace_irq_handler_exit(irq, action, res);
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -519,7 +519,9 @@ static void print_lock_name(struct lock_
 
 	printk(KERN_CONT " (");
 	__print_lock_name(class);
-	printk(KERN_CONT "){%s}", usage);
+	printk("){%s}-{%hd:%hd}", usage,
+			class->wait_type_outer ?: class->wait_type_inner,
+			class->wait_type_inner);
 }
 
 static void print_lockdep_cache(struct lockdep_map *lock)
@@ -793,6 +795,8 @@ register_lock_class(struct lockdep_map *
 	INIT_LIST_HEAD(&class->locks_before);
 	INIT_LIST_HEAD(&class->locks_after);
 	class->name_version = count_matching_names(class);
+	class->wait_type_inner = lock->wait_type_inner;
+	class->wait_type_outer = lock->wait_type_outer;
 	/*
 	 * We use RCU's safe list-add method to make
 	 * parallel walking of the hash-list safe:
@@ -3156,8 +3160,9 @@ static int mark_lock(struct task_struct
 /*
  * Initialize a lock instance's lock-class mapping info:
  */
-static void __lockdep_init_map(struct lockdep_map *lock, const char *name,
-		      struct lock_class_key *key, int subclass)
+void lockdep_init_map_waits(struct lockdep_map *lock, const char *name,
+			    struct lock_class_key *key, int subclass,
+			    short inner, short outer)
 {
 	int i;
 
@@ -3178,6 +3183,9 @@ static void __lockdep_init_map(struct lo
 
 	lock->name = name;
 
+	lock->wait_type_outer = outer;
+	lock->wait_type_inner = inner;
+
 	/*
 	 * No key, no joy, we need to hash something.
 	 */
@@ -3212,13 +3220,7 @@ static void __lockdep_init_map(struct lo
 		raw_local_irq_restore(flags);
 	}
 }
-
-void lockdep_init_map(struct lockdep_map *lock, const char *name,
-		      struct lock_class_key *key, int subclass)
-{
-	__lockdep_init_map(lock, name, key, subclass);
-}
-EXPORT_SYMBOL_GPL(lockdep_init_map);
+EXPORT_SYMBOL_GPL(lockdep_init_map_waits);
 
 struct lock_class_key __lockdep_no_validate__;
 EXPORT_SYMBOL_GPL(__lockdep_no_validate__);
@@ -3257,6 +3259,113 @@ print_lock_nested_lock_not_held(struct t
 	return 0;
 }
 
+static int
+print_lock_invalid_wait_context(struct task_struct *curr,
+				struct held_lock *hlock)
+{
+	if (!debug_locks_off())
+		return 0;
+	if (debug_locks_silent)
+		return 0;
+
+	printk("\n");
+	printk("=============================\n");
+	printk("[ BUG: Invalid wait context ]\n");
+	print_kernel_ident();
+	printk("-----------------------------\n");
+
+	printk("%s/%d is trying to lock:\n", curr->comm, task_pid_nr(curr));
+	print_lock(hlock);
+
+	printk("\nother info that might help us debug this:\n");
+	lockdep_print_held_locks(curr);
+
+	printk("\nstack backtrace:\n");
+	dump_stack();
+
+	return 0;
+}
+
+/*
+ * Verify the wait_type context.
+ *
+ * This check validates we takes locks in the right wait-type order; that is it
+ * ensures that we do not take mutexes inside spinlocks and do not attempt to
+ * acquire spinlocks inside raw_spinlocks and the sort.
+ *
+ * The entire thing is slightly more complex because of RCU, RCU is a lock that
+ * can be taken from (pretty much) any context but also has constraints.
+ * However when taken in a stricter environment the RCU lock does not loosen
+ * the constraints.
+ *
+ * Therefore we must look for the strictest environment in the lock stack and
+ * compare that to the lock we're trying to acquire.
+ */
+static int check_wait_context(struct task_struct *curr, struct held_lock *next)
+{
+	short next_inner = hlock_class(next)->wait_type_inner;
+	short next_outer = hlock_class(next)->wait_type_outer;
+	short curr_inner;
+	int depth;
+
+	if (!curr->lockdep_depth || !next_inner || next->trylock)
+		return 0;
+
+	if (!next_outer)
+		next_outer = next_inner;
+
+	/*
+	 * Find start of current irq_context..
+	 */
+	for (depth = curr->lockdep_depth - 1; depth >= 0; depth--) {
+		struct held_lock *prev = curr->held_locks + depth;
+		if (prev->irq_context != next->irq_context)
+			break;
+	}
+	depth++;
+
+	/*
+	 * Set appropriate wait type for the context; for IRQs we have to take
+	 * into account force_irqthread as that is implied by PREEMPT_RT.
+	 */
+	if (curr->hardirq_context) {
+		/*
+		 * Check if force_irqthreads will run us threaded.
+		 */
+		if (curr->hardirq_threaded)
+			curr_inner = LD_WAIT_CONFIG;
+		else
+			curr_inner = LD_WAIT_SPIN;
+	} else if (curr->softirq_context) {
+		/*
+		 * Softirqs are always threaded.
+		 */
+		curr_inner = LD_WAIT_CONFIG;
+	} else {
+		curr_inner = LD_WAIT_MAX;
+	}
+
+	for (; depth < curr->lockdep_depth; depth++) {
+		struct held_lock *prev = curr->held_locks + depth;
+		short prev_inner = hlock_class(prev)->wait_type_inner;
+
+		if (prev_inner) {
+			/*
+			 * We can have a bigger inner than a previous one
+			 * when outer is smaller than inner, as with RCU.
+			 *
+			 * Also due to trylocks.
+			 */
+			curr_inner = min(curr_inner, prev_inner);
+		}
+	}
+
+	if (next_outer > curr_inner)
+		return print_lock_invalid_wait_context(curr, next);
+
+	return 0;
+}
+
 static int __lock_is_held(const struct lockdep_map *lock, int read);
 
 /*
@@ -3323,7 +3432,7 @@ static int __lock_acquire(struct lockdep
 
 	class_idx = class - lock_classes + 1;
 
-	if (depth) {
+	if (depth) { /* we're holding locks */
 		hlock = curr->held_locks + depth - 1;
 		if (hlock->class_idx == class_idx && nest_lock) {
 			if (hlock->references) {
@@ -3365,6 +3474,9 @@ static int __lock_acquire(struct lockdep
 #endif
 	hlock->pin_count = pin_count;
 
+	if (check_wait_context(curr, hlock))
+		return 0;
+
 	if (check && !mark_irqflags(curr, hlock))
 		return 0;
 
@@ -3579,7 +3691,9 @@ __lock_set_class(struct lockdep_map *loc
 	if (!hlock)
 		return print_unlock_imbalance_bug(curr, lock, ip);
 
-	lockdep_init_map(lock, name, key, 0);
+	lockdep_init_map_waits(lock, name, key, 0,
+			       lock->wait_type_inner,
+			       lock->wait_type_outer);
 	class = register_lock_class(lock, subclass, 0);
 	hlock->class_idx = class - lock_classes + 1;
 
--- a/kernel/locking/mutex-debug.c
+++ b/kernel/locking/mutex-debug.c
@@ -85,7 +85,7 @@ void debug_mutex_init(struct mutex *lock
 	 * Make sure we are not reinitializing a held lock:
 	 */
 	debug_check_no_locks_freed((void *)lock, sizeof(*lock));
-	lockdep_init_map(&lock->dep_map, name, key, 0);
+	lockdep_init_map_wait(&lock->dep_map, name, key, 0, LD_WAIT_SLEEP);
 #endif
 	lock->magic = lock;
 }
--- a/kernel/locking/rwsem-spinlock.c
+++ b/kernel/locking/rwsem-spinlock.c
@@ -46,7 +46,7 @@ void __init_rwsem(struct rw_semaphore *s
 	 * Make sure we are not reinitializing a held semaphore:
 	 */
 	debug_check_no_locks_freed((void *)sem, sizeof(*sem));
-	lockdep_init_map(&sem->dep_map, name, key, 0);
+	lockdep_init_map_wait(&sem->dep_map, name, key, 0, LD_WAIT_SLEEP);
 #endif
 	sem->count = 0;
 	raw_spin_lock_init(&sem->wait_lock);
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -81,7 +81,7 @@ void __init_rwsem(struct rw_semaphore *s
 	 * Make sure we are not reinitializing a held semaphore:
 	 */
 	debug_check_no_locks_freed((void *)sem, sizeof(*sem));
-	lockdep_init_map(&sem->dep_map, name, key, 0);
+	lockdep_init_map_wait(&sem->dep_map, name, key, 0, LD_WAIT_SLEEP);
 #endif
 	atomic_long_set(&sem->count, RWSEM_UNLOCKED_VALUE);
 	raw_spin_lock_init(&sem->wait_lock);
--- a/kernel/locking/spinlock_debug.c
+++ b/kernel/locking/spinlock_debug.c
@@ -14,14 +14,14 @@
 #include <linux/export.h>
 
 void __raw_spin_lock_init(raw_spinlock_t *lock, const char *name,
-			  struct lock_class_key *key)
+			  struct lock_class_key *key, short inner)
 {
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 	/*
 	 * Make sure we are not reinitializing a held lock:
 	 */
 	debug_check_no_locks_freed((void *)lock, sizeof(*lock));
-	lockdep_init_map(&lock->dep_map, name, key, 0);
+	lockdep_init_map_wait(&lock->dep_map, name, key, 0, inner);
 #endif
 	lock->raw_lock = (arch_spinlock_t)__ARCH_SPIN_LOCK_UNLOCKED;
 	lock->magic = SPINLOCK_MAGIC;
@@ -39,7 +39,7 @@ void __rwlock_init(rwlock_t *lock, const
 	 * Make sure we are not reinitializing a held lock:
 	 */
 	debug_check_no_locks_freed((void *)lock, sizeof(*lock));
-	lockdep_init_map(&lock->dep_map, name, key, 0);
+	lockdep_init_map_wait(&lock->dep_map, name, key, 0, LD_WAIT_CONFIG);
 #endif
 	lock->raw_lock = (arch_rwlock_t) __ARCH_RW_LOCK_UNLOCKED;
 	lock->magic = RWLOCK_MAGIC;
--- a/kernel/rcu/update.c
+++ b/kernel/rcu/update.c
@@ -228,18 +228,30 @@ core_initcall(rcu_set_runtime_mode);
 
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 static struct lock_class_key rcu_lock_key;
-struct lockdep_map rcu_lock_map =
-	STATIC_LOCKDEP_MAP_INIT("rcu_read_lock", &rcu_lock_key);
+struct lockdep_map rcu_lock_map = {
+	.name = "rcu_read_lock",
+	.key = &rcu_lock_key,
+	.wait_type_outer = LD_WAIT_FREE,
+	.wait_type_inner = LD_WAIT_CONFIG, /* XXX PREEMPT_RCU ? */
+};
 EXPORT_SYMBOL_GPL(rcu_lock_map);
 
 static struct lock_class_key rcu_bh_lock_key;
-struct lockdep_map rcu_bh_lock_map =
-	STATIC_LOCKDEP_MAP_INIT("rcu_read_lock_bh", &rcu_bh_lock_key);
+struct lockdep_map rcu_bh_lock_map = {
+	.name = "rcu_read_lock_bh",
+	.key = &rcu_bh_lock_key,
+	.wait_type_outer = LD_WAIT_FREE,
+	.wait_type_inner = LD_WAIT_CONFIG, /* PREEMPT_LOCK also makes BH preemptible */
+};
 EXPORT_SYMBOL_GPL(rcu_bh_lock_map);
 
 static struct lock_class_key rcu_sched_lock_key;
-struct lockdep_map rcu_sched_lock_map =
-	STATIC_LOCKDEP_MAP_INIT("rcu_read_lock_sched", &rcu_sched_lock_key);
+struct lockdep_map rcu_sched_lock_map = {
+	.name = "rcu_read_lock_sched",
+	.key = &rcu_sched_lock_key,
+	.wait_type_outer = LD_WAIT_FREE,
+	.wait_type_inner = LD_WAIT_SPIN,
+};
 EXPORT_SYMBOL_GPL(rcu_sched_lock_map);
 
 static struct lock_class_key rcu_callback_key;
