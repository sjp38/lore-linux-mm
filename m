Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7976B0266
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:53:10 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m6so5266382qtc.1
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 06:53:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x40si7449978qtj.258.2017.10.11.06.53.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 06:53:09 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9BDr2Bj119377
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:53:08 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dhhdrw46u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:53:08 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 11 Oct 2017 14:53:05 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v5 03/22] mm: Dont assume page-table invariance during faults
Date: Wed, 11 Oct 2017 15:52:27 +0200
In-Reply-To: <1507729966-10660-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1507729966-10660-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1507729966-10660-4-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

From: Peter Zijlstra <peterz@infradead.org>

One of the side effects of speculating on faults (without holding
mmap_sem) is that we can race with free_pgtables() and therefore we
cannot assume the page-tables will stick around.

Remove the reliance on the pte pointer.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>

[Remove only if !CONFIG_SPF]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index 6632c9b357c9..b7a9baf3df8a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2287,6 +2287,7 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
+#ifndef CONFIG_SPF
 /*
  * handle_pte_fault chooses page fault handler according to an entry which was
  * read non-atomically.  Before making any commitment, on those architectures
@@ -2296,7 +2297,7 @@ EXPORT_SYMBOL_GPL(apply_to_page_range);
  * and do_anonymous_page can safely check later on).
  */
 static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
-				pte_t *page_table, pte_t orig_pte)
+				 pte_t *page_table, pte_t orig_pte)
 {
 	int same = 1;
 #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
@@ -2310,6 +2311,7 @@ static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
 	pte_unmap(page_table);
 	return same;
 }
+#endif /* CONFIG_SPF */
 
 static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
 {
@@ -2871,11 +2873,14 @@ int do_swap_page(struct vm_fault *vmf)
 
 	if (vma_readahead)
 		page = swap_readahead_detect(vmf, &swap_ra);
+
+#ifndef CONFIG_SPF
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
