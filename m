Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id C3C166B0253
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 10:46:19 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id 20so74632596wmh.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:19 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id b81si6381287wma.79.2016.03.30.07.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 07:46:18 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id 127so100540596wmu.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 07:46:18 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 2/9] arm64: mm: free __init memory via the linear mapping
Date: Wed, 30 Mar 2016 16:45:57 +0200
Message-Id: <1459349164-27175-3-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1459349164-27175-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net
Cc: mark.rutland@arm.com, steve.capper@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>

The implementation of free_initmem_default() expects __init_begin
and __init_end to be covered by the linear mapping, which is no
longer the case. So open code it instead, using addresses that are
explicitly translated from kernel virtual to linear virtual.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/mm/init.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 82ced5fa1e66..89376f3c65a3 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -452,7 +452,8 @@ void __init mem_init(void)
 
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
