From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200001122111.NAA68159@google.engr.sgi.com>
Subject: [RFC] 2.3.39 zone balancing
Date: Wed, 12 Jan 2000 13:11:55 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@transmeta.com, mingo@chiara.csoma.elte.hu, andrea@suse.de, alan@lxorguk.ukuu.org.uk
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Folks,

This is a note and a patch about memory balancing. Please read
the new file Documentation/vm/balance in the patch that explains
the logic behind the patch. 

Comments and feedback welcome. Thanks.

Kanoj

--- mm/page_alloc.c	Tue Jan 11 11:00:31 2000
+++ mm/page_alloc.c	Tue Jan 11 23:59:35 2000
@@ -6,6 +6,7 @@
  *  Support of BIGMEM added by Gerhard Wichert, Siemens AG, July 1999
  *  Reshaped it to be a zoned allocator, Ingo Molnar, Red Hat, 1999
  *  Discontiguous memory support, Kanoj Sarcar, SGI, Nov 1999
+ *  Zone balancing, Kanoj Sarcar, SGI, Jan 2000
  */
 
 #include <linux/config.h>
@@ -197,11 +198,25 @@
 #define ZONE_BALANCED(zone) \
 	(((zone)->free_pages > (zone)->pages_low) && (!(zone)->low_on_memory))
 
