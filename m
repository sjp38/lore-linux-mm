Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51EE2828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 11:15:51 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id d19so48866984lfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 08:15:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ey1si45794797wjd.157.2016.04.14.08.15.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Apr 2016 08:15:50 -0700 (PDT)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v6 18/20] memstick/r592: convert r592_io kthread into kthread worker API
Date: Thu, 14 Apr 2016 17:14:37 +0200
Message-Id: <1460646879-617-19-git-send-email-pmladek@suse.com>
In-Reply-To: <1460646879-617-1-git-send-email-pmladek@suse.com>
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>, Maxim Levitsky <maximlevitsky@gmail.com>

Kthreads are currently implemented as an infinite loop. Each
has its own variant of checks for terminating, freezing,
awakening. In many cases it is unclear to say in which state
it is and sometimes it is done a wrong way.

The plan is to convert kthreads into kthread_worker or workqueues
API. It allows to split the functionality into separate operations.
It helps to make a better structure. Also it defines a clean state
where no locks are taken, IRQs blocked, the kthread might sleep
or even be safely migrated.

The kthread worker API is useful when we want to have a dedicated
single thread for the work. It helps to make sure that it is
available when needed. Also it allows a better control, e.g.
define a scheduling priority.

This patch converts the r592_io kthread into the kthread worker
API. I am not sure how busy the kthread is and if anyone would
like to control the resources. It is well possible that a workqueue
would be perfectly fine. Well, the conversion between kthread
worker API and workqueues is pretty trivial.

The patch moves one iteration from the kthread into the kthread
worker function. It helps to remove all the hackery with process
state and kthread_should_stop().

The work is queued instead of waking the thread.

The work is explicitly canceled before the worker is destroyed.
It is self-queuing and it might take a long time until the queue
is drained, otherwise.

Important: The change is only compile tested. I did not find an easy
way how to check it in use.

Signed-off-by: Petr Mladek <pmladek@suse.com>
CC: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/memstick/host/r592.c | 58 ++++++++++++++++++++------------------------
 drivers/memstick/host/r592.h |  3 ++-
 2 files changed, 28 insertions(+), 33 deletions(-)

diff --git a/drivers/memstick/host/r592.c b/drivers/memstick/host/r592.c
index 7d29d6549110..1d8547b12eca 100644
--- a/drivers/memstick/host/r592.c
+++ b/drivers/memstick/host/r592.c
@@ -562,40 +562,32 @@ out:
 	return;
 }
 
-/* Main request processing thread */
-static int r592_process_thread(void *data)
+/* Main request processing work */
+static void r592_process_func(struct kthread_work *work)
 {
 	int error;
-	struct r592_device *dev = (struct r592_device *)data;
-
-	while (!kthread_should_stop()) {
-		if (!dev->io_started) {
-			dbg_verbose("IO: started");
-			dev->io_started = true;
-		}
-
-		set_current_state(TASK_INTERRUPTIBLE);
-		error = memstick_next_req(dev->host, &dev->req);
+	struct r592_device *dev =
+		container_of(work, struct r592_device, io_work);
 
-		if (error) {
-			if (error == -ENXIO || error == -EAGAIN) {
-				dbg_verbose("IO: done");
-			} else {
-				dbg("IO: unknown error from "
-					"memstick_next_req %d", error);
-			}
-			dev->io_started = false;
+	if (!dev->io_started) {
+		dbg_verbose("IO: started");
+		dev->io_started = true;
+	}
 
-			if (kthread_should_stop())
-				set_current_state(TASK_RUNNING);
+	error = memstick_next_req(dev->host, &dev->req);
 
-			schedule();
+	if (error) {
+		if (error == -ENXIO || error == -EAGAIN) {
+			dbg_verbose("IO: done");
 		} else {
-			set_current_state(TASK_RUNNING);
-			r592_execute_tpc(dev);
+			dbg("IO: unknown error from memstick_next_req %d",
+			    error);
 		}
+		dev->io_started = false;
+	} else {
+		r592_execute_tpc(dev);
+		queue_kthread_work(dev->io_worker, &dev->io_work);
 	}
-	return 0;
 }
 
 /* Reprogram chip to detect change in card state */
@@ -720,7 +712,7 @@ static void r592_submit_req(struct memstick_host *host)
 	if (dev->req)
 		return;
 
-	wake_up_process(dev->io_thread);
+	queue_kthread_work(dev->io_worker, &dev->io_work);
 }
 
 static const struct pci_device_id r592_pci_id_tbl[] = {
@@ -778,9 +770,10 @@ static int r592_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	r592_check_dma(dev);
 
 	dev->io_started = false;
-	dev->io_thread = kthread_run(r592_process_thread, dev, "r592_io");
-	if (IS_ERR(dev->io_thread)) {
-		error = PTR_ERR(dev->io_thread);
+	init_kthread_work(&dev->io_work, r592_process_func);
+	dev->io_worker = create_kthread_worker(0, "r592_io");
+	if (IS_ERR(dev->io_worker)) {
+		error = PTR_ERR(dev->io_worker);
 		goto error5;
 	}
 
@@ -806,7 +799,7 @@ error6:
 		dma_free_coherent(&pdev->dev, PAGE_SIZE, dev->dummy_dma_page,
 			dev->dummy_dma_page_physical_address);
 
-	kthread_stop(dev->io_thread);
+	destroy_kthread_worker(dev->io_worker);
 error5:
 	iounmap(dev->mmio);
 error4:
@@ -826,7 +819,8 @@ static void r592_remove(struct pci_dev *pdev)
 
 	/* Stop the processing thread.
 	That ensures that we won't take any more requests */
-	kthread_stop(dev->io_thread);
+	cancel_kthread_work_sync(&dev->io_work);
+	destroy_kthread_worker(dev->io_worker);
 
 	r592_enable_device(dev, false);
 
diff --git a/drivers/memstick/host/r592.h b/drivers/memstick/host/r592.h
index aa8f0f22f4ce..1ac71380ac04 100644
--- a/drivers/memstick/host/r592.h
+++ b/drivers/memstick/host/r592.h
@@ -139,7 +139,8 @@ struct r592_device {
 	spinlock_t irq_lock;
 	struct timer_list detect_timer;
 
-	struct task_struct *io_thread;
+	struct kthread_worker *io_worker;
+	struct kthread_work io_work;
 	bool io_started;
 	bool parallel_mode;
 
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
