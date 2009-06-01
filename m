Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 479EF6B004F
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 07:50:04 -0400 (EDT)
Date: Mon, 1 Jun 2009 13:50:46 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090601115046.GE5018@wotan.suse.de>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528135428.GB16528@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 09:54:28PM +0800, Wu Fengguang wrote:
> On Thu, May 28, 2009 at 08:23:57PM +0800, Nick Piggin wrote:
> > On Thu, May 28, 2009 at 05:59:34PM +0800, Wu Fengguang wrote:
> > > Hi Nick,
> > > 
> > > > > +     /*
> > > > > +      * remove_from_page_cache assumes (mapping && !mapped)
> > > > > +      */
> > > > > +     if (page_mapping(p) && !page_mapped(p)) {
> > > > > +             remove_from_page_cache(p);
> > > > > +             page_cache_release(p);
> > > > > +     }
> > > > 
> > > > remove_mapping would probably be a better idea. Otherwise you can
> > > > probably introduce pagecache removal vs page fault races which
> > > > will make the kernel bug.
> > > 
> > > We use remove_mapping() at first, then discovered that it made strong
> > > assumption on page_count=2.
> > > 
> > > I guess it is safe from races since we are locking the page?
> > 
> > Yes it probably should (although you will lose get_user_pages data, but
> > I guess that's the aim anyway).
> 
> Yes. We (and truncate) rely heavily on this logic:
> 
>         retry:
>                 lock_page(page);
>                 if (page->mapping == NULL)
>                         goto retry;
>                 // do something on page
>                 unlock_page(page);
> 
> So that we can steal/isolate a page under its page lock.
> 
> The truncate code does wait on writeback page, but we would like to
> isolate the page ASAP, so as to avoid someone to find it in the page
> cache (or swap cache) and then access its content.
> 
> I see no obvious problems to isolate a writeback page from page cache
> or swap cache. But also I'm not sure it won't break some assumption
> in some corner of the kernel.

The problem is that then you have lost synchronization in the
pagecache. Nothing then prevents a new page from being put
in there and trying to do IO to or from the same device as the
currently running writeback.

 
> > But I just don't like this one file having all that required knowledge
> 
> Yes that's a big problem.
> 
> One major complexity involves classify the page into different known
> types, by testing page flags, page_mapping, page_mapped, etc. This
> is not avoidable.

No.

 
> Another major complexity is on calling the isolation routines to
> remove references from
>         - PTE
>         - page cache
>         - swap cache
>         - LRU list
> They more or less made some assumptions on their operating environment
> that we have to take care of.  Unfortunately these complexities are
> also not easily resolvable.
> 
> > (and few comments) of all the files in mm/. If you want to get rid
> 
> I promise I'll add more comments :)

OK, but they should still go in their relevant files. Or as best as
possible. Right now it's just silly to have all this here when much
of it could be moved out to filemap.c, swap_state.c, page_alloc.c, etc.


> > of the page and don't care what it's count or dirtyness is, then
> > truncate_inode_pages_range is the correct API to use.
> >
> > (or you could extract out some of it so you can call it directly on
> > individual locked pages, if that helps).
>  
> The patch to move over to truncate_complete_page() would like this.
> It's not a big win indeed.

No I don't mean to do this, but to move the truncate_inode_pages
code for truncating a single, locked, page into another function
in mm/truncate.c and then call that from here.

> 
> ---
>  mm/memory-failure.c |   14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
> 
> --- sound-2.6.orig/mm/memory-failure.c
> +++ sound-2.6/mm/memory-failure.c
> @@ -327,20 +327,18 @@ static int me_pagecache_clean(struct pag
>  	if (!isolate_lru_page(p))
>  		page_cache_release(p);
>  
> -	if (page_has_private(p))
> -		do_invalidatepage(p, 0);
> -	if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
> -		Dprintk(KERN_ERR "MCE %#lx: failed to release buffers\n",
> -			page_to_pfn(p));
> -
>  	/*
>  	 * remove_from_page_cache assumes (mapping && !mapped)
>  	 */
>  	if (page_mapping(p) && !page_mapped(p)) {
> -		remove_from_page_cache(p);
> -		page_cache_release(p);
> +                ClearPageMlocked(p);
> +                truncate_complete_page(p->mapping, p)
>  	}
>  
> +	if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
> +		Dprintk(KERN_ERR "MCE %#lx: failed to release buffers\n",
> +			page_to_pfn(p));
> +
>  	return RECOVERED;
>  }
>  
> 
> > OK this is the point I was missing.
> > 
> > Should all be commented and put into mm/swap_state.c (or somewhere that
> > Hugh prefers).
> 
> But I doubt Hugh will welcome moving that bits into swap*.c ;)

Why not? If he has to look at it anyway, he probably rather looks
at fewer files :)

 
> > > Clean swap cache pages can be directly isolated. A later page fault will bring
> > > in the known good data from disk.
> > 
> > OK, but why do you ClearPageUptodate if it is just to be deleted from
> > swapcache anyway?
> 
> The ClearPageUptodate() is kind of a careless addition, in the hope
> that it will stop some random readers. Need more investigations.

OK. But it just muddies the waters in the meantime, so maybe take
such things out until there is a case for them.

 
> > > > You haven't waited on writeback here AFAIKS, and have you
> > > > *really* verified it is safe to call delete_from_swap_cache?
> > > 
> > > Good catch. I'll soon submit patches for handling the under
> > > read/write IO pages. In this patchset they are simply ignored.
> > 
> > Well that's quite important ;) I would suggest you just wait_on_page_writeback.
> > It is simple and should work. _Unless_ you can show it is a big problem that
> > needs equivalently big mes to fix ;)
> 
> Yes we could do wait_on_page_writeback() if necessary. The downside is,
> keeping writeback page in page cache opens a small time window for
> some one to access the page.

AFAIKS there already is such a window? You're doing lock_page and such.
No, it seems rather insane to do something like this here that no other
code in the mm ever does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
