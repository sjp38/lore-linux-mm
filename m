Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 926A66B0255
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 11:55:41 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so147992149wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:55:41 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id v10si5855482wje.35.2015.09.14.08.55.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 08:55:40 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so147032438wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:55:39 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH 2/3] arm64: only consider memblocks with NOMAP cleared for linear mapping
Date: Mon, 14 Sep 2015 17:55:28 +0200
Message-Id: <1442246129-13930-3-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1442246129-13930-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1442246129-13930-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, catalin.marinas@arm.com, will.deacon@arm.com, leif.lindholm@linaro.org, mark.rutland@arm.com, msalter@redhat.com, akpm@linux-foundation.org
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>

Take the new memblock attribute MEMBLOCK_NOMAP into account when
deciding whether a certain region is or should covered by the
kernel direct mapping.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm64/mm/init.c | 2 +-
 arch/arm64/mm/mmu.c  | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index f5c0680d17d9..48133235d9f5 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -119,7 +119,7 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
 int pfn_valid(unsigned long pfn)
 {
-	return memblock_is_memory(pfn << PAGE_SHIFT);
+	return memblock_is_map_memory(pfn << PAGE_SHIFT);
 }
 EXPORT_SYMBOL(pfn_valid);
 #endif
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 9211b8527f25..7067ae232bed 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -370,6 +370,8 @@ static void __init map_mem(void)
 
 		if (start >= end)
 			break;
+		if (memblock_is_nomap(reg))
+			continue;
 
 #ifndef CONFIG_ARM64_64K_PAGES
 		/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
