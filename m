Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D85EA6B02E1
	for <linux-mm@kvack.org>; Mon, 15 May 2017 05:00:32 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p29so107145230pgn.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 02:00:32 -0700 (PDT)
Received: from mail-pf0-f195.google.com (mail-pf0-f195.google.com. [209.85.192.195])
        by mx.google.com with ESMTPS id g192si10030087pgc.140.2017.05.15.02.00.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 02:00:31 -0700 (PDT)
Received: by mail-pf0-f195.google.com with SMTP id u26so15038701pfd.2
        for <linux-mm@kvack.org>; Mon, 15 May 2017 02:00:31 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 07/14] mm: consider zone which is not fully populated to have holes
Date: Mon, 15 May 2017 10:58:20 +0200
Message-Id: <20170515085827.16474-8-mhocko@kernel.org>
In-Reply-To: <20170515085827.16474-1-mhocko@kernel.org>
References: <20170515085827.16474-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__pageblock_pfn_to_page has two users currently, set_zone_contiguous
which checks whether the given zone contains holes and
pageblock_pfn_to_page which then carefully returns a first valid
page from the given pfn range for the given zone. This doesn't handle
zones which are not fully populated though. Memory pageblocks can be
offlined or might not have been onlined yet. In such a case the zone
should be considered to have holes otherwise pfn walkers can touch
and play with offline pages.

Current callers of pageblock_pfn_to_page in compaction seem to work
properly right now because they only isolate PageBuddy
(isolate_freepages_block) or PageLRU resp. __PageMovable
(isolate_migratepages_block) which will be always false for these pages.
It would be safer to skip these pages altogether, though.

In order to do this patch adds a new memory section state
(SECTION_IS_ONLINE) which is set in memory_present (during boot
time) or in online_pages_range during the memory hotplug. Similarly
offline_mem_sections clears the bit and it is called when the memory
range is offlined.

pfn_to_online_page helper is then added which check the mem section and
only returns a page if it is onlined already.

Use the new helper in __pageblock_pfn_to_page and skip the whole page
block in such a case.

Changes since v3
- clarify pfn_valid semantic - requested by Joonsoo

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/memory_hotplug.h | 21 ++++++++++++++++++++
 include/linux/mmzone.h         | 35 ++++++++++++++++++++++++++------
 mm/memory_hotplug.c            |  3 +++
 mm/page_alloc.c                |  5 ++++-
 mm/sparse.c                    | 45 +++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 101 insertions(+), 8 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 3c8cf86201c3..fc1c873504eb 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -14,6 +14,19 @@ struct memory_block;
 struct resource;
 
 #ifdef CONFIG_MEMORY_HOTPLUG
+/*
+ * Return page for the valid pfn only if the page is online. All pfn
+ * walkers which rely on the fully initialized page->flags and others
+ * should use this rather than pfn_valid && pfn_to_page
+ */
+#define pfn_to_online_page(pfn)				\
+({							\
+	struct page *___page = NULL;			\
+							\
+	if (online_section_nr(pfn_to_section_nr(pfn)))	\
+		___page = pfn_to_page(pfn);		\
+	___page;					\
+})
 
 /*
  * Types for free bootmem stored in page->lru.next. These have to be in
@@ -203,6 +216,14 @@ extern void set_zone_contiguous(struct zone *zone);
 extern void clear_zone_contiguous(struct zone *zone);
 
 #else /* ! CONFIG_MEMORY_HOTPLUG */
+#define pfn_to_online_page(pfn)			\
+({						\
+	struct page *___page = NULL;		\
+	if (pfn_valid(pfn))			\
+		___page = pfn_to_page(pfn);	\
+	___page;				\
+ })
+
 /*
  * Stub functions for when hotplug is off
  */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8363dd27b8af..927ad95a4552 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1143,9 +1143,10 @@ extern unsigned long usemap_size(void);
  */
 #define	SECTION_MARKED_PRESENT	(1UL<<0)
 #define SECTION_HAS_MEM_MAP	(1UL<<1)
-#define SECTION_MAP_LAST_BIT	(1UL<<2)
+#define SECTION_IS_ONLINE	(1UL<<2)
+#define SECTION_MAP_LAST_BIT	(1UL<<3)
 #define SECTION_MAP_MASK	(~(SECTION_MAP_LAST_BIT-1))
-#define SECTION_NID_SHIFT	2
+#define SECTION_NID_SHIFT	3
 
 static inline struct page *__section_mem_map_addr(struct mem_section *section)
 {
@@ -1174,6 +1175,23 @@ static inline int valid_section_nr(unsigned long nr)
 	return valid_section(__nr_to_section(nr));
 }
 
