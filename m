Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BC3276B0089
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 12:29:52 -0500 (EST)
Received: by pvc30 with SMTP id 30so2307145pvc.14
        for <linux-mm@kvack.org>; Sun, 05 Dec 2010 09:29:51 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v4 1/7] Fix checkpatch's report in swap.c
Date: Mon,  6 Dec 2010 02:29:09 +0900
Message-Id: <f4bc70172f1e6c7357480af503b7a01cd96ccadd.1291568905.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1291568905.git.minchan.kim@gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1291568905.git.minchan.kim@gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

checkpatch reports following problems.
It's a very annoying. This patch fixes it.

barrios@barrios-desktop:~/linux-2.6$ ./scripts/checkpatch.pl -f mm/swap.c
WARNING: line over 80 characters
+		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
+EXPORT_SYMBOL(mark_page_accessed);

ERROR: code indent should use tabs where possible
+  ^I^I}$

WARNING: please, no space before tabs
+  ^I^I}$

WARNING: please, no spaces at the start of a line
+  ^I^I}$

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
+EXPORT_SYMBOL(__pagevec_release);

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
+EXPORT_SYMBOL(____pagevec_lru_add);

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
+EXPORT_SYMBOL(pagevec_lookup);

WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
+EXPORT_SYMBOL(pagevec_lookup_tag);

total: 1 errors, 8 warnings, 517 lines checked

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/swap.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 3f48542..d5822b0 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -118,7 +118,8 @@ static void pagevec_move_tail(struct pagevec *pvec)
 			zone = pagezone;
 			spin_lock(&zone->lru_lock);
 		}
-		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
+		if (PageLRU(page) && !PageActive(page) &&
+					!PageUnevictable(page)) {
 			int lru = page_lru_base_type(page);
 			list_move_tail(&page->lru, &zone->lru[lru].list);
 			pgmoved++;
@@ -212,7 +213,6 @@ void mark_page_accessed(struct page *page)
 		SetPageReferenced(page);
 	}
 }
-
 EXPORT_SYMBOL(mark_page_accessed);
 
 void __lru_cache_add(struct page *page, enum lru_list lru)
@@ -371,7 +371,7 @@ void release_pages(struct page **pages, int nr, int cold)
 			}
 			__pagevec_free(&pages_to_free);
 			pagevec_reinit(&pages_to_free);
-  		}
+		}
 	}
 	if (zone)
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
@@ -396,7 +396,6 @@ void __pagevec_release(struct pagevec *pvec)
 	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
 	pagevec_reinit(pvec);
 }
-
 EXPORT_SYMBOL(__pagevec_release);
 
 /*
@@ -438,7 +437,6 @@ void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
 	release_pages(pvec->pages, pvec->nr, pvec->cold);
 	pagevec_reinit(pvec);
 }
-
 EXPORT_SYMBOL(____pagevec_lru_add);
 
 /*
@@ -481,7 +479,6 @@ unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 	pvec->nr = find_get_pages(mapping, start, nr_pages, pvec->pages);
 	return pagevec_count(pvec);
 }
-
 EXPORT_SYMBOL(pagevec_lookup);
 
 unsigned pagevec_lookup_tag(struct pagevec *pvec, struct address_space *mapping,
@@ -491,7 +488,6 @@ unsigned pagevec_lookup_tag(struct pagevec *pvec, struct address_space *mapping,
 					nr_pages, pvec->pages);
 	return pagevec_count(pvec);
 }
-
 EXPORT_SYMBOL(pagevec_lookup_tag);
 
 /*
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
