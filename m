Subject: 150 nonlinear
In-Reply-To: <4173D219.3010706@shadowen.org>
Message-Id: <E1CJYc0-0000aK-A8@ladymac.shadowen.org>
From: Andy Whitcroft <apw@shadowen.org>
Date: Mon, 18 Oct 2004 15:35:48 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

CONFIG_NONLINEAR memory model.

Revision: $Rev$

Signed-off-by: Andy Whitcroft <apw@shadowen.org>

diffstat 150-nonlinear
---
 include/linux/mm.h     |  103 +++++++++++++++++++++++++++++++++---
 include/linux/mmzone.h |  140 +++++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/numa.h   |    2 
 init/main.c            |    1 
 mm/Makefile            |    2 
 mm/bootmem.c           |   15 ++++-
 mm/memory.c            |    2 
 mm/nonlinear.c         |  137 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c        |   87 +++++++++++++++++++++++++++++-
 9 files changed, 469 insertions(+), 20 deletions(-)

diff -upN reference/include/linux/mm.h current/include/linux/mm.h
--- reference/include/linux/mm.h
+++ current/include/linux/mm.h
@@ -379,24 +379,76 @@ static inline void put_page(struct page 
 
 #define FLAGS_SHIFT	(sizeof(page_flags_t)*8)
 
-/* 32bit: NODE:ZONE */
+/*
+ * CONFIG_NONLINEAR:
+ *   If there is room for SECTIONS, NODES AND ZONES then:
+ *     NODE:ZONE:SECTION
+ *   else:
+ *     SECTION:ZONE
+ *
+ * Otherwise:
+ *   NODE:ZONE
+ */
+#ifdef CONFIG_NONLINEAR
+
+#if FLAGS_TOTAL_SHIFT >= SECTIONS_SHIFT + NODES_SHIFT + ZONES_SHIFT
+
+/* NODE:ZONE:SECTION */
 #define PGFLAGS_NODES_SHIFT	(FLAGS_SHIFT - NODES_SHIFT)
 #define PGFLAGS_ZONES_SHIFT	(PGFLAGS_NODES_SHIFT - ZONES_SHIFT)
+#define PGFLAGS_SECTIONS_SHIFT	(PGFLAGS_ZONES_SHIFT - SECTIONS_SHIFT)
+
+#define FLAGS_USED_SHIFT	(NODES_SHIFT + ZONES_SHIFT + SECTIONS_SHIFT)
 
 #define ZONETABLE_SHIFT		(NODES_SHIFT + ZONES_SHIFT)
 #define PGFLAGS_ZONETABLE_SHIFT	(FLAGS_SHIFT - ZONETABLE_SHIFT)
 
-#if NODES_SHIFT+ZONES_SHIFT > FLAGS_TOTAL_SHIFT
-#error NODES_SHIFT+ZONES_SHIFT > FLAGS_TOTAL_SHIFT
+#define ZONETABLE(section, node, zone) \
+			((node << ZONES_SHIFT) | zone)
+
+#else
+
+/* SECTION:ZONE */
+#define PGFLAGS_SECTIONS_SHIFT	(FLAGS_SHIFT - SECTIONS_SHIFT)
+#define PGFLAGS_ZONES_SHIFT	(PGFLAGS_SECTIONS_SHIFT - ZONES_SHIFT)
+
+#define FLAGS_USED_SHIFT	(SECTIONS_SHIFT + ZONES_SHIFT)
+
+#define ZONETABLE_SHIFT		(SECTIONS_SHIFT + ZONES_SHIFT)
+#define PGFLAGS_ZONETABLE_SHIFT	(FLAGS_SHIFT - ZONETABLE_SHIFT)
+
+#define ZONETABLE(section, node, zone) \
+			((section << ZONES_SHIFT) | zone)
+
+#endif
+
+#else /* !CONFIG_NONLINEAR */
+
+/* NODE:ZONE */
+#define PGFLAGS_NODES_SHIFT	(FLAGS_SHIFT - NODES_SHIFT)
+#define PGFLAGS_ZONES_SHIFT	(PGFLAGS_NODES_SHIFT - ZONES_SHIFT)
+
+#define ZONETABLE_SHIFT		(NODES_SHIFT + ZONES_SHIFT)
+#define PGFLAGS_ZONETABLE_SHIFT	(FLAGS_SHIFT - ZONETABLE_SHIFT)
+
+#define FLAGS_USED_SHIFT	(NODES_SHIFT + ZONES_SHIFT)
+
+#endif /* !CONFIG_NONLINEAR */
+
+#if FLAGS_USED_SHIFT > FLAGS_TOTAL_SHIFT
+#error SECTIONS_SHIFT+NODES_SHIFT+ZONES_SHIFT > FLAGS_TOTAL_SHIFT
 #endif
 
 #define NODEZONE(node, zone)		((node << ZONES_SHIFT) | zone)
 
 #define ZONES_MASK		(~((~0UL) << ZONES_SHIFT))
 #define NODES_MASK		(~((~0UL) << NODES_SHIFT))
+#define SECTIONS_MASK		(~((~0UL) << SECTIONS_SHIFT))
 #define ZONETABLE_MASK		(~((~0UL) << ZONETABLE_SHIFT))
 
-#define PGFLAGS_MASK		(~((~0UL) << PGFLAGS_ZONETABLE_SHIFT)
+#define ZONETABLE_SIZE  	(1 << ZONETABLE_SHIFT)
+
+#define PGFLAGS_MASK		(~((~0UL) << PGFLAGS_ZONETABLE_SHIFT))
 
 static inline unsigned long page_zonenum(struct page *page)
 {
@@ -405,13 +457,34 @@ static inline unsigned long page_zonenum
  	else
  		return (page->flags >> PGFLAGS_ZONES_SHIFT) & ZONES_MASK;
 }
+#ifdef PGFLAGS_NODES_SHIFT
 static inline unsigned long page_to_nid(struct page *page)
 {
+#if NODES_SHIFT == 0
+	return 0;
+#else 
 	if (FLAGS_SHIFT == (PGFLAGS_NODES_SHIFT + NODES_SHIFT))
 		return (page->flags >> PGFLAGS_NODES_SHIFT);
 	else
 		return (page->flags >> PGFLAGS_NODES_SHIFT) & NODES_MASK;
+#endif
 }
+#else
+static inline struct zone *page_zone(struct page *page);
+static inline unsigned long page_to_nid(struct page *page)
+{
+	return page_zone(page)->zone_pgdat->node_id;
+}
+#endif
+#ifdef PGFLAGS_SECTIONS_SHIFT
+static inline unsigned long page_to_section(struct page *page)
+{
+	if (FLAGS_SHIFT == (PGFLAGS_SECTIONS_SHIFT + SECTIONS_SHIFT))
+ 		return (page->flags >> PGFLAGS_SECTIONS_SHIFT);
+ 	else
+ 		return (page->flags >> PGFLAGS_SECTIONS_SHIFT) & SECTIONS_MASK;
+}
+#endif
 
 struct zone;
 extern struct zone *zone_table[];
@@ -425,13 +498,27 @@ static inline struct zone *page_zone(str
 			ZONETABLE_MASK];
 }
 
