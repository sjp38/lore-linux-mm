Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 0EF3E6B0044
	for <linux-mm@kvack.org>; Thu,  3 May 2012 19:37:53 -0400 (EDT)
Date: Thu, 3 May 2012 16:37:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] page_alloc.c: remove argument to
 pageblock_default_order
Message-Id: <20120503163749.d24bf07f.akpm@linux-foundation.org>
In-Reply-To: <1336065312-2891-1-git-send-email-rajman.mekaco@gmail.com>
References: <1336065312-2891-1-git-send-email-rajman.mekaco@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rajman mekaco <rajman.mekaco@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org

On Thu,  3 May 2012 22:45:12 +0530
rajman mekaco <rajman.mekaco@gmail.com> wrote:

> When CONFIG_HUGETLB_PAGE_SIZE_VARIABLE is not defined, then
> pageblock_default_order has an argument to it.
> 
> However, free_area_init_core will call it without any argument
> anyway.
> 
> Remove the argument to pageblock_default_order when
> CONFIG_HUGETLB_PAGE_SIZE_VARIABLE is not defined.
> 
> Signed-off-by: rajman mekaco <rajman.mekaco@gmail.com>
> ---
>  mm/page_alloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a712fb9..4b95412 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4274,7 +4274,7 @@ static inline void __init set_pageblock_order(unsigned int order)
>   * at compile-time. See include/linux/pageblock-flags.h for the values of
>   * pageblock_order based on the kernel config
>   */
> -static inline int pageblock_default_order(unsigned int order)
> +static inline int pageblock_default_order(void)
>  {
>  	return MAX_ORDER-1;
>  }

Interesting.  It has been that way since at least 3.1.

It didn't break the build because pageblock_default_order() is only
ever invoked by set_pageblock_order(), with:

	set_pageblock_order(pageblock_default_order());

and set_pageblock_order() is a macro:

#define set_pageblock_order(x)	do {} while (0)


There's yet another reason not to use macros, dammit - they hide bugs.


Mel, can you have a think about this please?  Can we just kill off
pageblock_default_order() and fold its guts into
set_pageblock_order(void)?  Only ia64 and powerpc can define
CONFIG_HUGETLB_PAGE_SIZE_VARIABLE.

--- a/mm/page_alloc.c~a
+++ a/mm/page_alloc.c
@@ -4300,25 +4300,24 @@ static inline void setup_usemap(struct p
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
 
-/* Return a sensible default order for the pageblock size. */
-static inline int pageblock_default_order(void)
-{
-	if (HPAGE_SHIFT > PAGE_SHIFT)
-		return HUGETLB_PAGE_ORDER;
-
-	return MAX_ORDER-1;
-}
-
 /* Initialise the number of pages represented by NR_PAGEBLOCK_BITS */
-static inline void __init set_pageblock_order(unsigned int order)
+static inline void __init set_pageblock_order(void)
 {
+	unsigned int order;
+
 	/* Check that pageblock_nr_pages has not already been setup */
 	if (pageblock_order)
 		return;
 
+	if (HPAGE_SHIFT > PAGE_SHIFT)
+		order = HUGETLB_PAGE_ORDER;
+	else
+		order = MAX_ORDER - 1;
+
 	/*
 	 * Assume the largest contiguous order of interest is a huge page.
-	 * This value may be variable depending on boot parameters on IA64
+	 * This value may be variable depending on boot parameters on IA64 and
+	 * powerpc.
 	 */
 	pageblock_order = order;
 }
@@ -4326,15 +4325,13 @@ static inline void __init set_pageblock_
 
 /*
  * When CONFIG_HUGETLB_PAGE_SIZE_VARIABLE is not set, set_pageblock_order()
- * and pageblock_default_order() are unused as pageblock_order is set
- * at compile-time. See include/linux/pageblock-flags.h for the values of
- * pageblock_order based on the kernel config
+ * is unused as pageblock_order is set at compile-time. See
+ * include/linux/pageblock-flags.h for the values of pageblock_order based on
+ * the kernel config
  */
-static inline int pageblock_default_order(unsigned int order)
+static inline void set_pageblock_order(void)
 {
-	return MAX_ORDER-1;
 }
-#define set_pageblock_order(x)	do {} while (0)
 
 #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
 
@@ -4422,7 +4419,7 @@ static void __paginginit free_area_init_
 		if (!size)
 			continue;
 
-		set_pageblock_order(pageblock_default_order());
+		set_pageblock_order();
 		setup_usemap(pgdat, zone, size);
 		ret = init_currently_empty_zone(zone, zone_start_pfn,
 						size, MEMMAP_EARLY);
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
