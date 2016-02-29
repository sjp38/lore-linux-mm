Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7126F6B025B
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:45:32 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id n186so52747431wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:32 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id as5si32581113wjc.15.2016.02.29.06.45.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 06:45:31 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id p65so48532150wmp.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:31 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 3/9] arm64: mm: avoid virt_to_page() translation for the zero page
Date: Mon, 29 Feb 2016 15:44:38 +0100
Message-Id: <1456757084-1078-4-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net, Ard Biesheuvel <ard.biesheuvel@linaro.org>

The zero page is statically allocated, so grab its struct page pointer
without using virt_to_page(), which will be restricted to the linear
mapping later.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/include/asm/pgtable.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 7d0a9eab1133..af80e437d075 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -57,7 +57,7 @@ extern void __pgd_error(const char *file, int line, unsigned long val);
  * for zero-mapped memory areas etc..
  */
 extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
-#define ZERO_PAGE(vaddr)	virt_to_page(empty_zero_page)
+#define ZERO_PAGE(vaddr)	pfn_to_page(__pa(empty_zero_page) >> PAGE_SHIFT)
 
 #define pte_ERROR(pte)		__pte_error(__FILE__, __LINE__, pte_val(pte))
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
