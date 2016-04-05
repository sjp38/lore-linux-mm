Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5366B0285
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 16:55:27 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bx7so1634570pad.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:55:27 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id lw14si1352347pab.202.2016.04.05.13.55.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 13:55:26 -0700 (PDT)
Received: by mail-pa0-x22f.google.com with SMTP id zm5so17824211pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:55:25 -0700 (PDT)
Date: Tue, 5 Apr 2016 13:55:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 09/10] huge pagecache: mmap_sem is unlocked when truncation
 splits pmd
In-Reply-To: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051352540.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Matthew Wilcox <willy@linux.intel.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

zap_pmd_range()'s CONFIG_DEBUG_VM !rwsem_is_locked(&mmap_sem) BUG()
will be invalid with huge pagecache, in whatever way it is implemented:
truncation of a hugely-mapped file to an unhugely-aligned size would
easily hit it.

(Although anon THP could in principle apply khugepaged to private file
mappings, which are not excluded by the MADV_HUGEPAGE restrictions, in
practice there's a vm_ops check which excludes them, so it never hits
this BUG() - there's no interface to "truncate" an anonymous mapping.)

We could complicate the test, to check i_mmap_rwsem also when there's a
vm_file; but my inclination was to make zap_pmd_range() more readable by
simply deleting this check.  A search has shown no report of the issue in
the years since commit e0897d75f0b2 ("mm, thp: print useful information
when mmap_sem is unlocked in zap_pmd_range") expanded it from VM_BUG_ON()
- though I cannot point to what commit I would say then fixed the issue.

But there are a couple of other patches now floating around, neither
yet in the tree: let's agree to retain the check as a VM_BUG_ON_VMA(),
as Matthew Wilcox has done; but subject to a vma_is_anonymous() check,
as Kirill Shutemov has done.  And let's get this in, without waiting
for any particular huge pagecache implementation to reach the tree.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/memory.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1182,15 +1182,8 @@ static inline unsigned long zap_pmd_rang
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
-#ifdef CONFIG_DEBUG_VM
-				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
-					pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
-						__func__, addr, end,
-						vma->vm_start,
-						vma->vm_end);
-					BUG();
-				}
-#endif
+				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
+				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
 				split_huge_pmd(vma, pmd, addr);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
