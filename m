Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 236FF6B025F
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 10:46:24 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id r72so102916173wmg.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:24 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id qs3si5601164wjc.230.2016.03.30.07.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 07:46:23 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id 191so92691279wmq.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:22 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 4/9] arm64: insn: avoid virt_to_page() translations on core kernel symbols
Date: Wed, 30 Mar 2016 16:45:59 +0200
Message-Id: <1459349164-27175-5-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net
Cc: mark.rutland@arm.com, steve.capper@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>

Before restricting virt_to_page() to the linear mapping, ensure that
the text patching code does not use it to resolve references into the
core kernel text, which is mapped in the vmalloc area.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/kernel/insn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 7371455160e5..368c08290dd8 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -96,7 +96,7 @@ static void __kprobes *patch_map(void *addr, int fixmap)
 	if (module && IS_ENABLED(CONFIG_DEBUG_SET_MODULE_RONX))
 		page = vmalloc_to_page(addr);
 	else if (!module && IS_ENABLED(CONFIG_DEBUG_RODATA))
-		page = virt_to_page(addr);
+		page = pfn_to_page(PHYS_PFN(__pa(addr)));
 	else
 		return addr;
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
