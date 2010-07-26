Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 576DB6006BA
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 11:47:03 -0400 (EDT)
Received: by pvc30 with SMTP id 30so127579pvc.14
        for <linux-mm@kvack.org>; Mon, 26 Jul 2010 08:47:01 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] Tight check of pfn_valid on sparsemem - v4
Date: Tue, 27 Jul 2010 00:46:03 +0900
Message-Id: <1280159163-23386-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>
Cc: Kukjin Kim <kgene.kim@samsung.com>, LKML <linux-kernel@vger.kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Changelog since v3
 o fix my totally mistake in v3
 o use set_page_private and page_private

Changelog since v2
 o Change some function names
 o Remove mark_memmap_hole in memmap bring up
 o Change CONFIG_SPARSEMEM with CONFIG_ARCH_HAS_HOLES_MEMORYMODEL

I have a plan following as after this patch is acked.

TODO:
1) expand pfn_valid to FALTMEM in ARM
I think we can enhance pfn_valid of FLATMEM in ARM.
Now it is doing binary search and it's expesive.
First of all, After we merge this patch, I expand it to FALTMEM of ARM.

2) remove memmap_valid_within
We can remove memmap_valid_within by strict pfn_valid's tight check.

3) Optimize hole check in sparsemem
In case of spasemem, we can optimize pfn_valid through defining new flag
like SECTION_HAS_HOLE of hole mem_section.

== CUT HERE ==

Kukjin reported oops happen while he change min_free_kbytes
http://www.spinics.net/lists/arm-kernel/msg92894.html
It happen by memory map on sparsemem.

The system has a memory map following as.
     section 0             section 1              section 2
0x20000000-0x25000000, 0x40000000-0x50000000, 0x50000000-0x58000000
SECTION_SIZE_BITS 28(256M)

It means section 0 is an incompletely filled section.
Nontheless, current pfn_valid of sparsemem checks pfn loosely.
It checks only mem_section's validation but ARM can free mem_map on hole
to save memory space. So in above case, pfn on 0x25000000 can pass pfn_valid's
validation check. It's not what we want.

We can match section size to smallest valid size.(ex, above case, 16M)
But Russell doesn't like it due to mem_section's memory overhead with different
configuration(ex, 512K section).

I tried to add valid pfn range in mem_section but everyone doesn't like it
due to size overhead. This patch is suggested by KAMEZAWA-san.
I just fixed compile error and change some naming.

This patch registers address of mem_section to memmap itself's page struct's
pg->private field. This means the page is used for memmap of the section.
Otherwise, the page is used for other purpose and memmap has a hole.

This patch is based on mmotm-2010-07-19

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reported-by: Kukjin Kim <kgene.kim@samsung.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/arm/mm/init.c     |    9 +++++++++
 include/linux/mmzone.h |   21 ++++++++++++++++++++-
 mm/mmzone.c            |   33 +++++++++++++++++++++++++++++++++
 3 files changed, 62 insertions(+), 1 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index bc98d5d..18b255d 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -238,6 +238,15 @@ static void __init arm_bootmem_free(struct meminfo *mi, unsigned long min,
 	arch_adjust_zones(zone_size, zhole_size);
 
 	free_area_init_node(0, zone_size, min, zhole_size);
+
+	/*
+	 * mark pages on mem_map with valid using pg->private.
+	 * mem_map on hole will be freed free_memmap later.
+	 */
+	for_each_bank(i, mi) {
+		mark_valid_memmap(bank_pfn_start(&mi->bank[i]),
+					bank_pfn_end(&mi->bank[i]));
+	}
 }
 
 #ifndef CONFIG_SPARSEMEM
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6e6e626..3b4d16f 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -15,6 +15,7 @@
 #include <linux/seqlock.h>
 #include <linux/nodemask.h>
 #include <linux/pageblock-flags.h>
+#include <linux/mm_types.h>
 #include <generated/bounds.h>
 #include <asm/atomic.h>
 #include <asm/page.h>
@@ -1032,11 +1033,29 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
 	return __nr_to_section(pfn_to_section_nr(pfn));
 }
 
+void mark_valid_memmap(unsigned long start, unsigned long end);
+
+#ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
+static inline int memmap_valid(unsigned long pfn)
+{
+	struct page *page = pfn_to_page(pfn);
+	struct page *__pg = virt_to_page(page);
+	return page_private(__pg) == (unsigned long)__pg;
+}
+#else
+static inline int memmap_valid(unsigned long pfn)
+{
+	return 1;
+}
+#endif
+
 static inline int pfn_valid(unsigned long pfn)
 {
+	struct mem_section *ms;
 	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
 		return 0;
-	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
+	ms = __nr_to_section(pfn_to_section_nr(pfn));
+	return valid_section(ms) && memmap_valid(pfn);
 }
 
 static inline int pfn_present(unsigned long pfn)
diff --git a/mm/mmzone.c b/mm/mmzone.c
index f5b7d17..8c3cf57 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -86,4 +86,37 @@ int memmap_valid_within(unsigned long pfn,
 
 	return 1;
 }
+
+/*
+ * Fill pg->private on valid mem_map with page itself.
+ * pfn_valid() will check this later. (see include/linux/mmzone.h)
+ * Every arch for supporting hole of mem_map should call
+ * mark_valid_memmap(start, end). please see usage in ARM.
+ */
+void mark_valid_memmap(unsigned long start, unsigned long end)
+{
+	struct mem_section *ms;
+	unsigned long pos, next;
+	struct page *pg;
+	void *memmap, *mapend;
+
+	for (pos = start; pos < end; pos = next) {
+		next = (pos + PAGES_PER_SECTION) & PAGE_SECTION_MASK;
+		ms = __pfn_to_section(pos);
+		if (!valid_section(ms))
+			continue;
+
+		for (memmap = (void*)pfn_to_page(pos),
+			/* The last page in section */
+			mapend = pfn_to_page(next-1);
+			memmap < mapend; memmap += PAGE_SIZE) {
+			pg = virt_to_page(memmap);
+			set_page_private(pg, (unsigned long)pg);
+		}
+	}
+}
+#else
+void mark_valid_memmap(unsigned long start, unsigned long end)
+{
+}
 #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
