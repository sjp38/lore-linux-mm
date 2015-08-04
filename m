Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 66C956B0038
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 17:37:57 -0400 (EDT)
Received: by pacgq8 with SMTP id gq8so17653929pac.3
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 14:37:57 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id fl3si1385242pab.16.2015.08.04.14.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Aug 2015 14:37:56 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so9350538pdr.2
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 14:37:56 -0700 (PDT)
Date: Tue, 4 Aug 2015 14:36:58 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm, vmscan: Do not wait for page writeback for GFP_NOFS
 allocations
In-Reply-To: <20150804095158.GE18509@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1508041433460.31462@eggly.anvils>
References: <1435677437-16717-1-git-send-email-mhocko@suse.cz> <20150701061731.GB6286@dhcp22.suse.cz> <20150701133715.GA6287@dhcp22.suse.cz> <20150702142551.GB9456@thunk.org> <20150702151321.GE12547@dhcp22.suse.cz> <alpine.LSU.2.11.1508032227050.5070@eggly.anvils>
 <20150804095158.GE18509@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Theodore Ts'o <tytso@mit.edu>, Nikolay Borisov <kernel@kyup.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Marian Marinov <mm@1h.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

From: Michal Hocko <mhocko@suse.cz>

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

Dave Chinner has properly pointed out that this is a deadlock in the
reclaim code because ext4 doesn't submit pages which are marked by
PG_writeback right away. The heuristic was introduced by e62e384e9da8
("memcg: prevent OOM with too many dirty pages") and it was applied
only when may_enter_fs was specified. The code has been changed by
c3b94f44fcb0 ("memcg: further prevent OOM with too many dirty pages")
which has removed the __GFP_FS restriction with a reasoning that we
do not get into the fs code. But this is not sufficient apparently
because the fs doesn't necessarily submit pages marked PG_writeback
for IO right away.

ext4_bio_write_page calls io_submit_add_bh but that doesn't necessarily
submit the bio. Instead it tries to map more pages into the bio and
mpage_map_one_extent might trigger memcg charge which might end up
waiting on a page which is marked PG_writeback but hasn't been submitted
yet so we would end up waiting for something that never finishes.

Fix this issue by replacing __GFP_IO by may_enter_fs check (for case 2)
before we go to wait on the writeback. The page fault path, which is the
only path that triggers memcg oom killer since 3.12, shouldn't require
GFP_NOFS and so we shouldn't reintroduce the premature OOM killer issue
which was originally addressed by the heuristic.

As per David Chinner the xfs is doing similar thing since 2.6.15 already
so ext4 is not the only affected filesystem. Moreover he notes:
: For example: IO completion might require unwritten extent conversion
: which executes filesystem transactions and GFP_NOFS allocations. The
: writeback flag on the pages can not be cleared until unwritten
: extent conversion completes. Hence memory reclaim cannot wait on
: page writeback to complete in GFP_NOFS context because it is not
: safe to do so, memcg reclaim or otherwise.

Cc: stable@vger.kernel.org # 3.9+
[tytso@mit.edu: corrected the control flow]
Fixes: c3b94f44fcb0 ("memcg: further prevent OOM with too many dirty pages")
Reported-by: Nikolay Borisov <kernel@kyup.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/vmscan.c |   16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

--- 4.2-rc5/mm/vmscan.c	2015-07-05 19:25:02.856131170 -0700
+++ linux/mm/vmscan.c	2015-08-02 21:24:03.000614050 -0700
@@ -973,22 +973,18 @@ static unsigned long shrink_page_list(st
 		 *    caller can stall after page list has been processed.
 		 *
 		 * 2) Global or new memcg reclaim encounters a page that is
-		 *    not marked for immediate reclaim or the caller does not
-		 *    have __GFP_IO. In this case mark the page for immediate
+		 *    not marked for immediate reclaim, or the caller does not
+		 *    have __GFP_FS (or __GFP_IO if it's simply going to swap,
+		 *    not to fs). In this case mark the page for immediate
 		 *    reclaim and continue scanning.
 		 *
-		 *    __GFP_IO is checked  because a loop driver thread might
+		 *    Require may_enter_fs because we would wait on fs, which
+		 *    may not have submitted IO yet. And the loop driver might
 		 *    enter reclaim, and deadlock if it waits on a page for
 		 *    which it is needed to do the write (loop masks off
 		 *    __GFP_IO|__GFP_FS for this reason); but more thought
 		 *    would probably show more reasons.
 		 *
-		 *    Don't require __GFP_FS, since we're not going into the
-		 *    FS, just waiting on its writeback completion. Worryingly,
-		 *    ext4 gfs2 and xfs allocate pages with
-		 *    grab_cache_page_write_begin(,,AOP_FLAG_NOFS), so testing
-		 *    may_enter_fs here is liable to OOM on them.
-		 *
 		 * 3) Legacy memcg encounters a page that is not already marked
 		 *    PageReclaim. memcg does not have any dirty pages
 		 *    throttling so we could easily OOM just because too many
@@ -1005,7 +1001,7 @@ static unsigned long shrink_page_list(st
 
 			/* Case 2 above */
 			} else if (sane_reclaim(sc) ||
-			    !PageReclaim(page) || !(sc->gfp_mask & __GFP_IO)) {
+			    !PageReclaim(page) || !may_enter_fs) {
 				/*
 				 * This is slightly racy - end_page_writeback()
 				 * might have just cleared PageReclaim, then

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
