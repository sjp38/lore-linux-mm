Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFBE228025E
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 14:17:25 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g23so37714028wme.4
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 11:17:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si32950722wjy.67.2016.12.22.11.17.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 11:17:24 -0800 (PST)
Date: Thu, 22 Dec 2016 20:17:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM: Better, but still there on
Message-ID: <20161222191719.GA19898@dhcp22.suse.cz>
References: <20161216155808.12809-1-mhocko@kernel.org>
 <20161216184655.GA5664@boerne.fritz.box>
 <20161217000203.GC23392@dhcp22.suse.cz>
 <20161217125950.GA3321@boerne.fritz.box>
 <862a1ada-17f1-9cff-c89b-46c47432e89f@I-love.SAKURA.ne.jp>
 <20161217210646.GA11358@boerne.fritz.box>
 <20161219134534.GC5164@dhcp22.suse.cz>
 <20161220020829.GA5449@boerne.fritz.box>
 <20161221073658.GC16502@dhcp22.suse.cz>
 <20161222101028.GA11105@ppc-nas.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161222101028.GA11105@ppc-nas.fritz.box>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nils Holland <nholland@tisys.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

TL;DR I still do not see what is going on here and it still smells like
multiple issues. Please apply the patch below on _top_ of what you had.

On Thu 22-12-16 11:10:29, Nils Holland wrote:
[...]
> http://ftp.tisys.org/pub/misc/boerne_2016-12-22.log.xz

It took me a while to realize that tracepoint and printk messages are
not sorted by the timestamp. Some massaging has fixed that
$ xzcat boerne_2016-12-22.log.xz | sed -e 's@.*192.168.17.32:6665 \[[[:space:]]*\([0-9\.]\+\)\] @\1 @' -e 's@.*192.168.17.32:53062[[:space:]]*\([^[:space:]]\+\)[[:space:]].*[[:space:]]\([0-9\.]\+\):@\2 \1@' | sort -k1 -n -s

461.757468 kswapd0-32 mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 nr_requested=32 nr_scanned=32 nr_skipped=0 nr_taken=32 lru=1
461.757501 kswapd0-32 mm_vmscan_lru_shrink_inactive: nid=0 nr_scanned=32 nr_reclaimed=32 nr_dirty=0 nr_writeback=0 nr_congested=0 nr_immediate=0 nr_activate=0 nr_ref_keep=0 nr_unmap_fail=0 p
riority=2 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
461.757504 kswapd0-32 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=11852 inactive=0 total_active=118195 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
461.757508 kswapd0-32 mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 nr_requested=32 nr_scanned=32 nr_skipped=0 nr_taken=32 lru=1
461.757535 kswapd0-32 mm_vmscan_lru_shrink_inactive: nid=0 nr_scanned=32 nr_reclaimed=32 nr_dirty=0 nr_writeback=0 nr_congested=0 nr_immediate=0 nr_activate=0 nr_ref_keep=0 nr_unmap_fail=0 p
riority=2 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
461.757537 kswapd0-32 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=11820 inactive=0 total_active=118195 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
461.757543 kswapd0-32 mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 nr_requested=32 nr_scanned=32 nr_skipped=0 nr_taken=32 lru=1
461.757584 kswapd0-32 mm_vmscan_lru_shrink_inactive: nid=0 nr_scanned=32 nr_reclaimed=32 nr_dirty=0 nr_writeback=0 nr_congested=0 nr_immediate=0 nr_activate=0 nr_ref_keep=0 nr_unmap_fail=0 p
riority=2 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
461.757588 kswapd0-32 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=11788 inactive=0 total_active=118195 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
[...]
482.722379 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=9939 inactive=0 total_active=120208 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
482.722379 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=9939 inactive=0 total_active=120208 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
482.722379 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=89 inactive=0 total_active=1301 active=0 ratio=1 flags=RECLAIM_WB_ANON|RECLAIM_WB_ASYNC
482.722385 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=0 inactive=0 total_active=0 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
482.722386 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=0 inactive=0 total_active=0 active=0 ratio=1 flags=RECLAIM_WB_ANON|RECLAIM_WB_ASYNC
482.722391 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=0 inactive=0 total_active=0 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
482.722391 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=0 inactive=0 total_active=0 active=0 ratio=1 flags=RECLAIM_WB_ANON|RECLAIM_WB_ASYNC
482.722396 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=1 inactive=0 total_active=21 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
482.722396 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=0 inactive=0 total_active=131 active=0 ratio=1 flags=RECLAIM_WB_ANON|RECLAIM_WB_ASYNC
482.722397 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=1 inactive=0 total_active=21 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
482.722397 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=0 inactive=0 total_active=131 active=0 ratio=1 flags=RECLAIM_WB_ANON|RECLAIM_WB_ASYNC
482.722401 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=450730 inactive=0 total_active=206026 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
484.144971 collect2 invoked oom-killer: gfp_mask=0x27080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=0, order=0, oom_score_adj=0
[...]
484.146871 Node 0 active_anon:100688kB inactive_anon:380kB active_file:1296560kB inactive_file:1848044kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:32180kB dirty:20896kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 40960kB anon_thp: 776kB writeback_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable? no
484.147097 DMA free:4004kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:8016kB inactive_file:12kB unevictable:0kB writepending:68kB present:15992kB managed:15916kB mlocked:0kB slab_reclaimable:2652kB slab_unreclaimable:1224kB kernel_stack:8kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
484.147319 lowmem_reserve[]: 0 808 3849 3849
484.147387 Normal free:41016kB min:41100kB low:51372kB high:61644kB active_anon:0kB inactive_anon:0kB active_file:464688kB inactive_file:48kB unevictable:0kB writepending:2684kB present:897016kB managed:831472kB mlocked:0kB slab_reclaimable:215812kB slab_unreclaimable:90092kB kernel_stack:1336kB pagetables:1436kB bounce:0kB free_pcp:372kB local_pcp:176kB free_cma:0kB
484.149971 lowmem_reserve[]: 0 0 24330 24330
484.152390 HighMem free:332648kB min:512kB low:39184kB high:77856kB active_anon:100688kB inactive_anon:380kB active_file:823856kB inactive_file:1847984kB unevictable:0kB writepending:18144kB present:3114256kB managed:3114256kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:836kB local_pcp:156kB free_cma:0kB

