Date: Wed, 22 Sep 2004 14:24:06 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: OOM killer being triggered too soon
Message-ID: <20040922172406.GD8197@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@osdl.org>
Cc: Barry Silverman <barry@disus.com>
List-ID: <linux-mm.kvack.org>

Hi fellows,

So thanks to Barry who has been collaborative
we found a workaround for his problems.

He is seeing spurious OOM kills:

Sep 14 20:16:18 dhcpaq kernel: oom-killer: gfp_mask=0x1d2
Sep 14 20:16:19 dhcpaq kernel: DMA per-cpu:
Sep 14 20:16:19 dhcpaq kernel: cpu 0 hot: low 2, high 6, batch 1
Sep 14 20:16:19 dhcpaq kernel: cpu 0 cold: low 0, high 2, batch 1
Sep 14 20:16:19 dhcpaq kernel: Normal per-cpu:
Sep 14 20:16:19 dhcpaq kernel: cpu 0 hot: low 12, high 36, batch 6
Sep 14 20:16:19 dhcpaq kernel: cpu 0 cold: low 0, high 12, batch 6
Sep 14 20:16:19 dhcpaq kernel: HighMem per-cpu: empty
Sep 14 20:16:19 dhcpaq kernel:
Sep 14 20:16:19 dhcpaq kernel: Free pages:         420kB (0kB HighMem)
Sep 14 20:16:19 dhcpaq kernel: Active:27885 inactive:32 dirty:0 writeback:0
unstable:0 free:105 slab:1027 mapped:27889 pagetables:177
		              ^^^^^^^^^^^^^

Sep 14 20:16:19 dhcpaq kernel: DMA free:44kB min:44kB low:88kB high:132kB
active:12384kB inactive:32kB present:16384kB pages_scanned:0
all_unreclaimable? no
Sep 14 20:16:19 dhcpaq kernel: protections[]: 0 0 0
Sep 14 20:16:21 dhcpaq kernel: Normal free:376kB min:300kB low:600kB
high:900kB active:99156kB inactive:96kB present:106496kB pages_scanned:0
all_unreclaimable? no
Sep 14 20:16:21 dhcpaq kernel: protections[]: 0 0 0
Sep 14 20:16:21 dhcpaq kernel: HighMem free:0kB min:128kB low:256kB
high:384kB active:0kB inactive:0kB present:0kB pages_scanned:0
all_unreclaimable? no
Sep 14 20:16:21 dhcpaq kernel: protections[]: 0 0 0
Sep 14 20:16:21 dhcpaq kernel: DMA: 1*4kB 1*8kB 0*16kB 1*32kB 0*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44kB
Sep 14 20:16:21 dhcpaq kernel: Normal: 20*4kB 3*8kB 1*16kB 0*32kB 0*64kB
0*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 376kB
Sep 14 20:16:21 dhcpaq kernel: HighMem: empty
Sep 14 20:16:21 dhcpaq kernel: nr_free_swap_pages: 96406
Sep 14 20:16:21 dhcpaq kernel: Swap cache: add 49668, delete 42859, find
20428/23905, race 0+1
Sep 14 20:16:21 dhcpaq kernel: Out of Memory: Killed process 1147 (bk).

Adding back the "if (nr_swap_pages) return" check to out_of_memory() fixed
the problems for him, but as he noted:


**********
[PATCH] oom killer: ignore free swapspace
                                                                                                                                                                                   
From: William Lee Irwin III <wli@holomorphy.com>
                                                                                                                                                                                   
During stress testing at Oracle to determine the maximum number of clients
2.6 can service, it was discovered that the failure mode of excessive
numbers of clients was kernel deadlock.  The following patch removes the
check if (nr_swap_pages > 0) from out_of_memory() as this heuristic fails
to detect memory exhaustion due to pinned allocations, directly causing the
aforementioned deadlock.
*********

What I think about it is that we should trigger the oom killer
based on failure/success rate of all reclaiming steps, including
pte unmap's. 

What we do now is to not oom kill if we successfully free SWAP_CLUSTER_MAX pages.
Thats too fragile.

If we make progress unmapping pte's from pages/swapping out pages 
we should also not trigger the oom killer. 

Its a threshold. We should increase the threshold "its time to OOM kill", 
but not much, otherwise we fail to OOM kill. Its kinda tricky.

I dont an idea of how to do that in a nice and "balanced" way, 
still thinking, ideas are welcome.

While investigating it I found out that, at refill_inactive_zone, we dont 
move mapped anon, swapcache pages to the inactive list if nr_swap_pages is zero.

We should move them because they already have allocated on-swap address.

Andrew, please apply.

--- linux-2.6.9-rc1-mm5/mm/vmscan.c.orig	2004-09-22 15:25:31.800412784 -0300
+++ linux-2.6.9-rc1-mm5/mm/vmscan.c	2004-09-22 15:25:34.618984296 -0300
@@ -722,7 +722,8 @@
 		list_del(&page->lru);
 		if (page_mapped(page)) {
 			if (!reclaim_mapped ||
-			    (total_swap_pages == 0 && PageAnon(page)) ||
+			    (total_swap_pages == 0 && PageAnon(page) && 
+				!PageSwapCache(page)) ||
 			    page_referenced(page, 0)) {
 				list_add(&page->lru, &l_active);
 				continue;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
