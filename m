Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DCCCE6B0069
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 03:56:28 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id z3so379076wme.2
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 00:56:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 48si405433edz.287.2017.11.15.00.56.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Nov 2017 00:56:27 -0800 (PST)
Date: Wed, 15 Nov 2017 09:56:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171115085625.afvw333csgypbk24@dhcp22.suse.cz>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171115005602.GB23810@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115005602.GB23810@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 15-11-17 09:56:02, Minchan Kim wrote:
> On Tue, Nov 14, 2017 at 06:37:42AM +0900, Tetsuo Handa wrote:
> > When shrinker_rwsem was introduced, it was assumed that
> > register_shrinker()/unregister_shrinker() are really unlikely paths
> > which are called during initialization and tear down. But nowadays,
> > register_shrinker()/unregister_shrinker() might be called regularly.
> > This patch prepares for allowing parallel registration/unregistration
> > of shrinkers.
> > 
> > Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
> > using one RCU section. But using atomic_inc()/atomic_dec() for each
> > do_shrink_slab() call will not impact so much.
> > 
> > This patch uses polling loop with short sleep for unregister_shrinker()
> > rather than wait_on_atomic_t(), for we can save reader's cost (plain
> > atomic_dec() compared to atomic_dec_and_test()), we can expect that
> > do_shrink_slab() of unregistering shrinker likely returns shortly, and
> > we can avoid khungtaskd warnings when do_shrink_slab() of unregistering
> > shrinker unexpectedly took so long.
> > 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> Before reviewing this patch, can't we solve the problem with more
> simple way? Like this.
> 
> Shakeel, What do you think?
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 13d711dd8776..cbb624cb9baa 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -498,6 +498,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  			sc.nid = 0;
>  
>  		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
> +		/*
> +		 * bail out if someone want to register a new shrinker to prevent
> +		 * long time stall by parallel ongoing shrinking.
> +		 */
> +		if (rwsem_is_contended(&shrinker_rwsem)) {
> +			freed = 1;
> +			break;
> +		}

So you want to do only partial slab shrinking if we have more contending
direct reclaimers? This would just make a larger pressure on those on
the list head rather than the tail. I do not think this is a good idea.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
