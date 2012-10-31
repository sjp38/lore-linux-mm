Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E8ED96B0072
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 07:48:24 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [Patch v4 8/8] memory-hotplug: allocate zone's pcp before onlining pages
Date: Wed, 31 Oct 2012 19:23:14 +0800
Message-Id: <1351682594-17347-9-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351682594-17347-1-git-send-email-wency@cn.fujitsu.com>
References: <1351682594-17347-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org
Cc: Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rjw@sisk.pl, Lai Jiangshan <laijs@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>

We use __free_page() to put a page to buddy system when onlining pages.
__free_page() will store NR_FREE_PAGES in zone's pcp.vm_stat_diff, so we
should allocate zone's pcp before onlining pages, otherwise we will lose
some free pages.

Cc: David Rientjes <rientjes@google.com>
Cc: Jiang Liu <liuj97@gmail.com>
Cc: Len Brown <len.brown@intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/memory_hotplug.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 72f4fef..63ea7df 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -505,12 +505,16 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	 * So, zonelist must be updated after online.
 	 */
 	mutex_lock(&zonelists_mutex);
-	if (!populated_zone(zone))
+	if (!populated_zone(zone)) {
 		need_zonelists_rebuild = 1;
+		build_all_zonelists(NULL, zone);
+	}
 
 	ret = walk_system_ram_range(pfn, nr_pages, &onlined_pages,
 		online_pages_range);
 	if (ret) {
+		if (need_zonelists_rebuild)
+			zone_pcp_reset(zone);
 		mutex_unlock(&zonelists_mutex);
 		printk(KERN_DEBUG "online_pages [mem %#010llx-%#010llx] failed\n",
 		       (unsigned long long) pfn << PAGE_SHIFT,
@@ -526,7 +530,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	if (onlined_pages) {
 		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
 		if (need_zonelists_rebuild)
-			build_all_zonelists(NULL, zone);
+			build_all_zonelists(NULL, NULL);
 		else
 			zone_pcp_update(zone);
 	}
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
