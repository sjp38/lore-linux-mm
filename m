Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62CB66B0006
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 17:07:26 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id b5-v6so7484393otk.21
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 14:07:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b67-v6si2845447oia.105.2018.10.04.14.07.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 14:07:23 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w94L4AiC013887
	for <linux-mm@kvack.org>; Thu, 4 Oct 2018 17:07:22 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mws733bxm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Oct 2018 17:07:19 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 4 Oct 2018 22:07:17 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] memblock: stop using implicit alignement to SMP_CACHE_BYTES
Date: Fri,  5 Oct 2018 00:07:04 +0300
Message-Id: <1538687224-17535-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-um@lists.infradead.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

When a memblock allocation APIs are called with align = 0, the alignment is
implicitly set to SMP_CACHE_BYTES.

Replace all such uses of memblock APIs with the 'align' parameter explicitly
set to SMP_CACHE_BYTES and stop implicit alignment assignment in the
memblock internal allocation functions.

For the case when memblock APIs are used via helper functions, e.g. like
iommu_arena_new_node() in Alpha, the helper functions were detected with
Coccinelle's help and then manually examined and updated where appropriate.

The direct memblock APIs users were updated using the semantic patch below:

@@
expression size, min_addr, max_addr, nid;
@@
(
|
- memblock_alloc_try_nid_raw(size, 0, min_addr, max_addr, nid)
+ memblock_alloc_try_nid_raw(size, SMP_CACHE_BYTES, min_addr, max_addr,
nid)
|
- memblock_alloc_try_nid_nopanic(size, 0, min_addr, max_addr, nid)
+ memblock_alloc_try_nid_nopanic(size, SMP_CACHE_BYTES, min_addr, max_addr,
nid)
|
- memblock_alloc_try_nid(size, 0, min_addr, max_addr, nid)
+ memblock_alloc_try_nid(size, SMP_CACHE_BYTES, min_addr, max_addr, nid)
|
- memblock_alloc(size, 0)
+ memblock_alloc(size, SMP_CACHE_BYTES)
|
- memblock_alloc_raw(size, 0)
+ memblock_alloc_raw(size, SMP_CACHE_BYTES)
|
- memblock_alloc_from(size, 0, min_addr)
+ memblock_alloc_from(size, SMP_CACHE_BYTES, min_addr)
|
- memblock_alloc_nopanic(size, 0)
+ memblock_alloc_nopanic(size, SMP_CACHE_BYTES)
|
- memblock_alloc_low(size, 0)
+ memblock_alloc_low(size, SMP_CACHE_BYTES)
|
- memblock_alloc_low_nopanic(size, 0)
+ memblock_alloc_low_nopanic(size, SMP_CACHE_BYTES)
|
- memblock_alloc_from_nopanic(size, 0, min_addr)
+ memblock_alloc_from_nopanic(size, SMP_CACHE_BYTES, min_addr)
|
- memblock_alloc_node(size, 0, nid)
+ memblock_alloc_node(size, SMP_CACHE_BYTES, nid)
)

Suggested-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/alpha/kernel/core_apecs.c            |  3 ++-
 arch/alpha/kernel/core_lca.c              |  3 ++-
 arch/alpha/kernel/core_marvel.c           |  4 ++--
 arch/alpha/kernel/core_mcpcia.c           |  6 +++--
 arch/alpha/kernel/core_t2.c               |  2 +-
 arch/alpha/kernel/core_titan.c            |  6 +++--
 arch/alpha/kernel/core_tsunami.c          |  6 +++--
 arch/alpha/kernel/core_wildfire.c         |  6 +++--
 arch/alpha/kernel/pci-noop.c              |  4 ++--
 arch/alpha/kernel/pci.c                   |  4 ++--
 arch/alpha/kernel/pci_iommu.c             |  4 ++--
 arch/arm/kernel/setup.c                   |  4 ++--
 arch/arm/mach-omap2/omap_hwmod.c          |  8 ++++---
 arch/arm64/kernel/setup.c                 |  2 +-
 arch/ia64/kernel/mca.c                    |  4 ++--
 arch/ia64/mm/tlb.c                        |  6 +++--
 arch/ia64/sn/kernel/io_common.c           |  4 +++-
 arch/ia64/sn/kernel/setup.c               |  5 ++--
 arch/m68k/sun3/sun3dvma.c                 |  2 +-
 arch/microblaze/mm/init.c                 |  2 +-
 arch/mips/kernel/setup.c                  |  2 +-
 arch/powerpc/kernel/pci_32.c              |  3 ++-
 arch/powerpc/lib/alloc.c                  |  2 +-
 arch/powerpc/mm/mmu_context_nohash.c      |  7 +++---
 arch/powerpc/platforms/powermac/nvram.c   |  2 +-
 arch/powerpc/platforms/powernv/pci-ioda.c |  6 ++---
 arch/powerpc/sysdev/msi_bitmap.c          |  2 +-
 arch/um/drivers/net_kern.c                |  2 +-
 arch/um/drivers/vector_kern.c             |  2 +-
 arch/um/kernel/initrd.c                   |  2 +-
 arch/unicore32/kernel/setup.c             |  2 +-
 arch/x86/kernel/acpi/boot.c               |  2 +-
 arch/x86/kernel/apic/io_apic.c            |  2 +-
 arch/x86/kernel/e820.c                    |  3 ++-
 arch/x86/platform/olpc/olpc_dt.c          |  2 +-
 arch/xtensa/platforms/iss/network.c       |  2 +-
 drivers/clk/ti/clk.c                      |  2 +-
 drivers/firmware/memmap.c                 |  3 ++-
 drivers/macintosh/smu.c                   |  2 +-
 drivers/of/of_reserved_mem.c              |  1 +
 include/linux/memblock.h                  |  3 ++-
 init/main.c                               | 13 +++++++----
 kernel/power/snapshot.c                   |  3 ++-
 lib/cpumask.c                             |  2 +-
 mm/memblock.c                             |  8 -------
 mm/page_alloc.c                           |  6 +++--
 mm/percpu.c                               | 39 ++++++++++++++++---------------
 mm/sparse.c                               |  3 ++-
 48 files changed, 118 insertions(+), 95 deletions(-)

