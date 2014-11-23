Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id F21236B007D
	for <linux-mm@kvack.org>; Sat, 22 Nov 2014 23:53:44 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id y10so7866975pdj.20
        for <linux-mm@kvack.org>; Sat, 22 Nov 2014 20:53:44 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id fn3si15319486pbc.235.2014.11.22.20.53.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 22 Nov 2014 20:53:43 -0800 (PST)
Received: from fsav303.sakura.ne.jp (fsav303.sakura.ne.jp [153.120.85.134])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sAN4rfcU081491
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 13:53:41 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (KD175108057186.ppp-bb.dion.ne.jp [175.108.57.186])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id sAN4rftL081488
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 13:53:41 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [PATCH 5/5] mm: Insert some delay if ongoing memory allocation stalls.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
In-Reply-To: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
Message-Id: <201411231353.BDE90173.FQOMJtHOLVFOFS@I-love.SAKURA.ne.jp>
Date: Sun, 23 Nov 2014 13:53:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

>From 4fad86f7a653dbbaec3ba2389f74f97a6705a558 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 23 Nov 2014 13:41:24 +0900
Subject: [PATCH 5/5] mm: Insert some delay if ongoing memory allocation stalls.

This patch introduces 1ms of unkillable sleep before retrying when
sleepable __alloc_pages_nodemask() is taking more than 5 seconds.
According to Documentation/timers/timers-howto.txt, msleep < 20ms
can sleep for up to 20ms, but this should not be a problem because
msleep(1) is called only when there is no choice but retrying.

This patch is intended for two purposes.

(1) Reduce CPU usage when memory allocation deadlock occurred, by
    avoiding useless busy retry loop.

