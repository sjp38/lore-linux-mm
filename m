Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id B3EAE6B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 02:56:58 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id k48so25639420wev.12
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 23:56:58 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w5si19287117wjr.60.2015.01.29.23.56.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 23:56:56 -0800 (PST)
Message-ID: <54CB3945.4080905@suse.cz>
Date: Fri, 30 Jan 2015 08:56:53 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V4] mm/thp: Allocate transparent hugepages on local node
References: <1421753671-16793-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150120164832.abe2e47b760e1a8d7bb6055b@linux-foundation.org> <54C62803.8010105@suse.cz> <8761btvc9t.fsf@linux.vnet.ibm.com>
In-Reply-To: <8761btvc9t.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/26/2015 03:37 PM, Aneesh Kumar K.V wrote:
> Vlastimil Babka <vbabka@suse.cz> writes:
> 
>> On 01/21/2015 01:48 AM, Andrew Morton wrote:
>>> On Tue, 20 Jan 2015 17:04:31 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>>> + * Should be called with the mm_sem of the vma hold.
>>> 
>>> That's a pretty cruddy sentence, isn't it?  Copied from
>>> alloc_pages_vma().  "vma->vm_mm->mmap_sem" would be better.
>>> 
>>> And it should tell us whether mmap_sem required a down_read or a
>>> down_write.  What purpose is it serving?
>>
>> This is already said for mmap_sem further above this comment line, which
>> should be just deleted (and from alloc_hugepage_vma comment too).
>>
>>>> + *
>>>> + */
>>>> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
>>>> +				unsigned long addr, int order)
>>> 
>>> This pointlessly bloats the kernel if CONFIG_TRANSPARENT_HUGEPAGE=n?
>>> 
>>> 
>>> 
>>> --- a/mm/mempolicy.c~mm-thp-allocate-transparent-hugepages-on-local-node-fix
>>> +++ a/mm/mempolicy.c
>>
>> How about this cleanup on top? I'm not fully decided on the GFP_TRANSHUGE test.
>> This is potentially false positive, although I doubt anything else uses the same
>> gfp mask bits.
> 
> IMHO I found that to be more complex.

I think it's better consolidated, but clearly there is no universal truth here.
So I'll let others add their opinions.

>>
>> Should "hugepage" be extra bool parameter instead? Should I #ifdef the parameter
>> only for CONFIG_TRANSPARENT_HUGEPAGE, or is it not worth the ugliness?
>>
> 
> I guess if we really want to consolidate both the functions, we should
> try the above, without all those #ifdef. It is just one extra arg.  But

OK, new version below.

> then is the reason to consolidate that strong ?

It reduces duplication. I also tried some bloat-o-meter. The extra param seems
to have some tiny cost, but overall it looks good.

./scripts/bloat-o-meter mm/mempolicy.o mempolicy1.o 
add/remove: 1/2 grow/shrink: 4/0 up/down: 195/-340 (-145)
function                                     old     new   delta
alloc_pages_vma                              327     502    +175
init_nodemask_of_mempolicy                   386     394      +8
interleave_nid.part                            -       6      +6
new_page                                     195     198      +3
interleave_nid                                57      60      +3
mpol_cond_put                                 23       -     -23
alloc_hugepage_vma                           317       -    -317

add/remove: 0/0 grow/shrink: 1/1 up/down: 16/-28 (-12)
function                                     old     new   delta
do_huge_pmd_anonymous_page                   968     984     +16
do_huge_pmd_wp_page                         2566    2538     -28

-------8<-------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Mon, 26 Jan 2015 11:41:33 +0100
Subject: [PATCH] mm/mempolicy: merge alloc_hugepage_vma to alloc_pages_vma

Commit "mm/thp: Allocate transparent hugepages on local node" has introduced
alloc_hugepage_vma() to mm/mempolicy.c to perform a special policy for THP
allocations. The function has the same interface as alloc_pages_vma(), shares
a lot of boilerplate code and a long comment.

This patch merges the hugepage special case into alloc_pages_vma. The extra if
condition should be cheap enough price to pay. We also prevent a (however
unlikely) race with parallel mems_allowed update, which could make hugepage
allocation restart only within the fallback call to alloc_hugepage_vma() and
not reconsider the special rule in alloc_hugepage_vma().

Also by making sure mpol_cond_put(pol) is always called before actual
allocation attempt, we can use a single exit path within the function.

Also update the comment for missing node parameter and obsolete reference to
mm_sem.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/gfp.h |  12 +++---
 mm/mempolicy.c      | 118 +++++++++++++++-------------------------------------
 2 files changed, 39 insertions(+), 91 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 60110e0..51bd1e7 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -334,22 +334,22 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 }
 extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 			struct vm_area_struct *vma, unsigned long addr,
-			int node);
-extern struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
-				       unsigned long addr, int order);
+			int node, bool hugepage);
+#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
+	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
-#define alloc_pages_vma(gfp_mask, order, vma, addr, node)	\
+#define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
 	alloc_pages(gfp_mask, order)
 #define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
 	alloc_pages(gfp_mask, order)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
 #define alloc_page_vma(gfp_mask, vma, addr)			\
-	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id())
+	alloc_pages_vma(gfp_mask, 0, vma, addr, numa_node_id(), false)
 #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
-	alloc_pages_vma(gfp_mask, 0, vma, addr, node)
+	alloc_pages_vma(gfp_mask, 0, vma, addr, node, false)
 
 extern struct page *alloc_kmem_pages(gfp_t gfp_mask, unsigned int order);
 extern struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 67b2d39..460483b 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1988,120 +1988,68 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
  *	@order:Order of the GFP allocation.
  * 	@vma:  Pointer to VMA or NULL if not available.
  *	@addr: Virtual Address of the allocation. Must be inside the VMA.
