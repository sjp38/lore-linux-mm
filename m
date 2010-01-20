Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F3C056B0071
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 17:53:25 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] bootmem: avoid DMA32 zone by default
Date: Wed, 20 Jan 2010 23:53:18 +0100
Message-Id: <1264027998-15257-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <20100120153000.GA13172@cmpxchg.org>
References: <20100120153000.GA13172@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, x86@kernel.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Bootmem already tries normal allocations above the DMA zone to reserve
it for users that can not cope with higher addresses.

The same principle applies to the DMA32 zone, which is currently not
spared from normal allocations.

This can lead to exhaustion of this limited amount of address space
through things that can easily live elsewhere, like the mem_map e.g.

Raise bootmem's default goal beyond DMA32 for architectures with this
zone defined.  For now, these are x86 and mips.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reported-by: Jiri Slaby <jslaby@suse.cz>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: x86@kernel.org
Cc: stable@kernel.org
---
 include/linux/bootmem.h |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

I cc'd stable because this affects already released kernels.  But since this is
the first report of DMA32 memory exhaustion through bootmem that I hear of,
you guys might want to skip this patch due to the fragile nature of early memory
management.

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index b10ec49..52c8272 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -96,20 +96,26 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 				      unsigned long align,
 				      unsigned long goal);
 
+#ifdef MAX_DMA32_PFN
+#define BOOTMEM_DEFAULT_GOAL	(MAX_DMA32_PFN << PAGE_SHIFT)
+#else
+#define BOOTMEM_DEFAULT_GOAL	__pa(MAX_DMA_ADDRESS)
+#endif
+
 #define alloc_bootmem(x) \
-	__alloc_bootmem(x, SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem(x, SMP_CACHE_BYTES, BOOTMEM_DEFAULT_GOAL)
 #define alloc_bootmem_nopanic(x) \
-	__alloc_bootmem_nopanic(x, SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_nopanic(x, SMP_CACHE_BYTES, BOOTMEM_DEFAULT_GOAL)
 #define alloc_bootmem_pages(x) \
-	__alloc_bootmem(x, PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem(x, PAGE_SIZE, BOOTMEM_DEFAULT_GOAL)
 #define alloc_bootmem_pages_nopanic(x) \
-	__alloc_bootmem_nopanic(x, PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_nopanic(x, PAGE_SIZE, BOOTMEM_DEFAULT_GOAL)
 #define alloc_bootmem_node(pgdat, x) \
-	__alloc_bootmem_node(pgdat, x, SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_node(pgdat, x, SMP_CACHE_BYTES, BOOTMEM_DEFAULT_GOAL)
 #define alloc_bootmem_pages_node(pgdat, x) \
-	__alloc_bootmem_node(pgdat, x, PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_node(pgdat, x, PAGE_SIZE, BOOTMEM_DEFAULT_GOAL)
 #define alloc_bootmem_pages_node_nopanic(pgdat, x) \
-	__alloc_bootmem_node_nopanic(pgdat, x, PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
+	__alloc_bootmem_node_nopanic(pgdat, x, PAGE_SIZE, BOOTMEM_DEFAULT_GOAL)
 
 #define alloc_bootmem_low(x) \
 	__alloc_bootmem_low(x, SMP_CACHE_BYTES, 0)
-- 
1.6.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
