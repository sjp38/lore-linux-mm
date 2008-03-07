From: Andi Kleen <andi@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [13/13] Convert x86-64 swiotlb to use the mask allocator directly
Message-Id: <20080307090723.BACE21B419C@basil.firstfloor.org>
Date: Fri,  7 Mar 2008 10:07:23 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The swiotlb and DMA pools already interact. Instead of using two separate
pools just always use the mask allocator pool. When swiotlb is active
the mask allocator pool is extended by the respective swiotlb size
(64MB by default as with the old code). Then all swiotlb bouncing
happens directly through the maskable zone.

This is ok because there are no "normal" memory consumers in 
the maskable zone and (nearly) all users who allocate from it would
already allocate from swiotlb before.

The code is based on the original swiotlb code, but heavily modified.

One difference now is that the swiotlb is only managed in page size
chunks now. The previous implementation used 2K "slabs". I'm still
running statistics to see if it's worth doing something about this.

lib/swiotlb.c is now not used anymore on x86.

Signed-off-by: Andi Kleen <ak@suse.de>

---
 arch/x86/Kconfig                 |    6 
 arch/x86/kernel/Makefile         |    2 
 arch/x86/kernel/pci-dma_64.c     |    4 
 arch/x86/kernel/pci-swiotlb_64.c |  431 +++++++++++++++++++++++++++++++++++++--
 include/asm-x86/swiotlb.h        |    2 
 include/linux/page-flags.h       |    1 
 6 files changed, 420 insertions(+), 26 deletions(-)

Index: linux/arch/x86/kernel/pci-dma_64.c
===================================================================
--- linux.orig/arch/x86/kernel/pci-dma_64.c
+++ linux/arch/x86/kernel/pci-dma_64.c
@@ -250,7 +250,7 @@ static __init int iommu_setup(char *p)
 		if (!strncmp(p, "nodac", 5))
 			forbid_dac = -1;
 
-#ifdef CONFIG_SWIOTLB
+#ifdef CONFIG_SWIOTLB_MASK_ALLOC
 		if (!strncmp(p, "soft",4))
 			swiotlb = 1;
 #endif
@@ -288,7 +288,7 @@ void __init pci_iommu_alloc(void)
 
 	detect_intel_iommu();
 
-#ifdef CONFIG_SWIOTLB
+#ifdef CONFIG_SWIOTLB_MASK_ALLOC
 	pci_swiotlb_init();
 #endif
 }
Index: linux/arch/x86/kernel/pci-swiotlb_64.c
===================================================================
--- linux.orig/arch/x86/kernel/pci-swiotlb_64.c
+++ linux/arch/x86/kernel/pci-swiotlb_64.c
@@ -1,30 +1,389 @@
-/* Glue code to lib/swiotlb.c */
-
+/*
+ * DMATLB implementation that bounces through isolated DMA zones.
+ * Losely based on the original swiotlb.c from Asit Mallick et.al.
+ *
+ * Still tries to be plug compatible with the lib/swiotlb.c,
+ * but that can be lifted at some point. That is the reason for the
+ * mixed naming convention.
+ *
+ * TBD: Should really support an interface for sleepy maps
+ */
 #include <linux/pci.h>
 #include <linux/cache.h>
 #include <linux/module.h>
 #include <linux/dma-mapping.h>
+#include <linux/ctype.h>
+#include <linux/bootmem.h>
+#include <linux/hardirq.h>
 
 #include <asm/gart.h>
 #include <asm/swiotlb.h>
 #include <asm/dma.h>
+#include <asm/dma-mapping.h>
+
+#define DEFAULT_SWIOTLB_SIZE (64*1024*1024)
 
 int swiotlb __read_mostly;
 
