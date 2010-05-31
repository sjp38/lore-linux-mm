Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 667016B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 01:09:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4V59Q9I029413
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 31 May 2010 14:09:26 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E6E345DE50
	for <linux-mm@kvack.org>; Mon, 31 May 2010 14:09:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6460445DE4D
	for <linux-mm@kvack.org>; Mon, 31 May 2010 14:09:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E4B8E18001
	for <linux-mm@kvack.org>; Mon, 31 May 2010 14:09:26 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0591C1DB803B
	for <linux-mm@kvack.org>; Mon, 31 May 2010 14:09:26 +0900 (JST)
Date: Mon, 31 May 2010 14:04:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-Id: <20100531140443.b36a4f02.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikFk_HnZWPG0s_VrRkro2rruEc8OBX5KfKp_QdX@mail.gmail.com>
References: <20100528143605.7E2A.A69D9226@jp.fujitsu.com>
	<AANLkTikB-8Qu03VrA5Z0LMXM_alSV7SLqzl-MmiLmFGv@mail.gmail.com>
	<20100528145329.7E2D.A69D9226@jp.fujitsu.com>
	<20100528125305.GE11364@uudg.org>
	<20100528140623.GA11041@barrios-desktop>
	<20100528143617.GF11364@uudg.org>
	<20100528151249.GB12035@barrios-desktop>
	<20100528152842.GH11364@uudg.org>
	<20100528154549.GC12035@barrios-desktop>
	<20100528164826.GJ11364@uudg.org>
	<20100531092133.73705339.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikFk_HnZWPG0s_VrRkro2rruEc8OBX5KfKp_QdX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, 31 May 2010 14:01:03 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi, Kame.
> 
> On Mon, May 31, 2010 at 9:21 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 28 May 2010 13:48:26 -0300
> > "Luis Claudio R. Goncalves" <lclaudio@uudg.org> wrote:
> >>
> >> oom-killer: give the dying task rt priority (v3)
> >>
> >> Give the dying task RT priority so that it can be scheduled quickly and die,
> >> freeing needed memory.
> >>
> >> Signed-off-by: Luis Claudio R. GonA?alves <lgoncalv@redhat.com>
> >>
> >> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> >> index 84bbba2..2b0204f 100644
> >> --- a/mm/oom_kill.c
> >> +++ b/mm/oom_kill.c
> >> @@ -266,6 +266,8 @@ static struct task_struct *select_bad_process(unsigned long *ppoints)
> >> A  */
> >> A static void __oom_kill_task(struct task_struct *p, int verbose)
> >> A {
> >> + A  A  struct sched_param param;
> >> +
> >> A  A  A  if (is_global_init(p)) {
> >> A  A  A  A  A  A  A  WARN_ON(1);
> >> A  A  A  A  A  A  A  printk(KERN_WARNING "tried to kill init!\n");
> >> @@ -288,6 +290,8 @@ static void __oom_kill_task(struct task_struct *p, int verbose)
> >> A  A  A  A * exit() and clear out its resources quickly...
> >> A  A  A  A */
> >> A  A  A  p->time_slice = HZ;
> >> + A  A  param.sched_priority = MAX_RT_PRIO-10;
> >> + A  A  sched_setscheduler(p, SCHED_FIFO, &param);
> >> A  A  A  set_tsk_thread_flag(p, TIF_MEMDIE);
> >>
> >
> > BTW, how about the other threads which share mm_struct ?
> 
> Could you elaborate your intention? :)
> 

IIUC, the purpose of rising priority is to accerate dying thread to exit()
for freeing memory AFAP. But to free memory, exit, all threads which share
mm_struct should exit, too. I'm sorry if I miss something.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
