Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 6CFCE6B007D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 02:41:14 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [PATCH v3 9/9] memory-hotplug: allocate zone's pcp before onlining pages
Date: Fri, 19 Oct 2012 14:46:42 +0800
Message-Id: <1350629202-9664-10-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>, Christoph Lameter <cl@linux.com>

From: Wen Congyang <wency@cn.fujitsu.com>

We use __free_page() to put a page to buddy system when onlining pages.
__free_page() will store NR_FREE_PAGES in zone's pcp.vm_stat_diff, so we
should allocate zone's pcp before onlining pages, otherwise we will lose
some free pages.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: Paul Mackerras <paulus@samba.org>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/memory_hotplug.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ec899a2..eb4c132 100644
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
@@ -525,9 +529,7 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	zone->zone_pgdat->node_present_pages += onlined_pages;
 	if (onlined_pages) {
 		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
-		if (need_zonelists_rebuild)
-			build_all_zonelists(NULL, zone);
-		else
+		if (!need_zonelists_rebuild)
 			zone_pcp_update(zone);
 	}
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
