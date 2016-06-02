Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 786C26B0260
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 05:40:18 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w143so61664232oiw.3
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 02:40:18 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id 80si29563718oia.153.2016.06.02.02.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 02:40:17 -0700 (PDT)
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 2 Jun 2016 03:40:17 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 4/4] powerpc/mm/radix: Implement tlb mmu gather flush efficiently
Date: Thu,  2 Jun 2016 15:09:49 +0530
Message-Id: <1464860389-29019-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1464860389-29019-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1464860389-29019-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Now that we track page size in mmu_gather, we can use address based
tlbie format when doing a tlb_flush(). We don't do this if we are
invalidating the full address space.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/mm/tlb-radix.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/tlb-radix.c b/arch/powerpc/mm/tlb-radix.c
index 6f06b0b04d71..e581a521a87e 100644
--- a/arch/powerpc/mm/tlb-radix.c
+++ b/arch/powerpc/mm/tlb-radix.c
@@ -261,11 +261,37 @@ void radix__flush_tlb_range(struct vm_area_struct *vma, unsigned long start,
 }
 EXPORT_SYMBOL(radix__flush_tlb_range);
 
+static int radix_get_mmu_psize(int page_size)
+{
+	int psize;
+
+	if (page_size == (1UL << mmu_psize_defs[mmu_virtual_psize].shift))
+		psize = mmu_virtual_psize;
+	else if (page_size == (1UL << mmu_psize_defs[MMU_PAGE_2M].shift))
+		psize = MMU_PAGE_2M;
+	else if (page_size == (1UL << mmu_psize_defs[MMU_PAGE_1G].shift))
+		psize = MMU_PAGE_1G;
+	else
+		return -1;
+	return psize;
+}
 
 void radix__tlb_flush(struct mmu_gather *tlb)
 {
+	int psize = 0;
 	struct mm_struct *mm = tlb->mm;
-	radix__flush_tlb_mm(mm);
+	int page_size = tlb->page_size;
+
+	psize = radix_get_mmu_psize(page_size);
+	if (psize == -1)
+		/* unknown page size */
+		goto flush_mm;
+
+	if (!tlb->fullmm && !tlb->need_flush_all)
+		radix__flush_tlb_range_psize(mm, tlb->start, tlb->end, psize);
+	else
+flush_mm:
+		radix__flush_tlb_mm(mm);
 }
 /*
  * flush the page walk cache for the address
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
