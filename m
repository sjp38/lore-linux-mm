Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E17D36B01BD
	for <linux-mm@kvack.org>; Fri, 28 May 2010 12:48:34 -0400 (EDT)
Received: by ywh33 with SMTP id 33so1072277ywh.11
        for <linux-mm@kvack.org>; Fri, 28 May 2010 09:48:33 -0700 (PDT)
Date: Fri, 28 May 2010 13:48:26 -0300
From: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100528164826.GJ11364@uudg.org>
References: <20100528143605.7E2A.A69D9226@jp.fujitsu.com>
 <AANLkTikB-8Qu03VrA5Z0LMXM_alSV7SLqzl-MmiLmFGv@mail.gmail.com>
 <20100528145329.7E2D.A69D9226@jp.fujitsu.com>
 <20100528125305.GE11364@uudg.org>
 <20100528140623.GA11041@barrios-desktop>
 <20100528143617.GF11364@uudg.org>
 <20100528151249.GB12035@barrios-desktop>
 <20100528152842.GH11364@uudg.org>
 <20100528154549.GC12035@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100528154549.GC12035@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Sat, May 29, 2010 at 12:45:49AM +0900, Minchan Kim wrote:
| On Fri, May 28, 2010 at 12:28:42PM -0300, Luis Claudio R. Goncalves wrote:
| > On Sat, May 29, 2010 at 12:12:49AM +0900, Minchan Kim wrote:
...
| > | I think highest RT proirity ins't good solution.
| > | As I mentiond, Some RT functions don't want to be preempted by other processes
| > | which cause memory pressure. It makes RT task broken.
| > 
| > For the RT case, if you reached a system OOM situation, your determinism has
| > already been hurt. If the memcg OOM happens on the same memcg your RT task
| > is - what will probably be the case most of time - again, the determinism
| > has deteriorated. For both these cases, giving the dying task SCHED_FIFO
| > MAX_RT_PRIO-1 means a faster recovery.
| 
| What I want to say is that determinisic has no relation with OOM. 
| Why is some RT task affected by other process's OOM?
| 
| Of course, if system has no memory, it is likely to slow down RT task. 
| But it's just only thought. If some task scheduled just is exit, we don't need
| to raise OOMed task's priority.
| 
| But raising min rt priority on your patch was what I want.
| It doesn't preempt any RT task.
| 
| So until now, I have made noise about your patch.
| Really, sorry for that. 
| I don't have any objection on raising priority part from now on. 

This is the third version of the patch, factoring in your input along with
Peter's comment. Basically the same patch, but using the lowest RT priority
to boost the dying task.

Thanks again for reviewing and commenting.
Luis

oom-killer: give the dying task rt priority (v3)

Give the dying task RT priority so that it can be scheduled quickly and die,
freeing needed memory.

Signed-off-by: Luis Claudio R. Goncalves <lgoncalv@redhat.com>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 84bbba2..2b0204f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -266,6 +266,8 @@ static struct task_struct *select_bad_process(unsigned long *ppoints)
  */
 static void __oom_kill_task(struct task_struct *p, int verbose)
 {
+	struct sched_param param;
+
 	if (is_global_init(p)) {
 		WARN_ON(1);
 		printk(KERN_WARNING "tried to kill init!\n");
@@ -288,6 +290,8 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
 	 * exit() and clear out its resources quickly...
 	 */
 	p->time_slice = HZ;
+	param.sched_priority = MAX_RT_PRIO-10;
+	sched_setscheduler(p, SCHED_FIFO, &param);
 	set_tsk_thread_flag(p, TIF_MEMDIE);
 
 	force_sig(SIGKILL, p);
-- 
[ Luis Claudio R. Goncalves                    Bass - Gospel - RT ]
[ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9  2696 7203 D980 A448 C8F8 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
