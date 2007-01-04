Date: Thu, 4 Jan 2007 10:37:12 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Check for populated zone in __drain_pages.
Message-ID: <Pine.LNX.4.64.0701041036210.21784@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Both process_zones()and drain_node_pages() check for populated zones before
touching pagesets. However, __drain_pages does not do so,

This may result in a NULL pointer dereference for pagesets in unpopulated
zones if a NUMA setup is combined with cpu hotplug.

Initially the unpopulated zone has the pcp pointers pointing to the boot
pagesets.  Since the zone is not populated the boot pageset pointers will
not be changed during page allocator and slab bootstrap.

If a cpu is later brought down (first call to __drain_pages()) then the pcp
pointers for cpus in unpopulated zones are set to NULL since __drain_pages
does not first check for an unpopulated zone.

If the cpu is then brought up again then we call process_zones() which will ignore
the unpopulated zone. So the pageset pointers will still be NULL.

If the cpu is then again brought down then __drain_pages will attempt to drain
pages by following the NULL pageset pointer for unpopulated zones.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-01-04 09:07:32.000000000 -0800
+++ linux-2.6/mm/page_alloc.c	2007-01-04 09:08:00.000000000 -0800
@@ -711,6 +711,9 @@
 	for_each_zone(zone) {
 		struct per_cpu_pageset *pset;
 
+		if (!populated_zone(zone))
+			continue;
+
 		pset = zone_pcp(zone, cpu);
 		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
 			struct per_cpu_pages *pcp;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
