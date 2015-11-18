Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 690E982F6C
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:27:24 -0500 (EST)
Received: by wmec201 with SMTP id c201so72986356wme.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:27:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id un9si3982193wjc.77.2015.11.18.05.27.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Nov 2015 05:27:23 -0800 (PST)
From: Petr Mladek <pmladek@suse.com>
Subject: [PATCH v3 17/22] ipmi: Convert kipmi kthread into kthread worker API
Date: Wed, 18 Nov 2015 14:25:22 +0100
Message-Id: <1447853127-3461-18-git-send-email-pmladek@suse.com>
In-Reply-To: <1447853127-3461-1-git-send-email-pmladek@suse.com>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>, Corey Minyard <minyard@acm.org>, openipmi-developer@lists.sourceforge.net

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

This patch converts kipmi kthread into the kthread worker API because
it modifies the scheduling priority. The change is quite straightforward.

First, we move the per-thread variable "busy_until" into the per-thread
structure struct smi_info. As a side effect, we could omit one parameter
in ipmi_thread_busy_wait(). On the other hand, the structure could not
longer be passed with the const qualifier.

The value of "busy_until" is initialized when the kthread is created.
Also the scheduling priority is set there. This helps to avoid an extra
init work.

One iteration of the kthread cycle is moved to a delayed work function.
The different delays between the cycles are solved the following way:

  + immediate cycle (nope) is converted into goto within the same work

  + immediate cycle with a possible reschedule is converted into
    re-queuing with a zero delay

  + schedule_timeout() is converted into re-queuing with the given
    delay

  + interruptible sleep is converted into nothing; The work
    will get queued again from the check_start_timer_thread().
    By other words the external wakeup_up_process() will get
    replaced by queuing with a zero delay.

Probably the most tricky change is when the worker is being stopped.
We need to explicitly cancel the work to prevent it from re-queuing.

Signed-off-by: Petr Mladek <pmladek@suse.com>
CC: Corey Minyard <minyard@acm.org>
CC: openipmi-developer@lists.sourceforge.net
---
 drivers/char/ipmi/ipmi_si_intf.c | 116 ++++++++++++++++++++++-----------------
 1 file changed, 66 insertions(+), 50 deletions(-)