-const struct dma_mapping_ops swiotlb_dma_ops = {
-	.mapping_error = swiotlb_dma_mapping_error,
-	.alloc_coherent = swiotlb_alloc_coherent,
-	.free_coherent = swiotlb_free_coherent,
-	.map_single = swiotlb_map_single,
-	.unmap_single = swiotlb_unmap_single,
-	.sync_single_for_cpu = swiotlb_sync_single_for_cpu,
-	.sync_single_for_device = swiotlb_sync_single_for_device,
-	.sync_single_range_for_cpu = swiotlb_sync_single_range_for_cpu,
-	.sync_single_range_for_device = swiotlb_sync_single_range_for_device,
-	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
-	.sync_sg_for_device = swiotlb_sync_sg_for_device,
-	.map_sg = swiotlb_map_sg,
-	.unmap_sg = swiotlb_unmap_sg,
+#define PageSwiotlb(p) test_bit(PG_swiotlb, &(p)->flags)
+#define SetPageSwiotlb(p)	set_bit(PG_swiotlb, &(p)->flags);
+#define ClearPageSwiotlb(p)	clear_bit(PG_swiotlb, &(p)->flags);
+
+int swiotlb_force __read_mostly;
+
+unsigned swiotlb_size;
+
+static unsigned long io_tlb_overflow = 32*1024;
+void *io_tlb_overflow_buffer;
+
+enum dma_sync_target {
+	SYNC_FOR_CPU = 0,
+	SYNC_FOR_DEVICE = 1,
+};
+
+static void
+dmatlb_full(struct device *dev, size_t size, int dir, int do_panic)
+{
+	/*
+	 * Ran out of IOMMU space for this operation. This is very bad.
+	 * Unfortunately the drivers cannot handle this operation properly.
+	 * unless they check for dma_mapping_error (most don't)
+	 * When the mapping is small enough return a static buffer to limit
+	 * the damage, or panic when the transfer is too big.
+	 */
+	printk(KERN_ERR "DMA: Out of DMA-TLB bounce space for %zu bytes at "
+	       "device %s\n", size, dev ? dev->bus_id : "?");
+
+	if (size > io_tlb_overflow && do_panic) {
+		if (dir == DMA_FROM_DEVICE || dir == DMA_BIDIRECTIONAL)
+			panic("DMA: Memory would be corrupted\n");
+		if (dir == DMA_TO_DEVICE || dir == DMA_BIDIRECTIONAL)
+			panic("DMA: Random memory would be DMAed\n");
+	}
+}
+
+static int
+needs_mapping(struct device *hwdev, dma_addr_t addr)
+{
+	dma_addr_t mask = 0xffffffff;
+	/* If the device has a mask, use it, otherwise default to 32 bits */
+	if (hwdev && hwdev->dma_mask)
+		mask = *hwdev->dma_mask;
+	return (addr & ~mask) != 0;
+}
+
+static void account(int pages, int size)
+{
+	unsigned waste;
+	get_cpu();
+	__count_vm_events(SWIOTLB_USED_PAGES, pages);
+	waste = (PAGE_SIZE * pages) - size;
+	__count_vm_events(SWIOTLB_BYTES_WASTED, waste);
+	__count_vm_event(SWIOTLB_NUM_ALLOCS);
+	put_cpu();
+}
+
+/*
+ * Allocates bounce buffer and returns its kernel virtual address.
+ */
+static void *
+map_single(struct device *hwdev, char *buffer, size_t size, int dir)
+{
+	void *dma_addr;
+	int pages, i;
+	struct page *p;
+	gfp_t gfp = GFP_ATOMIC;
+	p = alloc_pages_mask(gfp, max(size, MASK_MIN_SIZE), *hwdev->dma_mask);
+	if (!p)
+		return NULL;
+	SetPageSwiotlb(p);
+	pages = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	account(pages, size);
+	p->lru.next = (void *)buffer;
+	p->lru.prev = (void *)size;
+	for (i = 1; i < pages; i++) {
+		struct page *n = p + i;
+		SetPageSwiotlb(n);
+		n->lru.next = (void *)buffer + i*PAGE_SIZE;
+		n->lru.prev = (void *)PAGE_SIZE;
+	}
+
+	dma_addr = page_address(p);
+	if (dir == DMA_TO_DEVICE || dir == DMA_BIDIRECTIONAL)
+		memcpy(dma_addr, buffer, size);
+	BUG_ON(virt_to_phys(dma_addr + size - 1) & ~*hwdev->dma_mask);
+	return dma_addr;
+}
+
+static void dmatlb_unmap_single(struct device *hwdev, dma_addr_t dev_addr,
+				size_t size, int dir)
+{
+	char *dma_addr = bus_to_virt(dev_addr);
+	struct page *p = virt_to_page(dma_addr);
+	void *buffer;
+	int pages, i;
+
+	BUG_ON(dir == DMA_NONE);
+
+	if (!PageSwiotlb(p))
+		return;
+	BUG_ON((long)p->lru.prev < 0);
+	BUG_ON((unsigned long)p->lru.prev < size);
+
+	buffer = p->lru.next;
+
+	/*
+	 * First, sync the memory before unmapping the entry
+	 */
+	if (dir == DMA_FROM_DEVICE || dir == DMA_BIDIRECTIONAL)
+		memcpy(buffer, dma_addr, size);
+
+	ClearPageSwiotlb(p);
+	p->lru.next = NULL;
+	p->lru.prev = NULL;
+	pages = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	for (i = 1; i < pages; i++) {
+		struct page *n = p + i;
+		ClearPageSwiotlb(n);
+		BUG_ON((long)n->lru.prev < 0);
+		BUG_ON((void *)n->lru.next != buffer + i*PAGE_SIZE);
+		n->lru.next = NULL;
+		n->lru.prev = NULL;
+	}
+	__free_pages_mask(p, max(size, MASK_MIN_SIZE));
+	count_vm_event(SWIOTLB_NUM_FREES);
+}
+
+static void
+sync_single(struct device *hwdev, char *dma_addr, size_t size,
+	    int dir, int target, void *buffer)
+{
+	buffer += ((unsigned long)dma_addr & ~PAGE_MASK);
+	switch (target) {
+	case SYNC_FOR_CPU:
+		if (dir == DMA_FROM_DEVICE || dir == DMA_BIDIRECTIONAL)
+			memcpy(buffer, dma_addr, size);
+		else
+			BUG_ON(dir != DMA_TO_DEVICE);
+		break;
+	case SYNC_FOR_DEVICE:
+		if (dir == DMA_TO_DEVICE || dir == DMA_BIDIRECTIONAL)
+			memcpy(dma_addr, buffer, size);
+		else
+			BUG_ON(dir != DMA_FROM_DEVICE);
+		break;
+	default:
+		BUG();
+	}
+}
+
+/*
+ * Map a single buffer of the indicated size for DMA in streaming mode.  The
+ * physical address to use is returned.
+ *
+ * Once the device is given the dma address, the device owns this
+ * memory until either swiotlb_unmap_single or swiotlb_dma_sync_single
+ * is performed.
+ */
+static dma_addr_t
+dmatlb_map_single(struct device *hwdev, void *ptr, size_t size, int dir)
+{
+	dma_addr_t dev_addr = virt_to_bus(ptr);
+	void *map;
+
+	BUG_ON(dir == DMA_NONE);
+	/*
+	 * If the pointer passed in happens to be in the device's DMA
+	 * window, we can safely return the device addr and not worry
+	 * about bounce buffering it.
+	 */
+	if (!needs_mapping(hwdev, dev_addr) && !swiotlb_force)
+		return dev_addr;
+
+	/*
+	 * Oh well, have to allocate and map a bounce buffer.
+	 */
+	map = map_single(hwdev, ptr, size, dir);
+	if (!map) {
+		dmatlb_full(hwdev, size, dir, 1);
+		map = io_tlb_overflow_buffer;
+	}
+
+	dev_addr = virt_to_bus(map);
+	return dev_addr;
+}
+
+/*
+ * Make physical memory consistent for a single streaming mode DMA
+ * translation after a transfer.
+ *
+ * If you perform a dmatlb_map_single() but wish to interrogate the buffer
+ * using the cpu, yet do not wish to teardown the dma mapping, you must
+ * call this function before doing so.	At the next point you give the dma
+ * address back to the card, you must first perform a
+ * dmatlb_dma_sync_for_device, and then the device again owns the buffer
+ */
+static void
+dmatlb_sync_single(struct device *hwdev, dma_addr_t dev_addr,
+		    size_t size, int dir, int tgt)
+{
+	char *dma_addr = bus_to_virt(dev_addr);
+	struct page *p;
+
+	BUG_ON(dir == DMA_NONE);
+	p = virt_to_page(dma_addr);
+	if (PageSwiotlb(p))
+		sync_single(hwdev, dma_addr, size, dir, tgt, p->lru.next);
+}
+
+static void
+dmatlb_sync_single_for_cpu(struct device *hwdev, dma_addr_t dev_addr,
+			    size_t size, int dir)
+{
+	dmatlb_sync_single(hwdev, dev_addr, size, dir, SYNC_FOR_CPU);
+}
+
+static void
+dmatlb_sync_single_for_device(struct device *hwdev, dma_addr_t dev_addr,
+			       size_t size, int dir)
+{
+	dmatlb_sync_single(hwdev, dev_addr, size, dir, SYNC_FOR_DEVICE);
+}
+
+/*
+ * Same as above, but for a sub-range of the mapping.
+ */
+static void
+dmatlb_sync_single_range(struct device *hwdev, dma_addr_t dev_addr,
+			  unsigned long offset, size_t size,
+			  int dir, int tgt)
+{
+	char *dma_addr = bus_to_virt(dev_addr) + offset;
+	struct page *p = virt_to_page(dma_addr);
+
+	BUG_ON(dir == DMA_NONE);
+	if (PageSwiotlb(p))
+		sync_single(hwdev, dma_addr, size, dir, tgt, p->lru.next);
+}
+
+static void
+dmatlb_sync_single_range_for_cpu(struct device *hwdev, dma_addr_t dev_addr,
+				 unsigned long offset, size_t size, int dir)
+{
+	dmatlb_sync_single_range(hwdev, dev_addr, offset, size, dir,
+				  SYNC_FOR_CPU);
+}
+
+static void
+dmatlb_sync_single_range_for_device(struct device *hwdev,
+				    dma_addr_t dev_addr,
+				    unsigned long offset, size_t size,
+				    int dir)
+{
+	dmatlb_sync_single_range(hwdev, dev_addr, offset, size, dir,
+				  SYNC_FOR_DEVICE);
+}
+
+/*
+ * Unmap a set of streaming mode DMA translations.  Again, cpu read rules
+ * concerning calls here are the same as for swiotlb_unmap_single() above.
+ */
+static void
+dmatlb_unmap_sg(struct device *hwdev, struct scatterlist *sg, int nelems,
+		 int dir)
+{
+	int i;
+
+	BUG_ON(dir == DMA_NONE);
+
+	for (i = 0; i < nelems; i++, sg++) {
+		if (sg->dma_address != virt_to_bus(sg_virt(sg)))
+			dmatlb_unmap_single(hwdev, sg->dma_address,
+					    sg->dma_length, dir);
+	}
+}
+
+static int
+dmatlb_map_sg(struct device *hwdev, struct scatterlist *sg, int nelems,
+	       int dir)
+{
+	void *addr;
+	dma_addr_t dev_addr;
+	int i;
+
+	BUG_ON(dir == DMA_NONE);
+
+	for (i = 0; i < nelems; i++, sg++) {
+		addr = sg_virt(sg);
+		dev_addr = virt_to_bus(addr);
+		if (swiotlb_force || needs_mapping(hwdev, dev_addr)) {
+			void *map;
+			map = map_single(hwdev, addr, sg->length, dir);
+			if (!map) {
+				/* Don't panic here, we expect map_sg users
+				   to do proper error handling. */
+				dmatlb_full(hwdev, sg->length, dir, 0);
+				dmatlb_unmap_sg(hwdev, sg - i, i, dir);
+				sg[0].dma_length = 0;
+				return 0;
+			}
+			sg->dma_address = virt_to_bus(map);
+		} else
+			sg->dma_address = dev_addr;
+		sg->dma_length = sg->length;
+	}
+	return nelems;
+}
+
+static void
+dmatlb_sync_sg(struct device *hwdev, struct scatterlist *sg,
+		int nelems, int dir, int target)
+{
+	int i;
+
+	BUG_ON(dir == DMA_NONE);
+
+	for (i = 0; i < nelems; i++, sg++) {
+		void *p = bus_to_virt(sg->dma_address);
+		struct page *pg = virt_to_page(p);
+		if (PageSwiotlb(pg))
+			sync_single(hwdev, p, sg->dma_length, dir, target,
+				    pg->lru.next);
+	}
+}
+
+static void
+dmatlb_sync_sg_for_cpu(struct device *hwdev, struct scatterlist *sg,
+			int nelems, int dir)
+{
+	dmatlb_sync_sg(hwdev, sg, nelems, dir, SYNC_FOR_CPU);
+}
+
+static void
+dmatlb_sync_sg_for_device(struct device *hwdev, struct scatterlist *sg,
+			   int nelems, int dir)
+{
+	dmatlb_sync_sg(hwdev, sg, nelems, dir, SYNC_FOR_DEVICE);
+}
+
+static int
+dmatlb_dma_mapping_error(dma_addr_t dma_addr)
+{
+	return (dma_addr == virt_to_bus(io_tlb_overflow_buffer));
+}
+
+const struct dma_mapping_ops dmatlb_dma_ops = {
+	.mapping_error = dmatlb_dma_mapping_error,
+	.map_single = dmatlb_map_single,
+	.unmap_single = dmatlb_unmap_single,
+	.sync_single_for_cpu = dmatlb_sync_single_for_cpu,
+	.sync_single_for_device = dmatlb_sync_single_for_device,
+	.sync_single_range_for_cpu = dmatlb_sync_single_range_for_cpu,
+	.sync_single_range_for_device = dmatlb_sync_single_range_for_device,
+	.sync_sg_for_cpu = dmatlb_sync_sg_for_cpu,
+	.sync_sg_for_device = dmatlb_sync_sg_for_device,
+	.map_sg = dmatlb_map_sg,
+	.unmap_sg = dmatlb_unmap_sg,
 	.dma_supported = NULL,
 };
 
@@ -35,9 +394,43 @@ void __init pci_swiotlb_init(void)
 	       swiotlb = 1;
 	if (swiotlb_force)
 		swiotlb = 1;
+	if (!swiotlb_size)
+		swiotlb_size = DEFAULT_SWIOTLB_SIZE;
 	if (swiotlb) {
-		printk(KERN_INFO "PCI-DMA: Using software bounce buffering for IO (SWIOTLB)\n");
-		swiotlb_init();
-		dma_ops = &swiotlb_dma_ops;
+		printk(KERN_INFO
+       "PCI-DMA: Using software bounce buffering for IO (SWIOTLB)\n");
+
+		increase_mask_zone(swiotlb_size);
+
+		/*
+		 * Get the overflow emergency buffer
+		 */
+		io_tlb_overflow_buffer = alloc_bootmem_low(io_tlb_overflow);
+		if (!io_tlb_overflow_buffer)
+			panic("Cannot allocate SWIOTLB overflow buffer!\n");
+
+		dma_ops = &dmatlb_dma_ops;
+	}
+}
+
+#define COMPAT_IO_TLB_SHIFT 11
+
+static int __init
+setup_io_tlb_npages(char *str)
+{
+	if (isdigit(*str)) {
+		unsigned long slabs;
+		char *e;
+		slabs = simple_strtoul(str, &e, 0);
+		if (!isalpha(*e))
+			swiotlb = memparse(str, &e);
+		else
+			swiotlb_size = slabs  << COMPAT_IO_TLB_SHIFT;
 	}
+	if (*str == ',')
+		++str;
+	if (!strcmp(str, "force"))
+		swiotlb_force = 1;
+	return 1;
 }
