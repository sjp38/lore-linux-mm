From: Andi Kleen <andi@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [6/13] Core maskable allocator
Message-Id: <20080307090716.9D3E91B419C@basil.firstfloor.org>
Date: Fri,  7 Mar 2008 10:07:16 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is the core code of the maskable allocator. Introduction
appended.

Background:

The 16MB Linux ZONE_DMA has some long standing problems on
x86. Traditionally it was designed only for ISA dma which is limited to
24bit (16MB). This means it has a fixed 16MB size.

On 32bit i386 with its limited virtual memory space the next zone is
lowmem with ~900MB (on default split) which works for a lot of devices,
but not all.  But on x86-64 the next zone is only 4GB (DMA32) which is too
big for quite a lot more devices (typically 30,31 or 28bit limitations).

While the DMA zone is in a true VM zone and could be in theory used for
any user allocations in practice the VM has a concept called lower zone
protection to avoid low memory deadlocks that keeps ZONE_DMA nearly
always free unless the caller specifies GFP_DMA directly. This means
in practice it does not participate in the rest of the automatic VM
balancing and its memory is essentially reserved.

Then there is another pool used on x86-64: the swiotlb pool. It is 64MB
by default and used to bounce buffer in the pci DMA API in the low level
drivers for any devices that have 32bit limitations (very common)

Swiotlb and the DMA zone already interact. For consistent mappings swiotlb
will already allocate from both the DMA zone and from the swiotlb pool as
needed. On the other hand swiotlb is a truly separate pool not directly
visible to the normal zone balancing (although it happens to be in the
DMA32 zone). In practice ZONE_DMA behaves very similar in that respect.

Driver interfaces:

When drivers need DMA able memory they typically use the pci_*/dma_*
interfaces which allow specifying device masks.   There are two interfaces
here:

dma_alloc_coherent/pci_alloc_consistent to get a block of coherent
memory honouring a device DMA mask and mapped into an IOMMU as needed.
And pci_map_*/dma_map_* to remap an arbitary block to the DMA mask of
the device and into the IOMMU.

Both ways have their own disadvantages: coherent mappings can have some
bad performance penalties and high setup costs on some platforms which
are not full IO coherent, so they are not encouraged for high volume
driver data.  And pci/dma_map_* will always bounce buffer on the common
x86 swiotlb case so it might be quite expensive. Also on a lot of IOMMU
implementations (in particularly x86 swiotlb/pci-gart) pci/dma_map_*
does not support remapping to any DMA masks smaller than 32bit so it
cannot actually be used for ISA or any other device with <32bit DMA mask.

Then there is the old style way of directly telling the allocators
what memory you need by using GFP_DMA or GFP_DMA32 and then later using
bounce less pci/dma_map_*. That also has its own set of problems: first
GFP_DMA varies between architectures. On x86 it is always 16MB, on IA64
4GB, on some other architectures it doesn't exist at all or has other
sizes. GFP_DMA32 often doesn't exist at all (although it can be often
replaced with GFP_KERNEL on 32bit platforms).  This means any caller
needs to have knowledge about its platform which is often non portable.

Then the other problem is that it these are only single bits into small
fixed zones. So for example if a user has a 30bit DMA zone limit on 64bit
they have no other choice than to use GFP_DMA and when they need more than
16MB of memory they lose.  On the other hand on a lot of other boxes which
don't have any devices with <4GB dma masks ZONE_DMA is just wasted memory.

Then GFP_DMA is also not a very clean interface. It is usually
not documented what device mask is really needed. Also some driver
authors misunderstand it as meaning "required for any DMA" which is
not correct. And often it actually requires dma masks larger than 24bit
(16MB) so the fixed 24bit on x86 is limiting.

The pci_alloc_consistent implementation on x86 also has more problems:
usually it cannot use an IOMMU to remap the dma memory so they actually
have to allocate memory with physical addresses according to the dma mask
of the passed device. All they can do for this is to map it to GFP_DMA
(16MB small), GFP_DMA32 (big, but sometimes too big) or by getting
it from the swiotlb pool. It also attempts to get fitting memory from
the main allocator. That works mostly, but has bad corner cases and is
quite inelegant.

