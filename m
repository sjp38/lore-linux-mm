Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 01D738D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 20:46:42 -0500 (EST)
Received: by gyd10 with SMTP id 10so1463460gyd.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 17:46:41 -0800 (PST)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH] mm: fix dubious code in __count_immobile_pages()
Date: Fri, 18 Feb 2011 10:46:26 +0900
Message-Id: <1297993586-3514-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

When pfn_valid_within() failed 'iter' was incremented twice.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_alloc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e8b02771ccea..bf83d1c1d648 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5380,10 +5380,9 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
 	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
 		unsigned long check = pfn + iter;
 
-		if (!pfn_valid_within(check)) {
-			iter++;
+		if (!pfn_valid_within(check))
 			continue;
-		}
+
 		page = pfn_to_page(check);
 		if (!page_count(page)) {
 			if (PageBuddy(page))
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
