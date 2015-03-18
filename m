Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 470CF6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 11:16:49 -0400 (EDT)
Received: by qcbkw5 with SMTP id kw5so40786226qcb.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 08:16:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q41si16880507qkq.55.2015.03.18.08.16.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 08:16:48 -0700 (PDT)
Date: Wed, 18 Mar 2015 11:16:42 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] mm: don't count preallocated pmds
Message-ID: <alpine.LRH.2.02.1503181057340.14516@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-parisc@vger.kernel.org
Cc: jejb@parisc-linux.org, dave.anglin@bell.net

Hi

Here I'm sending a patch that fixes numerous "BUG: non-zero nr_pmds on 
freeing mm: -1" errors on 64-bit PA-RISC kernel.

I think the patch posted here 
http://www.spinics.net/lists/linux-parisc/msg05981.html is incorrect, it 
wouldn't work if the affected address range is freed and allocated 
multiple times.
	- 1. alloc pgd with built-in pmd, the count of pmds is 1
	- 2. free the range covered by the built-in pmd, the count of pmds 
		is 0, but the built-in pmd is still present
	- 3. alloc some memory in the range affected by the built-in pmd, 
		the count of pmds is still 0
	- 4. free the range covered by the built-in pmd, the counter 
		underflows to -1

Mikulas


From: Mikulas Patocka <mpatocka@redhat.com>

The patch dc6c9a35b66b520cf67e05d8ca60ebecad3b0479 that counts pmds 
allocated for a process introduced a bug on 64-bit PA-RISC kernels. There 
are many "BUG: non-zero nr_pmds on freeing mm: -1" messages.

The PA-RISC architecture preallocates one pmd with each pgd. This
preallocated pmd can never be freed - pmd_free does nothing when it is
called with this pmd. When the kernel attempts to free this preallocated
pmd, it decreases the count of allocated pmds. The result is that the
counter underflows and this error is reported.

This patch fixes the bug by introducing a macro pmd_preallocated and
making sure that the counter is not decremented when this preallocated pmd
is freed.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 arch/parisc/include/asm/pgalloc.h |    2 ++
 mm/memory.c                       |    5 ++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

Index: linux-4.0-rc4/arch/parisc/include/asm/pgalloc.h
===================================================================
--- linux-4.0-rc4.orig/arch/parisc/include/asm/pgalloc.h	2015-03-18 15:31:10.000000000 +0100
+++ linux-4.0-rc4/arch/parisc/include/asm/pgalloc.h	2015-03-18 15:33:20.000000000 +0100
@@ -81,6 +81,8 @@ static inline void pmd_free(struct mm_st
 	free_pages((unsigned long)pmd, PMD_ORDER);
 }
 
+#define pmd_preallocated(pmd)	(pmd_flag(*(pmd)) & PxD_FLAG_ATTACHED)
+
 #else
 
 /* Two Level Page Table Support for pmd's */
Index: linux-4.0-rc4/mm/memory.c
===================================================================
--- linux-4.0-rc4.orig/mm/memory.c	2015-03-18 15:30:42.000000000 +0100
+++ linux-4.0-rc4/mm/memory.c	2015-03-18 15:32:33.000000000 +0100
@@ -427,8 +427,11 @@ static inline void free_pmd_range(struct
 
 	pmd = pmd_offset(pud, start);
 	pud_clear(pud);
+#ifdef pmd_preallocated
+	if (!pmd_preallocated(pmd))
+#endif
+		mm_dec_nr_pmds(tlb->mm);
 	pmd_free_tlb(tlb, pmd, start);
-	mm_dec_nr_pmds(tlb->mm);
 }
 
 static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
