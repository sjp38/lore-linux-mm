Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id BB1708D000A
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 07:10:32 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v5 14/14] memory-hotplug: free node_data when a node is offlined
Date: Mon, 24 Dec 2012 20:09:24 +0800
Message-Id: <1356350964-13437-15-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1356350964-13437-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

From: Wen Congyang <wency@cn.fujitsu.com>

We call hotadd_new_pgdat() to allocate memory to store node_data. So we
should free it when removing a node.

Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/memory_hotplug.c |   20 +++++++++++++++++++-
 1 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f8a1d2f..447fa24 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1680,9 +1680,12 @@ static int check_cpu_on_node(void *data)
 /* offline the node if all memory sections of this node are removed */
 static void try_offline_node(int nid)
 {
+	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
-	unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
+	unsigned long end_pfn = start_pfn + pgdat->node_spanned_pages;
 	unsigned long pfn;
+	struct page *pgdat_page = virt_to_page(pgdat);
+	int i;
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
 		unsigned long section_nr = pfn_to_section_nr(pfn);
@@ -1709,6 +1712,21 @@ static void try_offline_node(int nid)
 	 */
 	node_set_offline(nid);
 	unregister_one_node(nid);
+
+	if (!PageSlab(pgdat_page) && !PageCompound(pgdat_page))
+		/* node data is allocated from boot memory */
+		return;
+
+	/* free waittable in each zone */
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		struct zone *zone = pgdat->node_zones + i;
+
+		if (zone->wait_table)
+			vfree(zone->wait_table);
+	}
+
+	arch_refresh_nodedata(nid, NULL);
+	arch_free_nodedata(pgdat);
 }
 
 int __ref remove_memory(int nid, u64 start, u64 size)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
