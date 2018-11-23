Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 63FA66B308E
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:54:46 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id k76so5280763oih.13
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 01:54:46 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l19si22656897otk.230.2018.11.23.01.54.42
        for <linux-mm@kvack.org>;
        Fri, 23 Nov 2018 01:54:43 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH] mm: Replace all open encodings for NUMA_NO_NODE
Date: Fri, 23 Nov 2018 15:24:16 +0530
Message-Id: <1542966856-12619-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: ocfs2-devel@oss.oracle.com, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org, iommu@lists.linux-foundation.org, linux-rdma@vger.kernel.org, dmaengine@vger.kernel.org, linux-block@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, linux-alpha@vger.kernel.org, akpm@linux-foundation.org, jiangqi903@gmail.com, hverkuil@xs4all.nl

At present there are multiple places where invalid node number is encoded
as -1. Even though implicitly understood it is always better to have macros
in there. Replace these open encodings for an invalid node number with the
global macro NUMA_NO_NODE. This helps remove NUMA related assumptions like
'invalid node' from various places redirecting them to a common definition.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---

Changes in V1:

- Dropped OCFS2 changes per Joseph
- Dropped media/video drivers changes per Hans

RFC - https://patchwork.kernel.org/patch/10678035/

Build tested this with multiple cross compiler options like alpha, sparc,
arm64, x86, powerpc, powerpc64le etc with their default config which might
not have compiled tested all driver related changes. I will appreciate
folks giving this a test in their respective build environment.

All these places for replacement were found by running the following grep
patterns on the entire kernel code. Please let me know if this might have
missed some instances. This might also have replaced some false positives.
I will appreciate suggestions, inputs and review.

1. git grep "nid == -1"
2. git grep "node == -1"
3. git grep "nid = -1"
4. git grep "node = -1"

 arch/alpha/include/asm/topology.h             |  2 +-
 arch/ia64/kernel/numa.c                       |  2 +-
 arch/ia64/mm/discontig.c                      |  6 +++---
 arch/ia64/sn/kernel/io_common.c               |  2 +-
 arch/powerpc/include/asm/pci-bridge.h         |  2 +-
 arch/powerpc/kernel/paca.c                    |  2 +-
 arch/powerpc/kernel/pci-common.c              |  2 +-
 arch/powerpc/mm/numa.c                        | 14 +++++++-------
 arch/powerpc/platforms/powernv/memtrace.c     |  4 ++--
 arch/sparc/kernel/auxio_32.c                  |  2 +-
 arch/sparc/kernel/pci_fire.c                  |  2 +-
 arch/sparc/kernel/pci_schizo.c                |  2 +-
 arch/sparc/kernel/pcic.c                      |  6 +++---
 arch/sparc/kernel/psycho_common.c             |  2 +-
 arch/sparc/kernel/sbus.c                      |  2 +-
 arch/sparc/mm/init_64.c                       |  6 +++---
 arch/sparc/prom/init_32.c                     |  2 +-
 arch/sparc/prom/init_64.c                     |  4 ++--
 arch/sparc/prom/tree_32.c                     | 12 ++++++------
 arch/sparc/prom/tree_64.c                     | 18 +++++++++---------
 arch/x86/include/asm/pci.h                    |  2 +-
 arch/x86/kernel/apic/x2apic_uv_x.c            |  6 +++---
 arch/x86/kernel/smpboot.c                     |  2 +-
 arch/x86/platform/olpc/olpc_dt.c              | 16 ++++++++--------
 drivers/block/mtip32xx/mtip32xx.c             |  4 ++--
 drivers/dma/dmaengine.c                       |  3 ++-
 drivers/infiniband/hw/hfi1/affinity.c         |  2 +-
 drivers/infiniband/hw/hfi1/init.c             |  2 +-
 drivers/iommu/dmar.c                          |  4 ++--
 drivers/iommu/intel-iommu.c                   |  2 +-
 drivers/misc/sgi-xp/xpc_uv.c                  |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  4 ++--
 init/init_task.c                              |  2 +-
 kernel/kthread.c                              |  2 +-
 kernel/sched/fair.c                           | 15 ++++++++-------
 lib/cpumask.c                                 |  2 +-
 mm/huge_memory.c                              | 12 ++++++------
 mm/hugetlb.c                                  |  2 +-
 mm/ksm.c                                      |  2 +-
 mm/memory.c                                   |  6 +++---
 mm/memory_hotplug.c                           | 12 ++++++------
 mm/mempolicy.c                                |  2 +-
 mm/page_alloc.c                               |  4 ++--
 mm/page_ext.c                                 |  2 +-
 net/core/pktgen.c                             |  2 +-
 net/qrtr/qrtr.c                               |  2 +-
 tools/perf/bench/numa.c                       |  6 +++---
 47 files changed, 109 insertions(+), 107 deletions(-)

