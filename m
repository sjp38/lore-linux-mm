Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BDAF06002D3
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:36 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765BCEJ011577
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:11:12 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FYR01818736
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FYwm026031
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 33/43] memblock: NUMA allocate can now use early_pfn_map
Date: Fri,  6 Aug 2010 15:15:14 +1000
Message-Id: <1281071724-28740-34-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

We now provide a default (weak) implementation of memblock_nid_range()
which uses the early_pfn_map[] if CONFIG_ARCH_POPULATES_NODE_MAP
is set. Sparc still needs to use its own method due to the way
the pages can be scattered between nodes.

This implementation is inefficient due to our main algorithm and
callback construct wanting to work on an ascending addresses bases
while early_pfn_map[] would rather work with nid's (it's unsorted
at that stage). But it should work and we can look into improving
it subsequently, possibly using arch compile options to chose a
different algorithm alltogether.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/memblock.h |    3 +++
 mm/memblock.c            |   28 +++++++++++++++++++++++++++-
 2 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index e5e8f9d..82b0302 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -47,6 +47,9 @@ extern long memblock_remove(phys_addr_t base, phys_addr_t size);
 extern long __init memblock_free(phys_addr_t base, phys_addr_t size);
 extern long __init memblock_reserve(phys_addr_t base, phys_addr_t size);
 
+/* The numa aware allocator is only available if
+ * CONFIG_ARCH_POPULATES_NODE_MAP is set
+ */
 extern phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
 extern phys_addr_t __init memblock_alloc(phys_addr_t size, phys_addr_t align);
 
diff --git a/mm/memblock.c b/mm/memblock.c
index 468ff43..af7e4d9 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -15,6 +15,7 @@
 #include <linux/init.h>
 #include <linux/bitops.h>
 #include <linux/poison.h>
+#include <linux/pfn.h>
 #include <linux/memblock.h>
 
 struct memblock memblock;
@@ -451,11 +452,36 @@ phys_addr_t __init memblock_alloc(phys_addr_t size, phys_addr_t align)
 /*
  * Additional node-local allocators. Search for node memory is bottom up
  * and walks memblock regions within that node bottom-up as well, but allocation
- * within an memblock region is top-down.
+ * within an memblock region is top-down. XXX I plan to fix that at some stage
+ *
+ * WARNING: Only available after early_node_map[] has been populated,
+ * on some architectures, that is after all the calls to add_active_range()
+ * have been done to populate it.
  */
 
 phys_addr_t __weak __init memblock_nid_range(phys_addr_t start, phys_addr_t end, int *nid)
 {
+#ifdef CONFIG_ARCH_POPULATES_NODE_MAP
+	/*
+	 * This code originates from sparc which really wants use to walk by addresses
+	 * and returns the nid. This is not very convenient for early_pfn_map[] users
+	 * as the map isn't sorted yet, and it really wants to be walked by nid.
+	 *
+	 * For now, I implement the inefficient method below which walks the early
+	 * map multiple times. Eventually we may want to use an ARCH config option
+	 * to implement a completely different method for both case.
+	 */
+	unsigned long start_pfn, end_pfn;
+	int i;
+
+	for (i = 0; i < MAX_NUMNODES; i++) {
+		get_pfn_range_for_nid(i, &start_pfn, &end_pfn);
+		if (start < PFN_PHYS(start_pfn) || start >= PFN_PHYS(end_pfn))
+			continue;
+		*nid = i;
+		return min(end, PFN_PHYS(end_pfn));
+	}
+#endif
 	*nid = 0;
 
 	return end;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
