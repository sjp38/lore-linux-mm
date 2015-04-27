Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB856B0072
	for <linux-mm@kvack.org>; Sun, 26 Apr 2015 23:01:04 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so114095050pac.1
        for <linux-mm@kvack.org>; Sun, 26 Apr 2015 20:01:04 -0700 (PDT)
Received: from mail.sfc.wide.ad.jp (shonan.sfc.wide.ad.jp. [2001:200:0:8803::53])
        by mx.google.com with ESMTPS id qd5si13380869pac.167.2015.04.26.20.01.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Apr 2015 20:01:02 -0700 (PDT)
From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Subject: [PATCH v4 05/10] lib: context and scheduling functions (kernel glue code) for libos
Date: Mon, 27 Apr 2015 12:00:13 +0900
Message-Id: <1430103618-10832-6-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1430103618-10832-1-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1429450104-47619-1-git-send-email-tazaki@sfc.wide.ad.jp>
 <1430103618-10832-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

contexnt primitives of kernel such as soft interupts, scheduling,
tasklet are implemented for libos. these functions eventually call the
functions registered by lib_init() API as well.

Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
---
 arch/lib/sched.c     | 406 +++++++++++++++++++++++++++++++++++++++++++++++++++
 arch/lib/softirq.c   | 108 ++++++++++++++
 arch/lib/tasklet.c   |  76 ++++++++++
 arch/lib/workqueue.c | 242 ++++++++++++++++++++++++++++++
 4 files changed, 832 insertions(+)
 create mode 100644 arch/lib/sched.c
 create mode 100644 arch/lib/softirq.c
 create mode 100644 arch/lib/tasklet.c
 create mode 100644 arch/lib/workqueue.c

