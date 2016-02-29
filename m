Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D95F86B0258
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:45:28 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p65so71779867wmp.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:28 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id d9si32477425wjr.170.2016.02.29.06.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 06:45:27 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id l68so40024310wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:27 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 1/9] arm64: vdso: avoid virt_to_page() translations on kernel symbols
Date: Mon, 29 Feb 2016 15:44:36 +0100
Message-Id: <1456757084-1078-2-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net, Ard Biesheuvel <ard.biesheuvel@linaro.org>

The translation performed by virt_to_page() is only valid for linear
addresses, and kernel symbols are no longer in the linear mapping.
So perform the __pa() translation explicitly, which does the right
thing in either case, and only then translate to a struct page offset.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/kernel/vdso.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/kernel/vdso.c b/arch/arm64/kernel/vdso.c
index 97bc68f4c689..fb3c17f031aa 100644
--- a/arch/arm64/kernel/vdso.c
+++ b/arch/arm64/kernel/vdso.c
@@ -131,11 +131,12 @@ static int __init vdso_init(void)
 		return -ENOMEM;
 
 	/* Grab the vDSO data page. */
-	vdso_pagelist[0] = virt_to_page(vdso_data);
+	vdso_pagelist[0] = pfn_to_page(__pa(vdso_data) >> PAGE_SHIFT);
 
 	/* Grab the vDSO code pages. */
-	for (i = 0; i < vdso_pages; i++)
-		vdso_pagelist[i + 1] = virt_to_page(&vdso_start + i * PAGE_SIZE);
+	vdso_pagelist[1] = pfn_to_page(__pa(&vdso_start) >> PAGE_SHIFT);
+	for (i = 1; i < vdso_pages; i++)
+		vdso_pagelist[i + 1] = vdso_pagelist[1] + i;
 
 	/* Populate the special mapping structures */
 	vdso_spec[0] = (struct vm_special_mapping) {
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
