Message-ID: <42E4852D.7010209@yahoo.com.au>
Date: Mon, 25 Jul 2005 16:22:37 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: PageReserved removal from swsusp
References: <42E44294.5020408@yahoo.com.au> <1122265909.6144.106.camel@localhost> <42E46FF5.5080805@yahoo.com.au>
In-Reply-To: <42E46FF5.5080805@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------030502020705030203070202"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ncunningham@cyclades.com
Cc: Linux Memory Management <linux-mm@kvack.org>, Pavel Machek <pavel@suse.cz>, Hugh Dickins <hugh@veritas.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030502020705030203070202
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:

> I'm currently playing around with trying to reuse an existing flag
> to get this information (instead of PageReserved). But it doesn't seem
> like a big problem if we have to fall back to the above.
> 

OK, with the attached patch (on top of the PageReserved removal patches)
things work nicely. However I'm not sure that I really like the use of
flags == 0xffffffff to indicate the page is unusable. For one thing it
may confuse things that walk physical pages, and for another it can
easily break if someone clears a flag of an 'unusable' page.

-- 
SUSE Labs, Novell Inc.


--------------030502020705030203070202
Content-Type: text/plain;
 name="mm-PageUnusable.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-PageUnusable.patch"

Index: linux-2.6/arch/i386/mm/init.c
===================================================================
--- linux-2.6.orig/arch/i386/mm/init.c
+++ linux-2.6/arch/i386/mm/init.c
@@ -273,7 +273,7 @@ void __init one_highpage_init(struct pag
 		__free_page(page);
 		totalhigh_pages++;
 	} else
-		SetPageReserved(page);
+		SetPageUnusable(page);
 }
 
 #ifdef CONFIG_NUMA
@@ -573,7 +573,7 @@ void __init mem_init(void)
 		/*
 		 * Only count reserved RAM pages
 		 */
-		if (page_is_ram(tmp) && PageReserved(pfn_to_page(tmp)))
+		if (!PageUnusable(pfn_to_page(tmp)) && PageReserved(pfn_to_page(tmp)))
 			reservedpages++;
 
 	set_highmem_pages_init(bad_ppro);
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -306,6 +306,9 @@ extern void __mod_page_state(unsigned lo
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#define PageUnusable(page)	((page)->flags == 0xffffffff)
+#define SetPageUnusable(page)	((page)->flags = 0xffffffff)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);
Index: linux-2.6/kernel/power/swsusp.c
===================================================================
--- linux-2.6.orig/kernel/power/swsusp.c
+++ linux-2.6/kernel/power/swsusp.c
@@ -433,16 +433,8 @@ static int save_highmem_zone(struct zone
 		if (!pfn_valid(pfn))
 			continue;
 		page = pfn_to_page(pfn);
-		/*
-		 * This condition results from rvmalloc() sans vmalloc_32()
-		 * and architectural memory reservations. This should be
-		 * corrected eventually when the cases giving rise to this
-		 * are better understood.
-		 */
-		if (PageReserved(page)) {
-			printk("highmem reserved page?!\n");
+		if (PageUnusable(page))
 			continue;
-		}
 		BUG_ON(PageNosave(page));
 		if (PageNosaveFree(page))
 			continue;
@@ -528,6 +520,8 @@ static int saveable(struct zone * zone, 
 		return 0;
 
 	page = pfn_to_page(pfn);
+	if (PageUnusable(page))
+		return 0;
 	if (PageNosave(page))
 		return 0;
 	if (pfn_is_nosave(pfn)) {
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -576,22 +576,29 @@ void mark_free_pages(struct zone *zone)
 	unsigned long zone_pfn, flags;
 	int order;
 	struct list_head *curr;
+	struct page *page;
 
 	if (!zone->spanned_pages)
 		return;
 
 	spin_lock_irqsave(&zone->lock, flags);
-	for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn)
-		ClearPageNosaveFree(pfn_to_page(zone_pfn + zone->zone_start_pfn));
+	for (zone_pfn = 0; zone_pfn < zone->spanned_pages; ++zone_pfn) {
+		page = pfn_to_page(zone_pfn + zone->zone_start_pfn);
+		if (PageUnusable(page))
+			continue;
+		ClearPageNosaveFree(page);
+	}
 
 	for (order = MAX_ORDER - 1; order >= 0; --order)
 		list_for_each(curr, &zone->free_area[order].free_list) {
-			unsigned long start_pfn, i;
+			unsigned long i;
 
-			start_pfn = page_to_pfn(list_entry(curr, struct page, lru));
-
-			for (i=0; i < (1<<order); i++)
-				SetPageNosaveFree(pfn_to_page(start_pfn+i));
+			page = list_entry(curr, struct page, lru);
+			for (i=0; i < (1<<order); i++) {
+				if (PageUnusable(page+i))
+					continue;
+				SetPageNosaveFree(page+i);
+			}
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
 }

--------------030502020705030203070202--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