diff --git a/arch/lib/sched.c b/arch/lib/sched.c
new file mode 100644
index 0000000..98a568a
--- /dev/null
+++ b/arch/lib/sched.c
@@ -0,0 +1,406 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/wait.h>
+#include <linux/list.h>
+#include <linux/sched.h>
+#include <linux/nsproxy.h>
+#include <linux/hash.h>
+#include <net/net_namespace.h>
+#include "lib.h"
+#include "sim.h"
+#include "sim-assert.h"
+
+/**
+   called by wait_event macro:
+   - prepare_to_wait
+   - schedule
+   - finish_wait
+ */
+
+struct SimTask *lib_task_create(void *private, unsigned long pid)
+{
+	struct SimTask *task = lib_malloc(sizeof(struct SimTask));
+	struct cred *cred;
+	struct nsproxy *ns;
+	struct user_struct *user;
+	struct thread_info *info;
+	struct pid *kpid;
+
+	if (!task)
+		return NULL;
+	memset(task, 0, sizeof(struct SimTask));
+	cred = lib_malloc(sizeof(struct cred));
+	if (!cred)
+		return NULL;
+	/* XXX: we could optimize away this allocation by sharing it
+	   for all tasks */
+	ns = lib_malloc(sizeof(struct nsproxy));
+	if (!ns)
+		return NULL;
+	user = lib_malloc(sizeof(struct user_struct));
+	if (!user)
+		return NULL;
+	info = alloc_thread_info(&task->kernel_task);
+	if (!info)
+		return NULL;
+	kpid = lib_malloc(sizeof(struct pid));
+	if (!kpid)
+		return NULL;
+	kpid->numbers[0].nr = pid;
+	cred->fsuid = make_kuid(current_user_ns(), 0);
+	cred->fsgid = make_kgid(current_user_ns(), 0);
+	cred->user = user;
+	atomic_set(&cred->usage, 1);
+	info->task = &task->kernel_task;
+	info->preempt_count = 0;
+	info->flags = 0;
+	atomic_set(&ns->count, 1);
+	ns->uts_ns = 0;
+	ns->ipc_ns = 0;
+	ns->mnt_ns = 0;
+	ns->pid_ns_for_children = 0;
+	ns->net_ns = &init_net;
+	task->kernel_task.cred = cred;
+	task->kernel_task.pid = pid;
+	task->kernel_task.pids[PIDTYPE_PID].pid = kpid;
+	task->kernel_task.pids[PIDTYPE_PGID].pid = kpid;
+	task->kernel_task.pids[PIDTYPE_SID].pid = kpid;
+	task->kernel_task.nsproxy = ns;
+	task->kernel_task.stack = info;
+	/* this is a hack. */
+	task->kernel_task.group_leader = &task->kernel_task;
+	task->private = private;
+	return task;
+}
+void lib_task_destroy(struct SimTask *task)
+{
+	lib_free((void *)task->kernel_task.nsproxy);
+	lib_free((void *)task->kernel_task.cred);
+	lib_free((void *)task->kernel_task.cred->user);
+	free_thread_info(task->kernel_task.stack);
+	lib_free(task);
+}
+void *lib_task_get_private(struct SimTask *task)
+{
+	return task->private;
+}
+
+int kernel_thread(int (*fn)(void *), void *arg, unsigned long flags)
+{
+	struct SimTask *task = lib_task_start((void (*)(void *))fn, arg);
+
+	return task->kernel_task.pid;
+}
+
+struct task_struct *get_current(void)
+{
+	struct SimTask *lib_task = lib_task_current();
+
+	return &lib_task->kernel_task;
+}
+
+struct thread_info *current_thread_info(void)
+{
+	return task_thread_info(get_current());
+}
+struct thread_info *alloc_thread_info(struct task_struct *task)
+{
+	return lib_malloc(sizeof(struct thread_info));
+}
+void free_thread_info(struct thread_info *ti)
+{
+	lib_free(ti);
+}
+
+
+void __put_task_struct(struct task_struct *t)
+{
+	lib_free(t);
+}
+
+void add_wait_queue(wait_queue_head_t *q, wait_queue_t *wait)
+{
+	wait->flags &= ~WQ_FLAG_EXCLUSIVE;
+	list_add(&wait->task_list, &q->task_list);
+}
+void add_wait_queue_exclusive(wait_queue_head_t *q, wait_queue_t *wait)
+{
+	wait->flags |= WQ_FLAG_EXCLUSIVE;
+	list_add_tail(&wait->task_list, &q->task_list);
+}
+void remove_wait_queue(wait_queue_head_t *q, wait_queue_t *wait)
+{
+	if (wait->task_list.prev != LIST_POISON2)
+		list_del(&wait->task_list);
+}
+void
+prepare_to_wait_exclusive(wait_queue_head_t *q, wait_queue_t *wait, int state)
+{
+	wait->flags |= WQ_FLAG_EXCLUSIVE;
+	if (list_empty(&wait->task_list))
+		list_add_tail(&wait->task_list, &q->task_list);
+	set_current_state(state);
+}
+void prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait, int state)
+{
+	unsigned long flags;
+
+	wait->flags &= ~WQ_FLAG_EXCLUSIVE;
+	spin_lock_irqsave(&q->lock, flags);
+	if (list_empty(&wait->task_list))
+		__add_wait_queue(q, wait);
+	set_current_state(state);
+	spin_unlock_irqrestore(&q->lock, flags);
+}
+void finish_wait(wait_queue_head_t *q, wait_queue_t *wait)
+{
+	set_current_state(TASK_RUNNING);
+	if (!list_empty(&wait->task_list))
+		list_del_init(&wait->task_list);
+}
+int autoremove_wake_function(wait_queue_t *wait, unsigned mode, int sync,
+			     void *key)
+{
+	int ret = default_wake_function(wait, mode, sync, key);
+
+	if (ret && (wait->task_list.prev != LIST_POISON2))
+		list_del_init(&wait->task_list);
+
+	return ret;
+}
+
+int woken_wake_function(wait_queue_t *wait, unsigned mode, int sync, void *key)
+{
+	wait->flags |= WQ_FLAG_WOKEN;
+	return default_wake_function(wait, mode, sync, key);
+}
+
+void __init_waitqueue_head(wait_queue_head_t *q, const char *name,
+			   struct lock_class_key *k)
+{
+	INIT_LIST_HEAD(&q->task_list);
+}
+/**
+ * wait_for_completion: - waits for completion of a task
+ * @x:  holds the state of this particular completion
+ *
+ * This waits to be signaled for completion of a specific task. It is NOT
+ * interruptible and there is no timeout.
+ *
+ * See also similar routines (i.e. wait_for_completion_timeout()) with timeout
+ * and interrupt capability. Also see complete().
+ */
+void wait_for_completion(struct completion *x)
+{
+	wait_for_completion_timeout(x, MAX_SCHEDULE_TIMEOUT);
+}
+unsigned long wait_for_completion_timeout(struct completion *x,
+					  unsigned long timeout)
+{
+	if (!x->done) {
+		DECLARE_WAITQUEUE(wait, current);
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		wait.flags |= WQ_FLAG_EXCLUSIVE;
+		list_add_tail(&wait.task_list, &x->wait.task_list);
+		do
+			timeout = schedule_timeout(timeout);
+		while (!x->done && timeout);
+		if (wait.task_list.prev != LIST_POISON2)
+			list_del(&wait.task_list);
+
+		if (!x->done)
+			return timeout;
+	}
+	x->done--;
+	return timeout ? : 1;
+}
+
+/**
+ * __wake_up - wake up threads blocked on a waitqueue.
+ * @q: the waitqueue
+ * @mode: which threads
+ * @nr_exclusive: how many wake-one or wake-many threads to wake up
+ * @key: is directly passed to the wakeup function
+ *
+ * It may be assumed that this function implies a write memory barrier before
+ * changing the task state if and only if any tasks are woken up.
+ */
+void __wake_up(wait_queue_head_t *q, unsigned int mode,
+	       int nr_exclusive, void *key)
+{
+	wait_queue_t *curr, *next;
+
+	list_for_each_entry_safe(curr, next, &q->task_list, task_list) {
+		unsigned flags = curr->flags;
+
+		if (curr->func(curr, mode, 0, key) &&
+		    (flags & WQ_FLAG_EXCLUSIVE) &&
+		    !--nr_exclusive)
+			break;
+	}
+}
+void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode,
+			int nr_exclusive, void *key)
+{
+	__wake_up(q, mode, nr_exclusive, key);
+}
+int default_wake_function(wait_queue_t *curr, unsigned mode, int wake_flags,
+			  void *key)
+{
+	struct task_struct *task = (struct task_struct *)curr->private;
+	struct SimTask *lib_task = container_of(task, struct SimTask,
+						kernel_task);
+
+	return lib_task_wakeup(lib_task);
+}
+__sched int bit_wait(struct wait_bit_key *word)
+{
+	if (signal_pending_state(current->state, current))
+		return 1;
+	schedule();
+	return 0;
+}
+int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *arg)
+{
+	struct wait_bit_key *key = arg;
+	struct wait_bit_queue *wait_bit
+		= container_of(wait, struct wait_bit_queue, wait);
+
+	if (wait_bit->key.flags != key->flags ||
+			wait_bit->key.bit_nr != key->bit_nr ||
+			test_bit(key->bit_nr, key->flags))
+		return 0;
+	else
+		return autoremove_wake_function(wait, mode, sync, key);
+}
+void __wake_up_bit(wait_queue_head_t *wq, void *word, int bit)
+{
+	struct wait_bit_key key = __WAIT_BIT_KEY_INITIALIZER(word, bit);
+	if (waitqueue_active(wq))
+		__wake_up(wq, TASK_NORMAL, 1, &key);
+}
+void wake_up_bit(void *word, int bit)
+{
+	/* FIXME */
+	return;
+	__wake_up_bit(bit_waitqueue(word, bit), word, bit);
+}
+wait_queue_head_t *bit_waitqueue(void *word, int bit)
+{
+	const int shift = BITS_PER_LONG == 32 ? 5 : 6;
+	const struct zone *zone = page_zone(virt_to_page(word));
+	unsigned long val = (unsigned long)word << shift | bit;
+
+	return &zone->wait_table[hash_long(val, zone->wait_table_bits)];
+}
+
+
+void schedule(void)
+{
+	lib_task_wait();
+}
+
+static void trampoline(void *context)
+{
+	struct SimTask *task = context;
+
+	lib_task_wakeup(task);
+}
+
+signed long schedule_timeout(signed long timeout)
+{
+	u64 ns;
+	struct SimTask *self;
+
+	if (timeout == MAX_SCHEDULE_TIMEOUT) {
+		lib_task_wait();
+		return MAX_SCHEDULE_TIMEOUT;
+	}
+	lib_assert(timeout >= 0);
+	ns = ((__u64)timeout) * (1000000000 / HZ);
+	self = lib_task_current();
+	lib_event_schedule_ns(ns, &trampoline, self);
+	lib_task_wait();
+	/* we know that we are always perfectly on time. */
+	return 0;
+}
+
+signed long schedule_timeout_uninterruptible(signed long timeout)
+{
+	return schedule_timeout(timeout);
+}
+signed long schedule_timeout_interruptible(signed long timeout)
+{
+	return schedule_timeout(timeout);
+}
+
+void yield(void)
+{
+	lib_task_yield();
+}
+
+void complete_all(struct completion *x)
+{
+	x->done += UINT_MAX / 2;
+	__wake_up(&x->wait, TASK_NORMAL, 0, 0);
+}
+void complete(struct completion *x)
+{
+	x->done++;
+	__wake_up(&x->wait, TASK_NORMAL, 1, 0);
+}
+
+long wait_for_completion_interruptible_timeout(
+	struct completion *x, unsigned long timeout)
+{
+	return wait_for_completion_timeout(x, timeout);
+}
+int wait_for_completion_interruptible(struct completion *x)
+{
+	wait_for_completion_timeout(x, MAX_SCHEDULE_TIMEOUT);
+	return 0;
+}
+int wake_up_process(struct task_struct *tsk)
+{
+	struct SimTask *lib_task =
+		container_of(tsk, struct SimTask, kernel_task);
+
+	return lib_task_wakeup(lib_task);
+}
+int _cond_resched(void)
+{
+	/* we never schedule to decrease latency. */
+	return 0;
+}
+int idle_cpu(int cpu)
+{
+	/* we are never idle: we call this from rcutiny.c and the answer */
+	/* does not matter, really. */
+	return 0;
+}
+
+unsigned long long __attribute__((weak)) sched_clock(void)
+{
+	return (unsigned long long)(jiffies - INITIAL_JIFFIES)
+	       * (NSEC_PER_SEC / HZ);
+}
+
+u64 local_clock(void)
+{
+	return sched_clock();
+}
+
+void __sched schedule_preempt_disabled(void)
+{
+}
+
+void resched_cpu(int cpu)
+{
+	rcu_sched_qs();
+}
diff --git a/arch/lib/softirq.c b/arch/lib/softirq.c
new file mode 100644
index 0000000..3f6363a
--- /dev/null
+++ b/arch/lib/softirq.c
@@ -0,0 +1,108 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/interrupt.h>
+#include "sim-init.h"
+#include "sim.h"
+#include "sim-assert.h"
+
+
+static struct softirq_action softirq_vec[NR_SOFTIRQS];
+static struct SimTask *g_softirq_task = 0;
+static int g_n_raises = 0;
+
+void lib_softirq_wakeup(void)
+{
+	g_n_raises++;
+	lib_task_wakeup(g_softirq_task);
+}
+
+static void softirq_task_function(void *context)
+{
+	while (true) {
+		do_softirq();
+		g_n_raises--;
+		if (g_n_raises == 0 || local_softirq_pending() == 0) {
+			g_n_raises = 0;
+			lib_task_wait();
+		}
+	}
+}
+
+static void ensure_task_created(void)
+{
+	if (g_softirq_task != 0)
+		return;
+	g_softirq_task = lib_task_start(&softirq_task_function, 0);
+}
+
+void open_softirq(int nr, void (*action)(struct softirq_action *))
+{
+	ensure_task_created();
+	softirq_vec[nr].action = action;
+}
+#define MAX_SOFTIRQ_RESTART 10
+
+void do_softirq(void)
+{
+	__u32 pending;
+	int max_restart = MAX_SOFTIRQ_RESTART;
+	struct softirq_action *h;
+
+	pending = local_softirq_pending();
+
+restart:
+	/* Reset the pending bitmask before enabling irqs */
+	set_softirq_pending(0);
+
+	local_irq_enable();
+
+	h = softirq_vec;
+
+	do {
+		if (pending & 1)
+			h->action(h);
+		h++;
+		pending >>= 1;
+	} while (pending);
+
+	local_irq_disable();
+
+	pending = local_softirq_pending();
+	if (pending && --max_restart)
+		goto restart;
+}
+void raise_softirq_irqoff(unsigned int nr)
+{
+	__raise_softirq_irqoff(nr);
+
+	lib_softirq_wakeup();
+}
+void __raise_softirq_irqoff(unsigned int nr)
+{
+	/* trace_softirq_raise(nr); */
+	or_softirq_pending(1UL << nr);
+}
+int __cond_resched_softirq(void)
+{
+	/* tell the caller that we did not need to re-schedule. */
+	return 0;
+}
+void raise_softirq(unsigned int nr)
+{
+	/* copy/paste from kernel/softirq.c */
+	unsigned long flags;
+
+	local_irq_save(flags);
+	raise_softirq_irqoff(nr);
+	local_irq_restore(flags);
+}
+
+void __local_bh_enable_ip(unsigned long ip, unsigned int cnt)
+{
+}
diff --git a/arch/lib/tasklet.c b/arch/lib/tasklet.c
new file mode 100644
index 0000000..6cc68f4
--- /dev/null
+++ b/arch/lib/tasklet.c
@@ -0,0 +1,76 @@
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
+void tasklet_init(struct tasklet_struct *t,
+		  void (*func)(unsigned long), unsigned long data)
+{
+	t->next = NULL;
+	t->state = 0;
+	atomic_set(&t->count, 0);
+	t->func = func;
+	t->data = data;
+}
+
+void tasklet_kill(struct tasklet_struct *t)
+{
+	/* theoretically, called from user context */
+	while (test_and_set_bit(TASKLET_STATE_SCHED, &t->state)) {
+		do
+			lib_task_yield();
+		while (test_bit(TASKLET_STATE_SCHED, &t->state));
+	}
+	clear_bit(TASKLET_STATE_SCHED, &t->state);
+}
+struct tasklet_struct *g_sched_events = NULL;
+static void run_tasklet_softirq(struct softirq_action *h)
+{
+	/* while (!list_empty (&g_sched_events)) */
+	/*   { */
+	struct tasklet_struct *tasklet = g_sched_events;
+
+	if (atomic_read(&tasklet->count) == 0) {
+		/* this tasklet is enabled so, we run it. */
+		test_and_clear_bit(TASKLET_STATE_SCHED, &tasklet->state);
+		tasklet->func(tasklet->data);
+	}
+	/* } */
+}
+static void ensure_softirq_opened(void)
+{
+	static bool opened = false;
+
+	if (opened)
+		return;
+	opened = true;
+	open_softirq(TASKLET_SOFTIRQ, run_tasklet_softirq);
+}
+static void trampoline(void *context)
+{
+	ensure_softirq_opened();
+	struct tasklet_struct *tasklet = context;
+	/* allow the tasklet to re-schedule itself */
+	lib_assert(tasklet->next != 0);
+	tasklet->next = 0;
+	g_sched_events = tasklet;
+	raise_softirq(TASKLET_SOFTIRQ);
+}
+void __tasklet_schedule(struct tasklet_struct *t)
+{
+	void *event;
+
+	/* Note: no need to set TASKLET_STATE_SCHED because
+	   it is set by caller. */
+	lib_assert(t->next == 0);
+	/* run the tasklet at the next immediately available opportunity. */
+	event = lib_event_schedule_ns(0, &trampoline, t);
+	t->next = event;
+}
diff --git a/arch/lib/workqueue.c b/arch/lib/workqueue.c
new file mode 100644
index 0000000..bd0e9c5
--- /dev/null
+++ b/arch/lib/workqueue.c
@@ -0,0 +1,242 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/workqueue.h>
+#include <linux/slab.h>
+#include "sim.h"
+#include "sim-assert.h"
+
+/* copy from kernel/workqueue.c */
+typedef unsigned long mayday_mask_t;
+struct workqueue_struct {
+	unsigned int flags;                     /* W: WQ_* flags */
+	union {
+		struct cpu_workqueue_struct __percpu *pcpu;
+		struct cpu_workqueue_struct *single;
+		unsigned long v;
+	} cpu_wq;                               /* I: cwq's */
+	struct list_head list;                  /* W: list of all workqueues */
+
+	struct mutex flush_mutex;               /* protects wq flushing */
+	int work_color;                         /* F: current work color */
+	int flush_color;                        /* F: current flush color */
+	atomic_t nr_cwqs_to_flush;              /* flush in progress */
+	struct wq_flusher *first_flusher;       /* F: first flusher */
+	struct list_head flusher_queue;         /* F: flush waiters */
+	struct list_head flusher_overflow;      /* F: flush overflow list */
+
+	mayday_mask_t mayday_mask;              /* cpus requesting rescue */
+	struct worker *rescuer;                 /* I: rescue worker */
+
+	int nr_drainers;                        /* W: drain in progress */
+	int saved_max_active;                   /* W: saved cwq max_active */
+#ifdef CONFIG_LOCKDEP
+	struct lockdep_map lockdep_map;
+#endif
+	char name[];                            /* I: workqueue name */
+};
+
+struct wq_barrier {
+	struct SimTask *waiter;
+	struct workqueue_struct wq;
+};
+
+static void
+workqueue_function(void *context)
+{
+	struct workqueue_struct *wq = context;
+
+	while (true) {
+		lib_task_wait();
+		while (!list_empty(&wq->list)) {
+			struct work_struct *work =
+				list_first_entry(&wq->list, struct work_struct,
+						entry);
+			work_func_t f = work->func;
+
+			if (work->entry.prev != LIST_POISON2) {
+				list_del_init(&work->entry);
+				clear_bit(WORK_STRUCT_PENDING_BIT,
+					  work_data_bits(work));
+				f(work);
+			}
+		}
+	}
+}
+
+static struct SimTask *workqueue_task(struct workqueue_struct *wq)
+{
+	struct wq_barrier *barr = container_of(wq, struct wq_barrier, wq);
+
+	if (barr->waiter == 0)
+		barr->waiter = lib_task_start(&workqueue_function, wq);
+	return barr->waiter;
+}
+
+static int flush_entry(struct workqueue_struct *wq, struct list_head *prev)
+{
+	int active = 0;
+
+	if (!list_empty(&wq->list)) {
+		active = 1;
+		lib_task_wakeup(workqueue_task(wq));
+		/* XXX: should wait for completion? but this will block
+		   and init won't return.. */
+		/* lib_task_wait (); */
+	}
+
+	return active;
+}
+
+void delayed_work_timer_fn(unsigned long data)
+{
+	struct delayed_work *dwork = (struct delayed_work *)data;
+	struct work_struct *work = &dwork->work;
+
+	list_add_tail(&work->entry, &dwork->wq->list);
+	lib_task_wakeup(workqueue_task(dwork->wq));
+}
+
+bool queue_work_on(int cpu, struct workqueue_struct *wq,
+		   struct work_struct *work)
+{
+	int ret = 0;
+
+	if (!test_and_set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(work))) {
+		list_add_tail(&work->entry, &wq->list);
+		lib_task_wakeup(workqueue_task(wq));
+		ret = 1;
+	}
+	return ret;
+}
+
+void flush_scheduled_work(void)
+{
+	flush_entry(system_wq, system_wq->list.prev);
+}
+bool flush_work(struct work_struct *work)
+{
+	return flush_entry(system_wq, &work->entry);
+}
+void flush_workqueue(struct workqueue_struct *wq)
+{
+	flush_entry(wq, wq->list.prev);
+}
+bool cancel_work_sync(struct work_struct *work)
+{
+	int retval = 0;
+
+	if (!test_and_set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(work)))
+		/* work was not yet queued */
+		return 0;
+	if (!list_empty(&work->entry)) {
+		/* work was queued. now unqueued. */
+		if (work->entry.prev != LIST_POISON2) {
+			list_del_init(&work->entry);
+			clear_bit(WORK_STRUCT_PENDING_BIT,
+				  work_data_bits(work));
+			retval = 1;
+		}
+	}
+	return retval;
+}
+bool queue_delayed_work_on(int cpu, struct workqueue_struct *wq,
+			   struct delayed_work *dwork, unsigned long delay)
+{
+	int ret = 0;
+	struct timer_list *timer = &dwork->timer;
+	struct work_struct *work = &dwork->work;
+
+	if (delay == 0)
+		return queue_work(wq, work);
+
+	if (!test_and_set_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(work))) {
+		lib_assert(!timer_pending(timer));
+		dwork->wq = wq;
+		/* This stores cwq for the moment, for the timer_fn */
+		timer->expires = jiffies + delay;
+		timer->data = (unsigned long)dwork;
+		timer->function = delayed_work_timer_fn;
+		add_timer(timer);
+		ret = 1;
+	}
+	return ret;
+}
+bool mod_delayed_work_on(int cpu, struct workqueue_struct *wq,
+			 struct delayed_work *dwork, unsigned long delay)
+{
+	del_timer(&dwork->timer);
+	__clear_bit(WORK_STRUCT_PENDING_BIT, work_data_bits(&dwork->work));
+	return queue_delayed_work(wq, dwork, delay);
+}
+bool cancel_delayed_work(struct delayed_work *dwork)
+{
+	del_timer(&dwork->timer);
+	return cancel_work_sync(&dwork->work);
+}
+
+struct workqueue_struct *__alloc_workqueue_key(const char *fmt,
+					       unsigned int flags,
+					       int max_active,
+					       struct lock_class_key *key,
+					       const char *lock_name, ...)
+{
+	va_list args, args1;
+	struct wq_barrier *barr;
+	struct workqueue_struct *wq;
+	size_t namelen;
+
+	/* determine namelen, allocate wq and format name */
+	va_start(args, lock_name);
+	va_copy(args1, args);
+	namelen = vsnprintf(NULL, 0, fmt, args) + 1;
+
+	barr = kzalloc(sizeof(*barr) + namelen, GFP_KERNEL);
+	if (!barr)
+		goto err;
+	barr->waiter = 0;
+	wq = &barr->wq;
+
+	vsnprintf(wq->name, namelen, fmt, args1);
+	va_end(args);
+	va_end(args1);
+
+	max_active = max_active ? : WQ_DFL_ACTIVE;
+	/* init wq */
+	wq->flags = flags;
+	wq->saved_max_active = max_active;
+	mutex_init(&wq->flush_mutex);
+	atomic_set(&wq->nr_cwqs_to_flush, 0);
+	INIT_LIST_HEAD(&wq->flusher_queue);
+	INIT_LIST_HEAD(&wq->flusher_overflow);
+
+	lockdep_init_map(&wq->lockdep_map, lock_name, key, 0);
+	INIT_LIST_HEAD(&wq->list);
+
+	/* start waiter task */
+	workqueue_task(wq);
+	return wq;
+err:
+	if (barr)
+		kfree(barr);
+	return NULL;
+}
+
+struct workqueue_struct *system_wq __read_mostly;
+struct workqueue_struct *system_power_efficient_wq __read_mostly;
+/* from linux/workqueue.h */
+#define system_nrt_wq                   __system_nrt_wq()
+
+static int __init init_workqueues(void)
+{
+	system_wq = alloc_workqueue("events", 0, 0);
+	system_power_efficient_wq = alloc_workqueue("events_power_efficient",
+						    WQ_POWER_EFFICIENT, 0);
+	return 0;
+}
+early_initcall(init_workqueues);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
