Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9AD526B006C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 00:17:46 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Wed, 27 Jun 2012 00:17:45 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id EF8DD6E804B
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 00:17:42 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5R4HgLJ40108126
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 00:17:42 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5R4HZ4g019961
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 01:17:41 -0300
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 5/5] [RFC][HACK] mm: Change memory management of anonymous pages on swapless systems
Date: Wed, 27 Jun 2012 00:17:15 -0400
Message-Id: <1340770635-9909-6-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1340770635-9909-1-git-send-email-john.stultz@linaro.org>
References: <1340770635-9909-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Taras Glek <tgek@mozilla.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Due to my newbie-ness, the following may not be precise, but
I think it conveys the intent of what I'm trying to do here.

Anonymous memory is tracked on two LRU lists: LRU_INACTIVE_ANON
and LRU_ACTIVE_ANON. This split is useful when we need to free
up pages and are trying to decide what to swap out.

However, on systems that do no have swap, this partition is less
clear. In many cases the code avoids aging active anonymous pages
onto the inactive list. However in some cases pages do get moved
to the inactive list, but we never call writepage, as there isn't
anything to swap out.

This patch changes some of the active/inactive list management of
anonymous memory when there is no swap. In that case pages are
always added to the active lru. The intent is that since anonymous
pages cannot be swapped out, they all shoudld be active.

The one exception is volatile pages, which can be moved to
the inactive lru by calling deactivate_page().

In addition, I've changed the logic so we also do try to shrink
the inactive anonymous lru, and call writepage. This should only
be done if there are volatile pages on the inactive lru.

This allows us to purge volatile pages in writepage when the system
does not have swap.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: Android Kernel Team <kernel-team@android.com>
CC: Robert Love <rlove@google.com>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Hugh Dickins <hughd@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Rik van Riel <riel@redhat.com>
CC: Dmitry Adamushko <dmitry.adamushko@gmail.com>
CC: Dave Chinner <david@fromorbit.com>
CC: Neil Brown <neilb@suse.de>
CC: Andrea Righi <andrea@betterlinux.com>
CC: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
CC: Taras Glek <tgek@mozilla.com>
CC: Mike Hommey <mh@glandium.org>
CC: Jan Kara <jack@suse.cz>
CC: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
CC: Michel Lespinasse <walken@google.com>
CC: Minchan Kim <minchan@kernel.org>
CC: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/pagevec.h |    5 +----
 include/linux/swap.h    |   23 +++++++++++++++--------
 mm/swap.c               |   13 ++++++++++++-
 mm/vmscan.c             |    9 ---------
 4 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 2aa12b8..e1312a5 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -22,6 +22,7 @@ struct pagevec {
 
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
+void __pagevec_lru_add_anon(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
@@ -64,10 +65,6 @@ static inline void pagevec_release(struct pagevec *pvec)
 		__pagevec_release(pvec);
 }
 
-static inline void __pagevec_lru_add_anon(struct pagevec *pvec)
-{
-	__pagevec_lru_add(pvec, LRU_INACTIVE_ANON);
-}
 
 static inline void __pagevec_lru_add_active_anon(struct pagevec *pvec)
 {
diff --git a/include/linux/swap.h b/include/linux/swap.h
index c84ec68..639936f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -238,14 +238,6 @@ extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
 
-/**
- * lru_cache_add: add a page to the page lists
- * @page: the page to add
- */
-static inline void lru_cache_add_anon(struct page *page)
-{
-	__lru_cache_add(page, LRU_INACTIVE_ANON);
-}
 
 static inline void lru_cache_add_file(struct page *page)
 {
@@ -474,5 +466,20 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 }
 
 #endif /* CONFIG_SWAP */
+
+/**
+ * lru_cache_add: add a page to the page lists
+ * @page: the page to add
+ */
+static inline void lru_cache_add_anon(struct page *page)
+{
+	int lru = LRU_INACTIVE_ANON;
+	if (!total_swap_pages)
+		lru = LRU_ACTIVE_ANON;
+
+	__lru_cache_add(page, lru);
+}
+
+
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */
diff --git a/mm/swap.c b/mm/swap.c
index 4e7e2ec..f35df46 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -691,7 +691,7 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	SetPageLRU(page_tail);
 
 	if (page_evictable(page_tail, NULL)) {
-		if (PageActive(page)) {
+		if (PageActive(page) || !total_swap_pages) {
 			SetPageActive(page_tail);
 			active = 1;
 			lru = LRU_ACTIVE_ANON;
@@ -755,6 +755,17 @@ void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
 }
 EXPORT_SYMBOL(__pagevec_lru_add);
 
+
+void __pagevec_lru_add_anon(struct pagevec *pvec)
+{
+	if (!total_swap_pages)
+		__pagevec_lru_add(pvec, LRU_ACTIVE_ANON);
+	else
+		__pagevec_lru_add(pvec, LRU_INACTIVE_ANON);
+}
+EXPORT_SYMBOL(__pagevec_lru_add_anon);
+
+
 /**
  * pagevec_lookup - gang pagecache lookup
  * @pvec:	Where the resulting pages are placed
diff --git a/mm/vmscan.c b/mm/vmscan.c
index eeb3bc9..52d8ad9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1597,15 +1597,6 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	if (!global_reclaim(sc))
 		force_scan = true;
 
-	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || (nr_swap_pages <= 0)) {
-		noswap = 1;
-		fraction[0] = 0;
-		fraction[1] = 1;
-		denominator = 1;
-		goto out;
-	}
-
 	anon  = get_lru_size(lruvec, LRU_ACTIVE_ANON) +
 		get_lru_size(lruvec, LRU_INACTIVE_ANON);
 	file  = get_lru_size(lruvec, LRU_ACTIVE_FILE) +
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
