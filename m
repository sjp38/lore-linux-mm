Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 32E356B0253
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 05:06:18 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u98so1270804wrb.4
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 02:06:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b18si5133357edh.47.2017.11.03.02.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 02:06:16 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vA3943sK077850
	for <linux-mm@kvack.org>; Fri, 3 Nov 2017 05:06:15 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2e0hqfky48-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Nov 2017 05:06:15 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Fri, 3 Nov 2017 09:06:13 -0000
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] s390/mm: fix pud table accounting
Date: Fri,  3 Nov 2017 10:05:51 +0100
Message-Id: <20171103090551.18231-1-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-next@vger.kernel.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, Heiko Carstens <heiko.carstens@de.ibm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

With "mm: account pud page tables" and "mm: consolidate page table
accounting" pud page table accounting was introduced which now results
in tons of warnings like this one on s390:

BUG: non-zero pgtables_bytes on freeing mm: -16384

Reason for this are our run-time folded page tables: by default new
processes start with three page table levels where the allocated pgd
is the same as the first pud. In this case there won't ever be a pud
allocated and therefore mm_inc_nr_puds() will also never be called.

However when freeing the address space free_pud_range() will call
exactly once mm_dec_nr_puds() which leads to misaccounting.

Therefore call mm_inc_nr_puds() within init_new_context() to fix
this. This is the same like we have it already for processes that run
with two page table levels (aka compat processes).

While at it also adjust the comment, since there is no "mm->nr_pmds"
anymore.

Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/include/asm/mmu_context.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/s390/include/asm/mmu_context.h b/arch/s390/include/asm/mmu_context.h
index 3c9abedc323c..4f943d58cbac 100644
--- a/arch/s390/include/asm/mmu_context.h
+++ b/arch/s390/include/asm/mmu_context.h
@@ -43,6 +43,8 @@ static inline int init_new_context(struct task_struct *tsk,
 		mm->context.asce_limit = STACK_TOP_MAX;
 		mm->context.asce = __pa(mm->pgd) | _ASCE_TABLE_LENGTH |
 				   _ASCE_USER_BITS | _ASCE_TYPE_REGION3;
+		/* pgd_alloc() did not account this pud */
+		mm_inc_nr_puds(mm);
 		break;
 	case -PAGE_SIZE:
 		/* forked 5-level task, set new asce with new_mm->pgd */
@@ -58,7 +60,7 @@ static inline int init_new_context(struct task_struct *tsk,
 		/* forked 2-level compat task, set new asce with new mm->pgd */
 		mm->context.asce = __pa(mm->pgd) | _ASCE_TABLE_LENGTH |
 				   _ASCE_USER_BITS | _ASCE_TYPE_SEGMENT;
-		/* pgd_alloc() did not increase mm->nr_pmds */
+		/* pgd_alloc() did not account this pmd */
 		mm_inc_nr_pmds(mm);
 	}
 	crst_table_init((unsigned long *) mm->pgd, pgd_entry_type(mm));
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
