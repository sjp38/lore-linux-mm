Date: Wed, 21 Nov 2007 23:58:49 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
Message-ID: <20071121235849.GG31674@csn.ul.ie>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com> <20071115162706.4b9b9e2a.akpm@linux-foundation.org> <20071121222059.GC31674@csn.ul.ie> <Pine.LNX.4.64.0711211434290.3809@schroedinger.engr.sgi.com> <20071121230041.GE31674@csn.ul.ie> <Pine.LNX.4.64.0711211530370.4383@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711211530370.4383@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, apw@shadowen.org, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On (21/11/07 15:34), Christoph Lameter didst pronounce:
> On Wed, 21 Nov 2007, Mel Gorman wrote:
> 
> > I thought this would be a good idea too but in testing mode, I didn't
> > want to fiddle with patches much in case I unconsciously screwed it up.
> 
> Okay here is a patch against the combining patch that just forgets about 
> coldness:
> 

I didn't think you were going to roll a patch and had queued this
slightly more agressive version. I think it is a superset of what your
patch does.

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc2-mm1-single_pcplist/include/linux/gfp.h linux-2.6.24-rc2-mm1-single_pcplist_noheat/include/linux/gfp.h
--- linux-2.6.24-rc2-mm1-single_pcplist/include/linux/gfp.h	2007-11-15 11:27:49.000000000 +0000
+++ linux-2.6.24-rc2-mm1-single_pcplist_noheat/include/linux/gfp.h	2007-11-21 23:38:29.000000000 +0000
@@ -221,7 +221,7 @@ extern unsigned long FASTCALL(get_zeroed
 extern void FASTCALL(__free_pages(struct page *page, unsigned int order));
 extern void FASTCALL(free_pages(unsigned long addr, unsigned int order));
 extern void FASTCALL(free_hot_page(struct page *page));
-extern void FASTCALL(free_cold_page(struct page *page));
+#define free_cold_page(page) free_hot_page(page)
 
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr),0)
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc2-mm1-single_pcplist/mm/page_alloc.c linux-2.6.24-rc2-mm1-single_pcplist_noheat/mm/page_alloc.c
--- linux-2.6.24-rc2-mm1-single_pcplist/mm/page_alloc.c	2007-11-21 23:55:45.000000000 +0000
+++ linux-2.6.24-rc2-mm1-single_pcplist_noheat/mm/page_alloc.c	2007-11-21 23:07:00.000000000 +0000
@@ -910,7 +910,6 @@ static void drain_pages(unsigned int cpu
 {
 	unsigned long flags;
 	struct zone *zone;
-	int i;
 
 	for_each_zone(zone) {
 		struct per_cpu_pageset *pset;
@@ -984,7 +983,7 @@ void mark_free_pages(struct zone *zone)
 /*
  * Free a 0-order page
  */
-static void fastcall free_hot_cold_page(struct page *page, int cold)
+void fastcall free_hot_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
@@ -1004,10 +1003,7 @@ static void fastcall free_hot_cold_page(
 	pcp = &zone_pcp(zone, get_cpu())->pcp;
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
-	if (cold)
-		list_add_tail(&page->lru, &pcp->list);
-	else
-		list_add(&page->lru, &pcp->list);
+	list_add(&page->lru, &pcp->list);
 	set_page_private(page, get_pageblock_migratetype(page));
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
@@ -1018,16 +1014,6 @@ static void fastcall free_hot_cold_page(
 	put_cpu();
 }
 
-void fastcall free_hot_page(struct page *page)
-{
-	free_hot_cold_page(page, 0);
-}
-	
-void fastcall free_cold_page(struct page *page)
-{
-	free_hot_cold_page(page, 1);
-}
-
 /*
  * split_page takes a non-compound higher-order page, and splits it into
  * n (1<<order) sub-pages: page[0..n]
@@ -1056,7 +1042,6 @@ static struct page *buffered_rmqueue(str
 {
 	unsigned long flags;
 	struct page *page;
-	int cold = !!(gfp_flags & __GFP_COLD);
 	int cpu;
 	int migratetype = allocflags_to_migratetype(gfp_flags);
 
@@ -1075,15 +1060,9 @@ again:
 		}
 
 		/* Find a page of the appropriate migrate type */
-		if (cold) {
-			list_for_each_entry_reverse(page, &pcp->list, lru)
-				if (page_private(page) == migratetype)
-					break;
-		} else {
-			list_for_each_entry(page, &pcp->list, lru)
-				if (page_private(page) == migratetype)
-					break;
-		}
+		list_for_each_entry(page, &pcp->list, lru)
+			if (page_private(page) == migratetype)
+				break;
 
 		/* Allocate more to the pcp list if necessary */
 		if (unlikely(&page->lru == &pcp->list)) {
@@ -1746,7 +1725,7 @@ void __pagevec_free(struct pagevec *pvec
 	int i = pagevec_count(pvec);
 
 	while (--i >= 0)
-		free_hot_cold_page(pvec->pages[i], pvec->cold);
+		free_hot_page(pvec->pages[i]);
 }
 
 fastcall void __free_pages(struct page *page, unsigned int order)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
