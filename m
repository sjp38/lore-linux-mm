Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECB206B0025
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 04:16:50 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g66so6836346pfj.11
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 01:16:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k64sor2340351pge.28.2018.03.30.01.16.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Mar 2018 01:16:49 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v4 2/5] arm: arm64: page_alloc: reduce unnecessary binary search in memblock_next_valid_pfn()
Date: Fri, 30 Mar 2018 01:15:52 -0700
Message-Id: <1522397755-33393-3-git-send-email-hejianet@gmail.com>
In-Reply-To: <1522397755-33393-1-git-send-email-hejianet@gmail.com>
References: <1522397755-33393-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, richard.weiyang@gmail.com, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
where possible") optimized the loop in memmap_init_zone(). But there is
still some room for improvement. E.g. if pfn and pfn+1 are in the same
memblock region, we can simply pfn++ instead of doing the binary search
in memblock_next_valid_pfn.

Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 arch/arm/include/asm/page.h   |  1 +
 arch/arm/mm/init.c            | 31 ++++++++++++++++++++++++-------
 arch/arm64/include/asm/page.h |  1 +
 arch/arm64/mm/init.c          | 31 ++++++++++++++++++++++++-------
 mm/page_alloc.c               |  5 +++--
 5 files changed, 53 insertions(+), 16 deletions(-)

diff --git a/arch/arm/include/asm/page.h b/arch/arm/include/asm/page.h
index 4355f0e..7a0404f 100644
--- a/arch/arm/include/asm/page.h
+++ b/arch/arm/include/asm/page.h
@@ -157,6 +157,7 @@ extern void copy_page(void *to, const void *from);
 typedef struct page *pgtable_t;
 
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
+extern int early_region_idx;
 extern int pfn_valid(unsigned long);
 #endif
 
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 0fb85ca..7779804 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -193,6 +193,8 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max_low,
 }
 
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
+int early_region_idx __meminitdata = -1;
+
 int pfn_valid(unsigned long pfn)
 {
 	return memblock_is_map_memory(__pfn_to_phys(pfn));
@@ -200,31 +202,46 @@ int pfn_valid(unsigned long pfn)
 EXPORT_SYMBOL(pfn_valid);
 
 /* HAVE_MEMBLOCK is always enabled on arm */
-unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
+unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
+							int *last_idx)
 {
 	struct memblock_type *type = &memblock.memory;
+	struct memblock_region *regions = type->regions;
 	unsigned int right = type->cnt;
 	unsigned int mid, left = 0;
+	unsigned long start_pfn, end_pfn;
 	phys_addr_t addr = PFN_PHYS(++pfn);
 
+	/* fast path, return pfn+1 if next pfn is in the same region */
+	if (*last_idx != -1) {
+		start_pfn = PFN_DOWN(regions[*last_idx].base);
+		end_pfn = PFN_DOWN(regions[*last_idx].base +
+				regions[*last_idx].size);
+
+		if (pfn >= start_pfn && pfn < end_pfn)
+			return pfn;
+	}
+
+	/* slow path, do the binary searching */
 	do {
 		mid = (right + left) / 2;
 
-		if (addr < type->regions[mid].base)
+		if (addr < regions[mid].base)
 			right = mid;
-		else if (addr >= (type->regions[mid].base +
-				  type->regions[mid].size))
+		else if (addr >= (regions[mid].base + regions[mid].size))
 			left = mid + 1;
 		else {
-			/* addr is within the region, so pfn is valid */
+			*last_idx = mid;
 			return pfn;
 		}
 	} while (left < right);
 
 	if (right == type->cnt)
 		return -1UL;
-	else
-		return PHYS_PFN(type->regions[right].base);
+
+	*last_idx = right;
+
+	return PHYS_PFN(regions[*last_idx].base);
 }
 EXPORT_SYMBOL(memblock_next_valid_pfn);
 #endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
diff --git a/arch/arm64/include/asm/page.h b/arch/arm64/include/asm/page.h
index 60d02c8..84b503a 100644
--- a/arch/arm64/include/asm/page.h
+++ b/arch/arm64/include/asm/page.h
@@ -38,6 +38,7 @@ extern void clear_page(void *to);
 typedef struct page *pgtable_t;
 
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
+extern int early_region_idx;
 extern int pfn_valid(unsigned long);
 #endif
 
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 13e43ff..cd9b473 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -285,6 +285,8 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
 #endif /* CONFIG_NUMA */
 
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
+int early_region_idx __meminitdata = -1;
+
 int pfn_valid(unsigned long pfn)
 {
 	return memblock_is_map_memory(pfn << PAGE_SHIFT);
@@ -292,31 +294,46 @@ int pfn_valid(unsigned long pfn)
 EXPORT_SYMBOL(pfn_valid);
 
 /* HAVE_MEMBLOCK is always enabled on arm64 */
-unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
+unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
+							int *last_idx)
 {
 	struct memblock_type *type = &memblock.memory;
+	struct memblock_region *regions = type->regions;
 	unsigned int right = type->cnt;
 	unsigned int mid, left = 0;
+	unsigned long start_pfn, end_pfn;
 	phys_addr_t addr = PFN_PHYS(++pfn);
 
+	/* fast path, return pfn+1 if next pfn is in the same region */
+	if (*last_idx != -1) {
+		start_pfn = PFN_DOWN(regions[*last_idx].base);
+		end_pfn = PFN_DOWN(regions[*last_idx].base +
+				regions[*last_idx].size);
+
+		if (pfn >= start_pfn && pfn < end_pfn)
+			return pfn;
+	}
+
+	/* slow path, do the binary searching */
 	do {
 		mid = (right + left) / 2;
 
-		if (addr < type->regions[mid].base)
+		if (addr < regions[mid].base)
 			right = mid;
-		else if (addr >= (type->regions[mid].base +
-				  type->regions[mid].size))
+		else if (addr >= (regions[mid].base + regions[mid].size))
 			left = mid + 1;
 		else {
-			/* addr is within the region, so pfn is valid */
+			*last_idx = mid;
 			return pfn;
 		}
 	} while (left < right);
 
 	if (right == type->cnt)
 		return -1UL;
-	else
-		return PHYS_PFN(type->regions[right].base);
+
+	*last_idx = right;
+
+	return PHYS_PFN(regions[*last_idx].base);
 }
 EXPORT_SYMBOL(memblock_next_valid_pfn);
 #endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8a92df7..f99b513 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5453,8 +5453,9 @@ void __ref build_all_zonelists(pg_data_t *pgdat)
  * done. Non-atomic initialization, single-pass.
  */
 #if (defined CONFIG_HAVE_MEMBLOCK) && (defined CONFIG_HAVE_ARCH_PFN_VALID)
-extern unsigned long memblock_next_valid_pfn(unsigned long pfn);
-#define skip_to_last_invalid_pfn(pfn) (memblock_next_valid_pfn(pfn) - 1)
+extern unsigned long memblock_next_valid_pfn(unsigned long pfn, int *last_idx);
+#define skip_to_last_invalid_pfn(pfn) \
+		(memblock_next_valid_pfn(pfn, &early_region_idx) - 1)
 #endif
 
 #ifndef skip_to_last_invalid_pfn
-- 
2.7.4
