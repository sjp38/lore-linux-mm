Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C46046B006E
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 06:42:00 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id k14so8443485wgh.10
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 03:42:00 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gu7si19197634wib.91.2015.01.26.03.41.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 03:41:58 -0800 (PST)
Message-ID: <54C62803.8010105@suse.cz>
Date: Mon, 26 Jan 2015 12:41:55 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH V4] mm/thp: Allocate transparent hugepages on local node
References: <1421753671-16793-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20150120164832.abe2e47b760e1a8d7bb6055b@linux-foundation.org>
In-Reply-To: <20150120164832.abe2e47b760e1a8d7bb6055b@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/21/2015 01:48 AM, Andrew Morton wrote:
> On Tue, 20 Jan 2015 17:04:31 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>> + * Should be called with the mm_sem of the vma hold.
> 
> That's a pretty cruddy sentence, isn't it?  Copied from
> alloc_pages_vma().  "vma->vm_mm->mmap_sem" would be better.
> 
> And it should tell us whether mmap_sem required a down_read or a
> down_write.  What purpose is it serving?

This is already said for mmap_sem further above this comment line, which
should be just deleted (and from alloc_hugepage_vma comment too).

>> + *
>> + */
>> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
>> +				unsigned long addr, int order)
> 
> This pointlessly bloats the kernel if CONFIG_TRANSPARENT_HUGEPAGE=n?
> 
> 
> 
> --- a/mm/mempolicy.c~mm-thp-allocate-transparent-hugepages-on-local-node-fix
> +++ a/mm/mempolicy.c

How about this cleanup on top? I'm not fully decided on the GFP_TRANSHUGE test.
This is potentially false positive, although I doubt anything else uses the same
gfp mask bits.

Should "hugepage" be extra bool parameter instead? Should I #ifdef the parameter
only for CONFIG_TRANSPARENT_HUGEPAGE, or is it not worth the ugliness?


--------8<--------
From: Vlastimil Babka <vbabka@suse.cz>
Date: Mon, 26 Jan 2015 11:41:33 +0100
Subject: [PATCH] mm/mempolicy: merge alloc_hugepage_vma to alloc_pages_vma

Commit "mm/thp: allocate transparent hugepages on local node" has introduced
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
 include/linux/gfp.h |   4 +-
 mm/mempolicy.c      | 121 ++++++++++++++++------------------------------------
 2 files changed, 39 insertions(+), 86 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 60110e0..c19318d 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -335,8 +335,8 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
 extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 			struct vm_area_struct *vma, unsigned long addr,
 			int node);
-extern struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
-				       unsigned long addr, int order);
+#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
+	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id())
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 67b2d39..fd132c9 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1988,15 +1988,14 @@ static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
  *	@order:Order of the GFP allocation.
  * 	@vma:  Pointer to VMA or NULL if not available.
  *	@addr: Virtual Address of the allocation. Must be inside the VMA.
+ *	@node: Which node to prefer for allocation (modulo policy).
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
@@ -2005,103 +2004,57 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	struct mempolicy *pol;
 	struct page *page;
 	unsigned int cpuset_mems_cookie;
+	struct zonelist *zl;
+	nodemask_t *nmask;
 
 retry_cpuset:
 	pol = get_vma_policy(vma, addr);
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
-	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
+	/* 
+	 * Detect hugepage allocations from the gfp mask. Ignore __GFP_WAIT
+	 * which may be removed from gfp by alloc_hugepage_gfpmask()
+	 */
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
+			((gfp & (GFP_TRANSHUGE & ~__GFP_WAIT))
+			 == (GFP_TRANSHUGE & ~__GFP_WAIT)) &&
+					pol->mode != MPOL_INTERLEAVE) {
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
2.1.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