-static inline void set_page_zone(struct page *page, unsigned long nodezone_num)
+static inline void set_page_zone(struct page *page, unsigned long zone)
+{
+	page->flags &= ~(ZONES_MASK << PGFLAGS_ZONES_SHIFT);
+	page->flags |= zone << PGFLAGS_ZONES_SHIFT;
+}
+static inline void set_page_node(struct page *page, unsigned long node)
 {
-	page->flags &= PGFLAGS_MASK;
-	page->flags |= nodezone_num << PGFLAGS_ZONETABLE_SHIFT;
+#if defined(PGFLAGS_NODES_SHIFT) && NODES_SHIFT != 0
+	page->flags &= ~(NODES_MASK << PGFLAGS_NODES_SHIFT);
+	page->flags |= node << PGFLAGS_NODES_SHIFT;
+#endif
+}
+static inline void set_page_section(struct page *page, unsigned long section)
+{
+#ifdef PGFLAGS_SECTIONS_SHIFT
+	page->flags &= ~(SECTIONS_MASK << PGFLAGS_SECTIONS_SHIFT);
+	page->flags |= section << PGFLAGS_SECTIONS_SHIFT;
+#endif
 }
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 /* The array of struct pages - for discontigmem use pgdat->lmem_map */
 extern struct page *mem_map;
 #endif
