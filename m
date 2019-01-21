Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 19/21] treewide: add checks for the return value of memblock_alloc*()
Date: Mon, 21 Jan 2019 10:04:06 +0200
In-Reply-To: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1548057848-15136-20-git-send-email-rppt@linux.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport <rppt@linux.ibm.com>
List-ID: <linux-mm.kvack.org>

Add check for the return value of memblock_alloc*() functions and call
panic() in case of error.
The panic message repeats the one used by panicing memblock allocators with
adjustment of parameters to include only relevant ones.

The replacement was mostly automated with semantic patches like the one
below with manual massaging of format strings.

@@
expression ptr, size, align;
@@
ptr = memblock_alloc(size, align);
+ if (!ptr)
+ 	panic("%s: Failed to allocate %lu bytes align=0x%lx\n", __func__,
size, align);

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Guo Ren <ren_guo@c-sky.com>             # c-sky
Acked-by: Paul Burton <paul.burton@mips.com>	     # MIPS
Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com> # s390
Reviewed-by: Juergen Gross <jgross@suse.com>         # Xen
---
 arch/alpha/kernel/core_cia.c              |  3 +++
 arch/alpha/kernel/core_marvel.c           |  6 ++++++
 arch/alpha/kernel/pci-noop.c              | 13 +++++++++++--
 arch/alpha/kernel/pci.c                   | 11 ++++++++++-
 arch/alpha/kernel/pci_iommu.c             | 12 ++++++++++++
 arch/arc/mm/highmem.c                     |  4 ++++
 arch/arm/kernel/setup.c                   |  6 ++++++
 arch/arm/mm/mmu.c                         | 14 +++++++++++++-
 arch/arm64/kernel/setup.c                 |  8 +++++---
 arch/arm64/mm/kasan_init.c                | 10 ++++++++++
 arch/c6x/mm/dma-coherent.c                |  4 ++++
 arch/c6x/mm/init.c                        |  3 +++
 arch/csky/mm/highmem.c                    |  5 +++++
 arch/h8300/mm/init.c                      |  3 +++
 arch/m68k/atari/stram.c                   |  4 ++++
 arch/m68k/mm/init.c                       |  3 +++
 arch/m68k/mm/mcfmmu.c                     |  6 ++++++
 arch/m68k/mm/motorola.c                   |  9 +++++++++
 arch/m68k/mm/sun3mmu.c                    |  6 ++++++
 arch/m68k/sun3/sun3dvma.c                 |  3 +++
 arch/microblaze/mm/init.c                 |  8 ++++++--
 arch/mips/cavium-octeon/dma-octeon.c      |  3 +++
 arch/mips/kernel/setup.c                  |  3 +++
 arch/mips/kernel/traps.c                  |  3 +++
 arch/mips/mm/init.c                       |  5 +++++
 arch/nds32/mm/init.c                      | 12 ++++++++++++
 arch/openrisc/mm/ioremap.c                |  8 ++++++--
 arch/powerpc/kernel/dt_cpu_ftrs.c         |  5 +++++
 arch/powerpc/kernel/pci_32.c              |  3 +++
 arch/powerpc/kernel/setup-common.c        |  3 +++
 arch/powerpc/kernel/setup_64.c            |  4 ++++
 arch/powerpc/lib/alloc.c                  |  3 +++
 arch/powerpc/mm/hash_utils_64.c           |  3 +++
 arch/powerpc/mm/mmu_context_nohash.c      |  9 +++++++++
 arch/powerpc/mm/pgtable-book3e.c          | 12 ++++++++++--
 arch/powerpc/mm/pgtable-book3s64.c        |  3 +++
 arch/powerpc/mm/pgtable-radix.c           |  9 ++++++++-
 arch/powerpc/mm/ppc_mmu_32.c              |  3 +++
 arch/powerpc/platforms/pasemi/iommu.c     |  3 +++
 arch/powerpc/platforms/powermac/nvram.c   |  3 +++
 arch/powerpc/platforms/powernv/opal.c     |  3 +++
 arch/powerpc/platforms/powernv/pci-ioda.c |  8 ++++++++
 arch/powerpc/platforms/ps3/setup.c        |  3 +++
 arch/powerpc/sysdev/msi_bitmap.c          |  3 +++
 arch/s390/kernel/setup.c                  | 13 +++++++++++++
 arch/s390/kernel/smp.c                    |  5 ++++-
 arch/s390/kernel/topology.c               |  6 ++++++
 arch/s390/numa/mode_emu.c                 |  3 +++
 arch/s390/numa/numa.c                     |  6 +++++-
 arch/sh/mm/init.c                         |  6 ++++++
 arch/sh/mm/numa.c                         |  4 ++++
 arch/um/drivers/net_kern.c                |  3 +++
 arch/um/drivers/vector_kern.c             |  3 +++
 arch/um/kernel/initrd.c                   |  2 ++
 arch/um/kernel/mem.c                      | 16 ++++++++++++++++
 arch/unicore32/kernel/setup.c             |  4 ++++
 arch/unicore32/mm/mmu.c                   | 15 +++++++++++++--
 arch/x86/kernel/acpi/boot.c               |  3 +++
 arch/x86/kernel/apic/io_apic.c            |  5 +++++
 arch/x86/kernel/e820.c                    |  3 +++
 arch/x86/platform/olpc/olpc_dt.c          |  3 +++
 arch/x86/xen/p2m.c                        | 11 +++++++++--
 arch/xtensa/mm/kasan_init.c               |  4 ++++
 arch/xtensa/mm/mmu.c                      |  3 +++
 drivers/clk/ti/clk.c                      |  3 +++
 drivers/macintosh/smu.c                   |  3 +++
 drivers/of/fdt.c                          |  8 +++++++-
 drivers/of/unittest.c                     |  8 +++++++-
 drivers/xen/swiotlb-xen.c                 |  7 +++++--
 kernel/power/snapshot.c                   |  3 +++
 lib/cpumask.c                             |  3 +++
 mm/kasan/init.c                           | 10 ++++++++--
 mm/sparse.c                               | 19 +++++++++++++++++--
 73 files changed, 409 insertions(+), 28 deletions(-)

diff --git a/arch/alpha/kernel/core_cia.c b/arch/alpha/kernel/core_cia.c
index 466cd44..f489170 100644
--- a/arch/alpha/kernel/core_cia.c
+++ b/arch/alpha/kernel/core_cia.c
@@ -332,6 +332,9 @@ cia_prepare_tbia_workaround(int window)
 
 	/* Use minimal 1K map. */
 	ppte = memblock_alloc(CIA_BROKEN_TBIA_SIZE, 32768);
+	if (!ppte)
+		panic("%s: Failed to allocate %u bytes align=0x%x\n",
+		      __func__, CIA_BROKEN_TBIA_SIZE, 32768);
 	pte = (virt_to_phys(ppte) >> (PAGE_SHIFT - 1)) | 1;
 
 	for (i = 0; i < CIA_BROKEN_TBIA_SIZE / sizeof(unsigned long); ++i)
diff --git a/arch/alpha/kernel/core_marvel.c b/arch/alpha/kernel/core_marvel.c
index c1d0c18..1db9d0e 100644
--- a/arch/alpha/kernel/core_marvel.c
+++ b/arch/alpha/kernel/core_marvel.c
@@ -83,6 +83,9 @@ mk_resource_name(int pe, int port, char *str)
 	
 	sprintf(tmp, "PCI %s PE %d PORT %d", str, pe, port);
 	name = memblock_alloc(strlen(tmp) + 1, SMP_CACHE_BYTES);
+	if (!name)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      strlen(tmp) + 1);
 	strcpy(name, tmp);
 
 	return name;
@@ -118,6 +121,9 @@ alloc_io7(unsigned int pe)
 	}
 
 	io7 = memblock_alloc(sizeof(*io7), SMP_CACHE_BYTES);
+	if (!io7)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(*io7));
 	io7->pe = pe;
 	raw_spin_lock_init(&io7->irq_lock);
 
diff --git a/arch/alpha/kernel/pci-noop.c b/arch/alpha/kernel/pci-noop.c
index 091cff3..ae82061 100644
--- a/arch/alpha/kernel/pci-noop.c
+++ b/arch/alpha/kernel/pci-noop.c
@@ -34,6 +34,9 @@ alloc_pci_controller(void)
 	struct pci_controller *hose;
 
 	hose = memblock_alloc(sizeof(*hose), SMP_CACHE_BYTES);
+	if (!hose)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(*hose));
 
 	*hose_tail = hose;
 	hose_tail = &hose->next;
