Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F181D6B005C
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 07:48:11 -0400 (EDT)
Date: Sat, 26 Sep 2009 19:48:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
Message-ID: <20090926114806.GA12419@localhost>
References: <20090926031537.GA10176@localhost> <Pine.LNX.4.64.0909261115530.12927@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0909261115530.12927@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Sep 26, 2009 at 07:09:21PM +0800, Hugh Dickins wrote:
> On Sat, 26 Sep 2009, Wu Fengguang wrote:
> 
> > The swap cache and page cache code assume that they 'own' the newly
> > allocated page and therefore can disregard the locking rules. However
> > now hwpoison can hit any time on any page.
> > 
> > So use the safer lock_page()/trylock_page(). The main intention is not
> > to close such a small time window of memory corruption. But to avoid
> > kernel oops that may result from such races, and also avoid raising
> > false alerts in hwpoison stress tests.
> > 
> > This in theory will slightly increase page cache/swap cache overheads,
> > however it seems to be too small to be measurable in benchmark.
> 
> No.
> 
> But I'd most certainly defer to Nick if he disagrees with me.
> 
> I don't think anyone would want to quarrel very long over the swap
> and migration mods alone, but add_to_page_cache() is of a higher
> order of magnitude.

Yup, add_to_page_cache() is hot path.

> I can't see any reason to surrender add_to_page_cache() optimizations
> to the remote possibility of hwpoison (infinitely remote for most of
> us); though I wouldn't myself want to run the benchmark to defend them.
> 
> You'd later be sending a patch to replace __SetPageUptodate()s by
> SetPageUptodate()s etc, wouldn't you?  Because any non-atomic op
> on page->flags might wipe your locked bit (or your hwpoison bit).

That's a sad fact, there may be more holes than we want/able to handle..

> You could make #ifdef CONFIG_HWPOISON_INJECT select the slower
> versions of these things; or #ifdef CONFIG_MEMORY_FAILURE? that
> would pose distros with a harder choice.  But I'd much prefer
> not to go that way.
> 
> Please accept that there will be quite a number of places where
> the code "knows" it's the only user of the page, and hwpoison
> handling and testing should work around those places (can shift
> things around slightly to suit itself better, but not add cost).
> 
> Look into why you think you want the page lock: I can see it's
> going to be useful if you're taking a page out of a file (but then
> why bother if page->mapping not set?), or if you're using rmap-style
> lookup (but then why bother if !page_mapped?).
> 
> I suspect if memory_failure() did something like:
> 	if (page->mapping)
> 		lock_page_nosync(p);
> then you'd be okay, perhaps with a few additional _inexpensive_
> tweaks here and there.  With the "necessary" memory barriers?
> no, we probably wouldn't want to be adding any in hot paths.
> 
> But I definitely say "something like": remember that page_mapping()
> does that weird thing with PageSwapCache (a mistake from day one in
> my opinion), which might or might not be what you want.  There are
> probably various reasons why it's not as simple as I suggest above.

Good view point! Could do it if turned out to be simple.

However we may well end up to accept the fact that "we just cannot do
hwpoison 100% correct", and settle with a simple and 99% correct code.

> It seems to me that the Intel hardware guys have done half a job
> here: the sooner they get to remapping the bad pages, the better.

When we can offer to set aside half memory :)

Thanks,
Fengguang

> > CC: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> > CC: Andi Kleen <andi@firstfloor.org> 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  include/linux/pagemap.h |   13 ++++---------
> >  mm/migrate.c            |    2 +-
> >  mm/swap_state.c         |    4 ++--
> >  3 files changed, 7 insertions(+), 12 deletions(-)
> > 
> > --- sound-2.6.orig/mm/swap_state.c	2009-09-14 10:50:19.000000000 +0800
> > +++ sound-2.6/mm/swap_state.c	2009-09-25 18:42:23.000000000 +0800
> > @@ -306,7 +306,7 @@ struct page *read_swap_cache_async(swp_e
> >  		 * re-using the just freed swap entry for an existing page.
> >  		 * May fail (-ENOMEM) if radix-tree node allocation failed.
> >  		 */
> > -		__set_page_locked(new_page);
> > +		lock_page(new_page);
> >  		SetPageSwapBacked(new_page);
> >  		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
> >  		if (likely(!err)) {
> > @@ -318,7 +318,7 @@ struct page *read_swap_cache_async(swp_e
> >  			return new_page;
> >  		}
> >  		ClearPageSwapBacked(new_page);
> > -		__clear_page_locked(new_page);
> > +		unlock_page(new_page);
> >  		swapcache_free(entry, NULL);
> >  	} while (err != -ENOMEM);
> >  
> > --- sound-2.6.orig/include/linux/pagemap.h	2009-09-14 10:50:19.000000000 +0800
> > +++ sound-2.6/include/linux/pagemap.h	2009-09-25 18:42:19.000000000 +0800
> > @@ -292,11 +292,6 @@ extern int __lock_page_killable(struct p
> >  extern void __lock_page_nosync(struct page *page);
> >  extern void unlock_page(struct page *page);
> >  
> > -static inline void __set_page_locked(struct page *page)
> > -{
> > -	__set_bit(PG_locked, &page->flags);
> > -}
> > -
> >  static inline void __clear_page_locked(struct page *page)
> >  {
> >  	__clear_bit(PG_locked, &page->flags);
> > @@ -435,18 +430,18 @@ extern void remove_from_page_cache(struc
> >  extern void __remove_from_page_cache(struct page *page);
> >  
> >  /*
> > - * Like add_to_page_cache_locked, but used to add newly allocated pages:
> > - * the page is new, so we can just run __set_page_locked() against it.
> > + * Like add_to_page_cache_locked, but used to add newly allocated pages.
> >   */
> >  static inline int add_to_page_cache(struct page *page,
> >  		struct address_space *mapping, pgoff_t offset, gfp_t gfp_mask)
> >  {
> >  	int error;
> >  
> > -	__set_page_locked(page);
> > +	if (!trylock_page(page))
> > +		return -EIO;	/* hwpoisoned */
> >  	error = add_to_page_cache_locked(page, mapping, offset, gfp_mask);
> >  	if (unlikely(error))
> > -		__clear_page_locked(page);
> > +		unlock_page(page);
> >  	return error;
> >  }
> >  
> > --- sound-2.6.orig/mm/migrate.c	2009-09-14 10:50:19.000000000 +0800
> > +++ sound-2.6/mm/migrate.c	2009-09-25 18:42:19.000000000 +0800
> > @@ -551,7 +551,7 @@ static int move_to_new_page(struct page 
> >  	 * holding a reference to the new page at this point.
> >  	 */
> >  	if (!trylock_page(newpage))
> > -		BUG();
> > +		return -EAGAIN;		/* got by hwpoison */
> >  
> >  	/* Prepare mapping for the new page.*/
> >  	newpage->index = page->index;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
