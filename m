Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 5A5396B0037
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 10:32:17 -0400 (EDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 4/6] mm: munlock: batch NR_MLOCK zone state updates
Date: Mon,  5 Aug 2013 16:32:03 +0200
Message-Id: <1375713125-18163-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
References: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: joern@logfs.org
Cc: mgorman@suse.de, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

Depending on previous batch which introduced batched isolation in
munlock_vma_range(), we can batch also the updates of NR_MLOCK
page stats. After the whole pagevec is processed for page isolation,
the stats are updated only once with the number of successful isolations.
There were however no measurable perfomance gains.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mlock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 08689b6..d112e06 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -238,6 +238,7 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 {
 	int i;
 	int nr = pagevec_count(pvec);
+	int delta_munlocked = -nr;
 
 	/* Phase 1: page isolation */
 	spin_lock_irq(&zone->lru_lock);
@@ -248,9 +249,6 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 			struct lruvec *lruvec;
 			int lru;
 
-			/* we have disabled interrupts */
-			__mod_zone_page_state(zone, NR_MLOCK, -1);
-
 			switch (__isolate_lru_page(page,
 						ISOLATE_UNEVICTABLE)) {
 			case 0:
@@ -275,8 +273,10 @@ skip_munlock:
 			 */
 			pvec->pages[i] = NULL;
 			put_page(page);
+			delta_munlocked++;
 		}
 	}
+	__mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
 	spin_unlock_irq(&zone->lru_lock);
 
 	/* Phase 2: page munlock and putback */
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
