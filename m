Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id D1DF26B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 12:00:54 -0400 (EDT)
Received: by lbpo4 with SMTP id o4so25817476lbp.2
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 09:00:54 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id p7si12445780wij.5.2015.09.10.09.00.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 09:00:53 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so33978292wic.0
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 09:00:52 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH] mm/early_ioremap: add explicit #include of asm/early_ioremap.h
Date: Thu, 10 Sep 2015 18:00:48 +0200
Message-Id: <1441900848-18527-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, msalter@redhat.com
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>

Commit 6b0f68e32ea8 ("mm: add utility for early copy from unmapped
ram") introduces a function copy_from_early_mem() into mm/early_ioremap.c
which itself calls early_memremap()/early_memunmap(). However, since
early_memunmap() has not been declared yet at this point in the .c file,
nor by any explicitly included header files, we are depending on a
transitive include of asm/early_ioremap.h to declare it, which is fragile.

So instead, include this header explicitly.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---

I ran into this by accident when trying to enable to the generic ioremap
implementation for 32-bit ARM.

 mm/early_ioremap.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
index 23f744d77ce0..17ae14b5aefa 100644
--- a/mm/early_ioremap.c
+++ b/mm/early_ioremap.c
@@ -15,6 +15,7 @@
 #include <linux/mm.h>
 #include <linux/vmalloc.h>
 #include <asm/fixmap.h>
+#include <asm/early_ioremap.h>
 
 #ifdef CONFIG_MMU
 static int early_ioremap_debug __initdata;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
