Date: Mon, 14 Apr 2003 19:00:57 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.67-mm3
Message-ID: <20030415020057.GC706@holomorphy.com>
References: <20030414015313.4f6333ad.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030414015313.4f6333ad.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 14, 2003 at 01:53:13AM -0700, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.67/2.5.67-mm3/
> 
> A bunch of new fixes, and a framebuffer update.  This should work a bit
> better than -mm2.


If one's goal is to free highmem pages, shrink_slab() is an ineffective
method of recovering them, as slab pages are all ZONE_NORMAL or ZONE_DMA.
Hence, this "FIXME: do not do for zone highmem". Presumably this is a
question of policy, as highmem allocations may be satisfied by reaping
slab pages and handing them back; but the FIXME says what we should do.


diff -urpN mm3-2.5.67-1/mm/vmscan.c mm3-2.5.67-2/mm/vmscan.c
--- mm3-2.5.67-1/mm/vmscan.c	2003-04-14 18:08:15.000000000 -0700
+++ mm3-2.5.67-2/mm/vmscan.c	2003-04-14 18:16:41.000000000 -0700
@@ -134,11 +134,9 @@ void remove_shrinker(struct shrinker *sh
  * If the vm encounted mapped pages on the LRU it increase the pressure on
  * slab to avoid swapping.
  *
- * FIXME: do not do for zone highmem
- *
  * We do weird things to avoid (scanned*seeks*entries) overflowing 32 bits.
  */
-static int shrink_slab(long scanned,  unsigned int gfp_mask)
+static int shrink_slab(long scanned, unsigned int gfp_mask)
 {
 	struct shrinker *shrinker;
 	long pages;
@@ -835,7 +833,8 @@ try_to_free_pages(struct zone *classzone
 
 		/* Take a nap, wait for some writeback to complete */
 		blk_congestion_wait(WRITE, HZ/10);
-		shrink_slab(total_scanned, gfp_mask);
+		if (classzone - classzone->zone_pgdat->node_zones < ZONE_HIGHMEM)
+			shrink_slab(total_scanned, gfp_mask);
 	}
 	if (gfp_mask & __GFP_FS)
 		out_of_memory();
@@ -895,7 +894,8 @@ static int balance_pgdat(pg_data_t *pgda
 				max_scan = SWAP_CLUSTER_MAX;
 			to_free -= shrink_zone(zone, max_scan, GFP_KERNEL,
 					to_reclaim, &nr_mapped, ps, priority);
-			shrink_slab(max_scan + nr_mapped, GFP_KERNEL);
+			if (i < ZONE_HIGHMEM)
+				shrink_slab(max_scan + nr_mapped, GFP_KERNEL);
 			if (zone->all_unreclaimable)
 				continue;
 			if (zone->pages_scanned > zone->present_pages * 2)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