(2) Allow SysRq-w (or SysRq-t) to report how long each thread is
    blocked for memory allocation.

  kworker/0:2     D ffff88007a2d8cf8     0    61      2 0x00000000
  MemAlloc: 69851 jiffies on 0x10
  Workqueue: events_freezable_power_ disk_events_workfn
   ffff88007a2e3898 0000000000000046 ffff88007a2e38f8 ffff88007a2d88d0
   0000000000013500 ffff88007a2e3fd8 0000000000013500 ffff88007a2d88d0
   ffff88007fffdb08 0000000100052ae5 ffff88007a2e38c8 ffffffff819d44c0
  Call Trace:
   [<ffffffff815951e4>] schedule+0x24/0x70
   [<ffffffff815982b1>] schedule_timeout+0x111/0x1a0
   [<ffffffff810b7470>] ? migrate_timer_list+0x60/0x60
   [<ffffffff810b778f>] msleep+0x2f/0x40
   [<ffffffff81110ecb>] __alloc_pages_nodemask+0x7eb/0xad0
   [<ffffffff81150dae>] alloc_pages_current+0x8e/0x100
   [<ffffffff81252156>] bio_copy_user_iov+0x1d6/0x380
   [<ffffffff8125474d>] ? blk_rq_init+0xed/0x160
   [<ffffffff81252399>] bio_copy_kern+0x49/0x100
   [<ffffffff8109a370>] ? prepare_to_wait_event+0x100/0x100
   [<ffffffff8125c0ef>] blk_rq_map_kern+0x6f/0x130
   [<ffffffff81159e1e>] ? kmem_cache_alloc+0x48e/0x4b0
   [<ffffffff8139c50f>] scsi_execute+0x12f/0x160
   [<ffffffff8139dd54>] scsi_execute_req_flags+0x84/0xf0
   [<ffffffffa01e19cc>] sr_check_events+0xbc/0x2e0 [sr_mod]
   [<ffffffff810912ac>] ? put_prev_entity+0x2c/0x3b0
   [<ffffffffa01d5177>] cdrom_check_events+0x17/0x30 [cdrom]
   [<ffffffffa01e1e5d>] sr_block_check_events+0x2d/0x30 [sr_mod]
   [<ffffffff81266236>] disk_check_events+0x56/0x1b0
   [<ffffffff812663a1>] disk_events_workfn+0x11/0x20
   [<ffffffff81076aef>] process_one_work+0x13f/0x370
   [<ffffffff81077ad9>] worker_thread+0x119/0x500
   [<ffffffff810779c0>] ? rescuer_thread+0x350/0x350
   [<ffffffff8107cbbc>] kthread+0xdc/0x100
   [<ffffffff8107cae0>] ? kthread_create_on_node+0x1b0/0x1b0
   [<ffffffff815995bc>] ret_from_fork+0x7c/0xb0
   [<ffffffff8107cae0>] ? kthread_create_on_node+0x1b0/0x1b0

  kworker/u16:28  D ffff8800793d0638     0  9950    346 0x00000080
  MemAlloc: 13014 jiffies on 0x250
   ffff880052777618 0000000000000046 ffff880052777678 ffff8800793d0210
   0000000000013500 ffff880052777fd8 0000000000013500 ffff8800793d0210
   ffff88007fffdb08 00000001000534b2 ffff880052777648 ffff88007c920000
  Call Trace:
   [<ffffffff815951e4>] schedule+0x24/0x70
   [<ffffffff815982b1>] schedule_timeout+0x111/0x1a0
   [<ffffffff810b7470>] ? migrate_timer_list+0x60/0x60
   [<ffffffff810b778f>] msleep+0x2f/0x40
   [<ffffffff81110ecb>] __alloc_pages_nodemask+0x7eb/0xad0
   [<ffffffff81150dae>] alloc_pages_current+0x8e/0x100
   [<ffffffffa0269f97>] xfs_buf_allocate_memory+0x168/0x247 [xfs]
   [<ffffffffa0235f62>] xfs_buf_get_map+0xd2/0x130 [xfs]
   [<ffffffffa0236534>] xfs_buf_read_map+0x24/0xc0 [xfs]
   [<ffffffffa025fdb9>] xfs_trans_read_buf_map+0x119/0x300 [xfs]
   [<ffffffffa022b9f9>] xfs_imap_to_bp+0x69/0xf0 [xfs]
   [<ffffffffa022bee9>] xfs_iread+0x79/0x410 [xfs]
   [<ffffffffa0251c8f>] ? kmem_zone_alloc+0x6f/0x100 [xfs]
   [<ffffffffa023d8ff>] xfs_iget+0x18f/0x530 [xfs]
   [<ffffffffa024589e>] xfs_lookup+0xae/0xd0 [xfs]
   [<ffffffffa0242cf3>] xfs_vn_lookup+0x73/0xc0 [xfs]
   [<ffffffff8117f1a8>] lookup_real+0x18/0x50
   [<ffffffff811848cc>] do_last+0x98c/0x1250
   [<ffffffff81180123>] ? inode_permission+0x13/0x40
   [<ffffffff81182699>] ? link_path_walk+0x79/0x850
   [<ffffffff81185253>] path_openat+0xc3/0x670
   [<ffffffff81186984>] do_filp_open+0x44/0xb0
   [<ffffffff81213991>] ? security_prepare_creds+0x11/0x20
   [<ffffffff8107e871>] ? prepare_creds+0xf1/0x1b0
   [<ffffffff8117c491>] do_open_exec+0x21/0xe0
   [<ffffffff8117d1eb>] do_execve_common.isra.27+0x1bb/0x5e0
   [<ffffffff8117d623>] do_execve+0x13/0x20
   [<ffffffff81073e56>] ____call_usermodehelper+0x126/0x1c0
   [<ffffffff81073ef0>] ? ____call_usermodehelper+0x1c0/0x1c0
   [<ffffffff81073f09>] call_helper+0x19/0x20
   [<ffffffff815995bc>] ret_from_fork+0x7c/0xb0
   [<ffffffff81073ef0>] ? ____call_usermodehelper+0x1c0/0x1c0

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/page_alloc.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c77418e..9e80b9f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -59,6 +59,7 @@
 #include <linux/page-debug-flags.h>
 #include <linux/hugetlb.h>
 #include <linux/sched/rt.h>
+#include <linux/delay.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -2738,6 +2739,12 @@ rebalance:
 					goto nopage;
 			}
 
+			/*
+			 * If wait == true and it is taking more than 5
+			 * seconds, sleep for 1ms for reducing CPU usage.
+			 */
+			if (time_after(jiffies, current->gfp_start + 5 * HZ))
+				msleep(1);
 			goto restart;
 		}
 	}
@@ -2748,6 +2755,12 @@ rebalance:
 						pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
+		/*
+		 * If wait == true and it is taking more than 5 seconds,
+		 * sleep for 1ms for reducing CPU usage.
+		 */
+		if (time_after(jiffies, current->gfp_start + 5 * HZ))
+			msleep(1);
 		goto rebalance;
 	} else {
 		/*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
