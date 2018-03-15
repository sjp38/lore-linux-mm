Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B96E6B0007
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 14:37:14 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id y3so5007957qka.14
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 11:37:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a17si773264qtg.76.2018.03.15.11.37.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 11:37:12 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 4/4] mm/hmm: change CPU page table snapshot functions to simplify drivers
Date: Thu, 15 Mar 2018 14:37:00 -0400
Message-Id: <20180315183700.3843-5-jglisse@redhat.com>
In-Reply-To: <20180315183700.3843-1-jglisse@redhat.com>
References: <20180315183700.3843-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This change hmm_vma_fault() and hmm_vma_get_pfns() API to allow HMM
to directly write entry that can match any device page table entry
format. Device driver now provide an array of flags value and we use
enum to index this array for each flag.

This also allow the device driver to ask for write fault on a per page
basis making API more flexible to service multiple device page faults
in one go.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h | 130 +++++++++++----------
 mm/hmm.c            | 331 +++++++++++++++++++++++++++++-----------------------
 2 files changed, 249 insertions(+), 212 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 61b0e1c05ee1..34e8a8c65bbd 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -80,11 +80,10 @@
 struct hmm;
 
 /*
- * hmm_pfn_t - HMM uses its own pfn type to keep several flags per page
+ * uint64_t - HMM uses its own pfn type to keep several flags per page
  *
  * Flags:
  * HMM_PFN_VALID: pfn is valid
- * HMM_PFN_READ:  CPU page table has read permission set
  * HMM_PFN_WRITE: CPU page table has write permission set
  * HMM_PFN_ERROR: corresponding CPU page table entry points to poisoned memory
  * HMM_PFN_EMPTY: corresponding CPU page table entry is pte_none()
@@ -92,64 +91,94 @@ struct hmm;
  *      result of vm_insert_pfn() or vm_insert_page(). Therefore, it should not
  *      be mirrored by a device, because the entry will never have HMM_PFN_VALID
  *      set and the pfn value is undefined.
- * HMM_PFN_DEVICE_UNADDRESSABLE: unaddressable device memory (ZONE_DEVICE)
+ * HMM_PFN_DEVICE_PRIVATE: private device memory (ZONE_DEVICE)
  */