+__setup("swiotlb=", setup_io_tlb_npages);
Index: linux/arch/x86/kernel/Makefile
===================================================================
--- linux.orig/arch/x86/kernel/Makefile
+++ linux/arch/x86/kernel/Makefile
@@ -95,5 +95,5 @@ ifeq ($(CONFIG_X86_64),y)
 
         obj-$(CONFIG_GART_IOMMU)	+= pci-gart_64.o aperture_64.o
         obj-$(CONFIG_CALGARY_IOMMU)	+= pci-calgary_64.o tce_64.o
-        obj-$(CONFIG_SWIOTLB)		+= pci-swiotlb_64.o
+	obj-$(CONFIG_SWIOTLB_MASK_ALLOC) += pci-swiotlb_64.o
 endif
Index: linux/arch/x86/Kconfig
===================================================================
--- linux.orig/arch/x86/Kconfig
+++ linux/arch/x86/Kconfig
@@ -437,7 +437,7 @@ config HPET_EMULATE_RTC
 config GART_IOMMU
 	bool "GART IOMMU support" if EMBEDDED
 	default y
-	select SWIOTLB
+	select SWIOTLB_MASK_ALLOC
 	select AGP
 	depends on X86_64 && PCI
 	help
@@ -453,7 +453,7 @@ config GART_IOMMU
 
 config CALGARY_IOMMU
 	bool "IBM Calgary IOMMU support"
