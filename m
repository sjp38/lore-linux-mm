Date: Mon, 9 Oct 2006 15:38:06 +0100
Subject: Re: mm section mismatches
Message-ID: <20061009143806.GA4841@skynet.ie>
References: <20061006184930.855d0f0b.akpm@google.com> <20061006211005.56d412f1.rdunlap@xenotime.net> <20061006234609.641f42f4.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20061006234609.641f42f4.akpm@osdl.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Randy Dunlap <rdunlap@xenotime.net>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On (06/10/06 23:46), Andrew Morton didst pronounce:
> On Fri, 6 Oct 2006 21:10:05 -0700
> Randy Dunlap <rdunlap@xenotime.net> wrote:
> 
> > On Fri, 6 Oct 2006 18:49:30 -0700 Andrew Morton wrote:
> > 
> > > i386 allmoconfig, -mm tree:
> 
> <looks>
> 
> > > WARNING: vmlinux - Section mismatch: reference to .init.data:arch_zone_highest_possible_pfn from .text between 'memmap_zone_idx' (at offset 0xc0155e3b) and 'calculate_totalreserve_pages'
> 
> This one is non-init memmap_zone_idx() referring to __initdata
> arch_zone_highest_possible_pfn (Hi, Mel).

Hi Andrew.

memmap_zone_idx() is not used anymore. It was required by an earlier version
of account-for-memmap-and-optionally-the-kernel-image-as-holes.patch but
not any more. This patch clears up the warning. It has been boottested on
x86_64 and ppc64.

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.19-rc1-clean/mm/page_alloc.c linux-2.6.19-rc1-fix_section/mm/page_alloc.c
--- linux-2.6.19-rc1-clean/mm/page_alloc.c	2006-10-06 10:33:58.000000000 +0100
+++ linux-2.6.19-rc1-fix_section/mm/page_alloc.c	2006-10-09 13:45:01.000000000 +0100
@@ -2294,19 +2294,6 @@ unsigned long __init zone_absent_pages_i
 	return __absent_pages_in_range(nid, zone_start_pfn, zone_end_pfn);
 }
 
-/* Return the zone index a PFN is in */
-int memmap_zone_idx(struct page *lmem_map)
-{
-	int i;
-	unsigned long phys_addr = virt_to_phys(lmem_map);
-	unsigned long pfn = phys_addr >> PAGE_SHIFT;
-
-	for (i = 0; i < MAX_NR_ZONES; i++)
-		if (pfn < arch_zone_highest_possible_pfn[i])
-			break;
-
-	return i;
-}
 #else
 static inline unsigned long zone_spanned_pages_in_node(int nid,
 					unsigned long zone_type,
@@ -2325,10 +2312,6 @@ static inline unsigned long zone_absent_
 	return zholes_size[zone_type];
 }
 
-static inline int memmap_zone_idx(struct page *lmem_map)
-{
-	return MAX_NR_ZONES;
-}
 #endif
 
 static void __init calculate_node_totalpages(struct pglist_data *pgdat,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
