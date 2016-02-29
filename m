Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id A85A96B0260
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:45:34 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p65so71784058wmp.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:34 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id 199si20675429wmv.97.2016.02.29.06.45.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 06:45:33 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id l68so61609757wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:33 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 4/9] arm64: insn: avoid virt_to_page() translations on core kernel symbols
Date: Mon, 29 Feb 2016 15:44:39 +0100
Message-Id: <1456757084-1078-5-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net, Ard Biesheuvel <ard.biesheuvel@linaro.org>

Before restricting virt_to_page() to the linear mapping, ensure that
the text patching code does not use it to resolve references into the
core kernel text, which is mapped in the vmalloc area.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/kernel/insn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 7371455160e5..219d3a5df142 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -96,7 +96,7 @@ static void __kprobes *patch_map(void *addr, int fixmap)
 	if (module && IS_ENABLED(CONFIG_DEBUG_SET_MODULE_RONX))
 		page = vmalloc_to_page(addr);
 	else if (!module && IS_ENABLED(CONFIG_DEBUG_RODATA))
-		page = virt_to_page(addr);
+		page = pfn_to_page(__pa(addr) >> PAGE_SHIFT);
 	else
 		return addr;
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