In practice this leads to various unfortunate situations: either the 64bit
system has upto 100MB of reserved memory wasted (ZONE_DMA + swiotlb),
but does not have any devices that require bouncing to 16MB or 4GB.

Or the system has devices that need bouncing to <4GB, but the pools in
their default size are too small and can overflow. There are various
hac^wworkarounds in drivers for this problem, but it still causes
problems for users.  The ZONE_DMA can also not be enlarged because a 
lot of drivers "know" that it is only 16MB and expect 16MB memory from it.

On 32bit x86 the problem is a little less severe because of the 900MB
ZONE_NORMAL which fits most devices, but there are still some problems
with more obscure devices with sufficiently small DMA masks. And ISA
devices still fit in badly.

Requirements for a solution:

There is clearly a need for a new better low memory bounce pool on x86.
It must be larger than 16MB and actually be variable sized. Also the
driver interfaces are inadequate. All DMA memory allocation should
specify what mask they actually need. That allows to extend the pool
and use a single pool for multiple masks.

The new pool must be isolated from the rest of the VM. Otherwise it
cannot be safely used in any device driver paths who cannot necessarily
safely allocate memory (e.g. the block write out path is not allowed to
do this to avoid deadlocks while swapping) The current effective pools
(ZONE_DMA, swiotlb) are already isolated in practice so this won't make
much difference.

Proposed solution:

I chose to implement a new "maskable memory" allocator to solve these
problems. The existing page buddy allocator is not really suited for
this because the data structures don't allow cheap allocation by physical 
address boundary. 

The allocator has a separate pool of memory that it grabs at boot
using the bootmem allocator. The memory is part of the lowest zone,
but practically invisible to the normal page allocator or VM.

The allocator is very simple: it works with pages and uses a bitmap to 
find memory. It also uses a simple rotating cursor through the bitmap.
It is very similar to the allocators used by the various IOMMU 
implementations.  While this is not a true O(1) allocator, in practice
it tends to find free pages very quickly and it is quite flexible.
Also it makes it very simple to allocate below arbitary address boundaries.
It has one advantage over buddy in that it doesn't require all
blocks to be size of power of two. It only rounds to pages. So especially 
larger blocks tend to have less overhead.

The allocator knows how to fall back to the other zones if 
the mask is sufficiently big enough, so it can be used for 
arbitrary masks.

I chose to only implement a page mask allocator only, not "kmalloc_mask",
because the various drivers I looked at actually tended to allocate 
quite large objects towards a page. Also if a sub page allocator 
is really needed there are several existing ones that could be 
relatively easily adopted (mm/dmapool.c or the lib/bitmap.c allocator)
on top of an page allocator.

The maskable allocator's pool is variable sized and the user can set 
it to any size needed (upto 2GB currently). The default sizing 
heuristics are for now the same as in the old code: by default
all free memory below 16MB is put into the pool (in practice that
is only ~8MB or so usable because the kernel is loaded there too) 
and swiotlb is needed another 64MB of low memory are reserved too.
The user can override this using the command line.
Any other subsystems can also increase the memory reservation
(but this currently has to happen early while bootmem is still active)

In the future I hope to make this more flexible. In particular
the low memory could not be fully reserved, but only put into
the "moveable" zone and then later as devices are discovered
and e.g. block devices are set up this pre reservation could
be actually reserved. This would then actually allow to use
a lot of the ~100MB that currently go to waste on x86-64.  But
so far that is not implemented yet.

Quirks:

The maskable allocator is able to sleep (for freeing
of other maskable allocations). It currently does this
using a simple timeout before it fails. This needs more evaluation on how 
well it really works under low memory conditions.

I added quite a lot of statistics counters for now to better evaluate
it. Some of them might be later removed.

There is currently no higher priority pool for GFP_ATOMIC.
In general memory pressure on the mask allocator should be less
because normal user space doesn't directly allocate from it.
That is why I didn't bother implementing it right now.
If its absence is a problem it could be added later.

Signed-off-by: Andi Kleen <ak@suse.de>

