Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id F10CE6B000C
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 04:05:50 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o33-v6so15896195plb.16
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 01:05:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u7-v6sor2731631plq.61.2018.04.05.01.05.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 01:05:50 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v7 4/5] arm: arm64: introduce pfn_valid_region()
Date: Thu,  5 Apr 2018 01:04:37 -0700
Message-Id: <1522915478-5044-5-git-send-email-hejianet@gmail.com>
In-Reply-To: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
References: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
where possible") optimized the loop in memmap_init_zone(). But there is
still some room for improvement. E.g. in early_pfn_valid(), we can record
the last returned memblock region. If current pfn and last pfn are in the
same memory region, we needn't do the unnecessary binary searches because
memblock_is_nomap is the same result for whole memory region.

Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 include/linux/arm96_common.h | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/include/linux/arm96_common.h b/include/linux/arm96_common.h
index 2f4dea4..bb86bd3 100644
--- a/include/linux/arm96_common.h
+++ b/include/linux/arm96_common.h
@@ -48,5 +48,29 @@ ulong __init_memblock memblock_next_valid_pfn(ulong pfn)
 	return PHYS_PFN(regions[early_region_idx].base);
 }
 EXPORT_SYMBOL(memblock_next_valid_pfn);
+
+int pfn_valid_region(ulong pfn)
+{
+	ulong start_pfn, end_pfn;
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
 #endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
 #endif /*__ARM96_COMMON_H*/
-- 
2.7.4
