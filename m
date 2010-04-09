Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F2F8B6B0214
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 07:39:53 -0400 (EDT)
Date: Fri, 9 Apr 2010 07:38:50 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: PROBLEM + POSS FIX: kernel stack overflow, xfs, many disks,
 heavy write load, 8k stack, x86-64
Message-ID: <20100409113850.GE13327@think>
References: <4BBC6719.7080304@humyo.com>
 <20100407140523.GJ11036@dastard>
 <4BBCAB57.3000106@humyo.com>
 <20100407234341.GK11036@dastard>
 <20100408030347.GM11036@dastard>
 <4BBDC92D.8060503@humyo.com>
 <4BBDEC9A.9070903@humyo.com>
 <20100408233837.GP11036@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100408233837.GP11036@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: John Berthels <john@humyo.com>, linux-kernel@vger.kernel.org, Nick Gregory <nick@humyo.com>, Rob Sanderson <rob@humyo.com>, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 09, 2010 at 09:38:37AM +1000, Dave Chinner wrote:
> On Thu, Apr 08, 2010 at 03:47:54PM +0100, John Berthels wrote:
> > John Berthels wrote:
> > >I'll reply again after it's been running long enough to draw conclusions.
> > We're getting pretty close on the 8k stack on this box now. It's
> > running 2.6.33.2 + your patch, with THREAD_ORDER 1, stack tracing
> > and CONFIG_LOCKDEP=y. (Sorry that LOCKDEP is on, please advise if
> > that's going to throw the figures and we'll restart the test systems
> > with new kernels).
> > 
> > This is significantly more than 5.6K, so it shows a potential
> > problem? Or is 720 bytes enough headroom?
> > 
> > jb
> > 
> > [ 4005.541869] apache2 used greatest stack depth: 2480 bytes left
> > [ 4005.541973] apache2 used greatest stack depth: 2240 bytes left
> > [ 4005.542070] apache2 used greatest stack depth: 1936 bytes left
> > [ 4005.542614] apache2 used greatest stack depth: 1616 bytes left
> > [ 5531.406529] apache2 used greatest stack depth: 720 bytes left
> > 
> > $ cat /sys/kernel/debug/tracing/stack_trace
> >        Depth    Size   Location    (55 entries)
> >        -----    ----   --------
> >  0)     7440      48   add_partial+0x26/0x90
> >  1)     7392      64   __slab_free+0x1a9/0x380
> >  2)     7328      64   kmem_cache_free+0xb9/0x160
> >  3)     7264      16   free_buffer_head+0x25/0x50
> >  4)     7248      64   try_to_free_buffers+0x79/0xc0
> >  5)     7184     160   xfs_vm_releasepage+0xda/0x130 [xfs]
> >  6)     7024      16   try_to_release_page+0x33/0x60
> >  7)     7008     384   shrink_page_list+0x585/0x860
> >  8)     6624     528   shrink_zone+0x636/0xdc0
> >  9)     6096     112   do_try_to_free_pages+0xc2/0x3c0
> > 10)     5984     112   try_to_free_pages+0x64/0x70
> > 11)     5872     256   __alloc_pages_nodemask+0x3d2/0x710
> > 12)     5616      48   alloc_pages_current+0x8c/0xe0
> > 13)     5568      32   __page_cache_alloc+0x67/0x70
> > 14)     5536      80   find_or_create_page+0x50/0xb0
> > 15)     5456     160   _xfs_buf_lookup_pages+0x145/0x350 [xfs]
> > 16)     5296      64   xfs_buf_get+0x74/0x1d0 [xfs]
> > 17)     5232      48   xfs_buf_read+0x2f/0x110 [xfs]
> > 18)     5184      80   xfs_trans_read_buf+0x2bf/0x430 [xfs]
> 
> We're entering memory reclaim with almost 6k of stack already in
> use. If we get down into the IO layer and then have to do a memory
> reclaim, then we'll have even less stack to work with. It looks like
> memory allocation needs at least 2KB of stack to work with now,
> so if we enter anywhere near the top of the stack we can blow it...

shrink_zone on my box isn't 500 bytes, but lets try the easy stuff
first.  This is against .34, if you have any trouble applying to .32,
just add the word noinline after the word static on the function
definitions.

This makes shrink_zone disappear from my check_stack.pl output.
Basically I think the compiler is inlining the shrink_active_zone and
shrink_inactive_zone code into shrink_zone.

-chris

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 79c8098..c70593e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -620,7 +620,7 @@ static enum page_references page_check_references(struct page *page,
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
-static unsigned long shrink_page_list(struct list_head *page_list,
+static noinline unsigned long shrink_page_list(struct list_head *page_list,
 					struct scan_control *sc,
 					enum pageout_io sync_writeback)
 {
@@ -1121,7 +1121,7 @@ static int too_many_isolated(struct zone *zone, int file,
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
-static unsigned long shrink_inactive_list(unsigned long max_scan,
+static noinline unsigned long shrink_inactive_list(unsigned long max_scan,
 			struct zone *zone, struct scan_control *sc,
 			int priority, int file)
 {
@@ -1341,7 +1341,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
 
-static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
+static noinline void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			struct scan_control *sc, int priority, int file)
 {
 	unsigned long nr_taken;
@@ -1504,7 +1504,7 @@ static int inactive_list_is_low(struct zone *zone, struct scan_control *sc,
 		return inactive_anon_is_low(zone, sc);
 }
 
-static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
+static noinline unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	struct zone *zone, struct scan_control *sc, int priority)
 {
 	int file = is_file_lru(lru);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
