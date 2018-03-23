Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C599D6B0261
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 20:55:55 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id i193so6591895qke.18
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 17:55:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a187si4814595qkb.222.2018.03.22.17.55.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 17:55:54 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 13/15] mm/hmm: factor out pte and pmd handling to simplify hmm_vma_walk_pmd() v2
Date: Thu, 22 Mar 2018 20:55:25 -0400
Message-Id: <20180323005527.758-14-jglisse@redhat.com>
In-Reply-To: <20180323005527.758-1-jglisse@redhat.com>
References: <20180323005527.758-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

No functional change, just create one function to handle pmd and one
to handle pte (hmm_vma_handle_pmd() and hmm_vma_handle_pte()).

Changed since v1:
  - s/pfns/pfn for pte as in that case we are dealing with a single pfn

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
---
 mm/hmm.c | 174 +++++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 102 insertions(+), 72 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 05b49a5d6674..2cc4dda1fd2e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -375,6 +375,99 @@ static int hmm_vma_walk_hole(unsigned long addr,
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
+			      uint64_t *pfn)
+{
+	struct hmm_vma_walk *hmm_vma_walk = walk->private;
+	struct vm_area_struct *vma = walk->vma;
+	pte_t pte = *ptep;
+
+	*pfn = 0;
+
+	if (pte_none(pte)) {
+		*pfn = 0;
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
+			*pfn = hmm_pfn_from_pfn(swp_offset(entry));
+			if (is_write_device_private_entry(entry)) {
+				*pfn |= HMM_PFN_WRITE;
+			} else if ((hmm_vma_walk->fault & hmm_vma_walk->write))
+				goto fault;
+			*pfn |= HMM_PFN_DEVICE_PRIVATE;
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
+		*pfn = HMM_PFN_ERROR;
+		return -EFAULT;
+	}
+
+	if ((hmm_vma_walk->fault & hmm_vma_walk->write) && !pte_write(pte))
+		goto fault;
+
+	*pfn = hmm_pfn_from_pfn(pte_pfn(pte));
+	*pfn |= pte_write(pte) ? HMM_PFN_WRITE : 0;
+	return 0;
+
+fault:
+	pte_unmap(ptep);
+	/* Fault any virtual address we were asked to fault */
+	return hmm_vma_walk_hole(addr, end, walk);
+}
+
 static int hmm_vma_walk_pmd(pmd_t *pmdp,
 			    unsigned long start,
 			    unsigned long end,
@@ -382,25 +475,20 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
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
@@ -416,17 +504,8 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		barrier();
 		if (!pmd_devmap(pmd) && !pmd_trans_huge(pmd))
 			goto again;
-		if (pmd_protnone(pmd))
-			return hmm_vma_walk_hole(start, end, walk);
-
-		if (write_fault && !pmd_write(pmd))
-			return hmm_vma_walk_hole(start, end, walk);
 
-		pfn = pmd_pfn(pmd) + pte_index(addr);
-		flag |= pmd_write(pmd) ? HMM_PFN_WRITE : 0;
-		for (; addr < end; addr += PAGE_SIZE, i++, pfn++)
-			pfns[i] = hmm_pfn_from_pfn(pfn) | flag;
-		return 0;
+		return hmm_vma_handle_pmd(walk, addr, end, &pfns[i], pmd);
 	}
 
 	if (pmd_bad(*pmdp))
@@ -434,67 +513,18 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 
 	ptep = pte_offset_map(pmdp, addr);
 	for (; addr < end; addr += PAGE_SIZE, ptep++, i++) {
-		pte_t pte = *ptep;
-
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
+		int r;
 
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
-		/* Fault any virtual address we were asked to fault */
-		return hmm_vma_walk_hole(start, end, walk);
 	}
 	pte_unmap(ptep - 1);
 
+	hmm_vma_walk->last = addr;
 	return 0;
 }
 
-- 
2.14.3
