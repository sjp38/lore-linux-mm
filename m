Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4611E6B0031
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 17:29:07 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id ii20so3182841qab.1
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 14:29:07 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id hj7si7316435qeb.2.2013.12.20.14.29.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Dec 2013 14:29:06 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH] mm/memblock: use WARN_ONCE when MAX_NUMNODES passed as input parameter
Date: Fri, 20 Dec 2013 17:28:56 -0500
Message-ID: <1387578536-18280-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, tj@kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>

From: Grygorii Strashko <grygorii.strashko@ti.com>

Check nid parameter and produce warning if it has deprecated MAX_NUMNODES
value. Also re-assign NUMA_NO_NODE value to the nid parameter in this case.

These will help to identify the wrong API usage (the caller) and make code
simpler.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
Incremental update on the memblock series as suggested by Tejun in
below thread:
	https://lkml.org/lkml/2013/12/14/159

 mm/memblock.c |   21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 71b11d9..6af873a 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -707,11 +707,9 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
 	struct memblock_type *rsv = &memblock.reserved;
 	int mi = *idx & 0xffffffff;
 	int ri = *idx >> 32;
-	bool check_node = (nid != NUMA_NO_NODE) && (nid != MAX_NUMNODES);
 
-	if (nid == MAX_NUMNODES)
-		pr_warn_once("%s: Usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE instead\n",
-			     __func__);
+	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
+		nid = NUMA_NO_NODE;
 
 	for ( ; mi < mem->cnt; mi++) {
 		struct memblock_region *m = &mem->regions[mi];
@@ -719,7 +717,7 @@ void __init_memblock __next_free_mem_range(u64 *idx, int nid,
 		phys_addr_t m_end = m->base + m->size;
 
 		/* only memory regions are associated with nodes, check it */
-		if (check_node && nid != memblock_get_region_node(m))
+		if (nid != NUMA_NO_NODE && nid != memblock_get_region_node(m))
 			continue;
 
 		/* scan areas before each reservation for intersection */
@@ -775,11 +773,9 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
 	struct memblock_type *rsv = &memblock.reserved;
 	int mi = *idx & 0xffffffff;
 	int ri = *idx >> 32;
-	bool check_node = (nid != NUMA_NO_NODE) && (nid != MAX_NUMNODES);
 
-	if (nid == MAX_NUMNODES)
-		pr_warn_once("%s: Usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE instead\n",
-			     __func__);
+	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
+		nid = NUMA_NO_NODE;
 
 	if (*idx == (u64)ULLONG_MAX) {
 		mi = mem->cnt - 1;
@@ -792,7 +788,7 @@ void __init_memblock __next_free_mem_range_rev(u64 *idx, int nid,
 		phys_addr_t m_end = m->base + m->size;
 
 		/* only memory regions are associated with nodes, check it */
-		if (check_node && nid != memblock_get_region_node(m))
+		if (nid != NUMA_NO_NODE && nid != memblock_get_region_node(m))
 			continue;
 
 		/* scan areas before each reservation for intersection */
@@ -980,9 +976,8 @@ static void * __init memblock_virt_alloc_internal(
 	phys_addr_t alloc;
 	void *ptr;
 
-	if (nid == MAX_NUMNODES)
-		pr_warn("%s: usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE\n",
-			__func__);
+	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
+		nid = NUMA_NO_NODE;
 
 	/*
 	 * Detect any accidental use of these APIs after slab is ready, as at
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