@@ -44,7 +47,13 @@ alloc_pci_controller(void)
 struct resource * __init
 alloc_resource(void)
 {
-	return memblock_alloc(sizeof(struct resource), SMP_CACHE_BYTES);
+	void *ptr = memblock_alloc(sizeof(struct resource), SMP_CACHE_BYTES);
+
+	if (!ptr)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(struct resource));
+
+	return ptr;
 }
 
 SYSCALL_DEFINE3(pciconfig_iobase, long, which, unsigned long, bus,
@@ -54,7 +63,7 @@ SYSCALL_DEFINE3(pciconfig_iobase, long, which, unsigned long, bus,
 
 	/* from hose or from bus.devfn */
 	if (which & IOBASE_FROM_HOSE) {
-		for (hose = hose_head; hose; hose = hose->next) 
+		for (hose = hose_head; hose; hose = hose->next)
 			if (hose->index == bus)
 				break;
 		if (!hose)
diff --git a/arch/alpha/kernel/pci.c b/arch/alpha/kernel/pci.c
index 9709812..64fbfb0 100644
--- a/arch/alpha/kernel/pci.c
+++ b/arch/alpha/kernel/pci.c
@@ -393,6 +393,9 @@ alloc_pci_controller(void)
 	struct pci_controller *hose;
 
 	hose = memblock_alloc(sizeof(*hose), SMP_CACHE_BYTES);
+	if (!hose)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(*hose));
 
 	*hose_tail = hose;
 	hose_tail = &hose->next;
@@ -403,7 +406,13 @@ alloc_pci_controller(void)
 struct resource * __init
 alloc_resource(void)
 {
-	return memblock_alloc(sizeof(struct resource), SMP_CACHE_BYTES);
+	void *ptr = memblock_alloc(sizeof(struct resource), SMP_CACHE_BYTES);
+
+	if (!ptr)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(struct resource));
+
+	return ptr;
 }
 
 
diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
index e4cf77b..3034d6d 100644
--- a/arch/alpha/kernel/pci_iommu.c
+++ b/arch/alpha/kernel/pci_iommu.c
@@ -80,6 +80,9 @@ iommu_arena_new_node(int nid, struct pci_controller *hose, dma_addr_t base,
 		       "    falling back to system-wide allocation\n",
 		       __func__, nid);
 		arena = memblock_alloc(sizeof(*arena), SMP_CACHE_BYTES);
+		if (!arena)
+			panic("%s: Failed to allocate %zu bytes\n", __func__,
+			      sizeof(*arena));
 	}
 
 	arena->ptes = memblock_alloc_node(sizeof(*arena), align, nid);
@@ -88,12 +91,21 @@ iommu_arena_new_node(int nid, struct pci_controller *hose, dma_addr_t base,
 		       "    falling back to system-wide allocation\n",
 		       __func__, nid);
 		arena->ptes = memblock_alloc(mem_size, align);
+		if (!arena->ptes)
+			panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+			      __func__, mem_size, align);
 	}
 
 #else /* CONFIG_DISCONTIGMEM */
 
 	arena = memblock_alloc(sizeof(*arena), SMP_CACHE_BYTES);
+	if (!arena)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(*arena));
 	arena->ptes = memblock_alloc(mem_size, align);
+	if (!arena->ptes)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, mem_size, align);
 
 #endif /* CONFIG_DISCONTIGMEM */
 
diff --git a/arch/arc/mm/highmem.c b/arch/arc/mm/highmem.c
index 48e7001..11f57e2 100644
--- a/arch/arc/mm/highmem.c
+++ b/arch/arc/mm/highmem.c
@@ -124,6 +124,10 @@ static noinline pte_t * __init alloc_kmap_pgtable(unsigned long kvaddr)
 	pmd_k = pmd_offset(pud_k, kvaddr);
 
 	pte_k = (pte_t *)memblock_alloc_low(PAGE_SIZE, PAGE_SIZE);
+	if (!pte_k)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
+
 	pmd_populate_kernel(&init_mm, pmd_k, pte_k);
 	return pte_k;
 }
diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 375b13f..5d78b6a 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -867,6 +867,9 @@ static void __init request_standard_resources(const struct machine_desc *mdesc)
 		boot_alias_start = phys_to_idmap(start);
 		if (arm_has_idmap_alias() && boot_alias_start != IDMAP_INVALID_ADDR) {
 			res = memblock_alloc(sizeof(*res), SMP_CACHE_BYTES);
+			if (!res)
+				panic("%s: Failed to allocate %zu bytes\n",
+				      __func__, sizeof(*res));
 			res->name = "System RAM (boot alias)";
 			res->start = boot_alias_start;
 			res->end = phys_to_idmap(end);
@@ -875,6 +878,9 @@ static void __init request_standard_resources(const struct machine_desc *mdesc)
 		}
 
 		res = memblock_alloc(sizeof(*res), SMP_CACHE_BYTES);
+		if (!res)
+			panic("%s: Failed to allocate %zu bytes\n", __func__,
+			      sizeof(*res));
 		res->name  = "System RAM";
 		res->start = start;
 		res->end = end;
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index 57de0dd..f3ce341 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -721,7 +721,13 @@ EXPORT_SYMBOL(phys_mem_access_prot);
 
 static void __init *early_alloc(unsigned long sz)
 {
-	return memblock_alloc(sz, sz);
+	void *ptr = memblock_alloc(sz, sz);
+
+	if (!ptr)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, sz, sz);
+
+	return ptr;
 }
 
 static void *__init late_alloc(unsigned long sz)
@@ -994,6 +1000,9 @@ void __init iotable_init(struct map_desc *io_desc, int nr)
 		return;
 
 	svm = memblock_alloc(sizeof(*svm) * nr, __alignof__(*svm));
+	if (!svm)
+		panic("%s: Failed to allocate %zu bytes align=0x%zx\n",
+		      __func__, sizeof(*svm) * nr, __alignof__(*svm));
 
 	for (md = io_desc; nr; md++, nr--) {
 		create_mapping(md);
@@ -1016,6 +1025,9 @@ void __init vm_reserve_area_early(unsigned long addr, unsigned long size,
 	struct static_vm *svm;
 
 	svm = memblock_alloc(sizeof(*svm), __alignof__(*svm));
+	if (!svm)
+		panic("%s: Failed to allocate %zu bytes align=0x%zx\n",
+		      __func__, sizeof(*svm), __alignof__(*svm));
 
 	vm = &svm->vm;
 	vm->addr = (void *)addr;
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index 4b0e123..5c5401f 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -209,6 +209,7 @@ static void __init request_standard_resources(void)
 	struct memblock_region *region;
 	struct resource *res;
 	unsigned long i = 0;
+	size_t res_size;
 
 	kernel_code.start   = __pa_symbol(_text);
 	kernel_code.end     = __pa_symbol(__init_begin - 1);
@@ -216,9 +217,10 @@ static void __init request_standard_resources(void)
 	kernel_data.end     = __pa_symbol(_end - 1);
 
 	num_standard_resources = memblock.memory.cnt;
-	standard_resources = memblock_alloc_low(num_standard_resources *
-					        sizeof(*standard_resources),
-					        SMP_CACHE_BYTES);
+	res_size = num_standard_resources * sizeof(*standard_resources);
+	standard_resources = memblock_alloc_low(res_size, SMP_CACHE_BYTES);
+	if (!standard_resources)
+		panic("%s: Failed to allocate %zu bytes\n", __func__, res_size);
 
 	for_each_memblock(memory, region) {
 		res = &standard_resources[i++];
diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 4b55b15..43d13c7 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -40,6 +40,11 @@ static phys_addr_t __init kasan_alloc_zeroed_page(int node)
 	void *p = memblock_alloc_try_nid(PAGE_SIZE, PAGE_SIZE,
 					      __pa(MAX_DMA_ADDRESS),
 					      MEMBLOCK_ALLOC_KASAN, node);
+	if (!p)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%llx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE, node,
+		      __pa(MAX_DMA_ADDRESS));
+
 	return __pa(p);
 }
 
@@ -48,6 +53,11 @@ static phys_addr_t __init kasan_alloc_raw_page(int node)
 	void *p = memblock_alloc_try_nid_raw(PAGE_SIZE, PAGE_SIZE,
 						__pa(MAX_DMA_ADDRESS),
 						MEMBLOCK_ALLOC_KASAN, node);
+	if (!p)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%llx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE, node,
+		      __pa(MAX_DMA_ADDRESS));
+
 	return __pa(p);
 }
 
diff --git a/arch/c6x/mm/dma-coherent.c b/arch/c6x/mm/dma-coherent.c
index 0be2898..0d3701b 100644
--- a/arch/c6x/mm/dma-coherent.c
+++ b/arch/c6x/mm/dma-coherent.c
@@ -138,6 +138,10 @@ void __init coherent_mem_init(phys_addr_t start, u32 size)
 
 	dma_bitmap = memblock_alloc(BITS_TO_LONGS(dma_pages) * sizeof(long),
 				    sizeof(long));
