Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BEBE66B005A
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 06:16:10 -0400 (EDT)
Subject: [RFC PATCH 2/3] kmemleak: Add callbacks to the bootmem allocator
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Mon, 06 Jul 2009 11:51:55 +0100
Message-ID: <20090706105155.16051.59597.stgit@pc1117.cambridge.arm.com>
In-Reply-To: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
References: <20090706104654.16051.44029.stgit@pc1117.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

This patch adds kmemleak_alloc/free callbacks to the bootmem allocator.
This would allow scanning of such blocks and help avoiding a whole class
of false positives and more kmemleak annotations.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
---
 mm/bootmem.c |   36 +++++++++++++++++++++++++++++-------
 1 files changed, 29 insertions(+), 7 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index d2a9ce9..18858ad 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -335,6 +335,8 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 {
 	unsigned long start, end;
 
+	kmemleak_free(__va(physaddr));
+
 	start = PFN_UP(physaddr);
 	end = PFN_DOWN(physaddr + size);
 
@@ -354,6 +356,8 @@ void __init free_bootmem(unsigned long addr, unsigned long size)
 {
 	unsigned long start, end;
 
+	kmemleak_free_part(__va(addr), size);
+
 	start = PFN_UP(addr);
 	end = PFN_DOWN(addr + size);
 
@@ -597,7 +601,9 @@ restart:
 void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
 					unsigned long goal)
 {
-	return ___alloc_bootmem_nopanic(size, align, goal, 0);
+	void *ptr =  ___alloc_bootmem_nopanic(size, align, goal, 0);
+	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
+	return ptr;
 }
 
 static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
@@ -631,7 +637,9 @@ static void * __init ___alloc_bootmem(unsigned long size, unsigned long align,
 void * __init __alloc_bootmem(unsigned long size, unsigned long align,
 			      unsigned long goal)
 {
-	return ___alloc_bootmem(size, align, goal, 0);
+	void *ptr = ___alloc_bootmem(size, align, goal, 0);
+	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
+	return ptr;
 }
 
 static void * __init ___alloc_bootmem_node(bootmem_data_t *bdata,
@@ -669,10 +677,14 @@ static void * __init ___alloc_bootmem_node(bootmem_data_t *bdata,
 void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
 				   unsigned long align, unsigned long goal)
 {
+	void *ptr;
+
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
-	return ___alloc_bootmem_node(pgdat->bdata, size, align, goal, 0);
+	ptr = ___alloc_bootmem_node(pgdat->bdata, size, align, goal, 0);
+	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
+	return ptr;
 }
 
 #ifdef CONFIG_SPARSEMEM
@@ -707,14 +719,18 @@ void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
 	ptr = alloc_arch_preferred_bootmem(pgdat->bdata, size, align, goal, 0);
+	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
 	if (ptr)
 		return ptr;
 
 	ptr = alloc_bootmem_core(pgdat->bdata, size, align, goal, 0);
+	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
 	if (ptr)
 		return ptr;
 
-	return __alloc_bootmem_nopanic(size, align, goal);
+	ptr = __alloc_bootmem_nopanic(size, align, goal);
+	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
+	return ptr;
 }
 
 #ifndef ARCH_LOW_ADDRESS_LIMIT
@@ -737,7 +753,9 @@ void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
 void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
 				  unsigned long goal)
 {
-	return ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT);
+	void *ptr =  ___alloc_bootmem(size, align, goal, ARCH_LOW_ADDRESS_LIMIT);
+	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
+	return ptr;
 }
 
 /**
@@ -758,9 +776,13 @@ void * __init __alloc_bootmem_low(unsigned long size, unsigned long align,
 void * __init __alloc_bootmem_low_node(pg_data_t *pgdat, unsigned long size,
 				       unsigned long align, unsigned long goal)
 {
+	void *ptr;
+
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
 
-	return ___alloc_bootmem_node(pgdat->bdata, size, align,
-				goal, ARCH_LOW_ADDRESS_LIMIT);
+	ptr = ___alloc_bootmem_node(pgdat->bdata, size, align,
+				    goal, ARCH_LOW_ADDRESS_LIMIT);
+	kmemleak_alloc(ptr, size, 1, GFP_KERNEL);
+	return ptr;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
