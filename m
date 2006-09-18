Subject: [PATCH] mm: exempt pcp alloc from watermarks
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <450D5310.50004@yahoo.com.au>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	 <20060914220011.2be9100a.akpm@osdl.org>
	 <20060914234926.9b58fd77.pj@sgi.com>
	 <20060915002325.bffe27d1.akpm@osdl.org>
	 <20060915012810.81d9b0e3.akpm@osdl.org>
	 <20060915203816.fd260a0b.pj@sgi.com>
	 <20060915214822.1c15c2cb.akpm@osdl.org>
	 <20060916043036.72d47c90.pj@sgi.com>
	 <20060916081846.e77c0f89.akpm@osdl.org>
	 <20060917022834.9d56468a.pj@sgi.com>	<450D1A94.7020100@yahoo.com.au>
	 <20060917041525.4ddbd6fa.pj@sgi.com>	<450D434B.4080702@yahoo.com.au>
	 <20060917061922.45695dcb.pj@sgi.com>  <450D5310.50004@yahoo.com.au>
Content-Type: text/plain
Date: Mon, 18 Sep 2006 14:44:55 +0200
Message-Id: <1158583495.23551.53.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Paul Jackson <pj@sgi.com>, akpm@osdl.org, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Sun, 2006-09-17 at 23:52 +1000, Nick Piggin wrote:

> What we could do then, is allocate pages in batches (we already do),
> but only check watermarks if we have to go to the buddly allocator
> (we don't currently do this, but really should anyway, considering
> that the watermark checks are based on pages in the buddy allocator
> rather than pages in buddy + pcp).

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/page_alloc.c |   57 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 53 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -767,6 +767,42 @@ void split_page(struct page *page, unsig
 		set_page_refcounted(page + i);
 }
 
+static struct page *get_pcp_page(struct zonelist *zonelist, struct zone *zone,
+				 gfp_t gfp_mask, int order)
+{
+	unsigned long flags;
+	int cold, cpu;
+	struct per_cpu_pages *pcp;
+	struct page *page;
+
+	if (unlikely(order != 0))
+		return NULL;
+
+	cold = !!(gfp_mask & __GFP_COLD);
+again:
+	page = NULL;
+	cpu = get_cpu();
+	pcp = &zone_pcp(zone, cpu)->pcp[cold];
+	local_irq_save(flags);
+	if (pcp->count) {
+		page = list_entry(pcp->list.next, struct page, lru);
+		list_del(&page->lru);
+		pcp->count--;
+		__count_zone_vm_events(PGALLOC, zone, 1);
+		zone_statistics(zonelist, zone);
+	}
+	local_irq_restore(flags);
+	put_cpu();
+
+	if (page) {
+		BUG_ON(bad_range(zone, page));
+		if (prep_new_page(page, 0, gfp_mask))
+			goto again;
+	}
+
+	return page;
+}
+
 /*
  * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
  * we cheat by calling it from here, in the order > 0 path.  Saves a branch
@@ -781,13 +817,17 @@ static struct page *buffered_rmqueue(str
 	int cpu;
 
 again:
-	cpu  = get_cpu();
+	cpu = get_cpu();
 	if (likely(order == 0)) {
 		struct per_cpu_pages *pcp;
 
 		pcp = &zone_pcp(zone, cpu)->pcp[cold];
 		local_irq_save(flags);
-		if (!pcp->count) {
+		/*
+		 * Even though we checked the pcps earlier we could have
+		 * been preempted and scheduled to another cpu.
+		 */
+		if (likely(!pcp->count)) {
 			pcp->count += rmqueue_bulk(zone, 0,
 						pcp->batch, &pcp->list);
 			if (unlikely(!pcp->count))
@@ -882,6 +922,16 @@ get_page_from_freelist(gfp_t gfp_mask, u
 
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
 			unsigned long mark;
+
+			/*
+			 * If there are pages in the pcp lists take those
+			 * without checking the watermarks, since the zone
+			 * free_pages count is without the pcp count.
+			 */
+			page = get_pcp_page(zonelist, *z, order, gfp_mask);
+			if (page)
+				break;
+
 			if (alloc_flags & ALLOC_WMARK_MIN)
 				mark = (*z)->pages_min;
 			else if (alloc_flags & ALLOC_WMARK_LOW)
@@ -896,9 +946,8 @@ get_page_from_freelist(gfp_t gfp_mask, u
 		}
 
 		page = buffered_rmqueue(zonelist, *z, order, gfp_mask);
-		if (page) {
+		if (page)
 			break;
-		}
 	} while (*(++z) != NULL);
 	return page;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