+	if (!dma_bitmap)
+		panic("%s: Failed to allocate %zu bytes align=0x%zx\n",
+		      __func__, BITS_TO_LONGS(dma_pages) * sizeof(long),
+		      sizeof(long));
 }
 
 static void c6x_dma_sync(struct device *dev, phys_addr_t paddr, size_t size,
diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
index e83c046..fe582c3 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -40,6 +40,9 @@ void __init paging_init(void)
 
 	empty_zero_page      = (unsigned long) memblock_alloc(PAGE_SIZE,
 							      PAGE_SIZE);
+	if (!empty_zero_page)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 
 	/*
 	 * Set up user data space
diff --git a/arch/csky/mm/highmem.c b/arch/csky/mm/highmem.c
index 53b1bfa..3317b774 100644
--- a/arch/csky/mm/highmem.c
+++ b/arch/csky/mm/highmem.c
@@ -141,6 +141,11 @@ static void __init fixrange_init(unsigned long start, unsigned long end,
 			for (; (k < PTRS_PER_PMD) && (vaddr != end); pmd++, k++) {
 				if (pmd_none(*pmd)) {
 					pte = (pte_t *) memblock_alloc_low(PAGE_SIZE, PAGE_SIZE);
+					if (!pte)
+						panic("%s: Failed to allocate %lu bytes align=%lx\n",
+						      __func__, PAGE_SIZE,
+						      PAGE_SIZE);
+
 					set_pmd(pmd, __pmd(__pa(pte)));
 					BUG_ON(pte != pte_offset_kernel(pmd, 0));
 				}
diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index a157890..0f04a5e 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -68,6 +68,9 @@ void __init paging_init(void)
 	 * to a couple of allocated pages.
 	 */
 	empty_zero_page = (unsigned long)memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (!empty_zero_page)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 
 	/*
 	 * Set up SFC/DFC registers (user data space).
diff --git a/arch/m68k/atari/stram.c b/arch/m68k/atari/stram.c
index 6ffc204..6152f9f 100644
--- a/arch/m68k/atari/stram.c
+++ b/arch/m68k/atari/stram.c
@@ -97,6 +97,10 @@ void __init atari_stram_reserve_pages(void *start_mem)
 		pr_debug("atari_stram pool: kernel in ST-RAM, using alloc_bootmem!\n");
 		stram_pool.start = (resource_size_t)memblock_alloc_low(pool_size,
 								       PAGE_SIZE);
+		if (!stram_pool.start)
+			panic("%s: Failed to allocate %lu bytes align=%lx\n",
+			      __func__, pool_size, PAGE_SIZE);
+
 		stram_pool.end = stram_pool.start + pool_size - 1;
 		request_resource(&iomem_resource, &stram_pool);
 		stram_virt_offset = 0;
diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
index 933c33e..8868a4c 100644
--- a/arch/m68k/mm/init.c
+++ b/arch/m68k/mm/init.c
@@ -94,6 +94,9 @@ void __init paging_init(void)
 	high_memory = (void *) end_mem;
 
 	empty_zero_page = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (!empty_zero_page)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 
 	/*
 	 * Set up SFC/DFC registers (user data space).
diff --git a/arch/m68k/mm/mcfmmu.c b/arch/m68k/mm/mcfmmu.c
index 492f953..6cb1e41 100644
--- a/arch/m68k/mm/mcfmmu.c
+++ b/arch/m68k/mm/mcfmmu.c
@@ -44,6 +44,9 @@ void __init paging_init(void)
 	int i;
 
 	empty_zero_page = (void *) memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (!empty_zero_page)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 
 	pg_dir = swapper_pg_dir;
 	memset(swapper_pg_dir, 0, sizeof(swapper_pg_dir));
@@ -51,6 +54,9 @@ void __init paging_init(void)
 	size = num_pages * sizeof(pte_t);
 	size = (size + PAGE_SIZE) & ~(PAGE_SIZE-1);
 	next_pgtable = (unsigned long) memblock_alloc(size, PAGE_SIZE);
+	if (!next_pgtable)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, size, PAGE_SIZE);
 
 	bootmem_end = (next_pgtable + size + PAGE_SIZE) & PAGE_MASK;
 	pg_dir += PAGE_OFFSET >> PGDIR_SHIFT;
diff --git a/arch/m68k/mm/motorola.c b/arch/m68k/mm/motorola.c
index 3f3d0bf..356601b 100644
--- a/arch/m68k/mm/motorola.c
+++ b/arch/m68k/mm/motorola.c
@@ -55,6 +55,9 @@ static pte_t * __init kernel_page_table(void)
 	pte_t *ptablep;
 
 	ptablep = (pte_t *)memblock_alloc_low(PAGE_SIZE, PAGE_SIZE);
+	if (!ptablep)
+		panic("%s: Failed to allocate %lu bytes align=%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 
 	clear_page(ptablep);
 	__flush_page_to_ram(ptablep);
@@ -96,6 +99,9 @@ static pmd_t * __init kernel_ptr_table(void)
 	if (((unsigned long)last_pgtable & ~PAGE_MASK) == 0) {
 		last_pgtable = (pmd_t *)memblock_alloc_low(PAGE_SIZE,
 							   PAGE_SIZE);
+		if (!last_pgtable)
+			panic("%s: Failed to allocate %lu bytes align=%lx\n",
+			      __func__, PAGE_SIZE, PAGE_SIZE);
 
 		clear_page(last_pgtable);
 		__flush_page_to_ram(last_pgtable);
@@ -278,6 +284,9 @@ void __init paging_init(void)
 	 * to a couple of allocated pages
 	 */
 	empty_zero_page = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (!empty_zero_page)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 
 	/*
 	 * Set up SFC/DFC registers
diff --git a/arch/m68k/mm/sun3mmu.c b/arch/m68k/mm/sun3mmu.c
index f736db4..eca1c46 100644
--- a/arch/m68k/mm/sun3mmu.c
+++ b/arch/m68k/mm/sun3mmu.c
@@ -46,6 +46,9 @@ void __init paging_init(void)
 	unsigned long size;
 
 	empty_zero_page = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (!empty_zero_page)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 
 	address = PAGE_OFFSET;
 	pg_dir = swapper_pg_dir;
@@ -56,6 +59,9 @@ void __init paging_init(void)
 	size = (size + PAGE_SIZE) & ~(PAGE_SIZE-1);
 
 	next_pgtable = (unsigned long)memblock_alloc(size, PAGE_SIZE);
+	if (!next_pgtable)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, size, PAGE_SIZE);
 	bootmem_end = (next_pgtable + size + PAGE_SIZE) & PAGE_MASK;
 
 	/* Map whole memory from PAGE_OFFSET (0x0E000000) */
diff --git a/arch/m68k/sun3/sun3dvma.c b/arch/m68k/sun3/sun3dvma.c
index 4d64711..399f3d0 100644
--- a/arch/m68k/sun3/sun3dvma.c
+++ b/arch/m68k/sun3/sun3dvma.c
@@ -269,6 +269,9 @@ void __init dvma_init(void)
 
 	iommu_use = memblock_alloc(IOMMU_TOTAL_ENTRIES * sizeof(unsigned long),
 				   SMP_CACHE_BYTES);
+	if (!iommu_use)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      IOMMU_TOTAL_ENTRIES * sizeof(unsigned long));
 
 	dvma_unmap_iommu(DVMA_START, DVMA_SIZE);
 
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index bd1cd4b..7e97d44 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -374,10 +374,14 @@ void * __ref zalloc_maybe_bootmem(size_t size, gfp_t mask)
 {
 	void *p;
 
-	if (mem_init_done)
+	if (mem_init_done) {
 		p = kzalloc(size, mask);
-	else
+	} else {
 		p = memblock_alloc(size, SMP_CACHE_BYTES);
+		if (!p)
+			panic("%s: Failed to allocate %zu bytes\n",
+			      __func__, size);
+	}
 
 	return p;
 }
diff --git a/arch/mips/cavium-octeon/dma-octeon.c b/arch/mips/cavium-octeon/dma-octeon.c
index e8eb60e..11d5a4e 100644
--- a/arch/mips/cavium-octeon/dma-octeon.c
+++ b/arch/mips/cavium-octeon/dma-octeon.c
@@ -245,6 +245,9 @@ void __init plat_swiotlb_setup(void)
 	swiotlbsize = swiotlb_nslabs << IO_TLB_SHIFT;
 
 	octeon_swiotlb = memblock_alloc_low(swiotlbsize, PAGE_SIZE);
+	if (!octeon_swiotlb)
+		panic("%s: Failed to allocate %zu bytes align=%lx\n",
+		      __func__, swiotlbsize, PAGE_SIZE);
 
 	if (swiotlb_init_with_tbl(octeon_swiotlb, swiotlb_nslabs, 1) == -ENOMEM)
 		panic("Cannot allocate SWIOTLB buffer");
diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
index 8c6c48ed..91bc962 100644
--- a/arch/mips/kernel/setup.c
+++ b/arch/mips/kernel/setup.c
@@ -918,6 +918,9 @@ static void __init resource_init(void)
 			end = HIGHMEM_START - 1;
 
 		res = memblock_alloc(sizeof(struct resource), SMP_CACHE_BYTES);
+		if (!res)
+			panic("%s: Failed to allocate %zu bytes\n", __func__,
+			      sizeof(struct resource));
 
 		res->start = start;
 		res->end = end;
