Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 42FBD6B0087
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 04:33:42 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v6 14/15] memory-hotplug: free node_data when a node is offlined
Date: Wed, 9 Jan 2013 17:32:38 +0800
Message-Id: <1357723959-5416-15-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

From: Wen Congyang <wency@cn.fujitsu.com>

We call hotadd_new_pgdat() to allocate memory to store node_data. So we
should free it when removing a node.

Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
Reviewed-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memory_hotplug.c |   30 +++++++++++++++++++++++++++---
 1 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a8703f7..8b67752 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1699,9 +1699,12 @@ static int check_cpu_on_node(void *data)
 /* offline the node if all memory sections of this node are removed */
 static void try_offline_node(int nid)
 {
-	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
-	unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
+	pg_data_t *pgdat = NODE_DATA(nid);
+	unsigned long start_pfn = pgdat->node_start_pfn;
+	unsigned long end_pfn = start_pfn + pgdat->node_spanned_pages;
 	unsigned long pfn;
+	struct page *pgdat_page = virt_to_page(pgdat);
+	int i;
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
 		unsigned long section_nr = pfn_to_section_nr(pfn);
@@ -1719,7 +1722,7 @@ static void try_offline_node(int nid)
 		return;
 	}
 
-	if (stop_machine(check_cpu_on_node, NODE_DATA(nid), NULL))
+	if (stop_machine(check_cpu_on_node, pgdat, NULL))
 		return;
 
 	/*
@@ -1728,6 +1731,27 @@ static void try_offline_node(int nid)
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
+	/*
+	 * Since there is no way to guarentee the address of pgdat/zone is not
+	 * on stack of any kernel threads or used by other kernel objects
+	 * without reference counting or other symchronizing method, do not
+	 * reset node_data and free pgdat here. Just reset it to 0 and reuse
+	 * the memory when the node is online again.
+	 */
+	memset(pgdat, 0, sizeof(*pgdat));
 }
 
 int __ref remove_memory(int nid, u64 start, u64 size)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
