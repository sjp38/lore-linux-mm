From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/7] sparsemem: record when a section has a valid mem_map
References: <exportbomb.1184333503@pinky>
Message-Id: <E1I9LJ4-00006d-03@hellhawk.shadowen.org>
Date: Fri, 13 Jul 2007 14:35:38 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

We have flags to indicate whether a section actually has a valid
mem_map associated with it.  This is never set and we rely solely
on the present bit to indicate a section is valid.  By definition
a section is not valid if it has no mem_map and there is a window
during init where the present bit is set but there is no mem_map,
during which pfn_valid() will return true incorrectly.

Use the existing SECTION_HAS_MEM_MAP flag to indicate the presence
of a valid mem_map.  Switch valid_section{,_nr} and pfn_valid()
to this bit.  Add a new present_section{,_nr} and pfn_present()
interfaces for those users who care to know that a section is going
to be valid.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 74b9679..f1f0af8 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -239,7 +239,7 @@ store_mem_state(struct sys_device *dev, const char *buf, size_t count)
 	mem = container_of(dev, struct memory_block, sysdev);
 	phys_section_nr = mem->phys_index;
 
-	if (!valid_section_nr(phys_section_nr))
+	if (!present_section_nr(phys_section_nr))
 		goto out;
 
 	if (!strncmp(buf, "online", min((int)count, 6)))
@@ -419,7 +419,7 @@ int register_new_memory(struct mem_section *section)
 
 int unregister_memory_section(struct mem_section *section)
 {
-	if (!valid_section(section))
+	if (!present_section(section))
 		return -EINVAL;
 
 	return remove_memory_block(0, section, 0);
@@ -444,7 +444,7 @@ int __init memory_dev_init(void)
 	 * during boot and have been initialized
 	 */
 	for (i = 0; i < NR_MEM_SECTIONS; i++) {
-		if (!valid_section_nr(i))
+		if (!present_section_nr(i))
 			continue;
 		err = add_memory_block(0, __nr_to_section(i), MEM_ONLINE, 0);
 		if (!ret)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 26341a6..f83317b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -792,12 +792,17 @@ static inline struct page *__section_mem_map_addr(struct mem_section *section)
 	return (struct page *)map;
 }
 
-static inline int valid_section(struct mem_section *section)
+static inline int present_section(struct mem_section *section)
 {
 	return (section && (section->section_mem_map & SECTION_MARKED_PRESENT));
 }
 
-static inline int section_has_mem_map(struct mem_section *section)
+static inline int present_section_nr(unsigned long nr)
+{
+	return present_section(__nr_to_section(nr));
+}
+
+static inline int valid_section(struct mem_section *section)
 {
 	return (section && (section->section_mem_map & SECTION_HAS_MEM_MAP));
 }
@@ -819,6 +824,13 @@ static inline int pfn_valid(unsigned long pfn)
 	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
 }
 
+static inline int pfn_present(unsigned long pfn)
+{
+        if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
+                return 0;
+        return present_section(__nr_to_section(pfn_to_section_nr(pfn)));
+}
+
 /*
  * These are _only_ used during initialisation, therefore they
  * can use __initdata ...  They could have names to indicate
diff --git a/mm/sparse.c b/mm/sparse.c
index ec6ead6..d6678ab 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -170,7 +170,7 @@ unsigned long __init node_memmap_size_bytes(int nid, unsigned long start_pfn,
 		if (nid != early_pfn_to_nid(pfn))
 			continue;
 
-		if (pfn_valid(pfn))
+		if (pfn_present(pfn))
 			nr_pages += PAGES_PER_SECTION;
 	}
 
@@ -201,11 +201,12 @@ static int __meminit sparse_init_one_section(struct mem_section *ms,
 		unsigned long pnum, struct page *mem_map,
 		unsigned long *pageblock_bitmap)
 {
-	if (!valid_section(ms))
+	if (!present_section(ms))
 		return -EINVAL;
 
 	ms->section_mem_map &= ~SECTION_MAP_MASK;
-	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum);
+	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
+							SECTION_HAS_MEM_MAP;
 	ms->pageblock_flags = pageblock_bitmap;
 
 	return 1;
@@ -282,7 +283,7 @@ void __init sparse_init(void)
 	unsigned long *usemap;
 
 	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
-		if (!valid_section_nr(pnum))
+		if (!present_section_nr(pnum))
 			continue;
 
 		map = sparse_early_mem_map_alloc(pnum);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
