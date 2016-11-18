Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71AD86B0441
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:17:55 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w132so34230867ita.1
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:17:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 87si6432081iom.203.2016.11.18.09.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 09:17:54 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v13 12/18] mm/hmm/mirror: helper to snapshot CPU page table
Date: Fri, 18 Nov 2016 13:18:21 -0500
Message-Id: <1479493107-982-13-git-send-email-jglisse@redhat.com>
In-Reply-To: <1479493107-982-1-git-send-email-jglisse@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

This does not use existing page table walker because we want to share
same code for our page fault handler.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h |  30 +++++++++-
 mm/hmm.c            | 163 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 191 insertions(+), 2 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 6571647..9e0f00d 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -95,13 +95,28 @@ struct hmm;
  *
  * Flags:
  * HMM_PFN_VALID: pfn is valid
+ * HMM_PFN_READ: read permission set
  * HMM_PFN_WRITE: CPU page table have the write permission set
+ * HMM_PFN_ERROR: corresponding CPU page table entry point to poisonous memory
+ * HMM_PFN_EMPTY: corresponding CPU page table entry is none (pte_none() true)
+ * HMM_PFN_DEVICE: this is device memory (ie a ZONE_DEVICE page)
+ * HMM_PFN_SPECIAL: corresponding CPU page table entry is special ie result of
+ *      vm_insert_pfn() or vm_insert_page() and thus should not be mirror by a
+ *      device (the entry will never have HMM_PFN_VALID set and the pfn value
+ *      is undefine)
+ * HMM_PFN_UNADDRESSABLE: unaddressable device memory (ZONE_DEVICE)
  */
 typedef unsigned long hmm_pfn_t;
 
 #define HMM_PFN_VALID (1 << 0)
