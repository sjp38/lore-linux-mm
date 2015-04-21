Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id B2B1E900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 17:17:11 -0400 (EDT)
Received: by wiax7 with SMTP id x7so116318399wia.0
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 14:17:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e5si5719149wix.88.2015.04.21.14.17.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 14:17:10 -0700 (PDT)
Date: Tue, 21 Apr 2015 22:17:04 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/6] mm: Defer TLB flush after unmap as long as possible
Message-ID: <20150421211704.GC14842@suse.de>
References: <1429612880-21415-1-git-send-email-mgorman@suse.de>
 <1429612880-21415-4-git-send-email-mgorman@suse.de>
 <5536B386.4050808@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5536B386.4050808@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 21, 2015 at 04:31:02PM -0400, Rik van Riel wrote:
> On 04/21/2015 06:41 AM, Mel Gorman wrote:
> > If a PTE is unmapped and it's dirty then it was writable recently. Due
> > to deferred TLB flushing, it's best to assume a writable TLB cache entry
> > exists. With that assumption, the TLB must be flushed before any IO can
> > start or the page is freed to avoid lost writes or data corruption. Prior
> > to this patch, such PFNs were simply flushed immediately. In this patch,
> > the caller is informed that such entries potentially exist and it's up to
> > the caller to flush before pages are freed or IO can start.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> > @@ -1450,10 +1455,11 @@ static int page_not_mapped(struct page *page)
> >   * page, used in the pageout path.  Caller must hold the page lock.
> >   * Return values are:
> >   *
> > - * SWAP_SUCCESS	- we succeeded in removing all mappings
> > - * SWAP_AGAIN	- we missed a mapping, try again later
> > - * SWAP_FAIL	- the page is unswappable
> > - * SWAP_MLOCK	- page is mlocked.
> > + * SWAP_SUCCESS	       - we succeeded in removing all mappings
> > + * SWAP_SUCCESS_CACHED - Like SWAP_SUCCESS but a writable TLB entry may exist
> > + * SWAP_AGAIN	       - we missed a mapping, try again later
> > + * SWAP_FAIL	       - the page is unswappable
> > + * SWAP_MLOCK	       - page is mlocked.
> >   */
> >  int try_to_unmap(struct page *page, enum ttu_flags flags)
> >  {
> > @@ -1481,7 +1487,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
> >  	ret = rmap_walk(page, &rwc);
> >  
> >  	if (ret != SWAP_MLOCK && !page_mapped(page))
> > -		ret = SWAP_SUCCESS;
> > +		ret = (ret == SWAP_AGAIN_CACHED) ? SWAP_SUCCESS_CACHED : SWAP_SUCCESS;
> > +
> >  	return ret;
> >  }
> 
> This wants a big fat comment explaining why SWAP_AGAIN_CACHED is turned
> into SWAP_SUCCESS_CACHED.
> 

I'll add something in V4. SWAP_AGAIN_CACHED indicates to rmap_walk that
it should continue the rmap but that a write cached PTE was encountered.
SWAP_SUCCESS is what callers of try_to_unmap() expect so
SWAP_SUCCESS_CACHED is the equivalent.

> I think I understand why this is happening, but I am not sure how to
> explain it...
> 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 12ec298087b6..0ad3f435afdd 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -860,6 +860,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  	unsigned long nr_reclaimed = 0;
> >  	unsigned long nr_writeback = 0;
> >  	unsigned long nr_immediate = 0;
> > +	bool tlb_flush_required = false;
> >  
> >  	cond_resched();
> >  
> > @@ -1032,6 +1033,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  				goto keep_locked;
> >  			case SWAP_MLOCK:
> >  				goto cull_mlocked;
> > +			case SWAP_SUCCESS_CACHED:
> > +				/* Must flush before free, fall through */
> > +				tlb_flush_required = true;
> >  			case SWAP_SUCCESS:
> >  				; /* try to free the page below */
> >  			}
> > @@ -1176,7 +1180,8 @@ keep:
> >  	}
> >  
> >  	mem_cgroup_uncharge_list(&free_pages);
> > -	try_to_unmap_flush();
> > +	if (tlb_flush_required)
> > +		try_to_unmap_flush();
> >  	free_hot_cold_page_list(&free_pages, true);
> 
> Don't we have to flush the TLB before calling pageout() on the page?
> 

Not any more. It got removed in patch 2 up and I forgot to reintroduce it
with a tlb_flush_required check here. Thanks for that.

> In other words, we would also have to batch up calls to pageout(), if
> we want to do batched TLB flushing.
> 
> This could be accomplished by putting the SWAP_SUCCESS_CACHED pages on
> a special list, instead of calling pageout() on them immediately, and
> then calling pageout() on all the pages on that list after the batch
> flush.
> 

True. We had discussed something like that on IRC. It's a good idea but
a separate patch because it's less clear-cut. We're taking a partial pass
through the list in an attempt to reduce IPIs.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