diff -upN reference/include/linux/mmzone.h current/include/linux/mmzone.h
--- reference/include/linux/mmzone.h
+++ current/include/linux/mmzone.h
@@ -372,7 +372,7 @@ int lower_zone_protection_sysctl_handler
 /* Returns the number of the current Node. */
 #define numa_node_id()		(cpu_to_node(smp_processor_id()))
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 
 extern struct pglist_data contig_page_data;
 #define NODE_DATA(nid)		(&contig_page_data)
@@ -384,6 +384,8 @@ extern struct pglist_data contig_page_da
 
 #include <asm/mmzone.h>
 
+#endif /* CONFIG_FLATMEM */
+
 #if BITS_PER_LONG == 32 || defined(ARCH_HAS_ATOMIC_UNSIGNED)
 /*
  * with 32 bit page->flags field, we reserve 8 bits for node/zone info.
@@ -395,10 +397,13 @@ extern struct pglist_data contig_page_da
 /*
  * with 64 bit flags field, there's plenty of room.
  */
-#define FLAGS_TOTAL_SHIFT	12
-#endif
+#define FLAGS_TOTAL_SHIFT	32
+
+#else
 
-#endif /* !CONFIG_DISCONTIGMEM */
+#error BITS_PER_LONG not set
+
+#endif
 
 extern DECLARE_BITMAP(node_online_map, MAX_NUMNODES);
 
@@ -429,6 +434,133 @@ static inline unsigned int num_online_no
 #define num_online_nodes()	1
 
 #endif /* CONFIG_DISCONTIGMEM || CONFIG_NUMA */
