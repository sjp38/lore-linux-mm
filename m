Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 912986B0027
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 22:00:51 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id e17so49637qtm.13
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:00:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n66si1475778qkl.46.2018.03.19.19.00.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 19:00:50 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 14/15] mm/hmm: change hmm_vma_fault() to allow write fault on page basis
Date: Mon, 19 Mar 2018 22:00:36 -0400
Message-Id: <20180320020038.3360-15-jglisse@redhat.com>
In-Reply-To: <20180320020038.3360-1-jglisse@redhat.com>
References: <20180320020038.3360-1-jglisse@redhat.com>
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
 mm/hmm.c            | 150 +++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 119 insertions(+), 33 deletions(-)

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
index dc703e9c3a95..956689804600 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -275,12 +275,10 @@ struct hmm_vma_walk {
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
@@ -288,7 +286,7 @@ static int hmm_vma_do_fault(struct mm_walk *walk,
 	int r;
 
 	flags |= hmm_vma_walk->block ? 0 : FAULT_FLAG_ALLOW_RETRY;
-	flags |= hmm_vma_walk->write ? FAULT_FLAG_WRITE : 0;
+	flags |= write_fault ? FAULT_FLAG_WRITE : 0;
 	r = handle_mm_fault(vma, addr, flags);
 	if (r & VM_FAULT_RETRY)
 		return -EBUSY;
@@ -320,15 +318,17 @@ static int hmm_pfns_bad(unsigned long addr,
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
@@ -339,16 +339,89 @@ static int hmm_vma_walk_hole(unsigned long addr,
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
@@ -358,14 +431,17 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
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
@@ -375,19 +451,33 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
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
 			      uint64_t *pfns)
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct vm_area_struct *vma = walk->vma;
+	bool fault, write_fault;
+	uint64_t cpu_flags;
 	pte_t pte = *ptep;
 
 	*pfns = 0;
+	cpu_flags = pte_to_hmm_pfn_flags(pte);
+	hmm_pte_need_fault(hmm_vma_walk, *pfns, cpu_flags,
+			   &fault, &write_fault);
 
 	if (pte_none(pte)) {
 		*pfns = 0;
-		if (hmm_vma_walk->fault)
+		if (fault || write_fault)
 			goto fault;
 		return 0;
 	}
@@ -396,7 +486,7 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 		swp_entry_t entry = pte_to_swp_entry(pte);
 
 		if (!non_swap_entry(entry)) {
-			if (hmm_vma_walk->fault)
+			if (fault || write_fault)
 				goto fault;
 			return 0;
 		}
@@ -406,21 +496,20 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 		 * device and report anything else as error.
 		 */
 		if (is_device_private_entry(entry)) {
+			cpu_flags = HMM_PFN_VALID | HMM_PFN_DEVICE_PRIVATE;
+			cpu_flags |= is_write_device_private_entry(entry) ?
+					HMM_PFN_WRITE : 0;
 			*pfns = hmm_pfn_from_pfn(swp_offset(entry));
-			if (is_write_device_private_entry(entry)) {
-				*pfns |= HMM_PFN_WRITE;
-			} else if ((hmm_vma_walk->fault & hmm_vma_walk->write))
-				goto fault;
 			*pfns |= HMM_PFN_DEVICE_PRIVATE;
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
@@ -431,17 +520,16 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 		return -EFAULT;
 	}
 
-	if ((hmm_vma_walk->fault & hmm_vma_walk->write) && !pte_write(pte))
+	if (fault || write_fault)
 		goto fault;
 
-	*pfns = hmm_pfn_from_pfn(pte_pfn(pte));
-	*pfns |= pte_write(pte) ? HMM_PFN_WRITE : 0;
+	*pfns = hmm_pfn_from_pfn(pte_pfn(pte)) | cpu_flags;
 	return 0;
 
 fault:
 	pte_unmap(ptep);
 	/* Fault any virtual address we were ask to fault */
-	return hmm_vma_walk_hole(addr, end, walk);
+	return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
 }
 
 static int hmm_vma_walk_pmd(pmd_t *pmdp,
@@ -662,7 +750,6 @@ EXPORT_SYMBOL(hmm_vma_range_done);
 /*
  * hmm_vma_fault() - try to fault some address in a virtual address range
  * @range: range being faulted
- * @write: is it a write fault
  * @block: allow blocking on fault (if true it sleeps and do not drop mmap_sem)
  * Returns: 0 success, error otherwise (-EAGAIN means mmap_sem have been drop)
  *
@@ -707,7 +794,7 @@ EXPORT_SYMBOL(hmm_vma_range_done);
  *
  * YOU HAVE BEEN WARNED !
  */
-int hmm_vma_fault(struct hmm_range *range, bool write, bool block)
+int hmm_vma_fault(struct hmm_range *range, bool block)
 {
 	struct vm_area_struct *vma = range->vma;
 	unsigned long start = range->start;
@@ -755,7 +842,6 @@ int hmm_vma_fault(struct hmm_range *range, bool write, bool block)
 	spin_unlock(&hmm->lock);
 
 	hmm_vma_walk.fault = true;
-	hmm_vma_walk.write = write;
 	hmm_vma_walk.block = block;
 	hmm_vma_walk.range = range;
 	mm_walk.private = &hmm_vma_walk;
-- 
2.14.3
