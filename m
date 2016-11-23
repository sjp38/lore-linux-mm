Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D3DEB6B027F
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 07:35:36 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id o3so2278991wjo.1
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 04:35:36 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id b6si30891542wjb.270.2016.11.23.04.35.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 04:35:35 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id f8so953617wje.2
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 04:35:35 -0800 (PST)
Date: Wed, 23 Nov 2016 13:35:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161123123532.GJ2864@dhcp22.suse.cz>
References: <20161123064925.9716-1-mhocko@kernel.org>
 <20161123064925.9716-3-mhocko@kernel.org>
 <87b89181-a141-611d-c772-c5e483aa4f49@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87b89181-a141-611d-c772-c5e483aa4f49@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 23-11-16 13:19:20, Vlastimil Babka wrote:
> On 11/23/2016 07:49 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __alloc_pages_may_oom makes sure to skip the OOM killer depending on
> > the allocation request. This includes lowmem requests, costly high
> > order requests and others. For a long time __GFP_NOFAIL acted as an
> > override for all those rules. This is not documented and it can be quite
> > surprising as well. E.g. GFP_NOFS requests are not invoking the OOM
> > killer but GFP_NOFS|__GFP_NOFAIL does so if we try to convert some of
> > the existing open coded loops around allocator to nofail request (and we
> > have done that in the past) then such a change would have a non trivial
> > side effect which is not obvious. Note that the primary motivation for
> > skipping the OOM killer is to prevent from pre-mature invocation.
> > 
> > The exception has been added by 82553a937f12 ("oom: invoke oom killer
> > for __GFP_NOFAIL"). The changelog points out that the oom killer has to
> > be invoked otherwise the request would be looping for ever. But this
> > argument is rather weak because the OOM killer doesn't really guarantee
> > any forward progress for those exceptional cases - e.g. it will hardly
> > help to form costly order - I believe we certainly do not want to kill
> > all processes and eventually panic the system just because there is a
> > nasty driver asking for order-9 page with GFP_NOFAIL not realizing all
> > the consequences - it is much better this request would loop for ever
> > than the massive system disruption, lowmem is also highly unlikely to be
> > freed during OOM killer and GFP_NOFS request could trigger while there
> > is still a lot of memory pinned by filesystems.
> > 
> > This patch simply removes the __GFP_NOFAIL special case in order to have
> > a more clear semantic without surprising side effects. Instead we do
> > allow nofail requests to access memory reserves to move forward in both
> > cases when the OOM killer is invoked and when it should be supressed.
> > __alloc_pages_nowmark helper has been introduced for that purpose.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> This makes some sense to me, but there might be unpleasant consequences,
> e.g. due to allowing costly allocations without reserves.

I am not sure I understand. Did you mean with reserves? Anyway, my code
inspection shown that we are not really doing GFP_NOFAIL for costly
orders. This might change in the future but even if we do that then this
shouldn't add a risk of the reserves depletion, right?

> I guess only testing will show...
> 
> Also some comments below.
[...]
> >  static inline struct page *
> > +__alloc_pages_nowmark(gfp_t gfp_mask, unsigned int order,
> > +						const struct alloc_context *ac)
> > +{
> > +	struct page *page;
> > +
> > +	page = get_page_from_freelist(gfp_mask, order,
> > +			ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
> > +	/*
> > +	 * fallback to ignore cpuset restriction if our nodes
> > +	 * are depleted
> > +	 */
> > +	if (!page)
> > +		page = get_page_from_freelist(gfp_mask, order,
> > +				ALLOC_NO_WATERMARKS, ac);
> 
> Is this enough? Look at what __alloc_pages_slowpath() does since
> e46e7b77c909 ("mm, page_alloc: recalculate the preferred zoneref if the
> context can ignore memory policies").

this is a one time attempt to do the nowmark allocation. If we need to
do the recalculation then this should happen in the next round. Or am I
missing your question?

> 
> ...
> 
> > -	}
> >  	/* Exhausted what can be done so it's blamo time */
> > -	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> > +	if (out_of_memory(&oc)) {
> 
> This removes the warning, but also the check for __GFP_NOFAIL itself. Was it
> what you wanted?

The point of the check was to keep looping for __GFP_NOFAIL requests
even when the OOM killer is disabled (out_of_memory returns false). We
are accomplishing that by 
> 
> >  		*did_some_progress = 1;
		^^^^ this

it is true we will not have the warning but I am not really sure we care
all that much. In any case it wouldn't be all that hard to check for oom
killer disabled and warn on in the allocator slow path.

thanks for having a look!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
