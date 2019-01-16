Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 73CD98E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 01:51:32 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id t10so3245698plo.13
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 22:51:32 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d23si5330170pgj.558.2019.01.15.22.51.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 22:51:31 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0G6iIZV136406
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 01:51:30 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q1xdckve5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 01:51:30 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 16 Jan 2019 06:51:28 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] mm/page_alloc: check return value of memblock_alloc_node_nopanic()
Date: Wed, 16 Jan 2019 08:51:21 +0200
Message-Id: <1547621481-8374-1-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

There are two early memory allocations that use
memblock_alloc_node_nopanic() and do not check its return value.
While this happens very early during boot and chances that the allocation
will fail are diminishing, it is still worth to have proper checks for the
allocation errors.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/page_alloc.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d295c9bc01a8..7801accbe02a 100644
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
+			panic("Failed to allocate %ld bytes for zone %s pageblock flags\n",
+			      usemapsize, zone->name);
+	}
 }
 #else
 static inline void setup_usemap(struct pglist_data *pgdat, struct zone *zone,
@@ -6609,6 +6613,9 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 		end = ALIGN(end, MAX_ORDER_NR_PAGES);
 		size =  (end - start) * sizeof(struct page);
 		map = memblock_alloc_node_nopanic(size, pgdat->node_id);
+		if (!map)
+			panic("Failed to allocate %ld bytes for memory map\n",
+			      size);
 		pgdat->node_mem_map = map + offset;
 	}
 	pr_debug("%s: node %d, pgdat %08lx, node_mem_map %08lx\n",
-- 
2.7.4
