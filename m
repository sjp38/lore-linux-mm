Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id A4E336B00A3
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:45:22 -0500 (EST)
Received: by iacb35 with SMTP id b35so33332352iac.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:45:22 -0800 (PST)
Date: Sat, 31 Dec 2011 23:45:19 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 4/6] mm: remove del_page_from_lru, add page_off_lru
In-Reply-To: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112312343570.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

del_page_from_lru() repeats del_page_from_lru_list(), also working out
which LRU the page was on, clearing the relevant bits.  Decouple those
functions: remove del_page_from_lru() and add page_off_lru().

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/mm_inline.h |   15 +++++++++------
 mm/swap.c                 |    4 ++--
 2 files changed, 11 insertions(+), 8 deletions(-)

--- mmotm.orig/include/linux/mm_inline.h	2011-12-31 14:49:11.044022084 -0800
+++ mmotm/include/linux/mm_inline.h	2011-12-31 14:55:00.860030864 -0800
@@ -54,8 +54,14 @@ static inline enum lru_list page_lru_bas
 	return LRU_INACTIVE_ANON;
 }
 
-static inline void
-del_page_from_lru(struct zone *zone, struct page *page)
+/**
+ * page_off_lru - which LRU list was page on? clearing its lru flags.
+ * @page: the page to test
+ *
+ * Returns the LRU list a page was on, as an index into the array of LRU
+ * lists; and clears its Unevictable or Active flags, ready for freeing.
+ */
+static inline enum lru_list page_off_lru(struct page *page)
 {
 	enum lru_list lru;
 
@@ -69,9 +75,7 @@ del_page_from_lru(struct zone *zone, str
 			lru += LRU_ACTIVE;
 		}
 	}
-	mem_cgroup_lru_del_list(page, lru);
-	list_del(&page->lru);
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -hpage_nr_pages(page));
+	return lru;
 }
 
 /**
@@ -92,7 +96,6 @@ static inline enum lru_list page_lru(str
 		if (PageActive(page))
 			lru += LRU_ACTIVE;
 	}
-
 	return lru;
 }
 
--- mmotm.orig/mm/swap.c	2011-12-30 21:29:54.415350465 -0800
+++ mmotm/mm/swap.c	2011-12-31 14:55:00.860030864 -0800
@@ -53,7 +53,7 @@ static void __page_cache_release(struct
 		spin_lock_irqsave(&zone->lru_lock, flags);
 		VM_BUG_ON(!PageLRU(page));
 		__ClearPageLRU(page);
-		del_page_from_lru(zone, page);
+		del_page_from_lru_list(zone, page, page_off_lru(page));
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
 }
@@ -617,7 +617,7 @@ void release_pages(struct page **pages,
 			}
 			VM_BUG_ON(!PageLRU(page));
 			__ClearPageLRU(page);
-			del_page_from_lru(zone, page);
+			del_page_from_lru_list(zone, page, page_off_lru(page));
 		}
 
 		list_add(&page->lru, &pages_to_free);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
