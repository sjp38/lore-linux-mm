Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3786B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 01:50:03 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id n130so48947qke.7
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 22:50:03 -0800 (PST)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id o132si5025098qka.50.2017.02.23.22.50.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 22:50:02 -0800 (PST)
Received: by mail-qk0-x244.google.com with SMTP id r90so1789283qki.3
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 22:50:02 -0800 (PST)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v2] mm/vmscan: fix high cpu usage of kswapd if there are no reclaimable pages
Date: Fri, 24 Feb 2017 14:49:52 +0800
Message-Id: <1487918992-7515-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Jia He <hejianet@gmail.com>

In a numa server, topology looks like
available: 3 nodes (0,2-3)
node 0 cpus:
node 0 size: 0 MB
node 0 free: 0 MB
node 2 cpus: 0 1 2 3 4 5 6 7
node 2 size: 15299 MB
node 2 free: 289 MB
node 3 cpus:
node 3 size: 15336 MB
node 3 free: 184 MB
node distances:
node   0   2   3
  0:  10  40  40
  2:  40  10  20
  3:  40  20  10
 
When I try to dynamically allocate the hugepages more than system total free 
memory:
e.g. echo 4000 >/proc/sys/vm/nr_hugepages
 
Then the kswapd will take 100% cpu for a long time(more than 3 hours, and will
not be about to end)
top result:
top - 13:42:59 up  3:37,  1 user,  load average: 1.09, 1.03, 1.01
Tasks:   1 total,   1 running,   0 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us, 12.5 sy,  0.0 ni, 85.5 id,  2.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem:  31371520 total, 30915136 used,   456384 free,      320 buffers
KiB Swap:  6284224 total,   115712 used,  6168512 free.    48192 cached Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND    
   76 root      20   0       0      0      0 R 100.0 0.000 217:17.29 kswapd3 

The root cause is: kswapd3 is waken up and then try to do reclaim again and 
again but it makes no progress. At last the allocated hugepages are less than
4000.
HugePages_Total:    1864
HugePages_Free:     1864
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:      16384 kB
  
At that time, even there are no relaimable pages in that node3, kswapd3 will 
not go to sleep.
Node 3, zone      DMA
  per-node stats
      nr_inactive_anon 0
      nr_active_anon 0
      nr_inactive_file 0
      nr_active_file 0
      nr_unevictable 0
      nr_isolated_anon 0
      nr_isolated_file 0
      nr_pages_scanned 0
      workingset_refault 0
      workingset_activate 0
      workingset_nodereclaim 0
      nr_anon_pages 0
      nr_mapped    0
      nr_file_pages 0
      nr_dirty     0
      nr_writeback 0
      nr_writeback_temp 0
      nr_shmem     0
      nr_shmem_hugepages 0
      nr_shmem_pmdmapped 0
      nr_anon_transparent_hugepages 0
      nr_unstable  0
      nr_vmscan_write 0
      nr_vmscan_immediate_reclaim 0
      nr_dirtied   0
      nr_written   0
  pages free     2951
        min      2821
        low      3526
        high     4231
   node_scanned  0
        spanned  245760
        present  245760
        managed  245388
      nr_free_pages 2951
      nr_zone_inactive_anon 0
      nr_zone_active_anon 0
      nr_zone_inactive_file 0
      nr_zone_active_file 0
      nr_zone_unevictable 0
      nr_zone_write_pending 0
      nr_mlock     0
      nr_slab_reclaimable 46
      nr_slab_unreclaimable 90
      nr_page_table_pages 0
      nr_kernel_stack 0
      nr_bounce    0
      nr_zspages   0
      numa_hit     2257
      numa_miss    0
      numa_foreign 0
      numa_interleave 982
      numa_local   0
      numa_other   2257
      nr_free_cma  0
        protection: (0, 0, 0, 0) 
It would be called a misconfiguration but it seems that it might be quite easy
to hit with NUMA machines which have large differences in the node sizes.

Further more, when it consumes most the memory in node3, every alloc slow path
might wake up kswapd3 and it will make things worse:
__alloc_pages_slowpath
    wake_all_kswapds
        wakeup_kswapd

This patch resolves the issue from 2 aspects:
1. In prepare_kswapd_sleep, only when zone is not balanced and there are
  reclaimable pages in this zone, kswapd will go to do relaim without sleeping
2. Don't wake up kswapd if there are no reclaimable pages in that node

After this patch:
top - 07:29:43 up 3 min,  1 user,  load average: 0.12, 0.13, 0.06
Tasks:   1 total,   0 running,   1 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.2 sy,  0.0 ni, 97.8 id,  2.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem:  31371520 total,   938112 used, 30433408 free,     5504 buffers
KiB Swap:  6284224 total,        0 used,  6284224 free.   632448 cached Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND    
   78 root      20   0       0      0      0 S 0.000 0.000   0:00.00 kswapd3    

Changes:
V2: - fix incorrect condition for assignment of node_has_reclaimable_pages
    - make commit decription better

Signed-off-by: Jia He <hejianet@gmail.com>
---
 mm/vmscan.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 532a2a7..7c5a563 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3139,7 +3139,8 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 		if (!managed_zone(zone))
 			continue;
 
-		if (!zone_balanced(zone, order, classzone_idx))
+		if (!zone_balanced(zone, order, classzone_idx)
+			&& zone_reclaimable_pages(zone))
 			return false;
 	}
 
@@ -3502,6 +3503,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
 	int z;
+	int node_has_relaimable_pages = 0;
 
 	if (!managed_zone(zone))
 		return;
@@ -3522,8 +3524,15 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 
 		if (zone_balanced(zone, order, classzone_idx))
 			return;
+
+		if (zone_reclaimable_pages(zone))
+			node_has_relaimable_pages = 1;
 	}
 
+	/* Dont wake kswapd if all zones has no reclaimable pages */
+	if (!node_has_relaimable_pages)
+		return;
+
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
 	wake_up_interruptible(&pgdat->kswapd_wait);
 }
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
