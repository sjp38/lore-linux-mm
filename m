Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id C428D6B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 14:51:00 -0400 (EDT)
Received: by qgep97 with SMTP id p97so3965227qge.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 11:51:00 -0700 (PDT)
Received: from ham-cannon.twitter.com ([8.25.196.27])
        by mx.google.com with ESMTPS id z82si100613qhd.91.2015.03.24.11.50.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Mar 2015 11:50:51 -0700 (PDT)
Date: Tue, 24 Mar 2015 11:50:47 -0700
From: Matt Mullins <mmullins@twopensource.com>
Subject: Re: [PATCH v11 21/21] brd: Rename XIP to DAX
Message-ID: <20150324185046.GA4994@whiteoak.sf.office.twttr.net>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-22-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411677218-29146-22-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, msharbiani@twopensource.com

On Thu, Sep 25, 2014 at 04:33:38PM -0400, Matthew Wilcox wrote:
> --- a/drivers/block/brd.c
> +++ b/drivers/block/brd.c
> @@ -97,13 +97,13 @@ static struct page *brd_insert_page(struct brd_device *brd, sector_t sector)
>  	 * Must use NOIO because we don't want to recurse back into the
>  	 * block or filesystem layers from page reclaim.
>  	 *
> -	 * Cannot support XIP and highmem, because our ->direct_access
> -	 * routine for XIP must return memory that is always addressable.
> -	 * If XIP was reworked to use pfns and kmap throughout, this
> +	 * Cannot support DAX and highmem, because our ->direct_access
> +	 * routine for DAX must return memory that is always addressable.
> +	 * If DAX was reworked to use pfns and kmap throughout, this
>  	 * restriction might be able to be lifted.
>  	 */
>  	gfp_flags = GFP_NOIO | __GFP_ZERO;
> -#ifndef CONFIG_BLK_DEV_XIP
> +#ifndef CONFIG_BLK_DEV_RAM_DAX
>  	gfp_flags |= __GFP_HIGHMEM;
>  #endif
>  	page = alloc_page(gfp_flags);

We're also developing a user of direct_access, and we ended up with some
questions about the sleeping guarantees of the direct_access API.

Since brd is currently the only (x86) implementation of DAX in Linus's tree,
I've been testing against that.  We noticed that the brd implementation of DAX
can call into alloc_page() with __GFP_WAIT if we call direct_access() on a page
that has not yet been allocated.  This is compounded by the fact that brd does
not support size > PAGE_SIZE (and thus I call bdev_direct_access() on each use),
though the limitation makes sense -- I shouldn't expect the brd driver to be
able to allocate a gigabyte of contiguous memory.

The potential sleeping behavior was somewhat surprising to me, as I would expect
the NV-DIMM device implementation to simply offset the pfn at which the device
is located rather than perform a memory allocation.  What are the guaranteed
and/or expected contexts from which direct_access() can be safely called?

While I can easily punt this usage to a work queue (that's what we already do
for devices where we need to submit a bio), part of our desire to use
direct_access is to avoid additional latency.

If it would make more sense for us to test against (for example) the pmem or an
mtd-block driver instead, as you've discussed with Mathieu Desnoyers, then I'd
be happy to work with those in our environment as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
