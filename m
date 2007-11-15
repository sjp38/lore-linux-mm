Date: Thu, 15 Nov 2007 02:32:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix boot problem with iSeries lacking hugepage support
Message-Id: <20071115023216.44002c28.akpm@linux-foundation.org>
In-Reply-To: <20071115101322.GA5128@skynet.ie>
References: <20071115101322.GA5128@skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linuxppc-dev@ozlabs.org, sfr@canb.auug.org.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Nov 2007 10:13:22 +0000 mel@skynet.ie (Mel Gorman) wrote:

> This patch is a fix for 2.6.24.
> 
> Ordinarily the size of a pageblock is determined at compile-time based on the
> hugepage size. On PPC64, the hugepage size is determined at runtime based on
> what is supported by the machine. With legacy machines such as iSeries that do
> not support hugepages, HPAGE_SHIFT becomes 0. This results in pageblock_order
> being set to -PAGE_SHIFT and a crash results shortly afterwards.
> 
> This patch sets HUGETLB_PAGE_SIZE_VARIABLE for PPC64 and adds a function
> to select a sensible value for pageblock order by default.  It checks that
> HPAGE_SHIFT is a sensible value before using the hugepage size; if it is
> not MAX_ORDER-1 is used.
> 
> Credit goes to Stephen Rothwell for identifying the bug and testing candidate
> patches.  Additional credit goes to Andy Whitcroft for spotting a problem
> with respects to IA-64 before releasing. Additional credit to David Gibson
> for testing with the libhugetlbfs test suite.
> 

umm.

> +
> +/* Return a sensible default order for the pageblock size. */
> +static inline int __init pageblock_default_order(void)

inline and __init doesn't make sense.

> +{
> +	if (HPAGE_SHIFT > PAGE_SHIFT)
> +		return HUGETLB_PAGE_ORDER;
> +
> +	return MAX_ORDER-1;
> +}
> +
>  /* Initialise the number of pages represented by NR_PAGEBLOCK_BITS */
>  static inline void __init set_pageblock_order(unsigned int order)
>  {
> @@ -3357,7 +3367,7 @@ static inline void __init set_pageblock_
>  }
>  #else /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
>  
> -/* Defined this way to avoid accidently referencing HUGETLB_PAGE_ORDER */
> +#define pageblock_default_order(x) (0)

that won't compile.

>  #define set_pageblock_order(x)	do {} while (0)
>  
>  #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
> @@ -3442,7 +3452,7 @@ static void __meminit free_area_init_cor
>  		if (!size)
>  			continue;
>  
> -		set_pageblock_order(HUGETLB_PAGE_ORDER);
> +		set_pageblock_order(pageblock_default_order());
>  		setup_usemap(pgdat, zone, size);
>  		ret = init_currently_empty_zone(zone, zone_start_pfn,


--- a/mm/page_alloc.c~fix-boot-problem-with-iseries-lacking-hugepage-support-fix
+++ a/mm/page_alloc.c
@@ -3268,7 +3268,7 @@ static void inline setup_usemap(struct p
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
 
 /* Return a sensible default order for the pageblock size. */
-static inline int __init pageblock_default_order(void)
+static inline int pageblock_default_order(void)
 {
 	if (HPAGE_SHIFT > PAGE_SHIFT)
 		return HUGETLB_PAGE_ORDER;
@@ -3291,7 +3291,11 @@ static inline void __init set_pageblock_
 }
 #else /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
 
-#define pageblock_default_order(x) (0)
+static inline int pageblock_default_order(void)
+{
+	return 0;
+}
+
 #define set_pageblock_order(x)	do {} while (0)
 
 #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
_


please avoid adding macros when C could have been used.  C is nicer to look
at and has typechecking and stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
