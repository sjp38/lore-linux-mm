Date: Thu, 15 Nov 2007 11:06:34 +0000
Subject: Re: [PATCH] Fix boot problem with iSeries lacking hugepage support
Message-ID: <20071115110633.GE5128@skynet.ie>
References: <20071115101322.GA5128@skynet.ie> <20071115023216.44002c28.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20071115023216.44002c28.akpm@linux-foundation.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linuxppc-dev@ozlabs.org, sfr@canb.auug.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (15/11/07 02:32), Andrew Morton didst pronounce:
> On Thu, 15 Nov 2007 10:13:22 +0000 mel@skynet.ie (Mel Gorman) wrote:
> 
> > This patch is a fix for 2.6.24.
> > 
> > Ordinarily the size of a pageblock is determined at compile-time based on the
> > hugepage size. On PPC64, the hugepage size is determined at runtime based on
> > what is supported by the machine. With legacy machines such as iSeries that do
> > not support hugepages, HPAGE_SHIFT becomes 0. This results in pageblock_order
> > being set to -PAGE_SHIFT and a crash results shortly afterwards.
> > 
> > This patch sets HUGETLB_PAGE_SIZE_VARIABLE for PPC64 and adds a function
> > to select a sensible value for pageblock order by default.  It checks that
> > HPAGE_SHIFT is a sensible value before using the hugepage size; if it is
> > not MAX_ORDER-1 is used.
> > 
> > Credit goes to Stephen Rothwell for identifying the bug and testing candidate
> > patches.  Additional credit goes to Andy Whitcroft for spotting a problem
> > with respects to IA-64 before releasing. Additional credit to David Gibson
> > for testing with the libhugetlbfs test suite.
> > 
> 
> umm.
> 
> > +
> > +/* Return a sensible default order for the pageblock size. */
> > +static inline int __init pageblock_default_order(void)
> 
> inline and __init doesn't make sense.
> 

I know the __init is meaningless in this context. It is there as a guide
if someone decides to drop the inline for some reason that it should
remain as __init. I can post a version with just the inline.

> > +{
> > +	if (HPAGE_SHIFT > PAGE_SHIFT)
> > +		return HUGETLB_PAGE_ORDER;
> > +
> > +	return MAX_ORDER-1;
> > +}
> > +
> >  /* Initialise the number of pages represented by NR_PAGEBLOCK_BITS */
> >  static inline void __init set_pageblock_order(unsigned int order)
> >  {
> > @@ -3357,7 +3367,7 @@ static inline void __init set_pageblock_
> >  }
> >  #else /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
> >  
> > -/* Defined this way to avoid accidently referencing HUGETLB_PAGE_ORDER */
> > +#define pageblock_default_order(x) (0)
> 
> that won't compile.
> 

It's never used so it could have been anything and still compiled. I admit
this is confusing.  I've posted a version below that changes this to a static
inline, returns MAX_ORDER-1 which is a sensible value even if unused and
comments on what is happening.

