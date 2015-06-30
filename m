Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id C49396B0032
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 11:17:25 -0400 (EDT)
Received: by wguu7 with SMTP id u7so12663852wgu.3
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 08:17:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t7si19904094wix.46.2015.06.30.08.17.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jun 2015 08:17:23 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] mm, vmscan: Do not wait for page writeback for GFP_NOFS allocations
Date: Tue, 30 Jun 2015 17:17:17 +0200
Message-Id: <1435677437-16717-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Marian Marinov <mm@1h.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org

Nikolay has reported a hang when a memcg reclaim got stuck with the
following backtrace:
PID: 18308  TASK: ffff883d7c9b0a30  CPU: 1   COMMAND: "rsync"
 #0 [ffff88177374ac60] __schedule at ffffffff815ab152
 #1 [ffff88177374acb0] schedule at ffffffff815ab76e
 #2 [ffff88177374acd0] schedule_timeout at ffffffff815ae5e5
 #3 [ffff88177374ad70] io_schedule_timeout at ffffffff815aad6a
 #4 [ffff88177374ada0] bit_wait_io at ffffffff815abfc6
 #5 [ffff88177374adb0] __wait_on_bit at ffffffff815abda5
 #6 [ffff88177374ae00] wait_on_page_bit at ffffffff8111fd4f
 #7 [ffff88177374ae50] shrink_page_list at ffffffff81135445
 #8 [ffff88177374af50] shrink_inactive_list at ffffffff81135845
 #9 [ffff88177374b060] shrink_lruvec at ffffffff81135ead
#10 [ffff88177374b150] shrink_zone at ffffffff811360c3
#11 [ffff88177374b220] shrink_zones at ffffffff81136eff
#12 [ffff88177374b2a0] do_try_to_free_pages at ffffffff8113712f
#13 [ffff88177374b300] try_to_free_mem_cgroup_pages at ffffffff811372be
#14 [ffff88177374b380] try_charge at ffffffff81189423
#15 [ffff88177374b430] mem_cgroup_try_charge at ffffffff8118c6f5
#16 [ffff88177374b470] __add_to_page_cache_locked at ffffffff8112137d
#17 [ffff88177374b4e0] add_to_page_cache_lru at ffffffff81121618
#18 [ffff88177374b510] pagecache_get_page at ffffffff8112170b
#19 [ffff88177374b560] grow_dev_page at ffffffff811c8297
#20 [ffff88177374b5c0] __getblk_slow at ffffffff811c91d6
#21 [ffff88177374b600] __getblk_gfp at ffffffff811c92c1
#22 [ffff88177374b630] ext4_ext_grow_indepth at ffffffff8124565c
#23 [ffff88177374b690] ext4_ext_create_new_leaf at ffffffff81246ca8
#24 [ffff88177374b6e0] ext4_ext_insert_extent at ffffffff81246f09
#25 [ffff88177374b750] ext4_ext_map_blocks at ffffffff8124a848
#26 [ffff88177374b870] ext4_map_blocks at ffffffff8121a5b7
#27 [ffff88177374b910] mpage_map_one_extent at ffffffff8121b1fa
#28 [ffff88177374b950] mpage_map_and_submit_extent at ffffffff8121f07b
#29 [ffff88177374b9b0] ext4_writepages at ffffffff8121f6d5
#30 [ffff88177374bb20] do_writepages at ffffffff8112c490
#31 [ffff88177374bb30] __filemap_fdatawrite_range at ffffffff81120199
#32 [ffff88177374bb80] filemap_flush at ffffffff8112041c
#33 [ffff88177374bb90] ext4_alloc_da_blocks at ffffffff81219da1
#34 [ffff88177374bbb0] ext4_rename at ffffffff81229b91
#35 [ffff88177374bcd0] ext4_rename2 at ffffffff81229e32
#36 [ffff88177374bce0] vfs_rename at ffffffff811a08a5
#37 [ffff88177374bd60] SYSC_renameat2 at ffffffff811a3ffc
#38 [ffff88177374bf60] sys_renameat2 at ffffffff811a408e
#39 [ffff88177374bf70] sys_rename at ffffffff8119e51e
#40 [ffff88177374bf80] system_call_fastpath at ffffffff815afa89

Dave Chinner has properly pointed out that this is deadlock in the
reclaim code because ext4 doesn't submit pages which are marked by
PG_writeback right away. The heuristic introduced by e62e384e9da8
("memcg: prevent OOM with too many dirty pages") assumes that pages
marked as writeback will be written out eventually without requiring any
memcg charges. This is not true for ext4 though.

ext4_bio_write_page calls io_submit_add_bh but that doesn't necessarily
submit the bio. Instead it tries to map more pages into the bio and
mpage_map_one_extent might trigger memcg charge which might end up
waiting on a page which is marked PG_writeback but hasn't been submitted
yet so we would end up waiting for something that never finishes.

Fix this issue by limiting the wait to reclaim triggered by __GFP_FS
allocations to make sure we are not called from filesystem paths
which might be doing exactly this kind of IO optimizations. The page
fault path shouldn't require GFP_NOFS and so we shouldn't reintroduce
the premature OOM killer issue which was originally addressed by the
heuristic.

Reported-by: Nikolay Borisov <kernel@kyup.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---

Hi,
the issue has been reported http://marc.info/?l=linux-kernel&m=143522730927480.
This obviously requires a patch ot make ext4_ext_grow_indepth call
sb_getblk with the GFP_NOFS mask but that one makes sense on its own
and Ted has mentioned he will push it. I haven't marked the patch for
stable yet. This is the first time the issue has been reported and
ext4 writeout code has changed considerably in 3.11 and I am not sure
the issue was present before. e62e384e9da8 which has introduced the
wait_on_page_writeback has been merged in 3.6 which is quite some time
ago. If we go with stable I would suggest marking it for 3.11+ and it
should obviously go with the ext4_ext_grow_indepth fix.

 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 37e90db1520b..6c44d424968e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -995,7 +995,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 
 			/* Case 3 above */
-			} else {
+			} else if (sc->gfp_mask & __GFP_FS) {
 				wait_on_page_writeback(page);
 			}
 		}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
