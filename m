Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 958A96B0255
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 15:53:23 -0400 (EDT)
Received: by iodv82 with SMTP id v82so34554481iod.0
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 12:53:23 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id w6si4604621igk.15.2015.10.20.12.53.18
        for <linux-mm@kvack.org>;
        Tue, 20 Oct 2015 12:53:18 -0700 (PDT)
Subject: [PATCH] mm, hugetlb: use memory policy when available
From: Dave Hansen <dave@sr71.net>
Date: Tue, 20 Oct 2015 12:53:17 -0700
Message-Id: <20151020195317.ADA052D8@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

I have a hugetlbfs user which is never explicitly allocating huge pages
with 'nr_hugepages'.  They only set 'nr_overcommit_hugepages' and then let
the pages be allocated from the buddy allocator at fault time.

This works, but they noticed that mbind() was not doing them any good and
the pages were being allocated without respect for the policy they
specified.

The code in question is this:

> struct page *alloc_huge_page(struct vm_area_struct *vma,
...
>         page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, gbl_chg);
>         if (!page) {
>                 page = alloc_buddy_huge_page(h, NUMA_NO_NODE);

dequeue_huge_page_vma() is smart and will respect the VMA's memory policy.
But, it only grabs _existing_ huge pages from the huge page pool.  If the
pool is empty, we fall back to alloc_buddy_huge_page() which obviously
can't do anything with the VMA's policy because it isn't even passed the
VMA.

Almost everybody preallocates huge pages.  That's probably why nobody has
ever noticed this.  Looking back at the git history, I don't think this
_ever_ worked from when alloc_buddy_huge_page() was introduced in 7893d1d5,
8 years ago.

The fix is to pass vma/addr down in to the places where we actually call in
to the buddy allocator.  It's fairly straightforward plumbing.  This has
been lightly tested.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/mm/hugetlb.c |  111 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 99 insertions(+), 12 deletions(-)

diff -puN mm/hugetlb.c~hugetlbfs-fix-mbind-when-demand-allocating mm/hugetlb.c
--- a/mm/hugetlb.c~hugetlbfs-fix-mbind-when-demand-allocating	2015-10-20 12:50:55.598628613 -0700
+++ b/mm/hugetlb.c	2015-10-20 12:50:55.605628929 -0700
@@ -1437,7 +1437,76 @@ void dissolve_free_huge_pages(unsigned l
 		dissolve_free_huge_page(pfn_to_page(pfn));
 }
 
-static struct page *alloc_buddy_huge_page(struct hstate *h, int nid)
+/*
+ * There are 3 ways this can get called:
+ * 1. With vma+addr: we use the VMA's memory policy
+ * 2. With !vma, but nid=NUMA_NO_NODE:  We try to allocate a huge
+ *    page from any node, and let the buddy allocator itself figure
+ *    it out.
+ * 3. With !vma, but nid!=NUMA_NO_NODE.  We allocate a huge page
+ *    strictly from 'nid'
+ */
+static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
+		struct vm_area_struct *vma, unsigned long addr, int nid)
+{
+	int order = huge_page_order(h);
+	gfp_t gfp = htlb_alloc_mask(h)|__GFP_COMP|__GFP_REPEAT|__GFP_NOWARN;
+	unsigned int cpuset_mems_cookie;
+
+	/*
+	 * We need a VMA to get a memory policy.  If we do not
+	 * have one, we use the 'nid' argument
+	 */
+	if (!vma) {
+		/*
+		 * If a specific node is requested, make sure to
+		 * get memory from there, but only when a node
+		 * is explicitly specified.
+		 */
+		if (nid != NUMA_NO_NODE)
+			gfp |= __GFP_THISNODE;
+		/*
+		 * Make sure to call something that can handle
+		 * nid=NUMA_NO_NODE
+		 */
+		return alloc_pages_node(nid, gfp, order);
+	}
+
+	/*
+	 * OK, so we have a VMA.  Fetch the mempolicy and try to
+	 * allocate a huge page with it.
+	 */
+	do {
+		struct page *page;
+		struct mempolicy *mpol;
+		struct zonelist *zl;
+		nodemask_t *nodemask;
+
+		cpuset_mems_cookie = read_mems_allowed_begin();
+		zl = huge_zonelist(vma, addr, gfp, &mpol, &nodemask);
+		mpol_cond_put(mpol);
+		page = __alloc_pages_nodemask(gfp, order, zl, nodemask);
+		if (page)
+			return page;
+	} while (read_mems_allowed_retry(cpuset_mems_cookie));
+
+	return NULL;
+}
+
+/*
+ * There are two ways to allocate a huge page:
+ * 1. When you have a VMA and an address (like a fault)
+ * 2. When you have no VMA (like when setting /proc/.../nr_hugepages)
+ *
+ * 'vma' and 'addr' are only for (1).  'nid' is always NUMA_NO_NODE in
+ * this case which signifies that the allocation should be done with
+ * respect for the VMA's memory policy.
+ *
+ * For (2), we ignore 'vma' and 'addr' and use 'nid' exclusively. This
+ * implies that memory policies will not be taken in to account.
+ */
+static struct page *__alloc_buddy_huge_page(struct hstate *h,
+		struct vm_area_struct *vma, unsigned long addr, int nid)
 {
 	struct page *page;
 	unsigned int r_nid;
@@ -1445,6 +1514,10 @@ static struct page *alloc_buddy_huge_pag
 	if (hstate_is_gigantic(h))
 		return NULL;
 
+	if (vma || addr) {
+		WARN_ON_ONCE(!addr || addr == -1);
+		WARN_ON_ONCE(nid != NUMA_NO_NODE);
+	}
 	/*
 	 * Assume we will successfully allocate the surplus page to
 	 * prevent racing processes from causing the surplus to exceed
@@ -1478,14 +1551,7 @@ static struct page *alloc_buddy_huge_pag
 	}
 	spin_unlock(&hugetlb_lock);
 
-	if (nid == NUMA_NO_NODE)
-		page = alloc_pages(htlb_alloc_mask(h)|__GFP_COMP|
-				   __GFP_REPEAT|__GFP_NOWARN,
-				   huge_page_order(h));
-	else
-		page = __alloc_pages_node(nid,
-			htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
-			__GFP_REPEAT|__GFP_NOWARN, huge_page_order(h));
+	page = __hugetlb_alloc_buddy_huge_page(h, vma, addr, nid);
 
 	spin_lock(&hugetlb_lock);
 	if (page) {
@@ -1510,6 +1576,27 @@ static struct page *alloc_buddy_huge_pag
 }
 
 /*
+ * Allocate a huge page from 'nid'.  Note, 'nid' may be
+ * NUMA_NO_NODE, which means that it may be allocated
+ * anywhere.
+ */
+struct page *__alloc_buddy_huge_page_no_mpol(struct hstate *h, int nid)
+{
+	unsigned long addr = -1;
+
+	return __alloc_buddy_huge_page(h, NULL, addr, nid);
+}
+
+/*
+ * Use the VMA's mpolicy to allocate a huge page from the buddy.
+ */
+struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
+		struct vm_area_struct *vma, unsigned long addr)
+{
+	return __alloc_buddy_huge_page(h, vma, addr, NUMA_NO_NODE);
+}
+
+/*
  * This allocation function is useful in the context where vma is irrelevant.
  * E.g. soft-offlining uses this function because it only cares physical
  * address of error page.
@@ -1524,7 +1611,7 @@ struct page *alloc_huge_page_node(struct
 	spin_unlock(&hugetlb_lock);
 
 	if (!page)
-		page = alloc_buddy_huge_page(h, nid);
+		page = __alloc_buddy_huge_page_no_mpol(h, nid);
 
 	return page;
 }
@@ -1554,7 +1641,7 @@ static int gather_surplus_pages(struct h
 retry:
 	spin_unlock(&hugetlb_lock);
 	for (i = 0; i < needed; i++) {
-		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
+		page = __alloc_buddy_huge_page_no_mpol(h, NUMA_NO_NODE);
 		if (!page) {
 			alloc_ok = false;
 			break;
@@ -1787,7 +1874,7 @@ struct page *alloc_huge_page(struct vm_a
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, gbl_chg);
 	if (!page) {
 		spin_unlock(&hugetlb_lock);
-		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
+		page = __alloc_buddy_huge_page_with_mpol(h, vma, addr);
 		if (!page)
 			goto out_uncharge_cgroup;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