> >  #define set_pageblock_order(x)	do {} while (0)
> >  
> >  #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
> > @@ -3442,7 +3452,7 @@ static void __meminit free_area_init_cor
> >  		if (!size)
> >  			continue;
> >  
> > -		set_pageblock_order(HUGETLB_PAGE_ORDER);
> > +		set_pageblock_order(pageblock_default_order());
> >  		setup_usemap(pgdat, zone, size);
> >  		ret = init_currently_empty_zone(zone, zone_start_pfn,
> 
> 
> --- a/mm/page_alloc.c~fix-boot-problem-with-iseries-lacking-hugepage-support-fix
> +++ a/mm/page_alloc.c
> @@ -3268,7 +3268,7 @@ static void inline setup_usemap(struct p
>  #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
>  
>  /* Return a sensible default order for the pageblock size. */
> -static inline int __init pageblock_default_order(void)
> +static inline int pageblock_default_order(void)
>  {
>  	if (HPAGE_SHIFT > PAGE_SHIFT)
>  		return HUGETLB_PAGE_ORDER;
> @@ -3291,7 +3291,11 @@ static inline void __init set_pageblock_
>  }
>  #else /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
>  
> -#define pageblock_default_order(x) (0)
> +static inline int pageblock_default_order(void)
> +{
> +	return 0;
> +}
> +
>  #define set_pageblock_order(x)	do {} while (0)
>  
>  #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
> _
> 
> 
> please avoid adding macros when C could have been used.  C is nicer to look
> at and has typechecking and stuff.
> 

Understood. Here is an updated version. It is functionally equivilant to
the earlier patch but may be easier on the eye

===

Ordinarily the size of a pageblock is determined at compile-time based on the
hugepage size. On PPC64, the hugepage size is determined at runtime based on
what is supported by the machine. With legacy machines such as iSeries that
do not support hugepages, HPAGE_SHIFT is 0. This results in pageblock_order
being set to -PAGE_SHIFT and a crash results shortly afterwards.

This patch adds a function to select a sensible value for pageblock order by
default when HUGETLB_PAGE_SIZE_VARIABLE is set. It checks that HPAGE_SHIFT
is a sensible value before using the hugepage size; if it is not MAX_ORDER-1
is used.

This is a fix for 2.6.24.

Credit goes to Stephen Rothwell for identifying the bug and testing candidate
patches.  Additional credit goes to Andy Whitcroft for spotting a problem
with respects to IA-64 before releasing. Additional credit to David Gibson
for testing with the libhugetlbfs test suite.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Tested-by: Stephen Rothwell <sfr@canb.auug.org.au>

--- 
 arch/powerpc/Kconfig |    5 +++++
 mm/page_alloc.c      |   23 +++++++++++++++++++++--
 2 files changed, 26 insertions(+), 2 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc2-mm1-clean/arch/powerpc/Kconfig linux-2.6.24-rc2-mm1-varpage-fix/arch/powerpc/Kconfig
--- linux-2.6.24-rc2-mm1-clean/arch/powerpc/Kconfig	2007-11-14 11:38:05.000000000 +0000
+++ linux-2.6.24-rc2-mm1-varpage-fix/arch/powerpc/Kconfig	2007-11-15 10:44:38.000000000 +0000
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
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc2-mm1-clean/mm/page_alloc.c linux-2.6.24-rc2-mm1-varpage-fix/mm/page_alloc.c
--- linux-2.6.24-rc2-mm1-clean/mm/page_alloc.c	2007-11-14 11:38:08.000000000 +0000
+++ linux-2.6.24-rc2-mm1-varpage-fix/mm/page_alloc.c	2007-11-15 11:01:13.000000000 +0000
@@ -3342,6 +3342,16 @@ static void inline setup_usemap(struct p
 #endif /* CONFIG_SPARSEMEM */
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
+
+/* Return a sensible default order for the pageblock size. */
+static inline int pageblock_default_order(void)
+{
+	if (HPAGE_SHIFT > PAGE_SHIFT)
+		return HUGETLB_PAGE_ORDER;
+
+	return MAX_ORDER-1;
+}
+
 /* Initialise the number of pages represented by NR_PAGEBLOCK_BITS */
 static inline void __init set_pageblock_order(unsigned int order)
 {
@@ -3357,7 +3367,16 @@ static inline void __init set_pageblock_
 }
 #else /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
 
-/* Defined this way to avoid accidently referencing HUGETLB_PAGE_ORDER */
+/*
+ * When CONFIG_HUGETLB_PAGE_SIZE_VARIABLE is not set, set_pageblock_order()
+ * and pageblock_default_order() are unused as pageblock_order is set
+ * at compile-time. See include/linux/pageblock-flags.h for the values of
+ * pageblock_order based on the kernel config
+ */
+static inline int pageblock_default_order(unsigned int order)
+{
+	return MAX_ORDER-1;
+}
 #define set_pageblock_order(x)	do {} while (0)
 
 #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
@@ -3442,7 +3461,7 @@ static void __meminit free_area_init_cor
 		if (!size)
 			continue;
 
-		set_pageblock_order(HUGETLB_PAGE_ORDER);
+		set_pageblock_order(pageblock_default_order());
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
