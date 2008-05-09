Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m4964RrU511014
	for <linux-mm@kvack.org>; Fri, 9 May 2008 06:04:27 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4964QZa2633916
	for <linux-mm@kvack.org>; Fri, 9 May 2008 07:04:27 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4964QmZ014610
	for <linux-mm@kvack.org>; Fri, 9 May 2008 07:04:26 +0100
Date: Fri, 9 May 2008 08:04:25 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] memory hotplug: memmap_init_zone called twice.
Message-ID: <20080509060425.GA9840@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Subject: [PATCH] memory hotplug: memmap_init_zone called twice.
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

__add_zone calls memmap_init_zone twice if memory gets attached to
an empty zone. Once via init_currently_empty_zone and once explictly
right after that call.
Looks like this is currently not a bug, however the call is
superfluous and might lead to subtle bugs if memmap_init_zone gets
changed. So make sure it is called only once.

Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <haveblue@us.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 mm/memory_hotplug.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/memory_hotplug.c
===================================================================
--- linux-2.6.orig/mm/memory_hotplug.c
+++ linux-2.6/mm/memory_hotplug.c
@@ -167,13 +167,9 @@ static int __add_zone(struct zone *zone,
 	int zone_type;
 
 	zone_type = zone - pgdat->node_zones;
-	if (!zone->wait_table) {
-		int ret = 0;
-		ret = init_currently_empty_zone(zone, phys_start_pfn,
-						nr_pages, MEMMAP_HOTPLUG);
-		if (ret < 0)
-			return ret;
-	}
+	if (!zone->wait_table)
+		return init_currently_empty_zone(zone, phys_start_pfn,
+						 nr_pages, MEMMAP_HOTPLUG);
 	memmap_init_zone(nr_pages, nid, zone_type,
 			 phys_start_pfn, MEMMAP_HOTPLUG);
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
