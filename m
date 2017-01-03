Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0535E6B0266
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 12:22:13 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id 3so211211924qtr.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:22:13 -0800 (PST)
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com. [209.85.220.174])
        by mx.google.com with ESMTPS id c33si43175074qte.33.2017.01.03.09.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 09:22:12 -0800 (PST)
Received: by mail-qk0-f174.google.com with SMTP id n21so376092593qka.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:22:12 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv6 03/11] arm64: Move some macros under #ifndef __ASSEMBLY__
Date: Tue,  3 Jan 2017 09:21:45 -0800
Message-Id: <1483464113-1587-4-git-send-email-labbott@redhat.com>
In-Reply-To: <1483464113-1587-1-git-send-email-labbott@redhat.com>
References: <1483464113-1587-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org


Several macros for various x_to_y exist outside the bounds of an
__ASSEMBLY__ guard. Move them in preparation for support for
CONFIG_DEBUG_VIRTUAL.

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 arch/arm64/include/asm/memory.h | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index bfe6328..f80a8e4 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -102,25 +102,6 @@
 #endif
 
 /*
- * Physical vs virtual RAM address space conversion.  These are
- * private definitions which should NOT be used outside memory.h
- * files.  Use virt_to_phys/phys_to_virt/__pa/__va instead.
- */
-#define __virt_to_phys(x) ({						\
-	phys_addr_t __x = (phys_addr_t)(x);				\
-	__x & BIT(VA_BITS - 1) ? (__x & ~PAGE_OFFSET) + PHYS_OFFSET :	\
-				 (__x - kimage_voffset); })
-
-#define __phys_to_virt(x)	((unsigned long)((x) - PHYS_OFFSET) | PAGE_OFFSET)
-#define __phys_to_kimg(x)	((unsigned long)((x) + kimage_voffset))
-
-/*
- * Convert a page to/from a physical address
- */
-#define page_to_phys(page)	(__pfn_to_phys(page_to_pfn(page)))
-#define phys_to_page(phys)	(pfn_to_page(__phys_to_pfn(phys)))
-
-/*
  * Memory types available.
  */
 #define MT_DEVICE_nGnRnE	0
@@ -187,6 +168,25 @@ static inline unsigned long kaslr_offset(void)
 #define PHYS_PFN_OFFSET	(PHYS_OFFSET >> PAGE_SHIFT)
 
 /*
+ * Physical vs virtual RAM address space conversion.  These are
+ * private definitions which should NOT be used outside memory.h
+ * files.  Use virt_to_phys/phys_to_virt/__pa/__va instead.
+ */
+#define __virt_to_phys(x) ({						\
+	phys_addr_t __x = (phys_addr_t)(x);				\
+	__x & BIT(VA_BITS - 1) ? (__x & ~PAGE_OFFSET) + PHYS_OFFSET :	\
+				 (__x - kimage_voffset); })
+
+#define __phys_to_virt(x)	((unsigned long)((x) - PHYS_OFFSET) | PAGE_OFFSET)
+#define __phys_to_kimg(x)	((unsigned long)((x) + kimage_voffset))
+
+/*
+ * Convert a page to/from a physical address
+ */
+#define page_to_phys(page)	(__pfn_to_phys(page_to_pfn(page)))
+#define phys_to_page(phys)	(pfn_to_page(__phys_to_pfn(phys)))
+
+/*
  * Note: Drivers should NOT use these.  They are the wrong
  * translation for translating DMA addresses.  Use the driver
  * DMA support - see dma-mapping.h.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
