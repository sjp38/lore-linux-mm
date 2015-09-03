Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 158ED6B0259
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 10:17:33 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so40805788igb.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:17:32 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id v8si41742780pdm.155.2015.09.03.07.17.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 07:17:32 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so49190561pac.2
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 07:17:31 -0700 (PDT)
From: Hajime Tazaki <thehajime@gmail.com>
Subject: [PATCH v6 04/10] lib: time handling (kernel glue code)
Date: Thu,  3 Sep 2015 23:16:26 +0900
Message-Id: <1441289792-64064-5-git-send-email-thehajime@gmail.com>
In-Reply-To: <1441289792-64064-1-git-send-email-thehajime@gmail.com>
References: <1431494921-24746-1-git-send-email-tazaki@sfc.wide.ad.jp>
 <1441289792-64064-1-git-send-email-thehajime@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <thehajime@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

timer related (internal) functions such as add_timer(),
do_gettimeofday() of kernel are trivially reimplemented
for libos. these eventually call the functions registered by lib_init()
API.

Signed-off-by: Hajime Tazaki <thehajime@gmail.com>
---
 arch/lib/hrtimer.c         | 117 ++++++++++++++++++
 arch/lib/tasklet-hrtimer.c |  57 +++++++++
 arch/lib/time.c            | 116 ++++++++++++++++++
 arch/lib/timer.c           | 299 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 589 insertions(+)
 create mode 100644 arch/lib/hrtimer.c
 create mode 100644 arch/lib/tasklet-hrtimer.c
 create mode 100644 arch/lib/time.c
 create mode 100644 arch/lib/timer.c

