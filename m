Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 698ED6B027F
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 11:09:13 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id d66so8303139ioe.23
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 08:09:13 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t69si792054ioe.112.2017.11.01.08.09.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 08:09:12 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm,oom: Use ALLOC_OOM for OOM victim's last second allocation.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1509537268-4726-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1509537268-4726-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171101135855.bqg2kuj6ao2cicqi@dhcp22.suse.cz>
In-Reply-To: <20171101135855.bqg2kuj6ao2cicqi@dhcp22.suse.cz>
Message-Id: <201711020008.EHB87824.QFFOJMLOHVFSOt@I-love.SAKURA.ne.jp>
Date: Thu, 2 Nov 2017 00:08:59 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov@virtuozzo.com

Michal Hocko wrote:
> On Wed 01-11-17 20:54:28, Tetsuo Handa wrote:
> > Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> > oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
> > to return false as soon as MMF_OOM_SKIP is set, many threads sharing the
> > victim's mm were not able to try allocation from memory reserves after the
> > OOM reaper gave up reclaiming memory.
> > 
> > Until Linux 4.7, we were using
> > 
> >   if (current->mm &&
> >       (fatal_signal_pending(current) || task_will_free_mem(current)))
> > 
> > as a condition to try allocation from memory reserves with the risk of OOM
> > lockup, but reports like [1] were impossible. Linux 4.8+ are regressed
> > compared to Linux 4.7 due to the risk of needlessly selecting more OOM
> > victims.
> 
> So what you are essentially saying is that there is a race window
> Proc1					Proc2				oom_reaper
> __alloc_pages_slowpath			out_of_memory
>   __gfp_pfmemalloc_flags		  select_bad_process # Proc1
> [1]  oom_reserves_allowed # false	  oom_kill_process
>     									  oom_reap_task
>   __alloc_pages_may_oom							    __oom_reap_task_mm
>   									      # doesn't unmap anything
>       									    set_bit(MMF_OOM_SKIP)
>     out_of_memory
>       task_will_free_mem
> [2]     MMF_OOM_SKIP check # true
>       select_bad_process # Another victim
> 
> mostly because the above is an artificial workload which triggers the
> pathological path where nothing is really unmapped due to mlocked
> memory,

Right.

>         which makes the race window (1-2) smaller than it usually is.

The race window (1-2) was larger than __oom_reap_task_mm() usually takes.

>                                                                       So
> this is pretty much a corner case which we want to address by making
> mlocked pages really reapable. Trying to use memory reserves for the
> oom victims reduces changes of the race.

Right. We cannot prevent non OOM victims from calling oom_kill_process().
But preventing existing OOM victims from calling oom_kill_process() (by
allowing them to try ALLOC_OOM allocation) can reduce subsequent OOM victims.

> 
> This would be really useful to have in the changelog IMHO.
> 
> > There is no need that the OOM victim is such malicious that consumes all
> > memory. It is possible that a multithreaded but non memory hog process is
> > selected by the OOM killer, and the OOM reaper fails to reclaim memory due
> > to e.g. khugepaged [2], and the process fails to try allocation from memory
> > reserves.
> 
> I am not sure about this part though. If the oom_reaper cannot take the
> mmap_sem then it retries for 1s. Have you ever seen the race to be that
> large?

Like shown in [2], khugepaged can prevent oom_reaper from taking the mmap_sem
for 1 second. Also, it won't be impossible for OOM victims to spend 1 second
between post __gfp_pfmemalloc_flags(gfp_mask) and pre mutex_trylock(&oom_lock)
(in other words, the race window (1-2) above). Therefore, non artificial
workloads could hit the same result.

> 
> > Therefore, this patch allows OOM victims to use ALLOC_OOM watermark
> > for last second allocation attempt.
> > 
> > [1] http://lkml.kernel.org/r/e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com
> > [2] http://lkml.kernel.org/r/201708090835.ICI69305.VFFOLMHOStJOQF@I-love.SAKURA.ne.jp
> > 
> > Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
> > Reported-by: Manish Jaggi <mjaggi@caviumnetworks.com>
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Oleg Nesterov <oleg@redhat.com>
> > Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> > Cc: David Rientjes <rientjes@google.com>
> > ---
> >  mm/page_alloc.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 6654f52..382ed57 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4112,9 +4112,14 @@ struct page *alloc_pages_before_oomkill(const struct oom_control *oc)
> >  	 * we're still under heavy pressure. But make sure that this reclaim
> >  	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
> >  	 * allocation which will never fail due to oom_lock already held.
> > +	 * Also, make sure that OOM victims can try ALLOC_OOM watermark in case
> > +	 * they haven't tried ALLOC_OOM watermark.
> >  	 */
> >  	return get_page_from_freelist((oc->gfp_mask | __GFP_HARDWALL) &
> >  				      ~__GFP_DIRECT_RECLAIM, oc->order,
> > +				      oom_reserves_allowed(current) &&
> > +				      !(oc->gfp_mask & __GFP_NOMEMALLOC) ?
> > +				      ALLOC_OOM :
> >  				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, oc->ac);
> 
> This just makes my eyes bleed. Really, why don't you simply make this
> more readable.
> 
> 	int alloc_flags = ALLOC_CPUSET | ALLOC_WMARK_HIGH;
> 	gfp_t gfp_mask = oc->gfp_mask | __GFP_HARDWALL;
> 	int reserves
> 
> 	gfp_mask &= ~__GFP_DIRECT_RECLAIM;
> 	reserves = __gfp_pfmemalloc_flags(gfp_mask);
> 	if (reserves)
> 		alloc_flags = reserves;
> 

OK. I inlined __gfp_pfmemalloc_flags() because
alloc_pages_before_oomkill() is known to be schedulable context.

> >  }
> >  
> > -- 
> > 1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
