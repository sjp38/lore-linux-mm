Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B22DC6B73EE
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 12:01:06 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w185-v6so9133118oig.19
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:01:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r135-v6si1500024oie.100.2018.09.05.09.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 09:01:04 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85FuTkd043241
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 12:01:03 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mahf5apkt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:00:55 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 17:00:53 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 22/29] mm: nobootmem: remove bootmem allocation APIs
Date: Wed,  5 Sep 2018 18:59:37 +0300
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536163184-26356-23-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The bootmem compatibility APIs are not used and can be removed.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/bootmem.h |  47 ----------
 mm/nobootmem.c          | 224 ------------------------------------------------
 2 files changed, 271 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index c97c105..73f1272 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -36,33 +36,6 @@ extern void free_bootmem_node(pg_data_t *pgdat,
 extern void free_bootmem(unsigned long physaddr, unsigned long size);
 extern void free_bootmem_late(unsigned long physaddr, unsigned long size);
 
-extern void *__alloc_bootmem(unsigned long size,
-			     unsigned long align,
-			     unsigned long goal);
-extern void *__alloc_bootmem_nopanic(unsigned long size,
-				     unsigned long align,
-				     unsigned long goal) __malloc;
-extern void *__alloc_bootmem_node(pg_data_t *pgdat,
-				  unsigned long size,
-				  unsigned long align,
-				  unsigned long goal) __malloc;
-void *__alloc_bootmem_node_high(pg_data_t *pgdat,
-				  unsigned long size,
-				  unsigned long align,
-				  unsigned long goal) __malloc;
-extern void *__alloc_bootmem_node_nopanic(pg_data_t *pgdat,
-				  unsigned long size,
-				  unsigned long align,
-				  unsigned long goal) __malloc;
-void *___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
-				  unsigned long size,
-				  unsigned long align,
-				  unsigned long goal,
-				  unsigned long limit) __malloc;
-extern void *__alloc_bootmem_low(unsigned long size,
-				 unsigned long align,
-				 unsigned long goal) __malloc;
-
 /* We are using top down, so it is safe to use 0 here */
 #define BOOTMEM_LOW_LIMIT 0
 
