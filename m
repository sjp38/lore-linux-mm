From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: [RFC] reduce hugetlb_instantiation_mutex usage
Date: Thu, 26 Oct 2006 15:17:20 -0700
Message-ID: <000101c6f94c$8138c590$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Christoph Lameter' <christoph@schroedinger.engr.sgi.com>, 'David Gibson' <david@gibson.dropbear.id.au>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Andrew Morton <akpm@osdl.org>, Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

First rev of patch to allow hugetlb page fault to scale.

hugetlb_instantiation_mutex was introduced to prevent spurious allocation
failure in a corner case: two threads race to instantiate same page with
only one free page left in the global pool.  However, this global
serialization hurts fault performance badly as noted by Christoph Lameter.
This patch attempt to cut back the use of mutex only when free page resource
is limited, thus allow fault to scale in most common cases.


Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- ./mm/hugetlb.c.orig	2006-10-26 10:26:43.000000000 -0700
+++ ./mm/hugetlb.c	2006-10-26 13:18:03.000000000 -0700
@@ -542,6 +542,8 @@ int hugetlb_fault(struct mm_struct *mm, 
 	pte_t entry;
 	int ret;
 	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
+	static atomic_t token = ATOMIC_INIT(0);
+	int use_mutex = 0;
 
 	ptep = huge_pte_alloc(mm, address);
 	if (!ptep)
@@ -552,12 +554,15 @@ int hugetlb_fault(struct mm_struct *mm, 
 	 * get spurious allocation failures if two CPUs race to instantiate
 	 * the same page in the page cache.
 	 */
-	mutex_lock(&hugetlb_instantiation_mutex);
+	if (atomic_inc_return(&token) >= free_huge_pages) {
+		mutex_lock(&hugetlb_instantiation_mutex);
+		use_mutex = 1;
+	}
+
 	entry = *ptep;
 	if (pte_none(entry)) {
 		ret = hugetlb_no_page(mm, vma, address, ptep, write_access);
-		mutex_unlock(&hugetlb_instantiation_mutex);
-		return ret;
+		goto out;
 	}
 
 	ret = VM_FAULT_MINOR;
@@ -568,7 +573,11 @@ int hugetlb_fault(struct mm_struct *mm, 
 		if (write_access && !pte_write(entry))
 			ret = hugetlb_cow(mm, vma, address, ptep, entry);
 	spin_unlock(&mm->page_table_lock);
-	mutex_unlock(&hugetlb_instantiation_mutex);
+
+out:
+	atomic_dec(&token);
+	if (use_mutex)
+		mutex_unlock(&hugetlb_instantiation_mutex);
 
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
