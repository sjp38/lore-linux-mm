Date: Fri, 18 Aug 2006 20:36:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: ZVC: Overstep counters
Message-ID: <Pine.LNX.4.64.0608182035220.3060@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Increments and decrements are usually grouped rather than mixed. We
can optimize the inc and dec functions for that case.

Increment and decrement the counters by 50% more than the threshold
in those cases and set the differential accordingly. This decreases
the need to update the atomic counters.

The idea came originally from Andrew Morton. The overstepping
alone was sufficient to address the contention issue found when updating
the global and the per zone counters from 160 processors.

Also remove some code in dec_zone_page_state.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc3/mm/vmstat.c
===================================================================
--- linux-2.6.18-rc3.orig/mm/vmstat.c	2006-07-29 23:15:36.000000000 -0700
+++ linux-2.6.18-rc3/mm/vmstat.c	2006-08-05 13:23:04.716084749 -0700
@@ -190,8 +190,8 @@ static void __inc_zone_state(struct zone
 	(*p)++;
 
 	if (unlikely(*p > STAT_THRESHOLD)) {
-		zone_page_state_add(*p, zone, item);
-		*p = 0;
+		zone_page_state_add(*p + STAT_THRESHOLD / 2, zone, item);
+		*p = -STAT_THRESHOLD / 2;
 	}
 }
 
@@ -209,8 +209,8 @@ void __dec_zone_page_state(struct page *
 	(*p)--;
 
 	if (unlikely(*p < -STAT_THRESHOLD)) {
-		zone_page_state_add(*p, zone, item);
-		*p = 0;
+		zone_page_state_add(*p - STAT_THRESHOLD / 2, zone, item);
+		*p = STAT_THRESHOLD /2;
 	}
 }
 EXPORT_SYMBOL(__dec_zone_page_state);
@@ -239,19 +239,9 @@ EXPORT_SYMBOL(inc_zone_page_state);
 void dec_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	unsigned long flags;
-	struct zone *zone;
-	s8 *p;
 
-	zone = page_zone(page);
 	local_irq_save(flags);
-	p = diff_pointer(zone, item);
-
-	(*p)--;
-
-	if (unlikely(*p < -STAT_THRESHOLD)) {
-		zone_page_state_add(*p, zone, item);
-		*p = 0;
-	}
+	__dec_zone_page_state(page, item);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(dec_zone_page_state);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