diff --git a/arch/mips/kernel/traps.c b/arch/mips/kernel/traps.c
index 2bbdee5..64b541a 100644
--- a/arch/mips/kernel/traps.c
+++ b/arch/mips/kernel/traps.c
@@ -2292,6 +2292,9 @@ void __init trap_init(void)
 
 		ebase = (unsigned long)
 			memblock_alloc(size, 1 << fls(size));
+		if (!ebase)
+			panic("%s: Failed to allocate %lu bytes align=0x%x\n",
+			      __func__, size, 1 << fls(size));
 
 		/*
 		 * Try to ensure ebase resides in KSeg0 if possible.
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index b521d8e..89e2afc 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -245,6 +245,11 @@ void __init fixrange_init(unsigned long start, unsigned long end,
 				if (pmd_none(*pmd)) {
 					pte = (pte_t *) memblock_alloc_low(PAGE_SIZE,
 									   PAGE_SIZE);
+					if (!pte)
+						panic("%s: Failed to allocate %lu bytes align=%lx\n",
+						      __func__, PAGE_SIZE,
+						      PAGE_SIZE);
+
 					set_pmd(pmd, __pmd((unsigned long)pte));
 					BUG_ON(pte != pte_offset_kernel(pmd, 0));
 				}
diff --git a/arch/nds32/mm/init.c b/arch/nds32/mm/init.c
index d1e521c..1d03633 100644
--- a/arch/nds32/mm/init.c
+++ b/arch/nds32/mm/init.c
@@ -79,6 +79,9 @@ static void __init map_ram(void)
 
 		/* Alloc one page for holding PTE's... */
 		pte = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+		if (!pte)
+			panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+			      __func__, PAGE_SIZE, PAGE_SIZE);
 		set_pmd(pme, __pmd(__pa(pte) + _PAGE_KERNEL_TABLE));
 
 		/* Fill the newly allocated page with PTE'S */
@@ -111,6 +114,9 @@ static void __init fixedrange_init(void)
 	pud = pud_offset(pgd, vaddr);
 	pmd = pmd_offset(pud, vaddr);
 	fixmap_pmd_p = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (!fixmap_pmd_p)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 	set_pmd(pmd, __pmd(__pa(fixmap_pmd_p) + _PAGE_KERNEL_TABLE));
 
 #ifdef CONFIG_HIGHMEM
@@ -123,6 +129,9 @@ static void __init fixedrange_init(void)
 	pud = pud_offset(pgd, vaddr);
 	pmd = pmd_offset(pud, vaddr);
 	pte = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (!pte)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 	set_pmd(pmd, __pmd(__pa(pte) + _PAGE_KERNEL_TABLE));
 	pkmap_page_table = pte;
 #endif /* CONFIG_HIGHMEM */
@@ -148,6 +157,9 @@ void __init paging_init(void)
 
 	/* allocate space for empty_zero_page */
 	zero_page = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (!zero_page)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 	zone_sizes_init();
 
 	empty_zero_page = virt_to_page(zero_page);
diff --git a/arch/openrisc/mm/ioremap.c b/arch/openrisc/mm/ioremap.c
index 051bcb4..a850995 100644
--- a/arch/openrisc/mm/ioremap.c
+++ b/arch/openrisc/mm/ioremap.c
@@ -122,10 +122,14 @@ pte_t __ref *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte;
 
-	if (likely(mem_init_done))
+	if (likely(mem_init_done)) {
 		pte = (pte_t *)get_zeroed_page(GFP_KERNEL);
-	else
+	} else {
 		pte = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+		if (!pte)
+			panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+			      __func__, PAGE_SIZE, PAGE_SIZE);
+	}
 
 	return pte;
 }
diff --git a/arch/powerpc/kernel/dt_cpu_ftrs.c b/arch/powerpc/kernel/dt_cpu_ftrs.c
index 2554824..af6814a 100644
--- a/arch/powerpc/kernel/dt_cpu_ftrs.c
+++ b/arch/powerpc/kernel/dt_cpu_ftrs.c
@@ -1008,6 +1008,11 @@ static int __init dt_cpu_ftrs_scan_callback(unsigned long node, const char
 	of_scan_flat_dt_subnodes(node, count_cpufeatures_subnodes,
 						&nr_dt_cpu_features);
 	dt_cpu_features = memblock_alloc(sizeof(struct dt_cpu_feature) * nr_dt_cpu_features, PAGE_SIZE);
+	if (!dt_cpu_features)
+		panic("%s: Failed to allocate %zu bytes align=0x%lx\n",
+		      __func__,
+		      sizeof(struct dt_cpu_feature) * nr_dt_cpu_features,
+		      PAGE_SIZE);
 
 	cpufeatures_setup_start(isa);
 
diff --git a/arch/powerpc/kernel/pci_32.c b/arch/powerpc/kernel/pci_32.c
index d3f04f2..0417fda 100644
--- a/arch/powerpc/kernel/pci_32.c
+++ b/arch/powerpc/kernel/pci_32.c
@@ -205,6 +205,9 @@ pci_create_OF_bus_map(void)
 
 	of_prop = memblock_alloc(sizeof(struct property) + 256,
 				 SMP_CACHE_BYTES);
+	if (!of_prop)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(struct property) + 256);
 	dn = of_find_node_by_path("/");
 	if (dn) {
 		memset(of_prop, -1, sizeof(struct property) + 256);
diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
index 82be48c..1810f09 100644
--- a/arch/powerpc/kernel/setup-common.c
+++ b/arch/powerpc/kernel/setup-common.c
@@ -461,6 +461,9 @@ void __init smp_setup_cpu_maps(void)
 
 	cpu_to_phys_id = memblock_alloc(nr_cpu_ids * sizeof(u32),
 					__alignof__(u32));
+	if (!cpu_to_phys_id)
+		panic("%s: Failed to allocate %zu bytes align=0x%zx\n",
+		      __func__, nr_cpu_ids * sizeof(u32), __alignof__(u32));
 
 	for_each_node_by_type(dn, "cpu") {
 		const __be32 *intserv;
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index 3dcd779..dd62b05 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -931,6 +931,10 @@ static void __ref init_fallback_flush(void)
 	l1d_flush_fallback_area = memblock_alloc_try_nid(l1d_size * 2,
 						l1d_size, MEMBLOCK_LOW_LIMIT,
 						limit, NUMA_NO_NODE);
+	if (!l1d_flush_fallback_area)
+		panic("%s: Failed to allocate %llu bytes align=0x%llx max_addr=%pa\n",
+		      __func__, l1d_size * 2, l1d_size, &limit);
+
 
 	for_each_possible_cpu(cpu) {
 		struct paca_struct *paca = paca_ptrs[cpu];
diff --git a/arch/powerpc/lib/alloc.c b/arch/powerpc/lib/alloc.c
index dedf88a..ce18087 100644
--- a/arch/powerpc/lib/alloc.c
+++ b/arch/powerpc/lib/alloc.c
@@ -15,6 +15,9 @@ void * __ref zalloc_maybe_bootmem(size_t size, gfp_t mask)
 		p = kzalloc(size, mask);
 	else {
 		p = memblock_alloc(size, SMP_CACHE_BYTES);
+		if (!p)
+			panic("%s: Failed to allocate %zu bytes\n", __func__,
+			      size);
 	}
 	return p;
 }
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index c7d5f48..ddf3b9c 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -915,6 +915,9 @@ static void __init htab_initialize(void)
 		linear_map_hash_slots = memblock_alloc_try_nid(
 				linear_map_hash_count, 1, MEMBLOCK_LOW_LIMIT,
 				ppc64_rma_size,	NUMA_NO_NODE);
+		if (!linear_map_hash_slots)
+			panic("%s: Failed to allocate %lu bytes max_addr=%pa\n",
+			      __func__, linear_map_hash_count, &ppc64_rma_size);
 	}
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
diff --git a/arch/powerpc/mm/mmu_context_nohash.c b/arch/powerpc/mm/mmu_context_nohash.c
index 22d71a58..1945c5f 100644
--- a/arch/powerpc/mm/mmu_context_nohash.c
+++ b/arch/powerpc/mm/mmu_context_nohash.c
@@ -461,10 +461,19 @@ void __init mmu_context_init(void)
 	 * Allocate the maps used by context management
 	 */
 	context_map = memblock_alloc(CTX_MAP_SIZE, SMP_CACHE_BYTES);
+	if (!context_map)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      CTX_MAP_SIZE);
 	context_mm = memblock_alloc(sizeof(void *) * (LAST_CONTEXT + 1),
 				    SMP_CACHE_BYTES);
+	if (!context_mm)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(void *) * (LAST_CONTEXT + 1));
 #ifdef CONFIG_SMP
 	stale_map[boot_cpuid] = memblock_alloc(CTX_MAP_SIZE, SMP_CACHE_BYTES);
