Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id A0C566B0144
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:20 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/22] mm: page allocator: Do not disable IRQs just to update stats
Date: Wed,  8 May 2013 17:02:59 +0100
Message-Id: <1368028987-8369-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The fast path of the allocator disables/enables interrupts to update
statistics but these statistics are only consumed by userspace. When
the page allocator always had to disable IRQs it was ok as we already
took the penalty but now with the IRQ-unsafe magazine it is overkill
to disable IRQs just to have accurate statistics. This patch does
not disable IRQs for updating statistics and accepts that the counters
might be slightly inaccurate.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c014b7a..3d619e3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1381,7 +1381,6 @@ struct page *rmqueue(struct zone *preferred_zone,
 			struct zone *zone, unsigned int order,
 			gfp_t gfp_flags, int migratetype)
 {
-	unsigned long flags;
 	struct page *page = NULL;
 
 	if (unlikely(gfp_flags & __GFP_NOFAIL)) {
@@ -1406,11 +1405,9 @@ again:
 	if (order == 0 && !in_interrupt() && !irqs_disabled())
 		page = rmqueue_magazine(zone, migratetype);
 
-	/* IRQ disabled for buddy list access of updating statistics */
-	local_irq_save(flags);
-
 	if (!page) {
-		spin_lock(&zone->lock);
+		unsigned long flags;
+		spin_lock_irqsave(&zone->lock, flags);
 		page = __rmqueue(zone, order, migratetype);
 		if (!page) {
 			spin_unlock_irqrestore(&zone->lock, flags);
@@ -1418,12 +1415,18 @@ again:
 		}
 		__mod_zone_freepage_state(zone, -(1 << order),
 					get_freepage_migratetype(page));
-		spin_unlock(&zone->lock);
+		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 
+	/*
+	 * NOTE: These are using the non-IRQ safe stats updating which
+	 * means that some updates will be lost. However, these stats
+	 * are not used internally by the VM and collisions are
+	 * expected to be very rare. Disabling/enabling interrupts just
+	 * to have accurate rarely-used counters is overkill.
+	 */
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
-	local_irq_restore(flags);
 
 	VM_BUG_ON(bad_range(zone, page));
 	if (prep_new_page(page, order, gfp_flags))
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
