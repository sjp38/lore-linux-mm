Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC2896B02FA
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 20:06:02 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id t37so26300096qtg.6
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 17:06:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r125si1817998qkb.213.2017.08.16.17.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 17:06:01 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM-v25 05/19] mm/hmm/mirror: device page fault handler
Date: Wed, 16 Aug 2017 20:05:34 -0400
Message-Id: <20170817000548.32038-6-jglisse@redhat.com>
In-Reply-To: <20170817000548.32038-1-jglisse@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

This handle page fault on behalf of device driver, unlike handle_mm_fault()
it does not trigger migration back to system memory for device memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h |  27 ++++++
 mm/hmm.c            | 256 +++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 271 insertions(+), 12 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 4cb6f9706c3c..79f5d4fa2d4f 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -292,6 +292,33 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 		     unsigned long end,
 		     hmm_pfn_t *pfns);
 bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range);
+
+
+/*
+ * Fault memory on behalf of device driver. Unlike handle_mm_fault(), this will
+ * not migrate any device memory back to system memory. The hmm_pfn_t array will
+ * be updated with the fault result and current snapshot of the CPU page table
+ * for the range.
+ *
+ * The mmap_sem must be taken in read mode before entering and it might be
+ * dropped by the function if the block argument is false. In that case, the
+ * function returns -EAGAIN.
+ *
+ * Return value does not reflect if the fault was successful for every single
+ * address or not. Therefore, the caller must to inspect the hmm_pfn_t array to
+ * determine fault status for each address.
+ *
+ * Trying to fault inside an invalid vma will result in -EINVAL.
+ *
+ * See the function description in mm/hmm.c for further documentation.
+ */
+int hmm_vma_fault(struct vm_area_struct *vma,
+		  struct hmm_range *range,
+		  unsigned long start,
+		  unsigned long end,
+		  hmm_pfn_t *pfns,
+		  bool write,
+		  bool block);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 
diff --git a/mm/hmm.c b/mm/hmm.c
index b8a24b80463e..91592dae364e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -236,6 +236,36 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
 
+struct hmm_vma_walk {
+	struct hmm_range	*range;
+	unsigned long		last;
+	bool			fault;
+	bool			block;
+	bool			write;
+};
+
+static int hmm_vma_do_fault(struct mm_walk *walk,
+			    unsigned long addr,
+			    hmm_pfn_t *pfn)
+{
+	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct vm_area_struct *vma = walk->vma;
+	int r;
+
+	flags |= hmm_vma_walk->block ? 0 : FAULT_FLAG_ALLOW_RETRY;
+	flags |= hmm_vma_walk->write ? FAULT_FLAG_WRITE : 0;
+	r = handle_mm_fault(vma, addr, flags);
+	if (r & VM_FAULT_RETRY)
+		return -EBUSY;
+	if (r & VM_FAULT_ERROR) {
+		*pfn = HMM_PFN_ERROR;
+		return -EFAULT;
+	}
+
+	return -EAGAIN;
+}
+
 static void hmm_pfns_special(hmm_pfn_t *pfns,
 			     unsigned long addr,
 			     unsigned long end)
@@ -259,34 +289,62 @@ static int hmm_pfns_bad(unsigned long addr,
 	return 0;
 }
 
