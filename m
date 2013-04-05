Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 11DD26B0074
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 05:37:27 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 09/11] x86, numa, acpi, memory-hotplug: Sanitize zone_movable_limit[].
Date: Fri, 5 Apr 2013 17:39:59 +0800
Message-Id: <1365154801-473-10-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1365154801-473-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1365154801-473-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, jiang.liu@huawei.com, guz.fnst@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

As mentioned by Liu Jiang and Wu Jiangguo, users could specify DMA,
DMA32, and HIGHMEM as movable. In order to ensure the kernel will
work correctly, we should exclude these memory ranges out from
zone_movable_limit[].

NOTE: Do find_usable_zone_for_movable() to initialize movable_zone
      so that sanitize_zone_movable_limit() could use it. This is
      pointed out by Wu Jianguo <wujianguo@huawei.com>.

Reported-by: Wu Jianguo <wujianguo@huawei.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Liu Jiang <jiang.liu@huawei.com>
Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
Reviewed-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Tested-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 mm/page_alloc.c |   54 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 53 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b97bdb5..f800aec 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4412,6 +4412,57 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
 	return __absent_pages_in_range(nid, zone_start_pfn, zone_end_pfn);
 }
 
+/**
+ * sanitize_zone_movable_limit - Sanitize the zone_movable_limit array.
+ *
+ * zone_movable_limit[] have been initialized when parsing SRAT or
+ * movablemem_map. This function will try to exclude ZONE_DMA, ZONE_DMA32,
+ * and HIGHMEM from zone_movable_limit[].
+ *
+ * zone_movable_limit[nid] == 0 means no limit for the node.
+ *
+ * Note: Need to be called with movable_zone initialized.
+ */
+static void __meminit sanitize_zone_movable_limit(void)
+{
+	int nid;
+
+	if (!movablemem_map.nr_map)
+		return;
+
+	/* Iterate each node id. */
+	for_each_node(nid) {
+		/* If we have no limit for this node, just skip it. */
+		if (!zone_movable_limit[nid])
+			continue;
+
+#ifdef CONFIG_ZONE_DMA
+		/* Skip DMA memory. */
+		if (zone_movable_limit[nid] <
+		    arch_zone_highest_possible_pfn[ZONE_DMA])
+			zone_movable_limit[nid] =
+				arch_zone_highest_possible_pfn[ZONE_DMA];
+#endif
+
+#ifdef CONFIG_ZONE_DMA32
+		/* Skip DMA32 memory. */
+		if (zone_movable_limit[nid] <
+		    arch_zone_highest_possible_pfn[ZONE_DMA32])
+			zone_movable_limit[nid] =
+				arch_zone_highest_possible_pfn[ZONE_DMA32];
+#endif
+
+#ifdef CONFIG_HIGHMEM
+		/* Skip lowmem if ZONE_MOVABLE is highmem. */
+		if (zone_movable_is_highmem() &&
+		    zone_movable_limit[nid] <
+		    arch_zone_lowest_possible_pfn[ZONE_HIGHMEM])
+			zone_movable_limit[nid] =
+				arch_zone_lowest_possible_pfn[ZONE_HIGHMEM];
+#endif
+	}
+}
+
 #else /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 static inline unsigned long __meminit zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
@@ -4826,7 +4877,6 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 		goto out;
 
 	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
-	find_usable_zone_for_movable();
 	usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
 
 restart:
@@ -4985,6 +5035,8 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 
 	/* Find the PFNs that ZONE_MOVABLE begins at in each node */
 	memset(zone_movable_pfn, 0, sizeof(zone_movable_pfn));
+	find_usable_zone_for_movable();
+	sanitize_zone_movable_limit();
 	find_zone_movable_pfns_for_nodes();
 
 	/* Print out the zone ranges */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
