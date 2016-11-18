Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B339C6B0442
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:17:56 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b123so2028567itb.3
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:17:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k93si6411164iod.245.2016.11.18.09.17.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 09:17:55 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v13 13/18] mm/hmm/mirror: device page fault handler
Date: Fri, 18 Nov 2016 13:18:22 -0500
Message-Id: <1479493107-982-14-git-send-email-jglisse@redhat.com>
In-Reply-To: <1479493107-982-1-git-send-email-jglisse@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

This handle page fault on behalf of device driver, unlike handle_mm_fault()
it does not trigger migration back to system memory for device memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h |  33 ++++++-
 mm/hmm.c            | 262 +++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 267 insertions(+), 28 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 9e0f00d..c79abfc 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -99,6 +99,7 @@ struct hmm;
  * HMM_PFN_WRITE: CPU page table have the write permission set
  * HMM_PFN_ERROR: corresponding CPU page table entry point to poisonous memory
  * HMM_PFN_EMPTY: corresponding CPU page table entry is none (pte_none() true)
+ * HMM_PFN_FAULT: use by hmm_vma_fault() to signify which address need faulting
  * HMM_PFN_DEVICE: this is device memory (ie a ZONE_DEVICE page)
  * HMM_PFN_SPECIAL: corresponding CPU page table entry is special ie result of
  *      vm_insert_pfn() or vm_insert_page() and thus should not be mirror by a
@@ -113,10 +114,11 @@ typedef unsigned long hmm_pfn_t;
 #define HMM_PFN_WRITE (1 << 2)
 #define HMM_PFN_ERROR (1 << 3)
 #define HMM_PFN_EMPTY (1 << 4)
-#define HMM_PFN_DEVICE (1 << 5)
-#define HMM_PFN_SPECIAL (1 << 6)
-#define HMM_PFN_UNADDRESSABLE (1 << 7)
-#define HMM_PFN_SHIFT 8
+#define HMM_PFN_FAULT (1 << 5)
+#define HMM_PFN_DEVICE (1 << 6)
+#define HMM_PFN_SPECIAL (1 << 7)
+#define HMM_PFN_UNADDRESSABLE (1 << 8)
+#define HMM_PFN_SHIFT 9
 
 static inline struct page *hmm_pfn_to_page(hmm_pfn_t pfn)
 {
@@ -298,6 +300,29 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 		     hmm_pfn_t *pfns);
 
 
+/*
+ * Fault memory on behalf of device driver unlike handle_mm_fault() it will not
+ * migrate any device memory back to system memory. The hmm_pfn_t array will be
+ * updated with fault result and current snapshot of the CPU page table for the
+ * range. Note that you must use hmm_range_monitor_start/end() to ascertain if
+ * you could use those.
+ *
+ * DO NOT USE hmm_vma_range_lock()/hmm_vma_range_unlock() IT WILL DEADLOCK !
+ *
+ * The mmap_sem must be taken in read mode before entering and it might be drop
+ * by the function if that happen the function return false. Otherwise, if the
+ * mmap_sem is still held it return true. The return value does not reflect if
+ * the fault was successfull or not, you need to inspect the hmm_pfn_t array to
+ * determine fault status.
+ *
+ * See function description in mm/hmm.c for documentation.
+ */
+bool hmm_vma_fault(struct vm_area_struct *vma,
+		   unsigned long start,
+		   unsigned long end,
+		   hmm_pfn_t *pfns);
+
+
 /* Below are for HMM internal use only ! Not to be use by device driver ! */
 void hmm_mm_destroy(struct mm_struct *mm);
 
diff --git a/mm/hmm.c b/mm/hmm.c
index f2ea76b..521adfd 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -461,6 +461,14 @@ bool hmm_vma_range_monitor_end(struct hmm_range *range)
 EXPORT_SYMBOL(hmm_vma_range_monitor_end);
 
 
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
@@ -477,10 +485,47 @@ static void hmm_pfns_special(hmm_pfn_t *pfns,
 		*pfns = HMM_PFN_SPECIAL;
 }
 
