Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3816B000A
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 05:02:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b17-v6so5295102pff.17
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 02:02:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g36-v6sor2399123plb.4.2018.07.06.02.02.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 02:02:03 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [RESEND PATCH v10 2/6] mm: page_alloc: remain memblock_next_valid_pfn() on arm/arm64
Date: Fri,  6 Jul 2018 17:01:11 +0800
Message-Id: <1530867675-9018-3-git-send-email-hejianet@gmail.com>
In-Reply-To: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
References: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jia He <jia.he@hxt-semitech.com>

From: Jia He <jia.he@hxt-semitech.com>

Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
where possible") optimized the loop in memmap_init_zone(). But it causes
possible panic bug. So Daniel Vacek reverted it later.

But as suggested by Daniel Vacek, it is fine to using memblock to skip
gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.
Daniel said:
"On arm and arm64, memblock is used by default. But generic version of
pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
not always return the next valid one but skips more resulting in some
valid frames to be skipped (as if they were invalid). And that's why
kernel was eventually crashing on some !arm machines."

About the performance consideration:
As said by James in b92df1de5,
"I have tested this patch on a virtual model of a Samurai CPU
with a sparse memory map.  The kernel boot time drops from 109 to
62 seconds."

Thus it would be better if we remain memblock_next_valid_pfn on arm/arm64.

Suggested-by: Daniel Vacek <neelx@redhat.com>
Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 include/linux/mmzone.h | 11 +++++++++++
 mm/memblock.c          | 30 ++++++++++++++++++++++++++++++
 mm/page_alloc.c        |  5 ++++-
 3 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 32699b2..57cdc42 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1241,6 +1241,8 @@ static inline int pfn_valid(unsigned long pfn)
 		return 0;
 	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
 }
+
+#define next_valid_pfn(pfn)	(pfn + 1)
 #endif
 
 static inline int pfn_present(unsigned long pfn)
@@ -1266,6 +1268,10 @@ static inline int pfn_present(unsigned long pfn)
 #endif
 
 #define early_pfn_valid(pfn)	pfn_valid(pfn)
+#ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
+extern ulong memblock_next_valid_pfn(ulong pfn);
+#define next_valid_pfn(pfn)	memblock_next_valid_pfn(pfn)
+#endif
 void sparse_init(void);
 #else
 #define sparse_init()	do {} while (0)
@@ -1287,6 +1293,11 @@ struct mminit_pfnnid_cache {
 #define early_pfn_valid(pfn)	(1)
 #endif
 
+/* fallback to default definitions*/
+#ifndef next_valid_pfn
+#define next_valid_pfn(pfn)	(pfn + 1)
+#endif
+
 void memory_present(int nid, unsigned long start, unsigned long end);
 
 /*
diff --git a/mm/memblock.c b/mm/memblock.c
index b9cdfa0..ccad225 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1139,6 +1139,36 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
 }
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
+#ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
+ulong __init_memblock memblock_next_valid_pfn(ulong pfn)
+{
+	struct memblock_type *type = &memblock.memory;
+	unsigned int right = type->cnt;
+	unsigned int mid, left = 0;
+	phys_addr_t addr = PFN_PHYS(++pfn);
+
+	do {
+		mid = (right + left) / 2;
+
+		if (addr < type->regions[mid].base)
+			right = mid;
+		else if (addr >= (type->regions[mid].base +
+				  type->regions[mid].size))
+			left = mid + 1;
+		else {
+			/* addr is within the region, so pfn is valid */
+			return pfn;
+		}
+	} while (left < right);
+
+	if (right == type->cnt)
+		return -1UL;
+	else
+		return PHYS_PFN(type->regions[right].base);
+}
+EXPORT_SYMBOL(memblock_next_valid_pfn);
+#endif /*CONFIG_HAVE_MEMBLOCK_PFN_VALID*/
+
 static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
 					phys_addr_t align, phys_addr_t start,
 					phys_addr_t end, int nid, ulong flags)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cd3c7b9..607deff 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5485,8 +5485,11 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		if (context != MEMMAP_EARLY)
 			goto not_early;
 
-		if (!early_pfn_valid(pfn))
+		if (!early_pfn_valid(pfn)) {
+			pfn = next_valid_pfn(pfn) - 1;
 			continue;
+		}
+
 		if (!early_pfn_in_nid(pfn, nid))
 			continue;
 		if (!update_defer_init(pgdat, pfn, end_pfn, &nr_initialised))
-- 
1.8.3.1
