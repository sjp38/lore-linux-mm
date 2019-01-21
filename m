Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3878E0018
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:05:31 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id i124so13670300pgc.2
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 00:05:31 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 63si12282727pfv.38.2019.01.21.00.05.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 00:05:30 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0L83nOm132200
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:05:29 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q59werxuq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 03:05:29 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 21 Jan 2019 08:05:26 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 10/21] memblock: refactor internal allocation functions
Date: Mon, 21 Jan 2019 10:03:57 +0200
In-Reply-To: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1548057848-15136-11-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport <rppt@linux.ibm.com>

Currently, memblock has several internal functions with overlapping
functionality. They all call memblock_find_in_range_node() to find free
memory and then reserve the allocated range and mark it with kmemleak.
However, there is difference in the allocation constraints and in fallback
strategies.

The allocations returning physical address first attempt to find free
memory on the specified node within mirrored memory regions, then retry on
the same node without the requirement for memory mirroring and finally fall
back to all available memory.

The allocations returning virtual address start with clamping the allowed
range to memblock.current_limit, attempt to allocate from the specified
node from regions with mirroring and with user defined minimal address. If
such allocation fails, next attempt is done with node restriction lifted.
Next, the allocation is retried with minimal address reset to zero and at
last without the requirement for mirrored regions.

Let's consolidate various fallbacks handling and make them more consistent
for physical and virtual variants. Most of the fallback handling is moved
to memblock_alloc_range_nid() and it now handles node and mirror fallbacks.

The memblock_alloc_internal() uses memblock_alloc_range_nid() to get a
physical address of the allocated range and converts it to virtual address.

The fallback for allocation below the specified minimal address remains in
memblock_alloc_internal() because memblock_alloc_range_nid() is used by CMA
with exact requirement for lower bounds.

The memblock_phys_alloc_nid() function is completely dropped as it is not
used anywhere outside memblock and its only usage can be replaced by a call
to memblock_alloc_range_nid().

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 include/linux/memblock.h |   1 -
 mm/memblock.c            | 173 +++++++++++++++++++++--------------------------
 2 files changed, 78 insertions(+), 96 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 6874fdc..cf4cd9c 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -371,7 +371,6 @@ static inline int memblock_get_region_node(const struct memblock_region *r)
 
 phys_addr_t memblock_phys_alloc_range(phys_addr_t size, phys_addr_t align,
 				      phys_addr_t start, phys_addr_t end);
