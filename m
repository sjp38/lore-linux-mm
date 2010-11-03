Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5F7896B00CA
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:44 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 53 of 66] add numa awareness to hugepage allocations
Message-Id: <223ee926614158fc1353.1288798108@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:28 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

It's mostly a matter of replacing alloc_pages with alloc_pages_vma after
introducing alloc_pages_vma. khugepaged needs special handling as the
allocation has to happen inside collapse_huge_page where the vma is known and
an error has to be returned to the outer loop to sleep alloc_sleep_millisecs in
case of failure. But it retains the more efficient logic of handling allocation
failures in khugepaged in case of CONFIG_NUMA=n.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -330,14 +330,17 @@ alloc_pages(gfp_t gfp_mask, unsigned int
 {
 	return alloc_pages_current(gfp_mask, order);
 }
-extern struct page *alloc_page_vma(gfp_t gfp_mask,
+extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 			struct vm_area_struct *vma, unsigned long addr);
 #else
 #define alloc_pages(gfp_mask, order) \
 		alloc_pages_node(numa_node_id(), gfp_mask, order)
-#define alloc_page_vma(gfp_mask, vma, addr) alloc_pages(gfp_mask, 0)
+#define alloc_pages_vma(gfp_mask, order, vma, addr)	\
+	alloc_pages(gfp_mask, order)
 #endif
 #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
+#define alloc_page_vma(gfp_mask, vma, addr)	\
+	alloc_pages_vma(gfp_mask, 0, vma, addr)
 
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -620,11 +620,26 @@ static int __do_huge_pmd_anonymous_page(
 	return ret;
 }
 
+static inline gfp_t alloc_hugepage_gfpmask(int defrag)
+{
+	return GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT);
+}
+
+static inline struct page *alloc_hugepage_vma(int defrag,
+					      struct vm_area_struct *vma,
+					      unsigned long haddr)
+{
+	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag),
+			       HPAGE_PMD_ORDER, vma, haddr);
+}
+
+#ifndef CONFIG_NUMA
 static inline struct page *alloc_hugepage(int defrag)
 {
-	return alloc_pages(GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT),
+	return alloc_pages(alloc_hugepage_gfpmask(defrag),
 			   HPAGE_PMD_ORDER);
 }
+#endif
 
 int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
@@ -639,7 +654,8 @@ int do_huge_pmd_anonymous_page(struct mm
 			return VM_FAULT_OOM;
 		if (unlikely(khugepaged_enter(vma)))
 			return VM_FAULT_OOM;
-		page = alloc_hugepage(transparent_hugepage_defrag(vma));
+		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
+					  vma, haddr);
 		if (unlikely(!page))
 			goto out;
 		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
@@ -858,7 +874,8 @@ int do_huge_pmd_wp_page(struct mm_struct
 
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow())
-		new_page = alloc_hugepage(transparent_hugepage_defrag(vma));
+		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
+					      vma, haddr);
 	else
 		new_page = NULL;
 
