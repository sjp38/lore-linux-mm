Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 761436B0256
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:07:00 -0500 (EST)
Received: by wmww144 with SMTP id w144so86926922wmw.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:07:00 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id pm2si10393400wjb.168.2015.11.23.01.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 01:06:59 -0800 (PST)
Received: by wmww144 with SMTP id w144so95198018wmw.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:06:59 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v3 03/13] arm64/efi: mark UEFI reserved regions as MEMBLOCK_NOMAP
Date: Mon, 23 Nov 2015 10:06:23 +0100
Message-Id: <1448269593-20758-4-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, matt@codeblueprint.co.uk
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

Change the EFI memory reservation logic to use memblock_mark_nomap()
rather than memblock_reserve() to mark UEFI reserved regions as
occupied. In addition to reserving them against allocations done by
memblock, this will also prevent them from being covered by the linear
mapping.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/kernel/efi.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/kernel/efi.c b/arch/arm64/kernel/efi.c
index 3aeb576965c0..d746d15c882f 100644
--- a/arch/arm64/kernel/efi.c
+++ b/arch/arm64/kernel/efi.c
@@ -187,7 +187,7 @@ static __init void reserve_regions(void)
 			early_init_dt_add_memory_arch(paddr, size);
 
 		if (is_reserve_region(md)) {
-			memblock_reserve(paddr, size);
+			memblock_mark_nomap(paddr, size);
 			if (efi_enabled(EFI_DBG))
 				pr_cont("*");
 		}
@@ -209,8 +209,6 @@ void __init efi_init(void)
 
 	efi_system_table = params.system_table;
 
-	memblock_reserve(params.mmap & PAGE_MASK,
-			 PAGE_ALIGN(params.mmap_size + (params.mmap & ~PAGE_MASK)));
 	memmap.phys_map = params.mmap;
 	memmap.map = early_memremap(params.mmap, params.mmap_size);
 	if (memmap.map == NULL) {
@@ -230,6 +228,9 @@ void __init efi_init(void)
 
 	reserve_regions();
 	early_memunmap(memmap.map, params.mmap_size);
+	memblock_mark_nomap(params.mmap & PAGE_MASK,
+			    PAGE_ALIGN(params.mmap_size +
+				       (params.mmap & ~PAGE_MASK)));
 }
 
 static bool __init efi_virtmap_init(void)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