+	if (!stale_map[boot_cpuid])
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      CTX_MAP_SIZE);
 
 	cpuhp_setup_state_nocalls(CPUHP_POWERPC_MMU_CTX_PREPARE,
 				  "powerpc/mmu/ctx:prepare",
diff --git a/arch/powerpc/mm/pgtable-book3e.c b/arch/powerpc/mm/pgtable-book3e.c
index 53cbc7d..1032ef7 100644
--- a/arch/powerpc/mm/pgtable-book3e.c
+++ b/arch/powerpc/mm/pgtable-book3e.c
@@ -57,8 +57,16 @@ void vmemmap_remove_mapping(unsigned long start,
 
 static __ref void *early_alloc_pgtable(unsigned long size)
 {
-	return memblock_alloc_try_nid(size, size, MEMBLOCK_LOW_LIMIT,
-				      __pa(MAX_DMA_ADDRESS), NUMA_NO_NODE);
+	void *ptr;
+
+	ptr = memblock_alloc_try_nid(size, size, MEMBLOCK_LOW_LIMIT,
+				     __pa(MAX_DMA_ADDRESS), NUMA_NO_NODE);
+
+	if (!ptr)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx max_addr=%lx\n",
+		      __func__, size, size, __pa(MAX_DMA_ADDRESS));
+
+	return ptr;
 }
 
 /*
diff --git a/arch/powerpc/mm/pgtable-book3s64.c b/arch/powerpc/mm/pgtable-book3s64.c
index 55876b7..68e95f8 100644
--- a/arch/powerpc/mm/pgtable-book3s64.c
+++ b/arch/powerpc/mm/pgtable-book3s64.c
@@ -197,6 +197,9 @@ void __init mmu_partition_table_init(void)
 	BUILD_BUG_ON_MSG((PATB_SIZE_SHIFT > 36), "Partition table size too large.");
 	/* Initialize the Partition Table with no entries */
 	partition_tb = memblock_alloc(patb_size, patb_size);
+	if (!partition_tb)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, patb_size, patb_size);
 
 	/*
 	 * update partition table control register,
diff --git a/arch/powerpc/mm/pgtable-radix.c b/arch/powerpc/mm/pgtable-radix.c
index 29bcea5..6fc05fd 100644
--- a/arch/powerpc/mm/pgtable-radix.c
+++ b/arch/powerpc/mm/pgtable-radix.c
@@ -53,13 +53,20 @@ static __ref void *early_alloc_pgtable(unsigned long size, int nid,
 {
 	phys_addr_t min_addr = MEMBLOCK_LOW_LIMIT;
 	phys_addr_t max_addr = MEMBLOCK_ALLOC_ANYWHERE;
+	void *ptr;
 
 	if (region_start)
 		min_addr = region_start;
 	if (region_end)
 		max_addr = region_end;
 
-	return memblock_alloc_try_nid(size, size, min_addr, max_addr, nid);
+	ptr = memblock_alloc_try_nid(size, size, min_addr, max_addr, nid);
+
+	if (!ptr)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%pa max_addr=%pa\n",
+		      __func__, size, size, nid, &min_addr, &max_addr);
+
+	return ptr;
 }
 
 static int early_map_kernel_page(unsigned long ea, unsigned long pa,
diff --git a/arch/powerpc/mm/ppc_mmu_32.c b/arch/powerpc/mm/ppc_mmu_32.c
index 36a664f..a85b2f4 100644
--- a/arch/powerpc/mm/ppc_mmu_32.c
+++ b/arch/powerpc/mm/ppc_mmu_32.c
@@ -212,6 +212,9 @@ void __init MMU_init_hw(void)
 	 */
 	if ( ppc_md.progress ) ppc_md.progress("hash:find piece", 0x322);
 	Hash = memblock_alloc(Hash_size, Hash_size);
+	if (!Hash)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, Hash_size, Hash_size);
 	_SDR1 = __pa(Hash) | SDR1_LOW_BITS;
 
 	Hash_end = (struct hash_pte *) ((unsigned long)Hash + Hash_size);
diff --git a/arch/powerpc/platforms/pasemi/iommu.c b/arch/powerpc/platforms/pasemi/iommu.c
index f62930f..ab75e70 100644
--- a/arch/powerpc/platforms/pasemi/iommu.c
+++ b/arch/powerpc/platforms/pasemi/iommu.c
@@ -211,6 +211,9 @@ static int __init iob_init(struct device_node *dn)
 	iob_l2_base = memblock_alloc_try_nid_raw(1UL << 21, 1UL << 21,
 					MEMBLOCK_LOW_LIMIT, 0x80000000,
 					NUMA_NO_NODE);
+	if (!iob_l2_base)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx max_addr=%x\n",
+		      __func__, 1UL << 21, 1UL << 21, 0x80000000);
 
 	pr_info("IOBMAP L2 allocated at: %p\n", iob_l2_base);
 
diff --git a/arch/powerpc/platforms/powermac/nvram.c b/arch/powerpc/platforms/powermac/nvram.c
index ae54d7f..e0a1d15 100644
--- a/arch/powerpc/platforms/powermac/nvram.c
+++ b/arch/powerpc/platforms/powermac/nvram.c
@@ -514,6 +514,9 @@ static int __init core99_nvram_setup(struct device_node *dp, unsigned long addr)
 		return -EINVAL;
 	}
 	nvram_image = memblock_alloc(NVRAM_SIZE, SMP_CACHE_BYTES);
+	if (!nvram_image)
+		panic("%s: Failed to allocate %u bytes\n", __func__,
+		      NVRAM_SIZE);
 	nvram_data = ioremap(addr, NVRAM_SIZE*2);
 	nvram_naddrs = 1; /* Make sure we get the correct case */
 
