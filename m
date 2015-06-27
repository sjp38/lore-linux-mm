Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id BD6706B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 22:30:22 -0400 (EDT)
Received: by obbkm3 with SMTP id km3so77262408obb.1
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 19:30:22 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id wx3si23584839oeb.11.2015.06.26.19.30.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 19:30:21 -0700 (PDT)
Message-ID: <558E09A1.2090102@huawei.com>
Date: Sat, 27 Jun 2015 10:25:37 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC v2 PATCH 4/8] mm: add mirrored memory to buddy system
References: <558E084A.60900@huawei.com>
In-Reply-To: <558E084A.60900@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Before free bootmem, set mirrored pageblock's migratetype to MIGRATE_MIRROR, so
they could free to buddy system's MIGRATE_MIRROR list.
When set reserved memory, skip the mirrored memory.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 include/linux/memblock.h |  3 +++
 mm/memblock.c            | 21 +++++++++++++++++++++
 mm/nobootmem.c           |  3 +++
 mm/page_alloc.c          |  3 +++
 4 files changed, 30 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 97f71ca..53be030 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -81,6 +81,9 @@ int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
 ulong choose_memblock_flags(void);
+#ifdef CONFIG_MEMORY_MIRROR
+void memblock_mark_migratemirror(void);
+#endif
 
 /* Low level functions */
 int memblock_add_range(struct memblock_type *type,
diff --git a/mm/memblock.c b/mm/memblock.c
index 7612876..0d0b210 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -19,6 +19,7 @@
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
+#include <linux/page-isolation.h>
 
 #include <asm-generic/sections.h>
 #include <linux/io.h>
@@ -818,6 +819,26 @@ int __init_memblock memblock_mark_mirror(phys_addr_t base, phys_addr_t size)
 	return memblock_setclr_flag(base, size, 1, MEMBLOCK_MIRROR);
 }
 
+#ifdef CONFIG_MEMORY_MIRROR
+void __init_memblock memblock_mark_migratemirror(void)
+{
+	unsigned long start_pfn, end_pfn, pfn;
+	int i, node;
+	struct page *page;
+
+	printk(KERN_DEBUG "Mirrored memory:\n");
+	for_each_mirror_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn,
+				&node) {
+		printk(KERN_DEBUG "  node %3d: [mem %#010llx-%#010llx]\n",
+			node, PFN_PHYS(start_pfn), PFN_PHYS(end_pfn) - 1);
+		for (pfn = start_pfn; pfn < end_pfn;
+				pfn += pageblock_nr_pages) {
+			page = pfn_to_page(pfn);
+			set_pageblock_migratetype(page, MIGRATE_MIRROR);
+		}
+	}
+}
+#endif
 
 /**
  * __next__mem_range - next function for for_each_free_mem_range() etc.
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 5258386..31aa6d4 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -129,6 +129,9 @@ static unsigned long __init free_low_memory_core_early(void)
 	u64 i;
 
 	memblock_clear_hotplug(0, -1);
+#ifdef CONFIG_MEMORY_MIRROR
+	memblock_mark_migratemirror();
+#endif
 
 	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end,
 				NULL)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e4d79f..aea78a5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4118,6 +4118,9 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 
 		block_migratetype = get_pageblock_migratetype(page);
 
+		if (is_migrate_mirror(block_migratetype))
+			continue;
+
 		/* Only test what is necessary when the reserves are not met */
 		if (reserve > 0) {
 			/*
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
