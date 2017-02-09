Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9636B0388
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 12:50:36 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 80so14731606pfy.2
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 09:50:36 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id c66si10710873pfb.26.2017.02.09.09.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 09:50:35 -0800 (PST)
From: Grzegorz Andrejczuk <grzegorz.andrejczuk@intel.com>
Subject: [RFC] mm/hugetlb: use mem policy when allocating surplus huge pages
Date: Thu,  9 Feb 2017 18:50:20 +0100
Message-Id: <1486662620-18146-1-git-send-email-grzegorz.andrejczuk@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, gerald.schaefer@de.ibm.com, aneesh.kumar@linux.vnet.ibm.com, vaishali.thakkar@oracle.com, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Grzegorz Andrejczuk <grzegorz.andrejczuk@intel.com>

Application allocating overcommitted hugepages behave differently when
its mempolicy is set to bind with NUMA nodes containing CPUs and not
containing CPUs. When memory is allocated on node with CPUs everything
work as expected, when memory is allocated on CPU-less node:
1. Some memory is allocated from node with CPUs.
2. Application is terminated with SIGBUS (due to touching not allocated
   page).

Reproduction (Node0: 90GB, 272 logical CPUs; Node1: 16GB, No CPUs):
int
main()
{
  char *p = (char*)mmap(0, 4*1024*1024, PROT_READ|PROT_WRITE,
                 MAP_PRIVATE|MAP_ANONYMOUS|MAP_HUGETLB, 0, 0);
  *p = 0;
  p += 2*1024*1024;
  *p=0;
  return  0;
}

echo 2 > /proc/sys/vm/nr_overcommit_hugepages
numactl -m 0 ./test #works
numactl -m 1 ./test #sigbus

The reason for this behavior is hugetlb_reserve_pages(...) omits
struct vm_area when calling hugetlb_acct_pages(..) and later allocation is
unable to determine memory policy.

To fix this issue memory policy is forwarded from hugetlb_reserved_pages
to allocation routine.
When policy is interleave, NUMA Node is computed by:
  page address >> huge_page_shift() % interleaved nodes count.

This algorithm assumes that address is known, but in this case address
is not known so to keep interleave working without it, dummy address is
computed as vm_start + (1 << huge_page_shift())*n, where n is allocated
page number.

Signed-off-by: Grzegorz Andrejczuk <grzegorz.andrejczuk@intel.com>
---
 mm/hugetlb.c | 49 +++++++++++++++++++++++++++++++++++--------------
 1 file changed, 35 insertions(+), 14 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 418bf01..3913066 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -67,7 +67,8 @@ static int num_fault_mutexes;
 struct mutex *hugetlb_fault_mutex_table ____cacheline_aligned_in_smp;
 
 /* Forward declaration */
-static int hugetlb_acct_memory(struct hstate *h, long delta);
+static int hugetlb_acct_memory(struct hstate *h, long delta,
+			       struct vm_area_struct *vma);
 
 static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
 {
@@ -81,7 +82,7 @@ static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
 	if (free) {
 		if (spool->min_hpages != -1)
 			hugetlb_acct_memory(spool->hstate,
-						-spool->min_hpages);
+						-spool->min_hpages, NULL);
 		kfree(spool);
 	}
 }
