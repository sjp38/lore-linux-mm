Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CCEDF6B01BD
	for <linux-mm@kvack.org>; Fri, 28 May 2010 08:53:13 -0400 (EDT)
Received: by gyg4 with SMTP id 4so944823gyg.14
        for <linux-mm@kvack.org>; Fri, 28 May 2010 05:53:12 -0700 (PDT)
Date: Fri, 28 May 2010 09:53:05 -0300
From: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100528125305.GE11364@uudg.org>
References: <20100528143605.7E2A.A69D9226@jp.fujitsu.com>
 <AANLkTikB-8Qu03VrA5Z0LMXM_alSV7SLqzl-MmiLmFGv@mail.gmail.com>
 <20100528145329.7E2D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100528145329.7E2D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, May 28, 2010 at 02:59:02PM +0900, KOSAKI Motohiro wrote:
| > RT Task
| > 
| > void non-RT-function()
| > {
| >    system call();
| >    buffer = malloc();
| >    memset(buffer);
| > }
| > /*
| >  * We make sure this function must be executed in some millisecond
| >  */
| > void RT-function()
| > {
| >    some calculation(); <- This doesn't have no dynamic characteristic
| > }
| > int main()
| > {
| >    non-RT-function();
| >    /* This function make sure RT-function cannot preempt by others */
| >    set_RT_max_high_priority();
| >    RT-function A();
| >    set_normal_priority();
| >    non-RT-function();
| > }
| > 
| > We don't want realtime in whole function of the task. What we want is
| > just RT-function A.
| > Of course, current Linux cannot make perfectly sure RT-functionA can
| > not preempt by others.
| > That's because some interrupt or exception happen. But RT-function A
| > doesn't related to any dynamic characteristic. What can justify to
| > preempt RT-function A by other processes?
| 
| As far as my observation, RT-function always have some syscall. because pure
| calculation doesn't need deterministic guarantee. But _if_ you are really
| using such priority design. I'm ok maximum NonRT priority instead maximum
| RT priority too.

I confess I failed to distinguish memcg OOM and system OOM and used "in
case of OOM kill the selected task the faster you can" as the guideline.
If the exit code path is short that shouldn't be a problem.

Maybe the right way to go would be giving the dying task the biggest
priority inside that memcg to be sure that it will be the next process from
that memcg to be scheduled. Would that be reasonable?

| Luis, NonRT high priority break your use case? and if yes, can you please
| explain the reason?

Most of my tests are in the realtime land, usually with premmpt_rt kernels.
In this case, an RT priority will be usually necessary. But that is not the
general case and I agree that a smoother (but not slower) solution could be
devised by just increasing the dying process'priority to be high enough for
the process set (memcg) it belongs to.

What is the impact of a memcg OOM for the system as a whole? That should be
factored in the equation too.

Luis
-- 
[ Luis Claudio R. Goncalves                    Bass - Gospel - RT ]
[ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9  2696 7203 D980 A448 C8F8 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
