Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 780A96B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 02:51:14 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so12386524wma.2
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 23:51:14 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id j16si6824216wmd.116.2016.11.23.23.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 23:51:12 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u144so4188589wmu.0
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 23:51:12 -0800 (PST)
Date: Thu, 24 Nov 2016 08:51:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161124075110.GA20668@dhcp22.suse.cz>
References: <20161123064925.9716-1-mhocko@kernel.org>
 <20161123064925.9716-3-mhocko@kernel.org>
 <87b89181-a141-611d-c772-c5e483aa4f49@suse.cz>
 <20161123123532.GJ2864@dhcp22.suse.cz>
 <75ad0d8e-3dff-8893-eb2d-5f3817d91d83@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <75ad0d8e-3dff-8893-eb2d-5f3817d91d83@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Thu 24-11-16 08:41:30, Vlastimil Babka wrote:
> On 11/23/2016 01:35 PM, Michal Hocko wrote:
> > On Wed 23-11-16 13:19:20, Vlastimil Babka wrote:
[...]
> > > >  static inline struct page *
> > > > +__alloc_pages_nowmark(gfp_t gfp_mask, unsigned int order,
> > > > +						const struct alloc_context *ac)
> > > > +{
> > > > +	struct page *page;
> > > > +
> > > > +	page = get_page_from_freelist(gfp_mask, order,
> > > > +			ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
> > > > +	/*
> > > > +	 * fallback to ignore cpuset restriction if our nodes
> > > > +	 * are depleted
> > > > +	 */
> > > > +	if (!page)
> > > > +		page = get_page_from_freelist(gfp_mask, order,
> > > > +				ALLOC_NO_WATERMARKS, ac);
> > > 
> > > Is this enough? Look at what __alloc_pages_slowpath() does since
> > > e46e7b77c909 ("mm, page_alloc: recalculate the preferred zoneref if the
> > > context can ignore memory policies").
> > 
> > this is a one time attempt to do the nowmark allocation. If we need to
> > do the recalculation then this should happen in the next round. Or am I
> > missing your question?
> 
> The next round no-watermarks allocation attempt in __alloc_pages_slowpath()
> uses different criteria than the new __alloc_pages_nowmark() callers. And it
> would be nicer to unify this as well, if possible.

I am sorry but I still do not see your point. Could you be more specific
why it matters? In other words this is what we were doing prior to this
patch already so I am not changing it. I just wrapped it into a helper
because I have to do the same thing at two places because of oom vs.
no-oom paths.

> > > > -	}
> > > >  	/* Exhausted what can be done so it's blamo time */
> > > > -	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> > > > +	if (out_of_memory(&oc)) {
> > > 
> > > This removes the warning, but also the check for __GFP_NOFAIL itself. Was it
> > > what you wanted?
> > 
> > The point of the check was to keep looping for __GFP_NOFAIL requests
> > even when the OOM killer is disabled (out_of_memory returns false). We
> > are accomplishing that by
> > > 
> > > >  		*did_some_progress = 1;
> > 		^^^^ this
> 
> But oom disabled means that this line is not reached?

Yes but it doesn't need to anymore because we have that "check NOFAIL on
nopage" check in the allocator slow path from the first patch. We didn't
have that previously so we had to "cheat" here.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
