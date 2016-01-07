Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 425846B0006
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 23:19:38 -0500 (EST)
Received: by mail-ig0-f179.google.com with SMTP id z14so43422718igp.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 20:19:38 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id 17si5336882iog.181.2016.01.06.20.19.36
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 20:19:37 -0800 (PST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 1/5] x86, memhp, numa: Online memory-less nodes at boot time.
Date: Thu, 7 Jan 2016 12:20:21 +0800
Message-ID: <1452140425-16577-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1452140425-16577-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1452140425-16577-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, tj@kernel.org, jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com
Cc: tangchen@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

For now, x86 does not support memory-less node. A node without memory
will not be onlined, and the cpus on it will be mapped to the other
online nodes with memory in init_cpu_to_node(). The reason of doing this
is to ensure each cpu has mapped to a node with memory, so that it will
be able to allocate local memory for that cpu.

But we don't have to do it in this way.

In this series of patches, we are going to construct cpu <-> node mapping
for all possible cpus at boot time, which is a 1-1 mapping. It means the
cpu will be mapped to the node it belongs to, and will never be changed.
If a node has only cpus but no memory, the cpus on it will be mapped to
a memory-less node. And the memory-less node should be onlined.

This patch allocate pgdats for all memory-less nodes and online them at
boot time. As a result, when cpus on these memory-less nodes try to allocate 
memory from local node, it will automatically fall back to the proper zones 
in the zonelists.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c     | 27 +++++++++++++--------------
 include/linux/mmzone.h |  1 +
 mm/page_alloc.c        |  2 +-
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index c3b3f65..010edb4 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -704,22 +704,19 @@ void __init x86_numa_init(void)
 	numa_init(dummy_numa_init);
 }
 
-static __init int find_near_online_node(int node)
+static void __init init_memory_less_node(int nid)
 {
-	int n, val;
-	int min_val = INT_MAX;
-	int best_node = -1;
+	unsigned long zones_size[MAX_NR_ZONES] = {0};
+	unsigned long zholes_size[MAX_NR_ZONES] = {0};
 
-	for_each_online_node(n) {
-		val = node_distance(node, n);
+	/* Allocate and initialize node data. Memory-less node is now online.*/
+	alloc_node_data(nid);
+	free_area_init_node(nid, zones_size, 0, zholes_size);
 
-		if (val < min_val) {
-			min_val = val;
-			best_node = n;
-		}
-	}
-
-	return best_node;
+	/*
+	 * All zonelists will be built later in start_kernel() after per cpu
+	 * areas are initialized.
+	 */
 }
 
 /*
@@ -748,8 +745,10 @@ void __init init_cpu_to_node(void)
 
 		if (node == NUMA_NO_NODE)
 			continue;
+
 		if (!node_online(node))
-			node = find_near_online_node(node);
+			init_memory_less_node(node);
+
 		numa_set_node(cpu, node);
 	}
 }
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e23a9e7..9c4d4d5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -736,6 +736,7 @@ static inline bool is_dev_zone(const struct zone *zone)
 
 extern struct mutex zonelists_mutex;
 void build_all_zonelists(pg_data_t *pgdat, struct zone *zone);
+void build_zonelists(pg_data_t *pgdat);
 void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx);
 bool zone_watermark_ok(struct zone *z, unsigned int order,
 		unsigned long mark, int classzone_idx, int alloc_flags);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d666df..15c0358 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4145,7 +4145,7 @@ static void set_zonelist_order(void)
 		current_zonelist_order = user_zonelist_order;
 }
 
-static void build_zonelists(pg_data_t *pgdat)
+void build_zonelists(pg_data_t *pgdat)
 {
 	int j, node, load;
 	enum zone_type i;
-- 
1.9.3



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
