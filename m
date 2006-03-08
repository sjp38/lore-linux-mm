Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
        by fgwmail7.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k28DgkfP011492 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:42:46 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp by m5.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k28Dgj5o026478 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:42:45 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s3.gw.fujitsu.co.jp (s3 [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9ED16D40B3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:42:45 +0900 (JST)
Received: from ml8.s.css.fujitsu.com (ml8.s.css.fujitsu.com [10.23.4.198])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F6B1D40B2
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:42:45 +0900 (JST)
Date: Wed, 08 Mar 2006 22:42:44 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 012/017](RFC) Memory hotplug for new nodes v.3. (rebuild zonelists after online pages)
Message-Id: <20060308213410.003A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

In current code, zonelist is considered to be build once, no modification.
But MemoryHotplug can add new zone/pgdat. It must be updated.

This patch modifies build_all_zonelists(). 
By this, build_all_zonelist() can reconfig pgdat's zonelists.

To update them safety, this patch use stop_machine_run().
Other cpus don't touch among updating them by using it.

In previous version (V2), kernel updated them after zone initialization.
But present_page of its new zone is still 0, because online_page()
is not called yet at this time. 
Build_zonelists() checks present_pages to find present zone.
It was too early. So, I changed it after online_pages().

Signed-off-by: Yasunori Goto     <y-goto@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: pgdat6/mm/page_alloc.c
===================================================================
--- pgdat6.orig/mm/page_alloc.c	2006-03-06 21:08:35.000000000 +0900
+++ pgdat6/mm/page_alloc.c	2006-03-06 21:08:46.000000000 +0900
@@ -37,6 +37,7 @@
 #include <linux/nodemask.h>
 #include <linux/vmalloc.h>
 #include <linux/mempolicy.h>
+#include <linux/stop_machine.h>
 
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -1761,14 +1762,29 @@ static void __meminit build_zonelists(pg
 
 #endif	/* CONFIG_NUMA */
 
-void __init build_all_zonelists(void)
+/* return values int ....just for stop_machine_run() */
+static int __meminit __build_all_zonelists(void *dummy)
 {
-	int i;
+	int nid;
+	for_each_online_node(nid)
+		build_zonelists(NODE_DATA(nid));
+	return 0;
+}
+
+void __meminit build_all_zonelists(void)
+{
+	if (system_state == SYSTEM_BOOTING) {
+		__build_all_zonelists(0);
+		cpuset_init_current_mems_allowed();
+	} else {
+		/* we have to stop all cpus to guaranntee there is no user
+		   of zonelist */
+		stop_machine_run(__build_all_zonelists, NULL, NR_CPUS);
+		/* cpuset refresh routine should be here */
+	}
 
-	for_each_online_node(i)
-		build_zonelists(NODE_DATA(i));
 	printk("Built %i zonelists\n", num_online_nodes());
-	cpuset_init_current_mems_allowed();
+
 }
 
 /*
Index: pgdat6/mm/memory_hotplug.c
===================================================================
--- pgdat6.orig/mm/memory_hotplug.c	2006-03-06 21:07:19.000000000 +0900
+++ pgdat6/mm/memory_hotplug.c	2006-03-06 21:08:46.000000000 +0900
@@ -123,6 +123,7 @@ int online_pages(unsigned long pfn, unsi
 	unsigned long flags;
 	unsigned long onlined_pages = 0;
 	struct zone *zone;
+	int need_refresh_zonelist = 0;
 
 	/*
 	 * This doesn't need a lock to do pfn_to_page().
@@ -135,6 +136,14 @@ int online_pages(unsigned long pfn, unsi
 	grow_pgdat_span(zone->zone_pgdat, pfn, pfn + nr_pages);
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 
+	/*
+	 * If this zone is not populated, then it is not in zonelist.
+	 * This means the page allocator ignores this zone.
+	 * So, zonelist must be updated after online.
+	 */
+	if (!populated_zone(zone))
+		need_refresh_zonelist = 1;
+
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page = pfn_to_page(pfn + i);
 		online_page(page);
@@ -144,6 +153,9 @@ int online_pages(unsigned long pfn, unsi
 
 	setup_per_zone_pages_min();
 
+	if (need_refresh_zonelist)
+		build_all_zonelists();
+
 	return 0;
 }
 

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
