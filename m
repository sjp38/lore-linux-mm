Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id B44466B006C
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 09:58:51 -0400 (EDT)
From: "Kim, Jong-Sung" <neidhard.kim@lge.com>
References: <1338880312-17561-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1338880312-17561-1-git-send-email-minchan@kernel.org>
Subject: RE: [PATCH] [RESEND] arm: limit memblock base address for early_pte_alloc
Date: Fri, 8 Jun 2012 22:58:50 +0900
Message-ID: <025701cd457e$d5065410$7f12fc30$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, 'Russell King' <linux@arm.linux.org.uk>
Cc: 'Nicolas Pitre' <nico@linaro.org>, 'Catalin Marinas' <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, 'Chanho Min' <chanho.min@lge.com>, linux-mm@kvack.org

> From: Minchan Kim [mailto:minchan@kernel.org]
> Sent: Tuesday, June 05, 2012 4:12 PM
> 
> If we do arm_memblock_steal with a page which is not aligned with section
> size, panic can happen during boot by page fault in map_lowmem.
> 
> Detail:
> 
> 1) mdesc->reserve can steal a page which is allocated at 0x1ffff000 by
> memblock
>    which prefers tail pages of regions.
> 2) map_lowmem maps 0x00000000 - 0x1fe00000
> 3) map_lowmem try to map 0x1fe00000 but it's not aligned by section due to
1.
> 4) calling alloc_init_pte allocates a new page for new pte by
memblock_alloc
> 5) allocated memory for pte is 0x1fffe000 -> it's not mapped yet.
> 6) memset(ptr, 0, sz) in early_alloc_aligned got PANICed!

May I suggest another simple approach? The first continuous couples of
sections are always safely section-mapped inside alloc_init_section funtion.
So, by limiting memblock_alloc to the end of the first continuous couples of
sections at the start of map_lowmem, map_lowmem can safely memblock_alloc &
memset even if we have one or more section-unaligned memory regions. The
limit can be extended back to arm_lowmem_limit after the map_lowmem is done.

diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index e5dad60..edf1e2d 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -1094,6 +1094,11 @@ static void __init kmap_init(void)
 static void __init map_lowmem(void)
 {
 	struct memblock_region *reg;
+	phys_addr_t pmd_map_end;
+
+	pmd_map_end = (memblock.memory.regions[0].base +
+	               memblock.memory.regions[0].size) & PMD_MASK;
+	memblock_set_current_limit(pmd_map_end);
 
 	/* Map all the lowmem memory banks. */
 	for_each_memblock(memory, reg) {
@@ -1113,6 +1118,8 @@ static void __init map_lowmem(void)
 
 		create_mapping(&map);
 	}
+
+	memblock_set_current_limit(arm_lowmem_limit);
 }
 
 /*
@@ -1123,8 +1130,6 @@ void __init paging_init(struct machine_desc *mdesc)
 {
 	void *zero_page;
 
-	memblock_set_current_limit(arm_lowmem_limit);
-
 	build_mem_type_table();
 	prepare_page_table();
 	map_lowmem();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
