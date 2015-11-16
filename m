Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8C76B0255
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:32:52 -0500 (EST)
Received: by wmec201 with SMTP id c201so191320151wme.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:32:51 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id kg3si47694581wjb.25.2015.11.16.10.32.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 10:32:51 -0800 (PST)
Received: by wmdw130 with SMTP id w130so123678172wmd.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:32:51 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 02/12] arm64: only consider memblocks with NOMAP cleared for linear mapping
Date: Mon, 16 Nov 2015 19:32:27 +0100
Message-Id: <1447698757-8762-3-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1447698757-8762-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-efi@vger.kernel.org, matt.fleming@intel.com, linux@arm.linux.org.uk, will.deacon@arm.com, grant.likely@linaro.org, catalin.marinas@arm.com, mark.rutland@arm.com, leif.lindholm@linaro.org, roy.franz@linaro.org
Cc: msalter@redhat.com, ryan.harkin@linaro.org, akpm@linux-foundation.org, linux-mm@kvack.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>

Take the new memblock attribute MEMBLOCK_NOMAP into account when
deciding whether a certain region is or should be covered by the
kernel direct mapping.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/mm/init.c | 2 +-
 arch/arm64/mm/mmu.c  | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 17bf39ac83ba..ac4d7cbbdd2d 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -120,7 +120,7 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
 int pfn_valid(unsigned long pfn)
 {
-	return memblock_is_memory(pfn << PAGE_SHIFT);
+	return memblock_is_map_memory(pfn << PAGE_SHIFT);
 }
 EXPORT_SYMBOL(pfn_valid);
 #endif
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index e3f563c81c48..0cf325c8dc55 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -421,6 +421,8 @@ static void __init map_mem(void)
 
 		if (start >= end)
 			break;
+		if (memblock_is_nomap(reg))
+			continue;
 
 		if (ARM64_SWAPPER_USES_SECTION_MAPS) {
 			/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
