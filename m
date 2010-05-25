Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C50396008F1
	for <linux-mm@kvack.org>; Tue, 25 May 2010 05:42:26 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o4P9gMcA007887
	for <linux-mm@kvack.org>; Tue, 25 May 2010 02:42:22 -0700
Received: from pwj7 (pwj7.prod.google.com [10.241.219.71])
	by hpaq7.eem.corp.google.com with ESMTP id o4P9gJk3029759
	for <linux-mm@kvack.org>; Tue, 25 May 2010 02:42:21 -0700
Received: by pwj7 with SMTP id 7so837686pwj.4
        for <linux-mm@kvack.org>; Tue, 25 May 2010 02:42:19 -0700 (PDT)
Date: Tue, 25 May 2010 02:42:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oom killer rewrite
In-Reply-To: <20100520092717.0c3d8f3f.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1005250231460.8045@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com> <20100520092717.0c3d8f3f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 May 2010, KAMEZAWA Hiroyuki wrote:

> I've pointed out that "normalized" parameter doesn't seem to work well in some
> situaion (in cluster). I hope you'll have an extra interface as
> 
> 	echo 3G > /proc/<pid>/oom_indemification
> 
> to allow users have "absolute value" setting.
> (If the admin know usual memory usage of an application, we can only
>  add badness to extra memory usage.)
> 
> To be honest, I can't fully understand why we need _normalized_ parameter. Why
> oom_adj _which is now used_ is not enough for setting "relative importance" ?
> 

The only sane badness heuristic will be one that effectively compares all 
eligible tasks for oom kill in a way that are relative to one another; I'm 
concerned that a tunable that is based on a pure memory quantity requires 
specific knowledge of the system (or memcg, cpuset, etc) capacity before 
it is meaningful.  In other words, I opted to use a relative proportion so 
that when tasks are constrained to cpusets or memcgs or mempolicies they 
become part of a "virtualized system" where the proportion is then used in 
calculation of the total amount of system RAM, memcg limit, cpuset mems 
capacities, etc, without knowledge of what that value actually is.  So 
"echo 3G" may be valid in your example when not constrained to any cgroup 
or mempolicy but becomes invalid if I attach it to a cpuset with a single 
node of 1G capacity.  When oom_score_adj, we can specify the proportion 
"of the resources that the application has access to" in comparison to 
other applications that share those resources to determine oom killing 
priority.  I think that's a very powerful interface and your suggestion 
could easily be implemented in userspace with a simple divide, thus we 
don't need kernel support for it.

> And, IIRC, Nick pointed out that "don't remove _used_ interfaces just because
> you hate it or it seems not clean". So, I recommend you to drop sysctl changes.
> 

I addressed this in 
oom-reintroduce-and-deprecate-oom_kill_allocating_task.patch so that the 
end result was that only the oom_dump_tasks sysctl was removed because it 
was now enabled by default since it provides useful information about the 
state of the VM at the time of allocation failure.  So there's no longer 
any removal of "used" interfaces (the only previous use of oom_dump_tasks 
was to enable it, which is now the default).  Are you disagreeing with the 
deprecation of the sysctl since it was then folded into the new 
oom_dump_quick sysctl?

Regardless, I dropped all of these cleanups from my latest patch series 
which I'll post shortly, but keep in mind that what existed in -mm before 
it was dropped did not break any userspace API, it simply deprecated them 
for removal in two years.

> I think the whole concept of your patch series is good and I like it.

Thanks, Kame, for your continued interest in this work, it's encouraging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
