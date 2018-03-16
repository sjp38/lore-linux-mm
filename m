Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E45C6B0275
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 16:36:00 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id z1so7424797qtz.12
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 13:36:00 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h36si1959109qtd.224.2018.03.16.13.35.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 13:35:59 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 14/14] mm/hmm: use device driver encoding for HMM pfn
Date: Fri, 16 Mar 2018 16:35:52 -0400
Message-Id: <20180316203552.4155-5-jglisse@redhat.com>
In-Reply-To: <20180316203552.4155-1-jglisse@redhat.com>
References: <20180316203552.4155-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

User of hmm_vma_fault() and hmm_vma_get_pfns() provide a flags array
and pfn shift value allowing them to define their own encoding for HMM
pfn that are fill inside the pfns array of the hmm_range struct. With
this device driver can get pfn that match their own private encoding
out of HMM without having to do any convertion.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h | 91 ++++++++++++++++++++++++++++++++---------------------
 mm/hmm.c            | 83 +++++++++++++++++++++++++++---------------------
 2 files changed, 102 insertions(+), 72 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index ee758c4e4bec..cb9af99f9371 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -80,68 +80,106 @@
 struct hmm;
 
 /*
+ * hmm_pfn_flag_e - HMM uses its own pfn type to keep several flags per page
+ *
  * Flags:
  * HMM_PFN_VALID: pfn is valid
  * HMM_PFN_WRITE: CPU page table has write permission set
  * HMM_PFN_ERROR: corresponding CPU page table entry points to poisoned memory
+ * HMM_PFN_EMPTY: corresponding CPU page table entry is pte_none()
  * HMM_PFN_SPECIAL: corresponding CPU page table entry is special; i.e., the
  *      result of vm_insert_pfn() or vm_insert_page(). Therefore, it should not
  *      be mirrored by a device, because the entry will never have HMM_PFN_VALID
  *      set and the pfn value is undefined.
- * HMM_PFN_DEVICE_PRIVATE: unaddressable device memory (ZONE_DEVICE)
+ * HMM_PFN_DEVICE_PRIVATE: private device memory (ZONE_DEVICE)
+ */
+enum hmm_pfn_flag_e {
+	HMM_PFN_VALID = 0,
+	HMM_PFN_WRITE,
+	HMM_PFN_ERROR,
+	HMM_PFN_NONE,
+	HMM_PFN_SPECIAL,
+	HMM_PFN_DEVICE_PRIVATE,
+	HMM_PFN_FLAG_MAX
+};
+
+/*
+ * struct hmm_range - track invalidation lock on virtual address range
+ *
+ * @vma: the vm area struct for the range
+ * @list: all range lock are on a list
+ * @start: range virtual start address (inclusive)
+ * @end: range virtual end address (exclusive)
+ * @pfns: array of pfns (big enough for the range)
+ * @flags: pfn flags to match device driver page table
+ * @pfn_shifts: pfn shift value (should be <= PAGE_SHIFT)
+ * @valid: pfns array did not change since it has been fill by an HMM function
  */
-#define HMM_PFN_VALID (1 << 0)
-#define HMM_PFN_WRITE (1 << 1)
-#define HMM_PFN_ERROR (1 << 2)
-#define HMM_PFN_SPECIAL (1 << 3)
-#define HMM_PFN_DEVICE_PRIVATE (1 << 4)
-#define HMM_PFN_SHIFT 5
+struct hmm_range {
+	struct vm_area_struct	*vma;
+	struct list_head	list;
+	unsigned long		start;
+	unsigned long		end;
+	uint64_t		*pfns;
+	const uint64_t		*flags;
+	uint8_t			pfn_shift;
+	bool			valid;
+};
 
 /*
  * hmm_pfn_to_page() - return struct page pointed to by a valid HMM pfn
+ * @range: range use to decode HMM pfn value
  * @pfn: HMM pfn value to get corresponding struct page from
  * Returns: struct page pointer if pfn is a valid HMM pfn, NULL otherwise
  *
  * If the uint64_t is valid (ie valid flag set) then return the struct page
  * matching the pfn value stored in the HMM pfn. Otherwise return NULL.
  */
