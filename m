Date: Wed, 21 Nov 2007 15:34:25 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
In-Reply-To: <20071121230041.GE31674@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0711211530370.4383@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com>
 <20071115162706.4b9b9e2a.akpm@linux-foundation.org> <20071121222059.GC31674@csn.ul.ie>
 <Pine.LNX.4.64.0711211434290.3809@schroedinger.engr.sgi.com>
 <20071121230041.GE31674@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, apw@shadowen.org, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Nov 2007, Mel Gorman wrote:

> I thought this would be a good idea too but in testing mode, I didn't
> want to fiddle with patches much in case I unconsciously screwed it up.

Okay here is a patch against the combining patch that just forgets about 
coldness:

---
 mm/page_alloc.c |   18 ++++--------------
 1 file changed, 4 insertions(+), 14 deletions(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-11-21 15:33:14.993673533 -0800
+++ linux-2.6/mm/page_alloc.c	2007-11-21 15:33:20.697205473 -0800
@@ -991,10 +991,7 @@ static void fastcall free_hot_cold_page(
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
@@ -1043,7 +1040,6 @@ static struct page *buffered_rmqueue(str
 {
 	unsigned long flags;
 	struct page *page;
-	int cold = !!(gfp_flags & __GFP_COLD);
 	int cpu;
 	int migratetype = allocflags_to_migratetype(gfp_flags);
 
@@ -1062,15 +1058,9 @@ again:
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