diff --git a/drivers/char/ipmi/ipmi_si_intf.c b/drivers/char/ipmi/ipmi_si_intf.c
index 654f6f36a071..fdb97eaded4b 100644
--- a/drivers/char/ipmi/ipmi_si_intf.c
+++ b/drivers/char/ipmi/ipmi_si_intf.c
@@ -302,7 +302,9 @@ struct smi_info {
 	/* Counters and things for the proc filesystem. */
 	atomic_t stats[SI_NUM_STATS];
 
-	struct task_struct *thread;
+	struct kthread_worker *worker;
+	struct delayed_kthread_work work;
+	struct timespec64 busy_until;
 
 	struct list_head link;
 	union ipmi_smi_info_union addr_info;
@@ -929,8 +931,9 @@ static void check_start_timer_thread(struct smi_info *smi_info)
 	if (smi_info->si_state == SI_NORMAL && smi_info->curr_msg == NULL) {
 		smi_mod_timer(smi_info, jiffies + SI_TIMEOUT_JIFFIES);
 
-		if (smi_info->thread)
-			wake_up_process(smi_info->thread);
+		if (smi_info->worker)
+			mod_delayed_kthread_work(smi_info->worker,
+						 &smi_info->work, 0);
 
 		start_next_msg(smi_info);
 		smi_event_handler(smi_info, 0);
@@ -1008,10 +1011,10 @@ static inline int ipmi_si_is_busy(struct timespec64 *ts)
 }
 
 static inline int ipmi_thread_busy_wait(enum si_sm_result smi_result,
-					const struct smi_info *smi_info,
-					struct timespec64 *busy_until)
+					struct smi_info *smi_info)
 {
 	unsigned int max_busy_us = 0;
+	struct timespec64 *busy_until = &smi_info->busy_until;
 
 	if (smi_info->intf_num < num_max_busy_us)
 		max_busy_us = kipmid_max_busy_us[smi_info->intf_num];
@@ -1042,53 +1045,49 @@ static inline int ipmi_thread_busy_wait(enum si_sm_result smi_result,
  * (if that is enabled).  See the paragraph on kimid_max_busy_us in
  * Documentation/IPMI.txt for details.
  */
-static int ipmi_thread(void *data)
+static void ipmi_func(struct kthread_work *work)
 {
-	struct smi_info *smi_info = data;
+	struct smi_info *smi_info = container_of(work, struct smi_info,
+						 work.work);
 	unsigned long flags;
 	enum si_sm_result smi_result;
-	struct timespec64 busy_until;
+	int busy_wait;
 
-	ipmi_si_set_not_busy(&busy_until);
-	set_user_nice(current, MAX_NICE);
-	while (!kthread_should_stop()) {
-		int busy_wait;
+next:
+	spin_lock_irqsave(&(smi_info->si_lock), flags);
+	smi_result = smi_event_handler(smi_info, 0);
 
-		spin_lock_irqsave(&(smi_info->si_lock), flags);
-		smi_result = smi_event_handler(smi_info, 0);
+	/*
+	 * If the driver is doing something, there is a possible
+	 * race with the timer.  If the timer handler see idle,
+	 * and the thread here sees something else, the timer
+	 * handler won't restart the timer even though it is
+	 * required.  So start it here if necessary.
+	 */
+	if (smi_result != SI_SM_IDLE && !smi_info->timer_running)
+		smi_mod_timer(smi_info, jiffies + SI_TIMEOUT_JIFFIES);
 
-		/*
-		 * If the driver is doing something, there is a possible
-		 * race with the timer.  If the timer handler see idle,
-		 * and the thread here sees something else, the timer
-		 * handler won't restart the timer even though it is
-		 * required.  So start it here if necessary.
-		 */
-		if (smi_result != SI_SM_IDLE && !smi_info->timer_running)
-			smi_mod_timer(smi_info, jiffies + SI_TIMEOUT_JIFFIES);
-
-		spin_unlock_irqrestore(&(smi_info->si_lock), flags);
-		busy_wait = ipmi_thread_busy_wait(smi_result, smi_info,
-						  &busy_until);
-		if (smi_result == SI_SM_CALL_WITHOUT_DELAY)
-			; /* do nothing */
-		else if (smi_result == SI_SM_CALL_WITH_DELAY && busy_wait)
-			schedule();
-		else if (smi_result == SI_SM_IDLE) {
-			if (atomic_read(&smi_info->need_watch)) {
-				schedule_timeout_interruptible(100);
-			} else {
-				/* Wait to be woken up when we are needed. */
-				__set_current_state(TASK_INTERRUPTIBLE);
-				schedule();
-			}
-		} else
-			schedule_timeout_interruptible(1);
+	spin_unlock_irqrestore(&(smi_info->si_lock), flags);
+	busy_wait = ipmi_thread_busy_wait(smi_result, smi_info);
+
+	if (smi_result == SI_SM_CALL_WITHOUT_DELAY)
+		goto next;
+	if (smi_result == SI_SM_CALL_WITH_DELAY && busy_wait) {
+		queue_delayed_kthread_work(smi_info->worker,
+					   &smi_info->work, 0);
+	} else if (smi_result == SI_SM_IDLE) {
+		if (atomic_read(&smi_info->need_watch)) {
+			queue_delayed_kthread_work(smi_info->worker,
+						   &smi_info->work, 100);
+		} else {
+			/* Nope. Wait to be queued when we are needed. */
+		}
+	} else {
+		queue_delayed_kthread_work(smi_info->worker,
+					   &smi_info->work, 1);
 	}
-	return 0;
 }
 
-
 static void poll(void *send_info)
 {
 	struct smi_info *smi_info = send_info;
@@ -1229,17 +1228,29 @@ static int smi_start_processing(void       *send_info,
 		enable = 1;
 
 	if (enable) {
-		new_smi->thread = kthread_run(ipmi_thread, new_smi,
-					      "kipmi%d", new_smi->intf_num);
-		if (IS_ERR(new_smi->thread)) {
+		struct kthread_worker *worker;
+
+		worker = create_kthread_worker(0, "kipmi%d",
+					       new_smi->intf_num);
+
+		if (IS_ERR(worker)) {
 			dev_notice(new_smi->dev, "Could not start"
 				   " kernel thread due to error %ld, only using"
 				   " timers to drive the interface\n",
-				   PTR_ERR(new_smi->thread));
-			new_smi->thread = NULL;
+				   PTR_ERR(worker));
+			goto out;
 		}
+
+		ipmi_si_set_not_busy(&new_smi->busy_until);
+		set_user_nice(worker->task, MAX_NICE);
+
+		init_delayed_kthread_work(&new_smi->work, ipmi_func);
+		queue_delayed_kthread_work(worker, &new_smi->work, 0);
+
+		new_smi->worker = worker;
 	}
 
+out:
 	return 0;
 }
 
@@ -3414,8 +3425,13 @@ static void check_for_broken_irqs(struct smi_info *smi_info)
 
 static inline void wait_for_timer_and_thread(struct smi_info *smi_info)
 {
-	if (smi_info->thread != NULL)
-		kthread_stop(smi_info->thread);
+	if (smi_info->worker != NULL) {
+		struct kthread_worker *worker = smi_info->worker;
+
+		smi_info->worker = NULL;
+		cancel_delayed_kthread_work_sync(&smi_info->work);
+		destroy_kthread_worker(worker);
+	}
 	if (smi_info->timer_running)
 		del_timer_sync(&smi_info->si_timer);
 }
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
