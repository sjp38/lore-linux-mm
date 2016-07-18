Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id CED4E6B025E
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 08:11:26 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so112865814lfw.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 05:11:26 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id m1si14470146wme.56.2016.07.18.05.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 05:11:25 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 9D4171C15EE
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 13:11:24 +0100 (IST)
Date: Mon, 18 Jul 2016 13:11:22 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/31] mm, vmscan: begin reclaiming pages on a per-node
 basis
Message-ID: <20160718121122.GQ9806@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-5-git-send-email-mgorman@techsingularity.net>
 <20160707011211.GA27987@js1304-P5Q-DELUXE>
 <20160707094808.GP11498@techsingularity.net>
 <20160708022852.GA2370@js1304-P5Q-DELUXE>
 <20160708100532.GC11498@techsingularity.net>
 <20160714062836.GB29676@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160714062836.GB29676@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 14, 2016 at 03:28:37PM +0900, Joonsoo Kim wrote:
> > That would be appreciated.
> 
> I make an artificial test case and test this series by using next tree
> (next-20160713) and found a regression.
> 
> My test setup is:
> 
> memory: 2048 mb
> movablecore: 1500 mb (imitates highmem system to test effect of skip logic)

This is not an equivalent test to highmem. Movable cannot store page table
pages and the highmem:lowmem ratio with this configuration is higher than
it should be. The OOM is still odd but the differences are worth
highlighting.

> fork invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
> fork cpuset=/ mems_allowed=0

Ok, high-order allocation failure for an allocation request that can
enter direct reclaim.

> Node 0 active_anon:79024kB inactive_anon:72kB active_file:569920kB inactive_file:1064260kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:1559112kB dirty:0kB writeback:0kB shmem:0kB shmem_thp
> : 0kB shmem_pmdmapped: 0kB anon_thp: 380kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
> Node 0 DMA free:2172kB min:204kB low:252kB high:300kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:2272kB kernel_stack:1216kB pagetables:2436kB bounce:0kB free_pcp:0k
> B local_pcp:0kB free_cma:0kB node_pages_scanned:15639736
> lowmem_reserve[]: 0 493 493 1955
> Node 0 DMA32 free:6372kB min:6492kB low:8112kB high:9732kB present:2080632kB managed:508600kB mlocked:0kB slab_reclaimable:27108kB slab_unreclaimable:74236kB kernel_stack:32752kB pagetables:67612kB bounce:
> 0kB free_pcp:112kB local_pcp:12kB free_cma:0kB node_pages_scanned:16302012
> lowmem_reserve[]: 0 0 0 1462
> Node 0 Normal free:0kB min:0kB low:0kB high:0kB present:18446744073708015752kB managed:0kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB lo
> cal_pcp:0kB free_cma:0kB node_pages_scanned:17033632
> lowmem_reserve[]: 0 0 0 11698
> Node 0 Movable free:29588kB min:19256kB low:24068kB high:28880kB present:1535864kB managed:1500964kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_
> pcp:208kB local_pcp:112kB free_cma:0kB node_pages_scanned:17725436

Present is corrupt but it's also interesting to note that
all_unreclaimable is true.

> lowmem_reserve[]: 0 0 0 0
> Node 0 DMA: 1*4kB (M) 1*8kB (U) 1*16kB (M) 1*32kB (M) 1*64kB (M) 2*128kB (UM) 1*256kB (M) 1*512kB (U) 1*1024kB (U) 0*2048kB 0*4096kB = 2172kB
> Node 0 DMA32: 60*4kB (ME) 45*8kB (UME) 24*16kB (ME) 13*32kB (UM) 12*64kB (UM) 6*128kB (UM) 6*256kB (M) 4*512kB (UM) 0*1024kB 0*2048kB 0*4096kB = 6520kB
> Node 0 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
> Node 0 Movable: 1*4kB (M) 130*8kB (M) 68*16kB (M) 30*32kB (M) 13*64kB (M) 9*128kB (M) 4*256kB (M) 0*512kB 1*1024kB (M) 1*2048kB (M) 5*4096kB (M) = 29652kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB

And it's true even though enough free pages are actually free so it's
not even trying to do the allocation.

The all_unreclaimable logic is related to the number of pages scanned
but currently pages skipped contributes to pages scanned. That is one
possibility. The other is that if all pages scanned are skipped then the
OOM killer can believe there is zero progress.

Try this to start with;

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3f06a7a0d135..c3e509c693bf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1408,7 +1408,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		isolate_mode_t mode, enum lru_list lru)
 {
 	struct list_head *src = &lruvec->lists[lru];
-	unsigned long nr_taken = 0;
+	unsigned long nr_taken = 0, total_skipped = 0;
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
 	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
 	unsigned long scan, nr_pages;
@@ -1462,10 +1462,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			if (!nr_skipped[zid])
 				continue;
 
+			total_skipped += nr_skipped[zid];
 			__count_zid_vm_events(PGSCAN_SKIP, zid, nr_skipped[zid]);
 		}
 	}
-	*nr_scanned = scan;
+	*nr_scanned = scan - total_skipped;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
 				    nr_taken, mode, is_file_lru(lru));
 	update_lru_sizes(lruvec, lru, nr_zone_taken, nr_taken);

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