diff --git a/arch/lib/hrtimer.c b/arch/lib/hrtimer.c
new file mode 100644
index 000000000000..6a99bad6c5b7
--- /dev/null
+++ b/arch/lib/hrtimer.c
@@ -0,0 +1,117 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/hrtimer.h>
+#include "sim-assert.h"
+#include "sim.h"
+
+/**
+ * hrtimer_init - initialize a timer to the given clock
+ * @timer:      the timer to be initialized
+ * @clock_id:   the clock to be used
+ * @mode:       timer mode abs/rel
+ */
+void hrtimer_init(struct hrtimer *timer, clockid_t clock_id,
+		  enum hrtimer_mode mode)
+{
+	memset(timer, 0, sizeof(*timer));
+}
+static void trampoline(void *context)
+{
+	struct hrtimer *timer = context;
+	enum hrtimer_restart restart = timer->function(timer);
+
+	if (restart == HRTIMER_RESTART) {
+		void *event =
+			lib_event_schedule_ns(ktime_to_ns(timer->_softexpires),
+					      &trampoline, timer);
+		timer->base = event;
+	} else {
+		/* mark as completed. */
+		timer->base = 0;
+	}
+}
+/**
+ * hrtimer_start_range_ns - (re)start an hrtimer on the current CPU
+ * @timer:      the timer to be added
+ * @tim:        expiry time
+ * @delta_ns:   "slack" range for the timer
+ * @mode:       expiry mode: absolute (HRTIMER_ABS) or relative (HRTIMER_REL)
+ *
+ * Returns:
+ *  0 on success
+ *  1 when the timer was active
+ */
+int __hrtimer_start_range_ns(struct hrtimer *timer, ktime_t tim,
+			     unsigned long delta_ns,
+			     const enum hrtimer_mode mode,
+			     int wakeup)
+{
+	int ret = hrtimer_cancel(timer);
+	s64 ns = ktime_to_ns(tim);
+	void *event;
+
+	if (mode == HRTIMER_MODE_ABS)
+		ns -= lib_current_ns();
+	timer->_softexpires = ns_to_ktime(ns);
+	event = lib_event_schedule_ns(ns, &trampoline, timer);
+	timer->base = event;
+	return ret;
+}
+/**
+ * hrtimer_try_to_cancel - try to deactivate a timer
+ * @timer:      hrtimer to stop
+ *
+ * Returns:
+ *  0 when the timer was not active
+ *  1 when the timer was active
+ * -1 when the timer is currently excuting the callback function and
+ *    cannot be stopped
+ */
+int hrtimer_try_to_cancel(struct hrtimer *timer)
+{
+	/* Note: we cannot return -1 from this function.
+	   see comment in hrtimer_cancel. */
+	if (timer->base == 0)
+		/* timer was not active yet */
+		return 1;
+	lib_event_cancel(timer->base);
+	timer->base = 0;
+	return 0;
+}
+/**
+ * hrtimer_cancel - cancel a timer and wait for the handler to finish.
+ * @timer:      the timer to be cancelled
+ *
+ * Returns:
+ *  0 when the timer was not active
+ *  1 when the timer was active
+ */
+int hrtimer_cancel(struct hrtimer *timer)
+{
+	/* Note: because we assume a uniprocessor non-interruptible */
+	/* system when running in the kernel, we know that the timer */
+	/* is not running when we execute this code, so, know that */
+	/* try_to_cancel cannot return -1 and we don't need to retry */
+	/* the cancel later to wait for the handler to finish. */
+	int ret = hrtimer_try_to_cancel(timer);
+
+	lib_assert(ret >= 0);
+	return ret;
+}
+void hrtimer_start_range_ns(struct hrtimer *timer, ktime_t tim,
+			   unsigned long delta_ns, const enum hrtimer_mode mode)
+{
+	__hrtimer_start_range_ns(timer, tim, delta_ns, mode, 1);
+}
+
+int hrtimer_get_res(const clockid_t which_clock, struct timespec *tp)
+{
+	*tp = ns_to_timespec(1);
+	return 0;
+}
diff --git a/arch/lib/tasklet-hrtimer.c b/arch/lib/tasklet-hrtimer.c
new file mode 100644
index 000000000000..fef4902d4938
--- /dev/null
+++ b/arch/lib/tasklet-hrtimer.c
@@ -0,0 +1,57 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/interrupt.h>
+#include "sim.h"
+#include "sim-assert.h"
+
+static enum hrtimer_restart __hrtimer_tasklet_trampoline(struct hrtimer *timer)
+{
+	struct tasklet_hrtimer *ttimer =
+		container_of(timer, struct tasklet_hrtimer, timer);
+
+	tasklet_schedule(&ttimer->tasklet);
+	return HRTIMER_NORESTART;
+}
+static void __tasklet_hrtimer_trampoline(unsigned long data)
+{
+	struct tasklet_hrtimer *ttimer = (void *)data;
+	enum hrtimer_restart restart;
+
+	restart = ttimer->function(&ttimer->timer);
+	if (restart != HRTIMER_NORESTART)
+		hrtimer_restart(&ttimer->timer);
+}
+/**
+ * tasklet_hrtimer_init - Init a tasklet/hrtimer combo for softirq callbacks
+ * @ttimer:      tasklet_hrtimer which is initialized
+ * @function:    hrtimer callback function which gets called from softirq context
+ * @which_clock: clock id (CLOCK_MONOTONIC/CLOCK_REALTIME)
+ * @mode:        hrtimer mode (HRTIMER_MODE_ABS/HRTIMER_MODE_REL)
+ */
+void tasklet_hrtimer_init(struct tasklet_hrtimer *ttimer,
+			  enum hrtimer_restart (*function)(struct hrtimer *),
+			  clockid_t which_clock, enum hrtimer_mode mode)
+{
+	hrtimer_init(&ttimer->timer, which_clock, mode);
+	ttimer->timer.function = __hrtimer_tasklet_trampoline;
+	tasklet_init(&ttimer->tasklet, __tasklet_hrtimer_trampoline,
+		     (unsigned long)ttimer);
+	ttimer->function = function;
+}
+
+void __tasklet_hi_schedule(struct tasklet_struct *t)
+{
+	/* Note: no need to set TASKLET_STATE_SCHED because
+	   it is set by caller. */
+	lib_assert(t->next == 0);
+	/* run the tasklet at the next immediately available opportunity. */
+	void *event =
+		lib_event_schedule_ns(0, (void *)&t->func, (void *)t->data);
+	t->next = event;
+}
diff --git a/arch/lib/time.c b/arch/lib/time.c
new file mode 100644
index 000000000000..bc119843e0fd
--- /dev/null
+++ b/arch/lib/time.c
@@ -0,0 +1,116 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/time.h>
+#include <linux/errno.h>
+#include <linux/timex.h>
+#include <linux/ktime.h>
+#include "sim.h"
+#include "sim-assert.h"
+
+unsigned long volatile jiffies = INITIAL_JIFFIES;
+u64 jiffies_64 = INITIAL_JIFFIES;
+
+struct timespec xtime;
+seqlock_t xtime_lock;
+/* accessed from wrap_clock from do_sys_settimeofday.
+   We don't call the latter so we should never access this variable. */
+struct timespec wall_to_monotonic;
+
+uint64_t ns_to_jiffies(uint64_t ns)
+{
+	do_div(ns, (1000000000 / HZ));
+	return ns;
+}
+
+void lib_update_jiffies(void)
+{
+	jiffies = ns_to_jiffies(lib_current_ns());
+	jiffies_64 = ns_to_jiffies(lib_current_ns());
+}
+
+/* copied from kernel/time/hrtimeer.c */
+#if BITS_PER_LONG < 64
+/*
+ * Divide a ktime value by a nanosecond value
+ */
+s64 __ktime_divns(const ktime_t kt, s64 div)
+{
+	int sft = 0;
+	s64 dclc;
+	u64 tmp;
+
+	dclc = ktime_to_ns(kt);
+	tmp = dclc < 0 ? -dclc : dclc;
+
+	/* Make sure the divisor is less than 2^32: */
+	while (div >> 32) {
+		sft++;
+		div >>= 1;
+	}
+	tmp >>= sft;
+	do_div(tmp, (unsigned long) div);
+	return dclc < 0 ? -tmp : tmp;
+}
+#endif /* BITS_PER_LONG >= 64 */
+
+static unsigned long
+round_jiffies_common(unsigned long j,
+		     bool force_up)
+{
+	int rem;
+	unsigned long original = j;
+
+	rem = j % HZ;
+	if (rem < HZ / 4 && !force_up)  /* round down */
+		j = j - rem;
+	else                            /* round up */
+		j = j - rem + HZ;
+	if (j <= jiffies)               /* rounding ate our timeout entirely; */
+		return original;
+	return j;
+}
+unsigned long round_jiffies(unsigned long j)
+{
+	return round_jiffies_common(j, false);
+}
+unsigned long round_jiffies_relative(unsigned long j)
+{
+	unsigned long j0 = jiffies;
+
+	/* Use j0 because jiffies might change while we run */
+	return round_jiffies_common(j + j0, false) - j0;
+}
+unsigned long round_jiffies_up(unsigned long j)
+{
+	return round_jiffies_common(j, true);
+}
+static void msleep_trampoline(void *context)
+{
+	struct SimTask *task = context;
+
+	lib_task_wakeup(task);
+}
+void msleep(unsigned int msecs)
+{
+	lib_event_schedule_ns(((__u64)msecs) * 1000000, &msleep_trampoline,
+			      lib_task_current());
+	lib_task_wait();
+}
+
+void read_persistent_clock(struct timespec *ts)
+{
+	u64 nsecs = lib_current_ns();
+
+	set_normalized_timespec(ts, nsecs / NSEC_PER_SEC,
+				nsecs % NSEC_PER_SEC);
+}
+
+void __init time_init(void)
+{
+}
diff --git a/arch/lib/timer.c b/arch/lib/timer.c
new file mode 100644
index 000000000000..d290e3721841
--- /dev/null
+++ b/arch/lib/timer.c
@@ -0,0 +1,299 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/timer.h>
+#include <linux/interrupt.h>
+#include <linux/hash.h>
+#include <linux/hashtable.h>
+
+#include "sim-assert.h"
+#include "sim.h"
+
+static DEFINE_HASHTABLE(lib_timers_hashtable, 9);
+struct lib_timer {
+	struct timer_list *timer;
+	struct hlist_node t_hash;
+	void *event;
+};
+
+static int hash(struct timer_list *timer)
+{
+	return hash_32(hash32_ptr(timer), HASH_BITS(lib_timers_hashtable));
+}
+
+static struct lib_timer *__lib_timers_find(struct hlist_head *head,
+					   struct timer_list *timer)
+{
+	struct lib_timer *l_timer;
+
+	hlist_for_each_entry(l_timer, head, t_hash) {
+		if (l_timer->timer == timer)
+			return l_timer;
+	}
+	return NULL;
+}
+
+static struct lib_timer *lib_timer_find(struct timer_list *timer)
+{
+	struct hlist_head *head;
+
+	head = &lib_timers_hashtable[hash(timer)];
+	return __lib_timers_find(head, timer);
+}
+
+/**
+ * init_timer_key - initialize a timer
+ * @timer: the timer to be initialized
+ * @name: name of the timer
+ * @key: lockdep class key of the fake lock used for tracking timer
+ *       sync lock dependencies
+ *
+ * init_timer_key() must be done to a timer prior calling *any* of the
+ * other timer functions.
+ */
+void init_timer_key(struct timer_list *timer,
+		    unsigned int flags,
+		    const char *name,
+		    struct lock_class_key *key)
+{
+	/**
+	 * Note: name and key are used for debugging. We ignore them
+	 * unconditionally.
+	 * Note: we do not initialize the lockdep map either because we
+	 * don't care.
+	 * and, finally, we never care about the base field either.
+	 *
+	 * So, for now, we have a timer which is marked as "not started"
+	 * thanks to its entry.pprev field set to NULL (timer_pending
+	 * will return 0)
+	 */
+	timer->entry.pprev = NULL;
+}
+
+struct hlist_head g_expired_events;
+struct hlist_head g_pending_events;
+
+static void run_timer_softirq(struct softirq_action *h)
+{
+	while (!hlist_empty(&g_expired_events)) {
+		struct timer_list *timer =
+			hlist_entry((&g_expired_events)->first,
+				    struct timer_list, entry);
+		void (*fn)(unsigned long);
+		unsigned long data;
+		struct lib_timer *l_timer = lib_timer_find(timer);
+
+		fn = timer->function;
+		data = timer->data;
+		lib_assert(l_timer->event == 0);
+
+		hlist_del(&timer->entry);
+		timer->entry.pprev = NULL;
+		fn(data);
+	}
+}
+
+static void ensure_softirq_opened(void)
+{
+	static bool opened = false;
+
+	if (opened)
+		return;
+	opened = true;
+	open_softirq(TIMER_SOFTIRQ, run_timer_softirq);
+}
+static void timer_trampoline(void *context)
+{
+	struct timer_list *timer;
+	struct lib_timer *l_timer;
+
+	ensure_softirq_opened();
+	timer = context;
+
+	l_timer = lib_timer_find(timer);
+	if (l_timer)
+		l_timer->event = NULL;
+
+	if (timer->entry.pprev != 0)
+		hlist_del(&timer->entry);
+
+	timer->entry.pprev = NULL;
+	hlist_add_head(&timer->entry, &g_expired_events);
+	raise_softirq(TIMER_SOFTIRQ);
+}
+/**
+ * add_timer - start a timer
+ * @timer: the timer to be added
+ *
+ * The kernel will do a ->function(->data) callback from the
+ * timer interrupt at the ->expires point in the future. The
+ * current time is 'jiffies'.
+ *
+ * The timer's ->expires, ->function (and if the handler uses it, ->data)
+ * fields must be set prior calling this function.
+ *
+ * Timers with an ->expires field in the past will be executed in the next
+ * timer tick.
+ */
+void add_timer(struct timer_list *timer)
+{
+	__u64 delay_ns = 0;
+	struct hlist_head *head;
+
+	lib_assert(!timer_pending(timer));
+	if (timer->expires <= jiffies)
+		delay_ns = (1000000000 / HZ); /* next tick. */
+	else
+		delay_ns =
+			((__u64)timer->expires *
+			 (1000000000 / HZ)) - lib_current_ns();
+	void *event = lib_event_schedule_ns(delay_ns, &timer_trampoline, timer);
+
+	/* store the external event in the hash table */
+	/* to be able to retrieve it from del_timer */
+	head = &lib_timers_hashtable[hash(timer)];
+	if (!__lib_timers_find(head, timer)) {
+		struct lib_timer *l_timer;
+
+		l_timer = lib_malloc(sizeof(struct lib_timer));
+		l_timer->timer = timer;
+		l_timer->event = event;
+		hlist_add_head(&l_timer->t_hash, head);
+	}
+
+	/* finally, store timer in list of pending events. */
+	hlist_add_head(&timer->entry, &g_pending_events);
+}
+/**
+ * del_timer - deactive a timer.
+ * @timer: the timer to be deactivated
+ *
+ * del_timer() deactivates a timer - this works on both active and inactive
+ * timers.
+ *
+ * The function returns whether it has deactivated a pending timer or not.
+ * (ie. del_timer() of an inactive timer returns 0, del_timer() of an
+ * active timer returns 1.)
+ */
+int del_timer(struct timer_list *timer)
+{
+	int retval;
+	struct lib_timer *l_timer;
+
+	if (timer->entry.pprev == NULL)
+		return 0;
+
+	l_timer = lib_timer_find(timer);
+	if (l_timer != NULL && l_timer->event != NULL) {
+		lib_event_cancel(l_timer->event);
+
+		if (l_timer->t_hash.next != LIST_POISON1) {
+			hlist_del(&l_timer->t_hash);
+			lib_free(l_timer);
+		}
+		retval = 1;
+	} else {
+		retval = 0;
+	}
+
+	if (timer->entry.next != LIST_POISON1)
+		hlist_del(&timer->entry);
+	timer->entry.pprev = NULL;
+	return retval;
+}
+
+/* ////////////////////// */
+
+void init_timer_deferrable_key(struct timer_list *timer,
+			       const char *name,
+			       struct lock_class_key *key)
+{
+	/**
+	 * From lwn.net:
+	 * Timers which are initialized in this fashion will be
+	 * recognized as deferrable by the kernel. They will not
+	 * be considered when the kernel makes its "when should
+	 * the next timer interrupt be?" decision. When the system
+	 * is busy these timers will fire at the scheduled time. When
+	 * things are idle, instead, they will simply wait until
+	 * something more important wakes up the processor.
+	 *
+	 * Note: Our implementation of deferrable timers uses
+	 * non-deferrable timers for simplicity.
+	 */
+	init_timer_key(timer, 0, name, key);
+}
+/**
+ * add_timer_on - start a timer on a particular CPU
+ * @timer: the timer to be added
+ * @cpu: the CPU to start it on
+ *
+ * This is not very scalable on SMP. Double adds are not possible.
+ */
+void add_timer_on(struct timer_list *timer, int cpu)
+{
+	/* we ignore the cpu: we have only one. */
+	add_timer(timer);
+}
+/**
+ * mod_timer - modify a timer's timeout
+ * @timer: the timer to be modified
+ * @expires: new timeout in jiffies
+ *
+ * mod_timer() is a more efficient way to update the expire field of an
+ * active timer (if the timer is inactive it will be activated)
+ *
+ * mod_timer(timer, expires) is equivalent to:
+ *
+ *     del_timer(timer); timer->expires = expires; add_timer(timer);
+ *
+ * Note that if there are multiple unserialized concurrent users of the
+ * same timer, then mod_timer() is the only safe way to modify the timeout,
+ * since add_timer() cannot modify an already running timer.
+ *
+ * The function returns whether it has modified a pending timer or not.
+ * (ie. mod_timer() of an inactive timer returns 0, mod_timer() of an
+ * active timer returns 1.)
+ */
+int mod_timer(struct timer_list *timer, unsigned long expires)
+{
+	int ret;
+
+	/* common optimization stolen from kernel */
+	if (timer_pending(timer) && timer->expires == expires)
+		return 1;
+
+	ret = del_timer(timer);
+	timer->expires = expires;
+	add_timer(timer);
+	return ret;
+}
+/**
+ * mod_timer_pending - modify a pending timer's timeout
+ * @timer: the pending timer to be modified
+ * @expires: new timeout in jiffies
+ *
+ * mod_timer_pending() is the same for pending timers as mod_timer(),
+ * but will not re-activate and modify already deleted timers.
+ *
+ * It is useful for unserialized use of timers.
+ */
+int mod_timer_pending(struct timer_list *timer, unsigned long expires)
+{
+	if (timer_pending(timer))
+		return 0;
+	return mod_timer(timer, expires);
+}
+
+int mod_timer_pinned(struct timer_list *timer, unsigned long expires)
+{
+	if (timer->expires == expires && timer_pending(timer))
+		return 1;
+
+	return mod_timer(timer, expires);
+}
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
