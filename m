Date: Tue, 1 Aug 2006 10:45:14 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/2] mm: speculative get_page
Message-ID: <20060801084514.GA17452@wotan.suse.de>
References: <20060726063905.GA32107@wotan.suse.de> <44CE234A.60203@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44CE234A.60203@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 31, 2006 at 04:35:38PM +0100, Andy Whitcroft wrote:
> Nick Piggin wrote:
> >
> >This patch introduces the core locking protocol to the pagecache
> >(ie. adds page_cache_get_speculative, and tweaks some update-side
> >code to make it work).
> >
> >Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> Ok, this one is a bit scarey but here goes.

Thanks for reviewing!

Will send out an incremental patch...

> 
> First question is about performance.  I seem to remember from your OLS 
> paper that there was good scaling improvements with this.  Was there any 
> benefit to simple cases (one process on SMP)?  There seems to be a good 
> deal less locking in here, well without preempt etc anyhow.

The single thread find_get_page numbers were improved, yes. Highlights
were on UP compiled kernel, P4 was about 3x faster and SMP kernel, G5
was about 2x faster working on a cache hot struct page. Cache cold
numbers were improved too.

Of course, this is a very tiny function anyway, performed within a
larger context... but at least we don't regress here.

Gang lookups I still haven't instrumeted fully - the difference would
be much less there I expect.

> 
> > include/linux/page-flags.h |    7 +++
> > include/linux/pagemap.h    |  103 
> > +++++++++++++++++++++++++++++++++++++++++++++
> > mm/filemap.c               |    4 +
> > mm/migrate.c               |   11 ++++
> > mm/swap_state.c            |    4 +
> > mm/vmscan.c                |   12 +++--
> > 6 files changed, 137 insertions(+), 4 deletions(-)
> >
> >Index: linux-2.6/include/linux/page-flags.h
> >===================================================================
> >--- linux-2.6.orig/include/linux/page-flags.h
> >+++ linux-2.6/include/linux/page-flags.h
> >@@ -86,6 +86,8 @@
> > #define PG_nosave_free		18	/* Free, should not be 
> > written */
> > #define PG_buddy		19	/* Page is free, on buddy lists */
> > 
> >+#define PG_nonewrefs		20	/* Block concurrent pagecache lookups
> >+					 * while testing refcount */
> 
> As always ... page flags :(.  It seems pretty key to the stabilisation 
> of _count, however are we really relying on that?  (See next comment ...)

Yeah it is a page flag. I think we do need it. Am I allowed to trade
PG_reserved for it? ;)

> >+/*
> >+ * speculatively take a reference to a page.
> >+ * If the page is free (_count == 0), then _count is untouched, and NULL
> >+ * is returned. Otherwise, _count is incremented by 1 and page is 
> >returned.
> >+ *
> >+ * This function must be run in the same rcu_read_lock() section as has
> >+ * been used to lookup the page in the pagecache radix-tree: this allows
> >+ * allocators to use a synchronize_rcu() to stabilize _count.
> 
> Ok, so that makes sense from the algorithm as we take an additional 
> reference somewhere within the 'rcu read lock'.  To get a stable count 
> we have to ensure there is no-one is in the read side.  However, the 
> commentary says we can use synchronize_rcu to get a stable count.  Is 
> that correct?  All that synchronize_rcu() guarentees is that all 
> concurrent readers at the start of the call will have finished when it 
> returns, there is no guarentee that there will be no new readers since 
> the start of the call, not in parallel with its completion?  Setting 

There will be no new readers, because if you have newly allocated this
page, lookups can no longer find it in pagecache after a synchronize_rcu.
The important word is "allocators" (ie. not pagecache) -- but I don't
think I have made that clear: will fix.

> PageNoNewRefs will not prevent a new reader upping the reference count 
> either as they wait after they have bumped it.  So do we really have a 
> way to stablise _count here?  I am likely missing something, educate me :).

We can't stabilise _count for pagecache pages. What we can do is prevent
any new *references* from being handed out via the pagecache (although
they may indeed increment _count, we don't give them the pointer).

> 
> Now I cannot see any users of this effect in either of the patches in 
> this set so perhaps we do not care?

synchronize_rcu(), no. I imagine it will become needed for memory hot
unplug if we're freeing up mem_map[]s. Other users might just find it
convenient, but so far I think I converted all users to something else
which tended to be cleaner anyway.

> >+	if (unlikely(!get_page_unless_zero(page)))
> >+		return NULL; /* page has been freed */
> >+
> >+	/*
> >+	 * Note that get_page_unless_zero provides a memory barrier.
> >+	 * This is needed to ensure PageNoNewRefs is evaluated after the
> >+	 * page refcount has been raised. See below comment.
> >+	 */
> >+
> >+	while (unlikely(PageNoNewRefs(page)))
> >+		cpu_relax();
> >+
> >+	/*
> >+	 * smp_rmb is to ensure the load of page->flags (for PageNoNewRefs())
> >+	 * is performed before a future load used to ensure the page is
> >+	 * the correct on (usually: page->mapping and page->index).
> 
> "the correct on[e]"

Yep.

> 
> Ok, this is a little confusing mostly I think because you don't provide 
> a corresponding read side example.  Or it should read.  "smp_rmb is 
> required to ensure the load ...., provided within get_page_unless_zero()."

This is the read-side example (only the page->mapping test is done by callers).

> 
> Also, I do wonder if there should be some way to indicate that we need a 
> barrier, and that we're stealing the one before or after which we get 
> for free.
> 
> 	if (unlikely(!get_page_unless_zero(page)))
> 		return NULL; /* page has been freed */
> 	/* smp_rmb() */

But you really need the commenting to show which accesses you are
interested in ordering, and who else cares.

> >Index: linux-2.6/mm/vmscan.c
> >===================================================================
> >--- linux-2.6.orig/mm/vmscan.c
> >+++ linux-2.6/mm/vmscan.c
> >@@ -380,6 +380,8 @@ int remove_mapping(struct address_space 
> > 	if (!mapping)
> > 		return 0;		/* truncate got there first */
> > 
> >+	SetPageNoNewRefs(page);
> >+	smp_wmb();
> > 	write_lock_irq(&mapping->tree_lock);
> 
> Ok.  Do we need the smp_wmb() here?  Would not the write_lock_irq() 
> provide a full barrier already.

No, only an acquire barrier (in this case, the store to page->flags
may leak as far as the write_unlock_irq at the end of the crit section).

> >Index: linux-2.6/mm/filemap.c
> >===================================================================
> >--- linux-2.6.orig/mm/filemap.c
> >+++ linux-2.6/mm/filemap.c
> >@@ -440,6 +440,8 @@ int add_to_page_cache(struct page *page,
> > 	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> > 
> > 	if (error == 0) {
> >+		SetPageNoNewRefs(page);
> >+		smp_wmb();
> > 		write_lock_irq(&mapping->tree_lock);
> 
> Again, do we not have an implicit barrier in write_lock_irq().

ditto

> 
> > 		error = radix_tree_insert(&mapping->page_tree, offset, page);
> > 		if (!error) {
> >@@ -451,6 +453,8 @@ int add_to_page_cache(struct page *page,
> > 			__inc_zone_page_state(page, NR_FILE_PAGES);
> > 		}
> > 		write_unlock_irq(&mapping->tree_lock);
> >+		smp_wmb();
> >+		ClearPageNoNewRefs(page);
> 
> Again, do we not have an implicit barrier in the unlock.

Only release: the store can go as far up as the write_lock_irq.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
