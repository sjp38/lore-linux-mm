Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 813E56B0259
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:45:30 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l68so40026338wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:30 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id s204si5246362wmd.36.2016.02.29.06.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 06:45:29 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id n186so52744979wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:29 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 2/9] arm64: mm: free __init memory via the linear mapping
Date: Mon, 29 Feb 2016 15:44:37 +0100
Message-Id: <1456757084-1078-3-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net, Ard Biesheuvel <ard.biesheuvel@linaro.org>

The implementation of free_initmem_default() expects __init_begin
and __init_end to be covered by the linear mapping, which is no
longer the case. So open code it instead, using addresses that are
explicitly translated from kernel virtual to linear virtual.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/mm/init.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index a08153c99ffa..cebad6cceda8 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -416,7 +416,8 @@ void __init mem_init(void)
 
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_reserved_area(__va(__pa(__init_begin)), __va(__pa(__init_end)),
+			   0, "unused kernel");
 	fixup_init();
 }
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
