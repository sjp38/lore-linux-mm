Date: Tue, 1 May 2007 20:00:42 +0100
Subject: Re: fragmentation avoidance Re: 2.6.22 -mm merge plans
Message-ID: <20070501190041.GA15493@skynet.ie>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070501101651.GA29957@skynet.ie> <Pine.LNX.4.64.0705010724010.22931@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705010724010.22931@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, apw@shadowen.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007, Christoph Lameter wrote:

> On Tue, 1 May 2007, Mel Gorman wrote:
>
>>    anti-fragmentation-switch-over-to-pfn_valid_within.patch
>>
>> These patches are the grouping pages by mobility patches. They get tested
>> every time someone boots the machine from the perspective that they affect
>> the page allocator. It is working to keep fragmentation problems to a
>> minimum and being exercised.  We have beaten it heavily here on tests
>> with a variety of machines using the system that drives test.kernel.org
>> for both functionality and performance testing. That covers x86, x86_64,
>> ppc64 and occasionally IA64. Granted, there are corner-case machines out
>> there or we'd never receive bug reports at all.
>>
>> They are currently being reviewed by Christoph Lameter. His feedback in
>> the linux-mm thread "Antifrag patchset comments" has given me a TODO list
>> which I'm currently working through. So far, there has been no fundamental
>> mistake in my opinion and the additional work is logical extensions.
>
> I think we really urgently need a defragmentation solution in Linux in
> order to support higher page allocations for various purposes. SLUB f.e.
> would benefit from it and the large blocksize patches are not reasonable
> without such a method.
>

I continue to maintain that anti-fragmentation is a pre-requisite for
any defragmentation mechanism to be effective without trashing overall
performance. If allocation success rates are low when everything possible
has been reclaimed as is the case without fragmentation avoidance, then
defragmentation will not help unless the the 1:1 phys:virt mappings is broken
which incurs its own considerable set of problems.

> However, the current code is not up to the task. I did not see a clean
> categorization of allocations nor a consistent handling of those. The
> cleanup work that would have to be done throughout the kernel is not
> there.

The choice of mobility marker to use in each case was deliberate (even if I
have made mistakes but what else is review for?). The choice by default is
UNMOVABLE as it's the safe choice even if may be sub-optimal.  The description
of the mobility types may not be the clearest. For example, buffers were
placed beside page cache in MOVABLE because they can both be reclaimed in
the same fashion - I consider moving it to disk to be as "movable" as any
other definition of the word but in your world movable always means page
migration which has led to some confusion. They could have been separated
out as MOVABLE and BUFFERS for a conceptually cleaner split but it did not
seem necessary because the more types there are, the bigger the memory and
performance footprint becomes. Additional flag groupings like GFP_BUFFERS
could be defined that alias to MOVABLE if you felt it would make the code
clearer but functionally, the behaviour remains the same. This is similar
to your feedback on the treatment of GFP_TEMPORARY.

There can be as many alias mobility types as you wish but if more "real"
types are required, you can have as you want as long as NR_PAGEBLOCK_BITS
is increased properly and allocflags_to_migratetype() is able to translate
GFP flags to the appropriate mobility type. It increases the performance
and memory footprint though.

> It is spotty. There seems to be a series of heuristic driving this
> thing (I have to agree with Nick there). The temporary allocations that
> were missed are just a few that I found. The review of the rest of the
> kernel was not done.

The review for temporary allocations was aimed at catching the most common
callers, not every single one of them because a full review of every caller
is a large undertaking.  If anything, it makes more sense to do a review of
all callers at the end when the core mechanism is finished. The default to
treat them as UNMOVABLE is sensible.

> Mel said that he fixed up locations that showed up to
> be a problem in testing. That is another issue: Too much focus on testing
> instead of conceptual cleanness and clean code in the kernel.

The patches started as a thought experiment of what "should work". They
were then tested to find flaws in the model and the results were fed back
in. How is that a disadvantage exactly?

