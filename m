Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DB7096B005A
	for <linux-mm@kvack.org>; Thu, 28 May 2009 06:00:05 -0400 (EDT)
Date: Thu, 28 May 2009 17:59:34 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in the VM v3
Message-ID: <20090528095934.GA10678@localhost>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528082616.GG6920@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Thu, May 28, 2009 at 04:26:16PM +0800, Nick Piggin wrote:
> On Wed, May 27, 2009 at 10:12:39PM +0200, Andi Kleen wrote:
> >
> > This patch adds the high level memory handler that poisons pages
> > that got corrupted by hardware (typically by a bit flip in a DIMM
> > or a cache) on the Linux level. Linux tries to access these
> > pages in the future then.

[snip]

> > +/*
> > + * Clean (or cleaned) page cache page.
> > + */
> > +static int me_pagecache_clean(struct page *p)
> > +{
> > +     if (!isolate_lru_page(p))
> > +             page_cache_release(p);
> > +
> > +     if (page_has_private(p))
> > +             do_invalidatepage(p, 0);
> > +     if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
> > +             Dprintk(KERN_ERR "MCE %#lx: failed to release buffers\n",
> > +                     page_to_pfn(p));
> > +
> > +     /*
> > +      * remove_from_page_cache assumes (mapping && !mapped)
> > +      */
> > +     if (page_mapping(p) && !page_mapped(p)) {
> > +             remove_from_page_cache(p);
> > +             page_cache_release(p);
> > +     }
> 
> remove_mapping would probably be a better idea. Otherwise you can
> probably introduce pagecache removal vs page fault races which
> will make the kernel bug.

We use remove_mapping() at first, then discovered that it made strong
assumption on page_count=2.

I guess it is safe from races since we are locking the page?

> 
> > +     }
> > +
> > +     me_pagecache_clean(p);
> > +
> > +     /*
> > +      * Did the earlier release work?
> > +      */
> > +     if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
> > +             return FAILED;
> > +
> > +     return RECOVERED;
> > +}
> > +
> > +/*
> > + * Clean and dirty swap cache.
> > + */
> > +static int me_swapcache_dirty(struct page *p)
> > +{
> > +     ClearPageDirty(p);
> > +
> > +     if (!isolate_lru_page(p))
> > +             page_cache_release(p);
> > +
> > +     return DELAYED;
> > +}
> > +
> > +static int me_swapcache_clean(struct page *p)
> > +{
> > +     ClearPageUptodate(p);
> > +
> > +     if (!isolate_lru_page(p))
> > +             page_cache_release(p);
> > +
> > +     delete_from_swap_cache(p);
> > +
> > +     return RECOVERED;
> > +}
> 
> All these handlers are quite interesting in that they need to
> know about most of the mm. What are you trying to do in each
> of them would be a good idea to say, and probably they should
> rather go into their appropriate files instead of all here
> (eg. swapcache stuff should go in mm/swap_state for example).

Yup, they at least need more careful comments.

Dirty swap cache page is tricky to handle. The page could live both in page
cache and swap cache(ie. page is freshly swapped in). So it could be referenced
concurrently by 2 types of PTEs: one normal PTE and another swap PTE. We try to
handle them consistently by calling try_to_unmap(TTU_IGNORE_HWPOISON) to convert
the normal PTEs to swap PTEs, and then
        - clear dirty bit to prevent IO
        - remove from LRU
        - but keep in the swap cache, so that when we return to it on
          a later page fault, we know the application is accessing
          corrupted data and shall be killed (we installed simple
          interception code in do_swap_page to catch it).

Clean swap cache pages can be directly isolated. A later page fault will bring
in the known good data from disk.

> You haven't waited on writeback here AFAIKS, and have you
> *really* verified it is safe to call delete_from_swap_cache?

Good catch. I'll soon submit patches for handling the under
read/write IO pages. In this patchset they are simply ignored.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
