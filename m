Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF526B0010
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:06 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id f1so10011568plb.7
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3-v6si3772305pld.135.2018.02.04.17.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 23/64] mm: huge pagecache: do not check mmap_sem state
Date: Mon,  5 Feb 2018 02:27:13 +0100
Message-Id: <20180205012754.23615-24-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Davidlohr Bueso <dave@stgolabs.net>

*THIS IS A HACK*

By dropping the rwsem_is_locked checks in zap_pmd_range()
and zap_pud_range() we can avoid having to teach
file_operations about mmrange. For example in xfs:
iomap_dio_rw() is called by .read_iter file callbacks.

No-Yet-Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/memory.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 7c69674cd9da..598a8c69e3d3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1422,8 +1422,6 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 		next = pmd_addr_end(addr, end);
 		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
-				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
-				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
 				__split_huge_pmd(vma, pmd, addr, false, NULL);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;
@@ -1459,7 +1457,6 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 		next = pud_addr_end(addr, end);
 		if (pud_trans_huge(*pud) || pud_devmap(*pud)) {
 			if (next - addr != HPAGE_PUD_SIZE) {
-				VM_BUG_ON_VMA(!rwsem_is_locked(&tlb->mm->mmap_sem), vma);
 				split_huge_pud(vma, pud, addr);
 			} else if (zap_huge_pud(tlb, vma, pud, addr))
 				goto next;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
