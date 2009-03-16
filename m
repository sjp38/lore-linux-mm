Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1960F6B0055
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 13:51:27 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 03/27] Do not check NUMA node ID when the caller knows the node is valid
Date: Mon, 16 Mar 2009 17:53:17 +0000
Message-Id: <1237226020-14057-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
References: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Callers of alloc_pages_node() can optionally specify -1 as a node to mean
"allocate from the current node". However, a number of the callers in fast
paths know for a fact their node is valid. To avoid a comparison and branch,
this patch adds alloc_pages_exact_node() that only checks the nid with
VM_BUG_ON(). Callers that know their node is valid are then converted.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
---
 arch/ia64/hp/common/sba_iommu.c   |    2 +-
 arch/ia64/kernel/mca.c            |    3 +--
 arch/ia64/kernel/uncached.c       |    3 ++-
 arch/ia64/sn/pci/pci_dma.c        |    3 ++-
 arch/powerpc/platforms/cell/ras.c |    2 +-
 arch/x86/kvm/vmx.c                |    2 +-
 drivers/misc/sgi-gru/grufile.c    |    2 +-
 drivers/misc/sgi-xp/xpc_uv.c      |    2 +-
 include/linux/gfp.h               |    9 +++++++++
 include/linux/mm.h                |    1 -
 kernel/profile.c                  |    8 ++++----
 mm/filemap.c                      |    2 +-
 mm/hugetlb.c                      |    4 ++--
 mm/mempolicy.c                    |    2 +-
 mm/migrate.c                      |    2 +-
 mm/slab.c                         |    4 ++--
 mm/slob.c                         |    4 ++--
 17 files changed, 32 insertions(+), 23 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 6d5e6c5..66a3257 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1116,7 +1116,7 @@ sba_alloc_coherent (struct device *dev, size_t size, dma_addr_t *dma_handle, gfp
 #ifdef CONFIG_NUMA
 	{
 		struct page *page;
-		page = alloc_pages_node(ioc->node == MAX_NUMNODES ?
+		page = alloc_pages_exact_node(ioc->node == MAX_NUMNODES ?
 		                        numa_node_id() : ioc->node, flags,
 		                        get_order(size));
 
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index bab1de2..2e614bd 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1829,8 +1829,7 @@ ia64_mca_cpu_init(void *cpu_data)
 			data = mca_bootmem();
 			first_time = 0;
 		} else
-			data = page_address(alloc_pages_node(numa_node_id(),
-					GFP_KERNEL, get_order(sz)));
+			data = __get_free_pages(GFP_KERNEL, get_order(sz));
 		if (!data)
 			panic("Could not allocate MCA memory for cpu %d\n",
 					cpu);
diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index 8eff8c1..6ba72ab 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -98,7 +98,8 @@ static int uncached_add_chunk(struct uncached_pool *uc_pool, int nid)
 
 	/* attempt to allocate a granule's worth of cached memory pages */
 
-	page = alloc_pages_node(nid, GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+	page = alloc_pages_exact_node(nid,
+				GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
 				IA64_GRANULE_SHIFT-PAGE_SHIFT);
 	if (!page) {
 		mutex_unlock(&uc_pool->add_chunk_mutex);
diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index 863f501..2aa52de 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -91,7 +91,8 @@ void *sn_dma_alloc_coherent(struct device *dev, size_t size,
 	 */
 	node = pcibus_to_node(pdev->bus);
 	if (likely(node >=0)) {
-		struct page *p = alloc_pages_node(node, flags, get_order(size));
+		struct page *p = alloc_pages_exact_node(node,
+						flags, get_order(size));
 
 		if (likely(p))
 			cpuaddr = page_address(p);
diff --git a/arch/powerpc/platforms/cell/ras.c b/arch/powerpc/platforms/cell/ras.c
index 5f961c4..16ba671 100644
--- a/arch/powerpc/platforms/cell/ras.c
+++ b/arch/powerpc/platforms/cell/ras.c
@@ -122,7 +122,7 @@ static int __init cbe_ptcal_enable_on_node(int nid, int order)
 
 	area->nid = nid;
 	area->order = order;
-	area->pages = alloc_pages_node(area->nid, GFP_KERNEL, area->order);
+	area->pages = alloc_pages_exact_node(area->nid, GFP_KERNEL, area->order);
 
 	if (!area->pages)
 		goto out_free_area;
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 7611af5..cca119a 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -1244,7 +1244,7 @@ static struct vmcs *alloc_vmcs_cpu(int cpu)
 	struct page *pages;
 	struct vmcs *vmcs;
 
-	pages = alloc_pages_node(node, GFP_KERNEL, vmcs_config.order);
+	pages = alloc_pages_exact_node(node, GFP_KERNEL, vmcs_config.order);
 	if (!pages)
 		return NULL;
 	vmcs = page_address(pages);
diff --git a/drivers/misc/sgi-gru/grufile.c b/drivers/misc/sgi-gru/grufile.c
index 6509838..52d4160 100644
--- a/drivers/misc/sgi-gru/grufile.c
+++ b/drivers/misc/sgi-gru/grufile.c
@@ -309,7 +309,7 @@ static int gru_init_tables(unsigned long gru_base_paddr, void *gru_base_vaddr)
 		pnode = uv_node_to_pnode(nid);
 		if (gru_base[bid])
 			continue;
-		page = alloc_pages_node(nid, GFP_KERNEL, order);
+		page = alloc_pages_exact_node(nid, GFP_KERNEL, order);
 		if (!page)
 			goto fail;
 		gru_base[bid] = page_address(page);
diff --git a/drivers/misc/sgi-xp/xpc_uv.c b/drivers/misc/sgi-xp/xpc_uv.c
index 29c0502..0563350 100644
--- a/drivers/misc/sgi-xp/xpc_uv.c
+++ b/drivers/misc/sgi-xp/xpc_uv.c
@@ -184,7 +184,7 @@ xpc_create_gru_mq_uv(unsigned int mq_size, int cpu, char *irq_name,
 	mq->mmr_blade = uv_cpu_to_blade_id(cpu);
 
 	nid = cpu_to_node(cpu);
-	page = alloc_pages_node(nid, GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+	page = alloc_pages_exact_node(nid, GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
 				pg_order);
 	if (page == NULL) {
 		dev_err(xpc_part, "xpc_create_gru_mq_uv() failed to alloc %d "
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 8736047..59eb093 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -4,6 +4,7 @@
 #include <linux/mmzone.h>
 #include <linux/stddef.h>
 #include <linux/linkage.h>
+#include <linux/mmdebug.h>
 
 struct vm_area_struct;
 
@@ -188,6 +189,14 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
 
+static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
+						unsigned int order)
+{
+	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
+
+	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
+}
+
 #ifdef CONFIG_NUMA
 extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 065cdf8..565e7b2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -7,7 +7,6 @@
 
 #include <linux/gfp.h>
 #include <linux/list.h>
-#include <linux/mmdebug.h>
 #include <linux/mmzone.h>
 #include <linux/rbtree.h>
 #include <linux/prio_tree.h>
diff --git a/kernel/profile.c b/kernel/profile.c
index 7724e04..62e08db 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -371,7 +371,7 @@ static int __cpuinit profile_cpu_callback(struct notifier_block *info,
 		node = cpu_to_node(cpu);
 		per_cpu(cpu_profile_flip, cpu) = 0;
 		if (!per_cpu(cpu_profile_hits, cpu)[1]) {
-			page = alloc_pages_node(node,
+			page = alloc_pages_exact_node(node,
 					GFP_KERNEL | __GFP_ZERO,
 					0);
 			if (!page)
@@ -379,7 +379,7 @@ static int __cpuinit profile_cpu_callback(struct notifier_block *info,
 			per_cpu(cpu_profile_hits, cpu)[1] = page_address(page);
 		}
 		if (!per_cpu(cpu_profile_hits, cpu)[0]) {
-			page = alloc_pages_node(node,
+			page = alloc_pages_exact_node(node,
 					GFP_KERNEL | __GFP_ZERO,
 					0);
 			if (!page)
@@ -570,14 +570,14 @@ static int create_hash_tables(void)
 		int node = cpu_to_node(cpu);
 		struct page *page;
 
-		page = alloc_pages_node(node,
+		page = alloc_pages_exact_node(node,
 				GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
 				0);
 		if (!page)
 			goto out_cleanup;
 		per_cpu(cpu_profile_hits, cpu)[1]
 				= (struct profile_hit *)page_address(page);
-		page = alloc_pages_node(node,
+		page = alloc_pages_exact_node(node,
 				GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
 				0);
 		if (!page)
diff --git a/mm/filemap.c b/mm/filemap.c
index 23acefe..2523d95 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -519,7 +519,7 @@ struct page *__page_cache_alloc(gfp_t gfp)
 {
 	if (cpuset_do_page_mem_spread()) {
 		int n = cpuset_mem_spread_node();
-		return alloc_pages_node(n, gfp, 0);
+		return alloc_pages_exact_node(n, gfp, 0);
 	}
 	return alloc_pages(gfp, 0);
 }
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 107da3d..1e99997 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -630,7 +630,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 	if (h->order >= MAX_ORDER)
 		return NULL;
 
-	page = alloc_pages_node(nid,
+	page = alloc_pages_exact_node(nid,
 		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
 						__GFP_REPEAT|__GFP_NOWARN,
 		huge_page_order(h));
@@ -649,7 +649,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
  * Use a helper variable to find the next node and then
  * copy it back to hugetlb_next_nid afterwards:
  * otherwise there's a window in which a racer might
- * pass invalid nid MAX_NUMNODES to alloc_pages_node.
+ * pass invalid nid MAX_NUMNODES to alloc_pages_exact_node.
  * But we don't need to use a spin_lock here: it really
  * doesn't matter if occasionally a racer chooses the
  * same nid as we do.  Move nid forward in the mask even
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 3eb4a6f..341fbca 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -767,7 +767,7 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 
 static struct page *new_node_page(struct page *page, unsigned long node, int **x)
 {
-	return alloc_pages_node(node, GFP_HIGHUSER_MOVABLE, 0);
+	return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
 }
 
 /*
diff --git a/mm/migrate.c b/mm/migrate.c
index a9eff3f..6bda9c2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -802,7 +802,7 @@ static struct page *new_page_node(struct page *p, unsigned long private,
 
 	*result = &pm->status;
 
-	return alloc_pages_node(pm->node,
+	return alloc_pages_exact_node(pm->node,
 				GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
 }
 
diff --git a/mm/slab.c b/mm/slab.c
index 4d00855..e7f1ded 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1680,7 +1680,7 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		flags |= __GFP_RECLAIMABLE;
 
-	page = alloc_pages_node(nodeid, flags, cachep->gfporder);
+	page = alloc_pages_exact_node(nodeid, flags, cachep->gfporder);
 	if (!page)
 		return NULL;
 
@@ -3210,7 +3210,7 @@ retry:
 		if (local_flags & __GFP_WAIT)
 			local_irq_enable();
 		kmem_flagcheck(cache, flags);
-		obj = kmem_getpages(cache, local_flags, -1);
+		obj = kmem_getpages(cache, local_flags, numa_node_id());
 		if (local_flags & __GFP_WAIT)
 			local_irq_disable();
 		if (obj) {
diff --git a/mm/slob.c b/mm/slob.c
index 52bc8a2..d646a4c 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -46,7 +46,7 @@
  * NUMA support in SLOB is fairly simplistic, pushing most of the real
  * logic down to the page allocator, and simply doing the node accounting
  * on the upper levels. In the event that a node id is explicitly
- * provided, alloc_pages_node() with the specified node id is used
+ * provided, alloc_pages_exact_node() with the specified node id is used
  * instead. The common case (or when the node id isn't explicitly provided)
  * will default to the current node, as per numa_node_id().
  *
@@ -236,7 +236,7 @@ static void *slob_new_page(gfp_t gfp, int order, int node)
 
 #ifdef CONFIG_NUMA
 	if (node != -1)
-		page = alloc_pages_node(node, gfp, order);
+		page = alloc_pages_exact_node(node, gfp, order);
 	else
 #endif
 		page = alloc_pages(gfp, order);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
