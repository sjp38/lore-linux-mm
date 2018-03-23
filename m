Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77A5D6B0268
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 20:55:56 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id x35so6849760qtx.5
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 17:55:56 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y10si1806267qkl.330.2018.03.22.17.55.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 17:55:55 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 14/15] mm/hmm: change hmm_vma_fault() to allow write fault on page basis
Date: Thu, 22 Mar 2018 20:55:26 -0400
Message-Id: <20180323005527.758-15-jglisse@redhat.com>
In-Reply-To: <20180323005527.758-1-jglisse@redhat.com>
References: <20180323005527.758-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This change hmm_vma_fault() to not take a global write fault flag
for a range but instead rely on caller to populate HMM pfns array
with proper fault flag ie HMM_PFN_VALID if driver want read fault
for that address or HMM_PFN_VALID and HMM_PFN_WRITE for write.

Moreover by setting HMM_PFN_DEVICE_PRIVATE the device driver can
ask for device private memory to be migrated back to system memory
through page fault.

This is more flexible API and it better reflects how device handles
and reports fault.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h |   2 +-
 mm/hmm.c            | 151 ++++++++++++++++++++++++++++++++++++++++------------
 2 files changed, 119 insertions(+), 34 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index e8515cad5a00..0f7ea3074175 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -317,7 +317,7 @@ bool hmm_vma_range_done(struct hmm_range *range);
  *
  * See the function description in mm/hmm.c for further documentation.
  */
-int hmm_vma_fault(struct hmm_range *range, bool write, bool block);
+int hmm_vma_fault(struct hmm_range *range, bool block);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 2cc4dda1fd2e..290c872062a1 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -299,12 +299,10 @@ struct hmm_vma_walk {
 	unsigned long		last;
 	bool			fault;
 	bool			block;
-	bool			write;
 };
 
