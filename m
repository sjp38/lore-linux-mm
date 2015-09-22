Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B4B176B0258
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 06:36:56 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so6116550pac.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 03:36:56 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id wn10si1527793pab.97.2015.09.22.03.36.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 03:36:56 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH v2 11/12] ARCv2: mm: THP: Implement flush_pmd_tlb_range() optimization
Date: Tue, 22 Sep 2015 16:04:55 +0530
Message-ID: <1442918096-17454-12-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
References: <1442918096-17454-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vineet Gupta <Vineet.Gupta1@synopsys.com>

Implement the TLB flush routine to evict a sepcific Super TLB entry,
vs. moving to a new ASID on every such flush.

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/hugepage.h |  4 ++++
 arch/arc/mm/tlb.c               | 20 ++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/arch/arc/include/asm/hugepage.h b/arch/arc/include/asm/hugepage.h
index d7614d2af454..bf74f507e038 100644
--- a/arch/arc/include/asm/hugepage.h
+++ b/arch/arc/include/asm/hugepage.h
@@ -75,4 +75,8 @@ extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 #define __HAVE_ARCH_PGTABLE_WITHDRAW
 extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
 
+#define __HAVE_ARCH_FLUSH_PMD_TLB_RANGE
+extern void flush_pmd_tlb_range(struct vm_area_struct *vma, unsigned long start,
+				unsigned long end);
+
 #endif
diff --git a/arch/arc/mm/tlb.c b/arch/arc/mm/tlb.c
index 80e28555a5de..b28731c175b1 100644
--- a/arch/arc/mm/tlb.c
+++ b/arch/arc/mm/tlb.c
@@ -626,6 +626,26 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	return pgtable;
 }
 
+void flush_pmd_tlb_range(struct vm_area_struct *vma, unsigned long start,
+			 unsigned long end)
+{
+	unsigned int cpu;
+	unsigned long flags;
+
+	local_irq_save(flags);
+
+	cpu = smp_processor_id();
+
+	if (likely(asid_mm(vma->vm_mm, cpu) != MM_CTXT_NO_ASID)) {
+		unsigned int asid = hw_pid(vma->vm_mm, cpu);
+
+		/* No need to loop here: this will always be for 1 Huge Page */
+		tlb_entry_erase(start | _PAGE_HW_SZ | asid);
+	}
+
+	local_irq_restore(flags);
+}
+
 #endif
 
 /* Read the Cache Build Confuration Registers, Decode them and save into
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
