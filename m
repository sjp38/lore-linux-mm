Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7AE0E6B01AF
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 00:55:45 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5G4tgoo023294
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Jun 2010 13:55:43 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 948F245DE51
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 13:55:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BD6A45DE4D
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 13:55:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 539F0E18001
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 13:55:42 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A09CE08003
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 13:55:42 +0900 (JST)
Date: Wed, 16 Jun 2010 13:51:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] use find_lock_task_mm in memory cgroups oom v2
Message-Id: <20100616135109.75b21f7c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikGcl8l8TvSWx2Ij7I5E-TVjGplRU5YfX0mTAG0@mail.gmail.com>
References: <20100615152450.f82c1f8c.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinEEYWULLICKqBr4yX7GL01E4cq0jQSfuN8J6Jq@mail.gmail.com>
	<20100616090334.d27e0c4e.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikGcl8l8TvSWx2Ij7I5E-TVjGplRU5YfX0mTAG0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Jun 2010 10:12:20 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> On Wed, Jun 16, 2010 at 5:33 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 15 Jun 2010 18:59:25 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> > -/*
> >> > +/**
> >> > + * find_lock_task_mm - Checking a process which a task belongs to has valid mm
> >> > + * and return a locked task which has a valid pointer to mm.
> >> > + *
> >>
> >> This comment should have been another patch.
> >> BTW, below comment uses "subthread" word.
> >> Personally it's easy to understand function's goal to me. :)
> >>
> >> How about following as?
> >> Checking a process which has any subthread with vaild mm
> >> ....
> >>
> > Sure. thank you. v2 is here. I removed unnecessary parts.
> >
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > When the OOM killer scans task, it check a task is under memcg or
> > not when it's called via memcg's context.
> >
> > But, as Oleg pointed out, a thread group leader may have NULL ->mm
> > and task_in_mem_cgroup() may do wrong decision. We have to use
> > find_lock_task_mm() in memcg as generic OOM-Killer does.
> >
> > Changelog:
> > A - removed unnecessary changes in comments.
> >
> 
> mm->owner solves the same problem, but unfortunately we have task
> based selection in OOM killer, so we need this patch. It is quite
> ironic that we find the mm from the task and then eventually the task
> back from mm->owner and then the mem cgroup. If we already know the mm
> from oom_kill.c, I think we can change the function to work off of
> that. mm->owner->cgroup..no?
> 

There is no function as for_each_mm(). There is only for_each_process().

And, generally, there is no way to get a task via mm_struct.
To send signal etc. we need task.
(mm_owner is an option but not always configured and there will be
 complicated problem as vfork() etc.)

I think oom_kill.c has to depend on thread, not mm, unfortunately.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