diff --git a/arch/alpha/kernel/core_apecs.c b/arch/alpha/kernel/core_apecs.c
index 1bf3eef..6df765f 100644
--- a/arch/alpha/kernel/core_apecs.c
+++ b/arch/alpha/kernel/core_apecs.c
@@ -346,7 +346,8 @@ apecs_init_arch(void)
 	 * Window 1 is direct access 1GB at 1GB
 	 * Window 2 is scatter-gather 8MB at 8MB (for isa)
 	 */
-	hose->sg_isa = iommu_arena_new(hose, 0x00800000, 0x00800000, 0);
+	hose->sg_isa = iommu_arena_new(hose, 0x00800000, 0x00800000,
+				       SMP_CACHE_BYTES);
 	hose->sg_pci = NULL;
 	__direct_map_base = 0x40000000;
 	__direct_map_size = 0x40000000;
diff --git a/arch/alpha/kernel/core_lca.c b/arch/alpha/kernel/core_lca.c
index 81c0c43..57e0750 100644
--- a/arch/alpha/kernel/core_lca.c
+++ b/arch/alpha/kernel/core_lca.c
@@ -275,7 +275,8 @@ lca_init_arch(void)
 	 * Note that we do not try to save any of the DMA window CSRs
 	 * before setting them, since we cannot read those CSRs on LCA.
 	 */
-	hose->sg_isa = iommu_arena_new(hose, 0x00800000, 0x00800000, 0);
+	hose->sg_isa = iommu_arena_new(hose, 0x00800000, 0x00800000,
+				       SMP_CACHE_BYTES);
 	hose->sg_pci = NULL;
 	__direct_map_base = 0x40000000;
 	__direct_map_size = 0x40000000;
diff --git a/arch/alpha/kernel/core_marvel.c b/arch/alpha/kernel/core_marvel.c
index 8a568c4..c1d0c18 100644
--- a/arch/alpha/kernel/core_marvel.c
+++ b/arch/alpha/kernel/core_marvel.c
@@ -82,7 +82,7 @@ mk_resource_name(int pe, int port, char *str)
 	char *name;
 	
 	sprintf(tmp, "PCI %s PE %d PORT %d", str, pe, port);
-	name = memblock_alloc(strlen(tmp) + 1, 0);
+	name = memblock_alloc(strlen(tmp) + 1, SMP_CACHE_BYTES);
 	strcpy(name, tmp);
 
 	return name;
@@ -117,7 +117,7 @@ alloc_io7(unsigned int pe)
 		return NULL;
 	}
 
-	io7 = memblock_alloc(sizeof(*io7), 0);
+	io7 = memblock_alloc(sizeof(*io7), SMP_CACHE_BYTES);
 	io7->pe = pe;
 	raw_spin_lock_init(&io7->irq_lock);
 
diff --git a/arch/alpha/kernel/core_mcpcia.c b/arch/alpha/kernel/core_mcpcia.c
index b1549db..74b1d01 100644
--- a/arch/alpha/kernel/core_mcpcia.c
+++ b/arch/alpha/kernel/core_mcpcia.c
@@ -364,9 +364,11 @@ mcpcia_startup_hose(struct pci_controller *hose)
 	 * Window 1 is scatter-gather (up to) 1GB at 1GB (for pci)
 	 * Window 2 is direct access 2GB at 2GB
 	 */
-	hose->sg_isa = iommu_arena_new(hose, 0x00800000, 0x00800000, 0);
+	hose->sg_isa = iommu_arena_new(hose, 0x00800000, 0x00800000,
+				       SMP_CACHE_BYTES);
 	hose->sg_pci = iommu_arena_new(hose, 0x40000000,
-				       size_for_memory(0x40000000), 0);
+				       size_for_memory(0x40000000),
+				       SMP_CACHE_BYTES);
 
 	__direct_map_base = 0x80000000;
 	__direct_map_size = 0x80000000;
diff --git a/arch/alpha/kernel/core_t2.c b/arch/alpha/kernel/core_t2.c
index 2c00b61..98d5b6f 100644
--- a/arch/alpha/kernel/core_t2.c
+++ b/arch/alpha/kernel/core_t2.c
@@ -351,7 +351,7 @@ t2_sg_map_window2(struct pci_controller *hose,
 
 	/* Note we can only do 1 SG window, as the other is for direct, so
 	   do an ISA SG area, especially for the floppy. */
-	hose->sg_isa = iommu_arena_new(hose, base, length, 0);
+	hose->sg_isa = iommu_arena_new(hose, base, length, SMP_CACHE_BYTES);
 	hose->sg_pci = NULL;
 
 	temp = (base & 0xfff00000UL) | ((base + length - 1) >> 20);
diff --git a/arch/alpha/kernel/core_titan.c b/arch/alpha/kernel/core_titan.c
index 9755159..2a2820f 100644
--- a/arch/alpha/kernel/core_titan.c
+++ b/arch/alpha/kernel/core_titan.c
@@ -316,10 +316,12 @@ titan_init_one_pachip_port(titan_pachip_port *port, int index)
 	 * Window 1 is direct access 1GB at 2GB
 	 * Window 2 is scatter-gather 1GB at 3GB
 	 */
-	hose->sg_isa = iommu_arena_new(hose, 0x00800000, 0x00800000, 0);
+	hose->sg_isa = iommu_arena_new(hose, 0x00800000, 0x00800000,
+				       SMP_CACHE_BYTES);
 	hose->sg_isa->align_entry = 8; /* 64KB for ISA */
 
-	hose->sg_pci = iommu_arena_new(hose, 0xc0000000, 0x40000000, 0);
+	hose->sg_pci = iommu_arena_new(hose, 0xc0000000, 0x40000000,
+				       SMP_CACHE_BYTES);
 	hose->sg_pci->align_entry = 4; /* Titan caches 4 PTEs at a time */
 
 	port->wsba[0].csr = hose->sg_isa->dma_base | 3;
diff --git a/arch/alpha/kernel/core_tsunami.c b/arch/alpha/kernel/core_tsunami.c
index f334b89..fc1ab73 100644
--- a/arch/alpha/kernel/core_tsunami.c
+++ b/arch/alpha/kernel/core_tsunami.c
@@ -319,12 +319,14 @@ tsunami_init_one_pchip(tsunami_pchip *pchip, int index)
 	 * NOTE: we need the align_entry settings for Acer devices on ES40,
 	 * specifically floppy and IDE when memory is larger than 2GB.
 	 */
-	hose->sg_isa = iommu_arena_new(hose, 0x00800000, 0x00800000, 0);
+	hose->sg_isa = iommu_arena_new(hose, 0x00800000, 0x00800000,
+				       SMP_CACHE_BYTES);
 	/* Initially set for 4 PTEs, but will be overridden to 64K for ISA. */
         hose->sg_isa->align_entry = 4;
 
 	hose->sg_pci = iommu_arena_new(hose, 0x40000000,
-				       size_for_memory(0x40000000), 0);
+				       size_for_memory(0x40000000),
+				       SMP_CACHE_BYTES);
         hose->sg_pci->align_entry = 4; /* Tsunami caches 4 PTEs at a time */
 
 	__direct_map_base = 0x80000000;
