Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 224E86B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 05:38:17 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id b80so6471902iob.23
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 02:38:17 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a39si2520937itj.136.2017.11.17.02.38.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Nov 2017 02:38:15 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,page_alloc: Use min watermark for last second allocation attempt.
Date: Fri, 17 Nov 2017 19:38:01 +0900
Message-Id: <1510915081-3768-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

__alloc_pages_may_oom() is doing last second allocation attempt using
ALLOC_WMARK_HIGH before calling out_of_memory(). This had two reasons.

The first reason is explained in the comment that it aims to catch
potential parallel OOM killing. But there is no longer parallel OOM
killing (in the sense that out_of_memory() is called "concurrently")
because we serialize out_of_memory() calls using oom_lock.

The second reason is explained by Andrea Arcangeli (who added that code)
that it aims to reduce the likelihood of OOM livelocks and be sure to
invoke the OOM killer. There was a risk of livelock or anyway of delayed
OOM killer invocation if ALLOC_WMARK_MIN is used, for relying on last
few pages which are constantly allocated and freed in the meantime will
not improve the situation. But there is no longer possibility of OOM
livelocks or failing to invoke the OOM killer because we need to mask
__GFP_DIRECT_RECLAIM for last second allocation attempt because oom_lock
prevents __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocations which last
second allocation attempt indirectly involve from failing.

Since the OOM killer does not always kill a process consuming significant
amount of memory (the OOM killer kills a process with highest OOM score
(or instead one of its children if any)), there can be time window where
ALLOC_WMARK_HIGH would fail and ALLOC_WMARK_MIN would succeed when
out_of_memory() is called "consecutively". Therefore, this patch changes
to use ALLOC_WMARK_MIN in order to minimize number of OOM victims.

