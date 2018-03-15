Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0746B0008
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 12:45:54 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s6so3146848pgn.3
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 09:45:54 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0124.outbound.protection.outlook.com. [104.47.1.124])
        by mx.google.com with ESMTPS id y25si3982197pfe.206.2018.03.15.09.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 09:45:52 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 1/6] mm/vmscan: Wake up flushers for legacy cgroups too
Date: Thu, 15 Mar 2018 19:45:48 +0300
Message-Id: <20180315164553.17856-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, stable@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Commit 726d061fbd36 ("mm: vmscan: kick flushers when we encounter
dirty pages on the LRU") added flusher invocation to
shrink_inactive_list() when many dirty pages on the LRU are encountered.

However, shrink_inactive_list() doesn't wake up flushers for legacy
cgroup reclaim, so the next commit bbef938429f5 ("mm: vmscan: remove
old flusher wakeup from direct reclaim path") removed the only source
of flusher's wake up in legacy mem cgroup reclaim path.

This leads to premature OOM if there is too many dirty pages in cgroup:
    # mkdir /sys/fs/cgroup/memory/test
    # echo $$ > /sys/fs/cgroup/memory/test/tasks
    # echo 50M > /sys/fs/cgroup/memory/test/memory.limit_in_bytes
    # dd if=/dev/zero of=tmp_file bs=1M count=100
    Killed

    dd invoked oom-killer: gfp_mask=0x14000c0(GFP_KERNEL), nodemask=(null), order=0, oom_score_adj=0

    Call Trace:
     dump_stack+0x46/0x65
     dump_header+0x6b/0x2ac
     oom_kill_process+0x21c/0x4a0
     out_of_memory+0x2a5/0x4b0
     mem_cgroup_out_of_memory+0x3b/0x60
     mem_cgroup_oom_synchronize+0x2ed/0x330
     pagefault_out_of_memory+0x24/0x54
     __do_page_fault+0x521/0x540
     page_fault+0x45/0x50

    Task in /test killed as a result of limit of /test
    memory: usage 51200kB, limit 51200kB, failcnt 73
    memory+swap: usage 51200kB, limit 9007199254740988kB, failcnt 0
    kmem: usage 296kB, limit 9007199254740988kB, failcnt 0
    Memory cgroup stats for /test: cache:49632KB rss:1056KB rss_huge:0KB shmem:0KB
            mapped_file:0KB dirty:49500KB writeback:0KB swap:0KB inactive_anon:0KB
	    active_anon:1168KB inactive_file:24760KB active_file:24960KB unevictable:0KB
    Memory cgroup out of memory: Kill process 3861 (bash) score 88 or sacrifice child
    Killed process 3876 (dd) total-vm:8484kB, anon-rss:1052kB, file-rss:1720kB, shmem-rss:0kB
    oom_reaper: reaped process 3876 (dd), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

Wake up flushers in legacy cgroup reclaim too.

Fixes: bbef938429f5 ("mm: vmscan: remove old flusher wakeup from direct reclaim path")
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: <stable@vger.kernel.org>
---
 mm/vmscan.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8fcd9f8d7390..4390a8d5be41 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1771,6 +1771,20 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (stat.nr_writeback && stat.nr_writeback == nr_taken)
 		set_bit(PGDAT_WRITEBACK, &pgdat->flags);
 
+	/*
+	 * If dirty pages are scanned that are not queued for IO, it
+	 * implies that flushers are not doing their job. This can
+	 * happen when memory pressure pushes dirty pages to the end of
+	 * the LRU before the dirty limits are breached and the dirty
+	 * data has expired. It can also happen when the proportion of
+	 * dirty pages grows not through writes but through memory
+	 * pressure reclaiming all the clean cache. And in some cases,
+	 * the flushers simply cannot keep up with the allocation
+	 * rate. Nudge the flusher threads in case they are asleep.
+	 */
+	if (stat.nr_unqueued_dirty == nr_taken)
+		wakeup_flusher_threads(WB_REASON_VMSCAN);
+
 	/*
 	 * Legacy memcg will stall in page writeback so avoid forcibly
 	 * stalling here.
@@ -1783,22 +1797,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		if (stat.nr_dirty && stat.nr_dirty == stat.nr_congested)
 			set_bit(PGDAT_CONGESTED, &pgdat->flags);
 
-		/*
-		 * If dirty pages are scanned that are not queued for IO, it
-		 * implies that flushers are not doing their job. This can
-		 * happen when memory pressure pushes dirty pages to the end of
-		 * the LRU before the dirty limits are breached and the dirty
-		 * data has expired. It can also happen when the proportion of
-		 * dirty pages grows not through writes but through memory
-		 * pressure reclaiming all the clean cache. And in some cases,
-		 * the flushers simply cannot keep up with the allocation
-		 * rate. Nudge the flusher threads in case they are asleep, but
-		 * also allow kswapd to start writing pages during reclaim.
-		 */
-		if (stat.nr_unqueued_dirty == nr_taken) {
-			wakeup_flusher_threads(WB_REASON_VMSCAN);
+		/* Allow kswapd to start writing pages during reclaim. */
+		if (stat.nr_unqueued_dirty == nr_taken)
 			set_bit(PGDAT_DIRTY, &pgdat->flags);
-		}
 
 		/*
 		 * If kswapd scans pages marked marked for immediate
-- 
2.16.1
