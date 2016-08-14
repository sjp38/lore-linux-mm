Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id DAC5A6B0253
	for <linux-mm@kvack.org>; Sun, 14 Aug 2016 06:44:53 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id n8so51128780ybn.2
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 03:44:53 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id v7si14889060wjm.289.2016.08.14.03.44.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Aug 2016 03:44:52 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i5so5960638wmg.2
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 03:44:52 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, vmscan: get rid of throttle_vm_writeout
Date: Sun, 14 Aug 2016 12:44:33 +0200
Message-Id: <1471171473-21418-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Marcelo Tosatti <mtosatti@redhat.com>, NeilBrown <neilb@suse.com>, Ondrej Kozina <okozina@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>

From: Michal Hocko <mhocko@suse.com>

throttle_vm_writeout has been introduced back in 2005 to fix OOMs caused
by excessive pageout activity during the reclaim. Too many pages could
be put under writeback therefore LRUs would be full of unreclaimable pages
until the IO completes and in turn the OOM killer could be invoked.

There have been some important changes introduced since then in the
reclaim path though. Writers are throttled by balance_dirty_pages
when initiating the buffered IO and later during the memory pressure,
the direct reclaim is throttled by wait_iff_congested if the node is
considered congested by dirty pages on LRUs and the underlying bdi
is congested by the queued IO. The kswapd is throttled as well if it
encounters pages marked for immediate reclaim or under writeback which
signals that that there are too many pages under writeback already.
Finally should_reclaim_retry does congestion_wait if the reclaim cannot
make any progress and there are too many dirty/writeback pages.

Another important aspect is that we do not issue any IO from the direct
reclaim context anymore. In a heavy parallel load this could queue a lot
of IO which would be very scattered and thus unefficient which would
just make the problem worse.

This three mechanisms should throttle and keep the amount of IO in a
steady state even under heavy IO and memory pressure so yet another
throttling point doesn't really seem helpful. Quite contrary, Mikulas
Patocka has reported that swap backed by dm-crypt doesn't work properly
because the swapout IO cannot make sufficient progress as the writeout
path depends on dm_crypt worker which has to allocate memory to perform
the encryption. In order to guarantee a forward progress it relies
on the mempool allocator. mempool_alloc(), however, prefers to use
the underlying (usually page) allocator before it grabs objects from
the pool. Such an allocation can dive into the memory reclaim and
consequently to throttle_vm_writeout. If there are too many dirty or
pages under writeback it will get throttled even though it is in fact a
flusher to clear pending pages.