@@ -70,26 +43,6 @@ extern void *__alloc_bootmem_low(unsigned long size,
 #define ARCH_LOW_ADDRESS_LIMIT  0xffffffffUL
 #endif
 
-#define alloc_bootmem(x) \
-	__alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
-#define alloc_bootmem_align(x, align) \
-	__alloc_bootmem(x, align, BOOTMEM_LOW_LIMIT)
-#define alloc_bootmem_pages(x) \
-	__alloc_bootmem(x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
-#define alloc_bootmem_pages_nopanic(x) \
-	__alloc_bootmem_nopanic(x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
-#define alloc_bootmem_node(pgdat, x) \
-	__alloc_bootmem_node(pgdat, x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
-#define alloc_bootmem_node_nopanic(pgdat, x) \
-	__alloc_bootmem_node_nopanic(pgdat, x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT)
-#define alloc_bootmem_pages_node(pgdat, x) \
-	__alloc_bootmem_node(pgdat, x, PAGE_SIZE, BOOTMEM_LOW_LIMIT)
-
-#define alloc_bootmem_low(x) \
-	__alloc_bootmem_low(x, SMP_CACHE_BYTES, 0)
-#define alloc_bootmem_low_pages(x) \
-	__alloc_bootmem_low(x, PAGE_SIZE, 0)
-
 /* FIXME: use MEMBLOCK_ALLOC_* variants here */
 #define BOOTMEM_ALLOC_ACCESSIBLE	0
 #define BOOTMEM_ALLOC_ANYWHERE		(~(phys_addr_t)0)
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 44ce7de..bc38e56 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -33,41 +33,6 @@ unsigned long min_low_pfn;
 unsigned long max_pfn;
 unsigned long long max_possible_pfn;
 
-static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
-					u64 goal, u64 limit)
-{
-	void *ptr;
-	u64 addr;
-	enum memblock_flags flags = choose_memblock_flags();
-
-	if (limit > memblock.current_limit)
-		limit = memblock.current_limit;
-
-again:
-	addr = memblock_find_in_range_node(size, align, goal, limit, nid,
-					   flags);
-	if (!addr && (flags & MEMBLOCK_MIRROR)) {
-		flags &= ~MEMBLOCK_MIRROR;
-		pr_warn("Could not allocate %pap bytes of mirrored memory\n",
-			&size);
-		goto again;
-	}
-	if (!addr)
-		return NULL;
-
-	if (memblock_reserve(addr, size))
-		return NULL;
-
-	ptr = phys_to_virt(addr);
-	memset(ptr, 0, size);
-	/*
-	 * The min_count is set to 0 so that bootmem allocated blocks
-	 * are never reported as leaks.
-	 */
-	kmemleak_alloc(ptr, size, 0, 0);
-	return ptr;
-}
-
 /**
  * free_bootmem_late - free bootmem pages directly to page allocator
  * @addr: starting address of the range
@@ -215,192 +180,3 @@ void __init free_bootmem(unsigned long addr, unsigned long size)
 {
 	memblock_free(addr, size);
 }
-
-static void * __init ___alloc_bootmem_nopanic(unsigned long size,
-					unsigned long align,
-					unsigned long goal,
-					unsigned long limit)
-{
-	void *ptr;
-
-	if (WARN_ON_ONCE(slab_is_available()))
-		return kzalloc(size, GFP_NOWAIT);
-
-restart:
-
-	ptr = __alloc_memory_core_early(NUMA_NO_NODE, size, align, goal, limit);
-
-	if (ptr)
-		return ptr;
-
-	if (goal != 0) {
-		goal = 0;
-		goto restart;
-	}
-
-	return NULL;
-}
-
-/**
- * __alloc_bootmem_nopanic - allocate boot memory without panicking
- * @size: size of the request in bytes
- * @align: alignment of the region
- * @goal: preferred starting address of the region
- *
- * The goal is dropped if it can not be satisfied and the allocation will
- * fall back to memory below @goal.
- *
- * Allocation may happen on any node in the system.
- *
- * Return: address of the allocated region or %NULL on failure.
- */
-void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
-					unsigned long goal)
-{
-	unsigned long limit = -1UL;
-
-	return ___alloc_bootmem_nopanic(size, align, goal, limit);
-}
-
-static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
-					unsigned long goal, unsigned long limit)
-{
-	void *mem = ___alloc_bootmem_nopanic(size, align, goal, limit);
-
-	if (mem)
-		return mem;
-	/*
-	 * Whoops, we cannot satisfy the allocation request.
-	 */
-	pr_alert("bootmem alloc of %lu bytes failed!\n", size);
-	panic("Out of memory");
-	return NULL;
-}
-
-/**
- * __alloc_bootmem - allocate boot memory
- * @size: size of the request in bytes
- * @align: alignment of the region
- * @goal: preferred starting address of the region
- *
- * The goal is dropped if it can not be satisfied and the allocation will
- * fall back to memory below @goal.
- *
- * Allocation may happen on any node in the system.
- *
- * The function panics if the request can not be satisfied.
- *
- * Return: address of the allocated region.
- */
-void * __init __alloc_bootmem(unsigned long size, unsigned long align,
-			      unsigned long goal)
-{
-	unsigned long limit = -1UL;
-
-	return ___alloc_bootmem(size, align, goal, limit);
-}
-
-void * __init ___alloc_bootmem_node_nopanic(pg_data_t *pgdat,
-						   unsigned long size,
-						   unsigned long align,
-						   unsigned long goal,
-						   unsigned long limit)
-{
-	void *ptr;
-
-again:
-	ptr = __alloc_memory_core_early(pgdat->node_id, size, align,
-					goal, limit);
-	if (ptr)
-		return ptr;
-
-	ptr = __alloc_memory_core_early(NUMA_NO_NODE, size, align,
-					goal, limit);
-	if (ptr)
-		return ptr;
-
-	if (goal) {
-		goal = 0;
-		goto again;
-	}
-
-	return NULL;
-}
-
-void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
-				   unsigned long align, unsigned long goal)
-{
-	if (WARN_ON_ONCE(slab_is_available()))
-		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
-
-	return ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, 0);
-}
-
-static void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
-				    unsigned long align, unsigned long goal,
-				    unsigned long limit)
-{
-	void *ptr;
-
-	ptr = ___alloc_bootmem_node_nopanic(pgdat, size, align, goal, limit);
-	if (ptr)
-		return ptr;
-
-	pr_alert("bootmem alloc of %lu bytes failed!\n", size);
-	panic("Out of memory");
-	return NULL;
-}
-
-/**
- * __alloc_bootmem_node - allocate boot memory from a specific node
- * @pgdat: node to allocate from
- * @size: size of the request in bytes
- * @align: alignment of the region
- * @goal: preferred starting address of the region
- *
- * The goal is dropped if it can not be satisfied and the allocation will
- * fall back to memory below @goal.
- *
- * Allocation may fall back to any node in the system if the specified node
- * can not hold the requested memory.
- *
- * The function panics if the request can not be satisfied.
- *
- * Return: address of the allocated region.
- */
-void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
-				   unsigned long align, unsigned long goal)
-{
-	if (WARN_ON_ONCE(slab_is_available()))
-		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
-
-	return ___alloc_bootmem_node(pgdat, size, align, goal, 0);
-}
-
-void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
-				   unsigned long align, unsigned long goal)
-{
-	return __alloc_bootmem_node(pgdat, size, align, goal);
-}
-
-
-/**
- * __alloc_bootmem_low - allocate low boot memory
- * @size: size of the request in bytes
- * @align: alignment of the region
- * @goal: preferred starting address of the region
- *
- * The goal is dropped if it can not be satisfied and the allocation will
- * fall back to memory below @goal.
- *
- * Allocation may happen on any node in the system.
- *
- * The function panics if the request can not be satisfied.
- *
- * Return: address of the allocated region.
- */
-void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
-				  unsigned long goal)
-{
-	return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT);
-}
-- 
2.7.4
