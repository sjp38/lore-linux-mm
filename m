Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id BB7036B026D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 04:11:03 -0500 (EST)
Received: by wmdw130 with SMTP id w130so189371519wmd.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 01:11:03 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id n206si39360263wma.29.2015.11.18.01.11.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 01:11:02 -0800 (PST)
Received: by wmww144 with SMTP id w144so187988707wmw.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 01:11:02 -0800 (PST)
Date: Wed, 18 Nov 2015 10:11:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: do not loop over ALLOC_NO_WATERMARKS without
 triggering reclaim
Message-ID: <20151118091101.GA19145@dhcp22.suse.cz>
References: <1447680139-16484-1-git-send-email-mhocko@kernel.org>
 <1447680139-16484-3-git-send-email-mhocko@kernel.org>
 <564B0841.6030409@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <564B0841.6030409@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 17-11-15 19:58:09, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > __alloc_pages_slowpath is looping over ALLOC_NO_WATERMARKS requests if
> > __GFP_NOFAIL is requested. This is fragile because we are basically
> > relying on somebody else to make the reclaim (be it the direct reclaim
> > or OOM killer) for us. The caller might be holding resources (e.g.
> > locks) which block other other reclaimers from making any progress for
> > example. Remove the retry loop and rely on __alloc_pages_slowpath to
> > invoke all allowed reclaim steps and retry logic.
> 
> This implies invoking OOM killer, doesn't it?

It does and the changelog is explicit about this.

> >   	/* Avoid recursion of direct reclaim */
> > -	if (current->flags & PF_MEMALLOC)
> > +	if (current->flags & PF_MEMALLOC) {
> > +		/*
> > +		 * __GFP_NOFAIL request from this context is rather bizarre
> > +		 * because we cannot reclaim anything and only can loop waiting
> > +		 * for somebody to do a work for us.
> > +		 */
> > +		if (WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> > +			cond_resched();
> > +			goto retry;
> 
> I think that this "goto retry;" omits call to out_of_memory() which is allowed
> for __GFP_NOFAIL allocations. 

It wasn't called for PF_MEMALLOC requests though. Whether invoking OOM
killer is a good idea for this case is a harder question and out of
scope of this patch.

> Even if this is what you meant, current thread
> can be a workqueue, which currently need a short sleep (as with
> wait_iff_congested() changes), can't it?

As the changelog tries to clarify PF_MEMALLOC with __GFP_NOFAIL is
basically a bug. That is the reason I am adding WARN_ON there. I do not
think making this code more complex for abusers/buggy code is really
worthwhile. Besides that I fail to see why a work item would ever
want to set PF_MEMALLOC for legitimate reasons. I have done a quick git
grep over the tree and there doesn't seem to be any user.

> 
> > +		}
> >   		goto nopage;
> > +	}
> >   
> >   	/* Avoid allocations with no watermarks from looping endlessly */
> >   	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> > 
> 
> Well, is it cond_resched() which should include
> 
>   if (current->flags & PF_WQ_WORKER)
>   	schedule_timeout(1);

I believe you are getting off-topic here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