-typedef unsigned long hmm_pfn_t;
+enum hmm_pfn_flag_e {
+	HMM_PFN_FLAG_VALID = 0,
+	HMM_PFN_FLAG_WRITE,
+	HMM_PFN_FLAG_ERROR,
+	HMM_PFN_FLAG_NONE,
+	HMM_PFN_FLAG_SPECIAL,
+	HMM_PFN_FLAG_DEVICE_PRIVATE,
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
+ * @valid: pfns array did not change since it has been fill by an HMM function
+ */
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
+#define HMM_RANGE_PFN_FLAG(f) (range->flags[HMM_PFN_FLAG_##f])
 
-#define HMM_PFN_VALID (1 << 0)
-#define HMM_PFN_READ (1 << 1)
-#define HMM_PFN_WRITE (1 << 2)
-#define HMM_PFN_ERROR (1 << 3)
-#define HMM_PFN_EMPTY (1 << 4)
-#define HMM_PFN_SPECIAL (1 << 5)
-#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 6)
-#define HMM_PFN_SHIFT 7
 
 /*
- * hmm_pfn_t_to_page() - return struct page pointed to by a valid hmm_pfn_t
- * @pfn: hmm_pfn_t to convert to struct page
+ * hmm_pfn_to_page() - return struct page pointed to by a valid hmm_pfn_t
+ * @pfn: uint64_t to convert to struct page
  * Returns: struct page pointer if pfn is a valid hmm_pfn_t, NULL otherwise
  *
- * If the hmm_pfn_t is valid (ie valid flag set) then return the struct page
+ * If the uint64_t is valid (ie valid flag set) then return the struct page
  * matching the pfn value stored in the hmm_pfn_t. Otherwise return NULL.
  */
-static inline struct page *hmm_pfn_t_to_page(hmm_pfn_t pfn)
+static inline struct page *hmm_pfn_to_page(const struct hmm_range *range,
+					   uint64_t pfn)
 {
-	if (!(pfn & HMM_PFN_VALID))
+	if (!(pfn & HMM_RANGE_PFN_FLAG(VALID)))
 		return NULL;
-	return pfn_to_page(pfn >> HMM_PFN_SHIFT);
+	return pfn_to_page(pfn >> range->pfn_shift);
 }
 
 /*
- * hmm_pfn_t_to_pfn() - return pfn value store in a hmm_pfn_t
- * @pfn: hmm_pfn_t to extract pfn from
- * Returns: pfn value if hmm_pfn_t is valid, -1UL otherwise
+ * hmm_pfn_to_pfn() - return pfn value store in a hmm_pfn_t
+ * @pfn: uint64_t to extract pfn from
+ * Returns: pfn value if uint64_t is valid, -1UL otherwise
  */
-static inline unsigned long hmm_pfn_t_to_pfn(hmm_pfn_t pfn)
+static inline unsigned long hmm_pfn_to_pfn(const struct hmm_range *range,
+					   uint64_t pfn)
 {
-	if (!(pfn & HMM_PFN_VALID))
+	if (!(pfn & HMM_RANGE_PFN_FLAG(VALID)))
 		return -1UL;
-	return (pfn >> HMM_PFN_SHIFT);
+	return (pfn >> range->pfn_shift);
 }
 
 /*
- * hmm_pfn_t_from_page() - create a valid hmm_pfn_t value from struct page
+ * hmm_pfn_from_page() - create a valid uint64_t value from struct page
+ * @range: struct hmm_range pointer where pfn encoding constant are
  * @page: struct page pointer for which to create the hmm_pfn_t
- * Returns: valid hmm_pfn_t for the page
+ * Returns: valid uint64_t for the page
  */
-static inline hmm_pfn_t hmm_pfn_t_from_page(struct page *page)
+static inline uint64_t hmm_pfn_from_page(const struct hmm_range *range,
+					 struct page *page)
 {
-	return (page_to_pfn(page) << HMM_PFN_SHIFT) | HMM_PFN_VALID;
+	return (page_to_pfn(page) << range->pfn_shift) |
+		HMM_RANGE_PFN_FLAG(VALID);
 }
 
 /*
- * hmm_pfn_t_from_pfn() - create a valid hmm_pfn_t value from pfn
+ * hmm_pfn_from_pfn() - create a valid uint64_t value from pfn
+ * @range: struct hmm_range pointer where pfn encoding constant are
  * @pfn: pfn value for which to create the hmm_pfn_t
- * Returns: valid hmm_pfn_t for the pfn
+ * Returns: valid uint64_t for the pfn
  */
-static inline hmm_pfn_t hmm_pfn_t_from_pfn(unsigned long pfn)
+static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
+					unsigned long pfn)
 {
-	return (pfn << HMM_PFN_SHIFT) | HMM_PFN_VALID;
+	return (pfn << range->pfn_shift) | HMM_RANGE_PFN_FLAG(VALID);
 }
 
 
@@ -271,23 +300,6 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
 void hmm_mirror_unregister(struct hmm_mirror *mirror);
 
 
