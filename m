Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CE6E26008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 03:17:49 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id o737Ncf0017573
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 00:23:38 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by hpaq6.eem.corp.google.com with ESMTP id o737NZFn007324
	for <linux-mm@kvack.org>; Tue, 3 Aug 2010 00:23:36 -0700
Received: by pva18 with SMTP id 18so2125803pva.23
        for <linux-mm@kvack.org>; Tue, 03 Aug 2010 00:23:35 -0700 (PDT)
Date: Tue, 3 Aug 2010 00:23:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
In-Reply-To: <20100803133255.deb5c208.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008030016590.20849@chino.kir.corp.google.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com> <20100729183809.ca4ed8be.akpm@linux-foundation.org> <20100730195338.4AF6.A69D9226@jp.fujitsu.com> <20100802134312.c0f48615.akpm@linux-foundation.org> <20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com> <20100803093610.f4d30ca7.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021742440.9569@chino.kir.corp.google.com> <20100803100815.11d10519.kamezawa.hiroyu@jp.fujitsu.com>
 <20100803102423.82415a17.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021850400.19184@chino.kir.corp.google.com> <20100803110534.e3e7a697.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008021953520.27231@chino.kir.corp.google.com>
 <20100803121146.cf35b7ed.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008022117200.4146@chino.kir.corp.google.com> <20100803133255.deb5c208.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010, KAMEZAWA Hiroyuki wrote:

> In old behavior, oom_score order is synchronous both in the system and
> container. High-score one will be killed.
> IOW, oom_score have worked as oom_score.
> 

This isn't necessarily true as I've already pointed out: the highest score 
as exported by /proc/pid/oom_score is not always killed if it's not a 
candidate task: it may be in a disjoint memcg, for example.  The highest 
_candidate_ task is killed, and that's unchanged with my rewrite.

The current /proc/pid/oom_score is also not synchronous between the system 
and container at least in the cpuset case since we currently divide a 
task's score by 8 if it doesn't intersect current's mems_allowed, so 
that's not true either.

> But, after the patch,  the user (of LXC at el.) can't trust oom_score. 

Yes, they can, but they need to know the context in which the oom occurs.  
/proc/pid/oom_score cannot export multiple values although its kill 
ranking actually depends on whether its a system oom, memcg oom, cpuset 
oom, etc.  It needs to export a single value as a function of the 
heuristic.  The user must then take those values at the time of 
collection and find how the various tasks rank relative to one another 
depending on MPOL_BIND, cpuset hierarchy, etc.  That's actually not that 
difficult because admins who don't use any cgroups typically only have 
system-wide ooms where oom_score is always accurate and admins who use 
cpusets or memcg or mempolicies on large NUMA systems already know the set 
of tasks that are attached to them and want to prioritize the killing list 
specifically for those entities.

> Especially with memcg, it just shows a _broken_ value.
> 

Not at all, the user knows what tasks are attached to the memcg and can 
easily determine which task is going to be killed when it ooms: simply 
iterate through the memcg tasklist, check /proc/pid/oom_score, and sort.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
