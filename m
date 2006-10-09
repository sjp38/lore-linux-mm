From: Paul Jackson <pj@sgi.com>
Date: Mon, 09 Oct 2006 03:54:51 -0700
Message-Id: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
Subject: [RFC] memory page alloc minor cleanups
Sender: owner-linux-mm@kvack.org
From: Paul Jackson <pj@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Andi Kleen <ak@suse.de>, mbligh@google.com, rohitseth@google.com, menage@google.com, Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

While coding up various alternative performance improvements
to the zonelist scanning below __alloc_pages(), I tripped
over a few minor code style and layout nits in mm/page_alloc.c

I noticed that Nick had a couple of these same nits in one of
his patches - so I hesitate to push this patch without sync'ing
with him, to minimize conflicts over more important patches.

The removal of the NULL zone check needs approval by someone
who knows this code better than I do -- I could have broken
something with this change.

Changes include:
 1) s/freeliest/freelist/ spelling fix
 2) Check for NULL *z zone seems useless - even if it could
    happen, so what?  Perhaps we should have a check later on
    if we are faced with an allocation request that is not
    allowed to fail - shouldn't that be a serious kernel error,
    passing an empty zonelist with a mandate to not fail?
 3) Initializing 'z' to zonelist->zones can wait until after the
    first get_page_from_freelist() fails; we only use 'z' in the
    wakeup_kswapd() loop, so let's initialize 'z' there, in a
    'for' loop.  Seems clearer.
 4) Remove superfluous braces around a break
 5) Fix a couple errant spaces
 6) Adjust indentation on the cpuset_zone_allowed() check, to match
    the lines just before it -- seems easier to read in this case.
 7) Add another set of braces to the zone_watermark_ok logic

Changes (4) and (7) I stole from some patch of Nick's.

Signed-off-by: Paul Jackson <pj@sgi.com>

---
 mm/page_alloc.c |   27 ++++++++++-----------------
 1 file changed, 10 insertions(+), 17 deletions(-)

--- 2.6.18-mm3.orig/mm/page_alloc.c	2006-10-06 17:30:43.330219854 -0700
+++ 2.6.18-mm3/mm/page_alloc.c	2006-10-07 11:08:13.493099651 -0700
@@ -497,7 +497,7 @@ static void free_one_page(struct zone *z
 	spin_lock(&zone->lock);
 	zone->all_unreclaimable = 0;
 	zone->pages_scanned = 0;
-	__free_one_page(page, zone ,order);
+	__free_one_page(page, zone, order);
 	spin_unlock(&zone->lock);
 }
 
@@ -937,7 +937,7 @@ int zone_watermark_ok(struct zone *z, in
 }
 
 /*
- * get_page_from_freeliest goes through the zonelist trying to allocate
+ * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
  */
 static struct page *
@@ -959,8 +959,8 @@ get_page_from_freelist(gfp_t gfp_mask, u
 			zone->zone_pgdat != zonelist->zones[0]->zone_pgdat))
 				break;
 		if ((alloc_flags & ALLOC_CPUSET) &&
-				!cpuset_zone_allowed(zone, gfp_mask))
-			continue;
+			!cpuset_zone_allowed(zone, gfp_mask))
+				continue;
 
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
 			unsigned long mark;
@@ -970,17 +970,18 @@ get_page_from_freelist(gfp_t gfp_mask, u
 				mark = zone->pages_low;
 			else
 				mark = zone->pages_high;
-			if (!zone_watermark_ok(zone , order, mark,
-				    classzone_idx, alloc_flags))
+			if (!zone_watermark_ok(zone, order, mark,
+				    classzone_idx, alloc_flags)) {
 				if (!zone_reclaim_mode ||
 				    !zone_reclaim(zone, gfp_mask, order))
 					continue;
+			}
 		}
 
 		page = buffered_rmqueue(zonelist, zone, order, gfp_mask);
-		if (page) {
+		if (page)
 			break;
-		}
+
 	} while (*(++z) != NULL);
 	return page;
 }
@@ -1056,21 +1057,13 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 	might_sleep_if(wait);
 
 restart:
-	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
-
-	if (unlikely(*z == NULL)) {
-		/* Should this ever happen?? */
-		return NULL;
-	}
-
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
 				zonelist, ALLOC_WMARK_LOW|ALLOC_CPUSET);
 	if (page)
 		goto got_pg;
 
-	do {
+	for (z = zonelist->zones; *z; z++)
 		wakeup_kswapd(*z, order);
-	} while (*(++z));
 
 	/*
 	 * OK, we're below the kswapd watermark and have kicked background

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
