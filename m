Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 12B24600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 20:24:07 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id o730RKAM002150
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 17:27:20 -0700
Received: from pwi2 (pwi2.prod.google.com [10.241.219.2])
	by hpaq14.eem.corp.google.com with ESMTP id o730RHdL008673
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 17:27:18 -0700
Received: by pwi2 with SMTP id 2so1443060pwi.18
        for <linux-mm@kvack.org>; Mon, 02 Aug 2010 17:27:17 -0700 (PDT)
Date: Mon, 2 Aug 2010 17:27:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
In-Reply-To: <20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008021713310.9569@chino.kir.corp.google.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com> <20100729183809.ca4ed8be.akpm@linux-foundation.org> <20100730195338.4AF6.A69D9226@jp.fujitsu.com> <20100802134312.c0f48615.akpm@linux-foundation.org>
 <20100803090058.48c0a0c9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010, KAMEZAWA Hiroyuki wrote:

> One reason I poitned out is that this new parameter is hard to use for admins and
> library writers. 
>   old oom_adj was defined as an parameter works as 
> 		(memory usage of app)/oom_adj.

Where are you getting this definition from?

Disregarding all the other small adjustments in the old heuristic, a 
reduced version of the formula was mm->total_vm << oom_adj.  It's a 
shift, not a divide.  That has no sensible meaning.

>   new oom_score_adj was define as
> 		(memory usage of app * oom_score_adj)/ system_memory
> 

No, it's (rss + swap + oom_score_adj) / bound memory.  It's an addition, 
not a multiplication, and it's a proportion of memory the application is 
bound to, not the entire system (it could be constrained by cpuset, 
mempolicy, or memcg).

> Then, an applications' oom_score on a host is quite different from on the other
> host. This operation is very new rather than a simple interface updates.
> This opinion was rejected.
> 

It wasn't rejected, I responded to your comment and you never wrote back.  
The idea 

> Anyway, I believe the value other than OOM_DISABLE is useless,

You're right in that OOM_DISABLE fulfills may typical use cases to simply 
protect a task by making it immune to the oom killer.  But there are other 
use cases for the oom killer that you're perhaps not using where a 
sensible userspace tunable does make a difference: the goal of the 
heuristic is always to kill the task consuming the most amount of memory 
to avoid killing tons of applications for subsequent page allocations.  We 
do run important tasks that consume lots of memory, though, and the kernel 
can't possibly know about that importance.  So although you may never use 
a positive oom_score_adj, although others will, you probably can find a 
use case for subtracting a memory quantity from a known memory hogging 
task that you consider to be vital in an effort to disregard that quantity 
from the score.  I'm sure you'll agree it's a much more powerful (and 
fine-grained) interface than oom_adj.

> I have no concerns. I'll use memcg if I want to control this kind of things.
> 

That would work if you want to setup individual memcgs for every 
application on your system, know what sane limits are for each one, and 
want to incur the significant memory expense of enabling 
CONFIG_CGROUP_MEM_RES_CTLR for its metadata.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