-static void hmm_vma_walk(struct vm_area_struct *vma,
+static void hmm_pfns_clear(hmm_pfn_t *pfns,
+			   unsigned long addr,
+			   unsigned long end)
+{
+	unsigned long npfns = (end - addr) >> PAGE_SHIFT;
+
+	memset(pfns, 0, sizeof(*pfns) * npfns);
+}
+
+static bool hmm_pfns_fault(hmm_pfn_t *pfns,
+			   unsigned long addr,
+			   unsigned long end)
+{
+	for (; addr < end; addr += PAGE_SIZE, pfns++)
+		if (*pfns & HMM_PFN_FAULT)
+			return true;
+	return false;
+}
+
+static bool hmm_vma_do_fault(struct vm_area_struct *vma,
+			     unsigned long addr,
+			     hmm_pfn_t *pfn)
+{
+	unsigned flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
+	int r;
+
+	flags |= (*pfn & HMM_PFN_WRITE) ? FAULT_FLAG_WRITE : 0;
+	r = handle_mm_fault(vma, addr, flags);
+	if (r & VM_FAULT_RETRY)
+		return false;
+	if (r & VM_FAULT_ERROR)
+		*pfn = HMM_PFN_ERROR;
+
+	return true;
+}
+
+static bool hmm_vma_walk(struct vm_area_struct *vma,
 			 unsigned long start,
 			 unsigned long end,
-			 hmm_pfn_t *pfns)
+			 hmm_pfn_t *pfns,
+			 bool fault)
 {
 	unsigned long addr, next;
 	hmm_pfn_t flag;
@@ -489,6 +534,7 @@ static void hmm_vma_walk(struct vm_area_struct *vma,
 
 	for (addr = start; addr < end; addr = next) {
 		unsigned long i = (addr - start) >> PAGE_SHIFT;
+		bool writefault = false;
 		pgd_t *pgdp;
 		pud_t *pudp;
 		pmd_t *pmdp;
@@ -504,15 +550,37 @@ static void hmm_vma_walk(struct vm_area_struct *vma,
 		next = pgd_addr_end(addr, end);
 		pgdp = pgd_offset(vma->vm_mm, addr);
 		if (pgd_none(*pgdp) || pgd_bad(*pgdp)) {
-			hmm_pfns_empty(&pfns[i], addr, next);
-			continue;
+			if (!(vma->vm_flags & VM_READ)) {
+				hmm_pfns_empty(&pfns[i], addr, next);
+				continue;
+			}
+			if (!fault || !hmm_pfns_fault(&pfns[i], addr, next)) {
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
+			if (!fault || !hmm_pfns_fault(&pfns[i], addr, next)) {
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
@@ -520,8 +588,23 @@ static void hmm_vma_walk(struct vm_area_struct *vma,
 		pmd = pmd_read_atomic(pmdp);
 		barrier();
 		if (pmd_none(pmd) || pmd_bad(pmd)) {
-			hmm_pfns_empty(&pfns[i], addr, next);
-			continue;
+			if (!(vma->vm_flags & VM_READ)) {
+				hmm_pfns_empty(&pfns[i], addr, next);
+				continue;
+			}
+			if (!fault || !hmm_pfns_fault(&pfns[i], addr, next)) {
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
 		}
 		if (pmd_trans_huge(pmd) || pmd_devmap(pmd)) {
 			unsigned long pfn = pmd_pfn(pmd) + pte_index(addr);
@@ -529,12 +612,33 @@ static void hmm_vma_walk(struct vm_area_struct *vma,
 
 			if (pmd_protnone(pmd)) {
 				hmm_pfns_clear(&pfns[i], addr, next);
+				if (!fault || !(vma->vm_flags & VM_READ))
+					continue;
+				if (!hmm_pfns_fault(&pfns[i], addr, next))
+					continue;
+
+				if (!hmm_vma_do_fault(vma, addr, &pfns[i]))
+					return false;
+				/* Start again for current address */
+				next = addr;
 				continue;
 			}
 			flags |= pmd_write(*pmdp) ? HMM_PFN_WRITE : 0;
 			flags |= pmd_devmap(pmd) ? HMM_PFN_DEVICE : 0;
-			for (; addr < next; addr += PAGE_SIZE, i++, pfn++)
+			for (; addr < next; addr += PAGE_SIZE, i++, pfn++) {
+				bool fault = pfns[i] & HMM_PFN_FAULT;
+				bool write = pfns[i] & HMM_PFN_WRITE;
+
 				pfns[i] = hmm_pfn_from_pfn(pfn) | flags;
+				if (!fault || !write || flags & HMM_PFN_WRITE)
+					continue;
+				pfns[i] = HMM_PFN_FAULT | HMM_PFN_WRITE;
+				if (!hmm_vma_do_fault(vma, addr, &pfns[i]))
+					return false;
+				/* Start again for current address */
+				next = addr;
+				break;
+			}
 			continue;
 		}
 
@@ -543,41 +647,91 @@ static void hmm_vma_walk(struct vm_area_struct *vma,
 			swp_entry_t entry;
 			pte_t pte = *ptep;
 
-			pfns[i] = 0;
-
 			if (pte_none(pte)) {
-				pfns[i] = HMM_PFN_EMPTY;
-				continue;
+				if (!fault || !(pfns[i] & HMM_PFN_FAULT)) {
+					pfns[i] = HMM_PFN_EMPTY;
+					continue;
+				}
+				if (!(vma->vm_flags & VM_READ)) {
+					pfns[i] = HMM_PFN_EMPTY;
+					continue;
+				}
+				if (!hmm_vma_do_fault(vma, addr, &pfns[i])) {
+					hmm_pfns_clear(&pfns[i], addr, end);
+					pte_unmap(ptep);
+					return false;
+				}
+				pte = *ptep;
 			}
 
 			entry = pte_to_swp_entry(pte);
 			if (!pte_present(pte) && !non_swap_entry(entry)) {
-				continue;
+				if (!fault || !(pfns[i] & HMM_PFN_FAULT)) {
+					pfns[i] = 0;
+					continue;
+				}
+				if (!(vma->vm_flags & VM_READ)) {
+					pfns[i] = 0;
+					continue;
+				}
+				if (!hmm_vma_do_fault(vma, addr, &pfns[i])) {
+					hmm_pfns_clear(&pfns[i], addr, end);
+					pte_unmap(ptep);
+					return false;
+				}
+				pte = *ptep;
 			}
 
+			writefault = (pfns[i]&(HMM_PFN_WRITE|HMM_PFN_FAULT)) ==
+				     (HMM_PFN_WRITE|HMM_PFN_FAULT) && fault;
+
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
+			if (!(vma->vm_flags & VM_READ) ||
+			    !(vma->vm_flags & VM_WRITE)) {
+				writefault = false;
+				continue;
+			}
+
+			if (writefault && !(pfns[i] & HMM_PFN_WRITE)) {
+				ptep++;
+				break;
+			}
+			writefault = false;
 		}
 		pte_unmap(ptep - 1);
+
+		if (writefault && (vma->vm_flags & VM_WRITE)) {
+			pfns[i] = HMM_PFN_WRITE | HMM_PFN_FAULT;
+			if (!hmm_vma_do_fault(vma, addr, &pfns[i])) {
+				return false;
+			}
+			writefault = false;
+			/* Start again for current address */
+			next = addr;
+		}
 	}
+
+	return true;
 }
 
 /*
@@ -613,7 +767,67 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 	if (end < vma->vm_start || end > vma->vm_end)
 		return -EINVAL;
 
-	hmm_vma_walk(vma, start, end, pfns);
+	hmm_vma_walk(vma, start, end, pfns, false);
 	return 0;
 }
 EXPORT_SYMBOL(hmm_vma_get_pfns);
+
+
+/*
+ * hmm_vma_fault() - try to fault some address in a virtual address range
+ * @vma: virtual memory area containing the virtual address range
+ * @start: fault range virtual start address (inclusive)
+ * @end: fault range virtual end address (exclusive)
+ * @pfns: array of hmm_pfn_t, only entry with fault flag set will be faulted
+ * Returns: true mmap_sem is still held, false mmap_sem have been release
+ *
+ * This is similar to a regular CPU page fault except that it will not trigger
+ * any memory migration if the memory being faulted is not accessible by CPUs.
+ *
+ * Only pfn with fault flag set will be faulted and the hmm_pfn_t write flag
+ * will be use to determine if it is a write fault or not.
+ *
+ * On error, for one virtual address in the range, the function will set the
+ * hmm_pfn_t error flag for the corresponding pfn entry.
+ *
+ * Expected use pattern:
+ *   retry:
+ *      down_read(&mm->mmap_sem);
+ *      // Find vma and address device wants to fault, initialize hmm_pfn_t
+ *      // array accordingly
+ *      hmm_vma_range_monitor_start(range, vma, start, end);
+ *      if (!hmm_vma_fault(vma, start, end, pfns, allow_retry)) {
+ *          hmm_vma_range_monitor_end(range);
+ *          // You might want to rate limit or yield to play nicely, you may
+ *          // also commit any valid pfn in the array assuming that you are
+ *          // getting true from hmm_vma_range_monitor_end()
+ *          goto retry;
+ *      }
+ *      // Take device driver lock that serialize device page table update
+ *      driver_lock_device_page_table_update();
+ *      if (hmm_vma_range_monitor_end(range)) {
+ *          // Commit pfns we got from hmm_vma_fault()
+ *      }
+ *      driver_unlock_device_page_table_update();
+ *      up_read(&mm->mmap_sem)
+ */
+bool hmm_vma_fault(struct vm_area_struct *vma,
+		   unsigned long start,
+		   unsigned long end,
+		   hmm_pfn_t *pfns)
+{
+	/* FIXME support hugetlb fs */
+	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
+		hmm_pfns_special(pfns, start, end);
+		return true;
+	}
+
+	/* Sanity check, this really should not happen ! */
+	if (start < vma->vm_start || start >= vma->vm_end)
+		return true;
+	if (end < vma->vm_start || end > vma->vm_end)
+		return true;
+
+	return hmm_vma_walk(vma, start, end, pfns, true);
+}
+EXPORT_SYMBOL(hmm_vma_fault);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
