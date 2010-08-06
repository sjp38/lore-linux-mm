Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D9A126B02AD
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:39 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FWT4025400
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:32 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FZet1200154
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:35 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FXMW021158
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 28/43] memblock: split memblock_find_base() out of __memblock_alloc_base()
Date: Fri,  6 Aug 2010 15:15:09 +1000
Message-Id: <1281071724-28740-29-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

This will be used by the array resize code and might prove useful
to some arch code as well at which point it can be made non-static.

Also add comment as to why aligning size is important

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

v2. Fix loss of size alignment
v3. Fix result code
---
 mm/memblock.c |   58 +++++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 38 insertions(+), 20 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index ae856d4..b775fca 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -345,12 +345,15 @@ phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int n
 
 	BUG_ON(0 == size);
 
+	/* We align the size to limit fragmentation. Without this, a lot of
+	 * small allocs quickly eat up the whole reserve array on sparc
+	 */
+	size = memblock_align_up(size, align);
+
 	/* We do a bottom-up search for a region with the right
 	 * nid since that's easier considering how memblock_nid_range()
 	 * works
 	 */
-	size = memblock_align_up(size, align);
-
 	for (i = 0; i < mem->cnt; i++) {
 		phys_addr_t ret = memblock_alloc_nid_region(&mem->regions[i],
 					       size, align, nid);
@@ -366,20 +369,7 @@ phys_addr_t __init memblock_alloc(phys_addr_t size, phys_addr_t align)
 	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
-phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
-{
-	phys_addr_t alloc;
-
-	alloc = __memblock_alloc_base(size, align, max_addr);
-
-	if (alloc == 0)
-		panic("ERROR: Failed to allocate 0x%llx bytes below 0x%llx.\n",
-		      (unsigned long long) size, (unsigned long long) max_addr);
-
-	return alloc;
-}
-
-phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
+static phys_addr_t __init memblock_find_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
 {
 	long i;
 	phys_addr_t base = 0;
@@ -387,8 +377,6 @@ phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, ph
 
 	BUG_ON(0 == size);
 
-	size = memblock_align_up(size, align);
-
 	/* Pump up max_addr */
 	if (max_addr == MEMBLOCK_ALLOC_ACCESSIBLE)
 		max_addr = memblock.current_limit;
@@ -405,13 +393,43 @@ phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, ph
 			continue;
 		base = min(memblockbase + memblocksize, max_addr);
 		res_base = memblock_find_region(memblockbase, base, size, align);
-		if (res_base != MEMBLOCK_ERROR &&
-		    memblock_add_region(&memblock.reserved, res_base, size) >= 0)
+		if (res_base != MEMBLOCK_ERROR)
 			return res_base;
 	}
+	return MEMBLOCK_ERROR;
+}
+
+phys_addr_t __init __memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
+{	
+	phys_addr_t found;
+
+	/* We align the size to limit fragmentation. Without this, a lot of
+	 * small allocs quickly eat up the whole reserve array on sparc
+	 */
+	size = memblock_align_up(size, align);
+
+	found = memblock_find_base(size, align, max_addr);
+	if (found != MEMBLOCK_ERROR &&
+	    memblock_add_region(&memblock.reserved, found, size) >= 0)
+		return found;
+
 	return 0;
 }
 
+phys_addr_t __init memblock_alloc_base(phys_addr_t size, phys_addr_t align, phys_addr_t max_addr)
+{
+	phys_addr_t alloc;
+
+	alloc = __memblock_alloc_base(size, align, max_addr);
+
+	if (alloc == 0)
+		panic("ERROR: Failed to allocate 0x%llx bytes below 0x%llx.\n",
+		      (unsigned long long) size, (unsigned long long) max_addr);
+
+	return alloc;
+}
+
+
 /* You must call memblock_analyze() before this. */
 phys_addr_t __init memblock_phys_mem_size(void)
 {
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
