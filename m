Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 420598D0039
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 13:48:22 -0400 (EDT)
Date: Sun, 20 Mar 2011 18:47:50 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction beware writeback
Message-ID: <20110320174750.GA5653@random.random>
References: <alpine.LSU.2.00.1103192318100.1877@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1103192318100.1877@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sat, Mar 19, 2011 at 11:27:38PM -0700, Hugh Dickins wrote:
> I notice there's a Bug 31142 "Large write to USB stick freezes"
> discussion happening (which I've not digested), for which Andrea
> is proposing a patch which reminds me of this one.  Thought I'd
> better throw this into the mix for consideration.

With regard to that bug:

https://bugzilla.kernel.org/attachment.cgi?id=51262

there's no sign of __wait_on_bit called by migrate_pages. I think the
problem there are the ->writepage run on udf to writeout dirty pages
(to retry migration in the next iteration of the loop when the page
isn't dirty anymore), which hopefully it's solved by the patch I sent.

> D  loop0:
> schedule +0x670
> io_schedule +0x50
> sync_page +0x84
> __wait_on_bit +0x90
> wait_on_page_bit +0xa4
> unmap_and_move +0x180
> migrate_pages +0xbc
> compact_zone +0xbc
> compact_zone_order +0xc8
> try_to_compact_pages +0x104
> __alloc_pages_direct_compact +0xc0
> __alloc_pages_nodemask +0x68c
> allocate_slab +0x84
> new_slab +0x58
> __slab_alloc +0x1ec
> kmem_cache_alloc +0x7c
> radix_tree_preload +0x94
> add_to_page_cache_locked +0x78
> shmem_getpage +0x208
> pagecache_write_begin +0x2c
> do_lo_send_aops +0xc0
> do_bio_filebacked +0x11c
> loop_thread +0x204
> kthread +0xac
> kernel_thread +0x54

So your patch will avoid waiting above in writeback if called by
direct compaction like above, agreed (currently we only avoid to call
lock_page but we could still wait in wait_on_page_writeback if force=1
goes on at the third pass of the migrate_pages loop). This seems a
separate issue to the last trace posted in bug 31142 as there was no
wait_on_bit in that last trace.

Interesting that slab allocates with order > 0 an object that is <4096
bytes. Is this related to slab_break_gfp_order? The comment talks
about fragmentation resistance in low memory, if that's the same
fragmentation that anti-frag solves, is this logic still actual? I
guess we still need it for cache coloring. However I noticed there's
no fallback to that, so once kmem_cache_create decided that an optimal
gfporder is > 0 (even if it doesn't need to be > 0) if the order 1
allocation fails, kmem_cache_alloc will fail too without fallback to
order 0. It could be more reliable than that.

A large allocation if nothing else reduces the frequency of gfp calls.

> So I've extended your earlier PF_MEMALLOC patch to prevent waiting for
> writeback as well as waiting for pagelock.  And I've never seen the
> hang again since putting this patch in.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---

This change looks good to me, it will make compaction a little less
reliable with regard to writeback. You are still going to execute
->writepage on dirty pages though (except for __GFP_NO_KSWAPD
allocations that signals the fact they don't need to be reliable with
my last patch for bug 31142 and foces sync=0 and have that sync
parameter checked before calling ->writepage too).

compaction usually has an huge amount of "source" memory to move, in
the destination space, so it's not so good that migration is so
aggressive and blocks when there may be another couple of contiguous
source page to move without waiting. Ideally we should move to the
next block of source pages in compaction, before setting force=1 in a
final pass. We insist a lot in migrate_pages when breaking the loop
after 1 pass could be enough, and then it should be compaction that if
it fails migration on all candidate source pages, tries an "harder
migrate" in a second pass. We could achieve that by having compaction
twiddle with the sync bit instead of the caller and only run one pass
of migrate when sync = 0. That's a bit larger change though and it may
consume more cpu in compaction (compaction loop not so cheap), so I'm
unsure if it would be an overall improvement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
