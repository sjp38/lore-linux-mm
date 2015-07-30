Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 212FE6B0253
	for <linux-mm@kvack.org>; Thu, 30 Jul 2015 15:59:53 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so33820487wic.0
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 12:59:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fu3si843347wib.77.2015.07.30.12.59.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jul 2015 12:59:51 -0700 (PDT)
Subject: Re: [PATCH v3 1/3] mm: rename alloc_pages_exact_node to
 __alloc_pages_node
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.11.1507301255380.5521@east.gentwo.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55BA822B.3020508@suse.cz>
Date: Thu, 30 Jul 2015 21:59:39 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1507301255380.5521@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Cliff Whickman <cpw@sgi.com>, Michael Ellerman <mpe@ellerman.id.au>, Robin Holt <robinmholt@gmail.com>

On 07/30/2015 07:58 PM, Christoph Lameter wrote:
> On Thu, 30 Jul 2015, Vlastimil Babka wrote:
> 
>> --- a/mm/slob.c
>> +++ b/mm/slob.c
>>  	void *page;
>>
>> -#ifdef CONFIG_NUMA
>> -	if (node != NUMA_NO_NODE)
>> -		page = alloc_pages_exact_node(node, gfp, order);
>> -	else
>> -#endif
>> -		page = alloc_pages(gfp, order);
>> +	page = alloc_pages_node(node, gfp, order);
> 
> NAK. This is changing slob behavior. With no node specified it must use
> alloc_pages because that obeys NUMA memory policies etc etc. It should not
> force allocation from the current node like what is happening here after
> the patch. See the code in slub.c that is similar.
 
Doh, somehow I convinced myself that there's #else and alloc_pages() is only
used for !CONFIG_NUMA so it doesn't matter. Here's a fixed version.

------8<------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Fri, 24 Jul 2015 15:49:47 +0200
Subject: [PATCH v3 1/3] mm: rename alloc_pages_exact_node to
 __alloc_pages_node

