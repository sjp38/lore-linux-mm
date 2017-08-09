Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 200B96B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 06:24:50 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c196so49796507itc.2
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 03:24:50 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id q188si3403216iof.204.2017.08.09.03.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 03:24:48 -0700 (PDT)
Date: Wed, 9 Aug 2017 12:24:39 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v8 09/14] lockdep: Apply crossrelease to completions
Message-ID: <20170809102439.7ze32yrua4ieyswe@hirez.programming.kicks-ass.net>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-10-git-send-email-byungchul.park@lge.com>
 <20170809095107.2nzb4m4wq2p77ppb@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170809095107.2nzb4m4wq2p77ppb@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Aug 09, 2017 at 11:51:07AM +0200, Peter Zijlstra wrote:
> On Mon, Aug 07, 2017 at 04:12:56PM +0900, Byungchul Park wrote:
> > +static inline void wait_for_completion(struct completion *x)
> > +{
> > +	complete_acquire(x);
> > +	__wait_for_completion(x);
> > +	complete_release(x);
> > +}
> > +
> > +static inline void wait_for_completion_io(struct completion *x)
> > +{
> > +	complete_acquire(x);
> > +	__wait_for_completion_io(x);
> > +	complete_release(x);
> > +}
> > +
> > +static inline int wait_for_completion_interruptible(struct completion *x)
> > +{
> > +	int ret;
> > +	complete_acquire(x);
> > +	ret = __wait_for_completion_interruptible(x);
> > +	complete_release(x);
> > +	return ret;
> > +}
> > +
> > +static inline int wait_for_completion_killable(struct completion *x)
> > +{
> > +	int ret;
> > +	complete_acquire(x);
> > +	ret = __wait_for_completion_killable(x);
> > +	complete_release(x);
> > +	return ret;
> > +}
> 
> I don't understand, why not change __wait_for_common() ?

That is what is wrong with the below?

Yes, it adds acquire/release to the timeout variants too, but I don't
see why we should exclude those, and even if we'd want to do that, it
would be trivial:

	bool timo = (timeout == MAX_SCHEDULE_TIMEOUT);

	if (!timo)
		complete_acquire(x);

	/* ... */

	if (!timo)
		complete_release(x);

But like said, I think we very much want to annotate waits with timeouts
too. Hitting the max timo doesn't necessarily mean we'll make fwd
progress, we could be stuck in a loop doing something else again before
returning to wait.

Also, even if we'd make fwd progress, hitting that max timo is still not
desirable.

---
Subject: lockdep: Apply crossrelease to completions
From: Byungchul Park <byungchul.park@lge.com>
Date: Mon, 7 Aug 2017 16:12:56 +0900

Although wait_for_completion() and its family can cause deadlock, the
lock correctness validator could not be applied to them until now,
because things like complete() are usually called in a different context
from the waiting context, which violates lockdep's assumption.

Thanks to CONFIG_LOCKDEP_CROSSRELEASE, we can now apply the lockdep
detector to those completion operations. Applied it.

Cc: npiggin@gmail.com
Cc: mingo@kernel.org
Cc: akpm@linux-foundation.org
Cc: tglx@linutronix.de
Cc: boqun.feng@gmail.com
Cc: willy@infradead.org
Cc: walken@google.com
Cc: kernel-team@lge.com
Cc: kirill@shutemov.name
Signed-off-by: Byungchul Park <byungchul.park@lge.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/linux/completion.h |   45 ++++++++++++++++++++++++++++++++++++++++++++-
 kernel/sched/completion.c  |   11 +++++++++++
 lib/Kconfig.debug          |    8 ++++++++
 3 files changed, 63 insertions(+), 1 deletion(-)

--- a/include/linux/completion.h
+++ b/include/linux/completion.h
@@ -9,6 +9,9 @@
  */
 
 #include <linux/wait.h>
