Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C5A0A6B002C
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 11:50:36 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id a17so1949224qta.10
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 08:50:36 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y22si272574qka.437.2018.02.06.08.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 08:50:35 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w16GnODg036203
	for <linux-mm@kvack.org>; Tue, 6 Feb 2018 11:50:34 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fycyga9tt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Feb 2018 11:50:33 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 6 Feb 2018 16:50:28 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v7 04/24] mm: Dont assume page-table invariance during faults
Date: Tue,  6 Feb 2018 17:49:50 +0100
In-Reply-To: <1517935810-31177-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1517935810-31177-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1517935810-31177-5-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

From: Peter Zijlstra <peterz@infradead.org>

One of the side effects of speculating on faults (without holding
mmap_sem) is that we can race with free_pgtables() and therefore we
cannot assume the page-tables will stick around.

Remove the reliance on the pte pointer.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

In most of the case pte_unmap_same() was returning 1, which meaning that
do_swap_page() should do its processing. So in most of the case there will
be no impact.

Now regarding the case where pte_unmap_safe() was returning 0, and thus
do_swap_page return 0 too, this happens when the page has already been
swapped back. This may happen before do_swap_page() get called or while in
the call to do_swap_page(). In that later case, the check done when
swapin_readahead() returns will detect that case.

The worst case would be that a page fault is occuring on 2 threads at the
same time on the same swapped out page. In that case one thread will take
much time looping in __read_swap_cache_async(). But in the regular page
fault path, this is even worse since the thread would wait for semaphore to
be released before starting anything.

[Remove only if !CONFIG_SPECULATIVE_PAGE_FAULT]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index 5ec6433d6a5c..32b9eb77d95c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2288,6 +2288,7 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
+#ifndef CONFIG_SPECULATIVE_PAGE_FAULT
 /*
  * handle_pte_fault chooses page fault handler according to an entry which was
  * read non-atomically.  Before making any commitment, on those architectures
@@ -2311,6 +2312,7 @@ static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
 	pte_unmap(page_table);
 	return same;
 }
+#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
 
 static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
 {
@@ -2898,11 +2900,13 @@ int do_swap_page(struct vm_fault *vmf)
 		swapcache = page;
 	}
 
+#ifndef CONFIG_SPECULATIVE_PAGE_FAULT
 	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte)) {
 		if (page)
 			put_page(page);
 		goto out;
 	}
+#endif
 
 	entry = pte_to_swp_entry(vmf->orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
