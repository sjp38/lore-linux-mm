Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 530896B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 10:02:36 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so25830239wib.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 07:02:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eu1si28802590wic.49.2015.08.05.07.02.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 07:02:34 -0700 (PDT)
Date: Wed, 5 Aug 2015 16:02:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 3/8] mm: page_alloc: do not lock up GFP_NOFS allocations
 upon OOM
Message-ID: <20150805140230.GF11176@dhcp22.suse.cz>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-4-git-send-email-mhocko@kernel.org>
 <201508052128.FIJ56269.QHSFOVFLOJOMFt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508052128.FIJ56269.QHSFOVFLOJOMFt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org

On Wed 05-08-15 21:28:39, Tetsuo Handa wrote:
> Reduced to only linux-mm.
> 
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > GFP_NOFS allocations are not allowed to invoke the OOM killer since
> > their reclaim abilities are severely diminished.  However, without the
> > OOM killer available there is no hope of progress once the reclaimable
> > pages have been exhausted.
> 
> Excuse me, but I still cannot understand. Why are !__GFP_FS allocations
> considered as "their reclaim abilities are severely diminished"?
> 
> It seems to me that not only GFP_NOFS allocation requests but also
> almost all types of memory allocation requests do not include
> __GFP_NO_KSWAPD flag.

__GFP_NO_KSWAPD is not to be used outside of very specific cases.

> Therefore, while a thread which called __alloc_pages_slowpath(GFP_NOFS)
> cannot reclaim FS memory, I assume that kswapd kernel threads which are
> woken up by the thread via wakeup_kswapd() via wake_all_kswapds() can
> reclaim FS memory by calling balance_pgdat(). Is this assumption correct?

yes.

> If the assumption is correct, when kswapd kernel threads returned from
> balance_pgdat() or got stuck inside reclaiming functions (e.g. blocked at
> mutex_lock() inside slab's shrinker functions), I think that the thread
> which called __alloc_pages_slowpath(GFP_NOFS) has reclaimed FS memory
> as if the thread called __alloc_pages_slowpath(GFP_KERNEL), and therefore
> the thread qualifies calling out_of_memory() as with __GFP_FS allocations.

You are missing an important point. We are talking about OOM situation
here. Which means that the background reclaim is not able to make
sufficient progress and neither is the direct reclaim. While the
GFP_IOFS requests are allowed to make a (V)FS activity which _might_
help GFP_NOFS is not by definition. And that is why this reclaim context
is less capable. Well to be more precise we do not perform IO (other
than the swapout) from the direct reclaim context because of the stack
restrictions so even GPF_IOFS is not _that_ strong but shrinkers are
still free to do metadata specific actions.
 
> > Don't risk hanging these allocations.  Leave it to the allocation site
> > to implement the fallback policy for failing allocations.
> 
> Are there memory pages which kswapd kernel threads cannot reclaim
> but __alloc_pages_slowpath(GFP_KERNEL) allocations can reclaim
> when __alloc_pages_slowpath(GFP_NOFS) allocations are hanging?

See above and have a look at the particular shrinkers code (e.g.
super_cache_scan).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