@@ -1655,7 +1672,11 @@ static void collapse_huge_page(struct mm
 	unsigned long hstart, hend;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+#ifndef CONFIG_NUMA
 	VM_BUG_ON(!*hpage);
+#else
+	VM_BUG_ON(*hpage);
+#endif
 
 	/*
 	 * Prevent all access to pagetables with the exception of
@@ -1693,7 +1714,15 @@ static void collapse_huge_page(struct mm
 	if (!pmd_present(*pmd) || pmd_trans_huge(*pmd))
 		goto out;
 
+#ifndef CONFIG_NUMA
 	new_page = *hpage;
+#else
+	new_page = alloc_hugepage_vma(khugepaged_defrag(), vma, address);
+	if (unlikely(!new_page)) {
+		*hpage = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+#endif
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL)))
 		goto out;
 
@@ -1724,6 +1753,9 @@ static void collapse_huge_page(struct mm
 		spin_unlock(&mm->page_table_lock);
 		anon_vma_unlock(vma->anon_vma);
 		mem_cgroup_uncharge_page(new_page);
+#ifdef CONFIG_NUMA
+		put_page(new_page);
+#endif
 		goto out;
 	}
 
@@ -1759,7 +1791,9 @@ static void collapse_huge_page(struct mm
 	mm->nr_ptes--;
 	spin_unlock(&mm->page_table_lock);
 
+#ifndef CONFIG_NUMA
 	*hpage = NULL;
+#endif
 	khugepaged_pages_collapsed++;
 out:
 	up_write(&mm->mmap_sem);
@@ -1995,11 +2029,16 @@ static void khugepaged_do_scan(struct pa
 	while (progress < pages) {
 		cond_resched();
 
+#ifndef CONFIG_NUMA
 		if (!*hpage) {
 			*hpage = alloc_hugepage(khugepaged_defrag());
 			if (unlikely(!*hpage))
 				break;
 		}
+#else
+		if (IS_ERR(*hpage))
+			break;
+#endif
 
 		spin_lock(&khugepaged_mm_lock);
 		if (!khugepaged_scan.mm_slot)
@@ -2014,37 +2053,55 @@ static void khugepaged_do_scan(struct pa
 	}
 }
 
+static void khugepaged_alloc_sleep(void)
+{
+	DEFINE_WAIT(wait);
+	add_wait_queue(&khugepaged_wait, &wait);
+	schedule_timeout_interruptible(
+		msecs_to_jiffies(
+			khugepaged_alloc_sleep_millisecs));
+	remove_wait_queue(&khugepaged_wait, &wait);
+}
+
+#ifndef CONFIG_NUMA
 static struct page *khugepaged_alloc_hugepage(void)
 {
 	struct page *hpage;
 
 	do {
 		hpage = alloc_hugepage(khugepaged_defrag());
-		if (!hpage) {
-			DEFINE_WAIT(wait);
-			add_wait_queue(&khugepaged_wait, &wait);
-			schedule_timeout_interruptible(
-				msecs_to_jiffies(
-					khugepaged_alloc_sleep_millisecs));
-			remove_wait_queue(&khugepaged_wait, &wait);
-		}
+		if (!hpage)
+			khugepaged_alloc_sleep();
 	} while (unlikely(!hpage) &&
 		 likely(khugepaged_enabled()));
 	return hpage;
 }
+#endif
 
 static void khugepaged_loop(void)
 {
 	struct page *hpage;
 
+#ifdef CONFIG_NUMA
+	hpage = NULL;
+#endif
 	while (likely(khugepaged_enabled())) {
+#ifndef CONFIG_NUMA
 		hpage = khugepaged_alloc_hugepage();
 		if (unlikely(!hpage))
 			break;
+#else
+		if (IS_ERR(hpage)) {
+			khugepaged_alloc_sleep();
+			hpage = NULL;
+		}
+#endif
 
 		khugepaged_do_scan(&hpage);
+#ifndef CONFIG_NUMA
 		if (hpage)
 			put_page(hpage);
+#endif
 		if (khugepaged_has_work()) {
 			DEFINE_WAIT(wait);
 			if (!khugepaged_scan_sleep_millisecs)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1794,7 +1794,7 @@ static struct page *alloc_page_interleav
 }
 
 /**
- * 	alloc_page_vma	- Allocate a page for a VMA.
+ * 	alloc_pages_vma	- Allocate a page for a VMA.
  *
  * 	@gfp:
  *      %GFP_USER    user allocation.
@@ -1803,6 +1803,7 @@ static struct page *alloc_page_interleav
  *      %GFP_FS      allocation should not call back into a file system.
  *      %GFP_ATOMIC  don't sleep.
  *
+ *	@order:Order of the GFP allocation.
  * 	@vma:  Pointer to VMA or NULL if not available.
  *	@addr: Virtual Address of the allocation. Must be inside the VMA.
  *
@@ -1816,7 +1817,8 @@ static struct page *alloc_page_interleav
  *	Should be called with the mm_sem of the vma hold.
  */
 struct page *
-alloc_page_vma(gfp_t gfp, struct vm_area_struct *vma, unsigned long addr)
+alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
+		unsigned long addr)
 {
 	struct mempolicy *pol = get_vma_policy(current, vma, addr);
 	struct zonelist *zl;
@@ -1828,7 +1830,7 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT);
 		mpol_cond_put(pol);
-		page = alloc_page_interleave(gfp, 0, nid);
+		page = alloc_page_interleave(gfp, order, nid);
 		put_mems_allowed();
 		return page;
 	}
@@ -1837,7 +1839,7 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 		/*
 		 * slow path: ref counted shared policy
 		 */
-		struct page *page =  __alloc_pages_nodemask(gfp, 0,
+		struct page *page =  __alloc_pages_nodemask(gfp, order,
 						zl, policy_nodemask(gfp, pol));
 		__mpol_put(pol);
 		put_mems_allowed();
@@ -1846,7 +1848,8 @@ alloc_page_vma(gfp_t gfp, struct vm_area
 	/*
 	 * fast path:  default or task policy
 	 */
-	page = __alloc_pages_nodemask(gfp, 0, zl, policy_nodemask(gfp, pol));
+	page = __alloc_pages_nodemask(gfp, order, zl,
+				      policy_nodemask(gfp, pol));
 	put_mems_allowed();
 	return page;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
