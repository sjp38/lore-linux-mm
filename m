Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B98E6B026C
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 10:39:38 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id i34so346910720qkh.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 07:39:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j3si7501519qkf.13.2016.12.08.07.39.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 07:39:37 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v14 10/16] mm/hmm/mirror: device page fault handler
Date: Thu,  8 Dec 2016 11:39:38 -0500
Message-Id: <1481215184-18551-11-git-send-email-jglisse@redhat.com>
In-Reply-To: <1481215184-18551-1-git-send-email-jglisse@redhat.com>
References: <1481215184-18551-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

This handle page fault on behalf of device driver, unlike handle_mm_fault()
it does not trigger migration back to system memory for device memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h |  26 +++++
 mm/hmm.c            | 269 ++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 267 insertions(+), 28 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index b5eafdc..f19c2a0 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -288,6 +288,32 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 		     unsigned long end,
 		     hmm_pfn_t *pfns);
 bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range);
+
+
+/*
+ * Fault memory on behalf of device driver unlike handle_mm_fault() it will not
+ * migrate any device memory back to system memory. The hmm_pfn_t array will be
+ * updated with fault result and current snapshot of the CPU page table for the
+ * range.
+ *
+ * The mmap_sem must be taken in read mode before entering and it might be drop
+ * by the function if block argument is false, when that happen the function
+ * returns -EAGAIN.
+ *
+ * Return value does not reflect if the fault was successfull for every single
+ * address or not, you need to inspect the hmm_pfn_t array to determine fault
+ * status for that address. Trying to fault inside an invalid vma will result
+ * in -EINVAL.
+ *
+ * See function description in mm/hmm.c for documentation.
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
index 0ef06df..a397d45 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -288,6 +288,15 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror)
 }
 EXPORT_SYMBOL(hmm_mirror_unregister);
 
+
+static void hmm_pfns_error(hmm_pfn_t *pfns,
+			   unsigned long addr,
+			   unsigned long end)
+{
+	for (; addr < end; addr += PAGE_SIZE, pfns++)
+		*pfns = HMM_PFN_ERROR;
+}
+
 static void hmm_pfns_empty(hmm_pfn_t *pfns,
 			   unsigned long addr,
 			   unsigned long end)
@@ -304,10 +313,43 @@ static void hmm_pfns_special(hmm_pfn_t *pfns,
 		*pfns = HMM_PFN_SPECIAL;
 }
 
-static void hmm_vma_walk(struct vm_area_struct *vma,
-			 unsigned long start,
-			 unsigned long end,
-			 hmm_pfn_t *pfns)
+static void hmm_pfns_clear(hmm_pfn_t *pfns,
+			   unsigned long addr,
+			   unsigned long end)
+{
+	unsigned long npfns = (end - addr) >> PAGE_SHIFT;
+
+	memset(pfns, 0, sizeof(*pfns) * npfns);
+}
+
+static int hmm_vma_do_fault(struct vm_area_struct *vma,
+			    const hmm_pfn_t fault,
+			    unsigned long addr,
+			    hmm_pfn_t *pfn,
+			    bool block)
+{
+	unsigned flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
+	int r;
+
+	flags |= block ? 0 : FAULT_FLAG_ALLOW_RETRY;
+	flags |= (fault & HMM_PFN_WRITE) ? FAULT_FLAG_WRITE : 0;
+	r = handle_mm_fault(vma, addr, flags);
+	if (r & VM_FAULT_RETRY)
+		return -EAGAIN;
+	if (r & VM_FAULT_ERROR) {
+		*pfn = HMM_PFN_ERROR;
+		return -EFAULT;
+	}
+
+	return 0;
+}
+
+static int hmm_vma_walk(struct vm_area_struct *vma,
+			const hmm_pfn_t fault,
+			unsigned long start,
+			unsigned long end,
+			hmm_pfn_t *pfns,
+			bool block)
 {
 	unsigned long addr, next;
 	hmm_pfn_t flag;
@@ -321,6 +363,7 @@ static void hmm_vma_walk(struct vm_area_struct *vma,
 		pmd_t *pmdp;
 		pte_t *ptep;
 		pmd_t pmd;
+		int ret;
 
 		/*
 		 * We are accessing/faulting for a device from an unknown
@@ -331,15 +374,37 @@ static void hmm_vma_walk(struct vm_area_struct *vma,
 		next = pgd_addr_end(addr, end);
 		pgdp = pgd_offset(vma->vm_mm, addr);
 		if (pgd_none(*pgdp) || pgd_bad(*pgdp)) {
-			hmm_pfns_empty(&pfns[i], addr, next);
-			continue;
+			if (!(vma->vm_flags & VM_READ)) {
+				hmm_pfns_empty(&pfns[i], addr, next);
+				continue;
+			}
+			if (!fault) {
+				hmm_pfns_empty(&pfns[i], addr, next);
+				continue;
+			}
+			pudp = pud_alloc(vma->vm_mm, pgdp, addr);
+			if (!pudp) {
+				hmm_pfns_error(&pfns[i], addr, next);
+				continue;
+			}
 		}
 
 		next = pud_addr_end(addr, end);
 		pudp = pud_offset(pgdp, addr);
 		if (pud_none(*pudp) || pud_bad(*pudp)) {
-			hmm_pfns_empty(&pfns[i], addr, next);
-			continue;
+			if (!(vma->vm_flags & VM_READ)) {
+				hmm_pfns_empty(&pfns[i], addr, next);
+				continue;
+			}
+			if (!fault) {
+				hmm_pfns_empty(&pfns[i], addr, next);
+				continue;
+			}
+			pmdp = pmd_alloc(vma->vm_mm, pudp, addr);
+			if (!pmdp) {
+				hmm_pfns_error(&pfns[i], addr, next);
+				continue;
+			}
 		}
 
 		next = pmd_addr_end(addr, end);
@@ -347,8 +412,24 @@ static void hmm_vma_walk(struct vm_area_struct *vma,
 		pmd = pmd_read_atomic(pmdp);
 		barrier();
 		if (pmd_none(pmd) || pmd_bad(pmd)) {
-			hmm_pfns_empty(&pfns[i], addr, next);
-			continue;
+			if (!(vma->vm_flags & VM_READ)) {
+				hmm_pfns_empty(&pfns[i], addr, next);
+				continue;
+			}
+			if (!fault) {
+				hmm_pfns_empty(&pfns[i], addr, next);
+				continue;
+			}
+			/*
+			 * Use pte_alloc() instead of pte_alloc_map, because we
+			 * can't run pte_offset_map on the pmd, if an huge pmd
+			 * could materialize from under us.
+			 */
+			if (unlikely(pte_alloc(vma->vm_mm, pmdp, addr))) {
+				hmm_pfns_error(&pfns[i], addr, next);
+				continue;
+			}
+			pmd = *pmdp;
 		}
 		if (pmd_trans_huge(pmd) || pmd_devmap(pmd)) {
 			unsigned long pfn = pmd_pfn(pmd) + pte_index(addr);
@@ -356,10 +437,14 @@ static void hmm_vma_walk(struct vm_area_struct *vma,
 
 			if (pmd_protnone(pmd)) {
 				hmm_pfns_clear(&pfns[i], addr, next);
+				if (fault)
+					goto fault;
 				continue;
 			}
 			flags |= pmd_write(*pmdp) ? HMM_PFN_WRITE : 0;
 			flags |= pmd_devmap(pmd) ? HMM_PFN_DEVICE : 0;
+			if ((flags & fault) != fault)
+				goto fault;
 			for (; addr < next; addr += PAGE_SIZE, i++, pfn++)
 				pfns[i] = hmm_pfn_from_pfn(pfn) | flags;
 			continue;
@@ -370,41 +455,63 @@ static void hmm_vma_walk(struct vm_area_struct *vma,
 			swp_entry_t entry;
 			pte_t pte = *ptep;
 
-			pfns[i] = 0;
-
 			if (pte_none(pte)) {
+				if (fault) {
+					pte_unmap(ptep);
+					goto fault;
+				}
 				pfns[i] = HMM_PFN_EMPTY;
 				continue;
 			}
 
 			entry = pte_to_swp_entry(pte);
 			if (!pte_present(pte) && !non_swap_entry(entry)) {
+				if (fault) {
+					pte_unmap(ptep);
+					goto fault;
+				}
+				pfns[i] = 0;
 				continue;
 			}
 
 			if (pte_present(pte)) {
 				pfns[i] = hmm_pfn_from_pfn(pte_pfn(pte))|flag;
 				pfns[i] |= pte_write(pte) ? HMM_PFN_WRITE : 0;
-				continue;
-			}
-
-			/*
-			 * This is a special swap entry, ignore migration, use
-			 * device and report anything else as error.
-			*/
-			if (is_device_entry(entry)) {
+			} else if (is_device_entry(entry)) {
+				/* Do not fault device entry */
 				pfns[i] = hmm_pfn_from_pfn(swp_offset(entry));
 				if (is_write_device_entry(entry))
 					pfns[i] |= HMM_PFN_WRITE;
 				pfns[i] |= HMM_PFN_DEVICE;
 				pfns[i] |= HMM_PFN_UNADDRESSABLE;
 				pfns[i] |= flag;
-			} else if (!is_migration_entry(entry)) {
+			} else if (is_migration_entry(entry) && fault) {
+				migration_entry_wait(vma->vm_mm, pmdp, addr);
+				/* Start again for current address */
+				next = addr;
+				ptep++;
+				break;
+			} else {
+				/* Report error for everything else */
 				pfns[i] = HMM_PFN_ERROR;
 			}
+			if ((fault & pfns[i]) != fault) {
+				pte_unmap(ptep);
+				goto fault;
+			}
 		}
 		pte_unmap(ptep - 1);
+		continue;
+
+fault:
+		ret = hmm_vma_do_fault(vma, fault, addr, &pfns[i], block);
+		if (ret)
+			return ret;
+		/* Start again for current address */
+		next = addr;
 	}
+
+	return 0;
 }
 
 /*
@@ -463,7 +570,7 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 	list_add_rcu(&range->list, &hmm->ranges);
 	spin_unlock(&hmm->lock);
 
-	hmm_vma_walk(vma, start, end, pfns);
+	hmm_vma_walk(vma, 0, start, end, pfns, false);
 	return 0;
 }
 EXPORT_SYMBOL(hmm_vma_get_pfns);
@@ -474,14 +581,22 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
  * @range: range being track
  * Returns: false if range data have been invalidated, true otherwise
  *
- * Range struct is use to track update to CPU page table after call to
- * hmm_vma_get_pfns(). Once device driver is done using or want to lock update
- * to data it gots from this function it calls hmm_vma_range_done() which stop
- * the tracking.
+ * Range struct is use to track update to CPU page table after call to either
+ * hmm_vma_get_pfns() or hmm_vma_fault(). Once device driver is done using or
+ * want to lock update to data it gots from those functions it must call the
+ * hmm_vma_range_done() function which stop tracking CPU page table update.
+ *
+ * Note that device driver must still implement general CPU page table update
+ * tracking either by using hmm_mirror (see hmm_mirror_register()) or by using
+ * mmu_notifier API directly.
+ *
+ * CPU page table update tracking done through hmm_range is only temporary and
+ * to be use while trying to duplicate CPU page table content for a range of
+ * virtual address.
  *
  * There is 2 way to use this :
  * again:
- *   hmm_vma_get_pfns(vma, range, start, end, pfns);
+ *   hmm_vma_get_pfns(vma, range, start, end, pfns); or hmm_vma_fault(...);
  *   trans = device_build_page_table_update_transaction(pfns);
  *   device_page_table_lock();
  *   if (!hmm_vma_range_done(vma, range)) {
@@ -492,7 +607,7 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
  *   device_page_table_unlock();
  *
  * Or:
- *   hmm_vma_get_pfns(vma, range, start, end, pfns);
+ *   hmm_vma_get_pfns(vma, range, start, end, pfns); or hmm_vma_fault(...);
  *   device_page_table_lock();
  *   hmm_vma_range_done(vma, range);
  *   device_update_page_table(pfns);
@@ -521,4 +636,102 @@ bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range)
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
+ * YOU HAVE BEEN WARN !
+ */
+int hmm_vma_fault(struct vm_area_struct *vma,
+		  struct hmm_range *range,
+		  unsigned long start,
+		  unsigned long end,
+		  hmm_pfn_t *pfns,
+		  bool write,
+		  bool block)
+{
+	hmm_pfn_t fault = HMM_PFN_READ | (write ? HMM_PFN_WRITE : 0);
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
+	/* Caller must have register a mirror (with hmm_mirror_register()) ! */
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
+	ret = hmm_vma_walk(vma, fault, start, end, pfns, block);
+	if (ret)
+		hmm_vma_range_done(vma, range);
+	return ret;
+}
+EXPORT_SYMBOL(hmm_vma_fault);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
