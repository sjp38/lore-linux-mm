Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 785726B0037
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:46 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so1708953eei.14
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q2si40616556eep.102.2014.04.18.07.50.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:45 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 01/16] mm: Disable zone_reclaim_mode by default
Date: Fri, 18 Apr 2014 15:50:28 +0100
Message-Id: <1397832643-14275-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

zone_reclaim_mode causes processes to prefer reclaiming memory from local
node instead of spilling over to other nodes. This made sense initially when
NUMA machines were almost exclusively HPC and the workload was partitioned
into nodes. The NUMA penalties were sufficiently high to justify reclaiming
the memory. On current machines and workloads it is often the case that
zone_reclaim_mode destroys performance but not all users know how to detect
this. Favour the common case and disable it by default. Users that are
sophisticated enough to know they need zone_reclaim_mode will detect it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 Documentation/sysctl/vm.txt         | 17 +++++++++--------
 arch/ia64/include/asm/topology.h    |  3 ++-
 arch/powerpc/include/asm/topology.h |  8 ++------
 include/linux/topology.h            |  3 ++-
 mm/page_alloc.c                     |  2 --
 5 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index dd9d0e3..5b6da0f 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -772,16 +772,17 @@ This is value ORed together of
 2	= Zone reclaim writes dirty pages out
 4	= Zone reclaim swaps pages
 
-zone_reclaim_mode is set during bootup to 1 if it is determined that pages
-from remote zones will cause a measurable performance reduction. The
-page allocator will then reclaim easily reusable pages (those page
-cache pages that are currently not used) before allocating off node pages.
-
-It may be beneficial to switch off zone reclaim if the system is
-used for a file server and all of memory should be used for caching files
-from disk. In that case the caching effect is more important than
+zone_reclaim_mode is disabled by default.  For file servers or workloads
+that benefit from having their data cached, zone_reclaim_mode should be
+left disabled as the caching effect is likely to be more important than
 data locality.
 
+zone_reclaim may be enabled if it's known that the workload is partitioned
+such that each partition fits within a NUMA node and that accessing remote
+memory would cause a measurable performance reduction.  The page allocator
+will then reclaim easily reusable pages (those page cache pages that are
+currently not used) before allocating off node pages.
+
 Allowing zone reclaim to write out pages stops processes that are
 writing large amounts of data from dirtying pages on other nodes. Zone
 reclaim will write out dirty pages if a zone fills up and so effectively
diff --git a/arch/ia64/include/asm/topology.h b/arch/ia64/include/asm/topology.h
index 5cb55a1..3555fdd 100644
--- a/arch/ia64/include/asm/topology.h
+++ b/arch/ia64/include/asm/topology.h
@@ -21,7 +21,8 @@
 #define PENALTY_FOR_NODE_WITH_CPUS 255
 
 /*
- * Distance above which we begin to use zone reclaim
+ * Nodes within this distance are eligible for reclaim by zone_reclaim() when
+ * zone_reclaim_mode is enabled.
  */
 #define RECLAIM_DISTANCE 15
 
diff --git a/arch/powerpc/include/asm/topology.h b/arch/powerpc/include/asm/topology.h
index c920215..6c8a8c5 100644
--- a/arch/powerpc/include/asm/topology.h
+++ b/arch/powerpc/include/asm/topology.h
@@ -9,12 +9,8 @@ struct device_node;
 #ifdef CONFIG_NUMA
 
 /*
- * Before going off node we want the VM to try and reclaim from the local
- * node. It does this if the remote distance is larger than RECLAIM_DISTANCE.
- * With the default REMOTE_DISTANCE of 20 and the default RECLAIM_DISTANCE of
- * 20, we never reclaim and go off node straight away.
- *
- * To fix this we choose a smaller value of RECLAIM_DISTANCE.
+ * If zone_reclaim_mode is enabled, a RECLAIM_DISTANCE of 10 will mean that
+ * all zones on all nodes will be eligible for zone_reclaim().
  */
 #define RECLAIM_DISTANCE 10
 
diff --git a/include/linux/topology.h b/include/linux/topology.h
index 7062330..53261e2 100644
--- a/include/linux/topology.h
+++ b/include/linux/topology.h
@@ -58,7 +58,8 @@ int arch_update_cpu_topology(void);
 /*
  * If the distance between nodes in a system is larger than RECLAIM_DISTANCE
  * (in whatever arch specific measurement units returned by node_distance())
- * then switch on zone reclaim on boot.
+ * and zone_reclaim_mode is enabled then the VM will only call zone_reclaim()
+ * on nodes within this distance.
  */
 #define RECLAIM_DISTANCE 30
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dba293..628f1e7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1860,8 +1860,6 @@ static void __paginginit init_zone_allows_reclaim(int nid)
 	for_each_node_state(i, N_MEMORY)
 		if (node_distance(nid, i) <= RECLAIM_DISTANCE)
 			node_set(i, NODE_DATA(nid)->reclaim_nodes);
-		else
-			zone_reclaim_mode = 1;
 }
 
 #else	/* CONFIG_NUMA */
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