[  345.352536] kworker/u4:0    D ffff88003df7f438 10488     6      2	0x00000000
[  345.352536] Workqueue: kcryptd kcryptd_crypt [dm_crypt]
[  345.352536]  ffff88003df7f438 ffff88003e5d0380 ffff88003e5d0380 ffff88003e5d8e80
[  345.352536]  ffff88003dfb3240 ffff88003df73240 ffff88003df80000 ffff88003df7f470
[  345.352536]  ffff88003e5d0380 ffff88003e5d0380 ffff88003df7f828 ffff88003df7f450
[  345.352536] Call Trace:
[  345.352536]  [<ffffffff818d466c>] schedule+0x3c/0x90
[  345.352536]  [<ffffffff818d96a8>] schedule_timeout+0x1d8/0x360
[  345.352536]  [<ffffffff81135e40>] ? detach_if_pending+0x1c0/0x1c0
[  345.352536]  [<ffffffff811407c3>] ? ktime_get+0xb3/0x150
[  345.352536]  [<ffffffff811958cf>] ? __delayacct_blkio_start+0x1f/0x30
[  345.352536]  [<ffffffff818d39e4>] io_schedule_timeout+0xa4/0x110
[  345.352536]  [<ffffffff8121d886>] congestion_wait+0x86/0x1f0
[  345.352536]  [<ffffffff810fdf40>] ? prepare_to_wait_event+0xf0/0xf0
[  345.352536]  [<ffffffff812061d4>] throttle_vm_writeout+0x44/0xd0
[  345.352536]  [<ffffffff81211533>] shrink_zone_memcg+0x613/0x720
[  345.352536]  [<ffffffff81211720>] shrink_zone+0xe0/0x300
[  345.352536]  [<ffffffff81211aed>] do_try_to_free_pages+0x1ad/0x450
[  345.352536]  [<ffffffff81211e7f>] try_to_free_pages+0xef/0x300
[  345.352536]  [<ffffffff811fef19>] __alloc_pages_nodemask+0x879/0x1210
[  345.352536]  [<ffffffff810e8080>] ? sched_clock_cpu+0x90/0xc0
[  345.352536]  [<ffffffff8125a8d1>] alloc_pages_current+0xa1/0x1f0
[  345.352536]  [<ffffffff81265ef5>] ? new_slab+0x3f5/0x6a0
[  345.352536]  [<ffffffff81265dd7>] new_slab+0x2d7/0x6a0
[  345.352536]  [<ffffffff810e7f87>] ? sched_clock_local+0x17/0x80
[  345.352536]  [<ffffffff812678cb>] ___slab_alloc+0x3fb/0x5c0
[  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
[  345.352536]  [<ffffffff810e7f87>] ? sched_clock_local+0x17/0x80
[  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
[  345.352536]  [<ffffffff81267ae1>] __slab_alloc+0x51/0x90
[  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
[  345.352536]  [<ffffffff81267d9b>] kmem_cache_alloc+0x27b/0x310
[  345.352536]  [<ffffffff811f71bd>] mempool_alloc_slab+0x1d/0x30
[  345.352536]  [<ffffffff811f6f11>] mempool_alloc+0x91/0x230
[  345.352536]  [<ffffffff8141a02d>] bio_alloc_bioset+0xbd/0x260
[  345.352536]  [<ffffffffc02f1a54>] kcryptd_crypt+0x114/0x3b0 [dm_crypt]

Let's just drop throttle_vm_writeout altogether. It is not very much
helpful anymore.

I have tried to test a potential writeback IO runaway similar to the one
described in the original patch which has introduced that [1]. Small
virtual machine (512MB RAM, 4 CPUs, 2G of swap space and disk image on a
rather slow NFS in a sync mode on the host) with 8 parallel writers each
writing 1G worth of data. As soon as the pagecache fills up and the
direct reclaim hits then I start anon memory consumer in a loop
(allocating 300M and exiting after populating it) in the background
to make the memory pressure even stronger as well as to disrupt the
steady state for the IO. The direct reclaim is throttled because of the
congestion as well as kswapd hitting congestion_wait due to nr_immediate
but throttle_vm_writeout doesn't ever trigger the sleep throughout
the test. Dirty+writeback are close to nr_dirty_threshold with some
fluctuations caused by the anon consumer.

[1] https://www2.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.9-rc1/2.6.9-rc1-mm3/broken-out/vm-pageout-throttling.patch
Cc: Marcelo Tosatti <mtosatti@redhat.com>
Cc: NeilBrown <neilb@suse.com>
Cc: Ondrej Kozina <okozina@redhat.com
Reported-by: Mikulas Patocka <mpatocka@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
I believe this is more a cleanup than a serious fix. Mikulas has
reported [1] that the throttling is less severe after 4e390b2b2f34
("Revert "mm, mempool: only set __GFP_NOMEMALLOC if there are free
elements""). Anyway, I believe that this function has shown its age
though and we should just get rid of it and make the throttling
mechanisms used by page allocator/reclaim easier to follow.

Mempool users believe that the page allocator shouldn't throttle their
allocations at all but I think that this needs a deeper consideration
so this is not addressed in this patch.

[1] http://lkml.kernel.org/r/alpine.LRH.2.02.1608030853430.15274@file01.intranet.prod.int.rdu2.redhat.com

 include/linux/writeback.h |  1 -
 mm/page-writeback.c       | 30 ------------------------------
 mm/vmscan.c               |  2 --
 3 files changed, 33 deletions(-)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index fc1e16c25a29..797100e10010 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -319,7 +319,6 @@ void laptop_mode_timer_fn(unsigned long data);
 #else
 static inline void laptop_sync_completion(void) { }
 #endif
-void throttle_vm_writeout(gfp_t gfp_mask);
 bool node_dirty_ok(struct pglist_data *pgdat);
 int wb_domain_init(struct wb_domain *dom, gfp_t gfp);
 #ifdef CONFIG_CGROUP_WRITEBACK
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f4cd7d8005c9..82e72524db55 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1965,36 +1965,6 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 	return false;
 }
 
-void throttle_vm_writeout(gfp_t gfp_mask)
-{
-	unsigned long background_thresh;
-	unsigned long dirty_thresh;
-
-        for ( ; ; ) {
-		global_dirty_limits(&background_thresh, &dirty_thresh);
-		dirty_thresh = hard_dirty_limit(&global_wb_domain, dirty_thresh);
-
-                /*
-                 * Boost the allowable dirty threshold a bit for page
-                 * allocators so they don't get DoS'ed by heavy writers
-                 */
-                dirty_thresh += dirty_thresh / 10;      /* wheeee... */
-
-                if (global_node_page_state(NR_UNSTABLE_NFS) +
-			global_node_page_state(NR_WRITEBACK) <= dirty_thresh)
-                        	break;
-                congestion_wait(BLK_RW_ASYNC, HZ/10);
-
-		/*
-		 * The caller might hold locks which can prevent IO completion
-		 * or progress in the filesystem.  So we cannot just sit here
-		 * waiting for IO to complete.
-		 */
-		if ((gfp_mask & (__GFP_FS|__GFP_IO)) != (__GFP_FS|__GFP_IO))
-			break;
-        }
-}
-
 /*
  * sysctl handler for /proc/sys/vm/dirty_writeback_centisecs
  */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f9b3112e963a..83203201c88b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2437,8 +2437,6 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	if (inactive_list_is_low(lruvec, false, sc))
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
-
-	throttle_vm_writeout(sc->gfp_mask);
 }
 
 /* Use reclaim/compaction for costly allocs or under memory pressure */
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