-	select SWIOTLB
+	select SWIOTLB_MASK_ALLOC
 	depends on X86_64 && PCI && EXPERIMENTAL
 	help
 	  Support for hardware IOMMUs in IBM's xSeries x366 and x460
@@ -484,7 +484,7 @@ config IOMMU_HELPER
 	def_bool (CALGARY_IOMMU || GART_IOMMU)
 
 # need this always selected by IOMMU for the VIA workaround
-config SWIOTLB
+config SWIOTLB_MASK_ALLOC
 	bool
 	help
 	  Support for software bounce buffers used on x86-64 systems
Index: linux/include/asm-x86/swiotlb.h
===================================================================
--- linux.orig/include/asm-x86/swiotlb.h
+++ linux/include/asm-x86/swiotlb.h
@@ -43,7 +43,7 @@ extern void swiotlb_init(void);
 
 extern int swiotlb_force;
 
-#ifdef CONFIG_SWIOTLB
+#ifdef CONFIG_SWIOTLB_MASK_ALLOC
 extern int swiotlb;
 #else
 #define swiotlb 0
Index: linux/include/linux/page-flags.h
===================================================================
--- linux.orig/include/linux/page-flags.h
+++ linux/include/linux/page-flags.h
@@ -107,6 +107,7 @@
  *         63                            32                              0
  */
 #define PG_uncached		31	/* Page has been mapped as uncached */
+#define PG_swiotlb		30	/* Page in swiotlb */
 #endif
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