diff --git a/arch/powerpc/platforms/powernv/opal.c b/arch/powerpc/platforms/powernv/opal.c
index 8e157f9..38fb678 100644
--- a/arch/powerpc/platforms/powernv/opal.c
+++ b/arch/powerpc/platforms/powernv/opal.c
@@ -172,6 +172,9 @@ int __init early_init_dt_scan_recoverable_ranges(unsigned long node,
 	 * Allocate a buffer to hold the MC recoverable ranges.
 	 */
 	mc_recoverable_range = memblock_alloc(size, __alignof__(u64));
+	if (!mc_recoverable_range)
+		panic("%s: Failed to allocate %u bytes align=0x%lx\n",
+		      __func__, size, __alignof__(u64));
 
 	for (i = 0; i < mc_recoverable_range_len; i++) {
 		mc_recoverable_range[i].start_addr =
diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c b/arch/powerpc/platforms/powernv/pci-ioda.c
index 1d6406a..4817f15 100644
--- a/arch/powerpc/platforms/powernv/pci-ioda.c
+++ b/arch/powerpc/platforms/powernv/pci-ioda.c
@@ -3727,6 +3727,9 @@ static void __init pnv_pci_init_ioda_phb(struct device_node *np,
 	pr_debug("  PHB-ID  : 0x%016llx\n", phb_id);
 
 	phb = memblock_alloc(sizeof(*phb), SMP_CACHE_BYTES);
+	if (!phb)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(*phb));
 
 	/* Allocate PCI controller */
 	phb->hose = hose = pcibios_alloc_controller(np);
@@ -3773,6 +3776,9 @@ static void __init pnv_pci_init_ioda_phb(struct device_node *np,
 		phb->diag_data_size = PNV_PCI_DIAG_BUF_SIZE;
 
 	phb->diag_data = memblock_alloc(phb->diag_data_size, SMP_CACHE_BYTES);
+	if (!phb->diag_data)
+		panic("%s: Failed to allocate %u bytes\n", __func__,
+		      phb->diag_data_size);
 
 	/* Parse 32-bit and IO ranges (if any) */
 	pci_process_bridge_OF_ranges(hose, np, !hose->global_number);
@@ -3832,6 +3838,8 @@ static void __init pnv_pci_init_ioda_phb(struct device_node *np,
 	pemap_off = size;
 	size += phb->ioda.total_pe_num * sizeof(struct pnv_ioda_pe);
 	aux = memblock_alloc(size, SMP_CACHE_BYTES);
+	if (!aux)
+		panic("%s: Failed to allocate %lu bytes\n", __func__, size);
 	phb->ioda.pe_alloc = aux;
 	phb->ioda.m64_segmap = aux + m64map_off;
 	phb->ioda.m32_segmap = aux + m32map_off;
diff --git a/arch/powerpc/platforms/ps3/setup.c b/arch/powerpc/platforms/ps3/setup.c
index 658bfab..4ce5458 100644
--- a/arch/powerpc/platforms/ps3/setup.c
+++ b/arch/powerpc/platforms/ps3/setup.c
@@ -127,6 +127,9 @@ static void __init prealloc(struct ps3_prealloc *p)
 		return;
 
 	p->address = memblock_alloc(p->size, p->align);
+	if (!p->address)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, p->size, p->align);
 
 	printk(KERN_INFO "%s: %lu bytes at %p\n", p->name, p->size,
 	       p->address);
diff --git a/arch/powerpc/sysdev/msi_bitmap.c b/arch/powerpc/sysdev/msi_bitmap.c
index d45450f..51a679a 100644
--- a/arch/powerpc/sysdev/msi_bitmap.c
+++ b/arch/powerpc/sysdev/msi_bitmap.c
@@ -129,6 +129,9 @@ int __ref msi_bitmap_alloc(struct msi_bitmap *bmp, unsigned int irq_count,
 		bmp->bitmap = kzalloc(size, GFP_KERNEL);
 	else {
 		bmp->bitmap = memblock_alloc(size, SMP_CACHE_BYTES);
+		if (!bmp->bitmap)
+			panic("%s: Failed to allocate %u bytes\n", __func__,
+			      size);
 		/* the bitmap won't be freed from memblock allocator */
 		kmemleak_not_leak(bmp->bitmap);
 	}
diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
index da48397..8f9e7f6 100644
--- a/arch/s390/kernel/setup.c
+++ b/arch/s390/kernel/setup.c
@@ -378,6 +378,10 @@ static void __init setup_lowcore(void)
 	 */
 	BUILD_BUG_ON(sizeof(struct lowcore) != LC_PAGES * PAGE_SIZE);
 	lc = memblock_alloc_low(sizeof(*lc), sizeof(*lc));
+	if (!lc)
+		panic("%s: Failed to allocate %zu bytes align=%zx\n",
+		      __func__, sizeof(*lc), sizeof(*lc));
+
 	lc->restart_psw.mask = PSW_KERNEL_BITS;
 	lc->restart_psw.addr = (unsigned long) restart_int_handler;
 	lc->external_new_psw.mask = PSW_KERNEL_BITS |
@@ -422,6 +426,9 @@ static void __init setup_lowcore(void)
 	 * all CPUs in cast *one* of them does a PSW restart.
 	 */
 	restart_stack = memblock_alloc(THREAD_SIZE, THREAD_SIZE);
+	if (!restart_stack)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, THREAD_SIZE, THREAD_SIZE);
 	restart_stack += STACK_INIT_OFFSET;
 
 	/*
@@ -488,6 +495,9 @@ static void __init setup_resources(void)
 
 	for_each_memblock(memory, reg) {
 		res = memblock_alloc(sizeof(*res), 8);
+		if (!res)
+			panic("%s: Failed to allocate %zu bytes align=0x%x\n",
+			      __func__, sizeof(*res), 8);
 		res->flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM;
 
 		res->name = "System RAM";
@@ -502,6 +512,9 @@ static void __init setup_resources(void)
 				continue;
 			if (std_res->end > res->end) {
 				sub_res = memblock_alloc(sizeof(*sub_res), 8);
+				if (!sub_res)
+					panic("%s: Failed to allocate %zu bytes align=0x%x\n",
+					      __func__, sizeof(*sub_res), 8);
 				*sub_res = *std_res;
 				sub_res->end = res->end;
 				std_res->start = res->end + 1;
diff --git a/arch/s390/kernel/smp.c b/arch/s390/kernel/smp.c
index 9061597..17c626e2 100644
--- a/arch/s390/kernel/smp.c
+++ b/arch/s390/kernel/smp.c
@@ -653,7 +653,7 @@ void __init smp_save_dump_cpus(void)
 	/* Allocate a page as dumping area for the store status sigps */
 	page = memblock_phys_alloc_range(PAGE_SIZE, PAGE_SIZE, 0, 1UL << 31);
 	if (!page)
-		panic("ERROR: Failed to allocate %x bytes below %lx\n",
+		panic("ERROR: Failed to allocate %lx bytes below %lx\n",
 		      PAGE_SIZE, 1UL << 31);
 
 	/* Set multi-threading state to the previous system. */
@@ -765,6 +765,9 @@ void __init smp_detect_cpus(void)
 
 	/* Get CPU information */
 	info = memblock_alloc(sizeof(*info), 8);
+	if (!info)
+		panic("%s: Failed to allocate %zu bytes align=0x%x\n",
+		      __func__, sizeof(*info), 8);
 	smp_get_core_info(info, 1);
 	/* Find boot CPU type */
 	if (sclp.has_core_type) {
diff --git a/arch/s390/kernel/topology.c b/arch/s390/kernel/topology.c
index 8992b04..8964a3f 100644
--- a/arch/s390/kernel/topology.c
+++ b/arch/s390/kernel/topology.c
@@ -520,6 +520,9 @@ static void __init alloc_masks(struct sysinfo_15_1_x *info,
 	nr_masks = max(nr_masks, 1);
 	for (i = 0; i < nr_masks; i++) {
 		mask->next = memblock_alloc(sizeof(*mask->next), 8);
+		if (!mask->next)
+			panic("%s: Failed to allocate %zu bytes align=0x%x\n",
+			      __func__, sizeof(*mask->next), 8);
 		mask = mask->next;
 	}
 }
@@ -538,6 +541,9 @@ void __init topology_init_early(void)
 	if (!MACHINE_HAS_TOPOLOGY)
 		goto out;
 	tl_info = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (!tl_info)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 	info = tl_info;
 	store_topology(info);
 	pr_info("The CPU configuration topology of the machine is: %d %d %d %d %d %d / %d\n",
diff --git a/arch/s390/numa/mode_emu.c b/arch/s390/numa/mode_emu.c
index bfba273..71a12a4 100644
--- a/arch/s390/numa/mode_emu.c
+++ b/arch/s390/numa/mode_emu.c
@@ -313,6 +313,9 @@ static void __ref create_core_to_node_map(void)
 	int i;
 
 	emu_cores = memblock_alloc(sizeof(*emu_cores), 8);
+	if (!emu_cores)
+		panic("%s: Failed to allocate %zu bytes align=0x%x\n",
+		      __func__, sizeof(*emu_cores), 8);
 	for (i = 0; i < ARRAY_SIZE(emu_cores->to_node_id); i++)
 		emu_cores->to_node_id[i] = NODE_ID_FREE;
 }
diff --git a/arch/s390/numa/numa.c b/arch/s390/numa/numa.c
index 2d1271e..8eb9e97 100644
--- a/arch/s390/numa/numa.c
+++ b/arch/s390/numa/numa.c
@@ -92,8 +92,12 @@ static void __init numa_setup_memory(void)
 	} while (cur_base < end_of_dram);
 
 	/* Allocate and fill out node_data */
-	for (nid = 0; nid < MAX_NUMNODES; nid++)
+	for (nid = 0; nid < MAX_NUMNODES; nid++) {
 		NODE_DATA(nid) = memblock_alloc(sizeof(pg_data_t), 8);
+		if (!NODE_DATA(nid))
+			panic("%s: Failed to allocate %zu bytes align=0x%x\n",
+			      __func__, sizeof(pg_data_t), 8);
+	}
 
 	for_each_online_node(nid) {
 		unsigned long start_pfn, end_pfn;
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index a0fa4de..fceefd9 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -128,6 +128,9 @@ static pmd_t * __init one_md_table_init(pud_t *pud)
 		pmd_t *pmd;
 
 		pmd = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+		if (!pmd)
+			panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+			      __func__, PAGE_SIZE, PAGE_SIZE);
 		pud_populate(&init_mm, pud, pmd);
 		BUG_ON(pmd != pmd_offset(pud, 0));
 	}
@@ -141,6 +144,9 @@ static pte_t * __init one_page_table_init(pmd_t *pmd)
 		pte_t *pte;
 
 		pte = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+		if (!pte)
+			panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+			      __func__, PAGE_SIZE, PAGE_SIZE);
 		pmd_populate_kernel(&init_mm, pmd, pte);
 		BUG_ON(pte != pte_offset_kernel(pmd, 0));
 	}
diff --git a/arch/sh/mm/numa.c b/arch/sh/mm/numa.c
index c4bde61..f7e4439 100644
--- a/arch/sh/mm/numa.c
+++ b/arch/sh/mm/numa.c
@@ -43,6 +43,10 @@ void __init setup_bootmem_node(int nid, unsigned long start, unsigned long end)
 	/* Node-local pgdat */
 	NODE_DATA(nid) = memblock_alloc_node(sizeof(struct pglist_data),
 					     SMP_CACHE_BYTES, nid);
+	if (!NODE_DATA(nid))
+		panic("%s: Failed to allocate %zu bytes align=0x%x nid=%d\n",
+		      __func__, sizeof(struct pglist_data), SMP_CACHE_BYTES,
+		      nid);
 
 	NODE_DATA(nid)->node_start_pfn = start_pfn;
 	NODE_DATA(nid)->node_spanned_pages = end_pfn - start_pfn;
diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index d80cfb1..6e5be5f 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -649,6 +649,9 @@ static int __init eth_setup(char *str)
 	}
 
 	new = memblock_alloc(sizeof(*new), SMP_CACHE_BYTES);
+	if (!new)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(*new));
 
 	INIT_LIST_HEAD(&new->list);
 	new->index = n;
diff --git a/arch/um/drivers/vector_kern.c b/arch/um/drivers/vector_kern.c
index 046fa9e..596e705 100644
--- a/arch/um/drivers/vector_kern.c
+++ b/arch/um/drivers/vector_kern.c
@@ -1576,6 +1576,9 @@ static int __init vector_setup(char *str)
 		return 1;
 	}
 	new = memblock_alloc(sizeof(*new), SMP_CACHE_BYTES);