@@ -101,7 +102,7 @@ struct hugepage_subpool *hugepage_new_subpool(struct hstate *h, long max_hpages,
 	spool->hstate = h;
 	spool->min_hpages = min_hpages;
 
-	if (min_hpages != -1 && hugetlb_acct_memory(h, min_hpages)) {
+	if (min_hpages != -1 && hugetlb_acct_memory(h, min_hpages, NULL)) {
 		kfree(spool);
 		return NULL;
 	}
@@ -576,7 +577,7 @@ void hugetlb_fix_reserve_counts(struct inode *inode)
 	if (rsv_adjust) {
 		struct hstate *h = hstate_inode(inode);
 
-		hugetlb_acct_memory(h, 1);
+		hugetlb_acct_memory(h, 1, NULL);
 	}
 }
 
@@ -1690,10 +1691,12 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
  * Increase the hugetlb pool such that it can accommodate a reservation
  * of size 'delta'.
  */
-static int gather_surplus_pages(struct hstate *h, int delta)
+static int gather_surplus_pages(struct hstate *h, int delta,
+				struct vm_area_struct *vma)
 {
 	struct list_head surplus_list;
 	struct page *page, *tmp;
+	unsigned long address_offset = 0;
 	int ret, i;
 	int needed, allocated;
 	bool alloc_ok = true;
@@ -1711,7 +1714,20 @@ static int gather_surplus_pages(struct hstate *h, int delta)
 retry:
 	spin_unlock(&hugetlb_lock);
 	for (i = 0; i < needed; i++) {
-		page = __alloc_buddy_huge_page_no_mpol(h, NUMA_NO_NODE);
+		if (vma) {
+			unsigned long dummy_addr = vma->vm_start +
+					(address_offset << huge_page_shift(h));
+
+			if (dummy_addr >= vma->vm_end) {
+				address_offset = 0;
+				dummy_addr = vma->vm_start;
+			}
+			page = __alloc_buddy_huge_page_with_mpol(h, vma,
+								 dummy_addr);
+			address_offset++;
+		} else {
+			page = __alloc_buddy_huge_page_no_mpol(h, NUMA_NO_NODE);
+		}
 		if (!page) {
 			alloc_ok = false;
 			break;
@@ -2057,7 +2073,7 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 		long rsv_adjust;
 
 		rsv_adjust = hugepage_subpool_put_pages(spool, 1);
-		hugetlb_acct_memory(h, -rsv_adjust);
+		hugetlb_acct_memory(h, -rsv_adjust, NULL);
 	}
 	return page;
 
@@ -3031,7 +3047,8 @@ unsigned long hugetlb_total_pages(void)
 	return nr_total_pages;
 }
 
-static int hugetlb_acct_memory(struct hstate *h, long delta)
+static int hugetlb_acct_memory(struct hstate *h, long delta,
+			       struct vm_area_struct *vma)
 {
 	int ret = -ENOMEM;
 
@@ -3054,7 +3071,7 @@ static int hugetlb_acct_memory(struct hstate *h, long delta)
 	 * semantics that cpuset has.
 	 */
 	if (delta > 0) {
-		if (gather_surplus_pages(h, delta) < 0)
+		if (gather_surplus_pages(h, delta, vma) < 0)
 			goto out;
 
 		if (delta > cpuset_mems_nr(h->free_huge_pages_node)) {
@@ -3112,7 +3129,7 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 		 * adjusted if the subpool has a minimum size.
 		 */
 		gbl_reserve = hugepage_subpool_put_pages(spool, reserve);
-		hugetlb_acct_memory(h, -gbl_reserve);
+		hugetlb_acct_memory(h, -gbl_reserve, NULL);
 	}
 }
 
@@ -4167,9 +4184,13 @@ int hugetlb_reserve_pages(struct inode *inode,
 
 	/*
 	 * Check enough hugepages are available for the reservation.
-	 * Hand the pages back to the subpool if there are not
+	 * Hand the pages back to the subpool if there are not.
 	 */
-	ret = hugetlb_acct_memory(h, gbl_reserve);
+	if (!vma || vma->vm_flags & VM_MAYSHARE)
+		ret = hugetlb_acct_memory(h, gbl_reserve, NULL);
+	else
+		ret = hugetlb_acct_memory(h, gbl_reserve, vma);
+
 	if (ret < 0) {
 		/* put back original number of pages, chg */
 		(void)hugepage_subpool_put_pages(spool, chg);
@@ -4202,7 +4223,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 
 			rsv_adjust = hugepage_subpool_put_pages(spool,
 								chg - add);
-			hugetlb_acct_memory(h, -rsv_adjust);
+			hugetlb_acct_memory(h, -rsv_adjust, NULL);
 		}
 	}
 	return 0;
@@ -4243,7 +4264,7 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
 	 * reservations to be released may be adjusted.
 	 */
 	gbl_reserve = hugepage_subpool_put_pages(spool, (chg - freed));
-	hugetlb_acct_memory(h, -gbl_reserve);
+	hugetlb_acct_memory(h, -gbl_reserve, NULL);
 
 	return 0;
 }
-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