+ *	@node: Which node to prefer for allocation (modulo policy).
+ *	@hugepage: for hugepages try only the preferred node if possible
  *
  * 	This function allocates a page from the kernel page pool and applies
  *	a NUMA policy associated with the VMA or the current process.
  *	When VMA is not NULL caller must hold down_read on the mmap_sem of the
  *	mm_struct of the VMA to prevent it from going away. Should be used for
- *	all allocations for pages that will be mapped into
- * 	user space. Returns NULL when no page can be allocated.
- *
- *	Should be called with the mm_sem of the vma hold.
+ *	all allocations for pages that will be mapped into user space. Returns
+ *	NULL when no page can be allocated.
  */
 struct page *
 alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
-		unsigned long addr, int node)
+		unsigned long addr, int node, bool hugepage)
 {
 	struct mempolicy *pol;
 	struct page *page;
 	unsigned int cpuset_mems_cookie;
+	struct zonelist *zl;
+	nodemask_t *nmask;
 
 retry_cpuset:
 	pol = get_vma_policy(vma, addr);
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
-	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
+	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage &&
+					pol->mode != MPOL_INTERLEAVE)) {
+		/*
+		 * For hugepage allocation and non-interleave policy which
+		 * allows the current node, we only try to allocate from the
+		 * current node and don't fall back to other nodes, as the
+		 * cost of remote accesses would likely offset THP benefits.
+		 *
+		 * If the policy is interleave, or does not allow the current
+		 * node in its nodemask, we allocate the standard way.
+		 */
+		nmask = policy_nodemask(gfp, pol);
+		if (!nmask || node_isset(node, *nmask)) {
+			mpol_cond_put(pol);
+			page = alloc_pages_exact_node(node, gfp, order);
+			goto out;
+		}
+	}
+
+	if (pol->mode == MPOL_INTERLEAVE) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
 		mpol_cond_put(pol);
 		page = alloc_page_interleave(gfp, order, nid);
-		if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
-			goto retry_cpuset;
-
-		return page;
+		goto out;
 	}
-	page = __alloc_pages_nodemask(gfp, order,
-				      policy_zonelist(gfp, pol, node),
-				      policy_nodemask(gfp, pol));
+
+	nmask = policy_nodemask(gfp, pol);
+	zl = policy_zonelist(gfp, pol, node);
 	mpol_cond_put(pol);
+	page = __alloc_pages_nodemask(gfp, order, zl, nmask);
+out:
 	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 	return page;
 }
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-/**
- * alloc_hugepage_vma: Allocate a hugepage for a VMA
- * @gfp:
- *   %GFP_USER	  user allocation.
- *   %GFP_KERNEL  kernel allocations,
- *   %GFP_HIGHMEM highmem/user allocations,
- *   %GFP_FS	  allocation should not call back into a file system.
- *   %GFP_ATOMIC  don't sleep.
- *
- * @vma:   Pointer to VMA or NULL if not available.
- * @addr:  Virtual Address of the allocation. Must be inside the VMA.
- * @order: Order of the hugepage for gfp allocation.
- *
- * This functions allocate a huge page from the kernel page pool and applies
- * a NUMA policy associated with the VMA or the current process.
- * For policy other than %MPOL_INTERLEAVE, we make sure we allocate hugepage
- * only from the current node if the current node is part of the node mask.
- * If we can't allocate a hugepage we fail the allocation and don' try to fallback
- * to other nodes in the node mask. If the current node is not part of node mask
- * or if the NUMA policy is MPOL_INTERLEAVE we use the allocator that can
- * fallback to nodes in the policy node mask.
- *
- * When VMA is not NULL caller must hold down_read on the mmap_sem of the
- * mm_struct of the VMA to prevent it from going away. Should be used for
- * all allocations for pages that will be mapped into
- * user space. Returns NULL when no page can be allocated.
- *
- * Should be called with vma->vm_mm->mmap_sem held.
- *
- */
-struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
-				unsigned long addr, int order)
-{
-	struct page *page;
-	nodemask_t *nmask;
-	struct mempolicy *pol;
-	int node = numa_node_id();
-	unsigned int cpuset_mems_cookie;
-
-retry_cpuset:
-	pol = get_vma_policy(vma, addr);
-	cpuset_mems_cookie = read_mems_allowed_begin();
-	/*
-	 * For interleave policy, we don't worry about
-	 * current node. Otherwise if current node is
-	 * in nodemask, try to allocate hugepage from
-	 * the current node. Don't fall back to other nodes
-	 * for THP.
-	 */
-	if (unlikely(pol->mode == MPOL_INTERLEAVE))
-		goto alloc_with_fallback;
-	nmask = policy_nodemask(gfp, pol);
-	if (!nmask || node_isset(node, *nmask)) {
-		mpol_cond_put(pol);
-		page = alloc_pages_exact_node(node, gfp, order);
-		if (unlikely(!page &&
-			     read_mems_allowed_retry(cpuset_mems_cookie)))
-			goto retry_cpuset;
-		return page;
-	}
-alloc_with_fallback:
-	mpol_cond_put(pol);
-	/*
-	 * if current node is not part of node mask, try
-	 * the allocation from any node, and we can do retry
-	 * in that case.
-	 */
-	return alloc_pages_vma(gfp, order, vma, addr, node);
-}
-#endif
-
 /**
  * 	alloc_pages_current - Allocate pages.
  *
-- 
2.1.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
