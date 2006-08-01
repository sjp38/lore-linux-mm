Date: Tue, 1 Aug 2006 11:04:28 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] mm: lockless pagecache
Message-ID: <20060801090428.GB17452@wotan.suse.de>
References: <20060726063941.GB32107@wotan.suse.de> <44CE2365.6040605@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44CE2365.6040605@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 31, 2006 at 04:36:05PM +0100, Andy Whitcroft wrote:
> Nick Piggin wrote:
> >Combine page_cache_get_speculative with lockless radix tree lookups to
> >introduce lockless page cache lookups (ie. no mapping->tree_lock on
> >the read-side).
> >
> >The only atomicity changes this introduces is that the gang pagecache
> >lookup functions now behave as if they are implemented with multiple
> >find_get_page calls, rather than operating on a snapshot of the pages.
> >In practice, this atomicity guarantee is not used anyway, and it is
> >difficult to see how it could be. Gang pagecache lookups are designed
> >to replace individual lookups, so these semantics are natural.
> >
> >Swapcache can no longer use find_get_page, because it has a different
> >method of encoding swapcache position into the page. Introduce a new
> >find_get_swap_page for it.
> >
> >Signed-off-by: Nick Piggin <npiggin@suse.de>
> >
> > include/linux/swap.h |    1
> > mm/filemap.c         |  161 
> > +++++++++++++++++++++++++++++++++++++--------------
> > mm/page-writeback.c  |    8 --
> > mm/readahead.c       |    7 --
> > mm/swap_state.c      |   27 +++++++-
> > mm/swapfile.c        |    2
> > 6 files changed, 150 insertions(+), 56 deletions(-)
> >
> 
> It seems in these routines you have two different placements for the rcu 
> locking.  Either outside or inside the repeat.  Should we assume that 
> those where the locks are outside the repeat: loop have very light payloads?

Yeah, I think the "inside" rcu locking is just used where we have to
sleep. Indeed the loop should be very light I expect it will almost
never retry, and only rarely spin on NoNewRefs.

