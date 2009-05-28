Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9818D6B006A
	for <linux-mm@kvack.org>; Thu, 28 May 2009 09:54:05 -0400 (EDT)
Date: Thu, 28 May 2009 21:54:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in the VM v3
Message-ID: <20090528135428.GB16528@localhost>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Disposition: inline
In-Reply-To: <20090528122357.GM6920@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 08:23:57PM +0800, Nick Piggin wrote:
> On Thu, May 28, 2009 at 05:59:34PM +0800, Wu Fengguang wrote:
> > Hi Nick,
> > 
> > > > +     /*
> > > > +      * remove_from_page_cache assumes (mapping && !mapped)
> > > > +      */
> > > > +     if (page_mapping(p) && !page_mapped(p)) {
> > > > +             remove_from_page_cache(p);
> > > > +             page_cache_release(p);
> > > > +     }
> > > 
> > > remove_mapping would probably be a better idea. Otherwise you can
> > > probably introduce pagecache removal vs page fault races which
> > > will make the kernel bug.
> > 
> > We use remove_mapping() at first, then discovered that it made strong
> > assumption on page_count=2.
> > 
> > I guess it is safe from races since we are locking the page?
> 
> Yes it probably should (although you will lose get_user_pages data, but
> I guess that's the aim anyway).

Yes. We (and truncate) rely heavily on this logic:

        retry:
                lock_page(page);
                if (page->mapping == NULL)
                        goto retry;
                // do something on page
                unlock_page(page);

So that we can steal/isolate a page under its page lock.

The truncate code does wait on writeback page, but we would like to
isolate the page ASAP, so as to avoid someone to find it in the page
cache (or swap cache) and then access its content.

I see no obvious problems to isolate a writeback page from page cache
or swap cache. But also I'm not sure it won't break some assumption
in some corner of the kernel.

> But I just don't like this one file having all that required knowledge

Yes that's a big problem.

One major complexity involves classify the page into different known
types, by testing page flags, page_mapping, page_mapped, etc. This
is not avoidable.

Another major complexity is on calling the isolation routines to
remove references from
        - PTE
        - page cache
        - swap cache
        - LRU list
They more or less made some assumptions on their operating environment
that we have to take care of.  Unfortunately these complexities are
also not easily resolvable.

> (and few comments) of all the files in mm/. If you want to get rid

I promise I'll add more comments :)

> of the page and don't care what it's count or dirtyness is, then
> truncate_inode_pages_range is the correct API to use.
>
> (or you could extract out some of it so you can call it directly on
> individual locked pages, if that helps).
 
The patch to move over to truncate_complete_page() would like this.
It's not a big win indeed.

---
 mm/memory-failure.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

--- sound-2.6.orig/mm/memory-failure.c
+++ sound-2.6/mm/memory-failure.c
@@ -327,20 +327,18 @@ static int me_pagecache_clean(struct pag
 	if (!isolate_lru_page(p))
 		page_cache_release(p);
 
-	if (page_has_private(p))
-		do_invalidatepage(p, 0);
-	if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
-		Dprintk(KERN_ERR "MCE %#lx: failed to release buffers\n",
-			page_to_pfn(p));
-
 	/*
 	 * remove_from_page_cache assumes (mapping && !mapped)
 	 */
 	if (page_mapping(p) && !page_mapped(p)) {
-		remove_from_page_cache(p);
-		page_cache_release(p);
+                ClearPageMlocked(p);
+                truncate_complete_page(p->mapping, p)
 	}
 
+	if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
+		Dprintk(KERN_ERR "MCE %#lx: failed to release buffers\n",
+			page_to_pfn(p));
+
 	return RECOVERED;
 }
 

> > > > +     }
> > > > +
> > > > +     me_pagecache_clean(p);
> > > > +
> > > > +     /*
> > > > +      * Did the earlier release work?
> > > > +      */
> > > > +     if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
> > > > +             return FAILED;
> > > > +
> > > > +     return RECOVERED;
> > > > +}
> > > > +
> > > > +/*
> > > > + * Clean and dirty swap cache.
> > > > + */
> > > > +static int me_swapcache_dirty(struct page *p)
> > > > +{
> > > > +     ClearPageDirty(p);
> > > > +
> > > > +     if (!isolate_lru_page(p))
> > > > +             page_cache_release(p);
> > > > +
> > > > +     return DELAYED;
> > > > +}
> > > > +
> > > > +static int me_swapcache_clean(struct page *p)
> > > > +{
> > > > +     ClearPageUptodate(p);
> > > > +
> > > > +     if (!isolate_lru_page(p))
> > > > +             page_cache_release(p);
> > > > +
> > > > +     delete_from_swap_cache(p);
> > > > +
> > > > +     return RECOVERED;
> > > > +}
> > > 
> > > All these handlers are quite interesting in that they need to
> > > know about most of the mm. What are you trying to do in each
> > > of them would be a good idea to say, and probably they should
> > > rather go into their appropriate files instead of all here
> > > (eg. swapcache stuff should go in mm/swap_state for example).
> > 
> > Yup, they at least need more careful comments.
> > 
> > Dirty swap cache page is tricky to handle. The page could live both in page
> > cache and swap cache(ie. page is freshly swapped in). So it could be referenced
> > concurrently by 2 types of PTEs: one normal PTE and another swap PTE. We try to
> > handle them consistently by calling try_to_unmap(TTU_IGNORE_HWPOISON) to convert
> > the normal PTEs to swap PTEs, and then
> >         - clear dirty bit to prevent IO
> >         - remove from LRU
> >         - but keep in the swap cache, so that when we return to it on
> >           a later page fault, we know the application is accessing
> >           corrupted data and shall be killed (we installed simple
> >           interception code in do_swap_page to catch it).
> 
> OK this is the point I was missing.
> 
> Should all be commented and put into mm/swap_state.c (or somewhere that
> Hugh prefers).

But I doubt Hugh will welcome moving that bits into swap*.c ;)

> 
> > Clean swap cache pages can be directly isolated. A later page fault will bring
> > in the known good data from disk.
> 
> OK, but why do you ClearPageUptodate if it is just to be deleted from
> swapcache anyway?

The ClearPageUptodate() is kind of a careless addition, in the hope
that it will stop some random readers. Need more investigations.

> > > You haven't waited on writeback here AFAIKS, and have you
> > > *really* verified it is safe to call delete_from_swap_cache?
> > 
> > Good catch. I'll soon submit patches for handling the under
> > read/write IO pages. In this patchset they are simply ignored.
> 
> Well that's quite important ;) I would suggest you just wait_on_page_writeback.
> It is simple and should work. _Unless_ you can show it is a big problem that
> needs equivalently big mes to fix ;)

Yes we could do wait_on_page_writeback() if necessary. The downside is,
keeping writeback page in page cache opens a small time window for
some one to access the page.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
