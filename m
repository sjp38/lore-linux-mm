Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 472996B0269
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 22:31:00 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id f2-v6so8113211qkm.10
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 19:31:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o19-v6sor4651064qki.159.2018.06.28.19.30.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 19:30:59 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v9 5/6] arm: arm64: introduce pfn_valid_region()
Date: Fri, 29 Jun 2018 10:29:22 +0800
Message-Id: <1530239363-2356-6-git-send-email-hejianet@gmail.com>
In-Reply-To: <1530239363-2356-1-git-send-email-hejianet@gmail.com>
References: <1530239363-2356-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, richard.weiyang@gmail.com, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
where possible") optimized the loop in memmap_init_zone(). But there is
still some room for improvement. E.g. in early_pfn_valid(), we can record
the last returned memblock region. If current pfn and last pfn are in the
same memory region, we needn't do the unnecessary binary searches because
memblock_is_nomap is the same result for whole memory region.

Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 include/linux/early_pfn.h | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/include/linux/early_pfn.h b/include/linux/early_pfn.h
index f9e40c3..9609391 100644
--- a/include/linux/early_pfn.h
+++ b/include/linux/early_pfn.h
@@ -51,5 +51,29 @@ ulong __init_memblock memblock_next_valid_pfn(ulong pfn)
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
 #endif /*CONFIG_HAVE_MEMBLOCK_PFN_VALID*/
 #endif /*__EARLY_PFN_H*/
-- 
1.8.3.1
