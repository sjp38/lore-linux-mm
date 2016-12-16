Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D33B66B0260
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 17:12:05 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i131so11140187wmf.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 14:12:05 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id g66si5389401wmf.113.2016.12.16.14.12.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 14:12:04 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id he10so16107677wjc.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 14:12:04 -0800 (PST)
Date: Fri, 16 Dec 2016 23:12:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161216221202.GE7645@dhcp22.suse.cz>
References: <20161216073941.GA26976@dhcp22.suse.cz>
 <20161216155808.12809-1-mhocko@kernel.org>
 <20161216155808.12809-3-mhocko@kernel.org>
 <20161216173151.GA23182@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216173151.GA23182@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nils Holland <nholland@tisys.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Fri 16-12-16 12:31:51, Johannes Weiner wrote:
> On Fri, Dec 16, 2016 at 04:58:08PM +0100, Michal Hocko wrote:
> > @@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
> >  	 * make sure exclude 0 mask - all other users should have at least
> >  	 * ___GFP_DIRECT_RECLAIM to get here.
> >  	 */
> > -	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
> > +	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
> >  		return true;
> 
> This makes sense, we should go back to what we had here. Because it's
> not that the reported OOMs are premature - there is genuinely no more
> memory reclaimable from the allocating context - but that this class
> of allocations should never invoke the OOM killer in the first place.

agreed, at least not with the current implementtion. If we had a proper
accounting where we know that the memory pinned by the fs is not really
there then we could invoke the oom killer and be safe

> > @@ -3737,6 +3752,16 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  		 */
> >  		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
> >  
> > +		/*
> > +		 * Help non-failing allocations by giving them access to memory
> > +		 * reserves but do not use ALLOC_NO_WATERMARKS because this
> > +		 * could deplete whole memory reserves which would just make
> > +		 * the situation worse
> > +		 */
> > +		page = __alloc_pages_cpuset_fallback(gfp_mask, order, ALLOC_HARDER, ac);
> > +		if (page)
> > +			goto got_pg;
> > +
> 
> But this should be a separate patch, IMO.
> 
> Do we observe GFP_NOFS lockups when we don't do this? 

this is hard to tell but considering users like grow_dev_page we can get
stuck with a very slow progress I believe. Those allocations could see
some help.

> Don't we risk
> premature exhaustion of the memory reserves, and it's better to wait
> for other reclaimers to make some progress instead?

waiting for other reclaimers would be preferable but we should at least
give these some priority, which is what ALLOC_HARDER should help with.

> Should we give
> reserve access to all GFP_NOFS allocations, or just the ones from a
> reclaim/cleaning context?

I would focus only for those which are important enough. Which are those
is a harder question. But certainly those with GFP_NOFAIL are important
enough.

> All that should go into the changelog of a separate allocation booster
> patch, I think.

The reason I did both in the same patch is to address the concern about
potential lockups when NOFS|NOFAIL cannot make any progress. I've chosen
ALLOC_HARDER to give the minimum portion of the reserves so that we do
not risk other high priority users to be blocked out but still help a
bit at least and prevent from starvation when other reclaimers are
faster to consume the reclaimed memory.

I can extend the changelog of course but I believe that having both
changes together makes some sense. NOFS|NOFAIL allocations are not all
that rare and sometimes we really depend on them making a further
progress.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
