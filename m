Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id F00BA800C7
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 10:54:59 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id b14so81720489wmb.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 07:54:59 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id s72si13330683wmd.89.2016.01.06.07.54.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 07:54:58 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id l65so64251769wmf.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 07:54:58 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH] mm/kasan: map KASAN zero page read only
Date: Wed,  6 Jan 2016 16:54:47 +0100
Message-Id: <1452095687-18136-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, ryabinin.a.a@gmail.com, catalin.marinas@arm.com, mingo@kernel.org
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>

The original x86_64-only version of KASAN mapped its zero page
read-only, but this got lost when the code was generalised and
ported to arm64, since, at the time, the PAGE_KERNEL_RO define
did not exist. It has been added to arm64 in the mean time, so
let's use it.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 mm/kasan/kasan_init.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 3f9a41cf0ac6..8726a92604ad 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -49,7 +49,7 @@ static void __init zero_pte_populate(pmd_t *pmd, unsigned long addr,
 	pte_t *pte = pte_offset_kernel(pmd, addr);
 	pte_t zero_pte;
 
-	zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL);
+	zero_pte = pfn_pte(PFN_DOWN(__pa(kasan_zero_page)), PAGE_KERNEL_RO);
 	zero_pte = pte_wrprotect(zero_pte);
 
 	while (addr + PAGE_SIZE <= end) {
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
