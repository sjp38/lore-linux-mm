Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CBF786B0092
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 21:51:51 -0400 (EDT)
Date: Mon, 12 Oct 2009 18:51:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [resend][PATCH v2] mlock() doesn't wait to finish
 lru_add_drain_all()
Message-Id: <20091012185139.75c13648.akpm@linux-foundation.org>
In-Reply-To: <20091013090347.C752.A69D9226@jp.fujitsu.com>
References: <20091009111709.1291.A69D9226@jp.fujitsu.com>
	<20091012165747.97f5bd87.akpm@linux-foundation.org>
	<20091013090347.C752.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Galbraith <efault@gmx.de>, Oleg Nesterov <onestero@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Oct 2009 10:17:48 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi
> 
> > On Fri,  9 Oct 2009 11:21:55 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > Recently, Mike Galbraith reported mlock() makes hang-up very long time in
> > > his system. Peter Zijlstra explainted the reason.
> > > 
> > >   Suppose you have 2 cpus, cpu1 is busy doing a SCHED_FIFO-99 while(1),
> > >   cpu0 does mlock()->lru_add_drain_all(), which does
> > >   schedule_on_each_cpu(), which then waits for all cpus to complete the
> > >   work. Except that cpu1, which is busy with the RT task, will never run
> > >   keventd until the RT load goes away.
> > > 
> > >   This is not so much an actual deadlock as a serious starvation case.
> > > 
> > > His system has two partions using cpusets and RT-task partion cpu doesn't
> > > have any PCP cache. thus, this result was pretty unexpected.
> > > 
> > > The fact is, mlock() doesn't need to wait to finish lru_add_drain_all().
> > > if mlock() can't turn on PG_mlock, vmscan turn it on later.
> > > 
> > > Thus, this patch replace it with lru_add_drain_all_async().
> > 
> > So why don't we just remove the lru_add_drain_all() call from sys_mlock()?
> 
> There are small reason. the administrators and the testers (include me)
> look at Mlock field in /proc/meminfo.
> They natually expect Mlock field match with actual number of mlocked pages
> if the system don't have any stress. Otherwise, we can't make mlock test case ;)
> 
> 
> > How did you work out why the lru_add_drain_all() is present in
> > sys_mlock() anyway?  Neither the code nor the original changelog tell
> > us.  Who do I thwap for that?  Nick and his reviewers.  Sigh.
> 
> [Umm, My dictionaly don't tell me the meaning of "thwap".  An meaning of
> an imitative word strongly depend on culture. Thus, I probably
> misunderstand this paragraph.]

"slap"?

> I've understand the existing reason by looooooong time review.
> 
> 
> > There are many callers of lru_add_drain_all() all over the place.  Each
> > of those is vulnerable to the same starvation issue, is it not?
> 
> There are.
> 
> > If so, it would be better to just fix up lru_add_drain_all().  Afaict
> > all of its functions can be performed in hard IRQ context, so we can
> > use smp_call_function()?
> 
> There is a option. but it have one downside, it require lru_add_pvecs
> related function call irq_disable().

I don't know what this means.  ____pagevec_lru_add() (for example) can
be trivially changed from spin_lock_irq() to spin_lock_irqsave().

In other cases we can perhaps split an existing

foo()
{
	spin_lock_irq(zone->lock);
}

into

__foo()
{
	spin_lock(zone->lock);
}

foo()
{
	local_irq_disable()
	__foo();
}

then call the new __foo().
	

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