----------
[ 1792.835056] Out of memory: Kill process 14294 (idle-priority) score 876 or sacrifice child
[ 1792.836073] Killed process 14458 (normal-priority) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[ 1792.837757] oom_reaper: reaped process 14458 (normal-priority), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[ 1794.366070] systemd-journal invoked oom-killer: gfp_mask=0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[ 1794.366073] systemd-journal cpuset=/ mems_allowed=0
[ 1794.366081] CPU: 2 PID: 13775 Comm: systemd-journal Tainted: G           O L   4.14.0-next-20171114+ #198
[ 1794.366082] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 1794.366083] Call Trace:
[ 1794.366089]  dump_stack+0x7c/0xbf
[ 1794.366094]  dump_header+0x69/0x2e1
[ 1794.366097]  ? trace_hardirqs_on_caller+0xf2/0x1a0
[ 1794.366102]  oom_kill_process+0x220/0x480
[ 1794.366106]  out_of_memory+0x117/0x370
[ 1794.366108]  ? out_of_memory+0x1c9/0x370
[ 1794.366111]  __alloc_pages_slowpath+0x955/0xc9a
[ 1794.366114]  ? __alloc_pages_nodemask+0x2b7/0x3a0
[ 1794.366122]  __alloc_pages_nodemask+0x379/0x3a0
[ 1794.366126]  filemap_fault+0x43f/0x7a0
[ 1794.366128]  ? filemap_fault+0x319/0x7a0
[ 1794.366168]  ? __xfs_filemap_fault.constprop.8+0x6c/0x210 [xfs]
[ 1794.366172]  ? down_read_nested+0x34/0x60
[ 1794.366202]  ? xfs_ilock+0x1f2/0x2e0 [xfs]
[ 1794.366230]  __xfs_filemap_fault.constprop.8+0x74/0x210 [xfs]
[ 1794.366235]  __do_fault+0x15/0x70
[ 1794.366238]  ? _raw_spin_unlock+0x1f/0x30
[ 1794.366240]  __handle_mm_fault+0x8ad/0xa40
[ 1794.366247]  handle_mm_fault+0x175/0x340
[ 1794.366248]  ? handle_mm_fault+0x36/0x340
[ 1794.366252]  __do_page_fault+0x234/0x4d0
[ 1794.366257]  page_fault+0x22/0x30
[ 1794.366259] RIP: 0033:0x560f6cb1442b
[ 1794.366260] RSP: 002b:00007fffd4f0c6e0 EFLAGS: 00010216
[ 1794.366262] RAX: 00007fffd4f0d374 RBX: 00007fffd4f0f470 RCX: 0000000000000028
[ 1794.366263] RDX: 0000000000000019 RSI: 000000000000003b RDI: 00007fffd4f0d368
[ 1794.366264] RBP: 00007fffd4f0d368 R08: 000000000000da70 R09: 00007fffd4f0d367
[ 1794.366265] R10: 0000000000000000 R11: 0000000000000000 R12: 000000000000002b
[ 1794.366265] R13: 0000000000000025 R14: ffffffffffffffff R15: 00007fffd4f0f458
[ 1794.366272] Mem-Info:
[ 1794.366276] active_anon:836924 inactive_anon:4744 isolated_anon:0
[ 1794.366276]  active_file:28 inactive_file:54 isolated_file:8
[ 1794.366276]  unevictable:0 dirty:0 writeback:0 unstable:0
[ 1794.366276]  slab_reclaimable:5648 slab_unreclaimable:32609
[ 1794.366276]  mapped:1612 shmem:6266 pagetables:9033 bounce:0
[ 1794.366276]  free:21656 free_pcp:684 free_cma:0
[ 1794.366279] Node 0 active_anon:3347696kB inactive_anon:18976kB active_file:112kB inactive_file:216kB unevictable:0kB isolated(anon):0kB isolated(file):32kB mapped:6448kB dirty:0kB writeback:0kB shmem:25064kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2850816kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[ 1794.366283] DMA free:14796kB min:284kB low:352kB high:420kB active_anon:1076kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB managed:15904kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1794.366283] lowmem_reserve[]: 0 2686 3630 3630
[ 1794.366289] DMA32 free:53380kB min:49792kB low:62240kB high:74688kB active_anon:2696300kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:2750788kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[ 1794.366289] lowmem_reserve[]: 0 0 944 944
[ 1794.366295] Normal free:18448kB min:17500kB low:21872kB high:26244kB active_anon:650740kB inactive_anon:18976kB active_file:220kB inactive_file:436kB unevictable:0kB writepending:0kB present:1048576kB managed:966968kB mlocked:0kB kernel_stack:19568kB pagetables:36132kB bounce:0kB free_pcp:2736kB local_pcp:680kB free_cma:0kB
[ 1794.366295] lowmem_reserve[]: 0 0 0 0
[ 1794.366299] DMA: 1*4kB (M) 1*8kB (M) 0*16kB 0*32kB 3*64kB (UM) 2*128kB (UM) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 0*2048kB 3*4096kB (M) = 14796kB
[ 1794.366327] DMA32: 7*4kB (U) 9*8kB (UM) 8*16kB (UM) 9*32kB (U) 6*64kB (UM) 6*128kB (UM) 8*256kB (UM) 5*512kB (M) 2*1024kB (UM) 0*2048kB 11*4096kB (UME) = 53380kB
[ 1794.366342] Normal: 557*4kB (UM) 476*8kB (UMH) 126*16kB (UMH) 84*32kB (UM) 16*64kB (UM) 9*128kB (UM) 4*256kB (UM) 4*512kB (UM) 3*1024kB (M) 0*2048kB 0*4096kB = 19060kB
[ 1794.366357] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 1794.366358] 6414 total pagecache pages
[ 1794.366361] 0 pages in swap cache
[ 1794.366362] Swap cache stats: add 0, delete 0, find 0/0
[ 1794.366362] Free swap  = 0kB
[ 1794.366363] Total swap = 0kB
[ 1794.366364] 1048429 pages RAM
[ 1794.366365] 0 pages HighMem/MovableOnly
[ 1794.366365] 115014 pages reserved
[ 1794.366366] 0 pages cma reserved
[ 1794.366368] Out of memory: Kill process 14294 (idle-priority) score 876 or sacrifice child
[ 1794.367372] Killed process 14459 (normal-priority) total-vm:4176kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[ 1794.369143] oom_reaper: reaped process 14459 (normal-priority), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
----------

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9568a23..34cd53cb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3335,15 +3335,15 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	}
 
 	/*
-	 * Go through the zonelist yet one more time, keep very high watermark
-	 * here, this is only to catch a parallel oom killing, we must fail if
-	 * we're still under heavy pressure. But make sure that this reclaim
-	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
-	 * allocation which will never fail due to oom_lock already held.
+	 * This allocation attempt must not depend on __GFP_DIRECT_RECLAIM &&
+	 * !__GFP_NORETRY allocation which will never fail due to oom_lock
+	 * already held. And since this allocation attempt does not sleep,
+	 * we will not fail to invoke the OOM killer even if we choose min
+	 * watermark here.
 	 */
 	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
 				      ~__GFP_DIRECT_RECLAIM, order,
-				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
+				      ALLOC_WMARK_MIN | ALLOC_CPUSET, ac);
 	if (page)
 		goto out;
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
