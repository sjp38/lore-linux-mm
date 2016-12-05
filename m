Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 95DF56B0267
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 04:18:51 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so353053356pgc.1
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:18:51 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0080.outbound.protection.outlook.com. [104.47.0.80])
        by mx.google.com with ESMTPS id v21si13943809pgh.212.2016.12.05.01.18.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 05 Dec 2016 01:18:50 -0800 (PST)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH v3 4/4] mm: hugetlb: support gigantic surplus pages
Date: Mon, 5 Dec 2016 17:17:11 +0800
Message-ID: <1480929431-22348-5-git-send-email-shijie.huang@arm.com>
In-Reply-To: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
References: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, vbabka@suze.cz, Huang Shijie <shijie.huang@arm.com>

When testing the gigantic page whose order is too large for the buddy
allocator, the libhugetlbfs test case "counter.sh" will fail.

The counter.sh is just a wrapper for counter.c, you can find them in:
  https://github.com/libhugetlbfs/libhugetlbfs/blob/master/tests/counters.c
  https://github.com/libhugetlbfs/libhugetlbfs/blob/master/tests/counters.sh

Please see the error log below:
 ............................................
    ........
    quota.sh (32M: 64):	PASS
    counters.sh (32M: 64):	FAIL mmap failed: Invalid argument
    ********** TEST SUMMARY
    *                      32M
    *                      32-bit 64-bit
    *     Total testcases:     0     87
    *             Skipped:     0      0
    *                PASS:     0     86
    *                FAIL:     0      1
    *    Killed by signal:     0      0
    *   Bad configuration:     0      0
    *       Expected FAIL:     0      0
    *     Unexpected PASS:     0      0
    * Strange test result:     0      0
    **********
 ............................................

The failure is caused by:
 1) kernel fails to allocate a gigantic page for the surplus case.
    And the gather_surplus_pages() will return NULL in the end.

 2) The condition checks for "over-commit" is wrong.

This patch does following things:

 1) This patch changes the condition checks for:
     return_unused_surplus_pages()
     nr_overcommit_hugepages_store()
     hugetlb_overcommit_handler()

 2) This patch introduces two helper functions:
    huge_nodemask() and __hugetlb_alloc_gigantic_page().
    Please see the descritions in the two functions.

 3) This patch uses __hugetlb_alloc_gigantic_page() to allocate the
    gigantic page in the __alloc_huge_page(). After this patch,
    gather_surplus_pages() can return a gigantic page for the surplus case.

After this patch, the counter.sh can pass for the gigantic page.

Signed-off-by: Huang Shijie <shijie.huang@arm.com>
---
 include/linux/mempolicy.h |  8 +++++
 mm/hugetlb.c              | 77 +++++++++++++++++++++++++++++++++++++++++++----
 mm/mempolicy.c            | 44 +++++++++++++++++++++++++++
 3 files changed, 123 insertions(+), 6 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 5f4d828..6539fbb 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -146,6 +146,8 @@ extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
 				enum mpol_rebind_step step);
 extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
 
+extern bool huge_nodemask(struct vm_area_struct *vma,
+				unsigned long addr, nodemask_t *mask);
 extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
 				struct mempolicy **mpol, nodemask_t **nodemask);
@@ -269,6 +271,12 @@ static inline void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 {
 }
 
