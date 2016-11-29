Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4CC6B0269
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:56:01 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id 41so116138088qtn.7
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:56:01 -0800 (PST)
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com. [209.85.220.178])
        by mx.google.com with ESMTPS id o63si35578013qkc.253.2016.11.29.10.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 10:56:00 -0800 (PST)
Received: by mail-qk0-f178.google.com with SMTP id x190so184730097qkb.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:56:00 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv4 08/10] mm/kasan: Switch to using __pa_symbol and lm_alias
Date: Tue, 29 Nov 2016 10:55:27 -0800
Message-Id: <1480445729-27130-9-git-send-email-labbott@redhat.com>
In-Reply-To: <1480445729-27130-1-git-send-email-labbott@redhat.com>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com

__pa_symbol is the correct API to find the physical address of symbols.
Switch to it to allow for debugging APIs to work correctly. Other
functions such as p*d_populate may call __pa internally. Ensure that the
address passed is in the linear region by calling lm_alias.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
Pointed out during review/testing of v3.
---
 mm/kasan/kasan_init.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 3f9a41c..ff04721 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -49,7 +49,7 @@ static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
 	pte_t *pte = pte_offset_kernel(pmd, addr);
 	pte_t zero_pte;
 
-	zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
+	zero_pte = pfn_pte(PFN_DOWN(__pa_symbol(kasan_zero_page)), PAGE_KERNEL);
 	zero_pte = pte_wrprotect(zero_pte);
 
 	while (addr + PAGE_SIZE <= end) {
@@ -69,7 +69,7 @@ static void __init zero_pmd_populate(pud_t *pud, unsigned long addr,
 		next = pmd_addr_end(addr, end);
 
 		if (IS_ALIGNED(addr, PMD_SIZE) && end - addr >= PMD_SIZE) {
-			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
+			pmd_populate_kernel(&init_mm, pmd, lm_alias(kasan_zero_pte));
 			continue;
 		}
 
@@ -94,7 +94,7 @@ static void __init zero_pud_populate(pgd_t *pgd, unsigned long addr,
 
 			pud_populate(&init_mm, pud, kasan_zero_pmd);
 			pmd = pmd_offset(pud, addr);
-			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
+			pmd_populate_kernel(&init_mm, pmd, lm_alias(kasan_zero_pte));
 			continue;
 		}
 
@@ -135,11 +135,11 @@ void __init kasan_populate_zero_shadow(const void *shadow_start,
 			 * puds,pmds, so pgd_populate(), pud_populate()
 			 * is noops.
 			 */
-			pgd_populate(&init_mm, pgd, kasan_zero_pud);
+			pgd_populate(&init_mm, pgd, lm_alias(kasan_zero_pud));
 			pud = pud_offset(pgd, addr);
-			pud_populate(&init_mm, pud, kasan_zero_pmd);
+			pud_populate(&init_mm, pud, lm_alias(kasan_zero_pmd));
 			pmd = pmd_offset(pud, addr);
-			pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
+			pmd_populate_kernel(&init_mm, pmd, lm_alias(kasan_zero_pte));
 			continue;
 		}
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
