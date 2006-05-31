Message-ID: <447DCF5A.7020407@shadowen.org>
Date: Wed, 31 May 2006 18:16:10 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [stable] [PATCH 0/2] Zone boundary alignment fixes, default configuration
References: <447173EF.9090000@shadowen.org> <exportbomb.1148291574@pinky> <20060531001322.GJ18769@moss.sous-sol.org>
In-Reply-To: <20060531001322.GJ18769@moss.sous-sol.org>
Content-Type: multipart/mixed;
 boundary="------------070903070307020504090409"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wright <chrisw@sous-sol.org>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, stable@kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070903070307020504090409
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Chris Wright wrote:
> * Andy Whitcroft (apw@shadowen.org) wrote:
> 
>>I think a concensus is forming that the checks for merging across
>>zones were removed from the buddy allocator without anyone noticing.
>>So I propose that the configuration option UNALIGNED_ZONE_BOUNDARIES
>>default to on, and those architectures which have been auditied
>>for alignment may turn it off.
> 
> 
> So what's the final outcome here for -stable?  The only
> relevant patch upstream appears to be Bob Picco's patch
> <http://kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=e984bb43f7450312ba66fe0e67a99efa6be3b246>

I am not sure we necessarily need to make any changes for stable.  The
lack of alignment checks has been in the mainline tree for a number of
months.  I believe that i386 in the simple cases should be aligned
correctly and that covers the majority of users.

If we are going to make any changes then I'd say we want two patches.
The node_mem_map alignment patch from Bob Picco (as cited above) and the
attached patch.  This is a simplification of the patches currently in
-mm, it should be functionally equivalent to the changes in -mm without
the exclusions and configuration options.

I've just run a regression suite over this one on the machines I have
here without any problems.

Comments?

-apw

--------------070903070307020504090409
Content-Type: text/plain;
 name="zone-allow-unaligned-zone-boundaries-for-2616-stable"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="zone-allow-unaligned-zone-boundaries-for-2616-stable"

From: Andy Whitcroft <apw@shadowen.org>

[Minimal fix for unaligned zone boundaries for stable.]

The buddy allocator has a requirement that boundaries between
contigious zones occur aligned with the the MAX_ORDER ranges.  Where
they do not we will incorrectly merge pages cross zone boundaries.
This can lead to pages from the wrong zone being handed out.

Originally the buddy allocator would check that buddies were in the
same zone by referencing the zone start and end page frame numbers.
This was removed as it became very expensive and the buddy allocator
already made the assumption that zones boundaries were aligned.

It is clear that not all configurations and architectures are
honouring this alignment requirement.  Therefore it seems safest
to reintroduce support for non-aligned zone boundaries.  

This patch introduces a new check when considering a page a buddy
it compares the zone_table index for the two pages and refuses to
merge the pages where they do not match.  The zone_table index is
unique for each node/zone combination when FLATMEM/DISCONTIGMEM
is enabled and for each section/zone combination when SPARSEMEM is
enabled (a SPARSEMEM section is at least a MAX_ORDER size).

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 include/linux/mm.h |    7 +++++--
 mm/page_alloc.c    |   17 +++++++++++------
 2 files changed, 16 insertions(+), 8 deletions(-)
diff -upN reference/include/linux/mm.h current/include/linux/mm.h
--- reference/include/linux/mm.h
+++ current/include/linux/mm.h
@@ -464,10 +464,13 @@ static inline unsigned long page_zonenum
 struct zone;
 extern struct zone *zone_table[];
 
+static inline int page_zone_id(struct page *page)
+{
+	return (page->flags >> ZONETABLE_PGSHIFT) & ZONETABLE_MASK;
+}
 static inline struct zone *page_zone(struct page *page)
 {
-	return zone_table[(page->flags >> ZONETABLE_PGSHIFT) &
-			ZONETABLE_MASK];
+	return zone_table[page_zone_id(page)];
 }
 
 static inline unsigned long page_to_nid(struct page *page)
diff -upN reference/mm/page_alloc.c current/mm/page_alloc.c
--- reference/mm/page_alloc.c
+++ current/mm/page_alloc.c
@@ -270,22 +270,27 @@ __find_combined_index(unsigned long page
  * we can do coalesce a page and its buddy if
  * (a) the buddy is not in a hole &&
  * (b) the buddy is in the buddy system &&
- * (c) a page and its buddy have the same order.
+ * (c) a page and its buddy have the same order &&
+ * (d) a page and its buddy are in the same zone.
  *
  * For recording whether a page is in the buddy system, we use PG_buddy.
  * Setting, clearing, and testing PG_buddy is serialized by zone->lock.
  *
  * For recording page's order, we use page_private(page).
  */
-static inline int page_is_buddy(struct page *page, int order)
+static inline int page_is_buddy(struct page *page, struct page *buddy,
+								int order)
 {
 #ifdef CONFIG_HOLES_IN_ZONE
-	if (!pfn_valid(page_to_pfn(page)))
+	if (!pfn_valid(page_to_pfn(buddy)))
 		return 0;
 #endif
 
-	if (PageBuddy(page) && page_order(page) == order) {
-		BUG_ON(page_count(page) != 0);
+	if (page_zone_id(page) != page_zone_id(buddy))
+		return 0;
+
+	if (PageBuddy(buddy) && page_order(buddy) == order) {
+		BUG_ON(page_count(buddy) != 0);
                return 1;
 	}
        return 0;
@@ -336,7 +341,7 @@ static inline void __free_one_page(struc
 		struct page *buddy;
 
 		buddy = __page_find_buddy(page, page_idx, order);
-		if (!page_is_buddy(buddy, order))
+		if (!page_is_buddy(page, buddy, order))
 			break;		/* Move the buddy up one level. */
 
 		list_del(&buddy->lru);

--------------070903070307020504090409--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
