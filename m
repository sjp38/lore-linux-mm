Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B01946B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 08:05:30 -0400 (EDT)
Subject: Re: [rfc] lru_add_drain_all() vs isolation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20090908193712.0CCF.A69D9226@jp.fujitsu.com>
References: <20090908190148.0CC9.A69D9226@jp.fujitsu.com>
	 <1252405209.7746.38.camel@twins>
	 <20090908193712.0CCF.A69D9226@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 08 Sep 2009 14:05:20 +0200
Message-Id: <1252411520.7746.68.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-09-08 at 20:41 +0900, KOSAKI Motohiro wrote:

> Thank you for kindly explanation. I gradually become to understand this isssue.
> Yes, lru_add_drain_all() use schedule_on_each_cpu() and it have following code
> 
>         for_each_online_cpu(cpu)
>                 flush_work(per_cpu_ptr(works, cpu));
> 
> However, I don't think your approach solve this issue.
> lru_add_drain_all() flush lru_add_pvecs and lru_rotate_pvecs.
> 
> lru_add_pvecs is accounted when
>   - lru move
>       e.g. read(2), write(2), page fault, vmscan, page migration, et al
> 
> lru_rotate_pves is accounted when
>   - page writeback
> 
> IOW, if RT-thread call write(2) syscall or page fault, we face the same
> problem. I don't think we can assume RT-thread don't make page fault....
> 
> hmm, this seems difficult problem. I guess any mm code should use
> schedule_on_each_cpu(). I continue to think this issue awhile.

This is about avoiding work when there is non, clearly when an
application does use the kernel it creates work.

But a clearly userspace, cpu-bound process, while(1), should not get
interrupted by things like lru_add_drain() when it doesn't have any
pages to drain.

> > There is nothing that makes lru_add_drain_all() the only such site, its
> > the one Mike posted to me, and my patch was a way to deal with that.
> 
> Well, schedule_on_each_cpu() is very limited used function.
> Practically we can ignore other caller.

No, we need to inspect all callers, having only a few makes that easier.

> > I also explained that its not only RT related in that the HPC folks also
> > want to avoid unneeded work -- for them its not starvation but a
> > performance issue.
> 
> I think you talked about OS jitter issue. if so, I don't think this issue
> make serious problem.  OS jitter mainly be caused by periodic action
>  (e.g. tick update, timer, vmstat update). it's because
> 	little-delay x plenty-times = large-delay
> 
> lru_add_drain_all() is called from very limited point. e.g. mlock, shm-lock,
> page-migration, memory-hotplug. all caller is not periodic.

Doesn't matter, if you want to reduce it, you need to address all of
them, a process 4 nodes away calling mlock() while this partition has
been user-bound for the last hour or so and doesn't have any lru pages
simply needn't be woken.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
