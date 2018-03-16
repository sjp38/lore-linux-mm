Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB306B000A
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:14:23 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id q185so5392960qke.0
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:14:23 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 26si8656484qtu.221.2018.03.16.12.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:14:22 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 05/14] mm/hmm: use struct for hmm_vma_fault(), hmm_vma_get_pfns() parameters
Date: Fri, 16 Mar 2018 15:14:10 -0400
Message-Id: <20180316191414.3223-6-jglisse@redhat.com>
In-Reply-To: <20180316191414.3223-1-jglisse@redhat.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Both hmm_vma_fault() and hmm_vma_get_pfns() were taking a hmm_range
struct as parameter and were initializing that struct with others of
their parameters. Have caller of those function do this as they are
likely to already do and only pass this struct to both function this
shorten function signature and make it easiers in the future to add
new parameters by simply adding them to the structure.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h | 18 ++++---------
 mm/hmm.c            | 78 +++++++++++++++++++----------------------------------
 2 files changed, 33 insertions(+), 63 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 61b0e1c05ee1..b65e527dd120 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -274,6 +274,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
 /*
  * struct hmm_range - track invalidation lock on virtual address range
  *
+ * @vma: the vm area struct for the range
  * @list: all range lock are on a list
  * @start: range virtual start address (inclusive)
  * @end: range virtual end address (exclusive)
@@ -281,6 +282,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
  * @valid: pfns array did not change since it has been fill by an HMM function
  */
 struct hmm_range {
+	struct vm_area_struct	*vma;
 	struct list_head	list;
 	unsigned long		start;
 	unsigned long		end;
@@ -301,12 +303,8 @@ struct hmm_range {
  *
  * IF YOU DO NOT FOLLOW THE ABOVE RULE THE SNAPSHOT CONTENT MIGHT BE INVALID !
  */
-int hmm_vma_get_pfns(struct vm_area_struct *vma,
-		     struct hmm_range *range,
-		     unsigned long start,
-		     unsigned long end,
-		     hmm_pfn_t *pfns);
-bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range);
+int hmm_vma_get_pfns(struct hmm_range *range);
+bool hmm_vma_range_done(struct hmm_range *range);
 
 
 /*
@@ -327,13 +325,7 @@ bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range);
  *
  * See the function description in mm/hmm.c for further documentation.
  */
-int hmm_vma_fault(struct vm_area_struct *vma,
-		  struct hmm_range *range,
-		  unsigned long start,
-		  unsigned long end,
-		  hmm_pfn_t *pfns,
-		  bool write,
-		  bool block);
+int hmm_vma_fault(struct hmm_range *range, bool write, bool block);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 64d9e7dae712..49f0f6b337ed 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -490,11 +490,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 
 /*
  * hmm_vma_get_pfns() - snapshot CPU page table for a range of virtual addresses
- * @vma: virtual memory area containing the virtual address range
- * @range: used to track snapshot validity
- * @start: range virtual start address (inclusive)
- * @end: range virtual end address (exclusive)
- * @entries: array of hmm_pfn_t: provided by the caller, filled in by function
+ * @range: range being snapshoted and all needed informations
  * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, 0 success
  *
  * This snapshots the CPU page table for a range of virtual addresses. Snapshot
@@ -508,26 +504,23 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
  * NOT CALLING hmm_vma_range_done() IF FUNCTION RETURNS 0 WILL LEAD TO SERIOUS
  * MEMORY CORRUPTION ! YOU HAVE BEEN WARNED !
  */
-int hmm_vma_get_pfns(struct vm_area_struct *vma,
-		     struct hmm_range *range,
-		     unsigned long start,
-		     unsigned long end,
-		     hmm_pfn_t *pfns)
+int hmm_vma_get_pfns(struct hmm_range *range)
 {
+	struct vm_area_struct *vma = range->vma;
 	struct hmm_vma_walk hmm_vma_walk;
 	struct mm_walk mm_walk;
 	struct hmm *hmm;
 
 	/* FIXME support hugetlb fs */
 	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
-		hmm_pfns_special(pfns, start, end);
+		hmm_pfns_special(range->pfns, range->start, range->end);
 		return -EINVAL;
 	}
 
 	/* Sanity check, this really should not happen ! */
-	if (start < vma->vm_start || start >= vma->vm_end)
+	if (range->start < vma->vm_start || range->start >= vma->vm_end)
 		return -EINVAL;
-	if (end < vma->vm_start || end > vma->vm_end)
+	if (range->end < vma->vm_start || range->end > vma->vm_end)
 		return -EINVAL;
 
 	hmm = hmm_register(vma->vm_mm);
@@ -538,9 +531,6 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 		return -EINVAL;
 
 	/* Initialize range to track CPU page table update */
-	range->start = start;
-	range->pfns = pfns;
-	range->end = end;
 	spin_lock(&hmm->lock);
 	range->valid = true;
 	list_add_rcu(&range->list, &hmm->ranges);
@@ -558,14 +548,13 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 	mm_walk.pmd_entry = hmm_vma_walk_pmd;
 	mm_walk.pte_hole = hmm_vma_walk_hole;
 
-	walk_page_range(start, end, &mm_walk);
+	walk_page_range(range->start, range->end, &mm_walk);
 	return 0;
 }
 EXPORT_SYMBOL(hmm_vma_get_pfns);
 
 /*
  * hmm_vma_range_done() - stop tracking change to CPU page table over a range
- * @vma: virtual memory area containing the virtual address range
  * @range: range being tracked
  * Returns: false if range data has been invalidated, true otherwise
  *
@@ -585,10 +574,10 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
  *
  * There are two ways to use this :
  * again:
- *   hmm_vma_get_pfns(vma, range, start, end, pfns); or hmm_vma_fault(...);
+ *   hmm_vma_get_pfns(range); or hmm_vma_fault(...);
  *   trans = device_build_page_table_update_transaction(pfns);
  *   device_page_table_lock();
- *   if (!hmm_vma_range_done(vma, range)) {
+ *   if (!hmm_vma_range_done(range)) {
  *     device_page_table_unlock();
  *     goto again;
  *   }
@@ -596,13 +585,13 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
  *   device_page_table_unlock();
  *
  * Or:
- *   hmm_vma_get_pfns(vma, range, start, end, pfns); or hmm_vma_fault(...);
+ *   hmm_vma_get_pfns(range); or hmm_vma_fault(...);
  *   device_page_table_lock();
- *   hmm_vma_range_done(vma, range);
- *   device_update_page_table(pfns);
+ *   hmm_vma_range_done(range);
+ *   device_update_page_table(range->pfns);
  *   device_page_table_unlock();
  */
-bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range)
+bool hmm_vma_range_done(struct hmm_range *range)
 {
 	unsigned long npages = (range->end - range->start) >> PAGE_SHIFT;
 	struct hmm *hmm;
@@ -612,7 +601,7 @@ bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range)
 		return false;
 	}
 
-	hmm = hmm_register(vma->vm_mm);
+	hmm = hmm_register(range->vma->vm_mm);
 	if (!hmm) {
 		memset(range->pfns, 0, sizeof(*range->pfns) * npages);
 		return false;
@@ -628,11 +617,7 @@ EXPORT_SYMBOL(hmm_vma_range_done);
 
 /*
  * hmm_vma_fault() - try to fault some address in a virtual address range
- * @vma: virtual memory area containing the virtual address range
- * @range: use to track pfns array content validity
- * @start: fault range virtual start address (inclusive)
- * @end: fault range virtual end address (exclusive)
- * @pfns: array of hmm_pfn_t, only entry with fault flag set will be faulted
+ * @range: range being faulted and all needed informations
  * @write: is it a write fault
  * @block: allow blocking on fault (if true it sleeps and do not drop mmap_sem)
  * Returns: 0 success, error otherwise (-EAGAIN means mmap_sem have been drop)
@@ -648,10 +633,10 @@ EXPORT_SYMBOL(hmm_vma_range_done);
  *   down_read(&mm->mmap_sem);
  *   // Find vma and address device wants to fault, initialize hmm_pfn_t
  *   // array accordingly
- *   ret = hmm_vma_fault(vma, start, end, pfns, allow_retry);
+ *   ret = hmm_vma_fault(range, write, block);
  *   switch (ret) {
  *   case -EAGAIN:
- *     hmm_vma_range_done(vma, range);
+ *     hmm_vma_range_done(range);
  *     // You might want to rate limit or yield to play nicely, you may
  *     // also commit any valid pfn in the array assuming that you are
  *     // getting true from hmm_vma_range_monitor_end()
@@ -665,7 +650,7 @@ EXPORT_SYMBOL(hmm_vma_range_done);
  *   }
  *   // Take device driver lock that serialize device page table update
  *   driver_lock_device_page_table_update();
- *   hmm_vma_range_done(vma, range);
+ *   hmm_vma_range_done(range);
  *   // Commit pfns we got from hmm_vma_fault()
  *   driver_unlock_device_page_table_update();
  *   up_read(&mm->mmap_sem)
@@ -675,28 +660,24 @@ EXPORT_SYMBOL(hmm_vma_range_done);
  *
  * YOU HAVE BEEN WARNED !
  */
-int hmm_vma_fault(struct vm_area_struct *vma,
-		  struct hmm_range *range,
-		  unsigned long start,
-		  unsigned long end,
-		  hmm_pfn_t *pfns,
-		  bool write,
-		  bool block)
+int hmm_vma_fault(struct hmm_range *range, bool write, bool block)
 {
+	struct vm_area_struct *vma = range->vma;
+	unsigned long start = range->start;
 	struct hmm_vma_walk hmm_vma_walk;
 	struct mm_walk mm_walk;
 	struct hmm *hmm;
 	int ret;
 
 	/* Sanity check, this really should not happen ! */
-	if (start < vma->vm_start || start >= vma->vm_end)
+	if (range->start < vma->vm_start || range->start >= vma->vm_end)
 		return -EINVAL;
-	if (end < vma->vm_start || end > vma->vm_end)
+	if (range->end < vma->vm_start || range->end > vma->vm_end)
 		return -EINVAL;
 
 	hmm = hmm_register(vma->vm_mm);
 	if (!hmm) {
-		hmm_pfns_clear(pfns, start, end);
+		hmm_pfns_clear(range->pfns, range->start, range->end);
 		return -ENOMEM;
 	}
 	/* Caller must have registered a mirror using hmm_mirror_register() */
@@ -704,9 +685,6 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 		return -EINVAL;
 
 	/* Initialize range to track CPU page table update */
-	range->start = start;
-	range->pfns = pfns;
-	range->end = end;
 	spin_lock(&hmm->lock);
 	range->valid = true;
 	list_add_rcu(&range->list, &hmm->ranges);
@@ -714,7 +692,7 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 
 	/* FIXME support hugetlb fs */
 	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
-		hmm_pfns_special(pfns, start, end);
+		hmm_pfns_special(range->pfns, range->start, range->end);
 		return 0;
 	}
 
@@ -734,7 +712,7 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 	mm_walk.pte_hole = hmm_vma_walk_hole;
 
 	do {
-		ret = walk_page_range(start, end, &mm_walk);
+		ret = walk_page_range(start, range->end, &mm_walk);
 		start = hmm_vma_walk.last;
 	} while (ret == -EAGAIN);
 
@@ -742,8 +720,8 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 		unsigned long i;
 
 		i = (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
-		hmm_pfns_clear(&pfns[i], hmm_vma_walk.last, end);
-		hmm_vma_range_done(vma, range);
+		hmm_pfns_clear(&range->pfns[i], hmm_vma_walk.last, range->end);
+		hmm_vma_range_done(range);
 	}
 	return ret;
 }
-- 
2.14.3
