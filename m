Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id EADEC6B003D
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 05:18:40 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH part2 2/4] x86, mm, numa, acpi: Introduce hotplug info into struct numa_meminfo.
Date: Thu, 21 Mar 2013 17:21:14 +0800
Message-Id: <1363857676-30694-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1363857676-30694-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1363857676-30694-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, guz.fnst@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since we are using struct numa_meminfo to store SRAT info, and sanitize
movablemem_map.map[], we need hotplug info in struct numa_meminfo.

This patch introduces a "bool hotpluggable" member into struct
numa_meminfo.

And modifies the following APIs' prototypes to support it:
   - numa_add_memblk()
   - numa_add_memblk_to()

And the following callers:
   - numaq_register_node()
   - dummy_numa_init()
   - amd_numa_init()
   - acpi_numa_memory_affinity_init() in x86

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/include/asm/numa.h     |    3 ++-
 arch/x86/kernel/apic/numaq_32.c |    2 +-
 arch/x86/mm/amdtopology.c       |    3 ++-
 arch/x86/mm/numa.c              |   10 +++++++---
 arch/x86/mm/numa_internal.h     |    1 +
 arch/x86/mm/srat.c              |    2 +-
 6 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/numa.h b/arch/x86/include/asm/numa.h
index 1b99ee5..73096b2 100644
--- a/arch/x86/include/asm/numa.h
+++ b/arch/x86/include/asm/numa.h
@@ -31,7 +31,8 @@ extern int numa_off;
 extern s16 __apicid_to_node[MAX_LOCAL_APIC];
 extern nodemask_t numa_nodes_parsed __initdata;
 
-extern int __init numa_add_memblk(int nodeid, u64 start, u64 end);
+extern int __init numa_add_memblk(int nodeid, u64 start, u64 end,
+				  bool hotpluggable);
 extern void __init numa_set_distance(int from, int to, int distance);
 
 static inline void set_apicid_to_node(int apicid, s16 node)
diff --git a/arch/x86/kernel/apic/numaq_32.c b/arch/x86/kernel/apic/numaq_32.c
index d661ee9..7a9c542 100644
--- a/arch/x86/kernel/apic/numaq_32.c
+++ b/arch/x86/kernel/apic/numaq_32.c
@@ -82,7 +82,7 @@ static inline void numaq_register_node(int node, struct sys_cfg_data *scd)
 	int ret;
 
 	node_set(node, numa_nodes_parsed);
-	ret = numa_add_memblk(node, start, end);
+	ret = numa_add_memblk(node, start, end, false);
 	BUG_ON(ret < 0);
 }
 
diff --git a/arch/x86/mm/amdtopology.c b/arch/x86/mm/amdtopology.c
index 5247d01..d521471 100644
--- a/arch/x86/mm/amdtopology.c
+++ b/arch/x86/mm/amdtopology.c
@@ -167,7 +167,8 @@ int __init amd_numa_init(void)
 			nodeid, base, limit);
 
 		prevbase = base;
-		numa_add_memblk(nodeid, base, limit);
+		/* Do not support memory hotplug for AMD cpu. */
+		numa_add_memblk(nodeid, base, limit, false);
 		node_set(nodeid, numa_nodes_parsed);
 	}
 
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 4cf3b49..5f98bb5 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -142,6 +142,7 @@ void __init setup_node_to_cpumask_map(void)
 }
 
 static int __init numa_add_memblk_to(int nid, u64 start, u64 end,
+				     bool hotpluggable,
 				     struct numa_meminfo *mi)
 {
 	/* ignore zero length blks */
@@ -163,6 +164,7 @@ static int __init numa_add_memblk_to(int nid, u64 start, u64 end,
 	mi->blk[mi->nr_blks].start = start;
 	mi->blk[mi->nr_blks].end = end;
 	mi->blk[mi->nr_blks].nid = nid;
+	mi->blk[mi->nr_blks].hotpluggable = hotpluggable;
 	mi->nr_blks++;
 	return 0;
 }
@@ -187,15 +189,17 @@ void __init numa_remove_memblk_from(int idx, struct numa_meminfo *mi)
  * @nid: NUMA node ID of the new memblk
  * @start: Start address of the new memblk
  * @end: End address of the new memblk
+ * @hotpluggable: True if memblk is hotpluggable
  *
  * Add a new memblk to the default numa_meminfo.
  *
  * RETURNS:
  * 0 on success, -errno on failure.
  */
-int __init numa_add_memblk(int nid, u64 start, u64 end)
+int __init numa_add_memblk(int nid, u64 start, u64 end,
+			   bool hotpluggable)
 {
-	return numa_add_memblk_to(nid, start, end, &numa_meminfo);
+	return numa_add_memblk_to(nid, start, end, hotpluggable, &numa_meminfo);
 }
 
 /* Initialize NODE_DATA for a node on the local memory */
@@ -644,7 +648,7 @@ static int __init dummy_numa_init(void)
 	       0LLU, PFN_PHYS(max_pfn) - 1);
 
 	node_set(0, numa_nodes_parsed);
-	numa_add_memblk(0, 0, PFN_PHYS(max_pfn));
+	numa_add_memblk(0, 0, PFN_PHYS(max_pfn), false);
 
 	return 0;
 }
diff --git a/arch/x86/mm/numa_internal.h b/arch/x86/mm/numa_internal.h
index bb2fbcc..1ce4e6b 100644
--- a/arch/x86/mm/numa_internal.h
+++ b/arch/x86/mm/numa_internal.h
@@ -8,6 +8,7 @@ struct numa_memblk {
 	u64			start;
 	u64			end;
 	int			nid;
+	bool			hotpluggable;
 };
 
 struct numa_meminfo {
diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index 4f443de..76c2eb4 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -290,7 +290,7 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 		goto out_err_bad_srat;
 	}
 
-	if (numa_add_memblk(node, start, end) < 0)
+	if (numa_add_memblk(node, start, end, hotpluggable) < 0)
 		goto out_err_bad_srat;
 
 	node_set(node, numa_nodes_parsed);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