-phys_addr_t memblock_phys_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
 phys_addr_t memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid);
 
 static inline phys_addr_t memblock_phys_alloc(phys_addr_t size,
diff --git a/mm/memblock.c b/mm/memblock.c
index 531fa77..739f769 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1312,30 +1312,84 @@ __next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
 
 #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
+/**
+ * memblock_alloc_range_nid - allocate boot memory block
+ * @size: size of memory block to be allocated in bytes
+ * @align: alignment of the region and block's size
+ * @start: the lower bound of the memory region to allocate (phys address)
+ * @end: the upper bound of the memory region to allocate (phys address)
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
+ *
+ * The allocation is performed from memory region limited by
+ * memblock.current_limit if @max_addr == %MEMBLOCK_ALLOC_ACCESSIBLE.
+ *
+ * If the specified node can not hold the requested memory the
+ * allocation falls back to any node in the system
+ *
+ * For systems with memory mirroring, the allocation is attempted first
+ * from the regions with mirroring enabled and then retried from any
+ * memory region.
+ *
+ * In addition, function sets the min_count to 0 using kmemleak_alloc_phys for
+ * allocated boot memory block, so that it is never reported as leaks.
+ *
+ * Return:
+ * Physical address of allocated memory block on success, %0 on failure.
+ */
 static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
 					phys_addr_t align, phys_addr_t start,
-					phys_addr_t end, int nid,
-					enum memblock_flags flags)
+					phys_addr_t end, int nid)
 {
+	enum memblock_flags flags = choose_memblock_flags();
 	phys_addr_t found;
 
+	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
+		nid = NUMA_NO_NODE;
+
 	if (!align) {
 		/* Can't use WARNs this early in boot on powerpc */
 		dump_stack();
 		align = SMP_CACHE_BYTES;
 	}
 
+	if (end > memblock.current_limit)
+		end = memblock.current_limit;
+
+again:
 	found = memblock_find_in_range_node(size, align, start, end, nid,
 					    flags);
-	if (found && !memblock_reserve(found, size)) {
+	if (found && !memblock_reserve(found, size))
+		goto done;
+
+	if (nid != NUMA_NO_NODE) {
+		found = memblock_find_in_range_node(size, align, start,
+						    end, NUMA_NO_NODE,
+						    flags);
+		if (found && !memblock_reserve(found, size))
+			goto done;
+	}
+
+	if (flags & MEMBLOCK_MIRROR) {
+		flags &= ~MEMBLOCK_MIRROR;
+		pr_warn("Could not allocate %pap bytes of mirrored memory\n",
+			&size);
+		goto again;
+	}
+
+	return 0;
+
+done:
+	/* Skip kmemleak for kasan_init() due to high volume. */
+	if (end != MEMBLOCK_ALLOC_KASAN)
 		/*
-		 * The min_count is set to 0 so that memblock allocations are
-		 * never reported as leaks.
+		 * The min_count is set to 0 so that memblock allocated
+		 * blocks are never reported as leaks. This is because many
+		 * of these blocks are only referred via the physical
+		 * address which is not looked up by kmemleak.
 		 */
 		kmemleak_alloc_phys(found, size, 0, 0);
-		return found;
-	}
-	return 0;
+
+	return found;
 }
 
 phys_addr_t __init memblock_phys_alloc_range(phys_addr_t size,
@@ -1343,35 +1397,13 @@ phys_addr_t __init memblock_phys_alloc_range(phys_addr_t size,
 					     phys_addr_t start,
 					     phys_addr_t end)
 {
-	return memblock_alloc_range_nid(size, align, start, end, NUMA_NO_NODE,
-					MEMBLOCK_NONE);
-}
-
-phys_addr_t __init memblock_phys_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
-{
-	enum memblock_flags flags = choose_memblock_flags();
-	phys_addr_t ret;
-
-again:
-	ret = memblock_alloc_range_nid(size, align, 0,
-				       MEMBLOCK_ALLOC_ACCESSIBLE, nid, flags);
-
-	if (!ret && (flags & MEMBLOCK_MIRROR)) {
-		flags &= ~MEMBLOCK_MIRROR;
-		goto again;
-	}
-	return ret;
+	return memblock_alloc_range_nid(size, align, start, end, NUMA_NO_NODE);
 }
 
 phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
-	phys_addr_t res = memblock_phys_alloc_nid(size, align, nid);
-
-	if (res)
-		return res;
-	return memblock_alloc_range_nid(size, align, 0,
-					MEMBLOCK_ALLOC_ACCESSIBLE,
-					NUMA_NO_NODE, MEMBLOCK_NONE);
+	return memblock_alloc_range_nid(size, align, 0, nid,
+					MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
 /**
@@ -1382,19 +1414,13 @@ phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t ali
  * @max_addr: the upper bound of the memory region to allocate (phys address)
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
- * The @min_addr limit is dropped if it can not be satisfied and the allocation
- * will fall back to memory below @min_addr. Also, allocation may fall back
- * to any node in the system if the specified node can not
- * hold the requested memory.
- *
- * The allocation is performed from memory region limited by
- * memblock.current_limit if @max_addr == %MEMBLOCK_ALLOC_ACCESSIBLE.
- *
- * The phys address of allocated boot memory block is converted to virtual and
- * allocated memory is reset to 0.
+ * Allocates memory block using memblock_alloc_range_nid() and
+ * converts the returned physical address to virtual.
  *
- * In addition, function sets the min_count to 0 using kmemleak_alloc for
- * allocated boot memory block, so that it is never reported as leaks.
+ * The @min_addr limit is dropped if it can not be satisfied and the allocation
+ * will fall back to memory below @min_addr. Other constraints, such
+ * as node and mirrored memory will be handled again in
+ * memblock_alloc_range_nid().
  *
  * Return:
  * Virtual address of allocated memory block on success, NULL on failure.
@@ -1405,11 +1431,6 @@ static void * __init memblock_alloc_internal(
 				int nid)
 {
 	phys_addr_t alloc;
-	void *ptr;
-	enum memblock_flags flags = choose_memblock_flags();
-
-	if (WARN_ONCE(nid == MAX_NUMNODES, "Usage of MAX_NUMNODES is deprecated. Use NUMA_NO_NODE instead\n"))
-		nid = NUMA_NO_NODE;
 
 	/*
 	 * Detect any accidental use of these APIs after slab is ready, as at
@@ -1419,54 +1440,16 @@ static void * __init memblock_alloc_internal(
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, nid);
 
-	if (!align) {
-		dump_stack();
-		align = SMP_CACHE_BYTES;
-	}
-
-	if (max_addr > memblock.current_limit)
-		max_addr = memblock.current_limit;
-again:
-	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
-					    nid, flags);
-	if (alloc && !memblock_reserve(alloc, size))
-		goto done;
-
-	if (nid != NUMA_NO_NODE) {
-		alloc = memblock_find_in_range_node(size, align, min_addr,
-						    max_addr, NUMA_NO_NODE,
-						    flags);
-		if (alloc && !memblock_reserve(alloc, size))
-			goto done;
-	}
-
-	if (min_addr) {
-		min_addr = 0;
-		goto again;
-	}
-
-	if (flags & MEMBLOCK_MIRROR) {
-		flags &= ~MEMBLOCK_MIRROR;
-		pr_warn("Could not allocate %pap bytes of mirrored memory\n",
-			&size);
-		goto again;
-	}
+	alloc = memblock_alloc_range_nid(size, align, min_addr, max_addr, nid);
 
-	return NULL;
-done:
-	ptr = phys_to_virt(alloc);
+	/* retry allocation without lower limit */
+	if (!alloc && min_addr)
+		alloc = memblock_alloc_range_nid(size, align, 0, max_addr, nid);
 
-	/* Skip kmemleak for kasan_init() due to high volume. */
-	if (max_addr != MEMBLOCK_ALLOC_KASAN)
-		/*
-		 * The min_count is set to 0 so that bootmem allocated
-		 * blocks are never reported as leaks. This is because many
-		 * of these blocks are only referred via the physical
-		 * address which is not looked up by kmemleak.
-		 */
-		kmemleak_alloc(ptr, size, 0, 0);
+	if (!alloc)
+		return NULL;
 
-	return ptr;
+	return phys_to_virt(alloc);
 }
 
 /**
-- 
2.7.4