> It looks
> like this is geared for a specific series of tests on specific platforms
> and also to a particular allocation size (max order sized huge pages).
>

Some series of tests had to be chosen and one combination was chosen
that was known to be particularly hostile to external fragmentation -
i.e. large numbers of kernel cache allocations at the same time as page
cache allocations. No one has suggested an alternative test that would be
more suitable. The platforms used were x86, x86_64 and ppc64 which are not
exactly insignificant platforms. At the time, I didn't have an IA64 machine and
franky the one I have now does not always boot so testing is not as thorough.

Huge page sized pages were chosen because they were the hardest allocation
to satisfy. If they could be allocated successfully, it stood to reason that
smaller allocations at least as well.

Hugepages and MAX_ORDER pages were close to the same size on x86, x86_64
and ppc64 which is why that figure was chosen. I point out that while IA64
can specify hugepagesz= to change the hugepage size, it's not documented
in Documentation/kernel-parameters.txt or I might have spotted this sooner.

These decisions were not random.

> There are major technical problems with
>
> 1. Large Scale allocs. Multiple MAX_ORDER blocks as required by the
>   antifrag patches may not exist on all platforms. Thus the antifrag
>   patches will not be able to generate their MAX_ORDER sections. We
>   could reduce MAX_ORDER on some platforms but that would have other
>   implications like limiting the highest order allocation.

MAX_ORDER was a sensible choice on the three initial platforms. However,
it is not a fundamental value in the mechanism and is an easy assumption to
break. I've included a patch below based on your review that choses a size
based on the value of HPAGE_SHIFT. It took 45 minutes to cobble together
so it's rough looking and I might have missed something but it has passed
stress tests on x86 without difficulty. Here is the dmesg output

[    0.000000] Built 1 zonelists, mobility grouping on at order 5. Total pages: 16224

Voila, grouping on order 5 instead of 10 (I used 5 instead of HPAGE_SHIFT
for testing purposes).

The order used can be any value >= 2 and < MAX_ORDER.

> 2. Small huge page size support. F.e. IA64 can support down to page size
>   huge pages. The antifrag patches handle huge page in a special way.
>   They are categorized as movable. Small huge pages may
>   therefore contaminate the movable area.

They are only categorised as movable when a sysctl is set. This has to be
the deliberate choice of the administrator and its intention was to allow
hugepages to be alloced from ZONE_MOVABLE. This was to allow flexible sizing
of the hugepage pool when that zone is configured until such time as hugepages
were really movable in 100% of situations.

> 3. Defining the size of ZONE_MOVABLE. This was done to guarantee
>   availability of movable memory but the practical effect is to
>   guarantee that we panic when too many unreclaimable allocations have
>   been done.
>

The size of ZONE_MOVABLE is determined at boot time and it is not
required for grouping page by mobility to be effective. Presumably by an
administrator that has identified the problem that is fixed by having this
zone available. Furthermore, it would be done with the understanding of what
it means for OOM situations if the partition is made too small. The expectation
is that he has a solid understanding of his workload before using this option.

> I have already said during the review that IMHO the patches are not ready
> for merging. They are currently more like a prototype that explores ideas.
> The generalization steps are not done.
>
> How we could make progress:
>
> 1. Develop a useful categorization of allocations in the kernel whose
>   utility goes beyond the antifrag patches. I.e. length of
>   the objects existence and the method of reclaim could be useful in
>   various contexts.
>

The length of objects existence is something I am wary of because it
puts a big burden on the caller of the page allocator. The method of
reclaim is already implied by the existing categorisations. What may be
missing is clear documentation

UNMOVABLE - You can't reclaim it

RECLAIMABLE - You need the help of another subsystem to reclaim objects
	within the page before the page is reclaimed or the allocation
	is short-lived. Even when reclaimable, there is no guarantee that
	reclaim will succeed.

MOVABLE - The page is directly reclaimable by kswapd or it may be
	migrated. Being able to reclaim is guaranteed except where mlock()
	is involved. mlock pages need to be migrated.

