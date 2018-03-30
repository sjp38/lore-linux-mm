Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB1486B026D
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 04:17:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id i127so6248041pgc.22
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 01:17:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2sor2432130pfn.15.2018.03.30.01.17.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Mar 2018 01:17:16 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v4 4/5] arm64: introduce pfn_valid_region()
Date: Fri, 30 Mar 2018 01:15:54 -0700
Message-Id: <1522397755-33393-5-git-send-email-hejianet@gmail.com>
In-Reply-To: <1522397755-33393-1-git-send-email-hejianet@gmail.com>
References: <1522397755-33393-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, richard.weiyang@gmail.com, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

This is the preparation for further optimizing in early_pfn_valid
on arm and arm64.

Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 arch/arm/include/asm/page.h   |  3 ++-
 arch/arm/mm/init.c            | 23 +++++++++++++++++++++++
 arch/arm64/include/asm/page.h |  3 ++-
 arch/arm64/mm/init.c          | 23 +++++++++++++++++++++++
 4 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/arch/arm/include/asm/page.h b/arch/arm/include/asm/page.h
index 7a0404f..559b414 100644
--- a/arch/arm/include/asm/page.h
+++ b/arch/arm/include/asm/page.h
@@ -158,7 +158,8 @@ typedef struct page *pgtable_t;
 
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
 extern int early_region_idx;
-extern int pfn_valid(unsigned long);
+extern int pfn_valid(unsigned long pfn);
+extern int pfn_valid_region(unsigned long pfn, int *last_idx);
 #endif
 
 #include <asm/memory.h>
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 7779804..11f9b82 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -201,6 +201,29 @@ int pfn_valid(unsigned long pfn)
 }
 EXPORT_SYMBOL(pfn_valid);
 
+int pfn_valid_region(unsigned long pfn, int *last_idx)
+{
+	unsigned long start_pfn, end_pfn;
+	struct memblock_type *type = &memblock.memory;
+	struct memblock_region *regions = type->regions;
+
+	if (*last_idx != -1) {
+		start_pfn = PFN_DOWN(regions[*last_idx].base);
+		end_pfn = PFN_DOWN(regions[*last_idx].base +
+					regions[*last_idx].size);
+
+		if (pfn >= start_pfn && pfn < end_pfn)
+			return !memblock_is_nomap(&regions[*last_idx]);
+	}
+
+	*last_idx = memblock_search_pfn_regions(pfn);
+	if (*last_idx == -1)
+		return false;
+
+	return !memblock_is_nomap(&regions[*last_idx]);
+}
+EXPORT_SYMBOL(pfn_valid_region);
+
 /* HAVE_MEMBLOCK is always enabled on arm */
 unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
 							int *last_idx)
diff --git a/arch/arm64/include/asm/page.h b/arch/arm64/include/asm/page.h
index 84b503a..27892d5 100644
--- a/arch/arm64/include/asm/page.h
+++ b/arch/arm64/include/asm/page.h
@@ -39,7 +39,8 @@ typedef struct page *pgtable_t;
 
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
 extern int early_region_idx;
-extern int pfn_valid(unsigned long);
+extern int pfn_valid(unsigned long pfn);
+extern int pfn_valid_region(unsigned long pfn, int *last_idx);
 #endif
 
 #include <asm/memory.h>
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index cd9b473..6dedd77 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -293,6 +293,29 @@ int pfn_valid(unsigned long pfn)
 }
 EXPORT_SYMBOL(pfn_valid);
 
+int pfn_valid_region(unsigned long pfn, int *last_idx)
+{
+	unsigned long start_pfn, end_pfn;
+	struct memblock_type *type = &memblock.memory;
+	struct memblock_region *regions = type->regions;
+
+	if (*last_idx != -1) {
+		start_pfn = PFN_DOWN(regions[*last_idx].base);
+		end_pfn = PFN_DOWN(regions[*last_idx].base +
+				regions[*last_idx].size);
+
+		if (pfn >= start_pfn && pfn < end_pfn)
+			return !memblock_is_nomap(&regions[*last_idx]);
+	}
+
+	*last_idx = memblock_search_pfn_regions(pfn);
+	if (*last_idx == -1)
+		return false;
+
+	return !memblock_is_nomap(&regions[*last_idx]);
+}
+EXPORT_SYMBOL(pfn_valid_region);
+
 /* HAVE_MEMBLOCK is always enabled on arm64 */
 unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
 							int *last_idx)
-- 
2.7.4
