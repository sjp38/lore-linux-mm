Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 921646B0022
	for <linux-mm@kvack.org>; Sun, 29 May 2011 14:14:10 -0400 (EDT)
Received: by pxi10 with SMTP id 10so2040762pxi.8
        for <linux-mm@kvack.org>; Sun, 29 May 2011 11:14:06 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 01/10] Make clear description of isolate/putback functions
Date: Mon, 30 May 2011 03:13:40 +0900
Message-Id: <5f9f6c96ccb344c4ca0dd9c1f06bd21db93fda51.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1306689214.git.minchan.kim@gmail.com>
References: <cover.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1306689214.git.minchan.kim@gmail.com>
References: <cover.1306689214.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>

Commonly, putback_lru_page is used with isolated_lru_page.
The isolated_lru_page picks the page in middle of LRU and
putback_lru_page insert the lru in head of LRU.
It means it could make LRU churning so we have to be very careful.
Let's clear description of isolate/putback functions.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/migrate.c |    2 +-
 mm/vmscan.c  |    8 ++++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 34132f8..819d233 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -68,7 +68,7 @@ int migrate_prep_local(void)
 }
 
 /*
- * Add isolated pages on the list back to the LRU under page lock
+ * Add isolated pages on the list back to the LRU's head under page lock
  * to avoid leaking evictable pages back onto unevictable list.
  */
 void putback_lru_pages(struct list_head *l)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8bfd450..a658dde 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -551,10 +551,10 @@ int remove_mapping(struct address_space *mapping, struct page *page)
 }
 
 /**
- * putback_lru_page - put previously isolated page onto appropriate LRU list
+ * putback_lru_page - put previously isolated page onto appropriate LRU list's head
  * @page: page to be put back to appropriate lru list
  *
- * Add previously isolated @page to appropriate LRU list.
+ * Add previously isolated @page to appropriate LRU list's head
  * Page may still be unevictable for other reasons.
  *
  * lru_lock must not be held, interrupts must be enabled.
@@ -1196,6 +1196,10 @@ static unsigned long clear_active_flags(struct list_head *page_list,
  *     without a stable reference).
  * (2) the lru_lock must not be held.
  * (3) interrupts must be enabled.
+ *
+ * NOTE : This function removes the page from LRU list and putback_lru_page
+ * insert the page to LRU list's head. It means it makes LRU churing so you
+ * have to use the function carefully.
  */
 int isolate_lru_page(struct page *page)
 {
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
