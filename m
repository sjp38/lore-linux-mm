Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8C43C82F64
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 04:36:15 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so21125055wic.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 01:36:15 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id dm8si23613487wjb.19.2015.10.23.01.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 01:36:14 -0700 (PDT)
Received: by wikq8 with SMTP id q8so66199935wik.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 01:36:14 -0700 (PDT)
Date: Fri, 23 Oct 2015 10:36:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for
 zone_reclaimable()checks
Message-ID: <20151023083612.GC2410@dhcp22.suse.cz>
References: <20151022151528.GG30579@mtj.duckdns.org>
 <20151022153559.GF26854@dhcp22.suse.cz>
 <20151022153703.GA3899@mtj.duckdns.org>
 <20151022154922.GG26854@dhcp22.suse.cz>
 <20151022184226.GA19289@mtj.duckdns.org>
 <201510230642.HDF57807.QJtSOVFFOMLHOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510230642.HDF57807.QJtSOVFFOMLHOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: htejun@gmail.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Fri 23-10-15 06:42:43, Tetsuo Handa wrote:
> Tejun Heo wrote:
> > On Thu, Oct 22, 2015 at 05:49:22PM +0200, Michal Hocko wrote:
> > > I am confused. What makes rescuer to not run? Nothing seems to be
> > > hogging CPUs, we are just out of workers which are loopin in the
> > > allocator but that is preemptible context.
> > 
> > It's concurrency management.  Workqueue thinks that the pool is making
> > positive forward progress and doesn't schedule anything else for
> > execution while that work item is burning cpu cycles.
> 
> Then, isn't below change easier to backport which will also alleviate
> needlessly burning CPU cycles?

This is quite obscure. If the vmstat_update fix needs workqueue tweaks
as well then I would vote for your original patch which is clear,
straightforward and easy to backport.

If WQ_MEM_RECLAIM can really guarantee one worker as described in the
documentation then I agree that fixing vmstat is a better fix. But that
doesn't seem to be the case currently.
 
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3385,6 +3385,7 @@ retry:
>  	((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
>  		/* Wait for some write requests to complete then retry */
>  		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
> +		schedule_timeout_uninterruptible(1);
>  		goto retry;
>  	}
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