---
 Documentation/DocBook/kernel-api.tmpl |    1 
 Documentation/kernel-parameters.txt   |    3 
 include/linux/gfp.h                   |   52 +++
 include/linux/page-flags.h            |    5 
 mm/Makefile                           |    1 
 mm/mask-alloc.c                       |  504 ++++++++++++++++++++++++++++++++++
 mm/page_alloc.c                       |    4 
 7 files changed, 565 insertions(+), 5 deletions(-)

Index: linux/mm/Makefile
===================================================================
--- linux.orig/mm/Makefile
+++ linux/mm/Makefile
@@ -33,4 +33,5 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
+obj-$(CONFIG_MASK_ALLOC) += mask-alloc.o
 
Index: linux/mm/mask-alloc.c
===================================================================
--- /dev/null
+++ linux/mm/mask-alloc.c
@@ -0,0 +1,504 @@
+/*
+ * Generic management of low memory zone to allocate memory with a address mask.
+ *
+ * The maskable pool is reserved inside another zone, but managed by a
+ * specialized bitmap allocator. The allocator is not O(1) (searches
+ * the bitmap with a last use hint) but should be fast enough for
+ * normal purposes.  The advantage of the allocator is that it can
+ * allocate based on a mask.
+ *
+ * The allocator could be improved, but it's better to keep
+ * things simple for now and there are relatively few users
+ * which are usually not that speed critical. Also for simple
+ * repetive allocation patterns it should be approximately usually
+ * O(1) anyways due to the rotating cursor in the bitmap.
+ *
+ * This allocator should be only used by architectures with reasonably
+ * continuous physical memory at least for the low normal zone.
+ *
+ * Note book:
+ * Right now there are no high priority reservations (__GFP_HIGH). Iff
+ * they are needed it would be possible to reserve some very low memory
+ * for those.
+ *
+ * Copyright 2007, 2008 Andi Kleen, SUSE Labs.
+ * Subject to the GNU Public License v.2 only.
+ */
+
+#include <linux/mm.h>
+#include <linux/gfp.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/bitops.h>
+#include <linux/string.h>
+#include <linux/wait.h>
+#include <linux/bootmem.h>
+#include <linux/module.h>
+#include <linux/fault-inject.h>
+#include <linux/ctype.h>
+#include <linux/kallsyms.h>
+#include "internal.h"
+
+#define BITS_PER_PAGE (PAGE_SIZE * 8)
+
+#define MASK_ZONE_LIMIT (2U<<30) /* 2GB max for now */
+
+#define Mprintk(x...)
+#define Mprint_symbol(x...)
+
+static int force_mask __read_mostly;
+static DECLARE_WAIT_QUEUE_HEAD(mask_zone_wait);
+unsigned long mask_timeout __read_mostly = 5*HZ;
+
+/*
+ * The mask_bitmap maintains all the pages in the mask pool.
+ * It is reversed (lowest pfn has the highest index)
+ * to make reverse search easier.
+ * All accesses are protected by the mask_bitmap_lock
+ */
+static DEFINE_SPINLOCK(mask_bitmap_lock);
+static unsigned long *mask_bitmap;
+static unsigned long mask_max_pfn;
+
+static inline unsigned pfn_to_maskbm_index(unsigned long pfn)
+{
+	return mask_max_pfn - pfn;
+}
+
+static inline unsigned maskbm_index_to_pfn(unsigned index)
+{
+	return mask_max_pfn - index;
+}
+
+static unsigned wait_for_mask_free(unsigned left)
+{
+	DEFINE_WAIT(wait);
+	prepare_to_wait(&mask_zone_wait, &wait, TASK_UNINTERRUPTIBLE);
+	left = schedule_timeout(left);
+	finish_wait(&mask_zone_wait, &wait);
+	return left;
+}
+
+/* First try normal zones if possible. */
+static struct page *
+alloc_higher_pages(gfp_t gfp_mask, unsigned order, unsigned long pfn)
+{
+	struct page *p = NULL;
+	if (pfn > mask_max_pfn) {
+#ifdef CONFIG_ZONE_DMA32
+		if (pfn <= (0xffffffff >> PAGE_SHIFT)) {
+			p = alloc_pages(gfp_mask|GFP_DMA32|__GFP_NOWARN,
+						order);
+			if (p && page_to_pfn(p) >= pfn) {
+				__free_pages(p, order);
+				p = NULL;
+			}
+		}
+#endif
+		p = alloc_pages(gfp_mask|__GFP_NOWARN, order);
+		if (p && page_to_pfn(p) >= pfn) {
+			__free_pages(p, order);
+			p = NULL;
+		}
+	}
+	return p;
+}
+
+static unsigned long alloc_mask(int pages, unsigned long max)
+{
+	static unsigned long next_bit;
+	unsigned long offset, flags, start, pfn;
+	int k;
+
+	if (max >= mask_max_pfn)
+		max = mask_max_pfn;
+
+	start = mask_max_pfn - max;
+
+	spin_lock_irqsave(&mask_bitmap_lock, flags);
+	offset = -1L;
+
+	if (next_bit >= start && next_bit + pages < (mask_max_pfn - (max>>1))) {
+		offset = find_next_zero_string(mask_bitmap, next_bit,
+					       mask_max_pfn, pages);
+		if (offset != -1L)
+			count_vm_events(MASK_BITMAP_SKIP, offset - next_bit);
+	}
+	if (offset == -1L) {
+		offset = find_next_zero_string(mask_bitmap, start,
+					mask_max_pfn, pages);
+		if (offset != -1L)
+			count_vm_events(MASK_BITMAP_SKIP, offset - start);
+	}
+	if (offset != -1L) {
+		for (k = 0; k < pages; k++) {
+			BUG_ON(test_bit(offset + k, mask_bitmap));
+			set_bit(offset + k, mask_bitmap);
+		}
+		next_bit = offset + pages;
+		if (next_bit >= mask_max_pfn)
+			next_bit = start;
+	}
+	spin_unlock_irqrestore(&mask_bitmap_lock, flags);
+	if (offset == -1L)
+		return -1L;
+
+	offset += pages - 1;
+	pfn = maskbm_index_to_pfn(offset);
+
+	BUG_ON(maskbm_index_to_pfn(offset) != pfn);
+	return pfn;
+}
+
+/**
+ * alloc_pages_mask - Alloc page(s) in a specific address range.
+ * @gfp:      Standard GFP mask. See get_free_pages for a list valid flags.
+ * @size:     Allocate size worth of pages. Rounded up to PAGE_SIZE.
+ * @mask:     Memory must fit into mask physical address.
+ *
+ * Returns a struct page *
+ *
+ * Manage dedicated maskable low memory zone. This zone are isolated
+ * from the normal zones. This is only a single continuous zone.
+ * The main difference to the standard allocator is that it tries
+ * to allocate memory with an physical address fitting in the passed mask.
+ *
+ * Warning: the size is in bytes, not in order like get_free_pages.
+ */
+struct page *
+alloc_pages_mask(gfp_t gfp, unsigned size, u64 mask)
+{
+	unsigned long max_pfn = mask >> PAGE_SHIFT;
+	unsigned pages = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	struct page *p;
+	unsigned left = (gfp & __GFP_REPEAT) ? ~0 : mask_timeout, oleft;
+	unsigned order = get_order(size);
+
+	BUG_ON(size < MASK_MIN_SIZE);	/* You likely passed order by mistake */
+	BUG_ON(gfp & (__GFP_DMA|__GFP_DMA32|__GFP_COMP));
+
+	/* Add fault injection here */
+
+again:
+	count_vm_event(MASK_ALLOC);
+	if (!force_mask) {
+		/* First try normal allocation in suitable zones
+		 * RED-PEN if size fits very badly in PS<<order don't do this?
+		 */
+		p = alloc_higher_pages(gfp, order, max_pfn);
+
+		/*
+		 * If the mask covers everything don't bother with the low zone
+		 * This way we avoid running out of low memory on a higher zones
+		 * OOM too.
+		 */
+		if (p != NULL || max_pfn >= max_low_pfn) {
+			count_vm_event(MASK_HIGHER);
+			count_vm_events(MASK_HIGH_WASTE,
+					(PAGE_SIZE << order) - size);
+			return p;
+		}
+	}
+
+	might_sleep_if(gfp & __GFP_WAIT);
+	do {
+		int i;
+		long pfn;
+
+		/* Implement waiter fairness queueing here? */
+
+		pfn = alloc_mask(pages, max_pfn);
+		if (pfn != -1L) {
+			p = pfn_to_page(pfn);
+
+			Mprintk("mask page %lx size %d mask %Lx\n",
+			       po, size, mask);
+
+			BUG_ON(pfn + pages > mask_max_pfn);
+
+			if (page_prep_struct(p))
+				goto again;
+
+			kernel_map_pages(p, pages, 1);
+
+			for (i = 0; i < pages; i++) {
+				struct page *n = p + i;
+				BUG_ON(!test_bit(pfn_to_maskbm_index(pfn+i),
+						mask_bitmap));
+				BUG_ON(!PageMaskAlloc(n));
+				arch_alloc_page(n, 0);
+				if (gfp & __GFP_ZERO)
+					clear_page(page_address(n));
+			}
+
+			count_vm_events(MASK_LOW_WASTE, pages*PAGE_SIZE-size);
+			return p;
+		}
+
+		if (!(gfp & __GFP_WAIT))
+			break;
+
+		oleft = left;
+		left = wait_for_mask_free(left);
+		count_vm_events(MASK_WAIT, left - oleft);
+	} while (left > 0);
+
+	if (!(gfp & __GFP_NOWARN)) {
+		printk(KERN_ERR
+		"%s: Cannot allocate maskable memory size %u gfp %x mask %Lx\n",
+				current->comm, size, gfp, mask);
+		dump_stack();
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(alloc_pages_mask);
+
+/**
+ * get_pages_mask - Allocate page(s) in specified address range.
+ * @gfp:      GFP mask, see get_free_pages for a list.
+ * @size:     Bytes to allocate (will be rounded up to pages)
+ * @mask:     Page must be located in mask physical address.
+ * Returns the virtual address of the page.
+ *
+ * Manage dedicated maskable low memory zone. This zone are isolated
+ * from the normal zones. This is only a single continuous zone.
+ * The main difference to the standard allocator is that it tries
+ * to allocate memory with an physical address fitting in the passed mask.
+ *
+ * Warning: the size is in bytes, not in order like get_free_pages.
+ */
+void *get_pages_mask(gfp_t gfp, unsigned size, u64 mask)
+{
+	struct page *p = alloc_pages_mask(gfp, size, mask);
+	if (!p)
+		return NULL;
+	return page_address(p);
+}
+EXPORT_SYMBOL(get_pages_mask);
+
+/**
+ * __free_pages_mask - Free pages allocated with get_pages_mask
+ * @page:  First struct page * to free
+ * @size:  Size in bytes.
+ * All pages allocated with alloc/get_pages_mask must be freed
+ * by the respective free.*mask functions.
+ */
+void __free_pages_mask(struct page *page, unsigned size)
+{
+	unsigned long pfn;
+	int i;
+	unsigned pages;
+
+	BUG_ON(size < MASK_MIN_SIZE); /* You likely passed order by mistake */
+	if (!PageMaskAlloc(page)) {
+		__free_pages(page, get_order(size));
+		return;
+	}
+
+	if (!put_page_testzero(page))
+		return;
+
+	count_vm_event(MASK_FREE);
+
+	pfn = page_to_pfn(page);
+	pages = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	kernel_map_pages(page, pages, 0);
+	for (i = 0; i < pages; i++) {
+		struct page *p = page + i;
+		if (free_pages_check(p, 0))
+			bad_page(p);
+		arch_free_page(p, 0);
+		BUG_ON(!PageMaskAlloc(p));
+		if (!test_and_clear_bit(pfn_to_maskbm_index(pfn + i),
+						mask_bitmap))
+			BUG();
+	}
+
+	Mprintk("mask free %lx size %u from ", pfn, size);
+	Mprint_symbol("%s\n", __builtin_return_address(0));
+	wake_up(&mask_zone_wait);
+}
+EXPORT_SYMBOL(__free_pages_mask);
+
+void free_pages_mask(void *mem, unsigned size)
+{
+	__free_pages_mask(virt_to_page(mem), size);
+}
+EXPORT_SYMBOL(free_pages_mask);
+
+static long mask_zone_size __initdata = -1L;
+
+static int __init setup_maskzone(char *s)
+{
+	do {
+		if (isdigit(*s)) {
+			mask_zone_size = memparse(s, &s);
+		} else if (!strncmp(s, "force", 5)) {
+			force_mask = 1;
+			s += 5;
+		} else
+			return -EINVAL;
+		if (*s == ',')
+			++s;
+	} while (*s);
+	return 0;
+}
+early_param("maskzone", setup_maskzone);
+
+/* Two level bitmap to keep track where we got memory from bootmem */
+#define NUM_BM_BITMAPS ((MASK_ZONE_LIMIT >> PAGE_SHIFT) / BITS_PER_PAGE)
+static unsigned long *alloc_bm[NUM_BM_BITMAPS] __initdata;
+
+static __init void mark_page(void *adr)
+{
+	unsigned long pfn = virt_to_phys(adr) >> PAGE_SHIFT;
+	unsigned i = pfn / BITS_PER_PAGE;
+	if (!alloc_bm[i])
+		alloc_bm[i] = alloc_bootmem_low(PAGE_SIZE);
+	__set_bit(pfn % BITS_PER_PAGE, alloc_bm[i]);
+}
+
+static __init int page_is_marked(unsigned long pfn)
+{
+	unsigned i = pfn / BITS_PER_PAGE;
+	return test_bit(pfn % BITS_PER_PAGE, alloc_bm[i]);
+}
+
+static __init void *boot_mask_page(void *adr)
+{
+	adr = __alloc_bootmem_nopanic(PAGE_SIZE, PAGE_SIZE,
+				      (unsigned long)adr);
+	if (!adr) {
+		printk(KERN_ERR "FAILED to allocate page for maskable zone\n");
+		return NULL;
+	}
+
+	mark_page(adr);
+	return adr;
+}
+
+static void __init init_mask_bitmap(void *adr)
+{
+	long mask_bitmap_bytes;
+
+	if (mask_bitmap) {
+		unsigned old_size = (mask_max_pfn + BITS_PER_LONG) / 8;
+		free_bootmem(virt_to_phys(mask_bitmap), old_size);
+	}
+
+	if (adr)
+		mask_max_pfn = virt_to_phys(adr) >> PAGE_SHIFT;
+
+	printk(KERN_INFO "Setting maskable low memory zone to %lu MB\n",
+			virt_to_phys(adr) >> 20);
+
+	mask_bitmap_bytes = (mask_max_pfn + BITS_PER_LONG) / 8;
+	mask_bitmap = alloc_bootmem(mask_bitmap_bytes);
+	memset(mask_bitmap, 0xff, mask_bitmap_bytes);
+}
+
+static void __init __increase_mask_zone(unsigned long size)
+{
+	void *adr = NULL;
+	long got = 0;
+
+	while (got < size) {
+		adr = boot_mask_page(adr);
+		if (!adr) {
+			printk(KERN_ERR
+		"increase_mask_zone failed at %lx\n", got);
+			break;
+		}
+		got += PAGE_SIZE;
+		if (virt_to_phys(adr) >= MASK_ZONE_LIMIT-PAGE_SIZE)
+			break;
+	}
+	init_mask_bitmap(adr);
+}
+
+void __init increase_mask_zone(unsigned long size)
+{
+	/*
+	 * When the user set an explicit zone size ignore any implicit
+	 * increases.
+	 */
+	if (mask_zone_size > 0 || size == 0)
+		return;
+	__increase_mask_zone(size);
+}
+
+/* Get memory for the low mask zone from bootmem */
+void __init init_mask_zone(unsigned long boundary)
+{
+	void *adr = NULL;
+	long got = 0;
+
+	/*
+	 * Grab upto boundary first unless the user set an explicit size.
+	 * This emulates the traditional DMA zone; actual size varying
+	 * depends on whatever is already there.
+	 */
+	if (mask_zone_size == -1L) {
+		for (adr = 0;; got += PAGE_SIZE) {
+			adr = boot_mask_page(adr);
+			if (!adr)
+				break;
+			if (virt_to_phys(adr) >= boundary - PAGE_SIZE)
+				break;
+		}
+		init_mask_bitmap(adr);
+	}
+
+	if (mask_zone_size > MASK_ZONE_LIMIT || mask_zone_size < -1L)
+		mask_zone_size = MASK_ZONE_LIMIT;
+
+	if (mask_zone_size > 0)
+		__increase_mask_zone(mask_zone_size);
+}
+
+static __init void prep_free_pg(unsigned pfn)
+{
+	struct page *p = pfn_to_page(pfn);
+	p->flags = 0;
+	__SetPageMaskAlloc(p);
+	__clear_bit(pfn_to_maskbm_index(pfn), mask_bitmap);
+	reset_page_mapcount(p);
+	set_page_count(p, 0);
+}
+
+void __init prepare_mask_zone(void)
+{
+	int i;
+	long marked = 0;
+
+	/* Free the pages previously gotten from bootmem */
+	for (i = 0; i < mask_max_pfn; i++) {
+		if (page_is_marked(i)) {
+			prep_free_pg(i);
+			marked++;
+		}
+	}
+
+	/* Now free the bitmap to the maskable zone too */
+	for (i = 0; i < ARRAY_SIZE(alloc_bm); i++) {
+		if (alloc_bm[i]) {
+			prep_free_pg(page_to_pfn(virt_to_page(alloc_bm[i])));
+			marked++;
+		}
+	}
+
+#if 1
+	for (i = 0; i <= mask_max_pfn; i++) {
+		struct page *p = pfn_to_page(i);
+		if (!PageMaskAlloc(p))
+			continue;
+		if (page_count(p))
+			panic("pfn %x count %d\n", i, page_count(p));
+		if (test_bit(pfn_to_maskbm_index(i), mask_bitmap))
+			panic("pfn %x already allocated\n", i);
+	}
+#endif
+
+	printk(KERN_INFO "Maskable zone upto %luMB with %luMB free\n",
+	       mask_max_pfn >> (20 - PAGE_SHIFT), marked >> (20 - PAGE_SHIFT));
+}
Index: linux/include/linux/gfp.h
===================================================================
--- linux.orig/include/linux/gfp.h
+++ linux/include/linux/gfp.h
@@ -214,14 +214,56 @@ extern unsigned long get_zeroed_page(gfp
 #define __get_free_page(gfp_mask) \
 		__get_free_pages((gfp_mask),0)
 
-#define __get_dma_pages(gfp_mask, order) \
-		__get_free_pages((gfp_mask) | GFP_DMA,(order))
-
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
 extern void free_hot_page(struct page *page);
 extern void free_cold_page(struct page *page);
 
+#include <asm/dma.h>  /* For TRAD_DMA_MASK/MAX_DMA_ADDRESS */
+
+#ifdef CONFIG_MASK_ALLOC
+extern struct page *alloc_pages_mask(gfp_t gfp_mask, unsigned size,
+					u64 mask);
+extern void *get_pages_mask(gfp_t gfp_mask, unsigned size,
+					u64 mask);
+extern void __free_pages_mask(struct page *page, unsigned size);
+extern void free_pages_mask(void *addr, unsigned size);
+
+/* Legacy interface. To be removed */
+static inline unsigned long __get_dma_pages(gfp_t gfp, unsigned order)
+{
+	unsigned size = PAGE_SIZE << order;
+	return (unsigned long)get_pages_mask(gfp, size, TRAD_DMA_MASK);
+}
+
+#define MASK_MIN_SIZE 16
+
+#else
+
+/*
+ * Architectures without mask alloc support continue using their dma zone
+ * (if they have one).
+ */
+#define gfp_mask(m) ((__pa(MAX_DMA_ADDRESS - 1) & (m)) ? 0 : __GFP_DMA)
+
+#define alloc_pages_mask(gfp, size, mask) \
+	__alloc_pages((gfp) | gfp_mask(mask), get_order(size))
+#define get_pages_mask(gfp, size, mask) \
+	__get_free_pages(gfp | gfp_mask(mask), get_order(size))
+#define __free_pages_mask(p, s) __free_pages(p, get_order(s))
+#define free_pages_mask(a, s) free_pages((unsigned long)addr, get_order(s))
+
+#define __get_dma_pages(gfp_mask, order) \
+		__get_free_pages((gfp_mask) | GFP_DMA, order)
+
+#endif
+
+#define get_page_mask(gfp, mask) get_pages_mask(gfp, PAGE_SIZE, mask)
+#define alloc_page_mask(gfp, mask) alloc_pages_mask(gfp, PAGE_SIZE, mask)
+
+#define __free_page_mask(page) __free_pages_mask(page, 0)
+#define free_page_mask(addr) free_pages_mask(addr, PAGE_SIZE)
+
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr),0)
 
@@ -230,4 +272,8 @@ void drain_zone_pages(struct zone *zone,
 void drain_all_pages(void);
 void drain_local_pages(void *dummy);
 
+void init_mask_zone(unsigned long trad);
+void increase_mask_zone(unsigned long size);
+void prepare_mask_zone(void);
+
 #endif /* __LINUX_GFP_H */
Index: linux/include/linux/page-flags.h
===================================================================
--- linux.orig/include/linux/page-flags.h
+++ linux/include/linux/page-flags.h
@@ -89,6 +89,7 @@
 #define PG_mappedtodisk		16	/* Has blocks allocated on-disk */
 #define PG_reclaim		17	/* To be reclaimed asap */
 #define PG_buddy		19	/* Page is free, on buddy lists */
+#define PG_mask_alloc		20	/* Page managed by the Mask allocator */
 
 /* PG_readahead is only used for file reads; PG_reclaim is only for writes */
 #define PG_readahead		PG_reclaim /* Reminder to do async read-ahead */
@@ -256,6 +257,10 @@ static inline void SetPageUptodate(struc
 #define __SetPageCompound(page)	__set_bit(PG_compound, &(page)->flags)
 #define __ClearPageCompound(page) __clear_bit(PG_compound, &(page)->flags)
 
+#define PageMaskAlloc(page)	test_bit(PG_mask_alloc, &(page)->flags)
+#define __SetPageMaskAlloc(page)	__set_bit(PG_mask_alloc, &(page)->flags)
+#define __ClearPageMaskAlloc(page) __clear_bit(PG_mask_alloc, &(page)->flags)
+
 /*
  * PG_reclaim is used in combination with PG_compound to mark the
  * head and tail of a compound page
Index: linux/Documentation/kernel-parameters.txt
===================================================================
--- linux.orig/Documentation/kernel-parameters.txt
+++ linux/Documentation/kernel-parameters.txt
@@ -2116,6 +2116,9 @@ and is between 256 and 4096 characters. 
 	norandmaps	Don't use address space randomization
 			Equivalent to echo 0 > /proc/sys/kernel/randomize_va_space
 
+	maskzone=size[MG] Set size of maskable DMA zone to size.
+		 force	Always allocate from the mask zone (for testing)
+
 ______________________________________________________________________
 
 TODO:
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -500,7 +500,7 @@ static void __free_pages_ok(struct page 
 	int reserved = 0;
 
 	for (i = 0 ; i < (1 << order) ; ++i)
-		reserved += free_pages_check(page + i, 0);
+		reserved += free_pages_check(page + i, 1 << PG_mask_alloc);
 	if (reserved)
 		return;
 
@@ -937,7 +937,7 @@ static void free_hot_cold_page(struct pa
 
 	if (PageAnon(page))
 		page->mapping = NULL;
-	if (free_pages_check(page, 0))
+	if (free_pages_check(page, 1 << PG_mask_alloc))
 		return;
 
 	if (!PageHighMem(page))
Index: linux/Documentation/DocBook/kernel-api.tmpl
===================================================================
--- linux.orig/Documentation/DocBook/kernel-api.tmpl
+++ linux/Documentation/DocBook/kernel-api.tmpl
@@ -164,6 +164,7 @@ X!Ilib/string.c
 !Emm/memory.c
 !Emm/vmalloc.c
 !Imm/page_alloc.c
+!Emm/mask-alloc.c
 !Emm/mempool.c
 !Emm/dmapool.c
 !Emm/page-writeback.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
