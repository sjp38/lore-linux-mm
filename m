Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB416B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 08:26:36 -0400 (EDT)
Received: by obbda8 with SMTP id da8so38931501obb.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 05:26:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z132si5179659oia.9.2015.10.21.05.26.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 21 Oct 2015 05:26:35 -0700 (PDT)
Subject: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable() checks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201510212126.JIF90648.HOOFJVFQLMStOF@I-love.SAKURA.ne.jp>
Date: Wed, 21 Oct 2015 21:26:19 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: torvalds@linux-foundation.org, mhocko@kernel.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

>From 0c50792dfa6396453c89c71351a7458b94d3e881 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 21 Oct 2015 21:15:30 +0900
Subject: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable() checks

Since "struct zone"->vm_stat[] is array of atomic_long_t, an attempt
to reduce frequency of updating values in vm_stat[] is achieved by
using per cpu variables "struct per_cpu_pageset"->vm_stat_diff[].
Values in vm_stat_diff[] are merged into vm_stat[] periodically
(configured via /proc/sys/vm/stat_interval) using vmstat_update
workqueue (struct delayed_work vmstat_work).

When a task attempted to allocate memory and reached direct reclaim
path, shrink_zones() checks whether there are reclaimable pages by
calling zone_reclaimable(). zone_reclaimable() makes decision based
on values in vm_stat[] by calling zone_page_state(). This is usually
fine because values in vm_stat_diff[] are expected to be merged into
vm_stat[] shortly.

However, if a workqueue which is processed before vmstat_update
workqueue is processed got stuck inside memory allocation request,
values in vm_stat_diff[] cannot be merged into vm_stat[]. As a result,
zone_reclaimable() continues using outdated vm_stat[] values and the
task which is doing direct reclaim path thinks that there are reclaimable
pages and therefore continues looping. The consequence is a silent
livelock (hang up without any kernel messages) because the OOM killer
will not be invoked.

We can hit such livelock by e.g. disk_events_workfn workqueue doing
memory allocation from bio_copy_kern().

