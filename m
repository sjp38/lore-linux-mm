Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6780C6B000D
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:14:24 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g199so7194256qke.18
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:14:24 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u55si738793qtk.439.2018.03.16.12.14.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:14:23 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 07/14] mm/hmm: use uint64_t for HMM pfn instead of defining hmm_pfn_t to ulong
Date: Fri, 16 Mar 2018 15:14:12 -0400
Message-Id: <20180316191414.3223-8-jglisse@redhat.com>
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

All device driver we care about are using 64bits page table entry. In
order to match this and to avoid useless define convert all HMM pfn to
directly use uint64_t. It is a first step on the road to allow driver
to directly use pfn value return by HMM (saving memory and CPU cycles
use for convertion between the two).

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h | 46 +++++++++++++++++++++-------------------------
 mm/hmm.c            | 26 +++++++++++++-------------
 2 files changed, 34 insertions(+), 38 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 4bdc58ffe9f3..78b3ed6d7977 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -80,8 +80,6 @@
 struct hmm;
 
 /*
- * hmm_pfn_t - HMM uses its own pfn type to keep several flags per page
- *
  * Flags:
  * HMM_PFN_VALID: pfn is valid
  * HMM_PFN_WRITE: CPU page table has write permission set
@@ -93,8 +91,6 @@ struct hmm;
  *      set and the pfn value is undefined.
  * HMM_PFN_DEVICE_UNADDRESSABLE: unaddressable device memory (ZONE_DEVICE)
  */
-typedef unsigned long hmm_pfn_t;
-
 #define HMM_PFN_VALID (1 << 0)
 #define HMM_PFN_WRITE (1 << 1)
 #define HMM_PFN_ERROR (1 << 2)
@@ -104,14 +100,14 @@ typedef unsigned long hmm_pfn_t;
 #define HMM_PFN_SHIFT 6
 
 /*
- * hmm_pfn_t_to_page() - return struct page pointed to by a valid hmm_pfn_t
- * @pfn: hmm_pfn_t to convert to struct page
- * Returns: struct page pointer if pfn is a valid hmm_pfn_t, NULL otherwise
+ * hmm_pfn_to_page() - return struct page pointed to by a valid HMM pfn
+ * @pfn: HMM pfn value to get corresponding struct page from
+ * Returns: struct page pointer if pfn is a valid HMM pfn, NULL otherwise
  *
- * If the hmm_pfn_t is valid (ie valid flag set) then return the struct page
- * matching the pfn value stored in the hmm_pfn_t. Otherwise return NULL.
+ * If the uint64_t is valid (ie valid flag set) then return the struct page
+ * matching the pfn value stored in the HMM pfn. Otherwise return NULL.
  */
-static inline struct page *hmm_pfn_t_to_page(hmm_pfn_t pfn)
+static inline struct page *hmm_pfn_to_page(uint64_t pfn)
 {
 	if (!(pfn & HMM_PFN_VALID))
 		return NULL;
@@ -119,11 +115,11 @@ static inline struct page *hmm_pfn_t_to_page(hmm_pfn_t pfn)
 }
 
 /*
- * hmm_pfn_t_to_pfn() - return pfn value store in a hmm_pfn_t
- * @pfn: hmm_pfn_t to extract pfn from
- * Returns: pfn value if hmm_pfn_t is valid, -1UL otherwise
+ * hmm_pfn_to_pfn() - return pfn value store in a HMM pfn
+ * @pfn: HMM pfn value to extract pfn from
+ * Returns: pfn value if HMM pfn is valid, -1UL otherwise
  */
-static inline unsigned long hmm_pfn_t_to_pfn(hmm_pfn_t pfn)
+static inline unsigned long hmm_pfn_to_pfn(uint64_t pfn)
 {
 	if (!(pfn & HMM_PFN_VALID))
 		return -1UL;
@@ -131,21 +127,21 @@ static inline unsigned long hmm_pfn_t_to_pfn(hmm_pfn_t pfn)
 }
 
 /*
- * hmm_pfn_t_from_page() - create a valid hmm_pfn_t value from struct page
- * @page: struct page pointer for which to create the hmm_pfn_t
- * Returns: valid hmm_pfn_t for the page
+ * hmm_pfn_from_page() - create a valid HMM pfn value from struct page
+ * @page: struct page pointer for which to create the HMM pfn
+ * Returns: valid HMM pfn for the page
  */
-static inline hmm_pfn_t hmm_pfn_t_from_page(struct page *page)
+static inline uint64_t hmm_pfn_from_page(struct page *page)
 {
 	return (page_to_pfn(page) << HMM_PFN_SHIFT) | HMM_PFN_VALID;
 }
 
 /*
- * hmm_pfn_t_from_pfn() - create a valid hmm_pfn_t value from pfn
- * @pfn: pfn value for which to create the hmm_pfn_t
- * Returns: valid hmm_pfn_t for the pfn
+ * hmm_pfn_from_pfn() - create a valid HMM pfn value from pfn
+ * @pfn: pfn value for which to create the HMM pfn
+ * Returns: valid HMM pfn for the pfn
  */
-static inline hmm_pfn_t hmm_pfn_t_from_pfn(unsigned long pfn)
+static inline uint64_t hmm_pfn_from_pfn(unsigned long pfn)
 {
 	return (pfn << HMM_PFN_SHIFT) | HMM_PFN_VALID;
 }
