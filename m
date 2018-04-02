Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B49A6B0010
	for <linux-mm@kvack.org>; Sun,  1 Apr 2018 22:33:03 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id h61-v6so4106602pld.3
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 19:33:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f64sor216464pgc.323.2018.04.01.19.33.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Apr 2018 19:33:02 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v5 4/5] arm64: introduce pfn_valid_region()
Date: Sun,  1 Apr 2018 19:30:35 -0700
Message-Id: <1522636236-12625-5-git-send-email-hejianet@gmail.com>
In-Reply-To: <1522636236-12625-1-git-send-email-hejianet@gmail.com>
References: <1522636236-12625-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, Grygorii Strashko <grygorii.strashko@linaro.org>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

This is the preparation for further optimizing in early_pfn_valid
on arm and arm64.

Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 arch/arm/include/asm/page.h   |  3 ++-
 arch/arm/mm/init.c            | 24 ++++++++++++++++++++++++
 arch/arm64/include/asm/page.h |  3 ++-
 arch/arm64/mm/init.c          | 24 ++++++++++++++++++++++++
 4 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/arch/arm/include/asm/page.h b/arch/arm/include/asm/page.h
index f38909c..3bd810e 100644
--- a/arch/arm/include/asm/page.h
+++ b/arch/arm/include/asm/page.h
@@ -158,9 +158,10 @@ typedef struct page *pgtable_t;
 
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
 extern int early_region_idx;
-extern int pfn_valid(unsigned long);
+extern int pfn_valid(unsigned long pfn);
 extern unsigned long memblock_next_valid_pfn(unsigned long pfn);
 #define skip_to_last_invalid_pfn(pfn) (memblock_next_valid_pfn(pfn) - 1)
+extern int pfn_valid_region(unsigned long pfn);
 #endif
 
 #include <asm/memory.h>
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 06ed190..bdcbf58 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -201,6 +201,30 @@ int pfn_valid(unsigned long pfn)
 }
 EXPORT_SYMBOL(pfn_valid);
 
+int pfn_valid_region(unsigned long pfn)
+{
+	unsigned long start_pfn, end_pfn;
+	struct memblock_type *type = &memblock.memory;
+	struct memblock_region *regions = type->regions;
+
+	if (early_region_idx != -1) {
+		start_pfn = PFN_DOWN(regions[early_region_idx].base);
+		end_pfn = PFN_DOWN(regions[early_region_idx].base +
+					regions[early_region_idx].size);
+
+		if (pfn >= start_pfn && pfn < end_pfn)
+			return !memblock_is_nomap(
+					&regions[early_region_idx]);
+	}
+
+	early_region_idx = memblock_search_pfn_regions(pfn);
+	if (early_region_idx == -1)
+		return false;
+
+	return !memblock_is_nomap(&regions[early_region_idx]);
+}
+EXPORT_SYMBOL(pfn_valid_region);
+
 /* HAVE_MEMBLOCK is always enabled on arm */
 unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
 {
diff --git a/arch/arm64/include/asm/page.h b/arch/arm64/include/asm/page.h
index f0d8c8e5..7087b63 100644
--- a/arch/arm64/include/asm/page.h
+++ b/arch/arm64/include/asm/page.h
@@ -39,9 +39,10 @@ typedef struct page *pgtable_t;
 
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
 extern int early_region_idx;
-extern int pfn_valid(unsigned long);
+extern int pfn_valid(unsigned long pfn);
 extern unsigned long memblock_next_valid_pfn(unsigned long pfn);
 #define skip_to_last_invalid_pfn(pfn) (memblock_next_valid_pfn(pfn) - 1)
+extern int pfn_valid_region(unsigned long pfn);
 #endif
 
 #include <asm/memory.h>
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 342e4e2..a1646b6 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -293,6 +293,30 @@ int pfn_valid(unsigned long pfn)
 }
 EXPORT_SYMBOL(pfn_valid);
 
+int pfn_valid_region(unsigned long pfn)
+{
+	unsigned long start_pfn, end_pfn;
+	struct memblock_type *type = &memblock.memory;
+	struct memblock_region *regions = type->regions;
+
+	if (early_region_idx != -1) {
+		start_pfn = PFN_DOWN(regions[early_region_idx].base);
+		end_pfn = PFN_DOWN(regions[early_region_idx].base +
+				regions[early_region_idx].size);
+
+		if (pfn >= start_pfn && pfn < end_pfn)
+			return !memblock_is_nomap(
+					&regions[early_region_idx]);
+	}
+
+	early_region_idx = memblock_search_pfn_regions(pfn);
+	if (early_region_idx == -1)
+		return false;
+
+	return !memblock_is_nomap(&regions[early_region_idx]);
+}
+EXPORT_SYMBOL(pfn_valid_region);
+
 /* HAVE_MEMBLOCK is always enabled on arm64 */
 unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
 {
-- 
2.7.4