+static inline int online_section(struct mem_section *section)
+{
+	return (section && (section->section_mem_map & SECTION_IS_ONLINE));
+}
+
+static inline int online_section_nr(unsigned long nr)
+{
+	return online_section(__nr_to_section(nr));
+}
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn);
+#ifdef CONFIG_MEMORY_HOTREMOVE
+void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn);
+#endif
+#endif
+
 static inline struct mem_section *__pfn_to_section(unsigned long pfn)
 {
 	return __nr_to_section(pfn_to_section_nr(pfn));
@@ -1252,10 +1270,15 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 #ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
 /*
  * pfn_valid() is meant to be able to tell if a given PFN has valid memmap
- * associated with it or not. In FLATMEM, it is expected that holes always
- * have valid memmap as long as there is valid PFNs either side of the hole.
- * In SPARSEMEM, it is assumed that a valid section has a memmap for the
- * entire section.
+ * associated with it or not. This means that a struct page exists for this
+ * pfn. The caller cannot assume the page is fully initialized in general.
+ * Hotplugable pages might not have been onlined yet. pfn_to_online_page()
+ * will ensure the struct page is fully online and initialized. Special pages
+ * (e.g. ZONE_DEVICE) are never onlined and should be treated accordingly.
+ *
+ * In FLATMEM, it is expected that holes always have valid memmap as long as
+ * there is valid PFNs either side of the hole. In SPARSEMEM, it is assumed
+ * that a valid section has a memmap for the entire section.
  *
  * However, an ARM, and maybe other embedded architectures in the future
  * free memmap backing holes to save memory on the assumption the memmap is
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 05796ee974f7..c3a146028ba6 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -929,6 +929,9 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 	unsigned long i;
 	unsigned long onlined_pages = *(unsigned long *)arg;
 	struct page *page;
+
+	online_mem_sections(start_pfn, start_pfn + nr_pages);
+
 	if (PageReserved(pfn_to_page(start_pfn)))
 		for (i = 0; i < nr_pages; i++) {
 			page = pfn_to_page(start_pfn + i);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c1670f090107..7e5151a7dd7b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1353,7 +1353,9 @@ struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
 	if (!pfn_valid(start_pfn) || !pfn_valid(end_pfn))
 		return NULL;
 
-	start_page = pfn_to_page(start_pfn);
+	start_page = pfn_to_online_page(start_pfn);
+	if (!start_page)
+		return NULL;
 
 	if (page_zone(start_page) != zone)
 		return NULL;
@@ -7671,6 +7673,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 			break;
 	if (pfn == end_pfn)
 		return;
+	offline_mem_sections(pfn, end_pfn);
 	zone = page_zone(pfn_to_page(pfn));
 	spin_lock_irqsave(&zone->lock, flags);
 	pfn = start_pfn;
diff --git a/mm/sparse.c b/mm/sparse.c
index 5032c9a619de..9d7fd666015e 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -222,7 +222,8 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
 
 		ms = __nr_to_section(section);
 		if (!ms->section_mem_map) {
-			ms->section_mem_map = sparse_encode_early_nid(nid);
+			ms->section_mem_map = sparse_encode_early_nid(nid) |
+							SECTION_IS_ONLINE;
 			section_mark_present(ms);
 		}
 	}
@@ -622,6 +623,48 @@ void __init sparse_init(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
+
+/* Mark all memory sections within the pfn range as online */
+void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn;
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
+		unsigned long section_nr = pfn_to_section_nr(start_pfn);
+		struct mem_section *ms;
+
+		/* onlining code should never touch invalid ranges */
+		if (WARN_ON(!valid_section_nr(section_nr)))
+			continue;
+
+		ms = __nr_to_section(section_nr);
+		ms->section_mem_map |= SECTION_IS_ONLINE;
+	}
+}
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+/* Mark all memory sections within the pfn range as online */
+void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long pfn;
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
+		unsigned long section_nr = pfn_to_section_nr(start_pfn);
+		struct mem_section *ms;
+
+		/*
+		 * TODO this needs some double checking. Offlining code makes
+		 * sure to check pfn_valid but those checks might be just bogus
+		 */
+		if (WARN_ON(!valid_section_nr(section_nr)))
+			continue;
+
+		ms = __nr_to_section(section_nr);
+		ms->section_mem_map &= ~SECTION_IS_ONLINE;
+	}
+}
+#endif
+
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid)
 {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
