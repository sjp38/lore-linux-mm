Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52CFD8E0001
	for <linux-mm@kvack.org>; Tue, 25 Dec 2018 21:35:48 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id x125so19240656qka.17
        for <linux-mm@kvack.org>; Tue, 25 Dec 2018 18:35:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i188sor11088843qki.56.2018.12.25.18.35.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Dec 2018 18:35:47 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH -mmotm] efi: drop kmemleak_ignore() for page allocator
Date: Tue, 25 Dec 2018 21:35:34 -0500
Message-Id: <20181226023534.64048-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: ard.biesheuvel@linaro.org, catalin.marinas@arm.com, mingo@kernel.org, linux-mm@kvack.org, linux-efi@vger.kernel.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

a0fc5578f1d (efi: Let kmemleak ignore false positives) is no longer
needed due to efi_mem_reserve_persistent() uses __get_free_page()
instead where kmemelak is not able to track regardless. Otherwise,
kernel reported "kmemleak: Trying to color unknown object at
0xffff801060ef0000 as Black"

Signed-off-by: Qian Cai <cai@lca.pw>
---
 drivers/firmware/efi/efi.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index 7ac09dd8f268..4c46ff6f2242 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -31,7 +31,6 @@
 #include <linux/acpi.h>
 #include <linux/ucs2_string.h>
 #include <linux/memblock.h>
-#include <linux/kmemleak.h>
 
 #include <asm/early_ioremap.h>
 
@@ -1027,8 +1026,6 @@ int __ref efi_mem_reserve_persistent(phys_addr_t addr, u64 size)
 	if (!rsv)
 		return -ENOMEM;
 
-	kmemleak_ignore(rsv);
-
 	rsv->size = EFI_MEMRESERVE_COUNT(PAGE_SIZE);
 	atomic_set(&rsv->count, 1);
 	rsv->entry[0].base = addr;
-- 
2.17.2 (Apple Git-113)