+
+#ifdef CONFIG_NONLINEAR
+
+/*
+ * SECTION_SHIFT                #bits space required to store a section #
+ * PHYS_SECTION_SHIFT           #bits required to store a physical section #
+ *
+ * PA_SECTION_SHIFT             physical address to/from section number
+ * PFN_SECTION_SHIFT            pfn to/from section number
+ */
+#define SECTIONS_SHIFT          (MAX_PHYSMEM_BITS - SECTION_SIZE_BITS)
+#define PHYS_SECTION_SHIFT      (MAX_PHYSADDR_BITS - SECTION_SIZE_BITS)
+
+#define PA_SECTION_SHIFT        (SECTION_SIZE_BITS)
+#define PFN_SECTION_SHIFT       (SECTION_SIZE_BITS - PAGE_SHIFT)
+
+#define NR_MEM_SECTIONS        	(1 << SECTIONS_SHIFT)
+#define NR_PHYS_SECTIONS        (1 << PHYS_SECTION_SHIFT)
+
+#define PAGES_PER_SECTION       (1 << PFN_SECTION_SHIFT)
+#define PAGE_SECTION_MASK	(~(PAGES_PER_SECTION-1))
+
+#if NR_MEM_SECTIONS == NR_PHYS_SECTIONS
+#define NONLINEAR_OPTIMISE 1
+#endif
+
+struct page;
+struct mem_section {
+	short section_nid;
+	struct page *section_mem_map;
+};
+
+#ifndef NONLINEAR_OPTIMISE
+extern short phys_section[NR_PHYS_SECTIONS];
+#endif
+extern struct mem_section mem_section[NR_MEM_SECTIONS];
+
+/*
+ * Given a kernel address, find the home node of the underlying memory.
+ */
+#define kvaddr_to_nid(kaddr)	pfn_to_nid(__pa(kaddr) >> PAGE_SHIFT)
+
+#if 0
+#define node_mem_map(nid)	(NODE_DATA(nid)->node_mem_map)
+
+#define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
+#define node_end_pfn(nid)						\
+({									\
+	pg_data_t *__pgdat = NODE_DATA(nid);				\
+	__pgdat->node_start_pfn + __pgdat->node_spanned_pages;		\
+})
+
+#define local_mapnr(kvaddr)						\
+({									\
+	unsigned long __pfn = __pa(kvaddr) >> PAGE_SHIFT;		\
+	(__pfn - node_start_pfn(pfn_to_nid(__pfn)));			\
+})
+#endif
+
+#if 0
+/* XXX: FIXME -- wli */
+#define kern_addr_valid(kaddr)	(0)
+#endif
+
+static inline struct mem_section *__pfn_to_section(unsigned long pfn)
+{
+#ifdef NONLINEAR_OPTIMISE
+	return &mem_section[pfn >> PFN_SECTION_SHIFT];
+#else
+	return &mem_section[phys_section[pfn >> PFN_SECTION_SHIFT]];
+#endif
+}
+
+#define pfn_to_page(pfn) 						\
+({ 									\
+	unsigned long __pfn = (pfn);					\
+	__pfn_to_section(__pfn)->section_mem_map + __pfn;		\
+})
+#define page_to_pfn(page)						\
+({									\
+	page - mem_section[page_to_section(page)].section_mem_map;	\
+})
+
+/* APW/XXX: this is not generic??? */
+#if 0
+#define pmd_page(pmd)		(pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
+#endif
+
+static inline int pfn_valid(unsigned long pfn)
+{
+	if ((pfn >> PFN_SECTION_SHIFT) >= NR_PHYS_SECTIONS) 
+		return 0;
+#ifdef NONLINEAR_OPTIMISE
+	return mem_section[pfn >> PFN_SECTION_SHIFT].section_mem_map != 0;
+#else
+	return phys_section[pfn >> PFN_SECTION_SHIFT] != -1;
+#endif
+}
+
+/*
+ * APW/XXX: these are _only_ used during initialisation, therefore they
+ * can use __initdata ... they should have names to indicate this
+ * restriction.
+ */
+#ifdef CONFIG_NUMA
+extern unsigned long phys_section_nid[NR_PHYS_SECTIONS];
+#define pfn_to_nid(pfn)							\
+({									\
+	unsigned long __pfn = (pfn);					\
+	phys_section_nid[__pfn >> PFN_SECTION_SHIFT];			\
+})
+#else
+	__pfn_to_section(__pfn)->section_nid;				\
+#define pfn_to_nid(pfn) 0
+#endif
+
+#define pfn_to_pgdat(pfn)						\
+({									\
+	NODE_DATA(pfn_to_nid(pfn));					\
+})
+
+int nonlinear_add(int nid, unsigned long start, unsigned long end);
+int nonlinear_calculate(int nid);
+void nonlinear_allocate(void);
+
+#endif /* CONFIG_NONLINEAR */
+
 #endif /* !__ASSEMBLY__ */
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MMZONE_H */
diff -upN reference/include/linux/numa.h current/include/linux/numa.h
--- reference/include/linux/numa.h
+++ current/include/linux/numa.h
@@ -3,7 +3,7 @@
 
 #include <linux/config.h>
 
-#ifdef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_FLATMEM
 #include <asm/numnodes.h>
 #endif
 
