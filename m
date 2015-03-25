Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id BE1AA6B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 23:25:23 -0400 (EDT)
Received: by pagj7 with SMTP id j7so14121234pag.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 20:25:23 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id yi7si1563639pbc.190.2015.03.24.20.25.21
        for <linux-mm@kvack.org>;
        Tue, 24 Mar 2015 20:25:22 -0700 (PDT)
Date: Wed, 25 Mar 2015 14:25:17 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v11 21/21] brd: Rename XIP to DAX
Message-ID: <20150325032517.GG31342@dastard>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-22-git-send-email-matthew.r.wilcox@intel.com>
 <20150324185046.GA4994@whiteoak.sf.office.twttr.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150324185046.GA4994@whiteoak.sf.office.twttr.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, msharbiani@twopensource.com

On Tue, Mar 24, 2015 at 11:50:47AM -0700, Matt Mullins wrote:
> On Thu, Sep 25, 2014 at 04:33:38PM -0400, Matthew Wilcox wrote:
> > --- a/drivers/block/brd.c
> > +++ b/drivers/block/brd.c
> > @@ -97,13 +97,13 @@ static struct page *brd_insert_page(struct brd_device *brd, sector_t sector)
> >  	 * Must use NOIO because we don't want to recurse back into the
> >  	 * block or filesystem layers from page reclaim.
> >  	 *
> > -	 * Cannot support XIP and highmem, because our ->direct_access
> > -	 * routine for XIP must return memory that is always addressable.
> > -	 * If XIP was reworked to use pfns and kmap throughout, this
> > +	 * Cannot support DAX and highmem, because our ->direct_access
> > +	 * routine for DAX must return memory that is always addressable.
> > +	 * If DAX was reworked to use pfns and kmap throughout, this
> >  	 * restriction might be able to be lifted.
> >  	 */
> >  	gfp_flags = GFP_NOIO | __GFP_ZERO;
> > -#ifndef CONFIG_BLK_DEV_XIP
> > +#ifndef CONFIG_BLK_DEV_RAM_DAX
> >  	gfp_flags |= __GFP_HIGHMEM;
> >  #endif
> >  	page = alloc_page(gfp_flags);
> 
> We're also developing a user of direct_access, and we ended up with some
> questions about the sleeping guarantees of the direct_access API.
> 
> Since brd is currently the only (x86) implementation of DAX in Linus's tree,
> I've been testing against that.  We noticed that the brd implementation of DAX
> can call into alloc_page() with __GFP_WAIT if we call direct_access() on a page
> that has not yet been allocated.  This is compounded by the fact that brd does
> not support size > PAGE_SIZE (and thus I call bdev_direct_access() on each use),
> though the limitation makes sense -- I shouldn't expect the brd driver to be
> able to allocate a gigabyte of contiguous memory.
> 
> The potential sleeping behavior was somewhat surprising to me, as I would expect
> the NV-DIMM device implementation to simply offset the pfn at which the device
> is located rather than perform a memory allocation.  What are the guaranteed
> and/or expected contexts from which direct_access() can be safely called?

I'll defer to whatever Willy and others say, but I my understanding
is that .direct_access has the same semantics as submitting an IO.
i.e. the intent of .direct_access is to set up direct access to the
memory and then return a pfn you can use to access it and hence what
operations are performed are backing device dependent.

Hence for some devices it might simply be an offset->pfn calculation
and immediately return, others might have to play mapping games
(maybe talk to an iommu?) and others, like brd, may have to allocate
backing store from some separate storage pool before access can be
granted. Expect that .direct_access can sleep, and you'll be fine.

> While I can easily punt this usage to a work queue (that's what we already do
> for devices where we need to submit a bio), part of our desire to use
> direct_access is to avoid additional latency.

brd is intended for testing purposes only because it isn't
persistent. However, we need something we can develop against and
imost of us don't have real hardware - that's what brd+dax is for.

If you want brd+dax to act like NVDIMM based persistent memory,
populate all the backing pages in the ram disk before running your
tests by writing zeros to the entire block device. Then the backing
store will be fully allocated, and .direct_access will never do
allocation until you flush the backing store...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
