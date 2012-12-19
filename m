Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 7919D6B005D
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 03:16:09 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v4 3/6] ACPI: Restructure movablecore_map with memory info from SRAT.
Date: Wed, 19 Dec 2012 16:15:00 +0800
Message-Id: <1355904903-22699-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1355904903-22699-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1355904903-22699-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, akpm@linux-foundation.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>

The Hot Plugable bit in SRAT flags specifys if the memory range
could be hotplugged.

If user specified movablecore_map=nn[KMG]@ss[KMG], reset
movablecore_map.map to the intersection of hotpluggable ranges from
SRAT and old movablecore_map.map.
Else if user specified movablecore_map=acpi, just use the hotpluggable
ranges from SRAT.
Otherwise, do nothing. The kernel will use all the memory in all nodes
evenly.

The idea "getting info from SRAT" was from Liu Jiang <jiang.liu@huawei.com>.
And the idea "do more limit for memblock" was from Wu Jianguo <wujianguo@huawei.com>

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Tested-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
---
 arch/x86/mm/srat.c |   38 +++++++++++++++++++++++++++++++++++---
 1 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
index 4ddf497..947a2b5 100644
--- a/arch/x86/mm/srat.c
+++ b/arch/x86/mm/srat.c
@@ -146,7 +146,12 @@ int __init
 acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 {
 	u64 start, end;
+	u32 hotpluggable;
 	int node, pxm;
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+	int overlap;
+	unsigned long start_pfn, end_pfn;
+#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
 	if (srat_disabled())
 		return -1;
@@ -157,8 +162,10 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	if ((ma->flags & ACPI_SRAT_MEM_ENABLED) == 0)
 		return -1;
 
-	if ((ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE) && !save_add_info())
+	hotpluggable = ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE;
+	if (hotpluggable && !save_add_info())
 		return -1;
+
 	start = ma->base_address;
 	end = start + ma->length;
 	pxm = ma->proximity_domain;
@@ -178,9 +185,34 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 
 	node_set(node, numa_nodes_parsed);
 
-	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]\n",
+	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx] %s\n",
 	       node, pxm,
-	       (unsigned long long) start, (unsigned long long) end - 1);
+	       (unsigned long long) start, (unsigned long long) end - 1,
+	       hotpluggable ? "Hot Pluggable": "");
+
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+	start_pfn = PFN_DOWN(start);
+	end_pfn = PFN_UP(end);
+
+	if (!hotpluggable) {
+		/* Clear the range overlapped in movablecore_map.map */
+		remove_movablecore_map(start_pfn, end_pfn);
+		goto out;
+	}
+
+	/* If not using SRAT, don't modify user configuration. */
+	if (!movablecore_map.acpi)
+		goto out;
+
+	/* If user chose to use SRAT info, insert the range anyway. */
+	if (insert_movablecore_map(start_pfn, end_pfn))
+		pr_err("movablecore_map: too many entries;"
+			" ignoring [mem %#010llx-%#010llx]\n",
+			(unsigned long long) start,
+			(unsigned long long) (end - 1));
+
+out:
+#endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 	return 0;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