[  255.054205] kworker/3:1     R  running task        0    45      2 0x00000008
[  255.056063] Workqueue: events_freezable_power_ disk_events_workfn
[  255.057715]  ffff88007f805680 ffff88007c55f6d0 ffffffff8116463d ffff88007c55f758
[  255.059705]  ffff88007f82b870 ffff88007c55f6e0 ffffffff811646be ffff88007c55f710
[  255.061694]  ffffffff811bdaf0 ffff88007f82b870 0000000000000400 0000000000000000
[  255.063690] Call Trace:
[  255.064664]  [<ffffffff8116463d>] ? __list_lru_count_one.isra.4+0x1d/0x80
[  255.066428]  [<ffffffff811646be>] ? list_lru_count_one+0x1e/0x20
[  255.068063]  [<ffffffff811bdaf0>] ? super_cache_count+0x50/0xd0
[  255.069666]  [<ffffffff8114ecf6>] ? shrink_slab.part.38+0xf6/0x2a0
[  255.071313]  [<ffffffff81151f78>] ? shrink_zone+0x2c8/0x2e0
[  255.072845]  [<ffffffff81152316>] ? do_try_to_free_pages+0x156/0x6d0
[  255.074527]  [<ffffffff810bc6b6>] ? mark_held_locks+0x66/0x90
[  255.076085]  [<ffffffff816ca797>] ? _raw_spin_unlock_irq+0x27/0x40
[  255.077727]  [<ffffffff810bc7d9>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[  255.079451]  [<ffffffff81152924>] ? try_to_free_pages+0x94/0xc0
[  255.081045]  [<ffffffff81145b4a>] ? __alloc_pages_nodemask+0x72a/0xdb0
[  255.082761]  [<ffffffff8118cd06>] ? alloc_pages_current+0x96/0x1b0
[  255.084407]  [<ffffffff8133985d>] ? bio_alloc_bioset+0x20d/0x2d0
[  255.086032]  [<ffffffff8133aba4>] ? bio_copy_kern+0xc4/0x180
[  255.087584]  [<ffffffff81344f20>] ? blk_rq_map_kern+0x70/0x130
[  255.089161]  [<ffffffff814a334d>] ? scsi_execute+0x12d/0x160
[  255.090696]  [<ffffffff814a3474>] ? scsi_execute_req_flags+0x84/0xf0
[  255.092466]  [<ffffffff814b55f2>] ? sr_check_events+0xb2/0x2a0
[  255.094042]  [<ffffffff814c3223>] ? cdrom_check_events+0x13/0x30
[  255.095634]  [<ffffffff814b5a35>] ? sr_block_check_events+0x25/0x30
[  255.097278]  [<ffffffff813501fb>] ? disk_check_events+0x5b/0x150
[  255.098865]  [<ffffffff81350307>] ? disk_events_workfn+0x17/0x20
[  255.100451]  [<ffffffff810890b5>] ? process_one_work+0x1a5/0x420
[  255.102046]  [<ffffffff81089051>] ? process_one_work+0x141/0x420
[  255.103625]  [<ffffffff8108944b>] ? worker_thread+0x11b/0x490
[  255.105159]  [<ffffffff816c4e95>] ? __schedule+0x315/0xac0
[  255.106643]  [<ffffffff81089330>] ? process_one_work+0x420/0x420
[  255.108217]  [<ffffffff8108f4e9>] ? kthread+0xf9/0x110
[  255.109634]  [<ffffffff8108f3f0>] ? kthread_create_on_node+0x230/0x230
[  255.111307]  [<ffffffff816cb35f>] ? ret_from_fork+0x3f/0x70
[  255.112785]  [<ffffffff8108f3f0>] ? kthread_create_on_node+0x230/0x230

[  273.930846] Showing busy workqueues and worker pools:
[  273.932299] workqueue events: flags=0x0
[  273.933465]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=4/256
[  273.935120]     pending: vmpressure_work_fn, vmstat_shepherd, vmstat_update, vmw_fb_dirty_flush [vmwgfx]
[  273.937489] workqueue events_freezable: flags=0x4
[  273.938795]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  273.940446]     pending: vmballoon_work [vmw_balloon]
[  273.941973] workqueue events_power_efficient: flags=0x80
[  273.943491]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  273.945167]     pending: check_lifetime
[  273.946422] workqueue events_freezable_power_: flags=0x84
[  273.947890]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  273.949579]     in-flight: 45:disk_events_workfn
[  273.951103] workqueue ipv6_addrconf: flags=0x8
[  273.952447]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/1
[  273.954121]     pending: addrconf_verify_work
[  273.955541] workqueue xfs-reclaim/sda1: flags=0x4
[  273.957036]   pwq 6: cpus=3 node=0 flags=0x0 nice=0 active=1/256
[  273.958847]     pending: xfs_reclaim_worker
[  273.960392] pool 6: cpus=3 node=0 flags=0x0 nice=0 workers=3 idle: 186 26

This patch changes zone_reclaimable() to use zone_page_state_snapshot()
in order to make sure that values in vm_stat_diff[] are taken into
account when making decision.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/vmscan.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index af4f4c0..2e4ef60 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -196,19 +196,19 @@ static unsigned long zone_reclaimable_pages(struct zone *zone)
 {
 	unsigned long nr;
 
-	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
-	     zone_page_state(zone, NR_INACTIVE_FILE);
+	nr = zone_page_state_snapshot(zone, NR_ACTIVE_FILE) +
+	     zone_page_state_snapshot(zone, NR_INACTIVE_FILE);
 
 	if (get_nr_swap_pages() > 0)
-		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
-		      zone_page_state(zone, NR_INACTIVE_ANON);
+		nr += zone_page_state_snapshot(zone, NR_ACTIVE_ANON) +
+		      zone_page_state_snapshot(zone, NR_INACTIVE_ANON);
 
 	return nr;
 }
 
 bool zone_reclaimable(struct zone *zone)
 {
-	return zone_page_state(zone, NR_PAGES_SCANNED) <
+	return zone_page_state_snapshot(zone, NR_PAGES_SCANNED) <
 		zone_reclaimable_pages(zone) * 6;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
