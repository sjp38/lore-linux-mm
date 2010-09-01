Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 574B56B004D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 18:06:29 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o81M6RUF008285
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 15:06:27 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz21.hot.corp.google.com with ESMTP id o81M63Tr029551
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 15:06:26 -0700
Received: by pzk33 with SMTP id 33so3636248pzk.14
        for <linux-mm@kvack.org>; Wed, 01 Sep 2010 15:06:25 -0700 (PDT)
Date: Wed, 1 Sep 2010 15:06:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2][BUGFIX] oom: remove totalpage normalization from
 oom_badness()
In-Reply-To: <20100830113007.525A.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009011436390.29305@chino.kir.corp.google.com>
References: <20100825184001.F3EF.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1008250300500.13300@chino.kir.corp.google.com> <20100830113007.525A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Aug 2010, KOSAKI Motohiro wrote:

> > > Current oom_score_adj is completely broken because It is strongly bound
> > > google usecase and ignore other all.
> > > 
> > 
> > That's wrong, we don't even use this heuristic yet and there is nothing, 
> > in any way, that is specific to Google.
> 
> Please show us an evidence. Big mouth is no good way to persuade us.

Evidence that Google isn't using this currently?

> I requested you "COMMUNICATE REAL WORLD USER", do you really realized this?
> 

We are certainly looking forward to using this when 2.6.36 is released 
since we work with both cpusets and memcg.

> > > 1) Priority inversion
> > >    As kamezawa-san pointed out, This break cgroup and lxr environment.
> > >    He said,
> > > 	> Assume 2 proceses A, B which has oom_score_adj of 300 and 0
> > > 	> And A uses 200M, B uses 1G of memory under 4G system
> > > 	>
> > > 	> Under the system.
> > > 	> 	A's socre = (200M *1000)/4G + 300 = 350
> > > 	> 	B's score = (1G * 1000)/4G = 250.
> > > 	>
> > > 	> In the cpuset, it has 2G of memory.
> > > 	> 	A's score = (200M * 1000)/2G + 300 = 400
> > > 	> 	B's socre = (1G * 1000)/2G = 500
> > > 	>
> > > 	> This priority-inversion don't happen in current system.
> > > 
> > 
> > You continually bring this up, and I've answered it three times, but 
> > you've never responded to it before and completely ignore it.  
> 
> Yes, I ignored. Don't talk your dream. I hope to see concrete use-case.
> As I repeatedly said, I don't care you while you ignore real world end user.
> ANY BODY DON'T EXCEPT STABILIZATION DEVELOPERS ARE KINDFUL FOR END USER
> HARMFUL. WE HAVE NO MERCY WHILE YOU CONTINUE TO INMORAL DEVELOPMENT.
> 

I'm not ignoring any user with this change, oom_score_adj is an extremely 
powerful interface for users who want to use it.  I'm sorry that it's not 
as simple to use as you may like.

Basically, it comes down to this: few users actually tune their oom 
killing priority, period.  That's partly because they accept the oom 
killer's heuristics to kill a memory-hogging task or use panic_on_oom, or 
because the old interface, /proc/pid/oom_adj, had no unit and no logical 
way of using it other than polarizing it (either +15 or -17).

For those users who do change their oom killing priority, few are using 
cpusets or memcg.  Yes, the priority changes depending on the context of 
the oom, but for users who don't use these cgroups the oom_score_adj unit 
is static since the amount of system memory (the only oom constraint) is 
static.

Now, for the users of both oom_score_adj and cpusets or memcg (in the 
future this will include Google), these users are interested in oom 
killing priority relative to other tasks attached to the same set of 
resources.  For our particular use case, we attach an aggregate of tasks 
to a cgroup and have a preference on the order in which those tasks are 
killed whenever that cgroup limit is exhausted.  We also care about 
protecting vital system tasks so that they aren't targeted before others 
are killed, such as job schedulers.

I think the key point your missing in our use case is that we don't 
necessary care about the system-wide oom condition when we're running with 
cpusets or memcg.  We can protect tasks with negative oom_score_adj, but 
we don't care about close tiebreakers on which cpuset or memg is penalized 
when the entire system is out of memory.  If that's the case, each cpuset 
and memcg is also, by definition, out of memory, so they are all subject 
to the oom killer.  This is equivalent to having several tasks with an 
oom_score_adj of +1000 (or oom_adj of +15) and only one getting killed 
based on the order of the tasklist.

So there is actually no "bug" or "regression" in this behavior (especially 
since the old oom killer had inversion as well because it factored cpuset 
placement into the heuristic score) and describing it as such is 
misleading.  It's actually a very powerful interface for those who choose 
to use it and accurately reflect the way the oom killer chooses tasks: 
relative to other eligible tasks competing for the same set of resources.

> > I don't know what this means, and this was your criticism before I changed 
> > the denominator during the revision of the patchset, so it's probably 
> > obsoleted.  oom_score_adj always operates based on the proportion of 
> > memory available to the application which is how the new oom killer 
> > determines which tasks to kill: relative to the importance (if defined by 
> > userspace) and memory usage compared to other tasks competing for it.
> 
> I already explained asymmetric numa issue in past. again, don't assuem
> you policy and your machine if you want to change kernel core code.
> 

Please explain it again, I don't see what the asymmetry in NUMA node size 
has to do with either mempolicy or cpuset ooms.  The administrator is 
fully aware of the sizes of these nodes at the time he or she attaches 
them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
