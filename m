Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC2CE6B0022
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 22:00:48 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id t27so46323qki.11
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:00:48 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x47si775916qta.143.2018.03.19.19.00.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 19:00:47 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 10/15] mm/hmm: do not differentiate between empty entry or missing directory v2
Date: Mon, 19 Mar 2018 22:00:32 -0400
Message-Id: <20180320020038.3360-11-jglisse@redhat.com>
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

There is no point in differentiating between a range for which there
is not even a directory (and thus entries) and empty entry (pte_none()
or pmd_none() returns true).

Simply drop the distinction ie remove HMM_PFN_EMPTY flag and merge now
duplicate hmm_vma_walk_hole() and hmm_vma_walk_clear() functions.

Changed since v1:
  - Improved comments

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h |  8 +++-----
 mm/hmm.c            | 45 +++++++++++++++------------------------------
 2 files changed, 18 insertions(+), 35 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 54d684fe3b90..cf283db22106 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -84,7 +84,6 @@ struct hmm;
  * HMM_PFN_VALID: pfn is valid. It has, at least, read permission.
  * HMM_PFN_WRITE: CPU page table has write permission set
  * HMM_PFN_ERROR: corresponding CPU page table entry points to poisoned memory
- * HMM_PFN_EMPTY: corresponding CPU page table entry is pte_none()
  * HMM_PFN_SPECIAL: corresponding CPU page table entry is special; i.e., the
  *      result of vm_insert_pfn() or vm_insert_page(). Therefore, it should not
  *      be mirrored by a device, because the entry will never have HMM_PFN_VALID
@@ -94,10 +93,9 @@ struct hmm;
 #define HMM_PFN_VALID (1 << 0)
 #define HMM_PFN_WRITE (1 << 1)
 #define HMM_PFN_ERROR (1 << 2)
-#define HMM_PFN_EMPTY (1 << 3)
-#define HMM_PFN_SPECIAL (1 << 4)
-#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 5)
-#define HMM_PFN_SHIFT 6
+#define HMM_PFN_SPECIAL (1 << 3)
+#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 4)
+#define HMM_PFN_SHIFT 5
 
 /*
  * hmm_pfn_to_page() - return struct page pointed to by a valid HMM pfn
diff --git a/mm/hmm.c b/mm/hmm.c
index 2df69a95c5ab..52204037ad84 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -324,6 +324,16 @@ static void hmm_pfns_clear(uint64_t *pfns,
 		*pfns = 0;
 }
 
+/*
+ * hmm_vma_walk_hole() - handle a range lacking valid pmd or pte(s)
+ * @start: range virtual start address (inclusive)
+ * @end: range virtual end address (exclusive)
+ * @walk: mm_walk structure
+ * Returns: 0 on success, -EAGAIN after page fault, or page fault error
+ *
+ * This function will be called whenever pmd_none() or pte_none() returns true,
+ * or whenever there is no page directory covering the virtual address range.
+ */
 static int hmm_vma_walk_hole(unsigned long addr,
 			     unsigned long end,
 			     struct mm_walk *walk)
@@ -333,31 +343,6 @@ static int hmm_vma_walk_hole(unsigned long addr,
 	uint64_t *pfns = range->pfns;
 	unsigned long i;
 
-	hmm_vma_walk->last = addr;
-	i = (addr - range->start) >> PAGE_SHIFT;
-	for (; addr < end; addr += PAGE_SIZE, i++) {
-		pfns[i] = HMM_PFN_EMPTY;
-		if (hmm_vma_walk->fault) {
-			int ret;
-
-			ret = hmm_vma_do_fault(walk, addr, &pfns[i]);
-			if (ret != -EAGAIN)
-				return ret;
-		}
-	}
-
-	return hmm_vma_walk->fault ? -EAGAIN : 0;
-}
-
-static int hmm_vma_walk_clear(unsigned long addr,
-			      unsigned long end,
-			      struct mm_walk *walk)
-{
-	struct hmm_vma_walk *hmm_vma_walk = walk->private;
-	struct hmm_range *range = hmm_vma_walk->range;
-	uint64_t *pfns = range->pfns;
-	unsigned long i;
-
 	hmm_vma_walk->last = addr;
 	i = (addr - range->start) >> PAGE_SHIFT;
 	for (; addr < end; addr += PAGE_SIZE, i++) {
@@ -416,10 +401,10 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		if (!pmd_devmap(pmd) && !pmd_trans_huge(pmd))
 			goto again;
 		if (pmd_protnone(pmd))
-			return hmm_vma_walk_clear(start, end, walk);
+			return hmm_vma_walk_hole(start, end, walk);
 
 		if (write_fault && !pmd_write(pmd))
-			return hmm_vma_walk_clear(start, end, walk);
+			return hmm_vma_walk_hole(start, end, walk);
 
 		pfn = pmd_pfn(pmd) + pte_index(addr);
 		flag |= pmd_write(pmd) ? HMM_PFN_WRITE : 0;
@@ -438,7 +423,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		pfns[i] = 0;
 
 		if (pte_none(pte)) {
-			pfns[i] = HMM_PFN_EMPTY;
+			pfns[i] = 0;
 			if (hmm_vma_walk->fault)
 				goto fault;
 			continue;
@@ -489,8 +474,8 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 
 fault:
 		pte_unmap(ptep);
-		/* Fault all pages in range */
-		return hmm_vma_walk_clear(start, end, walk);
+		/* Fault any virtual address we were ask to fault */
+		return hmm_vma_walk_hole(start, end, walk);
 	}
 	pte_unmap(ptep - 1);
 
-- 
2.14.3