-static inline struct page *hmm_pfn_to_page(uint64_t pfn)
+static inline struct page *hmm_pfn_to_page(const struct hmm_range *range,
+					   uint64_t pfn)
 {
-	if (!(pfn & HMM_PFN_VALID))
+	if (!(pfn & range->flags[HMM_PFN_VALID]))
 		return NULL;
-	return pfn_to_page(pfn >> HMM_PFN_SHIFT);
+	return pfn_to_page(pfn >> range->pfn_shift);
 }
 
 /*
  * hmm_pfn_to_pfn() - return pfn value store in a HMM pfn
+ * @range: range use to decode HMM pfn value
  * @pfn: HMM pfn value to extract pfn from
  * Returns: pfn value if HMM pfn is valid, -1UL otherwise
  */
-static inline unsigned long hmm_pfn_to_pfn(uint64_t pfn)
+static inline unsigned long hmm_pfn_to_pfn(const struct hmm_range *range,
+					   uint64_t pfn)
 {
-	if (!(pfn & HMM_PFN_VALID))
+	if (!(pfn & range->flags[HMM_PFN_VALID]))
 		return -1UL;
-	return (pfn >> HMM_PFN_SHIFT);
+	return (pfn >> range->pfn_shift);
 }
 
 /*
  * hmm_pfn_from_page() - create a valid HMM pfn value from struct page
+ * @range: range use to encode HMM pfn value
  * @page: struct page pointer for which to create the HMM pfn
  * Returns: valid HMM pfn for the page
  */
-static inline uint64_t hmm_pfn_from_page(struct page *page)
+static inline uint64_t hmm_pfn_from_page(const struct hmm_range *range,
+					 struct page *page)
 {
-	return (page_to_pfn(page) << HMM_PFN_SHIFT) | HMM_PFN_VALID;
+	return (page_to_pfn(page) << range->pfn_shift) |
+		range->flags[HMM_PFN_VALID];
 }
 
 /*
  * hmm_pfn_from_pfn() - create a valid HMM pfn value from pfn
+ * @range: range use to encode HMM pfn value
  * @pfn: pfn value for which to create the HMM pfn
  * Returns: valid HMM pfn for the pfn
  */
-static inline uint64_t hmm_pfn_from_pfn(unsigned long pfn)
+static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
+					unsigned long pfn)
 {
-	return (pfn << HMM_PFN_SHIFT) | HMM_PFN_VALID;
+	return (pfn << range->pfn_shift) | range->flags[HMM_PFN_VALID];
 }
 
 
@@ -263,25 +301,6 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
 void hmm_mirror_unregister(struct hmm_mirror *mirror);
 
 
-/*
- * struct hmm_range - track invalidation lock on virtual address range
- *
- * @vma: the vm area struct for the range
- * @list: all range lock are on a list
- * @start: range virtual start address (inclusive)
- * @end: range virtual end address (exclusive)
- * @pfns: array of pfns (big enough for the range)
- * @valid: pfns array did not change since it has been fill by an HMM function
- */
-struct hmm_range {
-	struct vm_area_struct	*vma;
-	struct list_head	list;
-	unsigned long		start;
-	unsigned long		end;
-	uint64_t		*pfns;
-	bool			valid;
-};
-
 /*
  * To snapshot the CPU page table, call hmm_vma_get_pfns(), then take a device
  * driver lock that serializes device page table updates, then call
diff --git a/mm/hmm.c b/mm/hmm.c
index 0ea530d0fd1d..7ccca5478ea1 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -263,6 +263,7 @@ static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
 {
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
 	struct vm_area_struct *vma = walk->vma;
 	int r;
 
@@ -272,7 +273,7 @@ static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
 	if (r & VM_FAULT_RETRY)
 		return -EBUSY;
 	if (r & VM_FAULT_ERROR) {
-		*pfn = HMM_PFN_ERROR;
+		*pfn = range->flags[HMM_PFN_ERROR];
 		return -EFAULT;
 	}
 
@@ -290,7 +291,7 @@ static int hmm_pfns_bad(unsigned long addr,
 
 	i = (addr - range->start) >> PAGE_SHIFT;
 	for (; addr < end; addr += PAGE_SIZE, i++)
-		pfns[i] = HMM_PFN_ERROR;
+		pfns[i] = range->flags[HMM_PFN_ERROR];
 
 	return 0;
 }
@@ -319,7 +320,7 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
 	hmm_vma_walk->last = addr;
 	i = (addr - range->start) >> PAGE_SHIFT;
 	for (; addr < end; addr += PAGE_SIZE, i++) {
-		pfns[i] = 0;
+		pfns[i] = range->flags[HMM_PFN_NONE];
 		if (fault || write_fault) {
 			int ret;
 
@@ -337,24 +338,27 @@ static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
 				      uint64_t pfns, uint64_t cpu_flags,
 				      bool *fault, bool *write_fault)
 {
+	struct hmm_range *range = hmm_vma_walk->range;
+
 	*fault = *write_fault = false;
 	if (!hmm_vma_walk->fault)
 		return;
 
 	/* We aren't ask to do anything ... */
