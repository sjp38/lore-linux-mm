Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id kB4DeSCP199602
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:40:29 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB4DeS6F3174428
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 14:40:28 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB4DeRxU020979
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 14:40:28 +0100
Date: Mon, 4 Dec 2006 14:40:27 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH/RFC 4/5] vmem shared memory hotplug support
Message-ID: <20061204134027.GF9209@osiris.boeblingen.de.ibm.com>
References: <20061204133132.GB9209@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061204133132.GB9209@osiris.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Unlike ia64 we need a mechanism which allows us to dynamically attach
shared memory regions.
These memory regions are accessed via the dcss device driver. dcss
implements the 'direct_access' operation, which requires struct pages
for every single shared page.
Therefore this implementation provides an interface to attach/detach
shared memory:

int add_shared_memory(unsigned long start, unsigned long size);
int remove_shared_memory(unsigned long start, unsigned long size);

The purpose of the add_shared_memory function is to add the given
memory range to the 1:1 mapping and to make sure that the
corresponding range in the vmemmap is backed with physical pages.
And of course to initialize the new struct pages.

remove_shared_memory in turn only invalidates the page table
entries in the 1:1 mapping. The page tables and the memory used for
struct pages in the vmemmap are currently not freed. They will be
reused when the next segment will be attached.
Given that the maximum size of shared memory region will be 2GB and
in addition all regions must reside below 2GB this is not too much of
a restriction, but there is room for improvement.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/mm/vmem.c        |  168 +++++++++++++++++++++++++++++++++++++++++++++
 include/asm-s390/pgtable.h |    3 
 2 files changed, 171 insertions(+)

Index: linux-2.6.19-rc6-mm2/arch/s390/mm/vmem.c
===================================================================
--- linux-2.6.19-rc6-mm2.orig/arch/s390/mm/vmem.c
+++ linux-2.6.19-rc6-mm2/arch/s390/mm/vmem.c
@@ -18,6 +18,14 @@ unsigned long vmalloc_end;
 EXPORT_SYMBOL(vmalloc_end);
 
 static struct page *vmem_map;
+static LIST_HEAD(mem_segs);
+static DEFINE_MUTEX(vmem_mutex);
+
+struct memory_segment {
+	struct list_head list;
+	unsigned long start;
+	unsigned long size;
+};
 
 void memmap_init(unsigned long size, int nid, unsigned long zone,
 		 unsigned long start_pfn)
@@ -126,6 +134,31 @@ static int vmem_add_range(unsigned long 
 }
 
 /*
+ * Remove a physical memory range from the 1:1 mapping.
+ * Currently only invalidates page table entries.
+ */
+static void vmem_remove_range(unsigned long start, unsigned long size)
+{
+	unsigned long address;
+	pgd_t *pg_dir;
+	pmd_t *pm_dir;
+	pte_t *pt_dir;
+	pte_t  pte;
+
+	pte_val(pte) = _PAGE_TYPE_EMPTY;
+	for (address = start; address < start + size; address += PAGE_SIZE) {
+		pg_dir = pgd_offset_k(address);
+		if (pgd_none(*pg_dir))
+			continue;
+		pm_dir = pmd_offset(pg_dir, address);
+		if (pmd_none(*pm_dir))
+			continue;
+		pt_dir = pte_offset_kernel(pm_dir, address);
+		set_pte(pt_dir, pte);
+	}
+}
+
+/*
  * Add a backed mem_map array to the virtual mem_map array.
  */
 static int vmem_add_mem_map(unsigned long start, unsigned long size)
