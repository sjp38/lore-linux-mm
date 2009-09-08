Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 95CA46B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 07:41:37 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n88BfdC0027927
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Sep 2009 20:41:39 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CFE4A45DE7D
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 20:41:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 76E2145DE6E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 20:41:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3776BE18009
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 20:41:38 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C12091DB8044
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 20:41:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
In-Reply-To: <1252405209.7746.38.camel@twins>
References: <20090908190148.0CC9.A69D9226@jp.fujitsu.com> <1252405209.7746.38.camel@twins>
Message-Id: <20090908193712.0CCF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Sep 2009 20:41:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: kosaki.motohiro@jp.fujitsu.com, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 2009-09-08 at 19:06 +0900, KOSAKI Motohiro wrote:
> > > On Tue, 2009-09-08 at 08:56 +0900, KOSAKI Motohiro wrote:
> > > > Hi Peter,
> > > > 
> > > > > On Mon, 2009-09-07 at 10:17 +0200, Mike Galbraith wrote:
> > > > > 
> > > > > > [  774.651779] SysRq : Show Blocked State
> > > > > > [  774.655770]   task                        PC stack   pid father
> > > > > > [  774.655770] evolution.bin D ffff8800bc1575f0     0  7349   6459 0x00000000
> > > > > > [  774.676008]  ffff8800bc3c9d68 0000000000000086 ffff8800015d9340 ffff8800bb91b780
> > > > > > [  774.676008]  000000000000dd28 ffff8800bc3c9fd8 0000000000013340 0000000000013340
> > > > > > [  774.676008]  00000000000000fd ffff8800015d9340 ffff8800bc1575f0 ffff8800bc157888
> > > > > > [  774.676008] Call Trace:
> > > > > > [  774.676008]  [<ffffffff812c4a11>] schedule_timeout+0x2d/0x20c
> > > > > > [  774.676008]  [<ffffffff812c4891>] wait_for_common+0xde/0x155
> > > > > > [  774.676008]  [<ffffffff8103f1cd>] ? default_wake_function+0x0/0x14
> > > > > > [  774.676008]  [<ffffffff810c0e63>] ? lru_add_drain_per_cpu+0x0/0x10
> > > > > > [  774.676008]  [<ffffffff810c0e63>] ? lru_add_drain_per_cpu+0x0/0x10
> > > > > > [  774.676008]  [<ffffffff812c49ab>] wait_for_completion+0x1d/0x1f
> > > > > > [  774.676008]  [<ffffffff8105fdf5>] flush_work+0x7f/0x93
> > > > > > [  774.676008]  [<ffffffff8105f870>] ? wq_barrier_func+0x0/0x14
> > > > > > [  774.676008]  [<ffffffff81060109>] schedule_on_each_cpu+0xb4/0xed
> > > > > > [  774.676008]  [<ffffffff810c0c78>] lru_add_drain_all+0x15/0x17
> > > > > > [  774.676008]  [<ffffffff810d1dbd>] sys_mlock+0x2e/0xde
> > > > > > [  774.676008]  [<ffffffff8100bc1b>] system_call_fastpath+0x16/0x1b
> > > > > 
> > > > > FWIW, something like the below (prone to explode since its utterly
> > > > > untested) should (mostly) fix that one case. Something similar needs to
> > > > > be done for pretty much all machine wide workqueue thingies, possibly
> > > > > also flush_workqueue().
> > > > 
> > > > Can you please explain reproduce way and problem detail?
> > > > 
> > > > AFAIK, mlock() call lru_add_drain_all() _before_ grab semaphoe. Then,
> > > > it doesn't cause any deadlock.
> > > 
> > > Suppose you have 2 cpus, cpu1 is busy doing a SCHED_FIFO-99 while(1),
> > > cpu0 does mlock()->lru_add_drain_all(), which does
> > > schedule_on_each_cpu(), which then waits for all cpus to complete the
> > > work. Except that cpu1, which is busy with the RT task, will never run
> > > keventd until the RT load goes away.
> > > 
> > > This is not so much an actual deadlock as a serious starvation case.
> > 
> > This seems flush_work vs RT-thread problem, not only lru_add_drain_all().
> > Why other workqueue flusher doesn't affect this issue?
> 
> flush_work() will only flush workqueues on which work has been enqueued
> as Oleg pointed out.
> 
> The problem is with lru_add_drain_all() enqueueing work on all
> workqueues.

Thank you for kindly explanation. I gradually become to understand this isssue.
Yes, lru_add_drain_all() use schedule_on_each_cpu() and it have following code

        for_each_online_cpu(cpu)
                flush_work(per_cpu_ptr(works, cpu));

However, I don't think your approach solve this issue.
lru_add_drain_all() flush lru_add_pvecs and lru_rotate_pvecs.

lru_add_pvecs is accounted when
  - lru move
      e.g. read(2), write(2), page fault, vmscan, page migration, et al

lru_rotate_pves is accounted when
  - page writeback

IOW, if RT-thread call write(2) syscall or page fault, we face the same
problem. I don't think we can assume RT-thread don't make page fault....

hmm, this seems difficult problem. I guess any mm code should use
schedule_on_each_cpu(). I continue to think this issue awhile.


> There is nothing that makes lru_add_drain_all() the only such site, its
> the one Mike posted to me, and my patch was a way to deal with that.

Well, schedule_on_each_cpu() is very limited used function.
Practically we can ignore other caller.


> I also explained that its not only RT related in that the HPC folks also
> want to avoid unneeded work -- for them its not starvation but a
> performance issue.

I think you talked about OS jitter issue. if so, I don't think this issue
make serious problem.  OS jitter mainly be caused by periodic action
 (e.g. tick update, timer, vmstat update). it's because
	little-delay x plenty-times = large-delay

lru_add_drain_all() is called from very limited point. e.g. mlock, shm-lock,
page-migration, memory-hotplug. all caller is not periodic.


> In generic we should avoid doing work when there is no work to be done.

Probably. but I'm not sure ;)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