@@ -284,7 +280,7 @@ struct hmm_range {
 	struct list_head	list;
 	unsigned long		start;
 	unsigned long		end;
-	hmm_pfn_t		*pfns;
+	uint64_t		*pfns;
 	bool			valid;
 };
 
@@ -307,7 +303,7 @@ bool hmm_vma_range_done(struct hmm_range *range);
 
 /*
  * Fault memory on behalf of device driver. Unlike handle_mm_fault(), this will
- * not migrate any device memory back to system memory. The hmm_pfn_t array will
+ * not migrate any device memory back to system memory. The HMM pfn array will
  * be updated with the fault result and current snapshot of the CPU page table
  * for the range.
  *
@@ -316,7 +312,7 @@ bool hmm_vma_range_done(struct hmm_range *range);
  * function returns -EAGAIN.
  *
  * Return value does not reflect if the fault was successful for every single
- * address or not. Therefore, the caller must to inspect the hmm_pfn_t array to
+ * address or not. Therefore, the caller must to inspect the HMM pfn array to
  * determine fault status for each address.
  *
  * Trying to fault inside an invalid vma will result in -EINVAL.
diff --git a/mm/hmm.c b/mm/hmm.c
index fa3c605c4b96..f674b73e7f4a 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -261,7 +261,7 @@ struct hmm_vma_walk {
 
 static int hmm_vma_do_fault(struct mm_walk *walk,
 			    unsigned long addr,
-			    hmm_pfn_t *pfn)
+			    uint64_t *pfn)
 {
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
@@ -281,7 +281,7 @@ static int hmm_vma_do_fault(struct mm_walk *walk,
 	return -EAGAIN;
 }
 
-static void hmm_pfns_special(hmm_pfn_t *pfns,
+static void hmm_pfns_special(uint64_t *pfns,
 			     unsigned long addr,
 			     unsigned long end)
 {
@@ -295,7 +295,7 @@ static int hmm_pfns_bad(unsigned long addr,
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
-	hmm_pfn_t *pfns = range->pfns;
+	uint64_t *pfns = range->pfns;
 	unsigned long i;
 
 	i = (addr - range->start) >> PAGE_SHIFT;
@@ -305,7 +305,7 @@ static int hmm_pfns_bad(unsigned long addr,
 	return 0;
 }
 
-static void hmm_pfns_clear(hmm_pfn_t *pfns,
+static void hmm_pfns_clear(uint64_t *pfns,
 			   unsigned long addr,
 			   unsigned long end)
 {
@@ -319,7 +319,7 @@ static int hmm_vma_walk_hole(unsigned long addr,
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
-	hmm_pfn_t *pfns = range->pfns;
+	uint64_t *pfns = range->pfns;
 	unsigned long i;
 
 	hmm_vma_walk->last = addr;
@@ -344,7 +344,7 @@ static int hmm_vma_walk_clear(unsigned long addr,
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
-	hmm_pfn_t *pfns = range->pfns;
+	uint64_t *pfns = range->pfns;
 	unsigned long i;
 
 	hmm_vma_walk->last = addr;
@@ -371,7 +371,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	struct vm_area_struct *vma = walk->vma;
-	hmm_pfn_t *pfns = range->pfns;
+	uint64_t *pfns = range->pfns;
 	unsigned long addr = start, i;
 	bool write_fault;
 	pte_t *ptep;
@@ -388,7 +388,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 
 	if (pmd_devmap(*pmdp) || pmd_trans_huge(*pmdp)) {
 		unsigned long pfn;
-		hmm_pfn_t flag = 0;
+		uint64_t flag = 0;
 		pmd_t pmd;
 
 		/*
@@ -413,7 +413,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		pfn = pmd_pfn(pmd) + pte_index(addr);
 		flag |= pmd_write(pmd) ? HMM_PFN_WRITE : 0;
 		for (; addr < end; addr += PAGE_SIZE, i++, pfn++)
-			pfns[i] = hmm_pfn_t_from_pfn(pfn) | flag;
+			pfns[i] = hmm_pfn_from_pfn(pfn) | flag;
 		return 0;
 	}
 
@@ -447,7 +447,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 			 * device and report anything else as error.
 			 */
 			if (is_device_private_entry(entry)) {
-				pfns[i] = hmm_pfn_t_from_pfn(swp_offset(entry));
+				pfns[i] = hmm_pfn_from_pfn(swp_offset(entry));
 				if (is_write_device_private_entry(entry)) {
 					pfns[i] |= HMM_PFN_WRITE;
 				} else if (write_fault)
@@ -472,7 +472,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		if (write_fault && !pte_write(pte))
 			goto fault;
 
-		pfns[i] = hmm_pfn_t_from_pfn(pte_pfn(pte));
+		pfns[i] = hmm_pfn_from_pfn(pte_pfn(pte));
 		pfns[i] |= pte_write(pte) ? HMM_PFN_WRITE : 0;
 		continue;
 
@@ -634,8 +634,8 @@ EXPORT_SYMBOL(hmm_vma_range_done);
  * This is similar to a regular CPU page fault except that it will not trigger
  * any memory migration if the memory being faulted is not accessible by CPUs.
  *
- * On error, for one virtual address in the range, the function will set the
- * hmm_pfn_t error flag for the corresponding pfn entry.
+ * On error, for one virtual address in the range, the function will mark the
+ * correspond HMM pfn entry with error flag.
  *
  * Expected use pattern:
  * retry:
-- 
2.14.3
