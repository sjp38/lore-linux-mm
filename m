Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB728E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:22:35 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o9so6218250pgv.19
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 06:22:35 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a6si1665602pgc.137.2019.01.17.06.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 06:22:33 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0HEJIrF132331
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:22:32 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q2u5krsqt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:22:32 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 17 Jan 2019 14:22:29 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2] mm/page_alloc: check return value of memblock_alloc_node_nopanic()
Date: Thu, 17 Jan 2019 16:22:21 +0200
Message-Id: <1547734941-944-1-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: William Kucharski <william.kucharski@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

There are two early memory allocations that use
memblock_alloc_node_nopanic() and do not check its return value.
While this happens very early during boot and chances that the allocation
will fail are diminishing, it is still worth to have proper checks for the
allocation errors.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: William Kucharski <william.kucharski@oracle.com>
---
v2: add pgdat->node_id to panic message

 mm/page_alloc.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d295c9bc01a8..13d5b338f434 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6376,10 +6376,14 @@ static void __ref setup_usemap(struct pglist_data *pgdat,
 {
 	unsigned long usemapsize = usemap_size(zone_start_pfn, zonesize);
 	zone->pageblock_flags = NULL;
-	if (usemapsize)
+	if (usemapsize) {
 		zone->pageblock_flags =
 			memblock_alloc_node_nopanic(usemapsize,
 							 pgdat->node_id);
+		if (!zone->pageblock_flags)
+			panic("Failed to allocate %ld bytes for zone %s pageblock flags on node %d\n",
+			      usemapsize, zone->name, pgdat->node_id);
+	}
 }
 #else
 static inline void setup_usemap(struct pglist_data *pgdat, struct zone *zone,
@@ -6609,6 +6613,9 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 		end = ALIGN(end, MAX_ORDER_NR_PAGES);
 		size =  (end - start) * sizeof(struct page);
 		map = memblock_alloc_node_nopanic(size, pgdat->node_id);
+		if (!map)
+			panic("Failed to allocate %ld bytes for node %d memory map\n",
+			      size, pgdat->node_id);
 		pgdat->node_mem_map = map + offset;
 	}
 	pr_debug("%s: node %d, pgdat %08lx, node_mem_map %08lx\n",
-- 
2.7.4