-	if (!(pfns & HMM_PFN_VALID))
+	if (!(pfns & range->flags[HMM_PFN_VALID]))
 		return;
 	/* If CPU page table is not valid then we need to fault */
-	*fault = cpu_flags & HMM_PFN_VALID;
+	*fault = cpu_flags & range->flags[HMM_PFN_VALID];
 	/* Need to write fault ? */
-	if ((pfns & HMM_PFN_WRITE) && !(cpu_flags & HMM_PFN_WRITE)) {
+	if ((pfns & range->flags[HMM_PFN_WRITE]) &&
+	    !(cpu_flags & range->flags[HMM_PFN_WRITE])) {
 		*fault = *write_fault = false;
 		return;
 	}
 	/* Do we fault on device memory ? */
-	if ((pfns & HMM_PFN_DEVICE_PRIVATE) &&
-	    (cpu_flags & HMM_PFN_DEVICE_PRIVATE)) {
-		*write_fault = pfns & HMM_PFN_WRITE;
+	if ((pfns & range->flags[HMM_PFN_DEVICE_PRIVATE]) &&
+	    (cpu_flags & range->flags[HMM_PFN_DEVICE_PRIVATE])) {
+		*write_fault = pfns & range->flags[HMM_PFN_WRITE];
 		*fault = true;
 	}
 }
@@ -396,13 +400,13 @@ static int hmm_vma_walk_hole(unsigned long addr, unsigned long end,
 	return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
 }
 
-static inline uint64_t pmd_to_hmm_pfn_flags(pmd_t pmd)
+static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd_t pmd)
 {
 	if (pmd_protnone(pmd))
 		return 0;
-	return pmd_write(pmd) ? HMM_PFN_VALID |
-				HMM_PFN_WRITE :
-				HMM_PFN_VALID;
+	return pmd_write(pmd) ? range->flags[HMM_PFN_VALID] |
+				range->flags[HMM_PFN_WRITE] :
+				range->flags[HMM_PFN_VALID];
 }
 
 static int hmm_vma_handle_pmd(struct mm_walk *walk,
@@ -412,12 +416,13 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 			      pmd_t pmd)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
 	unsigned long pfn, npages, i;
-	uint64_t flag = 0, cpu_flags;
 	bool fault, write_fault;
+	uint64_t cpu_flags;
 
 	npages = (end - addr) >> PAGE_SHIFT;
-	cpu_flags = pmd_to_hmm_pfn_flags(pmd);
+	cpu_flags = pmd_to_hmm_pfn_flags(range, pmd);
 	hmm_range_need_fault(hmm_vma_walk, pfns, npages, cpu_flags,
 			     &fault, &write_fault);
 
@@ -425,20 +430,19 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 		return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
 
 	pfn = pmd_pfn(pmd) + pte_index(addr);
-	flag |= pmd_write(pmd) ? HMM_PFN_WRITE : 0;
 	for (i = 0; addr < end; addr += PAGE_SIZE, i++, pfn++)
-		pfns[i] = hmm_pfn_from_pfn(pfn) | flag;
+		pfns[i] = hmm_pfn_from_pfn(range, pfn) | cpu_flags;
 	hmm_vma_walk->last = end;
 	return 0;
 }
 
-static inline uint64_t pte_to_hmm_pfn_flags(pte_t pte)
+static inline uint64_t pte_to_hmm_pfn_flags(struct hmm_range *range, pte_t pte)
 {
 	if (pte_none(pte) || !pte_present(pte))
 		return 0;
-	return pte_write(pte) ? HMM_PFN_VALID |
-				HMM_PFN_WRITE :
-				HMM_PFN_VALID;
+	return pte_write(pte) ? range->flags[HMM_PFN_VALID] |
+				range->flags[HMM_PFN_WRITE] :
+				range->flags[HMM_PFN_VALID];
 }
 
 static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