diff --git a/arch/alpha/kernel/core_wildfire.c b/arch/alpha/kernel/core_wildfire.c
index cad36fc..1099a07 100644
--- a/arch/alpha/kernel/core_wildfire.c
+++ b/arch/alpha/kernel/core_wildfire.c
@@ -111,8 +111,10 @@ wildfire_init_hose(int qbbno, int hoseno)
          * ??? We ought to scale window 3 memory.
          *
          */
-        hose->sg_isa = iommu_arena_new(hose, 0x00800000, 0x00800000, 0);
-        hose->sg_pci = iommu_arena_new(hose, 0xc0000000, 0x08000000, 0);
+        hose->sg_isa = iommu_arena_new(hose, 0x00800000, 0x00800000,
+				       SMP_CACHE_BYTES);
+        hose->sg_pci = iommu_arena_new(hose, 0xc0000000, 0x08000000,
+				       SMP_CACHE_BYTES);
 
 	pci = WILDFIRE_pci(qbbno, hoseno);
 
diff --git a/arch/alpha/kernel/pci-noop.c b/arch/alpha/kernel/pci-noop.c
index a9378ee..091cff3 100644
--- a/arch/alpha/kernel/pci-noop.c
+++ b/arch/alpha/kernel/pci-noop.c
@@ -33,7 +33,7 @@ alloc_pci_controller(void)
 {
 	struct pci_controller *hose;
 
-	hose = memblock_alloc(sizeof(*hose), 0);
+	hose = memblock_alloc(sizeof(*hose), SMP_CACHE_BYTES);
 
 	*hose_tail = hose;
 	hose_tail = &hose->next;
@@ -44,7 +44,7 @@ alloc_pci_controller(void)
 struct resource * __init
 alloc_resource(void)
 {
-	return memblock_alloc(sizeof(struct resource), 0);
+	return memblock_alloc(sizeof(struct resource), SMP_CACHE_BYTES);
 }
 
 SYSCALL_DEFINE3(pciconfig_iobase, long, which, unsigned long, bus,
diff --git a/arch/alpha/kernel/pci.c b/arch/alpha/kernel/pci.c
index 13937e7..9709812 100644
--- a/arch/alpha/kernel/pci.c
+++ b/arch/alpha/kernel/pci.c
@@ -392,7 +392,7 @@ alloc_pci_controller(void)
 {
 	struct pci_controller *hose;
 
-	hose = memblock_alloc(sizeof(*hose), 0);
+	hose = memblock_alloc(sizeof(*hose), SMP_CACHE_BYTES);
 
 	*hose_tail = hose;
 	hose_tail = &hose->next;
@@ -403,7 +403,7 @@ alloc_pci_controller(void)
 struct resource * __init
 alloc_resource(void)
 {
-	return memblock_alloc(sizeof(struct resource), 0);
+	return memblock_alloc(sizeof(struct resource), SMP_CACHE_BYTES);
 }
 
 
diff --git a/arch/alpha/kernel/pci_iommu.c b/arch/alpha/kernel/pci_iommu.c
index 82cf950..46e08e0 100644
--- a/arch/alpha/kernel/pci_iommu.c
+++ b/arch/alpha/kernel/pci_iommu.c
@@ -79,7 +79,7 @@ iommu_arena_new_node(int nid, struct pci_controller *hose, dma_addr_t base,
 		printk("%s: couldn't allocate arena from node %d\n"
 		       "    falling back to system-wide allocation\n",
 		       __func__, nid);
-		arena = memblock_alloc(sizeof(*arena), 0);
+		arena = memblock_alloc(sizeof(*arena), SMP_CACHE_BYTES);
 	}
 
 	arena->ptes = memblock_alloc_node(sizeof(*arena), align, nid);
@@ -92,7 +92,7 @@ iommu_arena_new_node(int nid, struct pci_controller *hose, dma_addr_t base,
 
 #else /* CONFIG_DISCONTIGMEM */
 
-	arena = memblock_alloc(sizeof(*arena), 0);
+	arena = memblock_alloc(sizeof(*arena), SMP_CACHE_BYTES);
 	arena->ptes = memblock_alloc_from(mem_size, align, 0);
 
 #endif /* CONFIG_DISCONTIGMEM */
diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 840a4ad..ac7e088 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -856,7 +856,7 @@ static void __init request_standard_resources(const struct machine_desc *mdesc)
 		 */
 		boot_alias_start = phys_to_idmap(start);
 		if (arm_has_idmap_alias() && boot_alias_start != IDMAP_INVALID_ADDR) {
-			res = memblock_alloc(sizeof(*res), 0);
+			res = memblock_alloc(sizeof(*res), SMP_CACHE_BYTES);
 			res->name = "System RAM (boot alias)";
 			res->start = boot_alias_start;
 			res->end = phys_to_idmap(end);
@@ -864,7 +864,7 @@ static void __init request_standard_resources(const struct machine_desc *mdesc)
 			request_resource(&iomem_resource, res);
 		}
 
-		res = memblock_alloc(sizeof(*res), 0);
+		res = memblock_alloc(sizeof(*res), SMP_CACHE_BYTES);
 		res->name  = "System RAM";
 		res->start = start;
 		res->end = end;
diff --git a/arch/arm/mach-omap2/omap_hwmod.c b/arch/arm/mach-omap2/omap_hwmod.c
index cd5732a..083dcd9 100644
--- a/arch/arm/mach-omap2/omap_hwmod.c
+++ b/arch/arm/mach-omap2/omap_hwmod.c
@@ -726,7 +726,7 @@ static int __init _setup_clkctrl_provider(struct device_node *np)
 	u64 size;
 	int i;
 
-	provider = memblock_alloc(sizeof(*provider), 0);
+	provider = memblock_alloc(sizeof(*provider), SMP_CACHE_BYTES);
 	if (!provider)
 		return -ENOMEM;
 
@@ -736,12 +736,14 @@ static int __init _setup_clkctrl_provider(struct device_node *np)
 		of_property_count_elems_of_size(np, "reg", sizeof(u32)) / 2;
 
 	provider->addr =
-		memblock_alloc(sizeof(void *) * provider->num_addrs, 0);
+		memblock_alloc(sizeof(void *) * provider->num_addrs,
+			       SMP_CACHE_BYTES);
 	if (!provider->addr)
 		return -ENOMEM;
 
 	provider->size =
-		memblock_alloc(sizeof(u32) * provider->num_addrs, 0);
+		memblock_alloc(sizeof(u32) * provider->num_addrs,
+			       SMP_CACHE_BYTES);
 	if (!provider->size)
 		return -ENOMEM;
 
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index 46d48ea..44def5b 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -212,7 +212,7 @@ static void __init request_standard_resources(void)
 	kernel_data.end     = __pa_symbol(_end - 1);
 
 	for_each_memblock(memory, region) {
-		res = memblock_alloc_low(sizeof(*res), 0);
+		res = memblock_alloc_low(sizeof(*res), SMP_CACHE_BYTES);
 		if (memblock_is_nomap(region)) {
 			res->name  = "reserved";
 			res->flags = IORESOURCE_MEM;
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 9a6603f..91bd1e1 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -361,9 +361,9 @@ static ia64_state_log_t ia64_state_log[IA64_MAX_LOG_TYPES];
 
 #define IA64_LOG_ALLOCATE(it, size) \
 	{ia64_state_log[it].isl_log[IA64_LOG_CURR_INDEX(it)] = \
-		(ia64_err_rec_t *)memblock_alloc(size, 0); \
+		(ia64_err_rec_t *)memblock_alloc(size, SMP_CACHE_BYTES); \
 	ia64_state_log[it].isl_log[IA64_LOG_NEXT_INDEX(it)] = \
-		(ia64_err_rec_t *)memblock_alloc(size, 0);}
+		(ia64_err_rec_t *)memblock_alloc(size, SMP_CACHE_BYTES);}
 #define IA64_LOG_LOCK_INIT(it) spin_lock_init(&ia64_state_log[it].isl_lock)
 #define IA64_LOG_LOCK(it)      spin_lock_irqsave(&ia64_state_log[it].isl_lock, s)
 #define IA64_LOG_UNLOCK(it)    spin_unlock_irqrestore(&ia64_state_log[it].isl_lock,s)
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index ab545da..9340bcb 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -59,8 +59,10 @@ struct ia64_tr_entry *ia64_idtrs[NR_CPUS];
 void __init
 mmu_context_init (void)
 {
-	ia64_ctx.bitmap = memblock_alloc((ia64_ctx.max_ctx + 1) >> 3, 0);
-	ia64_ctx.flushmap = memblock_alloc((ia64_ctx.max_ctx + 1) >> 3, 0);
+	ia64_ctx.bitmap = memblock_alloc((ia64_ctx.max_ctx + 1) >> 3,
+					 SMP_CACHE_BYTES);
+	ia64_ctx.flushmap = memblock_alloc((ia64_ctx.max_ctx + 1) >> 3,
+					   SMP_CACHE_BYTES);
 }
 
 /*
diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index 98f5522..8df13d0 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -391,7 +391,9 @@ void __init hubdev_init_node(nodepda_t * npda, cnodeid_t node)
 	if (node >= num_online_nodes())	/* Headless/memless IO nodes */
 		node = 0;
 
-	hubdev_info = (struct hubdev_info *)memblock_alloc_node(size, 0, node);
+	hubdev_info = (struct hubdev_info *)memblock_alloc_node(size,
+								SMP_CACHE_BYTES,
+								node);
 
 	npda->pdinfo = (void *)hubdev_info;
 }
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 71ad6b0..a6d40a2 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -511,7 +511,8 @@ static void __init sn_init_pdas(char **cmdline_p)
 	 */
 	for_each_online_node(cnode) {
 		nodepdaindr[cnode] =
-		    memblock_alloc_node(sizeof(nodepda_t), 0, cnode);
+		    memblock_alloc_node(sizeof(nodepda_t), SMP_CACHE_BYTES,
+					cnode);
 		memset(nodepdaindr[cnode]->phys_cpuid, -1,
 		    sizeof(nodepdaindr[cnode]->phys_cpuid));
 		spin_lock_init(&nodepdaindr[cnode]->ptc_lock);
@@ -522,7 +523,7 @@ static void __init sn_init_pdas(char **cmdline_p)
 	 */
 	for (cnode = num_online_nodes(); cnode < num_cnodes; cnode++)
 		nodepdaindr[cnode] =
-		    memblock_alloc_node(sizeof(nodepda_t), 0, 0);
+		    memblock_alloc_node(sizeof(nodepda_t), SMP_CACHE_BYTES, 0);
 
 	/*
 	 * Now copy the array of nodepda pointers to each nodepda.
diff --git a/arch/m68k/sun3/sun3dvma.c b/arch/m68k/sun3/sun3dvma.c
index 8be8b75..4d64711 100644
--- a/arch/m68k/sun3/sun3dvma.c
+++ b/arch/m68k/sun3/sun3dvma.c
@@ -268,7 +268,7 @@ void __init dvma_init(void)
 	list_add(&(hole->list), &hole_list);
 
 	iommu_use = memblock_alloc(IOMMU_TOTAL_ENTRIES * sizeof(unsigned long),
-				   0);
+				   SMP_CACHE_BYTES);
 
 	dvma_unmap_iommu(DVMA_START, DVMA_SIZE);
 
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 8c14988..b17fd8a 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -376,7 +376,7 @@ void * __ref zalloc_maybe_bootmem(size_t size, gfp_t mask)
 	if (mem_init_done)
 		p = kzalloc(size, mask);
 	else {
-		p = memblock_alloc(size, 0);
+		p = memblock_alloc(size, SMP_CACHE_BYTES);
 		if (p)
 			memset(p, 0, size);
 	}
diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
index 4efa8af..4de68e9 100644
--- a/arch/mips/kernel/setup.c
+++ b/arch/mips/kernel/setup.c
@@ -908,7 +908,7 @@ static void __init resource_init(void)
 		if (end >= HIGHMEM_START)
 			end = HIGHMEM_START - 1;
 
-		res = memblock_alloc(sizeof(struct resource), 0);
+		res = memblock_alloc(sizeof(struct resource), SMP_CACHE_BYTES);
 
 		res->start = start;
 		res->end = end;
diff --git a/arch/powerpc/kernel/pci_32.c b/arch/powerpc/kernel/pci_32.c
index d63be12..8271ffe 100644
--- a/arch/powerpc/kernel/pci_32.c
+++ b/arch/powerpc/kernel/pci_32.c
@@ -204,7 +204,8 @@ pci_create_OF_bus_map(void)
 	struct property* of_prop;
 	struct device_node *dn;
 
-	of_prop = memblock_alloc(sizeof(struct property) + 256, 0);
+	of_prop = memblock_alloc(sizeof(struct property) + 256,
+				 SMP_CACHE_BYTES);
 	dn = of_find_node_by_path("/");
 	if (dn) {
 		memset(of_prop, -1, sizeof(struct property) + 256);
diff --git a/arch/powerpc/lib/alloc.c b/arch/powerpc/lib/alloc.c
index 5b61704..dedf88a 100644
--- a/arch/powerpc/lib/alloc.c
+++ b/arch/powerpc/lib/alloc.c
@@ -14,7 +14,7 @@ void * __ref zalloc_maybe_bootmem(size_t size, gfp_t mask)
 	if (slab_is_available())
 		p = kzalloc(size, mask);
 	else {
-		p = memblock_alloc(size, 0);
+		p = memblock_alloc(size, SMP_CACHE_BYTES);
 	}
 	return p;
 }
diff --git a/arch/powerpc/mm/mmu_context_nohash.c b/arch/powerpc/mm/mmu_context_nohash.c
index 67b9d7b..2faca46 100644
--- a/arch/powerpc/mm/mmu_context_nohash.c
+++ b/arch/powerpc/mm/mmu_context_nohash.c
@@ -461,10 +461,11 @@ void __init mmu_context_init(void)
 	/*
 	 * Allocate the maps used by context management
 	 */
-	context_map = memblock_alloc(CTX_MAP_SIZE, 0);
-	context_mm = memblock_alloc(sizeof(void *) * (LAST_CONTEXT + 1), 0);
+	context_map = memblock_alloc(CTX_MAP_SIZE, SMP_CACHE_BYTES);
+	context_mm = memblock_alloc(sizeof(void *) * (LAST_CONTEXT + 1),
+				    SMP_CACHE_BYTES);
 #ifdef CONFIG_SMP
-	stale_map[boot_cpuid] = memblock_alloc(CTX_MAP_SIZE, 0);
+	stale_map[boot_cpuid] = memblock_alloc(CTX_MAP_SIZE, SMP_CACHE_BYTES);
 
 	cpuhp_setup_state_nocalls(CPUHP_POWERPC_MMU_CTX_PREPARE,
 				  "powerpc/mmu/ctx:prepare",
diff --git a/arch/powerpc/platforms/powermac/nvram.c b/arch/powerpc/platforms/powermac/nvram.c
index f3391be..ae54d7f 100644
--- a/arch/powerpc/platforms/powermac/nvram.c
+++ b/arch/powerpc/platforms/powermac/nvram.c
@@ -513,7 +513,7 @@ static int __init core99_nvram_setup(struct device_node *dp, unsigned long addr)
 		printk(KERN_ERR "nvram: no address\n");
 		return -EINVAL;
 	}
-	nvram_image = memblock_alloc(NVRAM_SIZE, 0);
+	nvram_image = memblock_alloc(NVRAM_SIZE, SMP_CACHE_BYTES);
 	nvram_data = ioremap(addr, NVRAM_SIZE*2);
 	nvram_naddrs = 1; /* Make sure we get the correct case */
 
diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c b/arch/powerpc/platforms/powernv/pci-ioda.c
index aba81cb..dd80744 100644
--- a/arch/powerpc/platforms/powernv/pci-ioda.c
+++ b/arch/powerpc/platforms/powernv/pci-ioda.c
@@ -3769,7 +3769,7 @@ static void __init pnv_pci_init_ioda_phb(struct device_node *np,
 	phb_id = be64_to_cpup(prop64);
 	pr_debug("  PHB-ID  : 0x%016llx\n", phb_id);
 
-	phb = memblock_alloc(sizeof(*phb), 0);
+	phb = memblock_alloc(sizeof(*phb), SMP_CACHE_BYTES);
 
 	/* Allocate PCI controller */
 	phb->hose = hose = pcibios_alloc_controller(np);
@@ -3815,7 +3815,7 @@ static void __init pnv_pci_init_ioda_phb(struct device_node *np,
 	else
 		phb->diag_data_size = PNV_PCI_DIAG_BUF_SIZE;
 
-	phb->diag_data = memblock_alloc(phb->diag_data_size, 0);
+	phb->diag_data = memblock_alloc(phb->diag_data_size, SMP_CACHE_BYTES);
 
 	/* Parse 32-bit and IO ranges (if any) */
 	pci_process_bridge_OF_ranges(hose, np, !hose->global_number);
@@ -3874,7 +3874,7 @@ static void __init pnv_pci_init_ioda_phb(struct device_node *np,
 	}
 	pemap_off = size;
 	size += phb->ioda.total_pe_num * sizeof(struct pnv_ioda_pe);
-	aux = memblock_alloc(size, 0);
+	aux = memblock_alloc(size, SMP_CACHE_BYTES);
 	phb->ioda.pe_alloc = aux;
 	phb->ioda.m64_segmap = aux + m64map_off;
 	phb->ioda.m32_segmap = aux + m32map_off;
diff --git a/arch/powerpc/sysdev/msi_bitmap.c b/arch/powerpc/sysdev/msi_bitmap.c
index 2444fed..d45450f 100644
--- a/arch/powerpc/sysdev/msi_bitmap.c
+++ b/arch/powerpc/sysdev/msi_bitmap.c
@@ -128,7 +128,7 @@ int __ref msi_bitmap_alloc(struct msi_bitmap *bmp, unsigned int irq_count,
 	if (bmp->bitmap_from_slab)
 		bmp->bitmap = kzalloc(size, GFP_KERNEL);
 	else {
-		bmp->bitmap = memblock_alloc(size, 0);
+		bmp->bitmap = memblock_alloc(size, SMP_CACHE_BYTES);
 		/* the bitmap won't be freed from memblock allocator */
 		kmemleak_not_leak(bmp->bitmap);
 	}
diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index 6738168..624cb47 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -650,7 +650,7 @@ static int __init eth_setup(char *str)
 		return 1;
 	}
 
-	new = memblock_alloc(sizeof(*new), 0);
+	new = memblock_alloc(sizeof(*new), SMP_CACHE_BYTES);
 
 	INIT_LIST_HEAD(&new->list);
 	new->index = n;
diff --git a/arch/um/drivers/vector_kern.c b/arch/um/drivers/vector_kern.c
index af72633..046fa9e 100644
--- a/arch/um/drivers/vector_kern.c
+++ b/arch/um/drivers/vector_kern.c
@@ -1575,7 +1575,7 @@ static int __init vector_setup(char *str)
 				 str, error);
 		return 1;
 	}
-	new = memblock_alloc(sizeof(*new), 0);
+	new = memblock_alloc(sizeof(*new), SMP_CACHE_BYTES);
 	INIT_LIST_HEAD(&new->list);
 	new->unit = n;
 	new->arguments = str;
diff --git a/arch/um/kernel/initrd.c b/arch/um/kernel/initrd.c
index 3678f5b..ce169ea 100644
--- a/arch/um/kernel/initrd.c
+++ b/arch/um/kernel/initrd.c
@@ -36,7 +36,7 @@ int __init read_initrd(void)
 		return 0;
 	}
 
-	area = memblock_alloc(size, 0);
+	area = memblock_alloc(size, SMP_CACHE_BYTES);
 
 	if (load_initrd(initrd, area, size) == -1)
 		return 0;
diff --git a/arch/unicore32/kernel/setup.c b/arch/unicore32/kernel/setup.c
index b2c38b32..4b0cb68 100644
--- a/arch/unicore32/kernel/setup.c
+++ b/arch/unicore32/kernel/setup.c
@@ -206,7 +206,7 @@ request_standard_resources(struct meminfo *mi)
 		if (mi->bank[i].size == 0)
 			continue;
 
-		res = memblock_alloc_low(sizeof(*res), 0);
+		res = memblock_alloc_low(sizeof(*res), SMP_CACHE_BYTES);
 		res->name  = "System RAM";
 		res->start = mi->bank[i].start;
 		res->end   = mi->bank[i].start + mi->bank[i].size - 1;
diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 35419f9..de2992a 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -933,7 +933,7 @@ static int __init acpi_parse_hpet(struct acpi_table_header *table)
 	 */
 #define HPET_RESOURCE_NAME_SIZE 9
 	hpet_res = memblock_alloc(sizeof(*hpet_res) + HPET_RESOURCE_NAME_SIZE,
-				  0);
+				  SMP_CACHE_BYTES);
 
 	hpet_res->name = (void *)&hpet_res[1];
 	hpet_res->flags = IORESOURCE_MEM;
diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
index 5fbc57e..2953bbf 100644
--- a/arch/x86/kernel/apic/io_apic.c
+++ b/arch/x86/kernel/apic/io_apic.c
@@ -2578,7 +2578,7 @@ static struct resource * __init ioapic_setup_resources(void)
 	n = IOAPIC_RESOURCE_NAME_SIZE + sizeof(struct resource);
 	n *= nr_ioapics;
 
-	mem = memblock_alloc(n, 0);
+	mem = memblock_alloc(n, SMP_CACHE_BYTES);
 	res = (void *)mem;
 
 	mem += sizeof(struct resource) * nr_ioapics;
diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index cd3b448..5fb541c 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -1093,7 +1093,8 @@ void __init e820__reserve_resources(void)
 	struct resource *res;
 	u64 end;
 
-	res = memblock_alloc(sizeof(*res) * e820_table->nr_entries, 0);
+	res = memblock_alloc(sizeof(*res) * e820_table->nr_entries,
+			     SMP_CACHE_BYTES);
 	e820_res = res;
 
 	for (i = 0; i < e820_table->nr_entries; i++) {
diff --git a/arch/x86/platform/olpc/olpc_dt.c b/arch/x86/platform/olpc/olpc_dt.c
index 115c8e4..24d2175 100644
--- a/arch/x86/platform/olpc/olpc_dt.c
+++ b/arch/x86/platform/olpc/olpc_dt.c
@@ -141,7 +141,7 @@ void * __init prom_early_alloc(unsigned long size)
 		 * fast enough on the platforms we care about while minimizing
 		 * wasted bootmem) and hand off chunks of it to callers.
 		 */
-		res = memblock_alloc(chunk_size, 0);
+		res = memblock_alloc(chunk_size, SMP_CACHE_BYTES);
 		BUG_ON(!res);
 		prom_early_allocated += chunk_size;
 		memset(res, 0, chunk_size);
diff --git a/arch/xtensa/platforms/iss/network.c b/arch/xtensa/platforms/iss/network.c
index 190846d..d052712 100644
--- a/arch/xtensa/platforms/iss/network.c
+++ b/arch/xtensa/platforms/iss/network.c
@@ -646,7 +646,7 @@ static int __init iss_net_setup(char *str)
 		return 1;
 	}
 
-	new = memblock_alloc(sizeof(*new), 0);
+	new = memblock_alloc(sizeof(*new), SMP_CACHE_BYTES);
 	if (new == NULL) {
 		pr_err("Alloc_bootmem failed\n");
 		return 1;
diff --git a/drivers/clk/ti/clk.c b/drivers/clk/ti/clk.c
index 8aa5f8f..d4e10af 100644
--- a/drivers/clk/ti/clk.c
+++ b/drivers/clk/ti/clk.c
@@ -347,7 +347,7 @@ void __init omap2_clk_legacy_provider_init(int index, void __iomem *mem)
 {
 	struct clk_iomap *io;
 
-	io = memblock_alloc(sizeof(*io), 0);
+	io = memblock_alloc(sizeof(*io), SMP_CACHE_BYTES);
 
 	io->mem = mem;
 
diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index 2a23453..d168c87 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -333,7 +333,8 @@ int __init firmware_map_add_early(u64 start, u64 end, const char *type)
 {
 	struct firmware_map_entry *entry;
 
-	entry = memblock_alloc(sizeof(struct firmware_map_entry), 0);
+	entry = memblock_alloc(sizeof(struct firmware_map_entry),
+			       SMP_CACHE_BYTES);
 	if (WARN_ON(!entry))
 		return -ENOMEM;
 
diff --git a/drivers/macintosh/smu.c b/drivers/macintosh/smu.c
index 880a81c..0a0b8e1 100644
--- a/drivers/macintosh/smu.c
+++ b/drivers/macintosh/smu.c
@@ -492,7 +492,7 @@ int __init smu_init (void)
 		goto fail_np;
 	}
 
-	smu = memblock_alloc(sizeof(struct smu_device), 0);
+	smu = memblock_alloc(sizeof(struct smu_device), SMP_CACHE_BYTES);
 
 	spin_lock_init(&smu->lock);
 	INIT_LIST_HEAD(&smu->cmd_list);
diff --git a/drivers/of/of_reserved_mem.c b/drivers/of/of_reserved_mem.c
index d6255c2..1977ee0 100644
--- a/drivers/of/of_reserved_mem.c
+++ b/drivers/of/of_reserved_mem.c
@@ -36,6 +36,7 @@ int __init __weak early_init_dt_alloc_reserved_memory_arch(phys_addr_t size,
 	 * panic()s on allocation failure.
 	 */
 	end = !end ? MEMBLOCK_ALLOC_ANYWHERE : end;
+	align = !align ? SMP_CACHE_BYTES : align;
 	base = __memblock_alloc_base(size, align, end);
 	if (!base)
 		return -ENOMEM;
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index d3bc270..cf5f7af 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -421,7 +421,8 @@ static inline void * __init memblock_alloc_node(phys_addr_t size,
 static inline void * __init memblock_alloc_node_nopanic(phys_addr_t size,
 							int nid)
 {
-	return memblock_alloc_try_nid_nopanic(size, 0, MEMBLOCK_LOW_LIMIT,
+	return memblock_alloc_try_nid_nopanic(size, SMP_CACHE_BYTES,
+					      MEMBLOCK_LOW_LIMIT,
 					      MEMBLOCK_ALLOC_ACCESSIBLE, nid);
 }
 
diff --git a/init/main.c b/init/main.c
index 473b554..568ad27 100644
--- a/init/main.c
+++ b/init/main.c
@@ -375,10 +375,11 @@ static inline void smp_prepare_cpus(unsigned int maxcpus) { }
 static void __init setup_command_line(char *command_line)
 {
 	saved_command_line =
-		memblock_alloc(strlen(boot_command_line) + 1, 0);
+		memblock_alloc(strlen(boot_command_line) + 1, SMP_CACHE_BYTES);
 	initcall_command_line =
-		memblock_alloc(strlen(boot_command_line) + 1, 0);
-	static_command_line = memblock_alloc(strlen(command_line) + 1, 0);
+		memblock_alloc(strlen(boot_command_line) + 1, SMP_CACHE_BYTES);
+	static_command_line = memblock_alloc(strlen(command_line) + 1,
+					     SMP_CACHE_BYTES);
 	strcpy(saved_command_line, boot_command_line);
 	strcpy(static_command_line, command_line);
 }
@@ -768,8 +769,10 @@ static int __init initcall_blacklist(char *str)
 		str_entry = strsep(&str, ",");
 		if (str_entry) {
 			pr_debug("blacklisting initcall %s\n", str_entry);
-			entry = memblock_alloc(sizeof(*entry), 0);
-			entry->buf = memblock_alloc(strlen(str_entry) + 1, 0);
+			entry = memblock_alloc(sizeof(*entry),
+					       SMP_CACHE_BYTES);
+			entry->buf = memblock_alloc(strlen(str_entry) + 1,
+						    SMP_CACHE_BYTES);
 			strcpy(entry->buf, str_entry);
 			list_add(&entry->next, &blacklisted_initcalls);
 		}
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 3c9e365..b0308a2 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -963,7 +963,8 @@ void __init __register_nosave_region(unsigned long start_pfn,
 		BUG_ON(!region);
 	} else {
 		/* This allocation cannot fail */
-		region = memblock_alloc(sizeof(struct nosave_region), 0);
+		region = memblock_alloc(sizeof(struct nosave_region),
+					SMP_CACHE_BYTES);
 	}
 	region->start_pfn = start_pfn;
 	region->end_pfn = end_pfn;
diff --git a/lib/cpumask.c b/lib/cpumask.c
index 75b5e76..8d666ab 100644
--- a/lib/cpumask.c
+++ b/lib/cpumask.c
@@ -163,7 +163,7 @@ EXPORT_SYMBOL(zalloc_cpumask_var);
  */
 void __init alloc_bootmem_cpumask_var(cpumask_var_t *mask)
 {
-	*mask = memblock_alloc(cpumask_size(), 0);
+	*mask = memblock_alloc(cpumask_size(), SMP_CACHE_BYTES);
 }
 
 /**
diff --git a/mm/memblock.c b/mm/memblock.c
index 32e5c62..59b7b51 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1298,9 +1298,6 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
 {
 	phys_addr_t found;
 
-	if (!align)
-		align = SMP_CACHE_BYTES;
-
 	found = memblock_find_in_range_node(size, align, start, end, nid,
 					    flags);
 	if (found && !memblock_reserve(found, size)) {
@@ -1394,8 +1391,6 @@ phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t ali
  * The allocation is performed from memory region limited by
  * memblock.current_limit if @max_addr == %MEMBLOCK_ALLOC_ACCESSIBLE.
  *
- * The memory block is aligned on %SMP_CACHE_BYTES if @align == 0.
- *
  * The phys address of allocated boot memory block is converted to virtual and
  * allocated memory is reset to 0.
  *
@@ -1425,9 +1420,6 @@ static void * __init memblock_alloc_internal(
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, nid);
 
-	if (!align)
-		align = SMP_CACHE_BYTES;
-
 	if (max_addr > memblock.current_limit)
 		max_addr = memblock.current_limit;
 again:
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 511447a..e687816 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7615,9 +7615,11 @@ void *__init alloc_large_system_hash(const char *tablename,
 		size = bucketsize << log2qty;
 		if (flags & HASH_EARLY) {
 			if (flags & HASH_ZERO)
-				table = memblock_alloc_nopanic(size, 0);
+				table = memblock_alloc_nopanic(size,
+							       SMP_CACHE_BYTES);
 			else
-				table = memblock_alloc_raw(size, 0);
+				table = memblock_alloc_raw(size,
+							   SMP_CACHE_BYTES);
 		} else if (hashdist) {
 			table = __vmalloc(size, gfp_flags, PAGE_KERNEL);
 		} else {
diff --git a/mm/percpu.c b/mm/percpu.c
index d21cb13..3f3af21 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1101,9 +1101,8 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	region_size = ALIGN(start_offset + map_size, lcm_align);
 
 	/* allocate chunk */
-	chunk = memblock_alloc(sizeof(struct pcpu_chunk) +
-				    BITS_TO_LONGS(region_size >> PAGE_SHIFT),
-				    0);
+	chunk = memblock_alloc(sizeof(struct pcpu_chunk) + BITS_TO_LONGS(region_size >> PAGE_SHIFT),
+			       SMP_CACHE_BYTES);
 
 	INIT_LIST_HEAD(&chunk->list);
 
@@ -1114,12 +1113,12 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	chunk->nr_pages = region_size >> PAGE_SHIFT;
 	region_bits = pcpu_chunk_map_bits(chunk);
 
-	chunk->alloc_map = memblock_alloc(BITS_TO_LONGS(region_bits) *
-					       sizeof(chunk->alloc_map[0]), 0);
-	chunk->bound_map = memblock_alloc(BITS_TO_LONGS(region_bits + 1) *
-					       sizeof(chunk->bound_map[0]), 0);
-	chunk->md_blocks = memblock_alloc(pcpu_chunk_nr_blocks(chunk) *
-					       sizeof(chunk->md_blocks[0]), 0);
+	chunk->alloc_map = memblock_alloc(BITS_TO_LONGS(region_bits) * sizeof(chunk->alloc_map[0]),
+					  SMP_CACHE_BYTES);
+	chunk->bound_map = memblock_alloc(BITS_TO_LONGS(region_bits + 1) * sizeof(chunk->bound_map[0]),
+					  SMP_CACHE_BYTES);
+	chunk->md_blocks = memblock_alloc(pcpu_chunk_nr_blocks(chunk) * sizeof(chunk->md_blocks[0]),
+					  SMP_CACHE_BYTES);
 	pcpu_init_md_blocks(chunk);
 
 	/* manage populated page bitmap */
@@ -2074,12 +2073,14 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	PCPU_SETUP_BUG_ON(pcpu_verify_alloc_info(ai) < 0);
 
 	/* process group information and build config tables accordingly */
-	group_offsets = memblock_alloc(ai->nr_groups *
-					     sizeof(group_offsets[0]), 0);
-	group_sizes = memblock_alloc(ai->nr_groups *
-					   sizeof(group_sizes[0]), 0);
-	unit_map = memblock_alloc(nr_cpu_ids * sizeof(unit_map[0]), 0);
-	unit_off = memblock_alloc(nr_cpu_ids * sizeof(unit_off[0]), 0);
+	group_offsets = memblock_alloc(ai->nr_groups * sizeof(group_offsets[0]),
+				       SMP_CACHE_BYTES);
+	group_sizes = memblock_alloc(ai->nr_groups * sizeof(group_sizes[0]),
+				     SMP_CACHE_BYTES);
+	unit_map = memblock_alloc(nr_cpu_ids * sizeof(unit_map[0]),
+				  SMP_CACHE_BYTES);
+	unit_off = memblock_alloc(nr_cpu_ids * sizeof(unit_off[0]),
+				  SMP_CACHE_BYTES);
 
 	for (cpu = 0; cpu < nr_cpu_ids; cpu++)
 		unit_map[cpu] = UINT_MAX;
@@ -2143,8 +2144,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	 * empty chunks.
 	 */
 	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
-	pcpu_slot = memblock_alloc(
-			pcpu_nr_slots * sizeof(pcpu_slot[0]), 0);
+	pcpu_slot = memblock_alloc(pcpu_nr_slots * sizeof(pcpu_slot[0]),
+				   SMP_CACHE_BYTES);
 	for (i = 0; i < pcpu_nr_slots; i++)
 		INIT_LIST_HEAD(&pcpu_slot[i]);
 
@@ -2457,7 +2458,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 	size_sum = ai->static_size + ai->reserved_size + ai->dyn_size;
 	areas_size = PFN_ALIGN(ai->nr_groups * sizeof(void *));
 
-	areas = memblock_alloc_nopanic(areas_size, 0);
+	areas = memblock_alloc_nopanic(areas_size, SMP_CACHE_BYTES);
 	if (!areas) {
 		rc = -ENOMEM;
 		goto out_free;
@@ -2598,7 +2599,7 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 	/* unaligned allocations can't be freed, round up to page size */
 	pages_size = PFN_ALIGN(unit_pages * num_possible_cpus() *
 			       sizeof(pages[0]));
-	pages = memblock_alloc(pages_size, 0);
+	pages = memblock_alloc(pages_size, SMP_CACHE_BYTES);
 
 	/* allocate pages */
 	j = 0;
diff --git a/mm/sparse.c b/mm/sparse.c
index c0788e3..6ff7cc0 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -68,7 +68,8 @@ static noinline struct mem_section __ref *sparse_index_alloc(int nid)
 	if (slab_is_available())
 		section = kzalloc_node(array_size, GFP_KERNEL, nid);
 	else
-		section = memblock_alloc_node(array_size, 0, nid);
+		section = memblock_alloc_node(array_size, SMP_CACHE_BYTES,
+					      nid);
 
 	return section;
 }
-- 
2.7.4