-#define HMM_PFN_WRITE (1 << 1)
-#define HMM_PFN_SHIFT 2
+#define HMM_PFN_READ (1 << 1)
+#define HMM_PFN_WRITE (1 << 2)
+#define HMM_PFN_ERROR (1 << 3)
+#define HMM_PFN_EMPTY (1 << 4)
+#define HMM_PFN_DEVICE (1 << 5)
+#define HMM_PFN_SPECIAL (1 << 6)
+#define HMM_PFN_UNADDRESSABLE (1 << 7)
+#define HMM_PFN_SHIFT 8
 
 static inline struct page *hmm_pfn_to_page(hmm_pfn_t pfn)
 {
@@ -272,6 +287,17 @@ bool hmm_vma_range_monitor_start(struct hmm_range *range,
 bool hmm_vma_range_monitor_end(struct hmm_range *range);
 
 
+/*
+ * Snapshot CPU page table, the snapshot content validity can be track using
+ * hmm_range_monitor_start/end() or hmm_vma_range_lock()/hmm_vma_range_unlock()
+ * mechanism. See function description in mm/hmm.c for documentation.
+ */
+int hmm_vma_get_pfns(struct vm_area_struct *vma,
+		     unsigned long start,
+		     unsigned long end,
+		     hmm_pfn_t *pfns);
+
+
 /* Below are for HMM internal use only ! Not to be use by device driver ! */
 void hmm_mm_destroy(struct mm_struct *mm);
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 746eb96..f2ea76b 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -19,10 +19,15 @@
  */
 #include <linux/mm.h>
 #include <linux/hmm.h>
+#include <linux/rmap.h>
+#include <linux/swap.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <linux/swapops.h>
+#include <linux/hugetlb.h>
 #include <linux/mmu_notifier.h>
 
+
 /*
  * struct hmm - HMM per mm struct
  *
@@ -454,3 +459,161 @@ bool hmm_vma_range_monitor_end(struct hmm_range *range)
 	return valid;
 }
 EXPORT_SYMBOL(hmm_vma_range_monitor_end);
+
+
+static void hmm_pfns_empty(hmm_pfn_t *pfns,
+			   unsigned long addr,
+			   unsigned long end)
+{
+	for (; addr < end; addr += PAGE_SIZE, pfns++)
+		*pfns = HMM_PFN_EMPTY;
+}
+
+static void hmm_pfns_special(hmm_pfn_t *pfns,
+			     unsigned long addr,
+			     unsigned long end)
+{
+	for (; addr < end; addr += PAGE_SIZE, pfns++)
+		*pfns = HMM_PFN_SPECIAL;
+}
+
+static void hmm_vma_walk(struct vm_area_struct *vma,
+			 unsigned long start,
+			 unsigned long end,
+			 hmm_pfn_t *pfns)
+{
+	unsigned long addr, next;
+	hmm_pfn_t flag;
+
+	flag = vma->vm_flags & VM_READ ? HMM_PFN_READ : 0;
+
+	for (addr = start; addr < end; addr = next) {
+		unsigned long i = (addr - start) >> PAGE_SHIFT;
+		pgd_t *pgdp;
+		pud_t *pudp;
+		pmd_t *pmdp;
+		pte_t *ptep;
+		pmd_t pmd;
+
+		/*
+		 * We are accessing/faulting for a device from an unknown
+		 * thread that might be foreign to the mm we are faulting
+		 * against so do not call arch_vma_access_permitted() !
+		 */
+
+		next = pgd_addr_end(addr, end);
+		pgdp = pgd_offset(vma->vm_mm, addr);
+		if (pgd_none(*pgdp) || pgd_bad(*pgdp)) {
+			hmm_pfns_empty(&pfns[i], addr, next);
+			continue;
+		}
+
+		next = pud_addr_end(addr, end);
+		pudp = pud_offset(pgdp, addr);
+		if (pud_none(*pudp) || pud_bad(*pudp)) {
+			hmm_pfns_empty(&pfns[i], addr, next);
+			continue;
+		}
+
+		next = pmd_addr_end(addr, end);
+		pmdp = pmd_offset(pudp, addr);
+		pmd = pmd_read_atomic(pmdp);
+		barrier();
+		if (pmd_none(pmd) || pmd_bad(pmd)) {
+			hmm_pfns_empty(&pfns[i], addr, next);
+			continue;
+		}
+		if (pmd_trans_huge(pmd) || pmd_devmap(pmd)) {
+			unsigned long pfn = pmd_pfn(pmd) + pte_index(addr);
+			hmm_pfn_t flags = flag;
+
+			if (pmd_protnone(pmd)) {
+				hmm_pfns_clear(&pfns[i], addr, next);
+				continue;
+			}
+			flags |= pmd_write(*pmdp) ? HMM_PFN_WRITE : 0;
+			flags |= pmd_devmap(pmd) ? HMM_PFN_DEVICE : 0;
+			for (; addr < next; addr += PAGE_SIZE, i++, pfn++)
+				pfns[i] = hmm_pfn_from_pfn(pfn) | flags;
+			continue;
+		}
+
+		ptep = pte_offset_map(pmdp, addr);
+		for (; addr < next; addr += PAGE_SIZE, i++, ptep++) {
+			swp_entry_t entry;
+			pte_t pte = *ptep;
+
+			pfns[i] = 0;
+
+			if (pte_none(pte)) {
+				pfns[i] = HMM_PFN_EMPTY;
+				continue;
+			}
+
+			entry = pte_to_swp_entry(pte);
+			if (!pte_present(pte) && !non_swap_entry(entry)) {
+				continue;
+			}
+
+			if (pte_present(pte)) {
+				pfns[i] = hmm_pfn_from_pfn(pte_pfn(pte))|flag;
+				pfns[i] |= pte_write(pte) ? HMM_PFN_WRITE : 0;
+				continue;
+			}
+
+			/*
+			 * This is a special swap entry, ignore migration, use
+			 * device and report anything else as error.
+			*/
+			if (is_device_entry(entry)) {
+				pfns[i] = hmm_pfn_from_pfn(swp_offset(entry));
+				if (is_write_device_entry(entry))
+					pfns[i] |= HMM_PFN_WRITE;
+				pfns[i] |= HMM_PFN_DEVICE;
+				pfns[i] |= HMM_PFN_UNADDRESSABLE;
+				pfns[i] |= flag;
+			} else if (!is_migration_entry(entry)) {
+				pfns[i] = HMM_PFN_ERROR;
+			}
+		}
+		pte_unmap(ptep - 1);
+	}
+}
+
+/*
+ * hmm_vma_get_pfns() - snapshot CPU page table for a range of virtual address
+ * @vma: virtual memory area containing the virtual address range
+ * @start: range virtual start address (inclusive)
+ * @end: range virtual end address (exclusive)
+ * @entries: array of hmm_pfn_t provided by caller fill by function
+ * Returns: -EINVAL if invalid argument, 0 otherwise
+ *
+ * This snapshot the CPU page table for a range of virtual address, snapshot is
+ * only valid while protected by hmm_vma_range_lock() or if return cookie value
+ * is still valid (see hmm_vma_check_cookie()).
+ *
+ * It will fill the pfns array using CPU pte. Note that any invalid CPU page
+ * table entry, at time of snapshot, can turn into a valid one after this
+ * function return but before calling hmm_vma_range_unlock().
+ */
+int hmm_vma_get_pfns(struct vm_area_struct *vma,
+		     unsigned long start,
+		     unsigned long end,
+		     hmm_pfn_t *pfns)
+{
+	/* FIXME support hugetlb fs */
+	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
+		hmm_pfns_special(pfns, start, end);
+		return -EINVAL;
+	}
+
+	/* Sanity check, this really should not happen ! */
+	if (start < vma->vm_start || start >= vma->vm_end)
+		return -EINVAL;
+	if (end < vma->vm_start || end > vma->vm_end)
+		return -EINVAL;
+
+	hmm_vma_walk(vma, start, end, pfns);
+	return 0;
+}
+EXPORT_SYMBOL(hmm_vma_get_pfns);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