@@ -446,18 +450,18 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 			      uint64_t *pfns)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
 	struct vm_area_struct *vma = walk->vma;
 	bool fault, write_fault;
 	uint64_t cpu_flags;
 	pte_t pte = *ptep;
 
-	*pfns = 0;
-	cpu_flags = pte_to_hmm_pfn_flags(pte);
+	*pfns = range->flags[HMM_PFN_NONE];
+	cpu_flags = pte_to_hmm_pfn_flags(range, pte);
 	hmm_pte_need_fault(hmm_vma_walk, *pfns, cpu_flags,
 			   &fault, &write_fault);
 
 	if (pte_none(pte)) {
-		*pfns = 0;
 		if (fault || write_fault)
 			goto fault;
 		return 0;
@@ -477,11 +481,16 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 		 * device and report anything else as error.
 		 */
 		if (is_device_private_entry(entry)) {
-			cpu_flags = HMM_PFN_VALID | HMM_PFN_DEVICE_PRIVATE;
+			cpu_flags = range->flags[HMM_PFN_VALID] |
+				    range->flags[HMM_PFN_DEVICE_PRIVATE];
 			cpu_flags |= is_write_device_private_entry(entry) ?
-					HMM_PFN_WRITE : 0;
-			*pfns = hmm_pfn_from_pfn(swp_offset(entry));
-			*pfns |= HMM_PFN_DEVICE_PRIVATE;
+					range->flags[HMM_PFN_WRITE] : 0;
+			hmm_pte_need_fault(hmm_vma_walk, *pfns, cpu_flags,
+					   &fault, &write_fault);
+			if (fault || write_fault)
+				goto fault;
+			*pfns = hmm_pfn_from_pfn(range, swp_offset(entry));
+			*pfns |= cpu_flags;
 			return 0;
 		}
 
@@ -504,7 +513,7 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 	if (fault || write_fault)
 		goto fault;
 
-	*pfns = hmm_pfn_from_pfn(pte_pfn(pte)) | cpu_flags;
+	*pfns = hmm_pfn_from_pfn(range, pte_pfn(pte)) | cpu_flags;
 	return 0;
 
 fault:
@@ -573,12 +582,13 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	return 0;
 }
 
-static void hmm_pfns_clear(uint64_t *pfns,
+static void hmm_pfns_clear(struct hmm_range *range,
+			   uint64_t *pfns,
 			   unsigned long addr,
 			   unsigned long end)
 {
 	for (; addr < end; addr += PAGE_SIZE, pfns++)
-		*pfns = 0;
+		*pfns = range->flags[HMM_PFN_NONE];
 }
 
 static void hmm_pfns_special(struct hmm_range *range)
@@ -586,7 +596,7 @@ static void hmm_pfns_special(struct hmm_range *range)
 	unsigned long addr = range->start, i = 0;
 
 	for (; addr < range->end; addr += PAGE_SIZE, i++)
-		range->pfns[i] = HMM_PFN_SPECIAL;
+		range->pfns[i] = range->flags[HMM_PFN_SPECIAL];
 }
 
 /*
@@ -644,7 +654,7 @@ int hmm_vma_get_pfns(struct hmm_range *range)
 		 * is not a case we care about (some operation like atomic no
 		 * longer make sense).
 		 */
-		hmm_pfns_clear(range->pfns, range->start, range->end);
+		hmm_pfns_clear(range, range->pfns, range->start, range->end);
 		return 0;
 	}
 
@@ -788,7 +798,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 
 	hmm = hmm_register(vma->vm_mm);
 	if (!hmm) {
-		hmm_pfns_clear(range->pfns, range->start, range->end);
+		hmm_pfns_clear(range, range->pfns, range->start, range->end);
 		return -ENOMEM;
 	}
 	/* Caller must have registered a mirror using hmm_mirror_register() */
@@ -814,7 +824,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 		 * is not a case we care about (some operation like atomic no
 		 * longer make sense).
 		 */
-		hmm_pfns_clear(range->pfns, range->start, range->end);
+		hmm_pfns_clear(range, range->pfns, range->start, range->end);
 		return 0;
 	}
 
@@ -841,7 +851,8 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 		unsigned long i;
 
 		i = (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
-		hmm_pfns_clear(&range->pfns[i], hmm_vma_walk.last, range->end);
+		hmm_pfns_clear(range, &range->pfns[i], hmm_vma_walk.last,
+			       range->end);
 		hmm_vma_range_done(range);
 	}
 	return ret;
-- 
2.14.3
