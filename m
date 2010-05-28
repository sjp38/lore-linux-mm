Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0CD6B6B01C4
	for <linux-mm@kvack.org>; Thu, 27 May 2010 23:52:00 -0400 (EDT)
Received: by qyk28 with SMTP id 28so1368144qyk.26
        for <linux-mm@kvack.org>; Thu, 27 May 2010 20:51:55 -0700 (PDT)
Date: Fri, 28 May 2010 00:51:47 -0300
From: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100528035147.GD11364@uudg.org>
References: <20100527180431.GP13035@uudg.org>
 <20100527183319.GA22313@redhat.com>
 <20100528090357.7DFB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100528090357.7DFB.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, May 28, 2010 at 11:54:07AM +0900, KOSAKI Motohiro wrote:
| Hi Luis,
| 
| > On 05/27, Luis Claudio R. Goncalves wrote:
| > >
| > > It sounds plausible giving the dying task an even higher priority to be
| > > sure it will be scheduled sooner and free the desired memory.
| > 
| > As usual, I can't really comment the changes in oom logic, just minor
| > nits...
| > 
| > > @@ -413,6 +415,8 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
| > >  	 */
| > >  	p->rt.time_slice = HZ;
| > >  	set_tsk_thread_flag(p, TIF_MEMDIE);
| > > +	param.sched_priority = MAX_RT_PRIO-1;
| > > +	sched_setscheduler(p, SCHED_FIFO, &param);
| > >
| > >  	force_sig(SIGKILL, p);
| > 
| > Probably sched_setscheduler_nocheck() makes more sense.
| > 
| > Minor, but perhaps it would be a bit better to send SIGKILL first,
| > then raise its prio.
| 
| I have no objection too. but I don't think Oleg's pointed thing is minor.
| Please send updated patch.
| 
| Thanks.

This version of the patch addresses the suggestions from Oleg Nesterov and
Kosaki Motohiro.

Thanks again for reviewing the patch.

oom-kill: give the dying task a higher priority (v2)

In a system under heavy load it was observed that even after the
oom-killer selects a task to die, the task may take a long time to die.

Right before sending a SIGKILL to the task selected by the oom-killer
this task has it's priority increased so that it can exit() exit soon,
freeing memory. That is accomplished by:

        /*
         * We give our sacrificial lamb high priority and access to
         * all the memory it needs. That way it should be able to
         * exit() and clear out its resources quickly...
         */
 	p->rt.time_slice = HZ;
 	set_tsk_thread_flag(p, TIF_MEMDIE);

It sounds plausible giving the dying task an even higher priority to be
sure it will be scheduled sooner and free the desired memory. Oleg Nesterov
pointed out it would be interesting sending the signal before increasing
the task priority.

Signed-off-by: Luis Claudio R. Goncalves <lclaudio@uudg.org>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b68e802..d352b3e 100644
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
@@ -413,8 +415,9 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
 	 */
 	p->rt.time_slice = HZ;
 	set_tsk_thread_flag(p, TIF_MEMDIE);
-
 	force_sig(SIGKILL, p);
+	param.sched_priority = MAX_RT_PRIO-1;
+	sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
 }
 
 static int oom_kill_task(struct task_struct *p)
-- 
[ Luis Claudio R. Goncalves                    Bass - Gospel - RT ]
[ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9  2696 7203 D980 A448 C8F8 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
