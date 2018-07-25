Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 927FC6B0003
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 15:42:04 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f91-v6so6106136plb.10
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 12:42:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j72-v6si14759344pfe.187.2018.07.25.12.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 12:42:03 -0700 (PDT)
Date: Wed, 25 Jul 2018 12:42:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv3 1/3] mm: Introduce vma_init()
Message-Id: <20180725124201.bcfec6827706fc87273f05bb@linux-foundation.org>
In-Reply-To: <20180725123924.g2yvgie2iz2txmek@kshutemo-mobl1>
References: <20180724121139.62570-1-kirill.shutemov@linux.intel.com>
	<20180724121139.62570-2-kirill.shutemov@linux.intel.com>
	<20180724130308.bbd46afc3703af4c5e1d6868@linux-foundation.org>
	<CA+55aFz1Vj3b2w-nOBdV5=WwsCYhSBprjPjGog6=_=q75Z5Z-w@mail.gmail.com>
	<20180724134158.676dfa7a4da16adbab3b851c@linux-foundation.org>
	<20180725123924.g2yvgie2iz2txmek@kshutemo-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 25 Jul 2018 15:39:24 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> There are few more:
> 
> arch/arm64/include/asm/tlb.h:   struct vm_area_struct vma = { .vm_mm = tlb->mm, };
> arch/arm64/mm/hugetlbpage.c:    struct vm_area_struct vma = { .vm_mm = mm };
> arch/arm64/mm/hugetlbpage.c:    struct vm_area_struct vma = { .vm_mm = mm };

I'n not understanding.  Your "mm: use vma_init() to initialize VMAs on
stack and data segments" addressed all those?

--- a/arch/arm64/include/asm/tlb.h~mm-use-vma_init-to-initialize-vmas-on-stack-and-data-segments
+++ a/arch/arm64/include/asm/tlb.h
@@ -37,7 +37,9 @@ static inline void __tlb_remove_table(vo
 
 static inline void tlb_flush(struct mmu_gather *tlb)
 {
-	struct vm_area_struct vma = { .vm_mm = tlb->mm, };
+	struct vm_area_struct vma;
+
+	vma_init(&vma, tlb->mm);
 
 	/*
 	 * The ASID allocator will either invalidate the ASID or mark
--- a/arch/arm64/mm/hugetlbpage.c~mm-use-vma_init-to-initialize-vmas-on-stack-and-data-segments
+++ a/arch/arm64/mm/hugetlbpage.c
@@ -108,11 +108,13 @@ static pte_t get_clear_flush(struct mm_s
 			     unsigned long pgsize,
 			     unsigned long ncontig)
 {
-	struct vm_area_struct vma = { .vm_mm = mm };
+	struct vm_area_struct vma;
 	pte_t orig_pte = huge_ptep_get(ptep);
 	bool valid = pte_valid(orig_pte);
 	unsigned long i, saddr = addr;
 
+	vma_init(&vma, mm);
+
 	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++) {
 		pte_t pte = ptep_get_and_clear(mm, addr, ptep);
 
@@ -145,9 +147,10 @@ static void clear_flush(struct mm_struct
 			     unsigned long pgsize,
 			     unsigned long ncontig)
 {
-	struct vm_area_struct vma = { .vm_mm = mm };
+	struct vm_area_struct vma;
 	unsigned long i, saddr = addr;
 
+	vma_init(&vma, mm);
 	for (i = 0; i < ncontig; i++, addr += pgsize, ptep++)
 		pte_clear(mm, addr, ptep);
 
