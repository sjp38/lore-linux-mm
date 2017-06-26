Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F14046B03C3
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 08:18:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f134so707395wme.3
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:18:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2si12142977wra.335.2017.06.26.05.18.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 05:18:39 -0700 (PDT)
Date: Mon, 26 Jun 2017 14:18:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm: kvmalloc support __GFP_RETRY_MAYFAIL for all
 sizes
Message-ID: <20170626121836.GL11534@dhcp22.suse.cz>
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-5-mhocko@kernel.org>
 <80500165-94c2-2d5c-ff7a-6310916da288@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <80500165-94c2-2d5c-ff7a-6310916da288@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 26-06-17 14:00:27, Vlastimil Babka wrote:
> On 06/23/2017 10:53 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Now that __GFP_RETRY_MAYFAIL has a reasonable semantic regardless of the
> > request size we can drop the hackish implementation for !costly orders.
> > __GFP_RETRY_MAYFAIL retries as long as the reclaim makes a forward
> > progress and backs of when we are out of memory for the requested size.
> > Therefore we do not need to enforce__GFP_NORETRY for !costly orders just
> > to silent the oom killer anymore.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> The flag is now supported, but not for the embedded page table
> allocations, so OOM is still theoretically possible, right?
> That should be rare, though. Worth mentioning anywhere?

Yes that is true. Not sure I would make it more complicated than
necessary. I can add a note in there if you insist but to me it sounds
like something that will only confuse people.
 
> Other than that.
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> > ---
> >  mm/util.c | 14 ++++----------
> >  1 file changed, 4 insertions(+), 10 deletions(-)
> > 
> > diff --git a/mm/util.c b/mm/util.c
> > index 6520f2d4a226..ee250e2cde34 100644
> > --- a/mm/util.c
> > +++ b/mm/util.c
> > @@ -339,9 +339,9 @@ EXPORT_SYMBOL(vm_mmap);
> >   * Uses kmalloc to get the memory but if the allocation fails then falls back
> >   * to the vmalloc allocator. Use kvfree for freeing the memory.
> >   *
> > - * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. __GFP_RETRY_MAYFAIL
> > - * is supported only for large (>32kB) allocations, and it should be used only if
> > - * kmalloc is preferable to the vmalloc fallback, due to visible performance drawbacks.
> > + * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported.
> > + * __GFP_RETRY_MAYFAIL is supported, and it should be used only if kmalloc is
> > + * preferable to the vmalloc fallback, due to visible performance drawbacks.
> >   *
> >   * Any use of gfp flags outside of GFP_KERNEL should be consulted with mm people.
> >   */
> > @@ -366,13 +366,7 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
> >  	if (size > PAGE_SIZE) {
> >  		kmalloc_flags |= __GFP_NOWARN;
> >  
> > -		/*
> > -		 * We have to override __GFP_RETRY_MAYFAIL by __GFP_NORETRY for !costly
> > -		 * requests because there is no other way to tell the allocator
> > -		 * that we want to fail rather than retry endlessly.
> > -		 */
> > -		if (!(kmalloc_flags & __GFP_RETRY_MAYFAIL) ||
> > -				(size <= PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> > +		if (!(kmalloc_flags & __GFP_RETRY_MAYFAIL))
> >  			kmalloc_flags |= __GFP_NORETRY;
> >  	}
> >  
> > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