-/*
- * struct hmm_range - track invalidation lock on virtual address range
- *
- * @list: all range lock are on a list
- * @start: range virtual start address (inclusive)
- * @end: range virtual end address (exclusive)
- * @pfns: array of pfns (big enough for the range)
- * @valid: pfns array did not change since it has been fill by an HMM function
- */
-struct hmm_range {
-	struct list_head	list;
-	unsigned long		start;
-	unsigned long		end;
-	hmm_pfn_t		*pfns;
-	bool			valid;
-};
-
 /*
  * To snapshot the CPU page table, call hmm_vma_get_pfns(), then take a device
  * driver lock that serializes device page table updates, then call
@@ -301,17 +313,13 @@ struct hmm_range {
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
  * Fault memory on behalf of device driver. Unlike handle_mm_fault(), this will
- * not migrate any device memory back to system memory. The hmm_pfn_t array will
+ * not migrate any device memory back to system memory. The uint64_t array will
  * be updated with the fault result and current snapshot of the CPU page table
  * for the range.
  *
@@ -320,20 +328,14 @@ bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range);
  * function returns -EAGAIN.
  *
  * Return value does not reflect if the fault was successful for every single
- * address or not. Therefore, the caller must to inspect the hmm_pfn_t array to
+ * address or not. Therefore, the caller must to inspect the uint64_t array to
  * determine fault status for each address.
  *
  * Trying to fault inside an invalid vma will result in -EINVAL.
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
+int hmm_vma_fault(struct hmm_range *range, bool block);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 
diff --git a/mm/hmm.c b/mm/hmm.c
index db24d9f9f046..fe92a580e6af 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -258,60 +258,63 @@ struct hmm_vma_walk {
 	unsigned long		last;
 	bool			fault;
 	bool			block;
-	bool			write;
 };
 
 static int hmm_vma_do_fault(struct mm_walk *walk,
 			    unsigned long addr,
-			    hmm_pfn_t *pfn)
+			    uint64_t *pfn)
 {
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
 	struct vm_area_struct *vma = walk->vma;
 	int r;
 
 	flags |= hmm_vma_walk->block ? 0 : FAULT_FLAG_ALLOW_RETRY;
-	flags |= hmm_vma_walk->write ? FAULT_FLAG_WRITE : 0;
+	flags |= (*pfn) & HMM_RANGE_PFN_FLAG(WRITE) ? FAULT_FLAG_WRITE : 0;
 	r = handle_mm_fault(vma, addr, flags);
 	if (r & VM_FAULT_RETRY)
 		return -EBUSY;
 	if (r & VM_FAULT_ERROR) {
-		*pfn = HMM_PFN_ERROR;
+		*pfn = HMM_RANGE_PFN_FLAG(ERROR);
 		return -EFAULT;
 	}
 
 	return -EAGAIN;
 }
 
-static void hmm_pfns_special(hmm_pfn_t *pfns,
+static void hmm_pfns_special(const struct hmm_range *range,
+			     uint64_t *pfns,
 			     unsigned long addr,
 			     unsigned long end)
 {
 	for (; addr < end; addr += PAGE_SIZE, pfns++)
-		*pfns = HMM_PFN_SPECIAL;
+		*pfns = HMM_RANGE_PFN_FLAG(SPECIAL);
 }
 
 static int hmm_pfns_bad(unsigned long addr,
 			unsigned long end,
 			struct mm_walk *walk)
 {
-	struct hmm_range *range = walk->private;
-	hmm_pfn_t *pfns = range->pfns;
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
+	uint64_t *pfns = range->pfns;
 	unsigned long i;
 
 	i = (addr - range->start) >> PAGE_SHIFT;
 	for (; addr < end; addr += PAGE_SIZE, i++)
-		pfns[i] = HMM_PFN_ERROR;
+		pfns[i] = HMM_RANGE_PFN_FLAG(ERROR);
 
 	return 0;
 }
 
-static void hmm_pfns_clear(hmm_pfn_t *pfns,
+static void hmm_pfns_clear(struct hmm_range *range,
+			   uint64_t *pfns,
 			   unsigned long addr,
 			   unsigned long end)
 {
 	for (; addr < end; addr += PAGE_SIZE, pfns++)
-		*pfns = 0;
+		*pfns = HMM_RANGE_PFN_FLAG(NONE);
 }
 
 static int hmm_vma_walk_hole(unsigned long addr,
@@ -320,13 +323,13 @@ static int hmm_vma_walk_hole(unsigned long addr,
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
-	hmm_pfn_t *pfns = range->pfns;
+	uint64_t *pfns = range->pfns;
 	unsigned long i;
 
 	hmm_vma_walk->last = addr;
 	i = (addr - range->start) >> PAGE_SHIFT;
 	for (; addr < end; addr += PAGE_SIZE, i++) {
-		pfns[i] = HMM_PFN_EMPTY;
+		pfns[i] = HMM_RANGE_PFN_FLAG(NONE);
 		if (hmm_vma_walk->fault) {
 			int ret;
 
@@ -339,29 +342,146 @@ static int hmm_vma_walk_hole(unsigned long addr,
 	return hmm_vma_walk->fault ? -EAGAIN : 0;
 }
 
-static int hmm_vma_walk_clear(unsigned long addr,
+static bool hmm_pfn_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
+			       const uint64_t *pfns, unsigned long npages,
+			       uint64_t cpu_flags)
+{
+	struct hmm_range *range = hmm_vma_walk->range;
+	uint64_t mask_valid, mask_write, mask_device;
+	unsigned long i;
+
+	if (!hmm_vma_walk->fault)
+		return false;
+
+	/* Mask flags we care about for fault */
+	mask_valid = HMM_RANGE_PFN_FLAG(VALID);
+	mask_write = HMM_RANGE_PFN_FLAG(WRITE);
+	mask_device = HMM_RANGE_PFN_FLAG(DEVICE_PRIVATE);
+
+	for (i = 0; i < npages; ++i) {
+		/* We aren't ask to do anything ... */
+		if (!(pfns[i] & mask_valid))
+			continue;
+		/* Need to write fault ? */
+		if ((pfns[i] & mask_write) && !(cpu_flags & mask_write))
+			return true;
+		/* Do we fault on device memory ? */
+		if ((pfns[i] & mask_device) && (cpu_flags & mask_device))
+			return true;
+	}
+	return false;
+}
+
+static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd_t pmd)
+{
+	if (pmd_protnone(pmd))
+		return 0;
+	return pmd_write(pmd) ? HMM_RANGE_PFN_FLAG(VALID) |
+				HMM_RANGE_PFN_FLAG(WRITE) :
+				HMM_RANGE_PFN_FLAG(VALID);
+}
+
+static int hmm_vma_handle_pmd(struct mm_walk *walk,
+			      unsigned long addr,
 			      unsigned long end,
-			      struct mm_walk *walk)
+			      uint64_t *pfns,
+			      pmd_t pmd)
 {
+	unsigned long npages = (end - addr) >> PAGE_SHIFT, pfn = 0;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
-	hmm_pfn_t *pfns = range->pfns;
-	unsigned long i;
+	uint64_t cpu_flags, i;
 
-	hmm_vma_walk->last = addr;
-	i = (addr - range->start) >> PAGE_SHIFT;
-	for (; addr < end; addr += PAGE_SIZE, i++) {
-		pfns[i] = 0;
-		if (hmm_vma_walk->fault) {
-			int ret;
+	cpu_flags = pmd_to_hmm_pfn_flags(range, pmd);
+	pfn = cpu_flags ? pmd_pfn(pmd) + pte_index(addr) : 0;
+	pfn = cpu_flags ? hmm_pfn_from_pfn(range, pfn) | cpu_flags : 0;
 
-			ret = hmm_vma_do_fault(walk, addr, &pfns[i]);
-			if (ret != -EAGAIN)
-				return ret;
+	if (hmm_pfn_need_fault(hmm_vma_walk, pfns, npages, cpu_flags)) {
+		int ret;
+
+		hmm_vma_walk->last = addr;
+		ret = hmm_vma_do_fault(walk, addr, pfns);
+		return ret ? ret : -EAGAIN;
+	}
+
+	for (i = 0; i < npages; i++) {
+		pfns[i] = pfn;
+		pfn = pfn ? (pfn + (1ULL << range->pfn_shift)) : 0;
+	}
+
+	hmm_vma_walk->last = end;
+	return 0;
+}
+
+static inline uint64_t hmm_vma_handle_pte(struct mm_walk *walk,
+					  unsigned long addr, pmd_t *pmdp,
+					  pte_t *ptep, uint64_t *pfns)
+{
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
+	uint64_t pfn = HMM_RANGE_PFN_FLAG(VALID);
+	struct vm_area_struct *vma = walk->vma;
+	pte_t pte = *ptep;
+	int ret;
+
+	if (pte_none(pte)) {
+		*pfns = HMM_RANGE_PFN_FLAG(NONE);
+		return 0;
+	}
+
+	if (!pte_present(pte)) {
+		swp_entry_t entry = pte_to_swp_entry(pte);
+
+		if (!non_swap_entry(entry)) {
+			if (hmm_pfn_need_fault(hmm_vma_walk, pfns, 1, pfn))
+				goto fault;
+			*pfns = HMM_RANGE_PFN_FLAG(NONE);
+			return 0;
 		}
+
+		if (is_device_private_entry(entry)) {
+			pfn |= range->vma->vm_flags & VM_WRITE ?
+			       HMM_RANGE_PFN_FLAG(DEVICE_PRIVATE) |
+			       HMM_RANGE_PFN_FLAG(WRITE) :
+			       HMM_RANGE_PFN_FLAG(DEVICE_PRIVATE);
+			pfn |= hmm_pfn_from_pfn(range, swp_offset(entry));
+
+			if (hmm_pfn_need_fault(hmm_vma_walk, pfns, 1, pfn))
+				goto fault;
+
+			*pfns = pfn;
+			return 0;
+		}
+
+		if (is_migration_entry(entry)) {
+			if (hmm_vma_walk->fault) {
+				pte_unmap(ptep);
+				hmm_vma_walk->last = addr;
+				migration_entry_wait(vma->vm_mm,
+						     pmdp, addr);
+				return -EAGAIN;
+			}
+
+			*pfns = HMM_RANGE_PFN_FLAG(NONE);
+			return 0;
+		}
+
+		/* Report error for everything else */
+		*pfns = HMM_RANGE_PFN_FLAG(ERROR);
+		return 0;
 	}
 
-	return hmm_vma_walk->fault ? -EAGAIN : 0;
+	pfn |= pte_write(pte) ? HMM_RANGE_PFN_FLAG(WRITE) : 0;
+	pfn |= hmm_pfn_from_pfn(range, pte_pfn(pte));
+	if (!hmm_pfn_need_fault(hmm_vma_walk, pfns, 1, pfn)) {
+		*pfns = pfn;
+		return 0;
+	}
+
+fault:
+	pte_unmap(ptep);
+	ret = hmm_vma_do_fault(walk, addr, pfns);
+	return ret ? ret : -EAGAIN;
 }
 
 static int hmm_vma_walk_pmd(pmd_t *pmdp,
@@ -372,15 +492,11 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	struct vm_area_struct *vma = walk->vma;
-	hmm_pfn_t *pfns = range->pfns;
+	uint64_t *pfns = range->pfns;
 	unsigned long addr = start, i;
-	bool write_fault;
-	hmm_pfn_t flag;
 	pte_t *ptep;
 
 	i = (addr - range->start) >> PAGE_SHIFT;
-	flag = vma->vm_flags & VM_READ ? HMM_PFN_READ : 0;
-	write_fault = hmm_vma_walk->fault & hmm_vma_walk->write;
 
 again:
 	if (pmd_none(*pmdp))
@@ -390,7 +506,6 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		return hmm_pfns_bad(start, end, walk);
 
 	if (pmd_devmap(*pmdp) || pmd_trans_huge(*pmdp)) {
-		unsigned long pfn;
 		pmd_t pmd;
 
 		/*
@@ -406,17 +521,8 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		barrier();
 		if (!pmd_devmap(pmd) && !pmd_trans_huge(pmd))
 			goto again;
-		if (pmd_protnone(pmd))
-			return hmm_vma_walk_clear(start, end, walk);
 
-		if (write_fault && !pmd_write(pmd))
-			return hmm_vma_walk_clear(start, end, walk);
-
-		pfn = pmd_pfn(pmd) + pte_index(addr);
-		flag |= pmd_write(pmd) ? HMM_PFN_WRITE : 0;
-		for (; addr < end; addr += PAGE_SIZE, i++, pfn++)
-			pfns[i] = hmm_pfn_t_from_pfn(pfn) | flag;
-		return 0;
+		return hmm_vma_handle_pmd(walk, addr, end, &pfns[i], pmd);
 	}
 
 	if (pmd_bad(*pmdp))
@@ -424,78 +530,23 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 
 	ptep = pte_offset_map(pmdp, addr);
 	for (; addr < end; addr += PAGE_SIZE, ptep++, i++) {
-		pte_t pte = *ptep;
-
-		pfns[i] = 0;
-
-		if (pte_none(pte)) {
-			pfns[i] = HMM_PFN_EMPTY;
-			if (hmm_vma_walk->fault)
-				goto fault;
-			continue;
-		}
-
-		if (!pte_present(pte)) {
-			swp_entry_t entry = pte_to_swp_entry(pte);
-
-			if (!non_swap_entry(entry)) {
-				if (hmm_vma_walk->fault)
-					goto fault;
-				continue;
-			}
+		int ret;
 
-			/*
-			 * This is a special swap entry, ignore migration, use
-			 * device and report anything else as error.
-			 */
-			if (is_device_private_entry(entry)) {
-				pfns[i] = hmm_pfn_t_from_pfn(swp_offset(entry));
-				if (is_write_device_private_entry(entry)) {
-					pfns[i] |= HMM_PFN_WRITE;
-				} else if (write_fault)
-					goto fault;
-				pfns[i] |= HMM_PFN_DEVICE_UNADDRESSABLE;
-				pfns[i] |= flag;
-			} else if (is_migration_entry(entry)) {
-				if (hmm_vma_walk->fault) {
-					pte_unmap(ptep);
-					hmm_vma_walk->last = addr;
-					migration_entry_wait(vma->vm_mm,
-							     pmdp, addr);
-					return -EAGAIN;
-				}
-				continue;
-			} else {
-				/* Report error for everything else */
-				pfns[i] = HMM_PFN_ERROR;
-			}
-			continue;
+		ret = hmm_vma_handle_pte(walk, addr, pmdp, ptep, &pfns[i]);
+		if (ret) {
+			hmm_vma_walk->last = addr;
+			return ret;
 		}
-
-		if (write_fault && !pte_write(pte))
-			goto fault;
-
-		pfns[i] = hmm_pfn_t_from_pfn(pte_pfn(pte)) | flag;
-		pfns[i] |= pte_write(pte) ? HMM_PFN_WRITE : 0;
-		continue;
-
-fault:
-		pte_unmap(ptep);
-		/* Fault all pages in range */
-		return hmm_vma_walk_clear(start, end, walk);
 	}
 	pte_unmap(ptep - 1);
 
+	hmm_vma_walk->last = addr;
 	return 0;
 }
 
 /*
  * hmm_vma_get_pfns() - snapshot CPU page table for a range of virtual addresses
- * @vma: virtual memory area containing the virtual address range
  * @range: used to track snapshot validity
- * @start: range virtual start address (inclusive)
- * @end: range virtual end address (exclusive)
- * @entries: array of hmm_pfn_t: provided by the caller, filled in by function
  * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, 0 success
  *
  * This snapshots the CPU page table for a range of virtual addresses. Snapshot
@@ -509,26 +560,23 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
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
+		hmm_pfns_special(range, range->pfns, range->start, range->end);
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
@@ -539,9 +587,6 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
 		return -EINVAL;
 
 	/* Initialize range to track CPU page table update */
-	range->start = start;
-	range->pfns = pfns;
-	range->end = end;
 	spin_lock(&hmm->lock);
 	range->valid = true;
 	list_add_rcu(&range->list, &hmm->ranges);
@@ -559,14 +604,13 @@ int hmm_vma_get_pfns(struct vm_area_struct *vma,
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
@@ -586,10 +630,10 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
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
@@ -597,15 +641,16 @@ EXPORT_SYMBOL(hmm_vma_get_pfns);
  *   device_page_table_unlock();
  *
  * Or:
- *   hmm_vma_get_pfns(vma, range, start, end, pfns); or hmm_vma_fault(...);
+ *   hmm_vma_get_pfns(range); or hmm_vma_fault(...);
  *   device_page_table_lock();
  *   hmm_vma_range_done(vma, range);
  *   device_update_page_table(pfns);
  *   device_page_table_unlock();
  */
-bool hmm_vma_range_done(struct vm_area_struct *vma, struct hmm_range *range)
+bool hmm_vma_range_done(struct hmm_range *range)
 {
 	unsigned long npages = (range->end - range->start) >> PAGE_SHIFT;
+	struct vm_area_struct *vma = range->vma;
 	struct hmm *hmm;
 
 	if (range->end <= range->start) {
@@ -629,12 +674,7 @@ EXPORT_SYMBOL(hmm_vma_range_done);
 
 /*
  * hmm_vma_fault() - try to fault some address in a virtual address range
- * @vma: virtual memory area containing the virtual address range
  * @range: use to track pfns array content validity
- * @start: fault range virtual start address (inclusive)
- * @end: fault range virtual end address (exclusive)
- * @pfns: array of hmm_pfn_t, only entry with fault flag set will be faulted
- * @write: is it a write fault
  * @block: allow blocking on fault (if true it sleeps and do not drop mmap_sem)
  * Returns: 0 success, error otherwise (-EAGAIN means mmap_sem have been drop)
  *
@@ -642,14 +682,14 @@ EXPORT_SYMBOL(hmm_vma_range_done);
  * any memory migration if the memory being faulted is not accessible by CPUs.
  *
  * On error, for one virtual address in the range, the function will set the
- * hmm_pfn_t error flag for the corresponding pfn entry.
+ * uint64_t error flag for the corresponding pfn entry.
  *
  * Expected use pattern:
  * retry:
  *   down_read(&mm->mmap_sem);
  *   // Find vma and address device wants to fault, initialize hmm_pfn_t
  *   // array accordingly
- *   ret = hmm_vma_fault(vma, start, end, pfns, allow_retry);
+ *   ret = hmm_vma_fault(range, block);
  *   switch (ret) {
  *   case -EAGAIN:
  *     hmm_vma_range_done(vma, range);
@@ -666,8 +706,9 @@ EXPORT_SYMBOL(hmm_vma_range_done);
  *   }
  *   // Take device driver lock that serialize device page table update
  *   driver_lock_device_page_table_update();
- *   hmm_vma_range_done(vma, range);
- *   // Commit pfns we got from hmm_vma_fault()
+ *   if (hmm_vma_range_done(range)) {
+ *     // Commit pfns we got from hmm_vma_fault()
+ *   }
  *   driver_unlock_device_page_table_update();
  *   up_read(&mm->mmap_sem)
  *
@@ -676,28 +717,24 @@ EXPORT_SYMBOL(hmm_vma_range_done);
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
+int hmm_vma_fault(struct hmm_range *range, bool block)
 {
+	struct vm_area_struct *vma = range->vma;
 	struct hmm_vma_walk hmm_vma_walk;
 	struct mm_walk mm_walk;
+	unsigned long start;
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
+		hmm_pfns_clear(range, range->pfns, range->start, range->end);
 		return -ENOMEM;
 	}
 	/* Caller must have registered a mirror using hmm_mirror_register() */
@@ -705,9 +742,6 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 		return -EINVAL;
 
 	/* Initialize range to track CPU page table update */
-	range->start = start;
-	range->pfns = pfns;
-	range->end = end;
 	spin_lock(&hmm->lock);
 	range->valid = true;
 	list_add_rcu(&range->list, &hmm->ranges);
@@ -715,12 +749,11 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 
 	/* FIXME support hugetlb fs */
 	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL)) {
-		hmm_pfns_special(pfns, start, end);
+		hmm_pfns_special(range, range->pfns, range->start, range->end);
 		return 0;
 	}
 
 	hmm_vma_walk.fault = true;
-	hmm_vma_walk.write = write;
 	hmm_vma_walk.block = block;
 	hmm_vma_walk.range = range;
 	mm_walk.private = &hmm_vma_walk;
@@ -734,8 +767,9 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 	mm_walk.pmd_entry = hmm_vma_walk_pmd;
 	mm_walk.pte_hole = hmm_vma_walk_hole;
 
+	start = range->start;
 	do {
-		ret = walk_page_range(start, end, &mm_walk);
+		ret = walk_page_range(start, range->end, &mm_walk);
 		start = hmm_vma_walk.last;
 	} while (ret == -EAGAIN);
 
@@ -743,8 +777,9 @@ int hmm_vma_fault(struct vm_area_struct *vma,
 		unsigned long i;
 
 		i = (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
-		hmm_pfns_clear(&pfns[i], hmm_vma_walk.last, end);
-		hmm_vma_range_done(vma, range);
+		hmm_pfns_clear(range, &range->pfns[i],
+			       hmm_vma_walk.last, range->end);
+		hmm_vma_range_done(range);
 	}
 	return ret;
 }
-- 
2.14.3
