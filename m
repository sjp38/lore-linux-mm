Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED4F6B03B4
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:18:05 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u89so35478316wrc.1
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 07:18:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f45si16009302wrf.145.2017.07.27.07.18.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 07:18:04 -0700 (PDT)
Date: Thu, 27 Jul 2017 16:18:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: replace TIF_MEMDIE checks by tsk_is_oom_victim
Message-ID: <20170727141801.GA31031@dhcp22.suse.cz>
References: <20170727090357.3205-1-mhocko@kernel.org>
 <20170727090357.3205-3-mhocko@kernel.org>
 <201707272301.EII82876.tOOJOFLMHFQSFV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707272301.EII82876.tOOJOFLMHFQSFV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 27-07-17 23:01:05, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 544d47e5cbbd..86a48affb938 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1896,7 +1896,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >  	 * bypass the last charges so that they can exit quickly and
> >  	 * free their memory.
> >  	 */
> > -	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
> > +	if (unlikely(tsk_is_oom_victim(current) ||
> >  		     fatal_signal_pending(current) ||
> >  		     current->flags & PF_EXITING))
> >  		goto force;
> 
> Did we check http://lkml.kernel.org/r/20160909140508.GO4844@dhcp22.suse.cz ?

I will double check.

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index c9f3569a76c7..65cc2f9aaa05 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -483,7 +483,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
> >  	 *				[...]
> >  	 *				out_of_memory
> >  	 *				  select_bad_process
> > -	 *				    # no TIF_MEMDIE task selects new victim
> > +	 *				    # no TIF_MEMDIE, selects new victim
> >  	 *  unmap_page_range # frees some memory
> >  	 */
> >  	mutex_lock(&oom_lock);
> 
> This comment is wrong. No MMF_OOM_SKIP mm selects new victim.

This hunk shouldn't make it to the patch.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
