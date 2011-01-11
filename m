Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A52396B00E8
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 06:45:47 -0500 (EST)
Date: Tue, 11 Jan 2011 11:45:21 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: mmotm hangs on compaction lock_page
Message-ID: <20110111114521.GD11932@csn.ul.ie>
References: <alpine.LSU.2.00.1101061632020.9601@sister.anvils> <20110107145259.GK29257@csn.ul.ie> <20110107175705.GL29257@csn.ul.ie> <20110110172609.GA11932@csn.ul.ie> <alpine.LSU.2.00.1101101458540.21100@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1101101458540.21100@tigran.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 10, 2011 at 03:56:37PM -0800, Hugh Dickins wrote:
> On Mon, 10 Jan 2011, Mel Gorman wrote:
> > On Fri, Jan 07, 2011 at 05:57:05PM +0000, Mel Gorman wrote:
> > > On Fri, Jan 07, 2011 at 02:52:59PM +0000, Mel Gorman wrote:
> > > > On Thu, Jan 06, 2011 at 05:20:25PM -0800, Hugh Dickins wrote:
> > > > > Hi Mel,
> > > > > 
> > > > > Here are the traces of two concurrent "cp -a kerneltree elsewhere"s
> > > > > which have hung on mmotm: in limited RAM, on a PowerPC
> > > > 
> > > > How limited in RAM and how many CPUs?
> 
> 700MB and 4 CPUs - but you've worked out a way to reproduce it, well done.
> 

It's your reproduction case although it showed up with 2G and 4 CPUs. It's
easier to trigger if min_free_kbytes is lower and SLUB is a required.

> > > > 
> > > > > - I don't have
> > > > > an explanation for why I can reproduce it in minutes on that box but
> > > > > never yet on the x86s.
> > > > > 
> 
> I still don't have any explanation for that.  And the minutes became
> hours as soon as I changed anything at all, also weird.
> 

It does reproduce on x86-64 - it's just a lot harder for some reason.
Where as I can reproduce on my ppc64 machine in 2-15 minutes, it took 45
minutes on x86-64 even under similar circumstances.

