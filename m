Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 6C7BA6B0034
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 08:24:14 -0400 (EDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 6/7] mm: munlock: remove redundant get_page/put_page pair on the fast path
Date: Mon, 19 Aug 2013 14:23:41 +0200
Message-Id: <1376915022-12741-7-git-send-email-vbabka@suse.cz>
In-Reply-To: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?J=C3=B6rn=20Engel?= <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

The performance of the fast path in munlock_vma_range() can be further improved
by avoiding atomic ops of a redundant get_page()/put_page() pair.

When calling get_page() during page isolation, we already have the pin from
follow_page_mask(). This pin will be then returned by __pagevec_lru_add(),
after which we do not reference the pages anymore.

After this patch, an 8% speedup was measured for munlocking a 56GB large memory
area with THP disabled.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: JA?rn Engel <joern@logfs.org>
---
 mm/mlock.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 43c1828..77ddd6a 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -297,8 +297,10 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
 			if (PageLRU(page)) {
 				lruvec = mem_cgroup_page_lruvec(page, zone);
 				lru = page_lru(page);
-
-				get_page(page);
+				/*
+				 * We already have pin from follow_page_mask()
+				 * so we can spare the get_page() here.
+				 */
 				ClearPageLRU(page);
 				del_page_from_lru_list(page, lruvec, lru);
 			} else {
@@ -330,25 +332,25 @@ skip_munlock:
 			lock_page(page);
 			if (!__putback_lru_fast_prepare(page, &pvec_putback,
 					&pgrescued)) {
-				/* Slow path */
+				/*
+				 * Slow path. We don't want to lose the last
+				 * pin before unlock_page()
+				 */
+				get_page(page); /* for putback_lru_page() */
 				__munlock_isolated_page(page);
 				unlock_page(page);
+				put_page(page); /* from follow_page_mask() */
 			}
 		}
 	}
 
-	/* Phase 3: page putback for pages that qualified for the fast path */
+	/*
+	 * Phase 3: page putback for pages that qualified for the fast path
+	 * This will also call put_page() to return pin from follow_page_mask()
+	 */
 	if (pagevec_count(&pvec_putback))
 		__putback_lru_fast(&pvec_putback, pgrescued);
 
-	/* Phase 4: put_page to return pin from follow_page_mask() */
-	for (i = 0; i < nr; i++) {
-		struct page *page = pvec->pages[i];
-
-		if (page)
-			put_page(page);
-	}
-
 	pagevec_reinit(pvec);
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