+	if (!new)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(*new));
 	INIT_LIST_HEAD(&new->list);
 	new->unit = n;
 	new->arguments = str;
diff --git a/arch/um/kernel/initrd.c b/arch/um/kernel/initrd.c
index ce169ea..1dcd310 100644
--- a/arch/um/kernel/initrd.c
+++ b/arch/um/kernel/initrd.c
@@ -37,6 +37,8 @@ int __init read_initrd(void)
 	}
 
 	area = memblock_alloc(size, SMP_CACHE_BYTES);
+	if (!area)
+		panic("%s: Failed to allocate %llu bytes\n", __func__, size);
 
 	if (load_initrd(initrd, area, size) == -1)
 		return 0;
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 799b571..99aa11b 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -66,6 +66,10 @@ static void __init one_page_table_init(pmd_t *pmd)
 	if (pmd_none(*pmd)) {
 		pte_t *pte = (pte_t *) memblock_alloc_low(PAGE_SIZE,
 							  PAGE_SIZE);
+		if (!pte)
+			panic("%s: Failed to allocate %lu bytes align=%lx\n",
+			      __func__, PAGE_SIZE, PAGE_SIZE);
+
 		set_pmd(pmd, __pmd(_KERNPG_TABLE +
 					   (unsigned long) __pa(pte)));
 		if (pte != pte_offset_kernel(pmd, 0))
@@ -77,6 +81,10 @@ static void __init one_md_table_init(pud_t *pud)
 {
 #ifdef CONFIG_3_LEVEL_PGTABLES
 	pmd_t *pmd_table = (pmd_t *) memblock_alloc_low(PAGE_SIZE, PAGE_SIZE);
+	if (!pmd_table)
+		panic("%s: Failed to allocate %lu bytes align=%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
+
 	set_pud(pud, __pud(_KERNPG_TABLE + (unsigned long) __pa(pmd_table)));
 	if (pmd_table != pmd_offset(pud, 0))
 		BUG();
@@ -126,6 +134,10 @@ static void __init fixaddr_user_init( void)
 
 	fixrange_init( FIXADDR_USER_START, FIXADDR_USER_END, swapper_pg_dir);
 	v = (unsigned long) memblock_alloc_low(size, PAGE_SIZE);
+	if (!v)
+		panic("%s: Failed to allocate %lu bytes align=%lx\n",
+		      __func__, size, PAGE_SIZE);
+
 	memcpy((void *) v , (void *) FIXADDR_USER_START, size);
 	p = __pa(v);
 	for ( ; size > 0; size -= PAGE_SIZE, vaddr += PAGE_SIZE,
@@ -146,6 +158,10 @@ void __init paging_init(void)
 
 	empty_zero_page = (unsigned long *) memblock_alloc_low(PAGE_SIZE,
 							       PAGE_SIZE);
+	if (!empty_zero_page)
+		panic("%s: Failed to allocate %lu bytes align=%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
+
 	for (i = 0; i < ARRAY_SIZE(zones_size); i++)
 		zones_size[i] = 0;
 
diff --git a/arch/unicore32/kernel/setup.c b/arch/unicore32/kernel/setup.c
index 4b0cb68..d3239cf 100644
--- a/arch/unicore32/kernel/setup.c
+++ b/arch/unicore32/kernel/setup.c
@@ -207,6 +207,10 @@ request_standard_resources(struct meminfo *mi)
 			continue;
 
 		res = memblock_alloc_low(sizeof(*res), SMP_CACHE_BYTES);
+		if (!res)
+			panic("%s: Failed to allocate %zu bytes align=%x\n",
+			      __func__, sizeof(*res), SMP_CACHE_BYTES);
+
 		res->name  = "System RAM";
 		res->start = mi->bank[i].start;
 		res->end   = mi->bank[i].start + mi->bank[i].size - 1;
diff --git a/arch/unicore32/mm/mmu.c b/arch/unicore32/mm/mmu.c
index a402192..aa2060b 100644
--- a/arch/unicore32/mm/mmu.c
+++ b/arch/unicore32/mm/mmu.c
@@ -145,8 +145,13 @@ static pte_t * __init early_pte_alloc(pmd_t *pmd, unsigned long addr,
 		unsigned long prot)
 {
 	if (pmd_none(*pmd)) {
-		pte_t *pte = memblock_alloc(PTRS_PER_PTE * sizeof(pte_t),
-					    PTRS_PER_PTE * sizeof(pte_t));
+		size_t size = PTRS_PER_PTE * sizeof(pte_t);
+		pte_t *pte = memblock_alloc(size, size);
+
+		if (!pte)
+			panic("%s: Failed to allocate %zu bytes align=%zx\n",
+			      __func__, size, size);
+
 		__pmd_populate(pmd, __pa(pte) | prot);
 	}
 	BUG_ON(pmd_bad(*pmd));
@@ -349,6 +354,9 @@ static void __init devicemaps_init(void)
 	 * Allocate the vector page early.
 	 */
 	vectors = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (!vectors)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 
 	for (addr = VMALLOC_END; addr; addr += PGDIR_SIZE)
 		pmd_clear(pmd_off_k(addr));
@@ -426,6 +434,9 @@ void __init paging_init(void)
 
 	/* allocate the zero page. */
 	zero_page = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (!zero_page)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		      __func__, PAGE_SIZE, PAGE_SIZE);
 
 	bootmem_init();
 
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 2624de1..8dcbf68 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -935,6 +935,9 @@ static int __init acpi_parse_hpet(struct acpi_table_header *table)
 #define HPET_RESOURCE_NAME_SIZE 9
 	hpet_res = memblock_alloc(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE,
 				  SMP_CACHE_BYTES);
+	if (!hpet_res)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE);
 
 	hpet_res->name = (void *)&hpet_res[1];
 	hpet_res->flags = IORESOURCE_MEM;
diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
index 2953bbf..397bfc8 100644
--- a/arch/x86/kernel/apic/io_apic.c
+++ b/arch/x86/kernel/apic/io_apic.c
@@ -2579,6 +2579,8 @@ static struct resource * __init ioapic_setup_resources(void)
 	n *= nr_ioapics;
 
 	mem = memblock_alloc(n, SMP_CACHE_BYTES);
+	if (!mem)
+		panic("%s: Failed to allocate %lu bytes\n", __func__, n);
 	res = (void *)mem;
 
 	mem += sizeof(struct resource) * nr_ioapics;
@@ -2623,6 +2625,9 @@ void __init io_apic_init_mappings(void)
 #endif
 			ioapic_phys = (unsigned long)memblock_alloc(PAGE_SIZE,
 								    PAGE_SIZE);
+			if (!ioapic_phys)
+				panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+				      __func__, PAGE_SIZE, PAGE_SIZE);
 			ioapic_phys = __pa(ioapic_phys);
 		}
 		set_fixmap_nocache(idx, ioapic_phys);
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 9c0eb54..1f18ec0 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -1095,6 +1095,9 @@ void __init e820__reserve_resources(void)
 
 	res = memblock_alloc(sizeof(*res) * e820_table->nr_entries,
 			     SMP_CACHE_BYTES);
+	if (!res)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(*res) * e820_table->nr_entries);
 	e820_res = res;
 
 	for (i = 0; i < e820_table->nr_entries; i++) {
diff --git a/arch/x86/platform/olpc/olpc_dt.c b/arch/x86/platform/olpc/olpc_dt.c
index b4ab779..dad3b60 100644
--- a/arch/x86/platform/olpc/olpc_dt.c
+++ b/arch/x86/platform/olpc/olpc_dt.c
@@ -141,6 +141,9 @@ void * __init prom_early_alloc(unsigned long size)
 		 * wasted bootmem) and hand off chunks of it to callers.
 		 */
 		res = memblock_alloc(chunk_size, SMP_CACHE_BYTES);
+		if (!res)
+			panic("%s: Failed to allocate %lu bytes\n", __func__,
+			      chunk_size);
 		BUG_ON(!res);
 		prom_early_allocated += chunk_size;
 		memset(res, 0, chunk_size);
diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
index 055e37e..95ce9b5 100644
--- a/arch/x86/xen/p2m.c
+++ b/arch/x86/xen/p2m.c
@@ -181,8 +181,15 @@ static void p2m_init_identity(unsigned long *p2m, unsigned long pfn)
 
 static void * __ref alloc_p2m_page(void)
 {
-	if (unlikely(!slab_is_available()))
-		return memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+	if (unlikely(!slab_is_available())) {
+		void *ptr = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
+
+		if (!ptr)
+			panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+			      __func__, PAGE_SIZE, PAGE_SIZE);
+
+		return ptr;
+	}
 
 	return (void *)__get_free_page(GFP_KERNEL);
 }
