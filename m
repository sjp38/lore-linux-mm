Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 499C46B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 19:55:01 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBB0swOG018184
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Dec 2009 09:54:58 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EAFB045DE4F
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:54:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B3CDE45DE4E
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:54:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EF491DB8040
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:54:57 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 536B11DB803A
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 09:54:57 +0900 (JST)
Date: Fri, 11 Dec 2009 09:51:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC mm][PATCH 2/5] percpu cached mm counter
Message-Id: <20091211095159.6472a009.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262360912101640y4b90db76w61a7a5dab5f8e796@mail.gmail.com>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262360912101640y4b90db76w61a7a5dab5f8e796@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Fri, 11 Dec 2009 09:40:07 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:
> >A static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
> > A {
> > - A  A  A  return (unsigned long)atomic_long_read(&(mm)->counters[member]);
> > + A  A  A  long ret;
> > + A  A  A  /*
> > + A  A  A  A * Because this counter is loosely synchronized with percpu cached
> > + A  A  A  A * information, it's possible that value gets to be minus. For user's
> > + A  A  A  A * convenience/sanity, avoid returning minus.
> > + A  A  A  A */
> > + A  A  A  ret = atomic_long_read(&(mm)->counters[member]);
> > + A  A  A  if (unlikely(ret < 0))
> > + A  A  A  A  A  A  A  return 0;
> > + A  A  A  return (unsigned long)ret;
> > A }
> 
> Now, your sync point is only task switching time.
> So we can't show exact number if many counting of mm happens
> in short time.(ie, before context switching).
> It isn't matter?
> 
I think it's not a matter from 2 reasons.

1. Now, considering servers which requires continuous memory usage monitoring
as ps/top, when there are 2000 processes, "ps -elf" takes 0.8sec.
Because system admins know that gathering process information consumes
some amount of cpu resource, they will not do that so frequently.(I hope)

2. When chains of page faults occur continously in a period, the monitor
of memory usage just see a snapshot of current numbers and "snapshot of what
moment" is at random, always. No one can get precise number in that kind of situation. 



> >
> > A static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
<snip>

> > Index: mmotm-2.6.32-Dec8/kernel/sched.c
> > ===================================================================
> > --- mmotm-2.6.32-Dec8.orig/kernel/sched.c
> > +++ mmotm-2.6.32-Dec8/kernel/sched.c
> > @@ -2858,6 +2858,7 @@ context_switch(struct rq *rq, struct tas
> > A  A  A  A trace_sched_switch(rq, prev, next);
> > A  A  A  A mm = next->mm;
> > A  A  A  A oldmm = prev->active_mm;
> > +
> > A  A  A  A /*
> > A  A  A  A  * For paravirt, this is coupled with an exit in switch_to to
> > A  A  A  A  * combine the page table reload and the switch backend into
> > @@ -5477,6 +5478,11 @@ need_resched_nonpreemptible:
> >
> > A  A  A  A if (sched_feat(HRTICK))
> > A  A  A  A  A  A  A  A hrtick_clear(rq);
> > + A  A  A  /*
> > + A  A  A  A * sync/invaldidate per-cpu cached mm related information
> > + A  A  A  A * before taling rq->lock. (see include/linux/mm.h)
> 
> taling => taking
> 
> > + A  A  A  A */
> > + A  A  A  sync_mm_counters_atomic();
> 
> It's my above concern.
> before the process schedule out, we could get the wrong info.
> It's not realistic problem?
> 
I think not, now.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
