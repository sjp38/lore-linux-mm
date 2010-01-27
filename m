Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 110816B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 18:40:28 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o0RNekZH011903
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 23:40:46 GMT
Received: from pwj17 (pwj17.prod.google.com [10.241.219.81])
	by wpaz29.hot.corp.google.com with ESMTP id o0RNeFcJ023769
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 15:40:44 -0800
Received: by pwj17 with SMTP id 17so70441pwj.39
        for <linux-mm@kvack.org>; Wed, 27 Jan 2010 15:40:44 -0800 (PST)
Date: Wed, 27 Jan 2010 15:40:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
In-Reply-To: <20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1001271511120.4663@chino.kir.corp.google.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com> <20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com> <20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, minchan.kim@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jan 2010, KAMEZAWA Hiroyuki wrote:

> Default oom-killer uses badness calculation based on process's vm_size
> and some amounts of heuristics. Some users see proc->oom_score and
> proc->oom_adj to control oom-killed tendency under their server.
> 
> Now, we know oom-killer don't work ideally in some situaion, in PCs. Some
> enhancements are demanded. But such enhancements for oom-killer makes
> incomaptibility to oom-controls in enterprise world. So, this patch
> adds sysctl for extensions for oom-killer. Main purpose is for
> making a chance for wider test for new scheme.
> 

That's insufficient for inclusion in mainline, we don't add new sysctls so 
that new heuristics can be tried out.  It's fine to propose a new sysctl 
to define how the oom killer behaves, but the main purpose would not be 
for testing; rather, it would be to enable options that users within the 
minority would want to use.

I disagree that we should be doing this as a bitmask that defines certain 
oom killer options; we already have three seperate sysctls which also 
enable options: panic_on_oom, oom_kill_allocating_task, and 
oom_dump_tasks.  Either these existing sysctls need to be converted to the 
bitmask, breaking the long-standing legacy support, or you simply need to 
clutter procfs a little more.  I'm slightly biased toward the latter since 
it doesn't require any userspace change and tunables such as panic_on_oom 
have been around for a long time.

 [ Note: it may be possible to consolidate two of these existing sysctls
   down into one: oom_dump_tasks can be enabled by default if the tasklist
   is sufficiently short and the only use-case for oom_kill_allocating_task
   is for machines with enormously long tasklists to prevent unnecessary
   delays in selecting a bad process to kill.  Thus, we could probably
   consolidate these into one sysctl: oom_kill_quick, which would disable
   the tasklist dump and always kill current when invoked. ]

> One cause of OOM-Killer is memory shortage in lower zones.
> (If memory is enough, lowmem_reserve_ratio works well. but..)

I don't understand the reference to lowmem_reserve_ratio here, it may 
reserve lowmem from ~GFP_DMA requests but it does nothing to prevent oom 
conditions from excessive DMA page allocations.

> I saw lowmem-oom frequently on x86-32 and sometimes on ia64 in
> my cusotmer support jobs. If we just see process's vm_size at oom,
> we can never kill a process which has lowmem.

That's not always true, it may end up killing a large consumer of DMA 
memory by chance simply because the heuristics work out that way.  In 
other words, we can't say it will "never" work correctly as it is 
currently implemented.  I agree we can make it smarter, however.

> At last, there will be an oom-serial-killer.
> 

Heh.

> Now, we have per-mm lowmem usage counter. We can make use of it
> to select a good victim.
> 
> This patch does
>   - add sysctl for new bahavior.
>   - add CONSTRAINT_LOWMEM to oom's constraint type.
>   - pass constraint to __badness()

You mean badness()?  Passing the constraint works well for my 
CONSTRAINT_MEMPOLICY patch as well.

>   - change calculation based on constraint. If CONSTRAINT_LOWMEM,
>     use low_rss instead of vmsize.
> 

Nack, we can't simply use the lowmem rss as a baseline because 
/proc/pid/oom_adj, the single most powerful heuristic in badness(), is not 
defined for these dual scenarios.  There may only be a single baseline to 
define for oom_adj, otherwise it will have erradic results depending on 
the context in which the oom killer is called.  It can be used to polarize 
the heuristic depending on the total VM size which may be disadvantageous 
when using lowmem rss as the baseline.

I think the best alternative would be to strongly penalize the badness() 
points for tasks that do not have a lowmem rss when we are constrained by 
CONSTRAINT_LOWMEM, similar to how we penalize tasks not sharing current's 
mems_allowed since it (usually) doesn't help.  We do not necessarily 
always want to kill the task that is consuming the most lowmem for a 
single page allocation; we need to decide how valuable lowmem is in 
relation to overall VM size, however.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