+static inline bool huge_nodemask(struct vm_area_struct *vma,
+				unsigned long addr, nodemask_t *mask)
+{
+	return false;
+}
+
 static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
 				struct mempolicy **mpol, nodemask_t **nodemask)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1395bef..04440b8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1506,6 +1506,69 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 
 /*
  * There are 3 ways this can get called:
+ *
+ * 1. When the NUMA is not enabled, use alloc_gigantic_page() to get
+ *    the gigantic page.
+ *
+ * 2. The NUMA is enabled, but the vma is NULL.
+ *    Initialize the @mask, and use alloc_fresh_gigantic_page() to get
+ *    the gigantic page.
+ *
+ * 3. The NUMA is enabled, and the vma is valid.
+ *    Use the @vma's memory policy.
+ *    Get @mask by huge_nodemask(), and use alloc_fresh_gigantic_page()
+ *    to get the gigantic page.
+ */
+static struct page *__hugetlb_alloc_gigantic_page(struct hstate *h,
+		struct vm_area_struct *vma, unsigned long addr, int nid)
+{
+	NODEMASK_ALLOC(nodemask_t, mask, GFP_KERNEL | __GFP_NORETRY);
+	struct page *page = NULL;
+
+	/* Not NUMA */
+	if (!IS_ENABLED(CONFIG_NUMA)) {
+		if (nid == NUMA_NO_NODE)
+			nid = numa_mem_id();
+
+		page = alloc_gigantic_page(nid, huge_page_order(h));
+		if (page)
+			prep_compound_gigantic_page(page, huge_page_order(h));
+		goto got_page;
+	}
+
+	/* NUMA && !vma */
+	if (!vma) {
+		/* First, check the mask */
+		if (!mask) {
+			mask = &node_states[N_MEMORY];
+		} else {
+			if (nid == NUMA_NO_NODE) {
+				if (!init_nodemask_of_mempolicy(mask)) {
+					NODEMASK_FREE(mask);
+					mask = &node_states[N_MEMORY];
+				}
+			} else {
+				init_nodemask_of_node(mask, nid);
+			}
+		}
+
+		page = alloc_fresh_gigantic_page(h, mask, false);
+		goto got_page;
+	}
+
+	/* NUMA && vma */
+	if (mask && huge_nodemask(vma, addr, mask))
+		page = alloc_fresh_gigantic_page(h, mask, false);
+
+got_page:
+	if (mask != &node_states[N_MEMORY])
+		NODEMASK_FREE(mask);
+
+	return page;
+}
+
+/*
+ * There are 3 ways this can get called:
  * 1. With vma+addr: we use the VMA's memory policy
  * 2. With !vma, but nid=NUMA_NO_NODE:  We try to allocate a huge
  *    page from any node, and let the buddy allocator itself figure
@@ -1584,7 +1647,7 @@ static struct page *__alloc_huge_page(struct hstate *h,
 	struct page *page;
 	unsigned int r_nid;
 
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return NULL;
 
 	/*
@@ -1629,7 +1692,10 @@ static struct page *__alloc_huge_page(struct hstate *h,
 	}
 	spin_unlock(&hugetlb_lock);
 
-	page = __hugetlb_alloc_buddy_huge_page(h, vma, addr, nid);
+	if (hstate_is_gigantic(h))
+		page = __hugetlb_alloc_gigantic_page(h, vma, addr, nid);
+	else
+		page = __hugetlb_alloc_buddy_huge_page(h, vma, addr, nid);
 
 	spin_lock(&hugetlb_lock);
 	if (page) {
@@ -1796,8 +1862,7 @@ static void return_unused_surplus_pages(struct hstate *h,
 	/* Uncommit the reservation */
 	h->resv_huge_pages -= unused_resv_pages;
 
-	/* Cannot return gigantic pages currently */
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return;
 
 	nr_pages = min(unused_resv_pages, h->surplus_huge_pages);
@@ -2514,7 +2579,7 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 	unsigned long input;
 	struct hstate *h = kobj_to_hstate(kobj, NULL);
 
-	if (hstate_is_gigantic(h))
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return -EINVAL;
 
 	err = kstrtoul(buf, 10, &input);
@@ -2966,7 +3031,7 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 
 	tmp = h->nr_overcommit_huge_pages;
 
-	if (write && hstate_is_gigantic(h))
+	if (write && hstate_is_gigantic(h) && !gigantic_page_supported())
 		return -EINVAL;
 
 	table->data = &tmp;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 6d3639e..3550a29 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1800,6 +1800,50 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
 
 #ifdef CONFIG_HUGETLBFS
 /*
+ * huge_nodemask(@vma, @addr, @mask)
+ * @vma: virtual memory area whose policy is sought
+ * @addr: address in @vma
+ * @mask: should be a valid nodemask pointer, not NULL
+ *
+ * Return true if we can succeed in extracting the policy nodemask
+ * for 'bind' or 'interleave' policy into the argument @mask, or
+ * initializing the argument @mask to contain the single node for
+ * 'preferred' or 'local' policy.
+ */
+bool huge_nodemask(struct vm_area_struct *vma, unsigned long addr,
+			nodemask_t *mask)
+{
+	struct mempolicy *mpol;
+	bool ret = true;
+	int nid;
+
+	mpol = get_vma_policy(vma, addr);
+
+	switch (mpol->mode) {
+	case MPOL_PREFERRED:
+		if (mpol->flags & MPOL_F_LOCAL)
+			nid = numa_node_id();
+		else
+			nid = mpol->v.preferred_node;
+		init_nodemask_of_node(mask, nid);
+		break;
+
+	case MPOL_BIND:
+		/* Fall through */
+	case MPOL_INTERLEAVE:
+		*mask = mpol->v.nodes;
+		break;
+
+	default:
+		ret = false;
+		break;
+	}
+	mpol_cond_put(mpol);
+
+	return ret;
+}
+
+/*
  * huge_zonelist(@vma, @addr, @gfp_flags, @mpol)
  * @vma: virtual memory area whose policy is sought
  * @addr: address in @vma for shared policy lookup and interleave policy
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
