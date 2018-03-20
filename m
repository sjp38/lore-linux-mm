Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E83C6B0026
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 22:00:50 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id t27so46388qki.11
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:00:50 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 132si1238138qkg.459.2018.03.19.19.00.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 19:00:49 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 13/15] mm/hmm: factor out pte and pmd handling to simplify hmm_vma_walk_pmd()
Date: Mon, 19 Mar 2018 22:00:35 -0400
Message-Id: <20180320020038.3360-14-jglisse@redhat.com>
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

No functional change, just create one function to handle pmd and one
to handle pte (hmm_vma_handle_pmd() and hmm_vma_handle_pte()).

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/hmm.c | 174 +++++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 102 insertions(+), 72 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 52cdceb35733..dc703e9c3a95 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -351,6 +351,99 @@ static int hmm_vma_walk_hole(unsigned long addr,
 	return hmm_vma_walk->fault ? -EAGAIN : 0;
 }
 
+static int hmm_vma_handle_pmd(struct mm_walk *walk,
+			      unsigned long addr,
+			      unsigned long end,
+			      uint64_t *pfns,
+			      pmd_t pmd)
+{
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	unsigned long pfn, i;
+	uint64_t flag = 0;
+
+	if (pmd_protnone(pmd))
+		return hmm_vma_walk_hole(addr, end, walk);
+
+	if ((hmm_vma_walk->fault & hmm_vma_walk->write) && !pmd_write(pmd))
+		return hmm_vma_walk_hole(addr, end, walk);
+
+	pfn = pmd_pfn(pmd) + pte_index(addr);
+	flag |= pmd_write(pmd) ? HMM_PFN_WRITE : 0;
+	for (i = 0; addr < end; addr += PAGE_SIZE, i++, pfn++)
+		pfns[i] = hmm_pfn_from_pfn(pfn) | flag;
+	hmm_vma_walk->last = end;
+	return 0;
+}
+
+static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
+			      unsigned long end, pmd_t *pmdp, pte_t *ptep,
+			      uint64_t *pfns)
+{
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct vm_area_struct *vma = walk->vma;
+	pte_t pte = *ptep;
+
+	*pfns = 0;
+
+	if (pte_none(pte)) {
+		*pfns = 0;
+		if (hmm_vma_walk->fault)
+			goto fault;
+		return 0;
+	}
+
+	if (!pte_present(pte)) {
+		swp_entry_t entry = pte_to_swp_entry(pte);
+
+		if (!non_swap_entry(entry)) {
+			if (hmm_vma_walk->fault)
+				goto fault;
+			return 0;
+		}
+
+		/*
+		 * This is a special swap entry, ignore migration, use
+		 * device and report anything else as error.
+		 */
+		if (is_device_private_entry(entry)) {
+			*pfns = hmm_pfn_from_pfn(swp_offset(entry));
+			if (is_write_device_private_entry(entry)) {
+				*pfns |= HMM_PFN_WRITE;
+			} else if ((hmm_vma_walk->fault & hmm_vma_walk->write))
+				goto fault;
+			*pfns |= HMM_PFN_DEVICE_PRIVATE;
+			return 0;
+		}
+
+		if (is_migration_entry(entry)) {
+			if (hmm_vma_walk->fault) {
+				pte_unmap(ptep);
+				hmm_vma_walk->last = addr;
+				migration_entry_wait(vma->vm_mm,
+						pmdp, addr);
+				return -EAGAIN;
+			}
+			return 0;
+		}
+
+		/* Report error for everything else */
+		*pfns = HMM_PFN_ERROR;
+		return -EFAULT;
+	}
+
+	if ((hmm_vma_walk->fault & hmm_vma_walk->write) && !pte_write(pte))
+		goto fault;
+
+	*pfns = hmm_pfn_from_pfn(pte_pfn(pte));
+	*pfns |= pte_write(pte) ? HMM_PFN_WRITE : 0;
+	return 0;
+
+fault:
+	pte_unmap(ptep);
+	/* Fault any virtual address we were ask to fault */
+	return hmm_vma_walk_hole(addr, end, walk);
+}
+
 static int hmm_vma_walk_pmd(pmd_t *pmdp,
 			    unsigned long start,
 			    unsigned long end,
@@ -358,25 +451,20 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 {
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
-	struct vm_area_struct *vma = walk->vma;
 	uint64_t *pfns = range->pfns;
 	unsigned long addr = start, i;
-	bool write_fault;
 	pte_t *ptep;
 
 	i = (addr - range->start) >> PAGE_SHIFT;
-	write_fault = hmm_vma_walk->fault & hmm_vma_walk->write;
 
 again:
 	if (pmd_none(*pmdp))
 		return hmm_vma_walk_hole(start, end, walk);
 
-	if (pmd_huge(*pmdp) && vma->vm_flags & VM_HUGETLB)
+	if (pmd_huge(*pmdp) && (range->vma->vm_flags & VM_HUGETLB))
 		return hmm_pfns_bad(start, end, walk);
 
 	if (pmd_devmap(*pmdp) || pmd_trans_huge(*pmdp)) {
-		unsigned long pfn;
-		uint64_t flag = 0;
 		pmd_t pmd;
 
 		/*
@@ -392,17 +480,8 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		barrier();
 		if (!pmd_devmap(pmd) && !pmd_trans_huge(pmd))
 			goto again;
-		if (pmd_protnone(pmd))
-			return hmm_vma_walk_hole(start, end, walk);
 
-		if (write_fault && !pmd_write(pmd))
-			return hmm_vma_walk_hole(start, end, walk);
-
-		pfn = pmd_pfn(pmd) + pte_index(addr);
-		flag |= pmd_write(pmd) ? HMM_PFN_WRITE : 0;
-		for (; addr < end; addr += PAGE_SIZE, i++, pfn++)
-			pfns[i] = hmm_pfn_from_pfn(pfn) | flag;
-		return 0;
+		return hmm_vma_handle_pmd(walk, addr, end, &pfns[i], pmd);
 	}
 
 	if (pmd_bad(*pmdp))
@@ -410,67 +489,18 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 
 	ptep = pte_offset_map(pmdp, addr);
 	for (; addr < end; addr += PAGE_SIZE, ptep++, i++) {
-		pte_t pte = *ptep;
+		int r;
 
-		pfns[i] = 0;
-
-		if (pte_none(pte)) {
-			pfns[i] = 0;
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
-
-			/*
-			 * This is a special swap entry, ignore migration, use
-			 * device and report anything else as error.
-			 */
-			if (is_device_private_entry(entry)) {
-				pfns[i] = hmm_pfn_from_pfn(swp_offset(entry));
-				if (is_write_device_private_entry(entry)) {
-					pfns[i] |= HMM_PFN_WRITE;
-				} else if (write_fault)
-					goto fault;
-				pfns[i] |= HMM_PFN_DEVICE_PRIVATE;
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
+		r = hmm_vma_handle_pte(walk, addr, end, pmdp, ptep, &pfns[i]);
+		if (r) {
+			/* hmm_vma_handle_pte() did unmap pte directory */
+			hmm_vma_walk->last = addr;
+			return r;
 		}
-
-		if (write_fault && !pte_write(pte))
-			goto fault;
-
-		pfns[i] = hmm_pfn_from_pfn(pte_pfn(pte));
-		pfns[i] |= pte_write(pte) ? HMM_PFN_WRITE : 0;
-		continue;
-
-fault:
-		pte_unmap(ptep);
-		/* Fault any virtual address we were ask to fault */
-		return hmm_vma_walk_hole(start, end, walk);
 	}
 	pte_unmap(ptep - 1);
 
+	hmm_vma_walk->last = addr;
 	return 0;
 }
 
-- 
2.14.3
