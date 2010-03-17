Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5985D6B021B
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:14:44 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 36/96] deferqueue: generic queue to defer work
Date: Wed, 17 Mar 2010 12:08:24 -0400
Message-Id: <1268842164-5590-37-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-36-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-36-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Add a interface to postpone an action until the end of the entire
checkpoint or restart operation. This is useful when during the
scan of tasks an operation cannot be performed in place, to avoid
the need for a second scan.

One use case is when restoring an ipc shared memory region that has
been deleted (but is still attached), during restart it needs to be
create, attached and then deleted. However, creation and attachment
are performed in distinct locations, so deletion can not be performed
on the spot. Instead, this work (delete) is deferred until later.
(This example is in one of the following patches).

This interface allows chronic procrastination in the kernel:

deferqueue_create(void):
    Allocates and returns a new deferqueue.

deferqueue_run(deferqueue):
    Executes all the pending works in the queue. Returns the number
    of works executed, or an error upon the first error reported by
    a deferred work.

deferqueue_add(deferqueue, data, size, func, dtor):
    Enqueue a deferred work. @function is the callback function to
    do the work, which will be called with @data as an argument.
    @size tells the size of data. @dtor is a destructor callback
    that is invoked for deferred works remaining in the queue when
    the queue is destroyed. NOTE: for a given deferred work, @dtor
    is _not_ called if @func was already called (regardless of the
    return value of the latter).

deferqueue_destroy(deferqueue):
    Free the deferqueue and any queued items while invoking the
    @dtor callback for each queued item.

Why aren't we using the existing kernel workqueue mechanism?  We need
to defer to work until the end of the operation: not earlier, since we
need other things to be in place; not later, to not block waiting for
it. However, the workqueue schedules the work for 'some time later'.
Also, the kernel workqueue may run in any task context, but we require
many times that an operation be run in the context of some specific
restarting task (e.g., restoring IPC state of a certain ipc_ns).

Instead, this mechanism is a simple way for the c/r operation as a
whole, and later a task in particular, to defer some action until
later (but not arbitrarily later) _in the restore_ operation.

Changelog[v19-rc1]
  - [Matt Helsley] Check for valid destructor before calling it
Changelog[v18]
  - Interface to pass simple pointers as data with deferqueue
Changelog[v17]
  - Fix deferqueue_add() function

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/Kconfig         |    5 ++
 include/linux/deferqueue.h |   78 +++++++++++++++++++++++++++++++
 kernel/Makefile            |    1 +
 kernel/deferqueue.c        |  110 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 194 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/deferqueue.h
 create mode 100644 kernel/deferqueue.c

diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
index 21fc86b..4a2c845 100644
--- a/checkpoint/Kconfig
+++ b/checkpoint/Kconfig
@@ -2,10 +2,15 @@
 # implemented the hooks for processor state etc. needed by the
 # core checkpoint/restart code.
 
+config DEFERQUEUE
+	bool
+	default n
+
 config CHECKPOINT
 	bool "Checkpoint/restart (EXPERIMENTAL)"
 	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
 	depends on CGROUP_FREEZER
+	select DEFERQUEUE
 	help
 	  Application checkpoint/restart is the ability to save the
 	  state of a running application so that it can later resume
diff --git a/include/linux/deferqueue.h b/include/linux/deferqueue.h
new file mode 100644
index 0000000..ea3b620
--- /dev/null
+++ b/include/linux/deferqueue.h
@@ -0,0 +1,78 @@
+/*
+ * deferqueue.h --- deferred work queue handling for Linux.
+ */
+
+#ifndef _LINUX_DEFERQUEUE_H
+#define _LINUX_DEFERQUEUE_H
+
+#include <linux/list.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+
+/*
+ * This interface allows chronic procrastination in the kernel:
+ *
+ * deferqueue_create(void):
+ *     Allocates and returns a new deferqueue.
+ *
+ * deferqueue_run(deferqueue):
+ *     Executes all the pending works in the queue. Returns the number
+ *     of works executed, or an error upon the first error reported by
+ *     a deferred work.
+ *
+ * deferqueue_add(deferqueue, data, size, func, dtor):
+ * 	Enqueue a deferred work. @function is the callback function to
+ *      do the work, which will be called with @data as an argument.
+ *      @size tells the size of data. @dtor is a destructor callback
+ *      that is invoked for deferred works remaining in the queue when
+ *      the queue is destroyed. NOTE: for a given deferred work, @dtor
+ *      is _not_ called if @func was already called (regardless of the
+ *      return value of the latter).
+ *
+ * deferqueue_destroy(deferqueue):
+ *      Free the deferqueue and any queued items while invoking the
+ *      @dtor callback for each queued item.
+ *
+ * The following helpers are useful when @data is a simple pointer:
+ *
+ * deferqueue_add_ptr(deferqueue, ptr, func, dtor):
+ *	Enqueue a deferred work whos data is @ptr.
+ *
+ * deferqueue_data_ptr(data):
+ *	Convert a deferqueue @data to a void * pointer.
+ */
+
+
+typedef int (*deferqueue_func_t)(void *);
+
+struct deferqueue_entry {
+	deferqueue_func_t function;
+	deferqueue_func_t destructor;
+	struct list_head list;
+	char data[0];
+};
+
+struct deferqueue_head {
+	spinlock_t lock;
+	struct list_head list;
+};
+
+struct deferqueue_head *deferqueue_create(void);
+void deferqueue_destroy(struct deferqueue_head *head);
+int deferqueue_add(struct deferqueue_head *head, void *data, int size,
+		   deferqueue_func_t func, deferqueue_func_t dtor);
+int deferqueue_run(struct deferqueue_head *head);
+
+static inline int deferqueue_add_ptr(struct deferqueue_head *head, void *ptr,
+				     deferqueue_func_t func,
+				     deferqueue_func_t dtor)
+{
+	return deferqueue_add(head, &ptr, sizeof(ptr), func, dtor);
+}
+
+static inline void *deferqueue_data_ptr(void *data)
+{
+	return *((void **) data);
+}
+
+#endif
diff --git a/kernel/Makefile b/kernel/Makefile
index 864ff75..3c2c303 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -24,6 +24,7 @@ CFLAGS_REMOVE_sched_clock.o = -pg
 CFLAGS_REMOVE_perf_event.o = -pg
 endif
 
