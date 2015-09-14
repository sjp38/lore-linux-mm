Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 158666B0254
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 11:55:40 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so139186176wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:55:39 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id q2si18064369wie.9.2015.09.14.08.55.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 08:55:39 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so148962359wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:55:38 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH 1/3] mm/memblock: add MEMBLOCK_NOMAP attribute to memblock memory table
Date: Mon, 14 Sep 2015 17:55:27 +0200
Message-Id: <1442246129-13930-2-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1442246129-13930-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1442246129-13930-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, catalin.marinas@arm.com, will.deacon@arm.com, leif.lindholm@linaro.org, mark.rutland@arm.com, msalter@redhat.com, akpm@linux-foundation.org
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>

This introduces the MEMBLOCK_NOMAP attribute and the required plumbing
to make it usable as an indicator that some parts of normal memory
should not be covered by the kernel direct mapping. It is up to the
arch to actually honor the attribute when laying out this mapping,
but the memblock code itself is modified to disregard these regions
for allocations and other general use.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 include/linux/memblock.h |  8 ++++++
 mm/memblock.c            | 28 ++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index c518eb589260..fdd6ac55c281 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -25,6 +25,7 @@ enum {
 	MEMBLOCK_NONE		= 0x0,	/* No special request */
 	MEMBLOCK_HOTPLUG	= 0x1,	/* hotpluggable region */
 	MEMBLOCK_MIRROR		= 0x2,	/* mirrored region */
+	MEMBLOCK_NOMAP		= 0x4,	/* don't add to kernel direct mapping */
 };
 
 struct memblock_region {
@@ -82,6 +83,7 @@ bool memblock_overlaps_region(struct memblock_type *type,
 int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
+int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
 ulong choose_memblock_flags(void);
 
 /* Low level functions */
@@ -188,6 +190,11 @@ static inline bool memblock_is_mirror(struct memblock_region *m)
 	return m->flags & MEMBLOCK_MIRROR;
 }
 
+static inline bool memblock_is_nomap(struct memblock_region *m)
+{
+	return m->flags & MEMBLOCK_NOMAP;
+}
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
 			    unsigned long  *end_pfn);
@@ -323,6 +330,7 @@ phys_addr_t memblock_start_of_DRAM(void);
 phys_addr_t memblock_end_of_DRAM(void);
 void memblock_enforce_memory_limit(phys_addr_t memory_limit);
 int memblock_is_memory(phys_addr_t addr);
+int memblock_is_map_memory(phys_addr_t addr);
 int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
 int memblock_is_reserved(phys_addr_t addr);
 bool memblock_is_region_reserved(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index 1c7b647e5897..bf2c8cfbc520 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -822,6 +822,17 @@ int __init_memblock memblock_mark_mirror(phys_addr_t base, phys_addr_t size)
 	return memblock_setclr_flag(base, size, 1, MEMBLOCK_MIRROR);
 }
 
+/**
+ * memblock_mark_nomap - Mark a memory region with flag MEMBLOCK_NOMAP.
+ * @base: the base phys addr of the region
+ * @size: the size of the region
+ *
+ * Return 0 on success, -errno on failure.
+ */
+int __init_memblock memblock_mark_nomap(phys_addr_t base, phys_addr_t size)
+{
+	return memblock_setclr_flag(base, size, 1, MEMBLOCK_NOMAP);
+}
 
 /**
  * __next_reserved_mem_region - next function for for_each_reserved_region()
@@ -913,6 +924,10 @@ void __init_memblock __next_mem_range(u64 *idx, int nid, ulong flags,
 		if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
 			continue;
 
+		/* skip nomap memory unless we were asked for it explicitly */
+		if (!(flags & MEMBLOCK_NOMAP) && memblock_is_nomap(m))
+			continue;
+
 		if (!type_b) {
 			if (out_start)
 				*out_start = m_start;
@@ -1022,6 +1037,10 @@ void __init_memblock __next_mem_range_rev(u64 *idx, int nid, ulong flags,
 		if ((flags & MEMBLOCK_MIRROR) && !memblock_is_mirror(m))
 			continue;
 
+		/* skip nomap memory unless we were asked for it explicitly */
+		if (!(flags & MEMBLOCK_NOMAP) && memblock_is_nomap(m))
+			continue;
+
 		if (!type_b) {
 			if (out_start)
 				*out_start = m_start;
@@ -1519,6 +1538,15 @@ int __init_memblock memblock_is_memory(phys_addr_t addr)
 	return memblock_search(&memblock.memory, addr) != -1;
 }
 
+int __init_memblock memblock_is_map_memory(phys_addr_t addr)
+{
+	int i = memblock_search(&memblock.memory, addr);
+
+	if (i == -1)
+		return false;
+	return !memblock_is_nomap(&memblock.memory.regions[i]);
+}
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int __init_memblock memblock_search_pfn_nid(unsigned long pfn,
 			 unsigned long *start_pfn, unsigned long *end_pfn)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
