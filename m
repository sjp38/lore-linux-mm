Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 89B226B0037
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 08:24:12 -0400 (EDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 4/7] mm: munlock: batch NR_MLOCK zone state updates
Date: Mon, 19 Aug 2013 14:23:39 +0200
Message-Id: <1376915022-12741-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?J=C3=B6rn=20Engel?= <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

Depending on previous batch which introduced batched isolation in
munlock_vma_range(), we can batch also the updates of NR_MLOCK
page stats. After the whole pagevec is processed for page isolation,
the stats are updated only once with the number of successful isolations.
There were however no measurable perfomance gains.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: JA?rn Engel <joern@logfs.org>
---
 mm/mlock.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 4a19838..95c152d 100644
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
 			if (PageLRU(page)) {
 				lruvec = mem_cgroup_page_lruvec(page, zone);
 				lru = page_lru(page);
@@ -272,8 +270,10 @@ skip_munlock:
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
