Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id C17D66B0255
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:06:56 -0500 (EST)
Received: by wmec201 with SMTP id c201so149996276wme.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:06:56 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id ey10si17878715wjd.117.2015.11.23.01.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 01:06:55 -0800 (PST)
Received: by wmec201 with SMTP id c201so95497388wme.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:06:55 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v3 02/13] arm64: only consider memblocks with NOMAP cleared for linear mapping
Date: Mon, 23 Nov 2015 10:06:22 +0100
Message-Id: <1448269593-20758-3-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1448269593-20758-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, matt@codeblueprint.co.uk
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

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
index abb66f84d4ac..4d75525e20be 100644
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
