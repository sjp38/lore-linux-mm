Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7026B0261
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 10:46:28 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id 191so92694298wmq.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:28 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id r123si23808391wmb.8.2016.03.30.07.46.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 07:46:27 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id r72so102918303wmg.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:27 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 6/9] arm64: mm: restrict virt_to_page() to the linear mapping
Date: Wed, 30 Mar 2016 16:46:01 +0200
Message-Id: <1459349164-27175-7-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net
Cc: mark.rutland@arm.com, steve.capper@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>

Now that the vmemmap region has been redefined to cover the linear region
rather than the entire physical address space, we no longer need to
perform a virtual-to-physical translation in the implementaion of
virt_to_page(). This restricts virt_to_page() translations to the linear
region, so redefine virt_addr_valid() as well.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/include/asm/memory.h | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index 8a2ab195ca77..f412f502ccdd 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -208,9 +208,19 @@ static inline void *phys_to_virt(phys_addr_t x)
  */
 #define ARCH_PFN_OFFSET		((unsigned long)PHYS_PFN_OFFSET)
 
+#ifndef CONFIG_SPARSEMEM_VMEMMAP
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
-#define	virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
+#define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
+#else
+#define __virt_to_pgoff(kaddr)	(((u64)(kaddr) & ~PAGE_OFFSET) / PAGE_SIZE * sizeof(struct page))
+#define __page_to_voff(kaddr)	(((u64)(page) & ~VMEMMAP_START) * PAGE_SIZE / sizeof(struct page))
+
+#define page_to_virt(page)	((void *)((__page_to_voff(page)) | PAGE_OFFSET))
+#define virt_to_page(vaddr)	((struct page *)((__virt_to_pgoff(vaddr)) | VMEMMAP_START))
 
+#define virt_addr_valid(kaddr)	pfn_valid((((u64)(kaddr) & ~PAGE_OFFSET) \
+					   + PHYS_OFFSET) >> PAGE_SHIFT)
+#endif
 #endif
 
 #include <asm-generic/memory_model.h>
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
