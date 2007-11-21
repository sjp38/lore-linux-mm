Date: Wed, 21 Nov 2007 22:03:37 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: pseries (power3) boot hang  (pageblock_nr_pages==0)
Message-ID: <20071121220337.GB31674@csn.ul.ie>
References: <1195682111.4421.23.camel@farscape.rchland.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1195682111.4421.23.camel@farscape.rchland.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Will Schmidt <will_schmidt@vnet.ibm.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@ozlabs.org>
List-ID: <linux-mm.kvack.org>

On (21/11/07 15:55), Will Schmidt didst pronounce:
> Hi Folks, 
> 
> I've been seeing a boot hang/crash on power3 systems for a few weeks.
> (hangs on a 270, drops to SP on a p610).   This afternoon I got around
> to tracking it down to the changes in 
> 
> commit d9c2340052278d8eb2ffb16b0484f8f794def4de
>     Do not depend on MAX_ORDER when grouping pages by mobility
> 
> cpu 0x0: Vector: 100 (System Reset) at [c00000006e803ae0]
>     pc: c00000000009bf50: .setup_per_zone_pages_min+0x298/0x34c
>     lr: c00000000009be38: .setup_per_zone_pages_min+0x180/0x34c
> [c00000006e803e20] c0000000005e3898 .init_per_zone_pages_min+0x80/0xa0
> [c00000006e803ea0] c0000000005c9c04 .kernel_init+0x214/0x3d8
> [c00000006e803f90] c000000000026cac .kernel_thread+0x4c/0x68
> 
> I narrowed it down to the for loop within setup_zone_migrate_reserve(),
> called by setup_per_zone_pages_min().   The loop spins forever due to
> pageblock_nr_pages being 0.
> 
> I imagine this would be properly fixed with something similar to the
> change for iSeries.  

Have you tried with the patch that fixed the iSeries boot problem?
Thanks for tracking down the problem to such a specific place.

Here it the iSeries fix in case it applies to this as well.

======

Ordinarily, the size of a pageblock is determined at compile-time based on
the hugepage size. On PPC64, the hugepage size is determined at runtime based
on what is supported by the machine. On legacy machines such as iSeries which
do not support hugepages, HPAGE_SHIFT is 0. This results in pageblock_order
being set to -PAGE_SHIFT and a crash results shortly afterwards.

This patch checks that HPAGE_SHIFT is a sensible value before using the
hugepage size. If it is 0, MAX_ORDER-1 is used instead as this is a sensible
value of pageblock_order.

This is a fix for 2.6.24.

Credit goes to Stephen Rothwell for identifying the bug and testing on
iSeries.  Additional credit goes to David Gibson for testing with the
libhugetlbfs test suite.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

---
 arch/powerpc/Kconfig |    5 +++++
 mm/page_alloc.c      |   11 ++++++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 18f397c..232c298 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -187,6 +187,11 @@ config FORCE_MAX_ZONEORDER
 	default "9" if PPC_64K_PAGES
 	default "13"
 
+config HUGETLB_PAGE_SIZE_VARIABLE
+	bool
+	depends on HUGETLB_PAGE
+	default y
+
 config MATH_EMULATION
 	bool "Math emulation"
 	depends on 4xx || 8xx || E200 || PPC_MPC832x || E500
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index da69d83..14e0ac3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3386,7 +3386,16 @@ static void __meminit free_area_init_core(struct pglist_data *pgdat,
 		if (!size)
 			continue;
 
-		set_pageblock_order(HUGETLB_PAGE_ORDER);
+		/*
+		 * If HPAGE_SHIFT is a sensible value, base the size of a
+		 * pageblock on the hugepage size. Otherwise MAX_ORDER-1
+		 * is a sensible choice
+		 */
+		if (HPAGE_SHIFT > PAGE_SHIFT)
+			set_pageblock_order(HUGETLB_PAGE_ORDER);
+		else
+			set_pageblock_order(MAX_ORDER-1);
+
 		setup_usemap(pgdat, zone, size);
 		ret = init_currently_empty_zone(zone, zone_start_pfn,
 						size, MEMMAP_EARLY);

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
