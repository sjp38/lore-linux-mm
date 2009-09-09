Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CB6C76B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 22:06:04 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n89263iM019151
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 9 Sep 2009 11:06:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C00A845DE54
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 11:06:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0374E45DE53
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 11:06:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D6AA8E08005
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 11:06:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 77E0BE78004
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 11:06:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
In-Reply-To: <1252411520.7746.68.camel@twins>
References: <20090908193712.0CCF.A69D9226@jp.fujitsu.com> <1252411520.7746.68.camel@twins>
Message-Id: <20090909103617.0CE0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  9 Sep 2009 11:06:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: kosaki.motohiro@jp.fujitsu.com, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi

> > Thank you for kindly explanation. I gradually become to understand this isssue.
> > Yes, lru_add_drain_all() use schedule_on_each_cpu() and it have following code
> > 
> >         for_each_online_cpu(cpu)
> >                 flush_work(per_cpu_ptr(works, cpu));
> > 
> > However, I don't think your approach solve this issue.
> > lru_add_drain_all() flush lru_add_pvecs and lru_rotate_pvecs.
> > 
> > lru_add_pvecs is accounted when
> >   - lru move
> >       e.g. read(2), write(2), page fault, vmscan, page migration, et al
> > 
> > lru_rotate_pves is accounted when
> >   - page writeback
> > 
> > IOW, if RT-thread call write(2) syscall or page fault, we face the same
> > problem. I don't think we can assume RT-thread don't make page fault....
> > 
> > hmm, this seems difficult problem. I guess any mm code should use
> > schedule_on_each_cpu(). I continue to think this issue awhile.
> 
> This is about avoiding work when there is non, clearly when an
> application does use the kernel it creates work.
> 
> But a clearly userspace, cpu-bound process, while(1), should not get
> interrupted by things like lru_add_drain() when it doesn't have any
> pages to drain.

Yup. makes sense.
So, I think you mean you'd like to tackle this special case as fist step, right?
if yes, I agree.


> > > There is nothing that makes lru_add_drain_all() the only such site, its
> > > the one Mike posted to me, and my patch was a way to deal with that.
> > 
> > Well, schedule_on_each_cpu() is very limited used function.
> > Practically we can ignore other caller.
> 
> No, we need to inspect all callers, having only a few makes that easier.

Sorry my poor english. I meaned I don't oppose your patch approach. I don't oppose
additional work at all.


> 
> > > I also explained that its not only RT related in that the HPC folks also
> > > want to avoid unneeded work -- for them its not starvation but a
> > > performance issue.
> > 
> > I think you talked about OS jitter issue. if so, I don't think this issue
> > make serious problem.  OS jitter mainly be caused by periodic action
> >  (e.g. tick update, timer, vmstat update). it's because
> > 	little-delay x plenty-times = large-delay
> > 
> > lru_add_drain_all() is called from very limited point. e.g. mlock, shm-lock,
> > page-migration, memory-hotplug. all caller is not periodic.
> 
> Doesn't matter, if you want to reduce it, you need to address all of
> them, a process 4 nodes away calling mlock() while this partition has
> been user-bound for the last hour or so and doesn't have any lru pages
> simply needn't be woken.

Doesn't matter? You mean can we stop to discuss hits HPC performance issue
as Christoph pointed out?
hmmm, sorry, I haven't catch your point.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