diff --git a/arch/alpha/include/asm/topology.h b/arch/alpha/include/asm/topology.h
index e6e13a8..f6dc89c 100644
--- a/arch/alpha/include/asm/topology.h
+++ b/arch/alpha/include/asm/topology.h
@@ -29,7 +29,7 @@ static const struct cpumask *cpumask_of_node(int node)
 {
 	int cpu;
 
-	if (node == -1)
+	if (node == NUMA_NO_NODE)
 		return cpu_all_mask;
 
 	cpumask_clear(&node_to_cpumask_map[node]);
diff --git a/arch/ia64/kernel/numa.c b/arch/ia64/kernel/numa.c
index 92c3762..1315da6 100644
--- a/arch/ia64/kernel/numa.c
+++ b/arch/ia64/kernel/numa.c
@@ -74,7 +74,7 @@ void __init build_cpu_to_node_map(void)
 		cpumask_clear(&node_to_cpu_mask[node]);
 
 	for_each_possible_early_cpu(cpu) {
-		node = -1;
+		node = NUMA_NO_NODE;
 		for (i = 0; i < NR_CPUS; ++i)
 			if (cpu_physical_id(cpu) == node_cpuid[i].phys_id) {
 				node = node_cpuid[i].nid;
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 8a96578..f9c3675 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -227,7 +227,7 @@ void __init setup_per_cpu_areas(void)
 	 * CPUs are put into groups according to node.  Walk cpu_map
 	 * and create new groups at node boundaries.
 	 */
-	prev_node = -1;
+	prev_node = NUMA_NO_NODE;
 	ai->nr_groups = 0;
 	for (unit = 0; unit < nr_units; unit++) {
 		cpu = cpu_map[unit];
@@ -435,7 +435,7 @@ static void __init *memory_less_node_alloc(int nid, unsigned long pernodesize)
 {
 	void *ptr = NULL;
 	u8 best = 0xff;
-	int bestnode = -1, node, anynode = 0;
+	int bestnode = NUMA_NO_NODE, node, anynode = 0;
 
 	for_each_online_node(node) {
 		if (node_isset(node, memory_less_mask))
@@ -447,7 +447,7 @@ static void __init *memory_less_node_alloc(int nid, unsigned long pernodesize)
 		anynode = node;
 	}
 
-	if (bestnode == -1)
+	if (bestnode == NUMA_NO_NODE)
 		bestnode = anynode;
 
 	ptr = memblock_alloc_try_nid(pernodesize, PERCPU_PAGE_SIZE,
diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index 8df13d0..86b3fcb 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -344,7 +344,7 @@ sn_common_bus_fixup(struct pci_bus *bus,
 		printk(KERN_WARNING "on node %d but only %d nodes online."
 		       "Association set to undetermined.\n",
 		       controller->node, num_online_nodes());
-		controller->node = -1;
+		controller->node = NUMA_NO_NODE;
 	}
 }
 
diff --git a/arch/powerpc/include/asm/pci-bridge.h b/arch/powerpc/include/asm/pci-bridge.h
index 94d4490..25a9e33 100644
--- a/arch/powerpc/include/asm/pci-bridge.h
+++ b/arch/powerpc/include/asm/pci-bridge.h
@@ -264,7 +264,7 @@ extern int pcibios_map_io_space(struct pci_bus *bus);
 #ifdef CONFIG_NUMA
 #define PHB_SET_NODE(PHB, NODE)		((PHB)->node = (NODE))
 #else
-#define PHB_SET_NODE(PHB, NODE)		((PHB)->node = -1)
+#define PHB_SET_NODE(PHB, NODE)		((PHB)->node = NUMA_NO_NODE)
 #endif
 
 #endif	/* CONFIG_PPC64 */
diff --git a/arch/powerpc/kernel/paca.c b/arch/powerpc/kernel/paca.c
index 913bfca..6a0bd51 100644
--- a/arch/powerpc/kernel/paca.c
+++ b/arch/powerpc/kernel/paca.c
@@ -36,7 +36,7 @@ static void *__init alloc_paca_data(unsigned long size, unsigned long align,
 	 * which will put its paca in the right place.
 	 */
 	if (cpu == boot_cpuid) {
-		nid = -1;
+		nid = NUMA_NO_NODE;
 		memblock_set_bottom_up(true);
 	} else {
 		nid = early_cpu_to_node(cpu);
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 88e4f69..14c33a9 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -132,7 +132,7 @@ struct pci_controller *pcibios_alloc_controller(struct device_node *dev)
 		int nid = of_node_to_nid(dev);
 
 		if (nid < 0 || !node_online(nid))
-			nid = -1;
+			nid = NUMA_NO_NODE;
 
 		PHB_SET_NODE(phb, nid);
 	}
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 3a048e9..77808a2 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -215,7 +215,7 @@ static void initialize_distance_lookup_table(int nid,
  */
 static int associativity_to_nid(const __be32 *associativity)
 {
-	int nid = -1;
+	int nid = NUMA_NO_NODE;
 
 	if (min_common_depth == -1)
 		goto out;
@@ -225,7 +225,7 @@ static int associativity_to_nid(const __be32 *associativity)
 
 	/* POWER4 LPAR uses 0xffff as invalid node */
 	if (nid == 0xffff || nid >= MAX_NUMNODES)
-		nid = -1;
+		nid = NUMA_NO_NODE;
 
 	if (nid > 0 &&
 		of_read_number(associativity, 1) >= distance_ref_points_depth) {
@@ -244,7 +244,7 @@ static int associativity_to_nid(const __be32 *associativity)
  */
 static int of_node_to_nid_single(struct device_node *device)
 {
-	int nid = -1;
+	int nid = NUMA_NO_NODE;
 	const __be32 *tmp;
 
 	tmp = of_get_associativity(device);
@@ -256,7 +256,7 @@ static int of_node_to_nid_single(struct device_node *device)
 /* Walk the device tree upwards, looking for an associativity id */
 int of_node_to_nid(struct device_node *device)
 {
-	int nid = -1;
+	int nid = NUMA_NO_NODE;
 
 	of_node_get(device);
 	while (device) {
@@ -454,7 +454,7 @@ static int of_drconf_to_nid_single(struct drmem_lmb *lmb)
  */
 static int numa_setup_cpu(unsigned long lcpu)
 {
-	int nid = -1;
+	int nid = NUMA_NO_NODE;
 	struct device_node *cpu;
 
 	/*
@@ -930,7 +930,7 @@ static int hot_add_drconf_scn_to_nid(unsigned long scn_addr)
 {
 	struct drmem_lmb *lmb;
 	unsigned long lmb_size;
-	int nid = -1;
+	int nid = NUMA_NO_NODE;
 
 	lmb_size = drmem_lmb_size();
 
@@ -960,7 +960,7 @@ static int hot_add_drconf_scn_to_nid(unsigned long scn_addr)
 static int hot_add_node_scn_to_nid(unsigned long scn_addr)
 {
 	struct device_node *memory;
-	int nid = -1;
+	int nid = NUMA_NO_NODE;
 
 	for_each_node_by_type(memory, "memory") {
 		unsigned long start, size;
diff --git a/arch/powerpc/platforms/powernv/memtrace.c b/arch/powerpc/platforms/powernv/memtrace.c
index 84d038e..1ce3bfc 100644
--- a/arch/powerpc/platforms/powernv/memtrace.c
+++ b/arch/powerpc/platforms/powernv/memtrace.c
@@ -223,7 +223,7 @@ static int memtrace_online(void)
 		ent = &memtrace_array[i];
 
 		/* We have onlined this chunk previously */
-		if (ent->nid == -1)
+		if (ent->nid == NUMA_NO_NODE)
 			continue;
 
 		/* Remove from io mappings */
@@ -257,7 +257,7 @@ static int memtrace_online(void)
 		 */
 		debugfs_remove_recursive(ent->dir);
 		pr_info("Added trace memory back to node %d\n", ent->nid);
-		ent->size = ent->start = ent->nid = -1;
+		ent->size = ent->start = ent->nid = NUMA_NO_NODE;
 	}
 	if (ret)
 		return ret;
diff --git a/arch/sparc/kernel/auxio_32.c b/arch/sparc/kernel/auxio_32.c
index a32d588..39f6c59 100644
--- a/arch/sparc/kernel/auxio_32.c
+++ b/arch/sparc/kernel/auxio_32.c
@@ -120,7 +120,7 @@ void __init auxio_power_probe(void)
 	node = prom_searchsiblings(node, "obio");
 	node = prom_getchild(node);
 	node = prom_searchsiblings(node, "power");
-	if (node == 0 || (s32)node == -1)
+	if (node == 0 || (s32)node == NUMA_NO_NODE)
 		return;
 
 	/* Map the power control register. */
diff --git a/arch/sparc/kernel/pci_fire.c b/arch/sparc/kernel/pci_fire.c
index be71ae0..474d3be 100644
--- a/arch/sparc/kernel/pci_fire.c
+++ b/arch/sparc/kernel/pci_fire.c
@@ -416,7 +416,7 @@ static int pci_fire_pbm_init(struct pci_pbm_info *pbm,
 	struct device_node *dp = op->dev.of_node;
 	int err;
 
-	pbm->numa_node = -1;
+	pbm->numa_node = NUMA_NO_NODE;
 
 	pbm->pci_ops = &sun4u_pci_ops;
 	pbm->config_space_reg_bits = 12;
diff --git a/arch/sparc/kernel/pci_schizo.c b/arch/sparc/kernel/pci_schizo.c
index 934b97c..87bb231 100644
--- a/arch/sparc/kernel/pci_schizo.c
+++ b/arch/sparc/kernel/pci_schizo.c
@@ -1347,7 +1347,7 @@ static int schizo_pbm_init(struct pci_pbm_info *pbm,
 	pbm->next = pci_pbm_root;
 	pci_pbm_root = pbm;
 
-	pbm->numa_node = -1;
+	pbm->numa_node = NUMA_NO_NODE;
 
 	pbm->pci_ops = &sun4u_pci_ops;
 	pbm->config_space_reg_bits = 8;
diff --git a/arch/sparc/kernel/pcic.c b/arch/sparc/kernel/pcic.c
index ee4c9a9..d5fe898 100644
--- a/arch/sparc/kernel/pcic.c
+++ b/arch/sparc/kernel/pcic.c
@@ -476,7 +476,7 @@ static void pcic_map_pci_device(struct linux_pcic *pcic,
 	unsigned long flags;
 	int j;
 
-	if (node == 0 || node == -1) {
+	if (node == 0 || node == NUMA_NO_NODE) {
 		strcpy(namebuf, "???");
 	} else {
 		prom_getstring(node, "name", namebuf, 63); namebuf[63] = 0;
@@ -535,7 +535,7 @@ pcic_fill_irq(struct linux_pcic *pcic, struct pci_dev *dev, int node)
 	int i, ivec;
 	char namebuf[64];
 
-	if (node == 0 || node == -1) {
+	if (node == 0 || node == NUMA_NO_NODE) {
 		strcpy(namebuf, "???");
 	} else {
 		prom_getstring(node, "name", namebuf, sizeof(namebuf));
@@ -625,7 +625,7 @@ void pcibios_fixup_bus(struct pci_bus *bus)
 	list_for_each_entry(dev, &bus->devices, bus_list) {
 		node = pdev_to_pnode(&pcic->pbm, dev);
 		if(node == 0)
-			node = -1;
+			node = NUMA_NO_NODE;
 
 		/* cookies */
 		pcp = pci_devcookie_alloc();
diff --git a/arch/sparc/kernel/psycho_common.c b/arch/sparc/kernel/psycho_common.c
index 81aa91e..dcbf492 100644
--- a/arch/sparc/kernel/psycho_common.c
+++ b/arch/sparc/kernel/psycho_common.c
@@ -454,7 +454,7 @@ void psycho_pbm_init_common(struct pci_pbm_info *pbm, struct platform_device *op
 	struct device_node *dp = op->dev.of_node;
 
 	pbm->name = dp->full_name;
-	pbm->numa_node = -1;
+	pbm->numa_node = NUMA_NO_NODE;
 	pbm->chip_type = chip_type;
 	pbm->chip_version = of_getintprop_default(dp, "version#", 0);
 	pbm->chip_revision = of_getintprop_default(dp, "module-revision#", 0);
diff --git a/arch/sparc/kernel/sbus.c b/arch/sparc/kernel/sbus.c
index c133dfc..28a4aa9 100644
--- a/arch/sparc/kernel/sbus.c
+++ b/arch/sparc/kernel/sbus.c
@@ -561,7 +561,7 @@ static void __init sbus_iommu_init(struct platform_device *op)
 
 	op->dev.archdata.iommu = iommu;
 	op->dev.archdata.stc = strbuf;
-	op->dev.archdata.numa_node = -1;
+	op->dev.archdata.numa_node = NUMA_NO_NODE;
 
 	reg_base = regs + SYSIO_IOMMUREG_BASE;
 	iommu->iommu_control = reg_base + IOMMU_CONTROL;
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 3c8aac2..cb1bed1 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -976,13 +976,13 @@ static u64 __init memblock_nid_range_sun4u(u64 start, u64 end, int *nid)
 {
 	int prev_nid, new_nid;
 
-	prev_nid = -1;
+	prev_nid = NUMA_NO_NODE;
 	for ( ; start < end; start += PAGE_SIZE) {
 		for (new_nid = 0; new_nid < num_node_masks; new_nid++) {
 			struct node_mem_mask *p = &node_masks[new_nid];
 
 			if ((start & p->mask) == p->match) {
-				if (prev_nid == -1)
+				if (prev_nid == NUMA_NO_NODE)
 					prev_nid = new_nid;
 				break;
 			}
@@ -1208,7 +1208,7 @@ int of_node_to_nid(struct device_node *dp)
 	md = mdesc_grab();
 
 	count = 0;
-	nid = -1;
+	nid = NUMA_NO_NODE;
 	mdesc_for_each_node_by_name(md, grp, "group") {
 		if (!scan_arcs_for_cfg_handle(md, grp, cfg_handle)) {
 			nid = count;
diff --git a/arch/sparc/prom/init_32.c b/arch/sparc/prom/init_32.c
index d204701..4c6e540 100644
--- a/arch/sparc/prom/init_32.c
+++ b/arch/sparc/prom/init_32.c
@@ -58,7 +58,7 @@ void __init prom_init(struct linux_romvec *rp)
 	prom_nodeops = romvec->pv_nodeops;
 
 	prom_root_node = prom_getsibling(0);
-	if ((prom_root_node == 0) || ((s32)prom_root_node == -1))
+	if ((prom_root_node == 0) || ((s32)prom_root_node == NUMA_NO_NODE))
 		prom_halt();
 
 	if((((unsigned long) prom_nodeops) == 0) || 
diff --git a/arch/sparc/prom/init_64.c b/arch/sparc/prom/init_64.c
index 103aa91..85669c0 100644
--- a/arch/sparc/prom/init_64.c
+++ b/arch/sparc/prom/init_64.c
@@ -36,13 +36,13 @@ void __init prom_init(void *cif_handler)
 	prom_cif_init(cif_handler);
 
 	prom_chosen_node = prom_finddevice(prom_chosen_path);
-	if (!prom_chosen_node || (s32)prom_chosen_node == -1)
+	if (!prom_chosen_node || (s32)prom_chosen_node == NUMA_NO_NODE)
 		prom_halt();
 
 	prom_stdout = prom_getint(prom_chosen_node, "stdout");
 
 	node = prom_finddevice("/openprom");
-	if (!node || (s32)node == -1)
+	if (!node || (s32)node == NUMA_NO_NODE)
 		prom_halt();
 
 	prom_getstring(node, "version", prom_version, sizeof(prom_version));
diff --git a/arch/sparc/prom/tree_32.c b/arch/sparc/prom/tree_32.c
index 0fed893..2d0a204 100644
--- a/arch/sparc/prom/tree_32.c
+++ b/arch/sparc/prom/tree_32.c
@@ -41,11 +41,11 @@ phandle prom_getchild(phandle node)
 {
 	phandle cnode;
 
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return 0;
 
 	cnode = __prom_getchild(node);
-	if (cnode == 0 || (s32)cnode == -1)
+	if (cnode == 0 || (s32)cnode == NUMA_NO_NODE)
 		return 0;
 
 	return cnode;
@@ -73,11 +73,11 @@ phandle prom_getsibling(phandle node)
 {
 	phandle sibnode;
 
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return 0;
 
 	sibnode = __prom_getsibling(node);
-	if (sibnode == 0 || (s32)sibnode == -1)
+	if (sibnode == 0 || (s32)sibnode == NUMA_NO_NODE)
 		return 0;
 
 	return sibnode;
@@ -220,7 +220,7 @@ static char *__prom_nextprop(phandle node, char * oprop)
  */
 char *prom_nextprop(phandle node, char *oprop, char *buffer)
 {
-	if (node == 0 || (s32)node == -1)
+	if (node == 0 || (s32)node == NUMA_NO_NODE)
 		return "";
 
 	return __prom_nextprop(node, oprop);
@@ -304,7 +304,7 @@ phandle prom_inst2pkg(int inst)
 	node = (*romvec->pv_v2devops.v2_inst2pkg)(inst);
 	restore_current();
 	spin_unlock_irqrestore(&prom_lock, flags);
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return 0;
 	return node;
 }
diff --git a/arch/sparc/prom/tree_64.c b/arch/sparc/prom/tree_64.c
index 989e799..2b4c515 100644
--- a/arch/sparc/prom/tree_64.c
+++ b/arch/sparc/prom/tree_64.c
@@ -44,10 +44,10 @@ phandle prom_getchild(phandle node)
 {
 	phandle cnode;
 
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return 0;
 	cnode = __prom_getchild(node);
-	if ((s32)cnode == -1)
+	if ((s32)cnode == NUMA_NO_NODE)
 		return 0;
 	return cnode;
 }
@@ -57,10 +57,10 @@ inline phandle prom_getparent(phandle node)
 {
 	phandle cnode;
 
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return 0;
 	cnode = prom_node_to_node("parent", node);
-	if ((s32)cnode == -1)
+	if ((s32)cnode == NUMA_NO_NODE)
 		return 0;
 	return cnode;
 }
@@ -77,10 +77,10 @@ phandle prom_getsibling(phandle node)
 {
 	phandle sibnode;
 
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return 0;
 	sibnode = __prom_getsibling(node);
-	if ((s32)sibnode == -1)
+	if ((s32)sibnode == NUMA_NO_NODE)
 		return 0;
 
 	return sibnode;
@@ -241,7 +241,7 @@ char *prom_firstprop(phandle node, char *buffer)
 	unsigned long args[7];
 
 	*buffer = 0;
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return buffer;
 
 	args[0] = (unsigned long) prom_nextprop_name;
@@ -267,7 +267,7 @@ char *prom_nextprop(phandle node, const char *oprop, char *buffer)
 	unsigned long args[7];
 	char buf[32];
 
-	if ((s32)node == -1) {
+	if ((s32)node == NUMA_NO_NODE) {
 		*buffer = 0;
 		return buffer;
 	}
@@ -370,7 +370,7 @@ inline phandle prom_inst2pkg(int inst)
 	p1275_cmd_direct(args);
 
 	node = (int) args[4];
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return 0;
 	return node;
 }
diff --git a/arch/x86/include/asm/pci.h b/arch/x86/include/asm/pci.h
index 6629636..dee2a31 100644
--- a/arch/x86/include/asm/pci.h
+++ b/arch/x86/include/asm/pci.h
@@ -141,7 +141,7 @@ cpumask_of_pcibus(const struct pci_bus *bus)
 	int node;
 
 	node = __pcibus_to_node(bus);
-	return (node == -1) ? cpu_online_mask :
+	return (node == NUMA_NO_NODE) ? cpu_online_mask :
 			      cpumask_of_node(node);
 }
 #endif
diff --git a/arch/x86/kernel/apic/x2apic_uv_x.c b/arch/x86/kernel/apic/x2apic_uv_x.c
index 391f358..3c3378a 100644
--- a/arch/x86/kernel/apic/x2apic_uv_x.c
+++ b/arch/x86/kernel/apic/x2apic_uv_x.c
@@ -1390,7 +1390,7 @@ static void __init build_socket_tables(void)
 	}
 
 	/* Set socket -> node values: */
-	lnid = -1;
+	lnid = NUMA_NO_NODE;
 	for_each_present_cpu(cpu) {
 		int nid = cpu_to_node(cpu);
 		int apicid, sockid;
@@ -1521,7 +1521,7 @@ static void __init uv_system_init_hub(void)
 			new_hub->pnode = 0xffff;
 
 		new_hub->numa_blade_id = uv_node_to_blade_id(nodeid);
-		new_hub->memory_nid = -1;
+		new_hub->memory_nid = NUMA_NO_NODE;
 		new_hub->nr_possible_cpus = 0;
 		new_hub->nr_online_cpus = 0;
 	}
@@ -1538,7 +1538,7 @@ static void __init uv_system_init_hub(void)
 
 		uv_cpu_info_per(cpu)->p_uv_hub_info = uv_hub_info_list(nodeid);
 		uv_cpu_info_per(cpu)->blade_cpu_id = uv_cpu_hub_info(cpu)->nr_possible_cpus++;
-		if (uv_cpu_hub_info(cpu)->memory_nid == -1)
+		if (uv_cpu_hub_info(cpu)->memory_nid == NUMA_NO_NODE)
 			uv_cpu_hub_info(cpu)->memory_nid = cpu_to_node(cpu);
 
 		/* Init memoryless node: */
diff --git a/arch/x86/kernel/smpboot.c b/arch/x86/kernel/smpboot.c
index a9134d1..c1d45dc 100644
--- a/arch/x86/kernel/smpboot.c
+++ b/arch/x86/kernel/smpboot.c
@@ -841,7 +841,7 @@ wakeup_secondary_cpu_via_init(int phys_apicid, unsigned long start_eip)
 /* reduce the number of lines printed when booting a large cpu count system */
 static void announce_cpu(int cpu, int apicid)
 {
-	static int current_node = -1;
+	static int current_node = NUMA_NO_NODE;
 	int node = early_cpu_to_node(cpu);
 	static int width, node_width;
 
diff --git a/arch/x86/platform/olpc/olpc_dt.c b/arch/x86/platform/olpc/olpc_dt.c
index 24d2175..7098127 100644
--- a/arch/x86/platform/olpc/olpc_dt.c
+++ b/arch/x86/platform/olpc/olpc_dt.c
@@ -29,10 +29,10 @@ static phandle __init olpc_dt_getsibling(phandle node)
 	const void *args[] = { (void *)node };
 	void *res[] = { &node };
 
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return 0;
 
-	if (olpc_ofw("peer", args, res) || (s32)node == -1)
+	if (olpc_ofw("peer", args, res) || (s32)node == NUMA_NO_NODE)
 		return 0;
 
 	return node;
@@ -43,10 +43,10 @@ static phandle __init olpc_dt_getchild(phandle node)
 	const void *args[] = { (void *)node };
 	void *res[] = { &node };
 
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return 0;
 
-	if (olpc_ofw("child", args, res) || (s32)node == -1) {
+	if (olpc_ofw("child", args, res) || (s32)node == NUMA_NO_NODE) {
 		pr_err("PROM: %s: fetching child failed!\n", __func__);
 		return 0;
 	}
@@ -60,7 +60,7 @@ static int __init olpc_dt_getproplen(phandle node, const char *prop)
 	int len;
 	void *res[] = { &len };
 
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return -1;
 
 	if (olpc_ofw("getproplen", args, res)) {
@@ -100,7 +100,7 @@ static int __init olpc_dt_nextprop(phandle node, char *prev, char *buf)
 
 	buf[0] = '\0';
 
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return -1;
 
 	if (olpc_ofw("nextprop", args, res) || success != 1)
@@ -115,7 +115,7 @@ static int __init olpc_dt_pkg2path(phandle node, char *buf,
 	const void *args[] = { (void *)node, buf, (void *)buflen };
 	void *res[] = { len };
 
-	if ((s32)node == -1)
+	if ((s32)node == NUMA_NO_NODE)
 		return -1;
 
 	if (olpc_ofw("package-to-path", args, res) || *len < 1)
@@ -176,7 +176,7 @@ static phandle __init olpc_dt_finddevice(const char *path)
 		return 0;
 	}
 
-	if ((s32) node == -1)
+	if ((s32) node == NUMA_NO_NODE)
 		return 0;
 
 	return node;
diff --git a/drivers/block/mtip32xx/mtip32xx.c b/drivers/block/mtip32xx/mtip32xx.c
index a7daa8a..b889452 100644
--- a/drivers/block/mtip32xx/mtip32xx.c
+++ b/drivers/block/mtip32xx/mtip32xx.c
@@ -4084,9 +4084,9 @@ static int get_least_used_cpu_on_node(int node)
 /* Helper for selecting a node in round robin mode */
 static inline int mtip_get_next_rr_node(void)
 {
-	static int next_node = -1;
+	static int next_node = NUMA_NO_NODE;
 
-	if (next_node == -1) {
+	if (next_node == NUMA_NO_NODE) {
 		next_node = first_online_node;
 		return next_node;
 	}
diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index f1a441ab..1aeefc7 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -386,7 +386,8 @@ EXPORT_SYMBOL(dma_issue_pending_all);
 static bool dma_chan_is_local(struct dma_chan *chan, int cpu)
 {
 	int node = dev_to_node(chan->device->dev);
-	return node == -1 || cpumask_test_cpu(cpu, cpumask_of_node(node));
+	return node == NUMA_NO_NODE ||
+		cpumask_test_cpu(cpu, cpumask_of_node(node));
 }
 
 /**
diff --git a/drivers/infiniband/hw/hfi1/affinity.c b/drivers/infiniband/hw/hfi1/affinity.c
index 2baf38c..3e8acb8 100644
--- a/drivers/infiniband/hw/hfi1/affinity.c
+++ b/drivers/infiniband/hw/hfi1/affinity.c
@@ -777,7 +777,7 @@ void hfi1_dev_affinity_clean_up(struct hfi1_devdata *dd)
 	_dev_comp_vect_cpu_mask_clean_up(dd, entry);
 unlock:
 	mutex_unlock(&node_affinity.lock);
-	dd->node = -1;
+	dd->node = NUMA_NO_NODE;
 }
 
 /*
diff --git a/drivers/infiniband/hw/hfi1/init.c b/drivers/infiniband/hw/hfi1/init.c
index 0904490..0bf4577 100644
--- a/drivers/infiniband/hw/hfi1/init.c
+++ b/drivers/infiniband/hw/hfi1/init.c
@@ -1303,7 +1303,7 @@ static struct hfi1_devdata *hfi1_alloc_devdata(struct pci_dev *pdev,
 		dd->unit = ret;
 		list_add(&dd->list, &hfi1_dev_list);
 	}
-	dd->node = -1;
+	dd->node = NUMA_NO_NODE;
 
 	spin_unlock_irqrestore(&hfi1_devs_lock, flags);
 	idr_preload_end();
diff --git a/drivers/iommu/dmar.c b/drivers/iommu/dmar.c
index d9c748b..86a9c19 100644
--- a/drivers/iommu/dmar.c
+++ b/drivers/iommu/dmar.c
@@ -477,7 +477,7 @@ static int dmar_parse_one_rhsa(struct acpi_dmar_header *header, void *arg)
 			int node = acpi_map_pxm_to_node(rhsa->proximity_domain);
 
 			if (!node_online(node))
-				node = -1;
+				node = NUMA_NO_NODE;
 			drhd->iommu->node = node;
 			return 0;
 		}
@@ -1062,7 +1062,7 @@ static int alloc_iommu(struct dmar_drhd_unit *drhd)
 	iommu->msagaw = msagaw;
 	iommu->segment = drhd->segment;
 
-	iommu->node = -1;
+	iommu->node = NUMA_NO_NODE;
 
 	ver = readl(iommu->reg + DMAR_VER_REG);
 	pr_info("%s: reg_base_addr %llx ver %d:%d cap %llx ecap %llx\n",
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index f3ccf02..9f6fb13 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -1772,7 +1772,7 @@ static struct dmar_domain *alloc_domain(int flags)
 		return NULL;
 
 	memset(domain, 0, sizeof(*domain));
-	domain->nid = -1;
+	domain->nid = NUMA_NO_NODE;
 	domain->flags = flags;
 	domain->has_iotlb_device = false;
 	INIT_LIST_HEAD(&domain->devices);
diff --git a/drivers/misc/sgi-xp/xpc_uv.c b/drivers/misc/sgi-xp/xpc_uv.c
index 0441abe..eef36dd 100644
--- a/drivers/misc/sgi-xp/xpc_uv.c
+++ b/drivers/misc/sgi-xp/xpc_uv.c
@@ -61,7 +61,7 @@ static struct xpc_heartbeat_uv *xpc_heartbeat_uv;
 					 XPC_NOTIFY_MSG_SIZE_UV)
 #define XPC_NOTIFY_IRQ_NAME		"xpc_notify"
 
-static int xpc_mq_node = -1;
+static int xpc_mq_node = NUMA_NO_NODE;
 
 static struct xpc_gru_mq_uv *xpc_activate_mq_uv;
 static struct xpc_gru_mq_uv *xpc_notify_mq_uv;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 113b38e..4fae85c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6414,7 +6414,7 @@ int ixgbe_setup_tx_resources(struct ixgbe_ring *tx_ring)
 {
 	struct device *dev = tx_ring->dev;
 	int orig_node = dev_to_node(dev);
-	int ring_node = -1;
+	int ring_node = NUMA_NO_NODE;
 	int size;
 
 	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
@@ -6508,7 +6508,7 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 {
 	struct device *dev = rx_ring->dev;
 	int orig_node = dev_to_node(dev);
-	int ring_node = -1;
+	int ring_node = NUMA_NO_NODE;
 	int size;
 
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
diff --git a/init/init_task.c b/init/init_task.c
index 5aebe3b..6641836 100644
--- a/init/init_task.c
+++ b/init/init_task.c
@@ -154,7 +154,7 @@ struct task_struct init_task
 	.vtime.state	= VTIME_SYS,
 #endif
 #ifdef CONFIG_NUMA_BALANCING
-	.numa_preferred_nid = -1,
+	.numa_preferred_nid = NUMA_NO_NODE,
 	.numa_group	= NULL,
 	.numa_faults	= NULL,
 #endif
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 087d18d..77f3d94 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -675,7 +675,7 @@ __kthread_create_worker(int cpu, unsigned int flags,
 {
 	struct kthread_worker *worker;
 	struct task_struct *task;
-	int node = -1;
+	int node = NUMA_NO_NODE;
 
 	worker = kzalloc(sizeof(*worker), GFP_KERNEL);
 	if (!worker)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index ee271bb..d830fa7 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1161,7 +1161,7 @@ void init_numa_balancing(unsigned long clone_flags, struct task_struct *p)
 
 	/* New address space, reset the preferred nid */
 	if (!(clone_flags & CLONE_VM)) {
-		p->numa_preferred_nid = -1;
+		p->numa_preferred_nid = NUMA_NO_NODE;
 		return;
 	}
 
@@ -1181,13 +1181,13 @@ void init_numa_balancing(unsigned long clone_flags, struct task_struct *p)
 
 static void account_numa_enqueue(struct rq *rq, struct task_struct *p)
 {
-	rq->nr_numa_running += (p->numa_preferred_nid != -1);
+	rq->nr_numa_running += (p->numa_preferred_nid != NUMA_NO_NODE);
 	rq->nr_preferred_running += (p->numa_preferred_nid == task_node(p));
 }
 
 static void account_numa_dequeue(struct rq *rq, struct task_struct *p)
 {
-	rq->nr_numa_running -= (p->numa_preferred_nid != -1);
+	rq->nr_numa_running -= (p->numa_preferred_nid != NUMA_NO_NODE);
 	rq->nr_preferred_running -= (p->numa_preferred_nid == task_node(p));
 }
 
@@ -1401,7 +1401,7 @@ bool should_numa_migrate_memory(struct task_struct *p, struct page * page,
 	 * two full passes of the "multi-stage node selection" test that is
 	 * executed below.
 	 */
-	if ((p->numa_preferred_nid == -1 || p->numa_scan_seq <= 4) &&
+	if ((p->numa_preferred_nid == NUMA_NO_NODE || p->numa_scan_seq <= 4) &&
 	    (cpupid_pid_unset(last_cpupid) || cpupid_match_pid(p, last_cpupid)))
 		return true;
 
@@ -1849,7 +1849,7 @@ static void numa_migrate_preferred(struct task_struct *p)
 	unsigned long interval = HZ;
 
 	/* This task has no NUMA fault statistics yet */
-	if (unlikely(p->numa_preferred_nid == -1 || !p->numa_faults))
+	if (unlikely(p->numa_preferred_nid == NUMA_NO_NODE || !p->numa_faults))
 		return;
 
 	/* Periodically retry migrating the task to the preferred node */
@@ -2096,7 +2096,7 @@ static int preferred_group_nid(struct task_struct *p, int nid)
 
 static void task_numa_placement(struct task_struct *p)
 {
-	int seq, nid, max_nid = -1;
+	int seq, nid, max_nid = NUMA_NO_NODE;
 	unsigned long max_faults = 0;
 	unsigned long fault_types[2] = { 0, 0 };
 	unsigned long total_faults;
@@ -2639,7 +2639,8 @@ static void update_scan_period(struct task_struct *p, int new_cpu)
 		 * the preferred node.
 		 */
 		if (dst_nid == p->numa_preferred_nid ||
-		    (p->numa_preferred_nid != -1 && src_nid != p->numa_preferred_nid))
+		    (p->numa_preferred_nid != NUMA_NO_NODE &&
+			src_nid != p->numa_preferred_nid))
 			return;
 	}
 
diff --git a/lib/cpumask.c b/lib/cpumask.c
index 8d666ab..a089c3f 100644
--- a/lib/cpumask.c
+++ b/lib/cpumask.c
@@ -206,7 +206,7 @@ unsigned int cpumask_local_spread(unsigned int i, int node)
 	/* Wrap: we always want a cpu. */
 	i %= num_online_cpus();
 
-	if (node == -1) {
+	if (node == NUMA_NO_NODE) {
 		for_each_cpu(cpu, cpu_online_mask)
 			if (i-- == 0)
 				return cpu;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 55478ab..5ccf89e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1480,7 +1480,7 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	struct anon_vma *anon_vma = NULL;
 	struct page *page;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
-	int page_nid = -1, this_nid = numa_node_id();
+	int page_nid = NUMA_NO_NODE, this_nid = numa_node_id();
 	int target_nid, last_cpupid = -1;
 	bool page_locked;
 	bool migrated = false;
@@ -1526,7 +1526,7 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	 */
 	page_locked = trylock_page(page);
 	target_nid = mpol_misplaced(page, vma, haddr);
-	if (target_nid == -1) {
+	if (target_nid == NUMA_NO_NODE) {
 		/* If the page was locked, there are no parallel migrations */
 		if (page_locked)
 			goto clear_pmdnuma;
@@ -1534,7 +1534,7 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 
 	/* Migration could have started since the pmd_trans_migrating check */
 	if (!page_locked) {
-		page_nid = -1;
+		page_nid = NUMA_NO_NODE;
 		if (!get_page_unless_zero(page))
 			goto out_unlock;
 		spin_unlock(vmf->ptl);
@@ -1556,14 +1556,14 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	if (unlikely(!pmd_same(pmd, *vmf->pmd))) {
 		unlock_page(page);
 		put_page(page);
-		page_nid = -1;
+		page_nid = NUMA_NO_NODE;
 		goto out_unlock;
 	}
 
 	/* Bail if we fail to protect against THP splits for any reason */
 	if (unlikely(!anon_vma)) {
 		put_page(page);
-		page_nid = -1;
+		page_nid = NUMA_NO_NODE;
 		goto clear_pmdnuma;
 	}
 
@@ -1625,7 +1625,7 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	if (anon_vma)
 		page_unlock_anon_vma_read(anon_vma);
 
-	if (page_nid != -1)
+	if (page_nid != NUMA_NO_NODE)
 		task_numa_fault(last_cpupid, page_nid, HPAGE_PMD_NR,
 				flags);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c007fb5..b769db7 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -887,7 +887,7 @@ static struct page *dequeue_huge_page_nodemask(struct hstate *h, gfp_t gfp_mask,
 	struct zonelist *zonelist;
 	struct zone *zone;
 	struct zoneref *z;
-	int node = -1;
+	int node = NUMA_NO_NODE;
 
 	zonelist = node_zonelist(nid, gfp_mask);
 
diff --git a/mm/ksm.c b/mm/ksm.c
index 5b0894b..d5f8834 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -597,7 +597,7 @@ static struct stable_node *alloc_stable_node_chain(struct stable_node *dup,
 		chain->chain_prune_time = jiffies;
 		chain->rmap_hlist_len = STABLE_NODE_CHAIN;
 #if defined (CONFIG_DEBUG_VM) && defined(CONFIG_NUMA)
-		chain->nid = -1; /* debug */
+		chain->nid = NUMA_NO_NODE; /* debug */
 #endif
 		ksm_stable_node_chains++;
 
diff --git a/mm/memory.c b/mm/memory.c
index 4ad2d29..c0e0348 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3564,7 +3564,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL;
-	int page_nid = -1;
+	int page_nid = NUMA_NO_NODE;
 	int last_cpupid;
 	int target_nid;
 	bool migrated = false;
@@ -3631,7 +3631,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 	target_nid = numa_migrate_prep(page, vma, vmf->address, page_nid,
 			&flags);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
-	if (target_nid == -1) {
+	if (target_nid == NUMA_NO_NODE) {
 		put_page(page);
 		goto out;
 	}
@@ -3645,7 +3645,7 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 		flags |= TNF_MIGRATE_FAIL;
 
 out:
-	if (page_nid != -1)
+	if (page_nid != NUMA_NO_NODE)
 		task_numa_fault(last_cpupid, page_nid, 1, flags);
 	return 0;
 }
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2b2b3cc..70e02f8 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -688,9 +688,9 @@ static void node_states_check_changes_online(unsigned long nr_pages,
 {
 	int nid = zone_to_nid(zone);
 
-	arg->status_change_nid = -1;
-	arg->status_change_nid_normal = -1;
-	arg->status_change_nid_high = -1;
+	arg->status_change_nid = NUMA_NO_NODE;
+	arg->status_change_nid_normal = NUMA_NO_NODE;
+	arg->status_change_nid_high = NUMA_NO_NODE;
 
 	if (!node_state(nid, N_MEMORY))
 		arg->status_change_nid = nid;
@@ -1484,9 +1484,9 @@ static void node_states_check_changes_offline(unsigned long nr_pages,
 	unsigned long present_pages = 0;
 	enum zone_type zt;
 
-	arg->status_change_nid = -1;
-	arg->status_change_nid_normal = -1;
-	arg->status_change_nid_high = -1;
+	arg->status_change_nid = NUMA_NO_NODE;
+	arg->status_change_nid_normal = NUMA_NO_NODE;
+	arg->status_change_nid_high = NUMA_NO_NODE;
 
 	/*
 	 * Check whether node_states[N_NORMAL_MEMORY] will be changed.
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 5837a06..e4f8248 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2278,7 +2278,7 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	unsigned long pgoff;
 	int thiscpu = raw_smp_processor_id();
 	int thisnid = cpu_to_node(thiscpu);
-	int polnid = -1;
+	int polnid = NUMA_NO_NODE;
 	int ret = -1;
 
 	pol = get_vma_policy(vma, addr);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a919ba5..9d38d9c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5846,7 +5846,7 @@ int __meminit __early_pfn_to_nid(unsigned long pfn,
 		return state->last_nid;
 
 	nid = memblock_search_pfn_nid(pfn, &start_pfn, &end_pfn);
-	if (nid != -1) {
+	if (nid != NUMA_NO_NODE) {
 		state->last_start = start_pfn;
 		state->last_end = end_pfn;
 		state->last_nid = nid;
@@ -6607,7 +6607,7 @@ unsigned long __init node_map_pfn_alignment(void)
 {
 	unsigned long accl_mask = 0, last_end = 0;
 	unsigned long start, end, mask;
-	int last_nid = -1;
+	int last_nid = NUMA_NO_NODE;
 	int i, nid;
 
 	for_each_mem_pfn_range(i, MAX_NUMNODES, &start, &end, &nid) {
diff --git a/mm/page_ext.c b/mm/page_ext.c
index ae44f7a..dfb0206 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -300,7 +300,7 @@ static int __meminit online_page_ext(unsigned long start_pfn,
 	start = SECTION_ALIGN_DOWN(start_pfn);
 	end = SECTION_ALIGN_UP(start_pfn + nr_pages);
 
-	if (nid == -1) {
+	if (nid == NUMA_NO_NODE) {
 		/*
 		 * In this case, "nid" already exists and contains valid memory.
 		 * "start_pfn" passed to us is a pfn which is an arg for
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 6ac9198..af3a746 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3625,7 +3625,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	pkt_dev->svlan_cfi = 0;
 	pkt_dev->svlan_id = 0xffff;
 	pkt_dev->burst = 1;
-	pkt_dev->node = -1;
+	pkt_dev->node = NUMA_NO_NODE;
 
 	err = pktgen_setup_dev(t->net, pkt_dev, ifname);
 	if (err)
diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index 86e1e37..0c56ae2 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -101,7 +101,7 @@ static inline struct qrtr_sock *qrtr_sk(struct sock *sk)
 	return container_of(sk, struct qrtr_sock, sk);
 }
 
-static unsigned int qrtr_local_nid = -1;
+static unsigned int qrtr_local_nid = NUMA_NO_NODE;
 
 /* for node ids */
 static RADIX_TREE(qrtr_nodes, GFP_KERNEL);
diff --git a/tools/perf/bench/numa.c b/tools/perf/bench/numa.c
index 4419551..e0ad5f1 100644
--- a/tools/perf/bench/numa.c
+++ b/tools/perf/bench/numa.c
@@ -298,7 +298,7 @@ static cpu_set_t bind_to_node(int target_node)
 
 	CPU_ZERO(&mask);
 
-	if (target_node == -1) {
+	if (target_node == NUMA_NO_NODE) {
 		for (cpu = 0; cpu < g->p.nr_cpus; cpu++)
 			CPU_SET(cpu, &mask);
 	} else {
@@ -339,7 +339,7 @@ static void bind_to_memnode(int node)
 	unsigned long nodemask;
 	int ret;
 
-	if (node == -1)
+	if (node == NUMA_NO_NODE)
 		return;
 
 	BUG_ON(g->p.nr_nodes > (int)sizeof(nodemask)*8);
@@ -1363,7 +1363,7 @@ static void init_thread_data(void)
 		int cpu;
 
 		/* Allow all nodes by default: */
-		td->bind_node = -1;
+		td->bind_node = NUMA_NO_NODE;
 
 		/* Allow all CPUs by default: */
 		CPU_ZERO(&td->bind_cpumask);
-- 
2.7.4
