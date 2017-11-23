Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACDAE6B027B
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:14:51 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 107so11646514wra.7
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 03:14:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h7si3260916edj.339.2017.11.23.03.14.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 03:14:50 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vANBEgtk006623
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:14:49 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2edufv0j8b-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:14:48 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ar@linux.vnet.ibm.com>;
	Thu, 23 Nov 2017 11:14:45 -0000
Date: Thu, 23 Nov 2017 11:14:38 +0000
From: Andrea Reale <ar@linux.vnet.ibm.com>
Subject: [PATCH v2 3/5] mm: memory_hotplug: memblock to track partially
 removed vmemmap mem
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <cover.1511433386.git.ar@linux.vnet.ibm.com>
Message-Id: <e17d447381b3f13d4d7d314916ca273b6f60d287.1511433386.git.ar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, m.bielski@virtualopensystems.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, mhocko@suse.com, realean2@ie.ibm.com

When hot-removing memory we need to free vmemmap memory.
However, depending on the memory is being removed, it might
not be always possible to free a full vmemmap page / huge-page
because part of it might still be used.

Commit ae9aae9eda2d ("memory-hotplug: common APIs to support page tables
hot-remove") introduced a workaround for x86
hot-remove, by which partially unused areas are filled with
the 0xFD constant. Full pages are only removed when fully
filled by 0xFDs.

This commit introduces a MEMBLOCK_UNUSED_VMEMMAP memblock flag, with
the goal of using it in place of 0xFDs. For now, this will be used for
the arm64 port of memory hot remove, but the idea is to eventually use
the same mechanism for x86 as well.

Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
Signed-off-by: Maciej Bielski <m.bielski@virtualopensystems.com>
---
 include/linux/memblock.h | 12 ++++++++++++
 mm/memblock.c            | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index bae11c7..0daec05 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -26,6 +26,9 @@ enum {
 	MEMBLOCK_HOTPLUG	= 0x1,	/* hotpluggable region */
 	MEMBLOCK_MIRROR		= 0x2,	/* mirrored region */
 	MEMBLOCK_NOMAP		= 0x4,	/* don't add to kernel direct mapping */
+#ifdef CONFIG_MEMORY_HOTREMOVE
+	MEMBLOCK_UNUSED_VMEMMAP	= 0x8,  /* Mark VMEMAP blocks as dirty */
+#endif
 };
 
 struct memblock_region {
@@ -90,6 +93,10 @@ int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
 int memblock_mark_nomap(phys_addr_t base, phys_addr_t size);
 int memblock_clear_nomap(phys_addr_t base, phys_addr_t size);
 ulong choose_memblock_flags(void);
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int memblock_mark_unused_vmemmap(phys_addr_t base, phys_addr_t size);
+int memblock_clear_unused_vmemmap(phys_addr_t base, phys_addr_t size);
+#endif
 
 /* Low level functions */
 int memblock_add_range(struct memblock_type *type,
@@ -182,6 +189,11 @@ static inline bool memblock_is_nomap(struct memblock_region *m)
 	return m->flags & MEMBLOCK_NOMAP;
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+bool memblock_is_vmemmap_unused_range(struct memblock_type *mt,
+		phys_addr_t start, phys_addr_t end);
+#endif
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
 			    unsigned long  *end_pfn);
diff --git a/mm/memblock.c b/mm/memblock.c
index 9120578..30d5aa4 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -809,6 +809,18 @@ int __init_memblock memblock_clear_nomap(phys_addr_t base, phys_addr_t size)
 	return memblock_setclr_flag(base, size, 0, MEMBLOCK_NOMAP);
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+int __init_memblock memblock_mark_unused_vmemmap(phys_addr_t base,
+		phys_addr_t size)
+{
+	return memblock_setclr_flag(base, size, 1, MEMBLOCK_UNUSED_VMEMMAP);
+}
+int __init_memblock memblock_clear_unused_vmemmap(phys_addr_t base,
+		phys_addr_t size)
+{
+	return memblock_setclr_flag(base, size, 0, MEMBLOCK_UNUSED_VMEMMAP);
+}
+#endif
 /**
  * __next_reserved_mem_region - next function for for_each_reserved_region()
  * @idx: pointer to u64 loop variable
@@ -1696,6 +1708,26 @@ void __init_memblock memblock_trim_memory(phys_addr_t align)
 	}
 }
 
+#ifdef CONFIG_MEMORY_HOTREMOVE
+bool __init_memblock memblock_is_vmemmap_unused_range(struct memblock_type *mt,
+		phys_addr_t start, phys_addr_t end)
+{
+	u64 i;
+	struct memblock_region *r;
+
+	i = memblock_search(mt, start);
+	r = &(mt->regions[i]);
+	while (r->base < end) {
+		if (!(r->flags & MEMBLOCK_UNUSED_VMEMMAP))
+			return 0;
+
+		r = &(memblock.memory.regions[++i]);
+	}
+
+	return 1;
+}
+#endif
+
 void __init_memblock memblock_set_current_limit(phys_addr_t limit)
 {
 	memblock.current_limit = limit;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
