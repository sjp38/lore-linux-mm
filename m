Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 622DF6B01B2
	for <linux-mm@kvack.org>; Thu, 27 May 2010 14:04:39 -0400 (EDT)
Received: by qyk28 with SMTP id 28so414789qyk.26
        for <linux-mm@kvack.org>; Thu, 27 May 2010 11:04:38 -0700 (PDT)
Date: Thu, 27 May 2010 15:04:31 -0300
From: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Subject: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100527180431.GP13035@uudg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

Hello,

Could you please review this patch?

The idea behind it is quite simple: give the dying task a higher priority
so that it can be scheduled sooner and die to free memory.


oom-kill: give the dying task a higher priority

In a system under heavy load it was observed that even after the
oom-killer selects a task to die, the task may take a long time to die.

Right before sending a SIGKILL to the selected task the oom-killer
increases the task priority so that it can exit quickly, freeing memory.
That is accomplished by:

        /*
         * We give our sacrificial lamb high priority and access to
         * all the memory it needs. That way it should be able to
         * exit() and clear out its resources quickly...
         */
 	p->rt.time_slice = HZ;
 	set_tsk_thread_flag(p, TIF_MEMDIE);

It sounds plausible giving the dying task an even higher priority to be
sure it will be scheduled sooner and free the desired memory.

Signed-off-by: Luis Claudio R. Goncalves <lclaudio@uudg.org>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b68e802..8047309 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -382,6 +382,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
  */
 static void __oom_kill_task(struct task_struct *p, int verbose)
 {
+	struct sched_param param;
+
 	if (is_global_init(p)) {
 		WARN_ON(1);
 		printk(KERN_WARNING "tried to kill init!\n");
@@ -413,6 +415,8 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
 	 */
 	p->rt.time_slice = HZ;
 	set_tsk_thread_flag(p, TIF_MEMDIE);
+	param.sched_priority = MAX_RT_PRIO-1;
+	sched_setscheduler(p, SCHED_FIFO, &param);
 
 	force_sig(SIGKILL, p);
 }


Thanks,
Luis
-- 
[ Luis Claudio R. Goncalves                    Bass - Gospel - RT ]
[ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9  2696 7203 D980 A448 C8F8 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
