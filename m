Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 357336B0030
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 23:03:39 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id w23so8802650pgv.17
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 20:03:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 126sor3120175pfe.81.2018.03.25.20.03.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Mar 2018 20:03:38 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v3 4/5] arm64: introduce pfn_valid_region()
Date: Sun, 25 Mar 2018 20:02:18 -0700
Message-Id: <1522033340-6575-5-git-send-email-hejianet@gmail.com>
In-Reply-To: <1522033340-6575-1-git-send-email-hejianet@gmail.com>
References: <1522033340-6575-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

This is the preparation for further optimizing in early_pfn_valid
on arm64.

Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 arch/arm64/include/asm/page.h |  3 ++-
 arch/arm64/mm/init.c          | 25 ++++++++++++++++++++++++-
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/page.h b/arch/arm64/include/asm/page.h
index 60d02c8..da2cba3 100644
--- a/arch/arm64/include/asm/page.h
+++ b/arch/arm64/include/asm/page.h
@@ -38,7 +38,8 @@ extern void clear_page(void *to);
 typedef struct page *pgtable_t;
 
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
-extern int pfn_valid(unsigned long);
+extern int pfn_valid(unsigned long pfn);
+extern int pfn_valid_region(unsigned long pfn, int *last_idx);
 #endif
 
 #include <asm/memory.h>
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 00e7b90..06433d5 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -290,7 +290,30 @@ int pfn_valid(unsigned long pfn)
 	return memblock_is_map_memory(pfn << PAGE_SHIFT);
 }
 EXPORT_SYMBOL(pfn_valid);
-#endif
+
+int pfn_valid_region(unsigned long pfn, int *last_idx)
+{
+	unsigned long start_pfn, end_pfn;
+	struct memblock_type *type = &memblock.memory;
+
+	if (*last_idx != -1) {
+		start_pfn = PFN_DOWN(type->regions[*last_idx].base);
+		end_pfn= PFN_DOWN(type->regions[*last_idx].base +
+					type->regions[*last_idx].size);
+
+		if (pfn >= start_pfn && pfn < end_pfn)
+			return !memblock_is_nomap(
+				&memblock.memory.regions[*last_idx]);
+	}
+
+	*last_idx = memblock_search_pfn_regions(pfn);
+	if (*last_idx == -1)
+		return false;
+
+	return !memblock_is_nomap(&memblock.memory.regions[*last_idx]);
+}
+EXPORT_SYMBOL(pfn_valid_region);
+#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
 
 #ifndef CONFIG_SPARSEMEM
 static void __init arm64_memory_present(void)
-- 
2.7.4
