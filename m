Date: Thu, 4 May 2006 11:14:22 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: assert/crash in __rmqueue() when enabling CONFIG_NUMA
Message-ID: <20060504091422.GA2346@elte.hu>
References: <20060419112130.GA22648@elte.hu> <p73aca07whs.fsf@bragg.suse.de> <20060502070618.GA10749@elte.hu> <200605020905.29400.ak@suse.de> <44576688.6050607@mbligh.org> <44576BF5.8070903@yahoo.com.au> <20060504013239.GG19859@localhost> <20060504083708.GA30853@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060504083708.GA30853@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bob Picco <bob.picco@hp.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

* Ingo Molnar <mingo@elte.hu> wrote:

> > The patch below isn't compile tested or correct for those cases where 
> > alloc_remap is called or where arch code has allocated node_mem_map 
> > for CONFIG_FLAT_NODE_MEM_MAP. It's just conveying what I believe the 
> > issue is.
> 
> thx. One pair of parentheses were missing i think - see the delta fix 
> below. I'll try it.

the same easy crash still happens if i enable CONFIG_NUMA:

 zone c214e600 (HighMem):
 pfn: 00037d00
 zone->zone_start_pfn: 00037e00
 zone->spanned_pages: 00007e00
 zone->zone_start_pfn + zone->spanned_pages: 0003fc00

 [<c010574a>] do_invalid_op+0x63/0x93
 [<c0104a0b>] error_code+0x4f/0x54
 [<c0164d48>] get_page_from_freelist+0x13e/0x565
 [<c01651dd>] __alloc_pages+0x6e/0x325
 [<c017a6c9>] alloc_page_vma+0x80/0x86
 [<c016e2ae>] __handle_mm_fault+0x1e7/0xd00
 [<c10fe9af>] do_page_fault+0x339/0x7c5
 [<c0104a0b>] error_code+0x4f/0x54

see the debug patch below.

	Ingo

----
From: Ingo Molnar <mingo@elte.hu>

do buddy zone size checks unconditionally.

Signed-off-by: Ingo Molnar <mingo@elte.hu>

----

 mm/page_alloc.c |   31 ++++++++++++++++++++++++-------
 1 files changed, 24 insertions(+), 7 deletions(-)

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -101,17 +101,32 @@ static int page_outside_zone_boundaries(
 			ret = 1;
 	} while (zone_span_seqretry(zone, seq));
 
+#define P(x) printk("%s: %08lx\n", #x, x)
+
+	if (ret) {
+		printk("zone %p (%s):\n", zone, zone->name);
+		P(pfn);
+		P(zone->zone_start_pfn);
+		P(zone->spanned_pages);
+		P(zone->zone_start_pfn + zone->spanned_pages);
+	}
+
 	return ret;
 }
 
 static int page_is_consistent(struct zone *zone, struct page *page)
 {
-#ifdef CONFIG_HOLES_IN_ZONE
-	if (!pfn_valid(page_to_pfn(page)))
+	if (!pfn_valid(page_to_pfn(page))) {
+		printk("BUG: pfn: %08lx, page: %p\n",
+			page_to_pfn(page), page);
+		dump_stack();
 		return 0;
-#endif
-	if (zone != page_zone(page))
+	}
+	if (zone != page_zone(page)) {
+		printk("zone: %p != %p == page_zone(%p)\n",
+			zone, page_zone(page), page);
 		return 0;
+	}
 
 	return 1;
 }
@@ -309,10 +324,12 @@ __find_combined_index(unsigned long page
  */
 static inline int page_is_buddy(struct page *page, int order)
 {
-#ifdef CONFIG_HOLES_IN_ZONE
-	if (!pfn_valid(page_to_pfn(page)))
+	if (!pfn_valid(page_to_pfn(page))) {
+		printk("BUG: pfn: %08lx, page: %p, order: %d\n",
+			page_to_pfn(page), page, order);
+		dump_stack();
 		return 0;
-#endif
+	}
 
 	if (PageBuddy(page) && page_order(page) == order) {
 		BUG_ON(page_count(page) != 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