+static void hmm_pfns_clear(hmm_pfn_t *pfns,
+			   unsigned long addr,
+			   unsigned long end)
+{
+	for (; addr < end; addr += PAGE_SIZE, pfns++)
+		*pfns = 0;
+}
+
 static int hmm_vma_walk_hole(unsigned long addr,
 			     unsigned long end,
 			     struct mm_walk *walk)
 {
-	struct hmm_range *range = walk->private;
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
 	hmm_pfn_t *pfns = range->pfns;
 	unsigned long i;
 
+	hmm_vma_walk->last = addr;
 	i = (addr - range->start) >> PAGE_SHIFT;
-	for (; addr < end; addr += PAGE_SIZE, i++)
+	for (; addr < end; addr += PAGE_SIZE, i++) {
 		pfns[i] = HMM_PFN_EMPTY;
+		if (hmm_vma_walk->fault) {
+			int ret;
 
-	return 0;
+			ret = hmm_vma_do_fault(walk, addr, &pfns[i]);
+			if (ret != -EAGAIN)
+				return ret;
+		}
+	}
+
+	return hmm_vma_walk->fault ? -EAGAIN : 0;
 }
 
 static int hmm_vma_walk_clear(unsigned long addr,
 			      unsigned long end,
 			      struct mm_walk *walk)
 {
-	struct hmm_range *range = walk->private;
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
 	hmm_pfn_t *pfns = range->pfns;
 	unsigned long i;
 
+	hmm_vma_walk->last = addr;
 	i = (addr - range->start) >> PAGE_SHIFT;
-	for (; addr < end; addr += PAGE_SIZE, i++)
+	for (; addr < end; addr += PAGE_SIZE, i++) {
 		pfns[i] = 0;
+		if (hmm_vma_walk->fault) {
+			int ret;
 
-	return 0;
+			ret = hmm_vma_do_fault(walk, addr, &pfns[i]);
+			if (ret != -EAGAIN)
+				return ret;
+		}
+	}
+
+	return hmm_vma_walk->fault ? -EAGAIN : 0;
 }
 
 static int hmm_vma_walk_pmd(pmd_t *pmdp,
@@ -294,15 +352,18 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 			    unsigned long end,
 			    struct mm_walk *walk)
 {
-	struct hmm_range *range = walk->private;
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
 	struct vm_area_struct *vma = walk->vma;
 	hmm_pfn_t *pfns = range->pfns;
 	unsigned long addr = start, i;
+	bool write_fault;
 	hmm_pfn_t flag;
 	pte_t *ptep;
 
 	i = (addr - range->start) >> PAGE_SHIFT;
 	flag = vma->vm_flags & VM_READ ? HMM_PFN_READ : 0;
+	write_fault = hmm_vma_walk->fault & hmm_vma_walk->write;
 
 again:
 	if (pmd_none(*pmdp))
@@ -331,6 +392,9 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		if (pmd_protnone(pmd))
 			return hmm_vma_walk_clear(start, end, walk);
 
+		if (write_fault && !pmd_write(pmd))
+			return hmm_vma_walk_clear(start, end, walk);
+
 		pfn = pmd_pfn(pmd) + pte_index(addr);
 		flag |= pmd_write(pmd) ? HMM_PFN_WRITE : 0;
 		for (; addr < end; addr += PAGE_SIZE, i++, pfn++)
@@ -347,13 +411,55 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 
 		pfns[i] = 0;
 
-		if (pte_none(pte) || !pte_present(pte)) {
+		if (pte_none(pte)) {
 			pfns[i] = HMM_PFN_EMPTY;
+			if (hmm_vma_walk->fault)
+				goto fault;
 			continue;
 		}
 
+		if (!pte_present(pte)) {
+			swp_entry_t entry;
+
+			if (!non_swap_entry(entry)) {
+				if (hmm_vma_walk->fault)
+					goto fault;
+				continue;
+			}
+
+			entry = pte_to_swp_entry(pte);
+
+			/*
+			 * This is a special swap entry, ignore migration, use
+			 * device and report anything else as error.
+			 */
+			if (is_migration_entry(entry)) {
+				if (hmm_vma_walk->fault) {
+					pte_unmap(ptep);
+					hmm_vma_walk->last = addr;
+					migration_entry_wait(vma->vm_mm,
+							     pmdp, addr);
+					return -EAGAIN;
+				}
+				continue;
+			} else {
+				/* Report error for everything else */
+				pfns[i] = HMM_PFN_ERROR;
+			}
+			continue;
+		}
+
+		if (write_fault && !pte_write(pte))
+			goto fault;
+
 		pfns[i] = hmm_pfn_t_from_pfn(pte_pfn(pte)) | flag;
 		pfns[i] |= pte_write(pte) ? HMM_PFN_WRITE : 0;
+		continue;
+
+fault:
+		pte_unmap(ptep);
+		/* Fault all pages in range */
+		return hmm_vma_walk_clear(start, end, walk);
 	}
 	pte_unmap(ptep - 1);
 
@@ -386,6 +492,7 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 		     unsigned long end,
 		     hmm_pfn_t *pfns)
 {
+	struct hmm_vma_walk hmm_vma_walk;
 	struct mm_walk mm_walk;
 	struct hmm *hmm;
 
@@ -417,9 +524,12 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 	list_add_rcu(&range->list, &hmm->ranges);
 	spin_unlock(&hmm->lock);
 
+	hmm_vma_walk.fault = false;
+	hmm_vma_walk.range = range;
+	mm_walk.private = &hmm_vma_walk;
+
 	mm_walk.vma = vma;
 	mm_walk.mm = vma->vm_mm;
-	mm_walk.private = range;
 	mm_walk.pte_entry = NULL;
 	mm_walk.test_walk = NULL;
 	mm_walk.hugetlb_entry = NULL;
@@ -427,7 +537,6 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 	mm_walk.pte_hole = hmm_vma_walk_hole;
 
 	walk_page_range(start, end, &mm_walk);
-
 	return 0;
 }
 EXPORT_SYMBOL(hmm_vma_get_pfns);
@@ -454,7 +563,7 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
  *
  * There are two ways to use this :
  * again:
- *   hmm_vma_get_pfns(vma, range, start, end, pfns);
+ *   hmm_vma_get_pfns(vma, range, start, end, pfns); or hmm_vma_fault(...);
  *   trans = device_build_page_table_update_transaction(pfns);
  *   device_page_table_lock();
  *   if (!hmm_vma_range_done(vma, range)) {
@@ -465,7 +574,7 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
  *   device_page_table_unlock();
  *
  * Or:
- *   hmm_vma_get_pfns(vma, range, start, end, pfns);
+ *   hmm_vma_get_pfns(vma, range, start, end, pfns); or hmm_vma_fault(...);
  *   device_page_table_lock();
  *   hmm_vma_range_done(vma, range);
  *   device_update_page_table(pfns);
@@ -494,4 +603,127 @@ bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range)
 	return range->valid;
 }
 EXPORT_SYMBOL(hmm_vma_range_done);