+obj-$(CONFIG_DEFERQUEUE) += deferqueue.o
 obj-$(CONFIG_FREEZER) += freezer.o
 obj-$(CONFIG_PROFILING) += profile.o
 obj-$(CONFIG_SYSCTL_SYSCALL_CHECK) += sysctl_check.o
diff --git a/kernel/deferqueue.c b/kernel/deferqueue.c
new file mode 100644
index 0000000..1204c8b
--- /dev/null
+++ b/kernel/deferqueue.c
@@ -0,0 +1,110 @@
+/*
+ *  Infrastructure to manage deferred work
+ *
+ *  This differs from a workqueue in that the work must be deferred
+ *  until specifically run by the caller.
+ *
+ *  As the only user currently is checkpoint/restart, which has
+ *  very simple usage, the locking is kept simple.  Adding rules
+ *  is protected by the head->lock.  But deferqueue_run() is only
+ *  called once, after all entries have been added.  So it is not
+ *  protected.  Similarly, _destroy is only called once when the
+ *  ckpt_ctx is releeased, so it is not locked or refcounted.  These
+ *  can of course be added if needed by other users.
+ *
+ *  Why not use workqueue ?  We need to defer work until the end of an
+ *  operation: not earlier, since we need other things to be in place;
+ *  not later, to not block waiting for it. However, the workqueue
+ *  schedules the work for 'some time later'. Also, workqueue may run
+ *  in any task context, but we require many times that an operation
+ *  be run in the context of some specific restarting task (e.g.,
+ *  restoring IPC state of a certain ipc_ns).
+ *
+ *  Instead, this mechanism is a simple way for the c/r operation as a
+ *  whole, and later a task in particular, to defer some action until
+ *  later (but not arbitrarily later) _in the restore_ operation.
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/deferqueue.h>
+
+struct deferqueue_head *deferqueue_create(void)
+{
+	struct deferqueue_head *h = kmalloc(sizeof(*h), GFP_KERNEL);
+	if (h) {
+		spin_lock_init(&h->lock);
+		INIT_LIST_HEAD(&h->list);
+	}
+	return h;
+}
+
+void deferqueue_destroy(struct deferqueue_head *h)
+{
+	if (!list_empty(&h->list)) {
+		struct deferqueue_entry *dq, *n;
+
+		pr_debug("%s: freeing non-empty queue\n", __func__);
+		list_for_each_entry_safe(dq, n, &h->list, list) {
+			if (dq->destructor)
+				dq->destructor(dq->data);
+			list_del(&dq->list);
+			kfree(dq);
+		}
+	}
+	kfree(h);
+}
+
+int deferqueue_add(struct deferqueue_head *head, void *data, int size,
+		   deferqueue_func_t func, deferqueue_func_t dtor)
+{
+	struct deferqueue_entry *dq;
+
+	dq = kmalloc(sizeof(*dq) + size, GFP_KERNEL);
+	if (!dq)
+		return -ENOMEM;
+
+	dq->function = func;
+	dq->destructor = dtor;
+	memcpy(dq->data, data, size);
+
+	pr_debug("%s: adding work %p func %p dtor %p\n",
+		 __func__, dq, func, dtor);
+	spin_lock(&head->lock);
+	list_add_tail(&dq->list, &head->list);
+	spin_unlock(&head->lock);
+	return 0;
+}
+
+/*
+ * deferqueue_run - perform all work in the work queue
+ * @head: deferqueue_head from which to run
+ *
+ * returns: number of works performed, or < 0 on error
+ */
+int deferqueue_run(struct deferqueue_head *head)
+{
+	struct deferqueue_entry *dq, *n;
+	int nr = 0;
+	int ret;
+
+	list_for_each_entry_safe(dq, n, &head->list, list) {
+		pr_debug("doing work %p function %p\n", dq, dq->function);
+		/* don't call destructor - function callback should do it */
+		ret = dq->function(dq->data);
+		if (ret < 0)
+			pr_debug("wq function failed %d\n", ret);
+		list_del(&dq->list);
+		kfree(dq);
+		nr++;
+	}
+
+	return nr;
+}
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
