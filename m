Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9614A6B0257
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 11:55:42 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so146533003wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:55:42 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id fz7si19460189wjc.198.2015.09.14.08.55.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 08:55:41 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so139187109wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:55:41 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH 3/3] arm64/efi: mark UEFI reserved regions as MEMBLOCK_NOMAP
Date: Mon, 14 Sep 2015 17:55:29 +0200
Message-Id: <1442246129-13930-4-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1442246129-13930-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1442246129-13930-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, catalin.marinas@arm.com, will.deacon@arm.com, leif.lindholm@linaro.org, mark.rutland@arm.com, msalter@redhat.com, akpm@linux-foundation.org
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>

Change the EFI memory reservation logic to use memblock_mark_nomap()
rather than memblock_reserve() to mark UEFI reserved regions as
occupied. In addition to reserving them against allocations done by
memblock, this will also prevent them from being covered by the linear
mapping.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/kernel/efi.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/kernel/efi.c b/arch/arm64/kernel/efi.c
index e8ca6eaedd02..f609325c4a83 100644
--- a/arch/arm64/kernel/efi.c
+++ b/arch/arm64/kernel/efi.c
@@ -193,7 +193,7 @@ static __init void reserve_regions(void)
 			early_init_dt_add_memory_arch(paddr, size);
 
 		if (is_reserve_region(md)) {
-			memblock_reserve(paddr, size);
+			memblock_mark_nomap(paddr, size);
 			if (uefi_debug)
 				pr_cont("*");
 		}
@@ -215,8 +215,6 @@ void __init efi_init(void)
 
 	efi_system_table = params.system_table;
 
-	memblock_reserve(params.mmap & PAGE_MASK,
-			 PAGE_ALIGN(params.mmap_size + (params.mmap & ~PAGE_MASK)));
 	memmap.phys_map = (void *)params.mmap;
 	memmap.map = early_memremap(params.mmap, params.mmap_size);
 	memmap.map_end = memmap.map + params.mmap_size;
@@ -228,6 +226,7 @@ void __init efi_init(void)
 
 	reserve_regions();
 	early_memunmap(memmap.map, params.mmap_size);
+	memblock_mark_nomap(params.mmap, params.mmap_size);
 }
 
 static bool __init efi_virtmap_init(void)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
