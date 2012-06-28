Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 4E6776B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 01:43:22 -0400 (EDT)
From: "Kim, Jong-Sung" <neidhard.kim@lge.com>
References: <1338880312-17561-1-git-send-email-minchan@kernel.org> <025701cd457e$d5065410$7f12fc30$@lge.com> <20120627160220.GA2310@linaro.org>
In-Reply-To: <20120627160220.GA2310@linaro.org>
Subject: RE: [PATCH] [RESEND] arm: limit memblock base address for early_pte_alloc
Date: Thu, 28 Jun 2012 14:43:17 +0900
Message-ID: <00e801cd54f0$eb8a3540$c29e9fc0$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dave Martin' <dave.martin@linaro.org>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Nicolas Pitre' <nico@linaro.org>, 'Catalin Marinas' <catalin.marinas@arm.com>, 'Chanho Min' <chanho.min@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

> From: Dave Martin [mailto:dave.martin@linaro.org]
> Sent: Thursday, June 28, 2012 1:02 AM
> 
> For me, it appears that this block just contains the initial region passed
> in ATAG_MEM or on the command line, with some reservations for
> swapper_pg_dir, the kernel text/data, device tree and initramfs.
> 
> So far as I can tell, the only memory guaranteed to be mapped here is the
> kernel image: there may be no guarantee that there is any unused space in
> this region which could be used to allocate extra page tables.
> The rest appears during the execution of map_lowmem().
> 
> Cheers
> ---Dave

Thank you for your comment, Dave! It was not that sophisticated choice, but
I thought that normal embedded system trying to reduce the BOM would have a
big-enough first memblock memory region. However you're right. There can be
exceptional systems. Then, how do you think about following manner:

diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index e5dad60..0bc5316 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -1094,6 +1094,16 @@ static void __init kmap_init(void)
 static void __init map_lowmem(void)
 {
        struct memblock_region *reg;
+       phys_addr_t pmd_map_end = 0;
+
+       for_each_memblock(memory, reg) {
+               pmd_map_end = reg->base + reg->size;
+               if((reg->base | reg->size) & ~PMD_MASK)
+                       break;
+       }
+       if(pmd_map_end > lowmem_limit)
+               pmd_map_end = lowmem_limit;
+       memblock_set_current_limit(pmd_map_end & PMD_MASK);
 
        /* Map all the lowmem memory banks. */
        for_each_memblock(memory, reg) {
@@ -1113,6 +1123,8 @@ static void __init map_lowmem(void)
 
                create_mapping(&map);
        }
+
+       memblock_set_current_limit(lowmem_limit);
 }
 
 /*
@@ -1123,8 +1135,6 @@ void __init paging_init(struct machine_desc *mdesc)
 {
        void *zero_page;
 
-       memblock_set_current_limit(arm_lowmem_limit);
-
        build_mem_type_table();
        prepare_page_table();
        map_lowmem();

This will not limit the PTE-allocation to near the end of first bank.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
