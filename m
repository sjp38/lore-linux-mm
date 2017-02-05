Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 171ED6B0261
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 11:14:34 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id i34so31200047qkh.6
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 08:14:34 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id f187si23319099qke.70.2017.02.05.08.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Feb 2017 08:14:33 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in zap_pmd_range()
Date: Sun,  5 Feb 2017 11:12:41 -0500
Message-Id: <20170205161252.85004-4-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-1-zi.yan@sent.com>
References: <20170205161252.85004-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, Zi Yan <ziy@nvidia.com>

From: Zi Yan <ziy@nvidia.com>

Originally, zap_pmd_range() checks pmd value without taking pmd lock.
This can cause pmd_protnone entry not being freed.

Because there are two steps in changing a pmd entry to a pmd_protnone
entry. First, the pmd entry is cleared to a pmd_none entry, then,
the pmd_none entry is changed into a pmd_protnone entry.
The racy check, even with barrier, might only see the pmd_none entry
in zap_pmd_range(), thus, the mapping is neither split nor zapped.

Later, in free_pmd_range(), pmd_none_or_clear() will see the
pmd_protnone entry and clear it as a pmd_bad entry. Furthermore,
since the pmd_protnone entry is not properly freed, the corresponding
deposited pte page table is not freed either.

This causes memory leak or kernel crashing, if VM_BUG_ON() is enabled.

This patch relies on __split_huge_pmd_locked() and
__zap_huge_pmd_locked().

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/memory.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 3929b015faf7..7cfdd5208ef5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1233,33 +1233,31 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 				struct zap_details *details)
 {
 	pmd_t *pmd;
+	spinlock_t *ptl;
 	unsigned long next;
 
 	pmd = pmd_offset(pud, addr);
+	ptl = pmd_lock(vma->vm_mm, pmd);
 	do {
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
 				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
 				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
-				__split_huge_pmd(vma, pmd, addr, false, NULL);
-			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
-				goto next;
+				__split_huge_pmd_locked(vma, pmd, addr, false);
+			} else if (__zap_huge_pmd_locked(tlb, vma, pmd, addr))
+				continue;
 			/* fall through */
 		}
-		/*
-		 * Here there can be other concurrent MADV_DONTNEED or
-		 * trans huge page faults running, and if the pmd is
-		 * none or trans huge it can change under us. This is
-		 * because MADV_DONTNEED holds the mmap_sem in read
-		 * mode.
-		 */
-		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
-			goto next;
+
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		spin_unlock(ptl);
 		next = zap_pte_range(tlb, vma, pmd, addr, next, details);
-next:
 		cond_resched();
+		spin_lock(ptl);
 	} while (pmd++, addr = next, addr != end);
+	spin_unlock(ptl);
 
 	return addr;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
