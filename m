Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2B32B6B025C
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 13:33:10 -0500 (EST)
Received: by wmec201 with SMTP id c201so133348281wme.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:33:09 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id j64si27396258wmd.123.2015.11.16.10.33.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 10:33:09 -0800 (PST)
Received: by wmvv187 with SMTP id v187so191198902wmv.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 10:33:09 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 10/12] ARM: only consider memblocks with NOMAP cleared for linear mapping
Date: Mon, 16 Nov 2015 19:32:35 +0100
Message-Id: <1447698757-8762-11-git-send-email-ard.biesheuvel@linaro.org>
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
index 0b7b61e31bc3..094e550144b3 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -1429,6 +1429,9 @@ static void __init map_lowmem(void)
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
