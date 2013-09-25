Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 58F5E6B009F
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:26:19 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so308579pbc.23
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:26:19 -0700 (PDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 09:26:09 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 9E4CD2BB0056
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:26:05 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PN9PA47143766
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:09:25 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8PNQ4Ow019609
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:26:04 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 36/40] kthread: Split out kthread-worker bits to avoid
 circular header-file dependency
Date: Thu, 26 Sep 2013 04:51:54 +0530
Message-ID: <20130925232149.26184.76968.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In subsequent patches, we will want to declare variables of kthread-work and
kthread-worker structures within mmzone.h. But trying to include kthread.h
inside mmzone.h to get the structure definitions, will lead to the following
circular header-file dependency.

     mmzone.h -> kthread.h -> sched.h -> gfp.h -> mmzone.h

We can avoid this by not including sched.h in kthread.h. But sched.h is quite
handy for call-sites which use the core kthread start/stop infrastructure such
as kthread-create-on-cpu/node etc. However, the kthread-work/worker framework
doesn't actually depend on sched.h.

So extract the definitions related to kthread-work/worker from kthread.h into
a new header-file named kthread-work.h (which doesn't include sched.h), so that
it can be easily included inside mmzone.h when required.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/kthread-work.h |   92 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/kthread.h      |   85 ---------------------------------------
 2 files changed, 93 insertions(+), 84 deletions(-)
 create mode 100644 include/linux/kthread-work.h

diff --git a/include/linux/kthread-work.h b/include/linux/kthread-work.h
new file mode 100644
index 0000000..6dae2ab
--- /dev/null
+++ b/include/linux/kthread-work.h
@@ -0,0 +1,92 @@
+#ifndef _LINUX_KTHREAD_WORK_H
+#define _LINUX_KTHREAD_WORK_H
+#include <linux/err.h>
+
+__printf(4, 5)
+
+/*
+ * Simple work processor based on kthread.
+ *
+ * This provides easier way to make use of kthreads.  A kthread_work
+ * can be queued and flushed using queue/flush_kthread_work()
+ * respectively.  Queued kthread_works are processed by a kthread
+ * running kthread_worker_fn().
+ */
+struct kthread_work;
+typedef void (*kthread_work_func_t)(struct kthread_work *work);
+
+struct kthread_worker {
+	spinlock_t		lock;
+	struct list_head	work_list;
+	struct task_struct	*task;
+	struct kthread_work	*current_work;
+};
+
+struct kthread_work {
+	struct list_head	node;
+	kthread_work_func_t	func;
+	wait_queue_head_t	done;
+	struct kthread_worker	*worker;
+};
+
+#define KTHREAD_WORKER_INIT(worker)	{				\
+	.lock = __SPIN_LOCK_UNLOCKED((worker).lock),			\
+	.work_list = LIST_HEAD_INIT((worker).work_list),		\
+	}
+
+#define KTHREAD_WORK_INIT(work, fn)	{				\
+	.node = LIST_HEAD_INIT((work).node),				\
+	.func = (fn),							\
+	.done = __WAIT_QUEUE_HEAD_INITIALIZER((work).done),		\
+	}
+
+#define DEFINE_KTHREAD_WORKER(worker)					\
+	struct kthread_worker worker = KTHREAD_WORKER_INIT(worker)
+
+#define DEFINE_KTHREAD_WORK(work, fn)					\
+	struct kthread_work work = KTHREAD_WORK_INIT(work, fn)
+
+/*
+ * kthread_worker.lock and kthread_work.done need their own lockdep class
+ * keys if they are defined on stack with lockdep enabled.  Use the
+ * following macros when defining them on stack.
+ */
+#ifdef CONFIG_LOCKDEP
+# define KTHREAD_WORKER_INIT_ONSTACK(worker)				\
+	({ init_kthread_worker(&worker); worker; })
+# define DEFINE_KTHREAD_WORKER_ONSTACK(worker)				\
+	struct kthread_worker worker = KTHREAD_WORKER_INIT_ONSTACK(worker)
+# define KTHREAD_WORK_INIT_ONSTACK(work, fn)				\
+	({ init_kthread_work((&work), fn); work; })
+# define DEFINE_KTHREAD_WORK_ONSTACK(work, fn)				\
+	struct kthread_work work = KTHREAD_WORK_INIT_ONSTACK(work, fn)
+#else
+# define DEFINE_KTHREAD_WORKER_ONSTACK(worker) DEFINE_KTHREAD_WORKER(worker)
+# define DEFINE_KTHREAD_WORK_ONSTACK(work, fn) DEFINE_KTHREAD_WORK(work, fn)
+#endif
+
+extern void __init_kthread_worker(struct kthread_worker *worker,
+			const char *name, struct lock_class_key *key);
+
+#define init_kthread_worker(worker)					\
+	do {								\
+		static struct lock_class_key __key;			\
+		__init_kthread_worker((worker), "("#worker")->lock", &__key); \
+	} while (0)
+
+#define init_kthread_work(work, fn)					\
+	do {								\
+		memset((work), 0, sizeof(struct kthread_work));		\
+		INIT_LIST_HEAD(&(work)->node);				\
+		(work)->func = (fn);					\
+		init_waitqueue_head(&(work)->done);			\
+	} while (0)
+
+int kthread_worker_fn(void *worker_ptr);
+
+bool queue_kthread_work(struct kthread_worker *worker,
+			struct kthread_work *work);
+void flush_kthread_work(struct kthread_work *work);
+void flush_kthread_worker(struct kthread_worker *worker);
+
+#endif /* _LINUX_KTHREAD_WORK_H */
diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 7dcef33..cbefb16 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -52,89 +52,6 @@ int kthreadd(void *unused);
 extern struct task_struct *kthreadd_task;
 extern int tsk_fork_get_node(struct task_struct *tsk);
 
-/*
- * Simple work processor based on kthread.
- *
- * This provides easier way to make use of kthreads.  A kthread_work
- * can be queued and flushed using queue/flush_kthread_work()
- * respectively.  Queued kthread_works are processed by a kthread
- * running kthread_worker_fn().
- */
-struct kthread_work;
-typedef void (*kthread_work_func_t)(struct kthread_work *work);
-
-struct kthread_worker {
-	spinlock_t		lock;
-	struct list_head	work_list;
-	struct task_struct	*task;
-	struct kthread_work	*current_work;
-};
-
-struct kthread_work {
-	struct list_head	node;
-	kthread_work_func_t	func;
-	wait_queue_head_t	done;
-	struct kthread_worker	*worker;
-};
-
-#define KTHREAD_WORKER_INIT(worker)	{				\
-	.lock = __SPIN_LOCK_UNLOCKED((worker).lock),			\
-	.work_list = LIST_HEAD_INIT((worker).work_list),		\
-	}
-
-#define KTHREAD_WORK_INIT(work, fn)	{				\
-	.node = LIST_HEAD_INIT((work).node),				\
-	.func = (fn),							\
-	.done = __WAIT_QUEUE_HEAD_INITIALIZER((work).done),		\
-	}
-
-#define DEFINE_KTHREAD_WORKER(worker)					\
-	struct kthread_worker worker = KTHREAD_WORKER_INIT(worker)
-
-#define DEFINE_KTHREAD_WORK(work, fn)					\
-	struct kthread_work work = KTHREAD_WORK_INIT(work, fn)
-
-/*
- * kthread_worker.lock and kthread_work.done need their own lockdep class
- * keys if they are defined on stack with lockdep enabled.  Use the
- * following macros when defining them on stack.
- */
-#ifdef CONFIG_LOCKDEP
-# define KTHREAD_WORKER_INIT_ONSTACK(worker)				\
-	({ init_kthread_worker(&worker); worker; })
-# define DEFINE_KTHREAD_WORKER_ONSTACK(worker)				\
-	struct kthread_worker worker = KTHREAD_WORKER_INIT_ONSTACK(worker)
-# define KTHREAD_WORK_INIT_ONSTACK(work, fn)				\
-	({ init_kthread_work((&work), fn); work; })
-# define DEFINE_KTHREAD_WORK_ONSTACK(work, fn)				\
-	struct kthread_work work = KTHREAD_WORK_INIT_ONSTACK(work, fn)
-#else
-# define DEFINE_KTHREAD_WORKER_ONSTACK(worker) DEFINE_KTHREAD_WORKER(worker)
-# define DEFINE_KTHREAD_WORK_ONSTACK(work, fn) DEFINE_KTHREAD_WORK(work, fn)
-#endif
-
-extern void __init_kthread_worker(struct kthread_worker *worker,
-			const char *name, struct lock_class_key *key);
-
-#define init_kthread_worker(worker)					\
-	do {								\
-		static struct lock_class_key __key;			\
-		__init_kthread_worker((worker), "("#worker")->lock", &__key); \
-	} while (0)
-
-#define init_kthread_work(work, fn)					\
-	do {								\
-		memset((work), 0, sizeof(struct kthread_work));		\
-		INIT_LIST_HEAD(&(work)->node);				\
-		(work)->func = (fn);					\
-		init_waitqueue_head(&(work)->done);			\
-	} while (0)
-
-int kthread_worker_fn(void *worker_ptr);
-
-bool queue_kthread_work(struct kthread_worker *worker,
-			struct kthread_work *work);
-void flush_kthread_work(struct kthread_work *work);
-void flush_kthread_worker(struct kthread_worker *worker);
+#include <linux/kthread-work.h>
 
 #endif /* _LINUX_KTHREAD_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
