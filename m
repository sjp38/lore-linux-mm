Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 58B296B005A
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 08:26:30 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3482389dak.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 05:26:29 -0700 (PDT)
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 2/5] vmevent: Convert from deferred timer to deferred work
Date: Fri,  1 Jun 2012 05:24:03 -0700
Message-Id: <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <20120601122118.GA6128@lizard>
References: <20120601122118.GA6128@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

We'll need to use smp_function_call() in the sampling routines, and the
call is not supposed to be called from the bottom halves. So, let's
convert vmevent to dffered workqueues.

As a side effect, we also fix the swap reporting (we cannot call
si_swapinfo from the interrupt context), i.e. the following oops should
be fixed now:

 =================================
 [ INFO: inconsistent lock state ]
 3.4.0-rc1+ #37 Not tainted
 ---------------------------------
 inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
 swapper/0/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
  (swap_lock){+.?...}, at: [<ffffffff8110449d>] si_swapinfo+0x1d/0x90
 {SOFTIRQ-ON-W} state was registered at:
   [<ffffffff8107ca7f>] mark_irqflags+0x15f/0x1b0
   [<ffffffff8107e5e3>] __lock_acquire+0x493/0x9d0
   [<ffffffff8107f20e>] lock_acquire+0x9e/0x200
   [<ffffffff813e9071>] _raw_spin_lock+0x41/0x50
   [<ffffffff8110449d>] si_swapinfo+0x1d/0x90
   [<ffffffff8117e7c8>] meminfo_proc_show+0x38/0x3f0
   [<ffffffff81141209>] seq_read+0x139/0x3f0
   [<ffffffff81174cc6>] proc_reg_read+0x86/0xc0
   [<ffffffff8111c19c>] vfs_read+0xac/0x160
   [<ffffffff8111c29a>] sys_read+0x4a/0x90
   [<ffffffff813ea652>] system_call_fastpath+0x16/0x1b

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 mm/vmevent.c |   49 ++++++++++++++++++++++++++++---------------------
 1 file changed, 28 insertions(+), 21 deletions(-)

diff --git a/mm/vmevent.c b/mm/vmevent.c
index 381e9d1..4ca2a04 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -3,7 +3,7 @@
 #include <linux/compiler.h>
 #include <linux/vmevent.h>
 #include <linux/syscalls.h>
-#include <linux/timer.h>
+#include <linux/workqueue.h>
 #include <linux/file.h>
 #include <linux/list.h>
 #include <linux/poll.h>
@@ -34,7 +34,7 @@ struct vmevent_watch {
 	struct vmevent_attr		*config_attrs[VMEVENT_CONFIG_MAX_ATTRS];
 
 	/* sampling */
-	struct timer_list		timer;
+	struct delayed_work		work;
 
 	/* poll */
 	wait_queue_head_t		waitq;
@@ -146,15 +146,13 @@ static bool vmevent_match(struct vmevent_watch *watch)
 }
 
 /*
- * This function is called from the timer context, which has the same
- * guaranties as an interrupt handler: it can have only one execution
- * thread (unlike bare softirq handler), so we don't need to worry
- * about racing w/ ourselves.
+ * This function is called from a workqueue, which can have only one
+ * execution thread, so we don't need to worry about racing w/ ourselves.
  *
- * We also don't need to worry about several instances of timers
- * accessing the same vmevent_watch, as we allocate vmevent_watch
- * together w/ the timer instance in vmevent_fd(), so there is always
- * one timer per vmevent_watch.
+ * We also don't need to worry about several instances of us accessing
+ * the same vmevent_watch, as we allocate vmevent_watch together w/ the
+ * work instance in vmevent_fd(), so there is always one work per
+ * vmevent_watch.
  *
  * All the above makes it possible to implement the lock-free logic,
  * using just the atomic watch->pending variable.
@@ -178,26 +176,35 @@ static void vmevent_sample(struct vmevent_watch *watch)
 	atomic_set(&watch->pending, 1);
 }
 
-static void vmevent_timer_fn(unsigned long data)
+static void vmevent_schedule_watch(struct vmevent_watch *watch)
 {
-	struct vmevent_watch *watch = (struct vmevent_watch *)data;
+	schedule_delayed_work(&watch->work,
+		nsecs_to_jiffies64(watch->config.sample_period_ns));
+}
+
+static struct vmevent_watch *work_to_vmevent_watch(struct work_struct *work)
+{
+	struct delayed_work *wk = to_delayed_work(work);
+
+	return container_of(wk, struct vmevent_watch, work);
+}
+
+static void vmevent_timer_fn(struct work_struct *work)
+{
+	struct vmevent_watch *watch = work_to_vmevent_watch(work);
 
 	vmevent_sample(watch);
 
 	if (atomic_read(&watch->pending))
 		wake_up(&watch->waitq);
-	mod_timer(&watch->timer, jiffies +
-			nsecs_to_jiffies64(watch->config.sample_period_ns));
+
+	vmevent_schedule_watch(watch);
 }
 
 static void vmevent_start_timer(struct vmevent_watch *watch)
 {
-	init_timer_deferrable(&watch->timer);
-	watch->timer.data = (unsigned long)watch;
-	watch->timer.function = vmevent_timer_fn;
-	watch->timer.expires = jiffies +
-			nsecs_to_jiffies64(watch->config.sample_period_ns);
-	add_timer(&watch->timer);
+	INIT_DELAYED_WORK_DEFERRABLE(&watch->work, vmevent_timer_fn);
+	vmevent_schedule_watch(watch);
 }
 
 static unsigned int vmevent_poll(struct file *file, poll_table *wait)
@@ -259,7 +266,7 @@ static int vmevent_release(struct inode *inode, struct file *file)
 {
 	struct vmevent_watch *watch = file->private_data;
 
-	del_timer_sync(&watch->timer);
+	cancel_delayed_work_sync(&watch->work);
 
 	kfree(watch);
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