You've defined these better yourself in your review. Arguably, RECLAIMABLE
should be separate from TEMPORARY and page buffers should be away from
MOVABLE but this did not appear necessary when tested.

If this breakout is found to be required, it is trivial to implement.

> 2. Have statistics of these various allocations.
>
> 3. Page allocator should gather statistics on how memory was allocated in
>   the various categories.
>

Statistics gathering has been done before and it can be done again. They were
used earlier in the development of the patches and then I stopped bringing
them forward in the belief they would not be of general interest. In a large
part, they helped define the current mobility types.  Gathering statistics
again is not a fundamental problem.

> 4. The available data can then be used to driver more intelligent reclaim
>   and develop methods of antifrag or defragmentation.
>

Once that data is available, it would help show how successfully fragmentation
avoidance as it currently stands and how it can be improved. The lack of the
statistics today does not seem a blocking issue because there are no users
of fragmentation avoidance that blow up if it's not effective.

Patch for breaking the MAX_ORDER grouping is as follows. Again, it's 45 minutes
coding so maybe I missed something but it survived a quick stress testing.

Not signed off due to incompleteness (e.g. should use a constant if the
hugepage size is known at compile time, nr_pages_pageblock should be
__read_mostly, not checked everywhere etc) and lack of full regression
testing and verification. If I hadn't bothered updating comments or printks,
the patch would be fairly small.

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-004_temporary/include/linux/pageblock-flags.h linux-2.6.21-rc7-mm2-005_group_arbitrary/include/linux/pageblock-flags.h
--- linux-2.6.21-rc7-mm2-004_temporary/include/linux/pageblock-flags.h	2007-04-27 22:04:34.000000000 +0100
+++ linux-2.6.21-rc7-mm2-005_group_arbitrary/include/linux/pageblock-flags.h	2007-05-01 16:02:51.000000000 +0100
@@ -1,6 +1,6 @@
 /*
  * Macros for manipulating and testing flags related to a
- * MAX_ORDER_NR_PAGES block of pages.
+ * large contiguous block of pages.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -35,6 +35,10 @@ enum pageblock_bits {
 	NR_PAGEBLOCK_BITS
 };
 
+/* Each pages_per_mobility_block of pages has NR_PAGEBLOCK_BITS */
+extern unsigned long nr_pages_pageblock;
+extern int pageblock_order;
+
 /* Forward declaration */
 struct page;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-004_temporary/mm/page_alloc.c linux-2.6.21-rc7-mm2-005_group_arbitrary/mm/page_alloc.c
--- linux-2.6.21-rc7-mm2-004_temporary/mm/page_alloc.c	2007-04-27 22:04:34.000000000 +0100
+++ linux-2.6.21-rc7-mm2-005_group_arbitrary/mm/page_alloc.c	2007-05-01 19:54:18.000000000 +0100
@@ -58,6 +58,8 @@ unsigned long totalram_pages __read_most
 unsigned long totalreserve_pages __read_mostly;
 long nr_swap_pages;
 int percpu_pagelist_fraction;
+unsigned long nr_pages_pageblock;
+int pageblock_order;
 
 static void __free_pages_ok(struct page *page, unsigned int order);
 
