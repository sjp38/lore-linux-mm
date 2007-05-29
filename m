Date: Tue, 29 May 2007 18:47:32 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH](memory hotplug) Fix unnecessary calling of init_currenty_empty_zone()
Message-Id: <20070529183819.159F.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hello.

This patch is to fix unnecessary calling of init_currently_empty_zone().

zone->present_pages is updated in online_pages(). But,
__add_zone() can be called twice or more before calling online_pages().
So, init_currenty_empty_zone() can be called unnecessary times.
It is cause of memory leak of zone's wait_table.

This patch is tested on my ia64 box with 2.6.22-rc2-mm1.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 mm/memory_hotplug.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: vmemmap/mm/memory_hotplug.c
===================================================================
--- vmemmap.orig/mm/memory_hotplug.c	2007-05-29 15:30:28.000000000 +0900
+++ vmemmap/mm/memory_hotplug.c	2007-05-29 17:31:43.000000000 +0900
@@ -65,7 +65,7 @@ static int __add_zone(struct zone *zone,
 	int zone_type;
 
 	zone_type = zone - pgdat->node_zones;
-	if (!populated_zone(zone)) {
+	if (!zone->wait_table) {
 		int ret = 0;
 		ret = init_currently_empty_zone(zone, phys_start_pfn,
 						nr_pages, MEMMAP_HOTPLUG);

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
