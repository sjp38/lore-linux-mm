Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CD5B4620097
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 23:03:54 -0400 (EDT)
Date: Thu, 8 Apr 2010 13:03:47 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: PROBLEM + POSS FIX: kernel stack overflow, xfs, many disks,
 heavy write load, 8k stack, x86-64
Message-ID: <20100408030347.GM11036@dastard>
References: <4BBC6719.7080304@humyo.com>
 <20100407140523.GJ11036@dastard>
 <4BBCAB57.3000106@humyo.com>
 <20100407234341.GK11036@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100407234341.GK11036@dastard>
Sender: owner-linux-mm@kvack.org
To: John Berthels <john@humyo.com>
Cc: linux-kernel@vger.kernel.org, Nick Gregory <nick@humyo.com>, Rob Sanderson <rob@humyo.com>, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 08, 2010 at 09:43:41AM +1000, Dave Chinner wrote:
> [added linux-mm]

Now really added linux-mm.

And there's a patch attached that stops direct reclaim from writing
back dirty pages - it seems to work fine from some rough testing
I've done. Perhaps you might want to give it a spin on a
test box, John?

> On Wed, Apr 07, 2010 at 04:57:11PM +0100, John Berthels wrote:
> > Dave Chinner wrote:
> > >I'm not seeing stacks deeper than about 5.6k on XFS under heavy write
> > >loads. That's nowhere near blowing an 8k stack, so there must be
> > >something special about what you are doing. Can you post the stack
> > >traces that are being generated for the deepest stack generated -
> > >/sys/kernel/debug/tracing/stack_trace should contain it.
> > Appended below. That doesn't seem to reach 8192 but the box it's
> > from has logged:
> > 
> > [74649.579386] apache2 used greatest stack depth: 7024 bytes left
> > 
> > full dmesg (gzipped) attached.
> > >What is generating the write load?
> > 
> > WebDAV PUTs in a modified mogilefs cluster, running
> > apache-mpm-worker (threaded) as the DAV server. The write load is a
> > mix of internet-upload speed writers trickling files up and some
> > local fast replicators copying from elsewhere in the cluster. mpm
> > worker cfg is:
> > 
> >        ServerLimit 20
> >        StartServers 5
> >        MaxClients 300
> >        MinSpareThreads 25
> >        MaxSpareThreads 75
> >        ThreadsPerChild 30
> >        MaxRequestsPerChild 0
> > 
> > File sizes are a mix of small to large (4GB+). Each disk is exported
> > as a mogile device, so it's possible for mogile to pound a single
> > disk with lots of write activity (if the random number generator
> > decides to put lots of files on that device at the same time).
> > 
> > We're also seeing occasional slowdowns + high load avg (up to ~300,
> > i.e. MaxClients) with a corresponding number of threads in D state.
> > (This slowdown + high load avg seems to correlate with what would
> > have previously caused a panic on the THREAD_ORDER 1, but not 100%
> > sure).
> > 
> > As you can see from the dmesg, this trips the "task xxx blocked for
> > more than 120 seconds." on some of the threads.
> > 
> > Don't know if that's related to the stack issue or to be expected
> > under the load.
> 
> It looks to be caused by direct memory reclaim trying to clean pages
> with a significant amount of stack already in use. basically there
> is not enough stack space left for the XFS ->writepage path to
> execute in. I can't see any fast fix for this occurring, so you are
> probably best to run with a larger stack for the moment.
> 
> As it is, I don't think direct memory reclim should be cleaning
> dirty file pages - it should be leaving that to the writeback
> threads (which are far more efficient at it) or, as a
> last resort, kswapd. Direct memory reclaim is invoked with an
> unknown amount of stack already in use, so there is never any
> guarantee that there is enough stack space left to enter the
> ->writepage path of any filesystem.
> 
> MM-folk - have there been any changes recently to writeback of
> pages from direct reclaim that may have caused this,
> or have we just been lucky for a really long time?
> 
> Cheers,
> 
> Dave.
> 
> >        Depth    Size   Location    (47 entries)
> >        -----    ----   --------
> >  0)     7568      16   mempool_alloc_slab+0x16/0x20
> >  1)     7552     144   mempool_alloc+0x65/0x140
> >  2)     7408      96   get_request+0x124/0x370
> >  3)     7312     144   get_request_wait+0x29/0x1b0
> >  4)     7168      96   __make_request+0x9b/0x490
> >  5)     7072     208   generic_make_request+0x3df/0x4d0
> >  6)     6864      80   submit_bio+0x7c/0x100
> >  7)     6784      96   _xfs_buf_ioapply+0x128/0x2c0 [xfs]
> >  8)     6688      48   xfs_buf_iorequest+0x75/0xd0 [xfs]
> >  9)     6640      32   _xfs_buf_read+0x36/0x70 [xfs]
> > 10)     6608      48   xfs_buf_read+0xda/0x110 [xfs]
> > 11)     6560      80   xfs_trans_read_buf+0x2a7/0x410 [xfs]
> > 12)     6480      80   xfs_btree_read_buf_block+0x5d/0xb0 [xfs]
> > 13)     6400      80   xfs_btree_lookup_get_block+0x84/0xf0 [xfs]
> > 14)     6320     176   xfs_btree_lookup+0xd7/0x490 [xfs]
> > 15)     6144      16   xfs_alloc_lookup_eq+0x19/0x20 [xfs]
> > 16)     6128      96   xfs_alloc_fixup_trees+0xee/0x350 [xfs]
> > 17)     6032     144   xfs_alloc_ag_vextent_near+0x916/0xb30 [xfs]
> > 18)     5888      32   xfs_alloc_ag_vextent+0xe5/0x140 [xfs]
> > 19)     5856      96   xfs_alloc_vextent+0x49f/0x630 [xfs]
> > 20)     5760     160   xfs_bmbt_alloc_block+0xbe/0x1d0 [xfs]
> > 21)     5600     208   xfs_btree_split+0xb3/0x6a0 [xfs]
> > 22)     5392      96   xfs_btree_make_block_unfull+0x151/0x190 [xfs]
> > 23)     5296     224   xfs_btree_insrec+0x39c/0x5b0 [xfs]
> > 24)     5072     128   xfs_btree_insert+0x86/0x180 [xfs]
> > 25)     4944     352   xfs_bmap_add_extent_delay_real+0x41e/0x1660 [xfs]
> > 26)     4592     208   xfs_bmap_add_extent+0x41c/0x450 [xfs]
> > 27)     4384     448   xfs_bmapi+0x982/0x1200 [xfs]
> > 28)     3936     256   xfs_iomap_write_allocate+0x248/0x3c0 [xfs]
> > 29)     3680     208   xfs_iomap+0x3d8/0x410 [xfs]
> > 30)     3472      32   xfs_map_blocks+0x2c/0x30 [xfs]
> > 31)     3440     256   xfs_page_state_convert+0x443/0x730 [xfs]
> > 32)     3184      64   xfs_vm_writepage+0xab/0x160 [xfs]
> > 33)     3120     384   shrink_page_list+0x65e/0x840
> > 34)     2736     528   shrink_zone+0x63f/0xe10
> > 35)     2208     112   do_try_to_free_pages+0xc2/0x3c0
> > 36)     2096     128   try_to_free_pages+0x77/0x80
> > 37)     1968     240   __alloc_pages_nodemask+0x3e4/0x710
> > 38)     1728      48   alloc_pages_current+0x8c/0xe0
> > 39)     1680      16   __get_free_pages+0xe/0x50
> > 40)     1664      48   __pollwait+0xca/0x110
> > 41)     1616      32   unix_poll+0x28/0xc0
> > 42)     1584      16   sock_poll+0x1d/0x20
> > 43)     1568     912   do_select+0x3d6/0x700
> > 44)      656     416   core_sys_select+0x18c/0x2c0
> > 45)      240     112   sys_select+0x4f/0x110
> > 46)      128     128   system_call_fastpath+0x16/0x1b

