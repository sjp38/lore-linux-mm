Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 725916B0037
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 10:27:37 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id u57so11888739wes.11
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 07:27:36 -0800 (PST)
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
        by mx.google.com with ESMTPS id wf8si14968542wjb.82.2014.02.18.07.27.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 07:27:35 -0800 (PST)
Received: by mail-wg0-f46.google.com with SMTP id x13so3355070wgg.13
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 07:27:35 -0800 (PST)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH 3/5] arm: mm: Make mmu_gather aware of huge pages
Date: Tue, 18 Feb 2014 15:27:13 +0000
Message-Id: <1392737235-27286-4-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1392737235-27286-1-git-send-email-steve.capper@linaro.org>
References: <1392737235-27286-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk, linux-mm@kvack.org
Cc: will.deacon@arm.com, catalin.marinas@arm.com, arnd@arndb.de, dsaxena@linaro.org, robherring2@gmail.com, Steve Capper <steve.capper@linaro.org>

Huge pages on short descriptors are arranged as pairs of 1MB sections.
We need to be careful and ensure that the TLBs for both sections are
flushed when we tlb_add_flush on a HugeTLB page.

This patch extends the tlb flush range to HPAGE_SIZE rather than
PAGE_SIZE when addresses belonging to huge page VMAs are added to
the flush range.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm/include/asm/tlb.h | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 0baf7f0..b2498e6 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -81,10 +81,17 @@ static inline void tlb_flush(struct mmu_gather *tlb)
 static inline void tlb_add_flush(struct mmu_gather *tlb, unsigned long addr)
 {
 	if (!tlb->fullmm) {
+		unsigned long size = PAGE_SIZE;
+
 		if (addr < tlb->range_start)
 			tlb->range_start = addr;
-		if (addr + PAGE_SIZE > tlb->range_end)
-			tlb->range_end = addr + PAGE_SIZE;
+
+		if (!config_enabled(CONFIG_ARM_LPAE) && tlb->vma
+				&& is_vm_hugetlb_page(tlb->vma))
+			size = HPAGE_SIZE;
+
+		if (addr + size > tlb->range_end)
+			tlb->range_end = addr + size;
 	}
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
