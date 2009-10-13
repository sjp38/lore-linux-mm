Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5C2156B0088
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 21:21:12 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9D1HnY9022579
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Oct 2009 10:17:50 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BBEA245DE4D
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 10:17:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9082345DE4F
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 10:17:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 78B361DB8042
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 10:17:49 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 324641DB803E
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 10:17:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH v2] mlock() doesn't wait to finish lru_add_drain_all()
In-Reply-To: <20091012165747.97f5bd87.akpm@linux-foundation.org>
References: <20091009111709.1291.A69D9226@jp.fujitsu.com> <20091012165747.97f5bd87.akpm@linux-foundation.org>
Message-Id: <20091013090347.C752.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 13 Oct 2009 10:17:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Galbraith <efault@gmx.de>, Oleg Nesterov <onestero@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

> On Fri,  9 Oct 2009 11:21:55 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > Recently, Mike Galbraith reported mlock() makes hang-up very long time in
> > his system. Peter Zijlstra explainted the reason.
> > 
> >   Suppose you have 2 cpus, cpu1 is busy doing a SCHED_FIFO-99 while(1),
> >   cpu0 does mlock()->lru_add_drain_all(), which does
> >   schedule_on_each_cpu(), which then waits for all cpus to complete the
> >   work. Except that cpu1, which is busy with the RT task, will never run
> >   keventd until the RT load goes away.
> > 
> >   This is not so much an actual deadlock as a serious starvation case.
> > 
> > His system has two partions using cpusets and RT-task partion cpu doesn't
> > have any PCP cache. thus, this result was pretty unexpected.
> > 
> > The fact is, mlock() doesn't need to wait to finish lru_add_drain_all().
> > if mlock() can't turn on PG_mlock, vmscan turn it on later.
> > 
> > Thus, this patch replace it with lru_add_drain_all_async().
> 
> So why don't we just remove the lru_add_drain_all() call from sys_mlock()?

There are small reason. the administrators and the testers (include me)
look at Mlock field in /proc/meminfo.
They natually expect Mlock field match with actual number of mlocked pages
if the system don't have any stress. Otherwise, we can't make mlock test case ;)


> How did you work out why the lru_add_drain_all() is present in
> sys_mlock() anyway?  Neither the code nor the original changelog tell
> us.  Who do I thwap for that?  Nick and his reviewers.  Sigh.

[Umm, My dictionaly don't tell me the meaning of "thwap".  An meaning of
an imitative word strongly depend on culture. Thus, I probably
misunderstand this paragraph.]

I've understand the existing reason by looooooong time review.


> There are many callers of lru_add_drain_all() all over the place.  Each
> of those is vulnerable to the same starvation issue, is it not?

There are.

> If so, it would be better to just fix up lru_add_drain_all().  Afaict
> all of its functions can be performed in hard IRQ context, so we can
> use smp_call_function()?

There is a option. but it have one downside, it require lru_add_pvecs
related function call irq_disable().

__lru_cache_add() is often called from page fault path. then we need
performance mesurement.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