+
+/*
+ * hmm_vma_fault() - try to fault some address in a virtual address range
+ * @vma: virtual memory area containing the virtual address range
+ * @range: use to track pfns array content validity
+ * @start: fault range virtual start address (inclusive)
+ * @end: fault range virtual end address (exclusive)
+ * @pfns: array of hmm_pfn_t, only entry with fault flag set will be faulted
+ * @write: is it a write fault
+ * @block: allow blocking on fault (if true it sleeps and do not drop mmap_sem)
+ * Returns: 0 success, error otherwise (-EAGAIN means mmap_sem have been drop)
+ *
+ * This is similar to a regular CPU page fault except that it will not trigger
+ * any memory migration if the memory being faulted is not accessible by CPUs.
+ *
+ * On error, for one virtual address in the range, the function will set the
+ * hmm_pfn_t error flag for the corresponding pfn entry.
+ *
+ * Expected use pattern:
+ * retry:
+ *   down_read(&mm->mmap_sem);
+ *   // Find vma and address device wants to fault, initialize hmm_pfn_t
+ *   // array accordingly
+ *   ret = hmm_vma_fault(vma, start, end, pfns, allow_retry);
+ *   switch (ret) {
+ *   case -EAGAIN:
+ *     hmm_vma_range_done(vma, range);
+ *     // You might want to rate limit or yield to play nicely, you may
+ *     // also commit any valid pfn in the array assuming that you are
+ *     // getting true from hmm_vma_range_monitor_end()
+ *     goto retry;
+ *   case 0:
+ *     break;
+ *   default:
+ *     // Handle error !
+ *     up_read(&mm->mmap_sem)
+ *     return;
+ *   }
+ *   // Take device driver lock that serialize device page table update
+ *   driver_lock_device_page_table_update();
+ *   hmm_vma_range_done(vma, range);
+ *   // Commit pfns we got from hmm_vma_fault()
+ *   driver_unlock_device_page_table_update();
+ *   up_read(&mm->mmap_sem)
+ *
+ * YOU MUST CALL hmm_vma_range_done() AFTER THIS FUNCTION RETURN SUCCESS (0)
+ * BEFORE FREEING THE range struct OR YOU WILL HAVE SERIOUS MEMORY CORRUPTION !
+ *
+ * YOU HAVE BEEN WARNED !
+ */
+int hmm_vma_fault(struct vm_area_struct *vma,
+		  struct hmm_range *range,
+		  unsigned long start,
+		  unsigned long end,
+		  hmm_pfn_t *pfns,
+		  bool write,
+		  bool block)
+{
+	struct hmm_vma_walk hmm_vma_walk;
+	struct mm_walk mm_walk;
+	struct hmm *hmm;
+	int ret;
+
+	/* Sanity check, this really should not happen ! */
+	if (start < vma->vm_start || start >= vma->vm_end)
+		return -EINVAL;
+	if (end < vma->vm_start || end > vma->vm_end)
+		return -EINVAL;
+
+	hmm = hmm_register(vma->vm_mm);
+	if (!hmm) {
+		hmm_pfns_clear(pfns, start, end);
+		return -ENOMEM;
+	}
+	/* Caller must have registered a mirror using hmm_mirror_register() */
+	if (!hmm->mmu_notifier.ops)
+		return -EINVAL;
+
+	/* Initialize range to track CPU page table update */
+	range->start = start;
+	range->pfns = pfns;
+	range->end = end;
+	spin_lock(&hmm->lock);
+	range->valid = true;
+	list_add_rcu(&range->list, &hmm->ranges);
+	spin_unlock(&hmm->lock);
+
+	/* FIXME support hugetlb fs */
+	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
+		hmm_pfns_special(pfns, start, end);
+		return 0;
+	}
+
+	hmm_vma_walk.fault = true;
+	hmm_vma_walk.write = write;
+	hmm_vma_walk.block = block;
+	hmm_vma_walk.range = range;
+	mm_walk.private = &hmm_vma_walk;
+	hmm_vma_walk.last = range->start;
+
+	mm_walk.vma = vma;
+	mm_walk.mm = vma->vm_mm;
+	mm_walk.pte_entry = NULL;
+	mm_walk.test_walk = NULL;
+	mm_walk.hugetlb_entry = NULL;
+	mm_walk.pmd_entry = hmm_vma_walk_pmd;
+	mm_walk.pte_hole = hmm_vma_walk_hole;
+
+	do {
+		ret = walk_page_range(start, end, &mm_walk);
+		start = hmm_vma_walk.last;
+	} while (ret == -EAGAIN);
+
+	if (ret) {
+		unsigned long i;
+
+		i = (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
+		hmm_pfns_clear(&pfns[i], hmm_vma_walk.last, end);
+		hmm_vma_range_done(vma, range);
+	}
+	return ret;
+}
+EXPORT_SYMBOL(hmm_vma_fault);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
