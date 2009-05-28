Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5A66B0088
	for <linux-mm@kvack.org>; Thu, 28 May 2009 08:23:40 -0400 (EDT)
Date: Thu, 28 May 2009 14:23:57 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090528122357.GM6920@wotan.suse.de>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528095934.GA10678@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 05:59:34PM +0800, Wu Fengguang wrote:
> Hi Nick,
> 
> > > +     /*
> > > +      * remove_from_page_cache assumes (mapping && !mapped)
> > > +      */
> > > +     if (page_mapping(p) && !page_mapped(p)) {
> > > +             remove_from_page_cache(p);
> > > +             page_cache_release(p);
> > > +     }
> > 
> > remove_mapping would probably be a better idea. Otherwise you can
> > probably introduce pagecache removal vs page fault races which
> > will make the kernel bug.
> 
> We use remove_mapping() at first, then discovered that it made strong
> assumption on page_count=2.
> 
> I guess it is safe from races since we are locking the page?

Yes it probably should (although you will lose get_user_pages data, but
I guess that's the aim anyway).

But I just don't like this one file having all that required knowledge
(and few comments) of all the files in mm/. If you want to get rid
of the page and don't care what it's count or dirtyness is, then
truncate_inode_pages_range is the correct API to use.

(or you could extract out some of it so you can call it directly on
individual locked pages, if that helps).


> > > +     }
> > > +
> > > +     me_pagecache_clean(p);
> > > +
> > > +     /*
> > > +      * Did the earlier release work?
> > > +      */
> > > +     if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
> > > +             return FAILED;
> > > +
> > > +     return RECOVERED;
> > > +}
> > > +
> > > +/*
> > > + * Clean and dirty swap cache.
> > > + */
> > > +static int me_swapcache_dirty(struct page *p)
> > > +{
> > > +     ClearPageDirty(p);
> > > +
> > > +     if (!isolate_lru_page(p))
> > > +             page_cache_release(p);
> > > +
> > > +     return DELAYED;
> > > +}
> > > +
> > > +static int me_swapcache_clean(struct page *p)
> > > +{
> > > +     ClearPageUptodate(p);
> > > +
> > > +     if (!isolate_lru_page(p))
> > > +             page_cache_release(p);
> > > +
> > > +     delete_from_swap_cache(p);
> > > +
> > > +     return RECOVERED;
> > > +}
> > 
> > All these handlers are quite interesting in that they need to
> > know about most of the mm. What are you trying to do in each
> > of them would be a good idea to say, and probably they should
> > rather go into their appropriate files instead of all here
> > (eg. swapcache stuff should go in mm/swap_state for example).
> 
> Yup, they at least need more careful comments.
> 
> Dirty swap cache page is tricky to handle. The page could live both in page
> cache and swap cache(ie. page is freshly swapped in). So it could be referenced
> concurrently by 2 types of PTEs: one normal PTE and another swap PTE. We try to
> handle them consistently by calling try_to_unmap(TTU_IGNORE_HWPOISON) to convert
> the normal PTEs to swap PTEs, and then
>         - clear dirty bit to prevent IO
>         - remove from LRU
>         - but keep in the swap cache, so that when we return to it on
>           a later page fault, we know the application is accessing
>           corrupted data and shall be killed (we installed simple
>           interception code in do_swap_page to catch it).

OK this is the point I was missing.

Should all be commented and put into mm/swap_state.c (or somewhere that
Hugh prefers).
 

> Clean swap cache pages can be directly isolated. A later page fault will bring
> in the known good data from disk.

OK, but why do you ClearPageUptodate if it is just to be deleted from
swapcache anyway?

 
> > You haven't waited on writeback here AFAIKS, and have you
> > *really* verified it is safe to call delete_from_swap_cache?
> 
> Good catch. I'll soon submit patches for handling the under
> read/write IO pages. In this patchset they are simply ignored.

Well that's quite important ;) I would suggest you just wait_on_page_writeback.
It is simple and should work. _Unless_ you can show it is a big problem that
needs equivalently big mes to fix ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