> >@@ -613,11 +613,22 @@ struct page *find_trylock_page(struct ad
> > {
> > 	struct page *page;
> > 
> >-	read_lock_irq(&mapping->tree_lock);
> >+	rcu_read_lock();
> >+repeat:
> > 	page = radix_tree_lookup(&mapping->page_tree, offset);
> >-	if (page && TestSetPageLocked(page))
> >-		page = NULL;
> >-	read_unlock_irq(&mapping->tree_lock);
> >+	if (page) {
> >+		page = page_cache_get_speculative(page);
> >+		if (unlikely(!page))
> >+			goto repeat;
> >+		/* Has the page been truncated? */
> >+		if (unlikely(page->mapping != mapping
> >+				|| page->index != offset)) {
> >+			page_cache_release(page);
> >+			goto repeat;
> >+		}
> >+	}
> >+	rcu_read_unlock();
> >+
> > 	return page;
> > }
> 
> This one has me puzzled.  This seem to no longer lock the page at all 
> when returning it.  It seems the semantics of this has changed wildly. 
> Also find_lock_page below still seems to lock the page, the semantic 
> seems maintained there?  I think I am expecting to find a 
> TestSetPageLocked() in the new version too?

Yeah, looks like I stuffed up merging it. Didn't notice because nobody
uses find_trylock_page (as Hugh points out, this should be the find_get_page
body, and find_trylock should be unchanged).

> >+	rcu_read_lock();
> >+repeat:
> >+	nr_found = radix_tree_gang_lookup(&mapping->page_tree,
> > 				(void **)pages, start, nr_pages);
> >-	for (i = 0; i < ret; i++)
> >-		page_cache_get(pages[i]);
> >-	read_unlock_irq(&mapping->tree_lock);
> >-	return ret;
> >+	for (i = 0; i < nr_found; i++) {
> >+		struct page *page;
> >+		page = page_cache_get_speculative(pages[i]);
> >+		if (unlikely(!page)) {
> >+bail:
> >+			/*
> >+			 * must return at least 1 page, so caller continues
> >+			 * calling in.
> 
> Although that is a resonable semantic, several callers seem to expect 
> all or nothing semantics here.  Mostly the direct callers to 
> find_get_pages().  The callers using pagevec_lookup() at least seem to 
> cope with a partial left fill as implemented here.

I don't see any problems with find_get_pages callers (splice and ramfs).
(hmm, ramfs should be moved over to find_get_pages_contig). You see, if
the pages being looked up are getting chucked out of pagecache anyway,
then then it could be valid to return.

Actually: find_get_pages is a little iffy, but ramfs is happy with that.
Maybe I'll reintroduce my find_get_pages_nonatomic, and leave fgps under
lock.

pagevec_lookup users seem to be fine. Maybe an API rename is in order
for them too, though.

> 
> >+			 */
> >+			if (i == 0)
> >+				goto repeat;
> >+			break;
> >+		}
> >+
> >+		/* Has the page been truncated? */
> >+		if (unlikely(page->mapping != mapping
> >+				|| page->index < start)) {
> >+			page_cache_release(page);
> >+			goto bail;
> 
> I have looked at this check for a while now and I can say I am troubled 
> by it.  We do not know which page we are looking up so can we truly say 
> the index check here is sufficient?  Also, could not the start= below 
> lead us to follow a moving page and skip pages?  Perhaps there is no way 

Hmm, it may move upwards and lead us to skip I think. Good point, I'll
look at that.

> to get any sort of guarentee with this interface before or after this 
> change; and all is well?  Tell me it is :).

Well the gang lookups were generally introduced to replace multiple calls
to fgp, so callers don't use the requirement of an atomic snapshot. However
you can still use the tree_lock to get the old semantics.

> 
> >+		}
> >+
> >+		/* ensure we don't pick up pages that have moved behind us */
> >+		start = page->index+1;
> >+	}
> >+	rcu_read_unlock();
> >+	return i;
> > }
> > 
> > /**
> >@@ -752,19 +786,35 @@ unsigned find_get_pages_contig(struct ad
> > 			       unsigned int nr_pages, struct page **pages)
> > {
> > 	unsigned int i;
> >-	unsigned int ret;
> >+	unsigned int nr_found;
> > 
> >-	read_lock_irq(&mapping->tree_lock);
> >-	ret = radix_tree_gang_lookup(&mapping->page_tree,
> >+	rcu_read_lock();
> >+repeat:
> >+	nr_found = radix_tree_gang_lookup(&mapping->page_tree,
> > 				(void **)pages, index, nr_pages);
> >-	for (i = 0; i < ret; i++) {
> >-		if (pages[i]->mapping == NULL || pages[i]->index != index)
> >+	for (i = 0; i < nr_found; i++) {
> >+		struct page *page;
> >+		page = page_cache_get_speculative(pages[i]);
> >+		if (unlikely(!page)) {
> >+bail:
> >+			/*
> >+			 * must return at least 1 page, so caller continues
> >+			 * calling in.
> >+			 */
> >+			if (i == 0)
> >+				goto repeat;
> > 			break;
> >+		}
> > 
> >-		page_cache_get(pages[i]);
> >+		/* Has the page been truncated? */
> >+		if (unlikely(page->mapping != mapping
> >+				|| page->index != index)) {
> >+			page_cache_release(page);
> >+			goto bail;
> >+		}
> 
> Ok, normally this construct is checking against the page at 
> (mapping,index) so it is very unlikely that the index does not match. 
> However in this case we are doing a contiguity scan, so in fact the 
> likelyhood of this missmatching is more defined by the likelyhood of 
> contiguity in the mapping.  The check originally had no such hints?  Is 
> it appropriate to have a hint here?

Yes. We have nothing protecting the page against being truncated or
moved by splice (wheras previously tree_lock would do it).

Thanks again for the review. I'll try to fix up the outstanding
issues you identified.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