diff --git a/arch/xtensa/mm/kasan_init.c b/arch/xtensa/mm/kasan_init.c
index 4852848..41047ca 100644
--- a/arch/xtensa/mm/kasan_init.c
+++ b/arch/xtensa/mm/kasan_init.c
@@ -45,6 +45,10 @@ static void __init populate(void *start, void *end)
 	pmd_t *pmd = pmd_offset(pgd, vaddr);
 	pte_t *pte = memblock_alloc(n_pages * sizeof(pte_t), PAGE_SIZE);
 
+	if (!pte)
+		panic("%s: Failed to allocate %zu bytes align=0x%lx\n",
+		      __func__, n_pages * sizeof(pte_t), PAGE_SIZE);
+
 	pr_debug("%s: %p - %p\n", __func__, start, end);
 
 	for (i = j = 0; i < n_pmds; ++i) {
diff --git a/arch/xtensa/mm/mmu.c b/arch/xtensa/mm/mmu.c
index a4dcfd3..2fb7d11 100644
--- a/arch/xtensa/mm/mmu.c
+++ b/arch/xtensa/mm/mmu.c
@@ -32,6 +32,9 @@ static void * __init init_pmd(unsigned long vaddr, unsigned long n_pages)
 		 __func__, vaddr, n_pages);
 
 	pte = memblock_alloc_low(n_pages * sizeof(pte_t), PAGE_SIZE);
+	if (!pte)
+		panic("%s: Failed to allocate %zu bytes align=%lx\n",
+		      __func__, n_pages * sizeof(pte_t), PAGE_SIZE);
 
 	for (i = 0; i < n_pages; ++i)
 		pte_clear(NULL, 0, pte + i);
diff --git a/drivers/clk/ti/clk.c b/drivers/clk/ti/clk.c
index d0cd585..5d7fb2e 100644
--- a/drivers/clk/ti/clk.c
+++ b/drivers/clk/ti/clk.c
@@ -351,6 +351,9 @@ void __init omap2_clk_legacy_provider_init(int index, void __iomem *mem)
 	struct clk_iomap *io;
 
 	io = memblock_alloc(sizeof(*io), SMP_CACHE_BYTES);
+	if (!io)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(*io));
 
 	io->mem = mem;
 
diff --git a/drivers/macintosh/smu.c b/drivers/macintosh/smu.c
index 42cf68d..6a84412 100644
--- a/drivers/macintosh/smu.c
+++ b/drivers/macintosh/smu.c
@@ -493,6 +493,9 @@ int __init smu_init (void)
 	}
 
 	smu = memblock_alloc(sizeof(struct smu_device), SMP_CACHE_BYTES);
+	if (!smu)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      sizeof(struct smu_device));
 
 	spin_lock_init(&smu->lock);
 	INIT_LIST_HEAD(&smu->cmd_list);
diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
index 7099c65..796460c 100644
--- a/drivers/of/fdt.c
+++ b/drivers/of/fdt.c
@@ -1185,7 +1185,13 @@ int __init __weak early_init_dt_reserve_memory_arch(phys_addr_t base,
 
 static void * __init early_init_dt_alloc_memory_arch(u64 size, u64 align)
 {
-	return memblock_alloc(size, align);
+	void *ptr = memblock_alloc(size, align);
+
+	if (!ptr)
+		panic("%s: Failed to allocate %llu bytes align=0x%llx\n",
+		      __func__, size, align);
+
+	return ptr;
 }
 
 bool __init early_init_dt_verify(void *params)
diff --git a/drivers/of/unittest.c b/drivers/of/unittest.c
index 8442738..10f6599 100644
--- a/drivers/of/unittest.c
+++ b/drivers/of/unittest.c
@@ -2234,7 +2234,13 @@ static struct device_node *overlay_base_root;
 
 static void * __init dt_alloc_memory(u64 size, u64 align)
 {
-	return memblock_alloc(size, align);
+	void *ptr = memblock_alloc(size, align);
+
+	if (!ptr)
+		panic("%s: Failed to allocate %llu bytes align=0x%llx\n",
+		      __func__, size, align);
+
+	return ptr;
 }
 
 /*
diff --git a/drivers/xen/swiotlb-xen.c b/drivers/xen/swiotlb-xen.c
index 989cf87..d3e49f1 100644
--- a/drivers/xen/swiotlb-xen.c
+++ b/drivers/xen/swiotlb-xen.c
@@ -214,10 +214,13 @@ int __ref xen_swiotlb_init(int verbose, bool early)
 	/*
 	 * Get IO TLB memory from any location.
 	 */
-	if (early)
+	if (early) {
 		xen_io_tlb_start = memblock_alloc(PAGE_ALIGN(bytes),
 						  PAGE_SIZE);
-	else {
+		if (!xen_io_tlb_start)
+			panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+			      __func__, PAGE_ALIGN(bytes), PAGE_SIZE);
+	} else {
 #define SLABS_PER_PAGE (1 << (PAGE_SHIFT - IO_TLB_SHIFT))
 #define IO_TLB_MIN_SLABS ((1<<20) >> IO_TLB_SHIFT)
 		while ((SLABS_PER_PAGE << order) > IO_TLB_MIN_SLABS) {
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 4802b03..f08a1e4 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -965,6 +965,9 @@ void __init __register_nosave_region(unsigned long start_pfn,
 		/* This allocation cannot fail */
 		region = memblock_alloc(sizeof(struct nosave_region),
 					SMP_CACHE_BYTES);
+		if (!region)
+			panic("%s: Failed to allocate %zu bytes\n", __func__,
+			      sizeof(struct nosave_region));
 	}
 	region->start_pfn = start_pfn;
 	region->end_pfn = end_pfn;
diff --git a/lib/cpumask.c b/lib/cpumask.c
index 087a3e9..0cb672e 100644
--- a/lib/cpumask.c
+++ b/lib/cpumask.c
@@ -165,6 +165,9 @@ EXPORT_SYMBOL(zalloc_cpumask_var);
 void __init alloc_bootmem_cpumask_var(cpumask_var_t *mask)
 {
 	*mask = memblock_alloc(cpumask_size(), SMP_CACHE_BYTES);
+	if (!*mask)
+		panic("%s: Failed to allocate %u bytes\n", __func__,
+		      cpumask_size());
 }
 
 /**
diff --git a/mm/kasan/init.c b/mm/kasan/init.c
index 45a1b5e..af907d8 100644
--- a/mm/kasan/init.c
+++ b/mm/kasan/init.c
@@ -83,8 +83,14 @@ static inline bool kasan_early_shadow_page_entry(pte_t pte)
 
 static __init void *early_alloc(size_t size, int node)
 {
-	return memblock_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
-					MEMBLOCK_ALLOC_ACCESSIBLE, node);
+	void *ptr = memblock_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
+					   MEMBLOCK_ALLOC_ACCESSIBLE, node);
+
+	if (!ptr)
+		panic("%s: Failed to allocate %zu bytes align=%zx nid=%d from=%llx\n",
+		      __func__, size, size, node, (u64)__pa(MAX_DMA_ADDRESS));
+
+	return ptr;
 }
 
 static void __ref zero_pte_populate(pmd_t *pmd, unsigned long addr,
diff --git a/mm/sparse.c b/mm/sparse.c
index 7ea5dc6..ad94242 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -65,11 +65,15 @@ static noinline struct mem_section __ref *sparse_index_alloc(int nid)
 	unsigned long array_size = SECTIONS_PER_ROOT *
 				   sizeof(struct mem_section);
 
-	if (slab_is_available())
+	if (slab_is_available()) {
 		section = kzalloc_node(array_size, GFP_KERNEL, nid);
-	else
+	} else {
 		section = memblock_alloc_node(array_size, SMP_CACHE_BYTES,
 					      nid);
+		if (!section)
+			panic("%s: Failed to allocate %lu bytes nid=%d\n",
+			      __func__, array_size, nid);
+	}
 
 	return section;
 }
@@ -218,6 +222,9 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
 		size = sizeof(struct mem_section*) * NR_SECTION_ROOTS;
 		align = 1 << (INTERNODE_CACHE_SHIFT);
 		mem_section = memblock_alloc(size, align);
+		if (!mem_section)
+			panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+			      __func__, size, align);
 	}
 #endif
 
@@ -411,6 +418,10 @@ struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid,
 	map = memblock_alloc_try_nid(size,
 					  PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
 					  MEMBLOCK_ALLOC_ACCESSIBLE, nid);
+	if (!map)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%lx\n",
+		      __func__, size, PAGE_SIZE, nid, __pa(MAX_DMA_ADDRESS));
+
 	return map;
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
@@ -425,6 +436,10 @@ static void __init sparse_buffer_init(unsigned long size, int nid)
 		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
 						__pa(MAX_DMA_ADDRESS),
 						MEMBLOCK_ALLOC_ACCESSIBLE, nid);
+	if (!sparsemap_buf)
+		panic("%s: Failed to allocate %lu bytes align=0x%lx nid=%d from=%lx\n",
+		      __func__, size, PAGE_SIZE, nid, __pa(MAX_DMA_ADDRESS));
+
 	sparsemap_buf_end = sparsemap_buf + size;
 }
 
-- 
2.7.4