Unfortunately LOST EVENT are not logged with the timestamp but there are
many lost events between 10:55:31-33 which corresponds to above time
range in timestamps:
$ xzgrep "10:55:3[1-3].*LOST" boerne_2016-12-22.log.xz | awk '{sum+=$6}END{print sum}'
5616415

so we do not have a good picture again :/ One thing is highly suspicious
though. I really doubt the _whole_ pagecache went down to zero and then up
in such a short time:
482.722379 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=89 inactive=0 total_active=1301 active=0 ratio=1 flags=RECLAIM_WB_ANON|RECLAIM_WB_ASYNC
482.722397 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=1 inactive=0 total_active=21 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
482.722401 cat-2974 mm_vmscan_inactive_list_is_low: nid=0 total_inactive=450730 inactive=0 total_active=206026 active=0 ratio=1 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC

File inactive 450730 resp. active 206026 roughly match the global
counters in the oom report so I would trust this to be more realistic. I
simply do not see any large source of the LRU isolation. Maybe those
pages have been truncated and new ones allocated. The time window is
really short though but who knows...

Another possibility would be a misaccounting but I do not see anything
that would use __mod_zone_page_state and __mod_node_page_state on LRU
handles node vs. zone counters inconsistently. Everything seems to go
via __update_lru_size.

Another thing to check would be the per-cpu counters usage. The
following patch should use the more precise numbers. I am also not
sure about the lockless nature of inactive_list_is_low so the patch
below adds the lru_lock there.

The only clear thing is that mm_vmscan_lru_isolate indeed skipped
through the whole list without finding a single suitable page
when it couldn't isolate any pages. So the failure is not due to
get_page_unless_zero.
$ xzgrep "mm_vmscan_lru_isolate.*nr_taken=0" boerne_2016-12-22.log.xz | sed 's@.*nr_scanned=\([0-9]*\).*@\1@' | sort | uniq -c
   7941 0

I am not able to draw any conclusion now. I am suspecting get_scan_count
as well. Let's see whether the patch below makes any difference and if
not I will dig into g_s_c some more. I will think about it some more,
maybe somebody else will notice something so I am sending this half
baked analysis.

---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index cb82913b62bb..8727b68a8e70 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -239,7 +239,7 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
 	if (!mem_cgroup_disabled())
 		return mem_cgroup_get_lru_size(lruvec, lru);
 
-	return node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
+	return node_page_state_snapshot(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
 }
 
 /*
@@ -2056,6 +2056,7 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	if (!file && !total_swap_pages)
 		return false;
 
+	spin_lock_irq(&pgdat->lru_lock);
 	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
 	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
 
@@ -2071,14 +2072,15 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 		if (!managed_zone(zone))
 			continue;
 
-		inactive_zone = zone_page_state(zone,
+		inactive_zone = zone_page_state_snapshot(zone,
 				NR_ZONE_LRU_BASE + (file * LRU_FILE));
-		active_zone = zone_page_state(zone,
+		active_zone = zone_page_state_snapshot(zone,
 				NR_ZONE_LRU_BASE + (file * LRU_FILE) + LRU_ACTIVE);
 
 		inactive -= min(inactive, inactive_zone);
 		active -= min(active, active_zone);
 	}
+	spin_unlock_irq(&pgdat->lru_lock);
 
 	gb = (inactive + active) >> (30 - PAGE_SHIFT);
 	if (gb)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