-static int hmm_vma_do_fault(struct mm_walk *walk,
-			    unsigned long addr,
-			    uint64_t *pfn)
+static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
+			    bool write_fault, uint64_t *pfn)
 {
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
@@ -312,7 +310,7 @@ static int hmm_vma_do_fault(struct mm_walk *walk,
 	int r;
 
 	flags |= hmm_vma_walk->block ? 0 : FAULT_FLAG_ALLOW_RETRY;
-	flags |= hmm_vma_walk->write ? FAULT_FLAG_WRITE : 0;
+	flags |= write_fault ? FAULT_FLAG_WRITE : 0;
 	r = handle_mm_fault(vma, addr, flags);
 	if (r & VM_FAULT_RETRY)
 		return -EBUSY;
@@ -344,15 +342,17 @@ static int hmm_pfns_bad(unsigned long addr,
  * hmm_vma_walk_hole() - handle a range lacking valid pmd or pte(s)
  * @start: range virtual start address (inclusive)
  * @end: range virtual end address (exclusive)
+ * @fault: should we fault or not ?
+ * @write_fault: write fault ?
  * @walk: mm_walk structure
  * Returns: 0 on success, -EAGAIN after page fault, or page fault error
  *
  * This function will be called whenever pmd_none() or pte_none() returns true,
  * or whenever there is no page directory covering the virtual address range.
  */
-static int hmm_vma_walk_hole(unsigned long addr,
-			     unsigned long end,
-			     struct mm_walk *walk)
+static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
+			      bool fault, bool write_fault,
+			      struct mm_walk *walk)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
@@ -363,16 +363,89 @@ static int hmm_vma_walk_hole(unsigned long addr,
 	i = (addr - range->start) >> PAGE_SHIFT;
 	for (; addr < end; addr += PAGE_SIZE, i++) {
 		pfns[i] = 0;
-		if (hmm_vma_walk->fault) {
+		if (fault || write_fault) {
 			int ret;
 
-			ret = hmm_vma_do_fault(walk, addr, &pfns[i]);
+			ret = hmm_vma_do_fault(walk, addr, write_fault,
+					       &pfns[i]);
 			if (ret != -EAGAIN)
 				return ret;
 		}
 	}
 
-	return hmm_vma_walk->fault ? -EAGAIN : 0;
+	return (fault || write_fault) ? -EAGAIN : 0;
+}
+
+static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
+				      uint64_t pfns, uint64_t cpu_flags,
+				      bool *fault, bool *write_fault)
+{
+	*fault = *write_fault = false;
+	if (!hmm_vma_walk->fault)
+		return;
+
+	/* We aren't ask to do anything ... */
+	if (!(pfns & HMM_PFN_VALID))
+		return;
+	/* If CPU page table is not valid then we need to fault */
+	*fault = cpu_flags & HMM_PFN_VALID;
+	/* Need to write fault ? */
+	if ((pfns & HMM_PFN_WRITE) && !(cpu_flags & HMM_PFN_WRITE)) {
+		*fault = *write_fault = false;
+		return;
+	}
+	/* Do we fault on device memory ? */
+	if ((pfns & HMM_PFN_DEVICE_PRIVATE) &&
+	    (cpu_flags & HMM_PFN_DEVICE_PRIVATE)) {
+		*write_fault = pfns & HMM_PFN_WRITE;
+		*fault = true;
+	}
+}
+
+static void hmm_range_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
+				 const uint64_t *pfns, unsigned long npages,
+				 uint64_t cpu_flags, bool *fault,
+				 bool *write_fault)
+{
+	unsigned long i;
+
+	if (!hmm_vma_walk->fault) {
+		*fault = *write_fault = false;
+		return;
+	}
+
+	for (i = 0; i < npages; ++i) {
+		hmm_pte_need_fault(hmm_vma_walk, pfns[i], cpu_flags,
+				   fault, write_fault);
+		if ((*fault) || (*write_fault))
+			return;
+	}
+}
+
+static int hmm_vma_walk_hole(unsigned long addr, unsigned long end,
+			     struct mm_walk *walk)
+{
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct hmm_range *range = hmm_vma_walk->range;
+	bool fault, write_fault;
+	unsigned long i, npages;
+	uint64_t *pfns;
+
+	i = (addr - range->start) >> PAGE_SHIFT;
+	npages = (end - addr) >> PAGE_SHIFT;
+	pfns = &range->pfns[i];
+	hmm_range_need_fault(hmm_vma_walk, pfns, npages,
+			     0, &fault, &write_fault);
+	return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
+}
+
+static inline uint64_t pmd_to_hmm_pfn_flags(pmd_t pmd)
+{
+	if (pmd_protnone(pmd))
+		return 0;
+	return pmd_write(pmd) ? HMM_PFN_VALID |
+				HMM_PFN_WRITE :
+				HMM_PFN_VALID;
 }
 
 static int hmm_vma_handle_pmd(struct mm_walk *walk,
@@ -382,14 +455,17 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 			      pmd_t pmd)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
-	unsigned long pfn, i;
-	uint64_t flag = 0;
+	unsigned long pfn, npages, i;
+	uint64_t flag = 0, cpu_flags;
+	bool fault, write_fault;
 
-	if (pmd_protnone(pmd))
-		return hmm_vma_walk_hole(addr, end, walk);
+	npages = (end - addr) >> PAGE_SHIFT;
+	cpu_flags = pmd_to_hmm_pfn_flags(pmd);
+	hmm_range_need_fault(hmm_vma_walk, pfns, npages, cpu_flags,
+			     &fault, &write_fault);
 
-	if ((hmm_vma_walk->fault & hmm_vma_walk->write) && !pmd_write(pmd))
-		return hmm_vma_walk_hole(addr, end, walk);
+	if (pmd_protnone(pmd) || fault || write_fault)
+		return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
 
 	pfn = pmd_pfn(pmd) + pte_index(addr);
 	flag |= pmd_write(pmd) ? HMM_PFN_WRITE : 0;
@@ -399,19 +475,32 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 	return 0;
 }
 
+static inline uint64_t pte_to_hmm_pfn_flags(pte_t pte)
+{
+	if (pte_none(pte) || !pte_present(pte))
+		return 0;
+	return pte_write(pte) ? HMM_PFN_VALID |
+				HMM_PFN_WRITE :
+				HMM_PFN_VALID;
+}
+
 static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 			      unsigned long end, pmd_t *pmdp, pte_t *ptep,
 			      uint64_t *pfn)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct vm_area_struct *vma = walk->vma;