+static inline unsigned long classfree(zone_t *zone)
+{
+	unsigned long free = 0;
+	zone_t *z = zone->zone_pgdat->node_zones;
+
+	while (z != zone) {
+		free += z->free_pages;
+		z++;
+	}
+	free += zone->free_pages;
+	return(free);
+}
+
 static inline int zone_balance_memory (zone_t *zone, int gfp_mask)
 {
 	int freed;
+	unsigned long free = classfree(zone);
 
-	if (zone->free_pages >= zone->pages_low) {
+	if (free >= zone->pages_low) {
 		if (!zone->low_on_memory)
 			return 1;
 		/*
@@ -208,7 +223,7 @@
 		 * Simple hysteresis: exit 'low memory mode' if
 		 * the upper limit has been reached:
 		 */
-		if (zone->free_pages >= zone->pages_high) {
+		if (free >= zone->pages_high) {
 			zone->low_on_memory = 0;
 			return 1;
 		}
@@ -220,12 +235,7 @@
 	 * state machine, but do not try to free pages
 	 * ourselves.
 	 */
-	if (!(gfp_mask & __GFP_WAIT))
-		return 1;
-
-	current->flags |= PF_MEMALLOC;
 	freed = try_to_free_pages(gfp_mask, zone);
-	current->flags &= ~PF_MEMALLOC;
 
 	if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
 		return 0;
@@ -232,6 +242,7 @@
 	return 1;
 }
 
+#if 0
 /*
  * We are still balancing memory in a global way:
  */
@@ -260,17 +271,13 @@
 	 * state machine, but do not try to free pages
 	 * ourselves.
 	 */
-	if (!(gfp_mask & __GFP_WAIT))
-		return 1;
-
-	current->flags |= PF_MEMALLOC;
 	freed = try_to_free_pages(gfp_mask, zone);
-	current->flags &= ~PF_MEMALLOC;
 
 	if (!freed && !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
 		return 0;
 	return 1;
 }
+#endif
 
 /*
  * This is the 'heart' of the zoned buddy allocator:
@@ -340,7 +347,7 @@
  * The main chunk of the balancing code is in this offline branch:
  */
 balance:
-	if (!balance_memory(z, gfp_mask))
+	if (!zone_balance_memory(z, gfp_mask))
 		goto nopage;
 	goto ready;
 }
@@ -513,6 +520,7 @@
 	unsigned long i, j;
 	unsigned long map_size;
 	unsigned int totalpages, offset;
+	unsigned int cumulative = 0;
 
 	totalpages = 0;
 	for (i = 0; i < MAX_NR_ZONES; i++) {
@@ -565,7 +573,7 @@
 	offset = lmem_map - mem_map;	
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		zone_t *zone = pgdat->node_zones + j;
-		unsigned long mask = -1;
+		unsigned long mask;
 		unsigned long size;
 
 		size = zones_size[j];
@@ -579,13 +587,11 @@
 			continue;
 
 		zone->offset = offset;
-		/*
-		 * It's unnecessery to balance the high memory zone
-		 */
-		if (j != ZONE_HIGHMEM) {
-			zone->pages_low = freepages.low;
-			zone->pages_high = freepages.high;
-		}
+		cumulative += size;
+		mask = (cumulative >> 7);
+		if (mask < 1) mask = 1;
+		zone->pages_low = mask*2;
+		zone->pages_high = mask*3;
 		zone->low_on_memory = 0;
 
 		for (i = 0; i < size; i++) {
@@ -598,6 +604,7 @@
 		}
 
 		offset += size;
+		mask = -1;
 		for (i = 0; i < MAX_ORDER; i++) {
 			unsigned long bitmap_size;
 
--- mm/vmscan.c	Tue Jan 11 11:00:31 2000
+++ mm/vmscan.c	Tue Jan 11 23:29:41 2000
@@ -534,8 +534,11 @@
 	int retval = 1;
 
 	wake_up_process(kswapd_process);
-	if (gfp_mask & __GFP_WAIT)
+	if (gfp_mask & __GFP_WAIT) {
+		current->flags |= PF_MEMALLOC;
 		retval = do_try_to_free_pages(gfp_mask, zone);
+		current->flags &= ~PF_MEMALLOC;
+	}
 	return retval;
 }
 
--- Documentation/vm/balance	Wed Jan 12 13:05:36 2000
+++ Documentation/vm/balance	Wed Jan 12 13:05:29 2000
@@ -0,0 +1,60 @@
+Started Jan 2000 by Kanoj Sarcar <kanoj@sgi.com>
+
+Memory balancing is _only_ needed for non __GFP_WAIT allocations.
+
+There are two reasons to be requesting non __GFP_WAIT allocations:
+the caller can not sleep (typically intr context), or does not want
+to incur cost overheads of page stealing and possible swap io.
+
+In the absence of non sleepable allocation requests, it seems detrimental
+to be doing balancing. Page reclamation can be kicked off lazily, that
+is, only when needed (aka zone free memory is 0), instead of making it
+a proactive process.
+
+That being said, the kernel should try to fulfill requests for direct
+mapped pages from the direct mapped pool, instead of falling back on
+the dma pool, so as to keep the dma pool filled for dma requests (atomic
+or not). A similar argument applies to highmem and direct mapped pages.
+OTOH, if there is a lot of free dma pages, it is preferable to satisfy
+regular memory requests by allocating one from the dma pool, instead
+of incurring the overhead of regular zone balancing.
+
+In 2.2, memory balancing/page reclamation would kick off only when the
+_total_ number of free pages fell below 1/64 th of total memory. With the
+right ratio of dma and regular memory, it is quite possible that balancing
+would not be done even when the dma zone was completely empty. 2.2 has
+been running production machines of varying memory sizes, and seems to be
+doing fine even with the presence of this problem. In 2.3, due to
+HIGHMEM, this problem is aggravated.
+
+In 2.3, zone balancing can be done in one of two ways: depending on the
+zone size (and possibly of the size of lower class zones), we can decide
+at init time how many free pages we should aim for while balancing any
+zone. The good part is, while balancing, we do not need to look at sizes
+of lower class zones, the bad part is, we might do too frequent balancing
+due to ignoring possibly lower usage in the lower class zones. Also,
+with a slight change in the allocation routine, it is possible to reduce
+the memclass() macro to be a simple equality.
+
+Another possible solution is that we balance only when the free memory
+of a zone _and_ all its lower class zones falls below 1/64th of the
+total memory in the zone and its lower class zones. This fixes the 2.2
+balancing problem, and stays as close to 2.2 behavior as possible. Also,
+the balancing algorithm works the same way on the various architectures,
+which have different numbers and types of zones. If we wanted to get
+fancy, we could assign different weights to free pages in different
+zones in the future.
+
+Note that if the size of the regular zone is huge compared to dma zone,
+it becomes less significant to consider the free dma pages while
+deciding whether to balance the regular zone. The first solution
+becomes more attractive then.
+
+The appended patch implements the second solution. It also "fixes" two
+problems: first, kswapd is woken up as in 2.2 on low memory conditions
+for non-sleepable allocations. Second, the HIGHMEM zone is also balanced,
+so as to give a fighting chance for replace_with_highmem() to get a
+HIGHMEM page, as well as to ensure that HIGHMEM allocations do not
+fall back into regular zone. This also makes sure that HIGHMEM pages
+are not leaked (for example, in situations where a HIGHMEM page is in 
+the swapcache but is not being used by anyone)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
