Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 8DD6B6B0257
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 08:58:42 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/4] mm: page_alloc: remove order assumption from __free_pages_bootmem()
Date: Tue, 13 Dec 2011 14:58:28 +0100
Message-Id: <1323784711-1937-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1323784711-1937-1-git-send-email-hannes@cmpxchg.org>
References: <1323784711-1937-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Even though bootmem passes an order with the page to be freed,
__free_pages_bootmem() assumes that 1 << order is always BITS_PER_LONG
if non-zero.  While this happens to be true, it's not really robust.
Remove that assumption and use 1 << order instead.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/page_alloc.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2b8ba3a..4d5e91c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -703,13 +703,14 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
 		set_page_refcounted(page);
 		__free_page(page);
 	} else {
-		int loop;
+		unsigned int nr_pages = 1 << order;
+		unsigned int loop;
 
 		prefetchw(page);
-		for (loop = 0; loop < BITS_PER_LONG; loop++) {
+		for (loop = 0; loop < nr_pages; loop++) {
 			struct page *p = &page[loop];
 
-			if (loop + 1 < BITS_PER_LONG)
+			if (loop + 1 < nr_pages)
 				prefetchw(p + 1);
 			__ClearPageReserved(p);
 			set_page_count(p, 0);
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