@@ -721,7 +723,7 @@ static int fallbacks[MIGRATE_TYPES][MIGR
 
 /*
  * Move the free pages in a range to the free lists of the requested type.
- * Note that start_page and end_pages are not aligned in a MAX_ORDER_NR_PAGES
+ * Note that start_page and end_pages are not aligned in a pageblock
  * boundary. If alignment is required, use move_freepages_block()
  */
 int move_freepages(struct zone *zone,
@@ -771,10 +773,10 @@ int move_freepages_block(struct zone *zo
 	struct page *start_page, *end_page;
 
 	start_pfn = page_to_pfn(page);
-	start_pfn = start_pfn & ~(MAX_ORDER_NR_PAGES-1);
+	start_pfn = start_pfn & ~(nr_pages_pageblock-1);
 	start_page = pfn_to_page(start_pfn);
-	end_page = start_page + MAX_ORDER_NR_PAGES - 1;
-	end_pfn = start_pfn + MAX_ORDER_NR_PAGES - 1;
+	end_page = start_page + nr_pages_pageblock - 1;
+	end_pfn = start_pfn + nr_pages_pageblock - 1;
 
 	/* Do not cross zone boundaries */
 	if (start_pfn < zone->zone_start_pfn)
@@ -838,14 +840,14 @@ static struct page *__rmqueue_fallback(s
 			 * back for a reclaimable kernel allocation, be more
 			 * agressive about taking ownership of free pages
 			 */
-			if (unlikely(current_order >= MAX_ORDER / 2) ||
+			if (unlikely(current_order >= pageblock_order / 2) ||
 					start_migratetype == MIGRATE_RECLAIMABLE) {
 				unsigned long pages;
 				pages = move_freepages_block(zone, page,
 								start_migratetype);
 
 				/* Claim the whole block if over half of it is free */
-				if ((pages << current_order) >= (1 << (MAX_ORDER-2)))
+				if ((pages << current_order) >= (1 << (pageblock_order-2)))
 					set_pageblock_migratetype(page,
 								start_migratetype);
 
@@ -858,7 +860,7 @@ static struct page *__rmqueue_fallback(s
 			__mod_zone_page_state(zone, NR_FREE_PAGES,
 							-(1UL << order));
 
-			if (current_order == MAX_ORDER - 1)
+			if (current_order == pageblock_order)
 				set_pageblock_migratetype(page,
 							start_migratetype);
 
@@ -2253,14 +2255,16 @@ void __meminit build_all_zonelists(void)
 	 * made on memory-hotadd so a system can start with mobility
 	 * disabled and enable it later
 	 */
-	if (vm_total_pages < (MAX_ORDER_NR_PAGES * MIGRATE_TYPES))
+	if (vm_total_pages < (nr_pages_pageblock * MIGRATE_TYPES))
 		page_group_by_mobility_disabled = 1;
 	else
 		page_group_by_mobility_disabled = 0;
 
-	printk("Built %i zonelists, mobility grouping %s.  Total pages: %ld\n",
+	printk("Built %i zonelists, mobility grouping %s at order %d. "
+		"Total pages: %ld\n",
 			num_online_nodes(),
 			page_group_by_mobility_disabled ? "off" : "on",
+			pageblock_order,
 			vm_total_pages);
 }
 
@@ -2333,7 +2337,7 @@ static inline unsigned long wait_table_b
 #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
 
 /*
- * Mark a number of MAX_ORDER_NR_PAGES blocks as MIGRATE_RESERVE. The number
+ * Mark a number of pageblocks as MIGRATE_RESERVE. The number
  * of blocks reserved is based on zone->pages_min. The memory within the
  * reserve will tend to store contiguous free pages. Setting min_free_kbytes
  * higher will lead to a bigger reserve which will get freed as contiguous
@@ -2348,9 +2352,10 @@ static void setup_zone_migrate_reserve(s
 	/* Get the start pfn, end pfn and the number of blocks to reserve */
 	start_pfn = zone->zone_start_pfn;
 	end_pfn = start_pfn + zone->spanned_pages;
-	reserve = roundup(zone->pages_min, MAX_ORDER_NR_PAGES) >> (MAX_ORDER-1);
+	reserve = roundup(zone->pages_min, nr_pages_pageblock) >>
+							pageblock_order;
 
-	for (pfn = start_pfn; pfn < end_pfn; pfn += MAX_ORDER_NR_PAGES) {
+	for (pfn = start_pfn; pfn < end_pfn; pfn += nr_pages_pageblock) {
 		if (!pfn_valid(pfn))
 			continue;
 		page = pfn_to_page(pfn);
@@ -2425,7 +2430,7 @@ void __meminit memmap_init_zone(unsigned
 		 * the start are marked MIGRATE_RESERVE by
 		 * setup_zone_migrate_reserve()
 		 */
-		if ((pfn & (MAX_ORDER_NR_PAGES-1)))
+		if ((pfn & (nr_pages_pageblock-1)))
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
 		INIT_LIST_HEAD(&page->lru);
@@ -3129,8 +3134,8 @@ static void __meminit calculate_node_tot
 #ifndef CONFIG_SPARSEMEM
 /*
  * Calculate the size of the zone->blockflags rounded to an unsigned long
- * Start by making sure zonesize is a multiple of MAX_ORDER-1 by rounding up
- * Then figure 1 NR_PAGEBLOCK_BITS worth of bits per MAX_ORDER-1, finally
+ * Start by making sure zonesize is a multiple of pageblock_order by rounding up
+ * Then figure 1 NR_PAGEBLOCK_BITS worth of bits per pageblock, finally
  * round what is now in bits to nearest long in bits, then return it in
  * bytes.
  */
@@ -3138,8 +3143,8 @@ static unsigned long __init usemap_size(
 {
 	unsigned long usemapsize;
 
-	usemapsize = roundup(zonesize, MAX_ORDER_NR_PAGES);
-	usemapsize = usemapsize >> (MAX_ORDER-1);
+	usemapsize = roundup(zonesize, nr_pages_pageblock);
+	usemapsize = usemapsize >> pageblock_order;
 	usemapsize *= NR_PAGEBLOCK_BITS;
 	usemapsize = roundup(usemapsize, 8 * sizeof(unsigned long));
 
@@ -3161,6 +3166,26 @@ static void inline setup_usemap(struct p
 				struct zone *zone, unsigned long zonesize) {}
 #endif /* CONFIG_SPARSEMEM */
 
+/* Initialise the number of pages represented by NR_PAGEBLOCK_BITS */
+void __init initonce_nr_pages_pageblock(void)
+{
+	/* There will never be a 1:1 mapping, it makes no sense */
+	if (nr_pages_pageblock)
+		return;
+
+#ifdef CONFIG_HUGETLB_PAGE
+	/*
+	 * Assume the largest contiguous order of interest is a huge page.
+	 * This value may be variable depending on boot parameters on IA64
+	 */
+	pageblock_order = HUGETLB_PAGE_ORDER;
+#else
+	/* If huge pages are not in use, group based on MAX_ORDER */
+	pageblock_order = MAX_ORDER-1;
+#endif
+	nr_pages_pageblock = 1 << pageblock_order;
+}
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -3241,6 +3266,7 @@ static void __meminit free_area_init_cor
 		if (!size)
 			continue;
 
+		initonce_nr_pages_pageblock();
 		setup_usemap(pgdat, zone, size);
 		ret = init_currently_empty_zone(zone, zone_start_pfn,
 						size, MEMMAP_EARLY);
@@ -4132,15 +4158,15 @@ static inline int pfn_to_bitidx(struct z
 {
 #ifdef CONFIG_SPARSEMEM
 	pfn &= (PAGES_PER_SECTION-1);
-	return (pfn >> (MAX_ORDER-1)) * NR_PAGEBLOCK_BITS;
+	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
 #else
 	pfn = pfn - zone->zone_start_pfn;
-	return (pfn >> (MAX_ORDER-1)) * NR_PAGEBLOCK_BITS;
+	return (pfn >> pageblock_order) * NR_PAGEBLOCK_BITS;
 #endif /* CONFIG_SPARSEMEM */
 }
 
 /**
- * get_pageblock_flags_group - Return the requested group of flags for the MAX_ORDER_NR_PAGES block of pages
+ * get_pageblock_flags_group - Return the requested group of flags for the nr_pages_pageblock block of pages
  * @page: The page within the block of interest
  * @start_bitidx: The first bit of interest to retrieve
  * @end_bitidx: The last bit of interest

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
