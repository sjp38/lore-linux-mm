Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 33DFD6B0254
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:06:53 -0500 (EST)
Received: by wmww144 with SMTP id w144so95194358wmw.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:06:52 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id it3si17858768wjb.195.2015.11.23.01.06.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 01:06:52 -0800 (PST)
Received: by wmvv187 with SMTP id v187so150194647wmv.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:06:51 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v3 01/13] mm/memblock: add MEMBLOCK_NOMAP attribute to memblock memory table
Date: Mon, 23 Nov 2015 10:06:21 +0100
Message-Id: <1448269593-20758-2-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, matt@codeblueprint.co.uk
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

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
index 24daf8fc4d7c..fec66f86eeff 100644
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
@@ -184,6 +186,11 @@ static inline bool memblock_is_mirror(struct memblock_region *m)
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
@@ -319,6 +326,7 @@ phys_addr_t memblock_start_of_DRAM(void);
 phys_addr_t memblock_end_of_DRAM(void);
 void memblock_enforce_memory_limit(phys_addr_t memory_limit);
 int memblock_is_memory(phys_addr_t addr);
+int memblock_is_map_memory(phys_addr_t addr);
 int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
 int memblock_is_reserved(phys_addr_t addr);
 bool memblock_is_region_reserved(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index d300f1329814..07ff069fef25 100644
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
