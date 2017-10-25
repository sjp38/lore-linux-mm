Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 563826B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 07:09:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u97so5589453wrc.3
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 04:09:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f24si1608074edc.451.2017.10.25.04.09.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Oct 2017 04:09:56 -0700 (PDT)
Date: Wed, 25 Oct 2017 13:09:55 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH 2/2] mm,oom: Try last second allocation after
 selecting an OOM victim.
Message-ID: <20171025110955.jsc4lqjbg6ww5va6@dhcp22.suse.cz>
References: <20171020124009.joie5neol3gbdmxe@dhcp22.suse.cz>
 <201710202318.IJE26050.SFVFMOLHQJOOtF@I-love.SAKURA.ne.jp>
 <20171023113057.bdfte7ihtklhjbdy@dhcp22.suse.cz>
 <201710242024.EDH13579.VQLFtFFMOOHSOJ@I-love.SAKURA.ne.jp>
 <20171024114104.twg73jvyjevovkjm@dhcp22.suse.cz>
 <201710251948.EJH00500.MOOStFLFQOHFJV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710251948.EJH00500.MOOStFLFQOHFJV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: aarcange@redhat.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, mgorman@suse.de, oleg@redhat.com, vdavydov.dev@gmail.com, vbabka@suse.cz

On Wed 25-10-17 19:48:09, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > The OOM killer is the last hand break. At the time you hit the OOM
> > condition your system is usually hard to use anyway. And that is why I
> > do care to make this path deadlock free. I have mentioned multiple times
> > that I find real life triggers much more important than artificial DoS
> > like workloads which make your system unsuable long before you hit OOM
> > killer.
> 
> Unable to invoke the OOM killer (i.e. OOM lockup) is worse than hand break injury.
> 
> If you do care to make this path deadlock free, you had better stop depending on
> mutex_trylock(&oom_lock). Not only printk() from oom_kill_process() can trigger
> deadlock due to console_sem versus oom_lock dependency but also

And this means that we have to fix printk. Completely silent oom path is
out of question IMHO

> schedule_timeout_killable(1) from out_of_memory() can also trigger deadlock
> due to SCHED_IDLE versus !SCHED_IDLE dependency (like I suggested at 
> http://lkml.kernel.org/r/201603031941.CBC81272.OtLMSFVOFJHOFQ@I-love.SAKURA.ne.jp ).

You are still missing the point here. You do not really have to sleep to
get preempted by high priority task here. Moreover sleep is done after
we have killed the victim and the reaper can already start tearing down
the memory. If you oversubscribe your system by high priority tasks you
are screwed no matter what.
 
> > > Current code is somehow easier to OOM lockup due to printk() versus oom_lock
> > > dependency, and I'm proposing a patch for mitigating printk() versus oom_lock
> > > dependency using oom_printk_lock because I can hardly examine OOM related
> > > problems since linux-4.9, and your response was "Hell no!".
> > 
> > Because you are repeatedly proposing a paper over rather than to attempt
> > something resembling a solution. And this is highly annoying. I've
> > already said that I am willing to sacrifice the stall warning rather
> > than fiddle with random locks put here and there.
> 
> I've already said that I do welcome removing the stall warning if it is
> replaced with a better approach. If there is no acceptable alternative now,
> I do want to avoid "warn_alloc() without oom_lock held" versus
> "oom_kill_process() with oom_lock held" dependency. And I'm waiting for your
> answer in that thread.

I have already responded. Nagging me further doesn't help.

[...]
> Despite you have said
> 
>   So let's agree to disagree about importance of the reliability
>   warn_alloc. I see it as an improvement which doesn't really have to be
>   perfect.

And I stand by this statement.

> at https://patchwork.kernel.org/patch/9381891/ , can we agree with killing
> the synchronous allocation stall warning messages and start seeking for
> asynchronous approach?

I've already said that I will not oppose removing it if regular
workloads are tripping over it. Johannes had some real world examples
AFAIR but didn't provide any details which we could use for the
changelog. I wouldn't be entirely happy about that but the reality says
that the printk infrastructure is not really prepared for extreme loads.
 
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3868,8 +3868,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	enum compact_result compact_result;
>  	int compaction_retries;
>  	int no_progress_loops;
> -	unsigned long alloc_start = jiffies;
> -	unsigned int stall_timeout = 10 * HZ;
>  	unsigned int cpuset_mems_cookie;
>  	int reserve_flags;
>  
> @@ -4001,14 +3999,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  	if (!can_direct_reclaim)
>  		goto nopage;
>  
> -	/* Make sure we know about allocations which stall for too long */
> -	if (time_after(jiffies, alloc_start + stall_timeout)) {
> -		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
> -			"page allocation stalls for %ums, order:%u",
> -			jiffies_to_msecs(jiffies-alloc_start), order);
> -		stall_timeout += 10 * HZ;
> -	}
> -
>  	/* Avoid recursion of direct reclaim */
>  	if (current->flags & PF_MEMALLOC)
>  		goto nopage;
> -- 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
