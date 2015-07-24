Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id B39336B0253
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:45:58 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so32087468wic.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 07:45:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id it9si4663424wid.64.2015.07.24.07.45.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 07:45:56 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC v2 1/4] mm: make alloc_pages_exact_node pass __GFP_THISNODE
Date: Fri, 24 Jul 2015 16:45:23 +0200
Message-Id: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>

The function alloc_pages_exact_node() was introduced in 6484eb3e2a81 ("page
allocator: do not check NUMA node ID when the caller knows the node is valid")
as an optimized variant of alloc_pages_node(), that doesn't allow the node id
to be -1. Unfortunately the name of the function can easily suggest that the
allocation is restricted to the given node and fails otherwise. In truth, the
node is only preferred, unless __GFP_THISNODE is passed among the gfp flags.

The misleading name has lead to mistakes in the past, see 5265047ac301 ("mm,
thp: really limit transparent hugepage allocation to local node") and
b360edb43f8e ("mm, mempolicy: migrate_to_node should only migrate to node").

To prevent further mistakes and provide a convenience function for allocations
truly restricted to a node, this patch makes alloc_pages_exact_node() pass
__GFP_THISNODE to that effect. The previous implementation of
alloc_pages_exact_node() is copied as __alloc_pages_node() which implies it's
an optimized variant of __alloc_pages_node() not intended for general usage.
All three functions are described in the comment.

Existing callers of alloc_pages_exact_node() are adjusted as follows:
- those that explicitly pass __GFP_THISNODE keep calling
  alloc_pages_exact_node(), but the flag is removed from the call
- others are converted to call __alloc_pages_node(). Some may still pass
  __GFP_THISNODE if they serve as wrappers that get gfp_flags from higher
  layers.

There's exception of sba_alloc_coherent() which open-codes the check for
nid == -1, so it is converted to use alloc_pages_node() instead. This means
it no longer performs some VM_BUG_ON checks, but otherwise the whole patch
makes no functional changes.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
I've dropped non-mm guys from CC for now and marked as RFC until we agree on
the API.

 arch/ia64/hp/common/sba_iommu.c   |  6 +-----
 arch/ia64/kernel/uncached.c       |  2 +-
 arch/ia64/sn/pci/pci_dma.c        |  2 +-
 arch/powerpc/platforms/cell/ras.c |  2 +-
 arch/x86/kvm/vmx.c                |  2 +-
 drivers/misc/sgi-xp/xpc_uv.c      |  2 +-
 include/linux/gfp.h               | 23 +++++++++++++++++++++++
 kernel/profile.c                  |  8 ++++----
 mm/filemap.c                      |  2 +-
 mm/hugetlb.c                      |  7 +++----
 mm/memory-failure.c               |  2 +-
 mm/mempolicy.c                    |  6 ++----
 mm/migrate.c                      |  6 ++----
 mm/slab.c                         |  2 +-
 mm/slob.c                         |  2 +-
 mm/slub.c                         |  2 +-
 16 files changed, 45 insertions(+), 31 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 344387a..a6d6190 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1140,13 +1140,9 @@ sba_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
 
 #ifdef CONFIG_NUMA
 	{
-		int node = ioc->node;
 		struct page *page;
 
-		if (node == NUMA_NO_NODE)
-			node = numa_node_id();
-
-		page = alloc_pages_exact_node(node, flags, get_order(size));
+		page = alloc_pages_node(ioc->node, flags, get_order(size));
 		if (unlikely(!page))
 			return NULL;
 
diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index 20e8a9b..b187c87 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -98,7 +98,7 @@ static int uncached_add_chunk(struct uncached_pool *uc_pool, int nid)
 	/* attempt to allocate a granule's worth of cached memory pages */
 
 	page = alloc_pages_exact_node(nid,
-				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
+				GFP_KERNEL | __GFP_ZERO,
 				IA64_GRANULE_SHIFT-PAGE_SHIFT);
 	if (!page) {
 		mutex_unlock(&uc_pool->add_chunk_mutex);
diff --git a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
index d0853e8..8f59907 100644
--- a/arch/ia64/sn/pci/pci_dma.c
+++ b/arch/ia64/sn/pci/pci_dma.c
@@ -92,7 +92,7 @@ static void *sn_dma_alloc_coherent(struct device *dev, size_t size,
 	 */
 	node = pcibus_to_node(pdev->bus);
 	if (likely(node >=0)) {
-		struct page *p = alloc_pages_exact_node(node,
+		struct page *p = __alloc_pages_node(node,
 						flags, get_order(size));
 
 		if (likely(p))
diff --git a/arch/powerpc/platforms/cell/ras.c b/arch/powerpc/platforms/cell/ras.c
index e865d74..ff5ae13 100644
--- a/arch/powerpc/platforms/cell/ras.c
+++ b/arch/powerpc/platforms/cell/ras.c
@@ -124,7 +124,7 @@ static int __init cbe_ptcal_enable_on_node(int nid, int order)
 	area->nid = nid;
 	area->order = order;
 	area->pages = alloc_pages_exact_node(area->nid,
-						GFP_KERNEL|__GFP_THISNODE,
+						GFP_KERNEL,
 						area->order);
 
 	if (!area->pages) {
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 2d73807..8c7f3b0 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -3158,7 +3158,7 @@ static struct vmcs *alloc_vmcs_cpu(int cpu)
 	struct page *pages;
 	struct vmcs *vmcs;
 
-	pages = alloc_pages_exact_node(node, GFP_KERNEL, vmcs_config.order);
+	pages = __alloc_pages_node(node, GFP_KERNEL, vmcs_config.order);
 	if (!pages)
 		return NULL;
 	vmcs = page_address(pages);
diff --git a/drivers/misc/sgi-xp/xpc_uv.c b/drivers/misc/sgi-xp/xpc_uv.c
index 95c8944..a4758cd 100644
--- a/drivers/misc/sgi-xp/xpc_uv.c
+++ b/drivers/misc/sgi-xp/xpc_uv.c
@@ -240,7 +240,7 @@ xpc_create_gru_mq_uv(unsigned int mq_size, int cpu, char *irq_name,
 
 	nid = cpu_to_node(cpu);
 	page = alloc_pages_exact_node(nid,
-				      GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
+				      GFP_KERNEL | __GFP_ZERO,
 				      pg_order);
 	if (page == NULL) {
 		dev_err(xpc_part, "xpc_create_gru_mq_uv() failed to alloc %d "
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 15928f0..c50848e 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -300,6 +300,22 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
 	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
 }
 
+/*
+ * An optimized version of alloc_pages_node(), to be only used in places where
+ * the overhead of the check for nid == -1 could matter.
+ */
+static inline struct page *
+__alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
+{
+	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
+
+	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
+}
+
+/*
+ * Allocate pages, preferring the node given as nid. When nid equals -1,
+ * prefer the current CPU's node.
+ */
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
@@ -310,11 +326,18 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
 
+/*
+ * Allocate pages, restricting the allocation to the node given as nid. The
+ * node must be valid and online. This is achieved by adding __GFP_THISNODE
+ * to gfp_mask.
+ */
 static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
 	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
 
+	gfp_mask |= __GFP_THISNODE;
+
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
 
diff --git a/kernel/profile.c b/kernel/profile.c
index a7bcd28..30a9404 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -339,7 +339,7 @@ static int profile_cpu_callback(struct notifier_block *info,
 		node = cpu_to_mem(cpu);
 		per_cpu(cpu_profile_flip, cpu) = 0;
 		if (!per_cpu(cpu_profile_hits, cpu)[1]) {
-			page = alloc_pages_exact_node(node,
+			page = __alloc_pages_node(node,
 					GFP_KERNEL | __GFP_ZERO,
 					0);
 			if (!page)
@@ -347,7 +347,7 @@ static int profile_cpu_callback(struct notifier_block *info,
 			per_cpu(cpu_profile_hits, cpu)[1] = page_address(page);
 		}
 		if (!per_cpu(cpu_profile_hits, cpu)[0]) {
-			page = alloc_pages_exact_node(node,
+			page = __alloc_pages_node(node,
 					GFP_KERNEL | __GFP_ZERO,
 					0);
 			if (!page)
@@ -544,14 +544,14 @@ static int create_hash_tables(void)
 		struct page *page;
 
 		page = alloc_pages_exact_node(node,
-				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
+				GFP_KERNEL | __GFP_ZERO,
 				0);
 		if (!page)
 			goto out_cleanup;
 		per_cpu(cpu_profile_hits, cpu)[1]
 				= (struct profile_hit *)page_address(page);
 		page = alloc_pages_exact_node(node,
-				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
+				GFP_KERNEL | __GFP_ZERO,
 				0);
 		if (!page)
 			goto out_cleanup;
diff --git a/mm/filemap.c b/mm/filemap.c
index 6bf5e42..5a7d4e2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -648,7 +648,7 @@ struct page *__page_cache_alloc(gfp_t gfp)
 		do {
 			cpuset_mems_cookie = read_mems_allowed_begin();
 			n = cpuset_mem_spread_node();
-			page = alloc_pages_exact_node(n, gfp, 0);
+			page = __alloc_pages_node(n, gfp, 0);
 		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
 
 		return page;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 271e443..156d8d7 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1089,8 +1089,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 	struct page *page;
 
 	page = alloc_pages_exact_node(nid,
-		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
-						__GFP_REPEAT|__GFP_NOWARN,
+		htlb_alloc_mask(h)|__GFP_COMP|__GFP_REPEAT|__GFP_NOWARN,
 		huge_page_order(h));
 	if (page) {
 		if (arch_prepare_hugepage(page)) {
@@ -1251,8 +1250,8 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 				   huge_page_order(h));
 	else
 		page = alloc_pages_exact_node(nid,
-			htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
-			__GFP_REPEAT|__GFP_NOWARN, huge_page_order(h));
+			htlb_alloc_mask(h)|__GFP_COMP|__GFP_REPEAT|
+			__GFP_NOWARN, huge_page_order(h));
 
 	if (page && arch_prepare_hugepage(page)) {
 		__free_pages(page, huge_page_order(h));
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 501820c..b783bc5 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1503,7 +1503,7 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
 		return alloc_huge_page_node(page_hstate(compound_head(p)),
 						   nid);
 	else
-		return alloc_pages_exact_node(nid, GFP_HIGHUSER_MOVABLE, 0);
+		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
 }
 
 /*
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7477432..4547960 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -945,8 +945,7 @@ static struct page *new_node_page(struct page *page, unsigned long node, int **x
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					node);
 	else
-		return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE |
-						    __GFP_THISNODE, 0);
+		return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE, 0);
 }
 
 /*
@@ -1986,8 +1985,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		nmask = policy_nodemask(gfp, pol);
 		if (!nmask || node_isset(node, *nmask)) {
 			mpol_cond_put(pol);
-			page = alloc_pages_exact_node(node,
-						gfp | __GFP_THISNODE, order);
+			page = alloc_pages_exact_node(node, gfp, order);
 			goto out;
 		}
 	}
diff --git a/mm/migrate.c b/mm/migrate.c
index f53838f..d139222 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1554,10 +1554,8 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 	struct page *newpage;
 
 	newpage = alloc_pages_exact_node(nid,
-					 (GFP_HIGHUSER_MOVABLE |
-					  __GFP_THISNODE | __GFP_NOMEMALLOC |
-					  __GFP_NORETRY | __GFP_NOWARN) &
-					 ~GFP_IOFS, 0);
+				(GFP_HIGHUSER_MOVABLE | __GFP_NOMEMALLOC |
+				 __GFP_NORETRY | __GFP_NOWARN) & ~GFP_IOFS, 0);
 
 	return newpage;
 }
diff --git a/mm/slab.c b/mm/slab.c
index 7eb38dd..5f49e63 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1594,7 +1594,7 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	if (memcg_charge_slab(cachep, flags, cachep->gfporder))
 		return NULL;
 
-	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
+	page = __alloc_pages_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
 	if (!page) {
 		memcg_uncharge_slab(cachep, cachep->gfporder);
 		slab_out_of_memory(cachep, flags, nodeid);
diff --git a/mm/slob.c b/mm/slob.c
index 4765f65..10d8e02 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -193,7 +193,7 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
 
 #ifdef CONFIG_NUMA
 	if (node != NUMA_NO_NODE)
-		page = alloc_pages_exact_node(node, gfp, order);
+		page = __alloc_pages_node(node, gfp, order);
 	else
 #endif
 		page = alloc_pages(gfp, order);
diff --git a/mm/slub.c b/mm/slub.c
index 54c0876..0486343 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1323,7 +1323,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 	if (node == NUMA_NO_NODE)
 		page = alloc_pages(flags, order);
 	else
-		page = alloc_pages_exact_node(node, flags, order);
+		page = __alloc_pages_node(node, flags, order);
 
 	if (!page)
 		memcg_uncharge_slab(s, order);
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
