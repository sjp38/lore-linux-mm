Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1816B0038
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:03:57 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id a194so247016774oib.5
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 06:03:57 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h20si8991614oib.88.2017.01.25.06.03.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 06:03:56 -0800 (PST)
Subject: Re: [PATCH v6] mm: Add memory allocation watchdog kernel thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<201612151924.HJJ69799.VSFLHOQFFMOtOJ@I-love.SAKURA.ne.jp>
	<201612282042.GDB17129.tOHFOFSQOFLVJM@I-love.SAKURA.ne.jp>
In-Reply-To: <201612282042.GDB17129.tOHFOFSQOFLVJM@I-love.SAKURA.ne.jp>
Message-Id: <201701252303.FCI17866.FOJFHMtSQOFVLO@I-love.SAKURA.ne.jp>
Date: Wed, 25 Jan 2017 23:03:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, hannes@cmpxchg.org, vdavydov.dev@gmail.com, mhocko@suse.cz, pmladek@suse.com, sergey.senozhatsky.work@gmail.com, vegard.nossum@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Andrew, what do you think about this version? There seems to be no objections.

This patch should be helpful for initial research of minutes-lasting stalls (e.g.
http://lkml.kernel.org/r/20170123135111.13ac3e47110de10a4bd503ef@linux-foundation.org )
and proving whether what Michal does not think are not happening
(e.g. http://lkml.kernel.org/r/20170125095337.GF32377@dhcp22.suse.cz ).
I think we can start testing this version at linux-next tree.

Tetsuo Handa wrote:
> Michal Hocko wrote at http://lkml.kernel.org/r/20161227105715.GE1308@dhcp22.suse.cz :
> > On Tue 27-12-16 19:39:28, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > I am not saying that the current code works perfectly when we are
> > > > hitting the direct reclaim close to the OOM but improving that requires
> > > > much more than slapping a global lock there.
> > > 
> > > So, we finally agreed that there are problems when we are hitting the direct
> > > reclaim close to the OOM. Good.
> > 
> > There has never been a disagreement here. The point we seem to be
> > disagreeing is how much those issues you are seeing matter. I do not
> > consider them top priority because they are not happening in real life
> > enough.
> 
> There is no evidence to prove "they are not happening in real life enough", for
> there is no catch-all reporting mechanism. I consider that offering a mean to
> find and report problems is top priority as a troubleshooting staff.
> 
> > > > Just try to remember how you were pushing really hard for oom timeouts
> > > > one year back because the OOM killer was suboptimal and could lockup. It
> > > > took some redesign and many changes to fix that. The result is
> > > > imho a better, more predictable and robust code which wouldn't be the
> > > > case if we just went your way to have a fix quickly...
> > > 
> > > I agree that the result is good for users who can update kernels. But that
> > > change was too large to backport. Any approach which did not in time for
> > > customers' deadline of deciding their kernels to use for 10 years is
> > > useless for them. Lack of catch-all reporting/triggering mechanism is
> > > unhappy for both customers and troubleshooting staffs at support centers.
> > 
> > Then implement whatever you find appropriate on those old kernels and
> > deal with the follow up reports. This is the fair deal you have cope
> > with when using and supporting old kernels.
> 
> Customers are using distributor's kernels. Due to out-of-tree vendor's prebuilt
> modules which can be loaded into only prebuilt distributor's kernels, it is
> impossible for me to make changes to those old kernels. Also, that distributor's
> policy is that "offer no support even if just rebuilt from source" which prevents
> customers from testing changes made by me to those old kernels. Thus, implement
> whatever I find appropriate on those old kernels is not an option. Merging
> upstream-first, in accordance with that distributor's policy, is the only option.
> 
> >  
> > > Improving the direct reclaim close to the OOM requires a lot of effort.
> > > We might add new bugs during that effort. So, where is valid reason that
> > > we can not have asynchronous watchdog like kmallocwd? Please do explain
> > > at kmallocwd thread. You have never persuaded me about keeping kmallocwd
> > > out of tree.
> > 
> > I am not going to repeat my arguments over again. I haven't nacked that
> > patch and it seems there is no great interest in it so do not try to
> > claim that it is me who is blocking this feature. I just do not think it
> > is worth it.
> 
> OK. I was assuming that Acked-by: or Reviewed-by: from you is essential.
> 
> So far, nobody has objections about having asynchronous watchdog.
> Mel, Johannes and Vladimir, what do you think about this version of
> kmallocwd? If no objections, I think we can start with this version
> with a fix shown below folded.
> 
> ----------------------------------------
> >From 5adc8d9bfb31dce1954667cabf65842df31d4ed7 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 28 Dec 2016 09:52:03 +0900
> Subject: [PATCH] mm: Don't check __GFP_KSWAPD_RECLAIM by memory allocation
>  watchdog.
> 
> There are some __GFP_KSWAPD_RECLAIM && !__GFP_DIRECT_RECLAIM callers.
> Since such callers do not sleep, we should check only __GFP_DIRECT_RECLAIM
> callers than __GFP_RECLAIM == (__GFP_KSWAPD_RECLAIM|__GFP_DIRECT_RECLAIM)
> callers.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/page_alloc.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6478f44..58c1238 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3769,10 +3769,10 @@ static void start_memalloc_timer(const gfp_t gfp_mask, const int order)
>  {
>  	struct memalloc_info *m = &current->memalloc;
>  
> -	/* We don't check for stalls for !__GFP_RECLAIM allocations. */
> -	if (!(gfp_mask & __GFP_RECLAIM))
> +	/* We don't check for stalls for !__GFP_DIRECT_RECLAIM allocations. */
> +	if (!(gfp_mask & __GFP_DIRECT_RECLAIM))
>  		return;
> -	/* We don't check for stalls for nested __GFP_RECLAIM allocations */
> +	/* Check based on outermost __GFP_DIRECT_RECLAIM allocations. */
>  	if (!m->valid) {
>  		m->sequence++;
>  		m->start = jiffies;
> @@ -3788,7 +3788,7 @@ static void stop_memalloc_timer(const gfp_t gfp_mask)
>  {
>  	struct memalloc_info *m = &current->memalloc;
>  
> -	if ((gfp_mask & __GFP_RECLAIM) && !--m->valid)
> +	if ((gfp_mask & __GFP_DIRECT_RECLAIM) && !--m->valid)
>  		this_cpu_dec(memalloc_in_flight[m->idx]);
>  }
>  #else
> -- 
> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