+	bool fault, write_fault;
+	uint64_t cpu_flags;
 	pte_t pte = *ptep;
 
 	*pfn = 0;
+	cpu_flags = pte_to_hmm_pfn_flags(pte);
+	hmm_pte_need_fault(hmm_vma_walk, *pfn, cpu_flags,
+			   &fault, &write_fault);
 
 	if (pte_none(pte)) {
-		*pfn = 0;
-		if (hmm_vma_walk->fault)
+		if (fault || write_fault)
 			goto fault;
 		return 0;
 	}
@@ -420,7 +509,7 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 		swp_entry_t entry = pte_to_swp_entry(pte);
 
 		if (!non_swap_entry(entry)) {
-			if (hmm_vma_walk->fault)
+			if (fault || write_fault)
 				goto fault;
 			return 0;
 		}
@@ -430,21 +519,20 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 		 * device and report anything else as error.
 		 */
 		if (is_device_private_entry(entry)) {
+			cpu_flags = HMM_PFN_VALID | HMM_PFN_DEVICE_PRIVATE;
+			cpu_flags |= is_write_device_private_entry(entry) ?
+					HMM_PFN_WRITE : 0;
 			*pfn = hmm_pfn_from_pfn(swp_offset(entry));
-			if (is_write_device_private_entry(entry)) {
-				*pfn |= HMM_PFN_WRITE;
-			} else if ((hmm_vma_walk->fault & hmm_vma_walk->write))
-				goto fault;
 			*pfn |= HMM_PFN_DEVICE_PRIVATE;
 			return 0;
 		}
 
 		if (is_migration_entry(entry)) {
-			if (hmm_vma_walk->fault) {
+			if (fault || write_fault) {
 				pte_unmap(ptep);
 				hmm_vma_walk->last = addr;
 				migration_entry_wait(vma->vm_mm,
-						pmdp, addr);
+						     pmdp, addr);
 				return -EAGAIN;
 			}
 			return 0;
@@ -455,17 +543,16 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 		return -EFAULT;
 	}
 
-	if ((hmm_vma_walk->fault & hmm_vma_walk->write) && !pte_write(pte))
+	if (fault || write_fault)
 		goto fault;
 
-	*pfn = hmm_pfn_from_pfn(pte_pfn(pte));
-	*pfn |= pte_write(pte) ? HMM_PFN_WRITE : 0;
+	*pfn = hmm_pfn_from_pfn(pte_pfn(pte)) | cpu_flags;
 	return 0;
 
 fault:
 	pte_unmap(ptep);
 	/* Fault any virtual address we were asked to fault */
-	return hmm_vma_walk_hole(addr, end, walk);
+	return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
 }
 
 static int hmm_vma_walk_pmd(pmd_t *pmdp,
@@ -686,7 +773,6 @@ EXPORT_SYMBOL(hmm_vma_range_done);
 /*
  * hmm_vma_fault() - try to fault some address in a virtual address range
  * @range: range being faulted
- * @write: is it a write fault
  * @block: allow blocking on fault (if true it sleeps and do not drop mmap_sem)
  * Returns: 0 success, error otherwise (-EAGAIN means mmap_sem have been drop)
  *
@@ -731,7 +817,7 @@ EXPORT_SYMBOL(hmm_vma_range_done);
  *
  * YOU HAVE BEEN WARNED !
  */
-int hmm_vma_fault(struct hmm_range *range, bool write, bool block)
+int hmm_vma_fault(struct hmm_range *range, bool block)
 {
 	struct vm_area_struct *vma = range->vma;
 	unsigned long start = range->start;
@@ -779,7 +865,6 @@ int hmm_vma_fault(struct hmm_range *range, bool write, bool block)
 	spin_unlock(&hmm->lock);
 
 	hmm_vma_walk.fault = true;
-	hmm_vma_walk.write = write;
 	hmm_vma_walk.block = block;
 	hmm_vma_walk.range = range;
 	mm_walk.private = &hmm_vma_walk;
-- 
2.14.3