The function alloc_pages_exact_node() was introduced in 6484eb3e2a81 ("page
allocator: do not check NUMA node ID when the caller knows the node is valid")
as an optimized variant of alloc_pages_node(), that doesn't fallback to current
node for nid == NUMA_NO_NODE. Unfortunately the name of the function can easily
suggest that the allocation is restricted to the given node and fails
otherwise. In truth, the node is only preferred, unless __GFP_THISNODE is
passed among the gfp flags.

The misleading name has lead to mistakes in the past, see 5265047ac301 ("mm,
thp: really limit transparent hugepage allocation to local node") and
b360edb43f8e ("mm, mempolicy: migrate_to_node should only migrate to node").

Another issue with the name is that there's a family of alloc_pages_exact*()
functions where 'exact' means exact size (instead of page order), which leads
to more confusion.

To prevent further mistakes, this patch effectively renames
alloc_pages_exact_node() to __alloc_pages_node() to better convey that it's
an optimized variant of alloc_pages_node() not intended for general usage.
Both functions get described in comments.

It has been also considered to really provide a convenience function for
allocations restricted to a node, but the major opinion seems to be that
__GFP_THISNODE already provides that functionality and we shouldn't duplicate
the API needlessly. The number of users would be small anyway.

Existing callers of alloc_pages_exact_node() are simply converted to call
__alloc_pages_node(), with the exception of sba_alloc_coherent() which
open-codes the check for NUMA_NO_NODE, so it is converted to use
alloc_pages_node() instead. This means it no longer performs some VM_BUG_ON
checks, and since the current check for nid in alloc_pages_node() uses a 'nid <
0' comparison (which includes NUMA_NO_NODE), it may hide wrong values which
would be previously exposed. Both differences will be rectified by the next
patch.

To sum up, this patch makes no functional changes, except temporarily hiding
potentially buggy callers. Restricting the checks in alloc_pages_node() is
left for the next patch which can in turn expose more existing buggy callers.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>
Cc: Greg Thelen <gthelen@google.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Acked-by: Michael Ellerman <mpe@ellerman.id.au>
Cc: Gleb Natapov <gleb@kernel.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Cliff Whickman <cpw@sgi.com>
Acked-by: Robin Holt <robinmholt@gmail.com>
---
 arch/ia64/hp/common/sba_iommu.c   |  6 +-----
 arch/ia64/kernel/uncached.c       |  2 +-
 arch/ia64/sn/pci/pci_dma.c        |  2 +-
 arch/powerpc/platforms/cell/ras.c |  2 +-
 arch/x86/kvm/vmx.c                |  2 +-
 drivers/misc/sgi-xp/xpc_uv.c      |  2 +-
 include/linux/gfp.h               | 23 +++++++++++++++--------
 kernel/profile.c                  |  8 ++++----
 mm/filemap.c                      |  2 +-
 mm/huge_memory.c                  |  6 ++----
 mm/hugetlb.c                      |  4 ++--
 mm/memory-failure.c               |  2 +-
 mm/mempolicy.c                    |  4 ++--
 mm/migrate.c                      |  4 ++--
 mm/page_alloc.c                   |  2 --
 mm/slab.c                         |  2 +-
 mm/slob.c                         |  4 ++--
 mm/slub.c                         |  2 +-
 18 files changed, 39 insertions(+), 40 deletions(-)

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
index 20e8a9b..f3976da 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -97,7 +97,7 @@ static int uncached_add_chunk(struct uncached_pool *uc_pool, int nid)
 
 	/* attempt to allocate a granule's worth of cached memory pages */
 
-	page = alloc_pages_exact_node(nid,
+	page = __alloc_pages_node(nid,
 				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
 				IA64_GRANULE_SHIFT-PAGE_SHIFT);
 	if (!page) {
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
index e865d74..2d4f60c 100644
--- a/arch/powerpc/platforms/cell/ras.c
+++ b/arch/powerpc/platforms/cell/ras.c
@@ -123,7 +123,7 @@ static int __init cbe_ptcal_enable_on_node(int nid, int order)
 
 	area->nid = nid;
 	area->order = order;
-	area->pages = alloc_pages_exact_node(area->nid,
+	area->pages = __alloc_pages_node(area->nid,
 						GFP_KERNEL|__GFP_THISNODE,
 						area->order);
 
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 0dbeec1..881286b 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -3150,7 +3150,7 @@ static struct vmcs *alloc_vmcs_cpu(int cpu)
 	struct page *pages;
 	struct vmcs *vmcs;
 
-	pages = alloc_pages_exact_node(node, GFP_KERNEL, vmcs_config.order);
+	pages = __alloc_pages_node(node, GFP_KERNEL, vmcs_config.order);
 	if (!pages)
 		return NULL;
 	vmcs = page_address(pages);
diff --git a/drivers/misc/sgi-xp/xpc_uv.c b/drivers/misc/sgi-xp/xpc_uv.c
index 95c8944..340b44d 100644
--- a/drivers/misc/sgi-xp/xpc_uv.c
+++ b/drivers/misc/sgi-xp/xpc_uv.c
@@ -239,7 +239,7 @@ xpc_create_gru_mq_uv(unsigned int mq_size, int cpu, char *irq_name,
 	mq->mmr_blade = uv_cpu_to_blade_id(cpu);
 
 	nid = cpu_to_node(cpu);
-	page = alloc_pages_exact_node(nid,
+	page = __alloc_pages_node(nid,
 				      GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
 				      pg_order);
 	if (page == NULL) {
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 3bd64b1..d2c142b 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -303,20 +303,28 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
 	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
 }
 
-static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
-						unsigned int order)
+/*
+ * Allocate pages, preferring the node given as nid. The node must be valid and
+ * online. For more general interface, see alloc_pages_node().
+ */
+static inline struct page *
+__alloc_pages_node(int nid, gfp_t gfp_mask, unsigned int order)
 {
-	/* Unknown node is current node */
-	if (nid < 0)
-		nid = numa_node_id();
+	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
 
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
 
-static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
+/*
+ * Allocate pages, preferring the node given as nid. When nid == NUMA_NO_NODE,
+ * prefer the current CPU's node.
+ */
+static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
-	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
+	/* Unknown node is current node */
+	if (nid < 0)
+		nid = numa_node_id();
 
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
@@ -357,7 +365,6 @@ extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
 void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
 void free_pages_exact(void *virt, size_t size);
-/* This is different from alloc_pages_exact_node !!! */
 void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 
 #define __get_free_page(gfp_mask) \
diff --git a/kernel/profile.c b/kernel/profile.c
index a7bcd28..99513e1 100644
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
@@ -543,14 +543,14 @@ static int create_hash_tables(void)
 		int node = cpu_to_mem(cpu);
 		struct page *page;
 
-		page = alloc_pages_exact_node(node,
+		page = __alloc_pages_node(node,
 				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
 				0);
 		if (!page)
 			goto out_cleanup;
 		per_cpu(cpu_profile_hits, cpu)[1]
 				= (struct profile_hit *)page_address(page);
-		page = alloc_pages_exact_node(node,
+		page = __alloc_pages_node(node,
 				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
 				0);
 		if (!page)
diff --git a/mm/filemap.c b/mm/filemap.c
index 204fd1c..b510a0d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -674,7 +674,7 @@ struct page *__page_cache_alloc(gfp_t gfp)
 		do {
 			cpuset_mems_cookie = read_mems_allowed_begin();
 			n = cpuset_mem_spread_node();
-			page = alloc_pages_exact_node(n, gfp, 0);
+			page = __alloc_pages_node(n, gfp, 0);
 		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
 
 		return page;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index aa58a32..56355f2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2469,7 +2469,7 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
 	 */
 	up_read(&mm->mmap_sem);
 
-	*hpage = alloc_pages_exact_node(node, gfp, HPAGE_PMD_ORDER);
+	*hpage = __alloc_pages_node(node, gfp, HPAGE_PMD_ORDER);
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
@@ -2568,9 +2568,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
-	/* Only allocate from the target node */
-	gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
-		__GFP_THISNODE;
+	gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), 0);
 
 	/* release the mmap_sem read lock. */
 	new_page = khugepaged_alloc_page(hpage, gfp, mm, vma, address, node);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e83fce5..4920bcb 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1331,7 +1331,7 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
 
-	page = alloc_pages_exact_node(nid,
+	page = __alloc_pages_node(nid,
 		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
 						__GFP_REPEAT|__GFP_NOWARN,
 		huge_page_order(h));
@@ -1483,7 +1483,7 @@ static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
 				   __GFP_REPEAT|__GFP_NOWARN,
 				   huge_page_order(h));
 	else
-		page = alloc_pages_exact_node(nid,
+		page = __alloc_pages_node(nid,
 			htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
 			__GFP_REPEAT|__GFP_NOWARN, huge_page_order(h));
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 9700539..839f934 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1468,7 +1468,7 @@ static struct page *new_page(struct page *p, unsigned long private, int **x)
 		return alloc_huge_page_node(page_hstate(compound_head(p)),
 						   nid);
 	else
-		return alloc_pages_exact_node(nid, GFP_HIGHUSER_MOVABLE, 0);
+		return __alloc_pages_node(nid, GFP_HIGHUSER_MOVABLE, 0);
 }
 
 /*
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d6f2cae..87a1779 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -942,7 +942,7 @@ static struct page *new_node_page(struct page *page, unsigned long node, int **x
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
 					node);
 	else
-		return alloc_pages_exact_node(node, GFP_HIGHUSER_MOVABLE |
+		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
 						    __GFP_THISNODE, 0);
 }
 
@@ -1998,7 +1998,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		nmask = policy_nodemask(gfp, pol);
 		if (!nmask || node_isset(hpage_node, *nmask)) {
 			mpol_cond_put(pol);
-			page = alloc_pages_exact_node(hpage_node,
+			page = __alloc_pages_node(hpage_node,
 						gfp | __GFP_THISNODE, order);
 			goto out;
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index d86cec0..cd673c8 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1195,7 +1195,7 @@ static struct page *new_page_node(struct page *p, unsigned long private,
 		return alloc_huge_page_node(page_hstate(compound_head(p)),
 					pm->node);
 	else
-		return alloc_pages_exact_node(pm->node,
+		return __alloc_pages_node(pm->node,
 				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
 }
 
@@ -1555,7 +1555,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 	int nid = (int) data;
 	struct page *newpage;
 
-	newpage = alloc_pages_exact_node(nid,
+	newpage = __alloc_pages_node(nid,
 					 (GFP_HIGHUSER_MOVABLE |
 					  __GFP_THISNODE | __GFP_NOMEMALLOC |
 					  __GFP_NORETRY | __GFP_NOWARN) &
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4b220cb..88d2ee9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3511,8 +3511,6 @@ EXPORT_SYMBOL(alloc_pages_exact);
  *
  * Like alloc_pages_exact(), but try to allocate on node nid first before falling
  * back.
- * Note this is not alloc_pages_exact_node() which allocates on a specific node,
- * but is not exact.
  */
 void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
 {
diff --git a/mm/slab.c b/mm/slab.c
index 4c5910f..1783eda 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1595,7 +1595,7 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 	if (memcg_charge_slab(cachep, flags, cachep->gfporder))
 		return NULL;
 
-	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
+	page = __alloc_pages_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
 	if (!page) {
 		memcg_uncharge_slab(cachep, cachep->gfporder);
 		slab_out_of_memory(cachep, flags, nodeid);
diff --git a/mm/slob.c b/mm/slob.c
index 165bbd3..0d7e5df 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -45,7 +45,7 @@
  * NUMA support in SLOB is fairly simplistic, pushing most of the real
  * logic down to the page allocator, and simply doing the node accounting
  * on the upper levels. In the event that a node id is explicitly
- * provided, alloc_pages_exact_node() with the specified node id is used
+ * provided, __alloc_pages_node() with the specified node id is used
  * instead. The common case (or when the node id isn't explicitly provided)
  * will default to the current node, as per numa_node_id().
  *
@@ -193,7 +193,7 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
 
 #ifdef CONFIG_NUMA
 	if (node != NUMA_NO_NODE)
-		page = alloc_pages_exact_node(node, gfp, order);
+		page = __alloc_pages_node(node, gfp, order);
 	else
 #endif
 		page = alloc_pages(gfp, order);
diff --git a/mm/slub.c b/mm/slub.c
index 257283f..b48ad97 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1336,7 +1336,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
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