+#ifdef CONFIG_LOCKDEP_COMPLETE
+#include <linux/lockdep.h>
+#endif
 
 /*
  * struct completion - structure used to maintain state for a "completion"
@@ -25,10 +28,50 @@
 struct completion {
 	unsigned int done;
 	wait_queue_head_t wait;
+#ifdef CONFIG_LOCKDEP_COMPLETE
+	struct lockdep_map_cross map;
+#endif
 };
 
+#ifdef CONFIG_LOCKDEP_COMPLETE
+static inline void complete_acquire(struct completion *x)
+{
+	lock_acquire_exclusive((struct lockdep_map *)&x->map, 0, 0, NULL, _RET_IP_);
+}
+
+static inline void complete_release(struct completion *x)
+{
+	lock_release((struct lockdep_map *)&x->map, 0, _RET_IP_);
+}
+
+static inline void complete_release_commit(struct completion *x)
+{
+	lock_commit_crosslock((struct lockdep_map *)&x->map);
+}
+
+#define init_completion(x)						\
+do {									\
+	static struct lock_class_key __key;				\
+	lockdep_init_map_crosslock((struct lockdep_map *)&(x)->map,	\
+			"(complete)" #x,				\
+			&__key, 0);					\
+	__init_completion(x);						\
+} while (0)
+#else
+#define init_completion(x) __init_completion(x)
+static inline void complete_acquire(struct completion *x) {}
+static inline void complete_release(struct completion *x) {}
+static inline void complete_release_commit(struct completion *x) {}
+#endif
+
+#ifdef CONFIG_LOCKDEP_COMPLETE
+#define COMPLETION_INITIALIZER(work) \
+	{ 0, __WAIT_QUEUE_HEAD_INITIALIZER((work).wait), \
+	STATIC_CROSS_LOCKDEP_MAP_INIT("(complete)" #work, &(work)) }
+#else
 #define COMPLETION_INITIALIZER(work) \
 	{ 0, __WAIT_QUEUE_HEAD_INITIALIZER((work).wait) }
+#endif
 
 #define COMPLETION_INITIALIZER_ONSTACK(work) \
 	({ init_completion(&work); work; })
@@ -70,7 +113,7 @@ struct completion {
  * This inline function will initialize a dynamically created completion
  * structure.
  */
-static inline void init_completion(struct completion *x)
+static inline void __init_completion(struct completion *x)
 {
 	x->done = 0;
 	init_waitqueue_head(&x->wait);
--- a/kernel/sched/completion.c
+++ b/kernel/sched/completion.c
@@ -32,6 +32,12 @@ void complete(struct completion *x)
 	unsigned long flags;
 
 	spin_lock_irqsave(&x->wait.lock, flags);
+
+	/*
+	 * Perform commit of crossrelease here.
+	 */
+	complete_release_commit(x);
+
 	if (x->done != UINT_MAX)
 		x->done++;
 	__wake_up_locked(&x->wait, TASK_NORMAL, 1);
@@ -92,9 +98,14 @@ __wait_for_common(struct completion *x,
 {
 	might_sleep();
 
+	complete_acquire(x);
+
 	spin_lock_irq(&x->wait.lock);
 	timeout = do_wait_for_common(x, action, timeout, state);
 	spin_unlock_irq(&x->wait.lock);
+
+	complete_release(x);
+
 	return timeout;
 }
 
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1085,6 +1085,14 @@ config LOCKDEP_CROSSRELEASE
 	 such as page locks or completions can use the lock correctness
 	 detector, lockdep.
 
+config LOCKDEP_COMPLETE
+	bool "Lock debugging: allow completions to use deadlock detector"
+	select LOCKDEP_CROSSRELEASE
+	default n
+	help
+	 A deadlock caused by wait_for_completion() and complete() can be
+	 detected by lockdep using crossrelease feature.
+
 config PROVE_LOCKING
 	bool "Lock debugging: prove locking correctness"
 	depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
