Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2D46B01F0
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 23:52:20 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o7Q3qHgM007178
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 20:52:18 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by kpbe20.cbf.corp.google.com with ESMTP id o7Q3qGIn014001
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 20:52:16 -0700
Received: by pxi6 with SMTP id 6so625600pxi.17
        for <linux-mm@kvack.org>; Wed, 25 Aug 2010 20:52:16 -0700 (PDT)
Date: Wed, 25 Aug 2010 20:52:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2][BUGFIX] oom: remove totalpage normalization from
 oom_badness()
In-Reply-To: <20100826122025.38112f79.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008252041490.15750@chino.kir.corp.google.com>
References: <20100825184001.F3EF.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1008250300500.13300@chino.kir.corp.google.com> <20100826093923.d4ac29b6.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008251746200.28401@chino.kir.corp.google.com>
 <20100826101139.eb05fe2d.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008251920510.6227@chino.kir.corp.google.com> <20100826122025.38112f79.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Aug 2010, KAMEZAWA Hiroyuki wrote:

> > Hmm, you need to know the amount of memory that you can use iff you know 
> > the memcg limit and it's a static value.  Otherwise, you only need to know 
> > the "memory usage of your application relative to others in the same 
> > cgroup."  An oom_score_adj of +300 adds 30% of that memcg's limit to the 
> > task, allowing all other tasks to use 30% more memory than that task with 
> > it still be killed.  An oom_score_adj of -300 allows that task to use 30% 
> > more memory than other tasks without getting killed.  These don't need to 
> > know the actual limit.
> > 
> 
> Hmm. What's complicated is oom_score_adj's behavior.
> 

I understand it's a little tricky when dealing with memcg-constrained oom 
conditions versus system-wide oom conditions.  Think of it this way: if 
the system is oom, then every memcg, every cpuset, and every mempolicy is 
also oom.  That doesn't imply that something in every memcg, every cpuset, 
or every mempolicy must be killed, however.  What cgroup happens to be 
penalized in this scenario isn't necessarily the scope of oom_score_adj's 
purpose.  oom_score_adj certainly does have a stronger influence over a 
task's priority when it's a system oom and not a memcg oom because the 
size of available memory is different, but that's fine: we set positive 
and negative oom_score_adj values for a reason based on the application, 
and that's not necessarily (but can be) a function of the memcg or system 
capacity.  Again, oom_score_adj is only meaningful when considered 
relative to other candidate tasks since the badness score itself is 
considered relative to other candidate tasks.

You can have multiple tasks that have +1000 oom_score_adj values (or 
multiple tasks that have +15 oom_adj values).  Only one will be killed and 
it's dependent only on the ordering of the tasklist.  That isn't an 
exception case, that only means that we prevented needless oom killing.

> > > So, an approximate oom_score under memcg can be
> > > 
> > >  memcg_oom_score = (oom_score - oom_score_adj) * system_memory/memcg's limit
> > > 		+ oom_score_adj.
> > > 
> > 
> > Right, that's the exact score within the memcg.
> > 
> > But, I still wouldn't encourage a formula like this because the memcg 
> > limit (or cpuset mems, mempolicy nodes, etc) are dynamic and may change 
> > out from under us.  So it's more important to define oom_score_adj in the 
> > user's mind as a proportion of memory available to be added (either 
> > positively or negatively) to its memory use when comparing it to other 
> > tasks.  The point is that the memcg limit isn't interesting in this 
> > formula, it's more important to understand the priority of the task 
> > _compared_ to other tasks memory usage in that memcg.
> > 
> 
> yes. For defineing/understanding priority, oom_score_adj is that.
> But it's priority isn't static.
> 

If the memcg limit changes because we're attaching more tasks, yes, we may 
want to change its oom_score_adj relative to those tasks.  So 
oom_score_adj is a function of the attached tasks and its allowed set of 
resources in comparison to them, not the limit itself.

> > If that tasks leaks memory or becomes 
> > significantly large, for whatever reason, it could be killed, but we _can_ 
> > discount the 1G in comparison to other tasks as the "cost of doing 
> > business" when it comes to vital system tasks:
> > 
> > 	(memory usage) * (memory+swap limit / system memory)
> > 
> 
> yes. under 8G system, -250 will allow ingnoring 2G of usage.
> 

Yeah, that conversion could be useful if the system RAM capacity or memcg 
limit, etc, remains static.

> == How about this text ? ==
> 
> When you set a task's oom_score_adj, it can get priority not to be oom-killed.

And the reverse, it can get priority to be killed :)

> oom_score_adj gives priority proportional to the memory limitation.
> 
> Assuming you set -250 to oom_score_adj.
> 
> Under 4G memory limit, it gets 25% of bonus...1G memory bonus for avoiding OOM.
> Under 8G memory limit, it gets 25% of bonus...2G memory bonus for avoiding OOM.
> 
> Then, what bonus a task can get depends on the context of OOM. If you use
> oom_score_adj and want to give bonus to a task, setting it in regard with
> minimum memory limitation which a task is under will work well.

Very nice, and the "bonus" there is what the task can safely use in 
comparison to any other task competing for the same resources without 
getting selected itself because of that memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