@@ -185,6 +218,115 @@ static int vmem_add_mem(unsigned long st
 }
 
 /*
+ * Add memory segment to the segment list if it doesn't overlap with
+ * an already present segment.
+ */
+static int insert_memory_segment(struct memory_segment *seg)
+{
+	struct memory_segment *tmp;
+
+	if (PFN_DOWN(seg->start + seg->size) > max_pfn ||
+	    seg->start + seg->size < seg->start)
+		return -ERANGE;
+
+	list_for_each_entry(tmp, &mem_segs, list) {
+		if (seg->start >= tmp->start + tmp->size)
+			continue;
+		if (seg->start + seg->size <= tmp->start)
+			continue;
+		return -ENOSPC;
+	}
+	list_add(&seg->list, &mem_segs);
+	return 0;
+}
+
+/*
+ * Remove memory segment from the segment list.
+ */
+static void remove_memory_segment(struct memory_segment *seg)
+{
+	list_del(&seg->list);
+}
+
+static void __remove_shared_memory(struct memory_segment *seg)
+{
+	remove_memory_segment(seg);
+	vmem_remove_range(seg->start, seg->size);
+}
+
+int remove_shared_memory(unsigned long start, unsigned long size)
+{
+	struct memory_segment *seg;
+	int ret;
+
+	mutex_lock(&vmem_mutex);
+
+	ret = -ENOENT;
+	list_for_each_entry(seg, &mem_segs, list) {
+		if (seg->start == start && seg->size == size)
+			break;
+	}
+
+	if (seg->start != start || seg->size != size)
+		goto out;
+
+	ret = 0;
+	__remove_shared_memory(seg);
+	kfree(seg);
+out:
+	mutex_unlock(&vmem_mutex);
+	return ret;
+}
+
+int add_shared_memory(unsigned long start, unsigned long size)
+{
+	struct memory_segment *seg;
+	struct page *page;
+	unsigned long pfn, num_pfn, end_pfn;
+	int ret;
+
+	mutex_lock(&vmem_mutex);
+	ret = -ENOMEM;
+	seg = kzalloc(sizeof(*seg), GFP_KERNEL);
+	if (!seg)
+		goto out;
+	seg->start = start;
+	seg->size = size;
+
+	ret = insert_memory_segment(seg);
+	if (ret)
+		goto out_free;
+
+	ret = vmem_add_mem(start, size);
+	if (ret)
+		goto out_remove;
+
+	pfn = PFN_DOWN(start);
+	num_pfn = PFN_DOWN(size);
+	end_pfn = pfn + num_pfn;
+
+	page = pfn_to_page(pfn);
+	memset(page, 0, num_pfn * sizeof(struct page));
+
+	for (; pfn < end_pfn; pfn++) {
+		page = pfn_to_page(pfn);
+		init_page_count(page);
+		reset_page_mapcount(page);
+		SetPageReserved(page);
+		INIT_LIST_HEAD(&page->lru);
+	}
+	goto out;
+
+out_remove:
+	__remove_shared_memory(seg);
+out_free:
+	kfree(seg);
+out:
+	mutex_unlock(&vmem_mutex);
+	return ret;
+}
+
+/*
  * map whole physical memory to virtual memory (identity mapping)
  */
 void __init vmem_map_init(void)
@@ -200,3 +342,29 @@ void __init vmem_map_init(void)
 	for (i = 0; i < MEMORY_CHUNKS && memory_chunk[i].size > 0; i++)
 		vmem_add_mem(memory_chunk[i].addr, memory_chunk[i].size);
 }
+
+/*
+ * Convert memory chunk array to a memory segment list so there is a single
+ * list that contains both r/w memory and shared memory segments.
+ */
+static __init int vmem_convert_memory_chunk(void)
+{
+       struct memory_segment *seg;
+       int i;
+
+       mutex_lock(&vmem_mutex);
+       for (i = 0; i < MEMORY_CHUNKS && memory_chunk[i].size > 0; i++) {
+	       if (!memory_chunk[i].size)
+		       continue;
+	       seg = kzalloc(sizeof(*seg), GFP_KERNEL);
+	       if (!seg)
+		       panic("Out of memory...\n");
+	       seg->start = memory_chunk[i].addr;
+	       seg->size = memory_chunk[i].size;
+	       insert_memory_segment(seg);
+       }
+       mutex_unlock(&vmem_mutex);
+       return 0;
+}
+
+core_initcall(vmem_convert_memory_chunk);
Index: linux-2.6.19-rc6-mm2/include/asm-s390/pgtable.h
===================================================================
--- linux-2.6.19-rc6-mm2.orig/include/asm-s390/pgtable.h
+++ linux-2.6.19-rc6-mm2/include/asm-s390/pgtable.h
@@ -817,6 +817,9 @@ static inline pte_t mk_swap_pte(unsigned
 
 #define kern_addr_valid(addr)   (1)
 
+extern int add_shared_memory(unsigned long start, unsigned long size);
+extern int remove_shared_memory(unsigned long start, unsigned long size);
+
 /*
  * No page table caches to initialise
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
