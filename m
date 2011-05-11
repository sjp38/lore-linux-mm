Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6466B0025
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:17:07 -0400 (EDT)
Received: by pvc12 with SMTP id 12so459030pvc.14
        for <linux-mm@kvack.org>; Wed, 11 May 2011 10:17:05 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v1 01/10] Make clear description of isolate/putback functions
Date: Thu, 12 May 2011 02:16:40 +0900
Message-Id: <f16e108699b5fca93ebed81d306c9db06a266e61.1305132792.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1305132792.git.minchan.kim@gmail.com>
References: <cover.1305132792.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1305132792.git.minchan.kim@gmail.com>
References: <cover.1305132792.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

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
index e4a5c91..a04f68a 100644
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
index 292582c..a6a87c0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -555,10 +555,10 @@ int remove_mapping(struct address_space *mapping, struct page *page)
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
@@ -1200,6 +1200,10 @@ static unsigned long clear_active_flags(struct list_head *page_list,
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
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