-- 
Dave Chinner
david@fromorbit.com

mm: disallow direct reclaim page writeback

From: Dave Chinner <dchinner@redhat.com>

When we enter direct reclaim we may have used an arbitrary amount of stack
space, and hence entering the filesystem to do writeback can then lead to
stack overruns.

Writeback from direct reclaim is a bad idea, anyway. The background flusher
threads should be taking care of cleaning dirty pages, and direct reclaim will
kick them if they aren't already doing work. If direct reclaim is also calling
->writepage, it will cause the IO patterns from the background flusher threads
to be upset by LRU-order writeback from pageout(). Having competing sources of
IO trying to clean pages on the same backing device reduces throughput by
increasing the amount of seeks that the backing device has to do to write back
the pages.

Hence for direct reclaim we should not allow ->writepages to be entered at all.
Set up the relevant scan_control structures to enforce this, and prevent
sc->may_writepage from being set in other places in the direct reclaim path in
response to other events.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 mm/vmscan.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f293372..3c194f4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1829,10 +1829,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 * writeout.  So in laptop mode, write out the whole world.
 		 */
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
-		if (total_scanned > writeback_threshold) {
+		if (total_scanned > writeback_threshold)
 			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);
-			sc->may_writepage = 1;
-		}
 
 		/* Take a nap, wait for some writeback to complete */
 		if (!sc->hibernation_mode && sc->nr_scanned &&
@@ -1874,7 +1872,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 {
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
-		.may_writepage = !laptop_mode,
+		.may_writepage = 0,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
 		.may_swap = 1,
@@ -1896,7 +1894,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						struct zone *zone, int nid)
 {
 	struct scan_control sc = {
-		.may_writepage = !laptop_mode,
+		.may_writepage = 0,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.swappiness = swappiness,
@@ -1929,7 +1927,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 {
 	struct zonelist *zonelist;
 	struct scan_control sc = {
-		.may_writepage = !laptop_mode,
+		.may_writepage = 0,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
@@ -2570,7 +2568,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	struct reclaim_state reclaim_state;
 	int priority;
 	struct scan_control sc = {
-		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
+		.may_writepage = (current_is_kswapd() &&
+					(zone_reclaim_mode & RECLAIM_WRITE)),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.may_swap = 1,
 		.nr_to_reclaim = max_t(unsigned long, nr_pages,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
