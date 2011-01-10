Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 45BF56B0087
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 12:26:37 -0500 (EST)
Date: Mon, 10 Jan 2011 17:26:10 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: mmotm hangs on compaction lock_page
Message-ID: <20110110172609.GA11932@csn.ul.ie>
References: <alpine.LSU.2.00.1101061632020.9601@sister.anvils> <20110107145259.GK29257@csn.ul.ie> <20110107175705.GL29257@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110107175705.GL29257@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 07, 2011 at 05:57:05PM +0000, Mel Gorman wrote:
> On Fri, Jan 07, 2011 at 02:52:59PM +0000, Mel Gorman wrote:
> > On Thu, Jan 06, 2011 at 05:20:25PM -0800, Hugh Dickins wrote:
> > > Hi Mel,
> > > 
> > > Here are the traces of two concurrent "cp -a kerneltree elsewhere"s
> > > which have hung on mmotm: in limited RAM, on a PowerPC
> > 
> > How limited in RAM and how many CPUs?
> > 
> > > - I don't have
> > > an explanation for why I can reproduce it in minutes on that box but
> > > never yet on the x86s.
> > > 
> > 
> > Strongest bet is simply that compaction is not triggering for you on the
> > x86 boxes. Monitor "grep compact /proc/vmstat" on the two machines and
> > see if the counters are growing on powerpc and not on x86. I'm trying to
> > reproduce the problem locally but no luck yet.
> > 
> > > Perhaps we can get it to happen with just one cp: the second cp here
> > > seemed to be deadlocking itself, unmap_and_move()'s force lock_page
> > > waiting on a page which its page cache readahead already holds locked.
> > > 
> > > cp              D 000000000fea3110     0 18874  18873 0x00008010
> > > Call Trace:
> > >  .__switch_to+0xcc/0x110
> > >  .schedule+0x670/0x7b0
> > >  .io_schedule+0x50/0x8c
> > >  .sync_page+0x84/0xa0
> > >  .sync_page_killable+0x10/0x48
> > >  .__wait_on_bit_lock+0x9c/0x140
> > >  .__lock_page_killable+0x74/0x98
> > >  .do_generic_file_read+0x2b0/0x504
> > >  .generic_file_aio_read+0x214/0x29c
> > >  .do_sync_read+0xac/0x10c
> > >  .vfs_read+0xd0/0x1a0
> > >  .SyS_read+0x58/0xa0
> > >  syscall_exit+0x0/0x40
> > >  syscall_exit+0x0/0x40
> > > 
> > > cp              D 000000000fea3110     0 18876  18875 0x00008010
> > > Call Trace:
> > >  0xc000000001343b68 (unreliable)
> > >  .__switch_to+0xcc/0x110
> > >  .schedule+0x670/0x7b0
> > >  .io_schedule+0x50/0x8c
> > >  .sync_page+0x84/0xa0
> > >  .__wait_on_bit_lock+0x9c/0x140
> > >  .__lock_page+0x74/0x98
> > >  .unmap_and_move+0xfc/0x380
> > >  .migrate_pages+0xbc/0x18c
> > >  .compact_zone+0xbc/0x400
> > >  .compact_zone_order+0xc8/0xf4
> > >  .try_to_compact_pages+0x104/0x1b8
> > >  .__alloc_pages_direct_compact+0xa8/0x228
> > >  .__alloc_pages_nodemask+0x42c/0x730
> > >  .allocate_slab+0x84/0x168
> > >  .new_slab+0x58/0x198
> > >  .__slab_alloc+0x1ec/0x430
> > >  .kmem_cache_alloc+0x7c/0xe0
> > >  .radix_tree_preload+0x94/0x140
> > >  .add_to_page_cache_locked+0x70/0x1f0
> > >  .add_to_page_cache_lru+0x50/0xac
> > >  .mpage_readpages+0xcc/0x198
> > >  .ext3_readpages+0x28/0x40
> > >  .__do_page_cache_readahead+0x1ac/0x2ac
> > >  .ra_submit+0x28/0x38
> > 
> > Something is odd right here. I would have expected entries in the
> > calli stack containing
> > 
> >  .ondemand_readahead
> >  .page_cache_sync_readahead
> > 
> > I am going to have to assume these functions were really called
> > otherwise the ra_submit is a mystery :(
> > 
> > >  .do_generic_file_read+0xe8/0x504
> > >  .generic_file_aio_read+0x214/0x29c
> > >  .do_sync_read+0xac/0x10c
> > >  .vfs_read+0xd0/0x1a0
> > >  .SyS_read+0x58/0xa0
> > >  syscall_exit+0x0/0x40
> > > 
> > > I haven't made a patch for it, just hacked unmap_and_move() to say
> > > "if (!0)" instead of "if (!force)" to get on with my testing.  I expect
> > > you'll want to pass another arg down to migrate_pages() to prevent
> > > setting force, or give it some flags, or do something with PF_MEMALLOC.
> > > 
> > 
> > I tend to agree but I'm failing to see how it might be happening right now.
> > The callchain looks something like
> > 
> > do_generic_file_read
> >    # page is not found
> >    page_cache_sync_readahead
> >       ondemand_readahead
> >          ra_submit
> >             __do_page_cache_readahead
> >                # Allocates a bunch of pages
> >                # Sets PageReadahead. Otherwise the pages  initialised
> >                # and they are not on the LRU yet
> >                read_pages
> >                   # Calls mapping->readpages which calls mpage_readpages
> >                   mpage_readpages
> >                      # For the list of pages (index initialised), add
> >                      # each of them to the LRU. Adding to the LRU
> >                      # locks the page and should return the page
> >                      # locked.
> >                      add_to_page_cache_lru
> >                      # sets PageSwapBacked
> >                         add_to_page_cache
> >                            # locks page
> >                            add_to_page_cache_locked
> >                               # preloads radix tree
> >                                  radix_tree_preload
> >                                  # DEADLOCK HERE. This is what does not
> >                                  # make sense. Compaction could not be
> >                                  # be finding the page on the LRU as
> >                                  # lru_cache_add_file() has not been
> >                                  # called yet for this page
> > 
> > So I don't think we are locking on the same page.
> > 
> > Here is a possibility. mpage_readpages() is reading ahead so there are obviously
> > pages that are not Uptodate. It queues these for asynchronous read with
> > block_read_full_page(), returns and adds the page to the LRU (so compaction
> > is now able to find it). IO starts at some time in the future with the page
> > still locked and gets unlocked at the end of IO by end_buffer_async_read().
> > 
> > Between when IO is queued and it completes, a new page is being added to
> > the LRU, the radix tree is loaded and compaction kicks off trying to
> > lock the same page that is not up to date yet. Something is preventing
> > the IO completing and the page being unlocked but I'm missing what that
> > might be.
> > 
> > Does this sound plausible? I'll keep looking but I wanted to see if
> > someone spotted quickly a major flaw in the reasoning or have a quick
> > guess as to why the page might not be getting unlocked at the end of IO
> > properly.
> > 
> 

I got this reproduced locally and it is related to readahead pages but
the other patch I posted was garbage. This patch fixes makes the problem
unreprodible for me at least. I still don't have the exact reason why pages are
not getting unlocked by IO completion but suspect it's because the same process
completes the IO that started it. If it's deadlocked, it never finishes the IO.

==== CUT HERE ====
mm: compaction: Avoid potential deadlock for readahead pages and direct compaction

Hugh Dickins reported that two instances of cp were locking up when
running on ppc64 in a memory constrained environment. The deadlock
appears to apply to readahead pages. When reading ahead, the pages are
added locked to the LRU and queued for IO. The process is also inserting
pages into the page cache and so is calling radix_preload and entering
the page allocator. When SLUB is used, this can result in direct
compaction finding the page that was just added to the LRU but still
locked by the current process leading to deadlock.

This patch avoids locking pages for migration that might already be
locked by the current process. Ideally it would only apply for direct
compaction but compaction does not set PF_MEMALLOC so there is no way
currently of identifying a process in direct compaction. A process-flag
could be added but is likely to be overkill.

Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/migrate.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index b8a32da..d88288f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -644,6 +644,19 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 	if (!trylock_page(page)) {
 		if (!force)
 			goto move_newpage;
+
+		/*
+		 * During page readahead, pages are added locked to the LRU
+		 * and marked up to date when the IO completes. As part of
+		 * readahead, a process can reload the radix tree, enter
+		 * page reclamation, direct compaction and migrate page.
+		 * Hence, during readahead, a process can end up trying to
+		 * lock the same page twice leading to deadlock. Avoid this
+		 * situation.
+		 */
+		if (PageMappedToDisk(page) && !PageUptodate(page))
+			goto move_newpage;
+
 		lock_page(page);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
