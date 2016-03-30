Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id DC0766B007E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 10:46:17 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id p65so75386321wmp.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:17 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id b144si23776828wmd.54.2016.03.30.07.46.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 07:46:16 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id p65so186617345wmp.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:16 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 1/9] arm64: vdso: avoid virt_to_page() translations on kernel symbols
Date: Wed, 30 Mar 2016 16:45:56 +0200
Message-Id: <1459349164-27175-2-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net
Cc: mark.rutland@arm.com, steve.capper@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>

The translation performed by virt_to_page() is only valid for linear
addresses, and kernel symbols are no longer in the linear mapping.
So perform the __pa() translation explicitly, which does the right
thing in either case, and only then translate to a struct page offset.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/kernel/vdso.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/kernel/vdso.c b/arch/arm64/kernel/vdso.c
index 97bc68f4c689..64fc030be0f2 100644
--- a/arch/arm64/kernel/vdso.c
+++ b/arch/arm64/kernel/vdso.c
@@ -131,11 +131,11 @@ static int __init vdso_init(void)
 		return -ENOMEM;
 
 	/* Grab the vDSO data page. */
-	vdso_pagelist[0] = virt_to_page(vdso_data);
+	vdso_pagelist[0] = pfn_to_page(PHYS_PFN(__pa(vdso_data)));
 
 	/* Grab the vDSO code pages. */
 	for (i = 0; i < vdso_pages; i++)
-		vdso_pagelist[i + 1] = virt_to_page(&vdso_start + i * PAGE_SIZE);
+		vdso_pagelist[i + 1] = pfn_to_page(PHYS_PFN(__pa(&vdso_start)) + i);
 
 	/* Populate the special mapping structures */
 	vdso_spec[0] = (struct vm_special_mapping) {
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
