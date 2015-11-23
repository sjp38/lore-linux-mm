Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 61A6A6B025E
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:07:29 -0500 (EST)
Received: by wmuu63 with SMTP id u63so44722910wmu.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:07:29 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id 4si17826791wma.36.2015.11.23.01.07.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 01:07:28 -0800 (PST)
Received: by wmww144 with SMTP id w144so86943487wmw.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:07:28 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v3 11/13] ARM: only consider memblocks with NOMAP cleared for linear mapping
Date: Mon, 23 Nov 2015 10:06:31 +0100
Message-Id: <1448269593-20758-12-git-send-email-ard.biesheuvel@linaro.org>
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
 arch/arm/mm/init.c | 5 ++++-
 arch/arm/mm/mmu.c  | 3 +++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 8a63b4cdc0f2..16104b1e2661 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -191,7 +191,7 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max_low,
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
 int pfn_valid(unsigned long pfn)
 {
-	return memblock_is_memory(__pfn_to_phys(pfn));
+	return memblock_is_map_memory(__pfn_to_phys(pfn));
 }
 EXPORT_SYMBOL(pfn_valid);
 #endif
@@ -432,6 +432,9 @@ static void __init free_highpages(void)
 		if (end <= max_low)
 			continue;
 
+		if (memblock_is_nomap(mem))
+			continue;
+
 		/* Truncate partial highmem entries */
 		if (start < max_low)
 			start = max_low;
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index 8c69830e791a..c615d2eb9232 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -1435,6 +1435,9 @@ static void __init map_lowmem(void)
 		phys_addr_t end = start + reg->size;
 		struct map_desc map;
 
+		if (memblock_is_nomap(reg))
+			continue;
+
 		if (end > arm_lowmem_limit)
 			end = arm_lowmem_limit;
 		if (start >= end)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