> > > > 
> > > > Strongest bet is simply that compaction is not triggering for you on the
> > > > x86 boxes. Monitor "grep compact /proc/vmstat" on the two machines and
> > > > see if the counters are growing on powerpc and not on x86. I'm trying to
> > > > reproduce the problem locally but no luck yet.
> > > > 
> 
> Other machines have been busy frying other fish, I didn't get to
> investigate that hypothesis.
> 
> > > > > Perhaps we can get it to happen with just one cp: the second cp here
> > > > > seemed to be deadlocking itself, unmap_and_move()'s force lock_page
> > > > > waiting on a page which its page cache readahead already holds locked.
> > > > > 
> > > > > cp              D 000000000fea3110     0 18874  18873 0x00008010
> > > > > Call Trace:
> > > > >  .__switch_to+0xcc/0x110
> > > > >  .schedule+0x670/0x7b0
> > > > >  .io_schedule+0x50/0x8c
> > > > >  .sync_page+0x84/0xa0
> > > > >  .sync_page_killable+0x10/0x48
> > > > >  .__wait_on_bit_lock+0x9c/0x140
> > > > >  .__lock_page_killable+0x74/0x98
> > > > >  .do_generic_file_read+0x2b0/0x504
> > > > >  .generic_file_aio_read+0x214/0x29c
> > > > >  .do_sync_read+0xac/0x10c
> > > > >  .vfs_read+0xd0/0x1a0
> > > > >  .SyS_read+0x58/0xa0
> > > > >  syscall_exit+0x0/0x40
> > > > >  syscall_exit+0x0/0x40
> > > > > 
> > > > > cp              D 000000000fea3110     0 18876  18875 0x00008010
> > > > > Call Trace:
> > > > >  0xc000000001343b68 (unreliable)
> > > > >  .__switch_to+0xcc/0x110
> > > > >  .schedule+0x670/0x7b0
> > > > >  .io_schedule+0x50/0x8c
> > > > >  .sync_page+0x84/0xa0
> > > > >  .__wait_on_bit_lock+0x9c/0x140
> > > > >  .__lock_page+0x74/0x98
> > > > >  .unmap_and_move+0xfc/0x380
> > > > >  .migrate_pages+0xbc/0x18c
> > > > >  .compact_zone+0xbc/0x400
> > > > >  .compact_zone_order+0xc8/0xf4
> > > > >  .try_to_compact_pages+0x104/0x1b8
> > > > >  .__alloc_pages_direct_compact+0xa8/0x228
> > > > >  .__alloc_pages_nodemask+0x42c/0x730
> > > > >  .allocate_slab+0x84/0x168
> > > > >  .new_slab+0x58/0x198
> > > > >  .__slab_alloc+0x1ec/0x430
> > > > >  .kmem_cache_alloc+0x7c/0xe0
> > > > >  .radix_tree_preload+0x94/0x140
> > > > >  .add_to_page_cache_locked+0x70/0x1f0
> > > > >  .add_to_page_cache_lru+0x50/0xac
> > > > >  .mpage_readpages+0xcc/0x198
> > > > >  .ext3_readpages+0x28/0x40
> > > > >  .__do_page_cache_readahead+0x1ac/0x2ac
> > > > >  .ra_submit+0x28/0x38
> > > > 
> > > > Something is odd right here. I would have expected entries in the
> > > > calli stack containing
> > > > 
> > > >  .ondemand_readahead
> > > >  .page_cache_sync_readahead
> > > > 
> > > > I am going to have to assume these functions were really called
> > > > otherwise the ra_submit is a mystery :(
> 
> I hadn't noticed that, very strange.  I've confirmed that stacktrace
> several times since, and there's no sign of .ondemand_readahead or
> .page_cache_sync_readahead or .page_cache_async_readahead anywhere
> in the raw stack.  But I'm unfamiliar with PPC, perhaps there's
> some magic way they're there but don't appear (a function descriptor
> thing which works out differently in their case?).
> 

I can't find an explanation but oddly they do show up when I reproduce
the case. Figuring it out isn't the highest priority but it's very
curious.

> > > > >  .do_generic_file_read+0xe8/0x504
> > > > >  .generic_file_aio_read+0x214/0x29c
> > > > >  .do_sync_read+0xac/0x10c
> > > > >  .vfs_read+0xd0/0x1a0
> > > > >  .SyS_read+0x58/0xa0
> > > > >  syscall_exit+0x0/0x40
> > > > > 
> > > > > I haven't made a patch for it, just hacked unmap_and_move() to say
> > > > > "if (!0)" instead of "if (!force)" to get on with my testing.  I expect
> > > > > you'll want to pass another arg down to migrate_pages() to prevent
> > > > > setting force, or give it some flags, or do something with PF_MEMALLOC.
> > > > > 
> > > > 
> > > > I tend to agree but I'm failing to see how it might be happening right now.
> > > > The callchain looks something like
> > > > 
> > > > do_generic_file_read
> > > >    # page is not found
> > > >    page_cache_sync_readahead
> > > >       ondemand_readahead
> > > >          ra_submit
> > > >             __do_page_cache_readahead
> > > >                # Allocates a bunch of pages
> > > >                # Sets PageReadahead. Otherwise the pages  initialised
> > > >                # and they are not on the LRU yet
> > > >                read_pages
> > > >                   # Calls mapping->readpages which calls mpage_readpages
> > > >                   mpage_readpages
> > > >                      # For the list of pages (index initialised), add
> > > >                      # each of them to the LRU. Adding to the LRU
> > > >                      # locks the page and should return the page
> > > >                      # locked.
> > > >                      add_to_page_cache_lru
> > > >                      # sets PageSwapBacked
> > > >                         add_to_page_cache
> > > >                            # locks page
> > > >                            add_to_page_cache_locked
> > > >                               # preloads radix tree
> > > >                                  radix_tree_preload
> > > >                                  # DEADLOCK HERE. This is what does not
> > > >                                  # make sense. Compaction could not be
> > > >                                  # be finding the page on the LRU as
> > > >                                  # lru_cache_add_file() has not been
> > > >                                  # called yet for this page
> > > > 
> > > > So I don't think we are locking on the same page.
> 
> Right: the hanging lock_pages of both cps tend to be on the page for
> pgoff_t 0 of some file, whereas the add_to_page_cache is on the page for
> pgoff_t 2 (which in the cases I saw had readahead == reclaim bit set).
> 

Ok, good to have that confirmed.

> > > > 
> > > > Here is a possibility. mpage_readpages() is reading ahead so there are obviously
> > > > pages that are not Uptodate. It queues these for asynchronous read with
> > > > block_read_full_page(), returns and adds the page to the LRU (so compaction
> > > > is now able to find it). IO starts at some time in the future with the page
> > > > still locked and gets unlocked at the end of IO by end_buffer_async_read().
> > > > 
> > > > Between when IO is queued and it completes, a new page is being added to
> > > > the LRU, the radix tree is loaded and compaction kicks off trying to
> > > > lock the same page that is not up to date yet. Something is preventing
> > > > the IO completing and the page being unlocked but I'm missing what that
> > > > might be.
> > > > 
> > > > Does this sound plausible? I'll keep looking but I wanted to see if
> > > > someone spotted quickly a major flaw in the reasoning or have a quick
> > > > guess as to why the page might not be getting unlocked at the end of IO
> > > > properly.
> > > > 
> 
> When I first posted the problem, it seemed obvious to me - but that's
> probably because I have a very strong bias against lock_page in the
> page reclaim path,

If page reclaim used lock_page(), it probably would be vunerable to the
same problem. If it happened to work, it was because the page didn't reach
the end of the LRU list fast enough to cause problems. We use
trylock_page() where it matters though.

> and I just jumped on this as an example of how
> unwise that can be, without thinking it fully through.
> 
> Once you analysed more deeply, I couldn't see it anymore: I couldn't
> see here why the IO would not complete and the page be unlocked, to
> let the new lockers in.
> 
> > 
> > I got this reproduced locally and it is related to readahead pages but
> 
> Oh brilliant, Mel: thanks so much for that effort. 

Thanks for the test case. It was just a matter of fiddling with it until
it reproduced. FWIW, setting min_free_kbytes to 1024 for the copy was the
easiest way of reproducing the problem quickly.

> I was about to call
> you off it, in case it was just some anomaly of my machine (or a
> surprising side-effect of another, anon_vma, issue in migrate.c,
> for which I do have a patch to post later).
> 
> > the other patch I posted was garbage.
> 
> I did give it a run, additionally setting PF_MEMALLOC before the call
> to __alloc_pages_direct_compact and clearing after, you appeared to
> be relying on that.  It didn't help, but now, only now, do I see there
> are two calls to __alloc_pages_direct_compact and I missed the second
> one - perhaps that's why it didn't help.
> 

That is the most likely explanation. It was after I posted the patch I
remembered that PF_MEMALLOC is not set for compaction. It's not a memory
allocator and unlike page reclaim, it's not freeing up new pages. Once upon
a time, I was concerned that compaction could use ALLOC_NO_WATERMARKS but
it is not calling back into the allocator and even if it was, PF_MEMALLOC
should be set so we detect that recursion.

> > This patch fixes makes the problem
> > unreprodible for me at least. I still don't have the exact reason why pages are
> > not getting unlocked by IO completion but suspect it's because the same process
> > completes the IO that started it. If it's deadlocked, it never finishes the IO.
> 
> It again seems fairly obvious to me, now that you've spelt it out for me
> this far.  If we go the mpage_readpages route, that builds up an mpage bio,
> calling add_to_page_cache (which sets the locked bit) on a series of pages,
> before submitting the bio whose mpage_end_io will unlock them all after.
> An allocation when adding second or third... page is in danger of
> deadlocking on the first page down in compaction's migration.
> 

Perfect.

> > ==== CUT HERE ====
> > mm: compaction: Avoid potential deadlock for readahead pages and direct compaction
> > 
> > Hugh Dickins reported that two instances of cp were locking up when
> > running on ppc64 in a memory constrained environment. The deadlock
> > appears to apply to readahead pages. When reading ahead, the pages are
> > added locked to the LRU and queued for IO. The process is also inserting
> > pages into the page cache and so is calling radix_preload and entering
> > the page allocator. When SLUB is used, this can result in direct
> > compaction finding the page that was just added to the LRU but still
> > locked by the current process leading to deadlock.
> > 
> > This patch avoids locking pages for migration that might already be
> > locked by the current process. Ideally it would only apply for direct
> > compaction but compaction does not set PF_MEMALLOC so there is no way
> > currently of identifying a process in direct compaction. A process-flag
> > could be added but is likely to be overkill.
> > 
> > Reported-by: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> But whilst I'm hugely grateful to you for working this out,
> I'm sorry to say that I'm not keen on your patch!
> 
> PageMappedToDisk is an fs thing, not an mm thing (migrate.c copies it
> over but that's all), and I don't like to see you rely on it.  I expect
> it works well for ext234 and many others that use mpage_readpages,
> but what of btrfs_readpages? 

Well spotted! That's a good reason for not being keen on the patch :). 

> I couldn't see any use of PageMappedToDisk
> there.  I suppose you could insist it use it too, but...
> 

We could but it'd be too easy to miss again in the future.

> How about setting and clearing PF_MEMALLOC around the call to
> try_to_compact_pages() in __alloc_pages_direct_compact(), and
> skipping the lock_page when PF_MEMALLOC is set, whatever the
> page flags?  That would mimic __alloc_pages_direct_reclaim
> (hmm, reclaim_state??);

Setting reclaim_state would not detect the situation where we recurse
back into the page allocator. I do not believe this is happening at the
moment but maybe the situation just hasn't been encuntered yet.

> and I've a suspicion that this readahead
> deadlock may not be the only one lurking.
> 

It's a better plan. Initially I wanted to avoid use of PF_MEMALLOC but
you've more than convinced me. For anyone watching, I also considered the
sync parameter being passed into migrate pages but it's used to determine if
we should wait_on_page_writeback() or not and is not suitable for overloading
to avoid the use with lock_page().

How about this then? Andrew, if accepted, this should replace the patch
mm-vmscan-reclaim-order-0-and-use-compaction-instead-of-lumpy-reclaim-avoid-potential-deadlock-for-readahead-pages-and-direct-compaction.patch
in -mm.

==== CUT HERE ====
mm: compaction: Avoid a potential deadlock due to lock_page() during direct compaction

Hugh Dickins reported that two instances of cp were locking up when
running on ppc64 in a memory constrained environment. It also affects
x86-64 but was harder to reproduce. The deadlock was related to readahead
pages. When reading ahead, the pages are added locked to the LRU and queued
for IO. The process is also inserting pages into the page cache and so is
calling radix_preload and entering the page allocator. When SLUB is used,
this can result in direct compaction finding the page that was just added
to the LRU but still locked by the current process leading to deadlock.

This patch avoids locking pages in the direct compaction patch because
we cannot be certain the current process is not holding the lock. To do
this, PF_MEMALLOC is set for compaction. Compaction should not be
re-entering the page allocator and so will not breach watermarks through
the use of ALLOC_NO_WATERMARKS.

Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/migrate.c    |   17 +++++++++++++++++
 mm/page_alloc.c |    3 +++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index b8a32da..7c3e307 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -644,6 +644,23 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	if (!trylock_page(page)) {
 		if (!force)
 			goto move_newpage;
+
+		/*
+		 * It's not safe for direct compaction to call lock_page.
+		 * For example, during page readahead pages are added locked
+		 * to the LRU. Later, when the IO completes the pages are
+		 * marked uptodate and unlocked. However, the queueing
+		 * could be merging multiple pages for one bio (e.g.
+		 * mpage_readpages). If an allocation happens for the
+		 * second or third page, the process can end up locking
+		 * the same page twice and deadlocking. Rather than
+		 * trying to be clever about what pages can be locked,
+		 * avoid the use of lock_page for direct compaction
+		 * altogether.
+		 */
+		if (current->flags & PF_MEMALLOC)
+			goto move_newpage;
+
 		lock_page(page);
 	}
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index aede3a4..a5313f1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1809,12 +1809,15 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	bool sync_migration)
 {
 	struct page *page;
+	struct task_struct *p = current;
 
 	if (!order || compaction_deferred(preferred_zone))
 		return NULL;
 
+	p->flags |= PF_MEMALLOC;
 	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
 						nodemask, sync_migration);
+	p->flags &= ~PF_MEMALLOC;
 	if (*did_some_progress != COMPACT_SKIPPED) {
 
 		/* Page migration frees to the PCP lists but we want merging */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
