Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5B38B6B0256
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:32:54 -0500 (EST)
Received: by wmww144 with SMTP id w144so122749650wmw.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:32:54 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id eu18si35420744wjd.136.2015.11.16.10.32.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 10:32:53 -0800 (PST)
Received: by wmdw130 with SMTP id w130so123679610wmd.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:32:53 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 03/12] arm64/efi: mark UEFI reserved regions as MEMBLOCK_NOMAP
Date: Mon, 16 Nov 2015 19:32:28 +0100
Message-Id: <1447698757-8762-4-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, matt.fleming@intel.com, linux@arm.linux.org.uk, will.deacon@arm.com, grant.likely@linaro.org, catalin.marinas@arm.com, mark.rutland@arm.com, leif.lindholm@linaro.org, roy.franz@linaro.org
Cc: msalter@redhat.com, ryan.harkin@linaro.org, akpm@linux-foundation.org, linux-mm@kvack.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>

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
index de46b50f4cdf..c7c7fb417110 100644
--- a/arch/arm64/kernel/efi.c
+++ b/arch/arm64/kernel/efi.c
@@ -183,7 +183,7 @@ static __init void reserve_regions(void)
 			early_init_dt_add_memory_arch(paddr, size);
 
 		if (is_reserve_region(md)) {
-			memblock_reserve(paddr, size);
+			memblock_mark_nomap(paddr, size);
 			if (efi_enabled(EFI_DBG))
 				pr_cont("*");
 		}
@@ -205,8 +205,6 @@ void __init efi_init(void)
 
 	efi_system_table = params.system_table;
 
-	memblock_reserve(params.mmap & PAGE_MASK,
-			 PAGE_ALIGN(params.mmap_size + (params.mmap & ~PAGE_MASK)));
 	memmap.phys_map = params.mmap;
 	memmap.map = early_memremap(params.mmap, params.mmap_size);
 	memmap.map_end = memmap.map + params.mmap_size;
@@ -218,6 +216,9 @@ void __init efi_init(void)
 
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