diff -upN reference/init/main.c current/init/main.c
--- reference/init/main.c
+++ current/init/main.c
@@ -480,6 +480,7 @@ asmlinkage void __init start_kernel(void
 {
 	char * command_line;
 	extern struct kernel_param __start___param[], __stop___param[];
+
 /*
  * Interrupts are still disabled. Do necessary setups, then
  * enable them
diff -upN reference/mm/bootmem.c current/mm/bootmem.c
--- reference/mm/bootmem.c
+++ current/mm/bootmem.c
@@ -255,6 +255,7 @@ found:
 static unsigned long __init free_all_bootmem_core(pg_data_t *pgdat)
 {
 	struct page *page;
+	unsigned long pfn;
 	bootmem_data_t *bdata = pgdat->bdata;
 	unsigned long i, count, total = 0;
 	unsigned long idx;
@@ -265,15 +266,26 @@ static unsigned long __init free_all_boo
 
 	count = 0;
 	/* first extant page of the node */
-	page = virt_to_page(phys_to_virt(bdata->node_boot_start));
+	pfn = bdata->node_boot_start >> PAGE_SHIFT;
 	idx = bdata->node_low_pfn - (bdata->node_boot_start >> PAGE_SHIFT);
 	map = bdata->node_bootmem_map;
 	/* Check physaddr is O(LOG2(BITS_PER_LONG)) page aligned */
 	if (bdata->node_boot_start == 0 ||
 	    ffs(bdata->node_boot_start) - PAGE_SHIFT > ffs(BITS_PER_LONG))
 		gofast = 1;
+	page = pfn_to_page(pfn);
 	for (i = 0; i < idx; ) {
 		unsigned long v = ~map[i / BITS_PER_LONG];
+
+		/*
+		 * Makes use of the guarentee that *_mem_map will be
+		 * contigious in sections aligned at MAX_ORDER.
+		 * APW/XXX: we are making an assumption that our node_boot_start
+		 * is aligned to BITS_PER_LONG ... is this valid/enforced.
+		 */
+		if ((pfn & ((1 << MAX_ORDER) - 1)) == 0)
+			page = pfn_to_page(pfn);
+
 		if (gofast && v == ~0UL) {
 			int j;
 
@@ -302,6 +314,7 @@ static unsigned long __init free_all_boo
 			i+=BITS_PER_LONG;
 			page += BITS_PER_LONG;
 		}
+		pfn += BITS_PER_LONG;
 	}
 	total += count;
 
diff -upN reference/mm/Makefile current/mm/Makefile
--- reference/mm/Makefile
+++ current/mm/Makefile
@@ -15,6 +15,6 @@ obj-y			:= bootmem.o filemap.o mempool.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
+obj-$(CONFIG_NONLINEAR)       += nonlinear.o
 obj-$(CONFIG_SHMEM) += shmem.o
 obj-$(CONFIG_TINY_SHMEM) += tiny-shmem.o
-
diff -upN reference/mm/memory.c current/mm/memory.c
--- reference/mm/memory.c
+++ current/mm/memory.c
@@ -56,7 +56,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
 struct page *mem_map;
diff -upN /dev/null current/mm/nonlinear.c
--- /dev/null
+++ current/mm/nonlinear.c
@@ -0,0 +1,137 @@
+/*
+ * Non-linear memory mappings.
+ */
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/bootmem.h>
+#include <linux/module.h>
+#include <asm/dma.h>
+
+/*
+ * Permenant non-linear data:
+ *
+ * 1) phys_section	- valid physical memory sections (in mem_section)
+ * 2) mem_section	- memory sections, mem_map's for valid memory
+ */
+#ifndef NONLINEAR_OPTIMISE
+short phys_section[NR_PHYS_SECTIONS] = { [ 0 ... NR_PHYS_SECTIONS-1] = -1 };
+EXPORT_SYMBOL(phys_section);
+#endif
+struct mem_section mem_section[NR_MEM_SECTIONS];
+EXPORT_SYMBOL(mem_section);
+
+
+/*
+ * Initialisation time data:
+ *
+ * 1) phys_section_nid  - physical section node id
+ * 2) phys_section_pfn  - physical section base page frame
+ */
+unsigned long phys_section_nid[NR_PHYS_SECTIONS] __initdata =
+	{ [ 0 ... NR_PHYS_SECTIONS-1] = -1 };
+static unsigned long phys_section_pfn[NR_PHYS_SECTIONS] __initdata;
+
+/* Record a non-linear memory area for a node. */
+int nonlinear_add(int nid, unsigned long start, unsigned long end)
+{
+	unsigned long pfn = start;
+
+printk(KERN_WARNING "APW: nonlinear_add: nid<%d> start<%08lx:%ld> end<%08lx:%ld>\n",
+		nid, start, start >> PFN_SECTION_SHIFT, end, end >> PFN_SECTION_SHIFT);
+	start &= PAGE_SECTION_MASK;
+	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION) {
+/*printk(KERN_WARNING "  APW: nonlinear_add: section<%d> pfn<%08lx>\n", 
+	pfn >> PFN_SECTION_SHIFT, pfn);*/
+		phys_section_nid[pfn >> PFN_SECTION_SHIFT] = nid;
+		phys_section_pfn[pfn >> PFN_SECTION_SHIFT] = pfn;
+	}
+
+	return 1;
+}
+
+/*
+ * Calculate the space required on a per node basis for the mmap.
+ */
+int nonlinear_calculate(int nid)
+{
+	int pnum;
+	int sections = 0;
+
+	for (pnum = 0; pnum < NR_PHYS_SECTIONS; pnum++) {
+		if (phys_section_nid[pnum] == nid)
+			sections++;
+	}
+
+	return (sections * PAGES_PER_SECTION * sizeof(struct page));
+}
+
+
+/* XXX/APW: NO! */
+void *alloc_remap(int nid, unsigned long size);
+
+/*
+ * Allocate the accumulated non-linear sections, allocate a mem_map
+ * for each and record the physical to section mapping.
+ */
+void nonlinear_allocate(void)
+{
+	int snum = 0;
+	int pnum;
+	struct page *map;
+
+	for (pnum = 0; pnum < NR_PHYS_SECTIONS; pnum++) {
+		if (phys_section_nid[pnum] == -1)
+			continue;
+
+		/* APW/XXX: this is a dumbo name for this feature, should
+		 * be something like alloc_really_really_early. */
+#ifdef HAVE_ARCH_ALLOC_REMAP
+		map = alloc_remap(phys_section_nid[pnum],
+				sizeof(struct page) * PAGES_PER_SECTION);
+#else
+		map = 0;
+#endif
+		if (!map)
+			map = alloc_bootmem_node(NODE_DATA(phys_section_nid[pnum]),
+				sizeof(struct page) * PAGES_PER_SECTION);
+		if (!map)
+			continue;
+
+		/*
+		 * Subtle, we encode the real pfn into the mem_map such that
+		 * the identity pfn - section_mem_map will return the actual
+		 * physical page frame number.
+		 */
+#ifdef NONLINEAR_OPTIMISE
+		snum = pnum;
+#else
+		phys_section[pnum] = snum;
+#endif
+		mem_section[snum].section_mem_map = map -
+			phys_section_pfn[pnum];
+
+if ((pnum % 32) == 0)
+printk(KERN_WARNING "APW: nonlinear_allocate: section<%d> map<%p> ms<%p> pfn<%08lx>\n", pnum, map, mem_section[snum].section_mem_map,  phys_section_pfn[pnum]);
+
+
+		snum++;
+	}
+
+#if 0
+#define X(x)	printk(KERN_WARNING "APW: " #x "<%08lx>\n", x)
+	X(FLAGS_SHIFT);
+	X(SECTIONS_SHIFT);
+	X(ZONES_SHIFT);
+	X(PGFLAGS_SECTIONS_SHIFT);
+	X(PGFLAGS_ZONES_SHIFT);
+	X(ZONETABLE_SHIFT);
+	X(PGFLAGS_ZONETABLE_SHIFT);
+	X(FLAGS_USED_SHIFT);
+	X(ZONES_MASK);
+	X(NODES_MASK);
+	X(SECTIONS_MASK);
+	X(ZONETABLE_MASK);
+	X(ZONETABLE_SIZE);
+	X(PGFLAGS_MASK);
+#endif
+}
diff -upN reference/mm/page_alloc.c current/mm/page_alloc.c
--- reference/mm/page_alloc.c
+++ current/mm/page_alloc.c
@@ -49,7 +49,7 @@ EXPORT_SYMBOL(nr_swap_pages);
  * Used by page_zone() to look up the address of the struct zone whose
  * id is encoded in the upper bits of page->flags
  */
-struct zone *zone_table[1 << (ZONES_SHIFT + NODES_SHIFT)];
+struct zone *zone_table[ZONETABLE_SIZE];
 EXPORT_SYMBOL(zone_table);
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
@@ -63,6 +63,7 @@ unsigned long __initdata nr_all_pages;
  */
 static int bad_range(struct zone *zone, struct page *page)
 {
+	/* printk(KERN_WARNING "bad_range: page<%p> pfn<%08lx> s<%08lx> e<%08lx> zone<%p><%p>\n", page, page_to_pfn(page), zone->zone_start_pfn,  zone->zone_start_pfn + zone->spanned_pages, zone, page_zone(page)); */
 	if (page_to_pfn(page) >= zone->zone_start_pfn + zone->spanned_pages)
 		return 1;
 	if (page_to_pfn(page) < zone->zone_start_pfn)
@@ -187,7 +188,11 @@ static inline void __free_pages_bulk (st
 	if (order)
 		destroy_compound_page(page, order);
 	mask = (~0UL) << order;
+#ifdef CONFIG_NONLINEAR
+	page_idx = page_to_pfn(page) - zone->zone_start_pfn;
+#else
 	page_idx = page - base;
+#endif
 	if (page_idx & ~mask)
 		BUG();
 	index = page_idx >> (1 + order);
@@ -204,8 +209,35 @@ static inline void __free_pages_bulk (st
 			break;
 
 		/* Move the buddy up one level. */
+#ifdef CONFIG_NONLINEAR
+		/*
+		 * Locate the struct page for both the matching buddy in our
+		 * pair (buddy1) and the combined O(n+1) page they form (page).
+		 * 
+		 * 1) Any buddy B1 will have an order O twin B2 which satisfies
+		 * the following equasion:
+		 *     B2 = B1 ^ (1 << O)
+		 * For example, if the starting buddy (buddy2) is #8 its order
+		 * 1 buddy is #10:
+		 *     B2 = 8 ^ (1 << 1) = 8 ^ 2 = 10
+		 *
+		 * 2) Any buddy B will have an order O+1 parent P which
+		 * satisfies the following equasion:
+		 *     P = B & ~(1 << O)
+		 *
+		 * Assumption: *_mem_map is contigious at least up to MAX_ORDER
+		 */
+		buddy1 = page + ((page_idx ^ (1 << order)) - page_idx);
+		buddy2 = page;
+
+		page = page - (page_idx - (page_idx & ~(1 << order)));
+
+		if (bad_range(zone, buddy1))
+		printk(KERN_WARNING "__free_pages_bulk: buddy1<%p> buddy2<%p> page<%p> page_idx<%ld> off<%ld>\n", buddy1, buddy2, page, page_idx, (page_idx - (page_idx & ~(1 << order)))); 
+#else
 		buddy1 = base + (page_idx ^ (1 << order));
 		buddy2 = base + page_idx;
+#endif
 		BUG_ON(bad_range(zone, buddy1));
 		BUG_ON(bad_range(zone, buddy2));
 		list_del(&buddy1->lru);
@@ -215,7 +247,11 @@ static inline void __free_pages_bulk (st
 		index >>= 1;
 		page_idx &= mask;
 	}
+#ifdef CONFIG_NONLINEAR
+	list_add(&page->lru, &area->free_list);
+#else
 	list_add(&(base + page_idx)->lru, &area->free_list);
+#endif
 }
 
 static inline void free_pages_check(const char *function, struct page *page)
@@ -380,7 +416,11 @@ static struct page *__rmqueue(struct zon
 
 		page = list_entry(area->free_list.next, struct page, lru);
 		list_del(&page->lru);
+#ifdef CONFIG_NONLINEAR
+		index = page_to_pfn(page) - zone->zone_start_pfn;
+#else
 		index = page - zone->zone_mem_map;
+#endif
 		if (current_order != MAX_ORDER-1)
 			MARK_USED(index, current_order, area);
 		zone->free_pages -= 1UL << order;
@@ -1401,9 +1441,39 @@ void __init memmap_init_zone(unsigned lo
 {
 	struct page *start = pfn_to_page(start_pfn);
 	struct page *page;
+	struct zone *zonep = &NODE_DATA(nid)->node_zones[zone];
+#ifdef CONFIG_NONLINEAR
+	int pfn;
+#endif
+
+	/* APW/XXX: this is the place to both allocate the memory for the
+	 * section; scan the range offered relative to the zone and
+	 * instantiate the page's.
+	 */
+	printk(KERN_WARNING "APW: zone<%p> start<%08lx> pgdat<%p>\n",
+			zonep, start_pfn, zonep->zone_pgdat);
 
+#ifdef CONFIG_NONLINEAR
+	for (pfn = start_pfn; pfn < (start_pfn + size); pfn++) {
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+
+		/*
+		 * Record the CHUNKZONE for this page and the install the
+		 * zone_table link for it also.
+		 */
+		set_page_node(page, nid);
+		set_page_zone(page, zone);
+		set_page_section(page, pfn >> PFN_SECTION_SHIFT);
+		zone_table[ZONETABLE(pfn >> PFN_SECTION_SHIFT, nid, zone)] =
+			zonep;
+#else
 	for (page = start; page < (start + size); page++) {
-		set_page_zone(page, NODEZONE(nid, zone));
+		set_page_node(page, nid);
+		set_page_zone(page, zone);
+#endif
+
 		set_page_count(page, 0);
 		reset_page_mapcount(page);
 		SetPageReserved(page);
@@ -1413,8 +1483,15 @@ void __init memmap_init_zone(unsigned lo
 		if (!is_highmem_idx(zone))
 			set_page_address(page, __va(start_pfn << PAGE_SHIFT));
 #endif
+		
+#ifdef CONFIG_NONLINEAR
+	}
+#else
 		start_pfn++;
 	}
+#endif
+	printk(KERN_WARNING "APW: zone<%p> start<%08lx> pgdat<%p>\n",
+			zonep, start_pfn, zonep->zone_pgdat);
 }
 
 /*
@@ -1509,7 +1586,9 @@ static void __init free_area_init_core(s
 		unsigned long size, realsize;
 		unsigned long batch;
 
+#ifndef CONFIG_NONLINEAR
 		zone_table[NODEZONE(nid, j)] = zone;
+#endif
 		realsize = size = zones_size[j];
 		if (zholes_size)
 			realsize -= zholes_size[j];
@@ -1613,7 +1692,7 @@ void __init node_alloc_mem_map(struct pg
 #endif
 		map = alloc_bootmem_node(pgdat, size);
 	pgdat->node_mem_map = map;
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 	mem_map = contig_page_data.node_mem_map;
 #endif
 }
@@ -1632,7 +1711,7 @@ void __init free_area_init_node(int nid,
 	free_area_init_core(pgdat, zones_size, zholes_size);
 }
 
-#ifndef CONFIG_DISCONTIGMEM
+#ifdef CONFIG_FLATMEM
 static bootmem_data_t contig_bootmem_data;
 struct pglist_data contig_page_data = { .bdata = &contig_bootmem_data };
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
