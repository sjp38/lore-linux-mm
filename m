Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 02416600801
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 01:15:38 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id o765FZjM013800
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:35 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o765FZ1c606284
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:35 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o765FYC1021199
	for <linux-mm@kvack.org>; Fri, 6 Aug 2010 15:15:34 +1000
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 34/43] memblock: Separate memblock_alloc_nid() and memblock_alloc_try_nid()
Date: Fri,  6 Aug 2010 15:15:15 +1000
Message-Id: <1281071724-28740-35-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

The former is now strict, it will fail if it cannot honor the allocation
within the node, while the later implements the previous semantic which
falls back to allocating anywhere.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/sparc/mm/init_64.c  |    4 ++--
 include/linux/memblock.h |    6 +++++-
 mm/memblock.c            |   14 ++++++++++++++
 3 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 0883113..dc584d2 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -820,7 +820,7 @@ static void __init allocate_node_data(int nid)
 	struct pglist_data *p;
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
-	paddr = memblock_alloc_nid(sizeof(struct pglist_data), SMP_CACHE_BYTES, nid);
+	paddr = memblock_alloc_try_nid(sizeof(struct pglist_data), SMP_CACHE_BYTES, nid);
 	if (!paddr) {
 		prom_printf("Cannot allocate pglist_data for nid[%d]\n", nid);
 		prom_halt();
@@ -840,7 +840,7 @@ static void __init allocate_node_data(int nid)
 	if (p->node_spanned_pages) {
 		num_pages = bootmem_bootmap_pages(p->node_spanned_pages);
 
-		paddr = memblock_alloc_nid(num_pages << PAGE_SHIFT, PAGE_SIZE, nid);
+		paddr = memblock_alloc_try_nid(num_pages << PAGE_SHIFT, PAGE_SIZE, nid);
 		if (!paddr) {
 			prom_printf("Cannot allocate bootmap for nid[%d]\n",
 				  nid);
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 82b0302..c8da03e 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -50,7 +50,11 @@ extern long __init memblock_reserve(phys_addr_t base, phys_addr_t size);
 /* The numa aware allocator is only available if
  * CONFIG_ARCH_POPULATES_NODE_MAP is set
  */
-extern phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
+extern phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align,
+					int nid);
+extern phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align,
+					    int nid);
+
 extern phys_addr_t __init memblock_alloc(phys_addr_t size, phys_addr_t align);
 
 /* Flags for memblock_alloc_base() amd __memblock_alloc_base() */
diff --git a/mm/memblock.c b/mm/memblock.c
index af7e4d9..1802d97 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -537,9 +537,23 @@ phys_addr_t __init memblock_alloc_nid(phys_addr_t size, phys_addr_t align, int n
 			return ret;
 	}
 
+	return 0;
+}
+
+phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
+{
+	phys_addr_t res = memblock_alloc_nid(size, align, nid);
+
+	if (res)
+		return res;
 	return memblock_alloc(size, align);
 }
 
+
+/*
+ * Remaining API functions
+ */
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
