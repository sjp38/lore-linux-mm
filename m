Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E17D66B01F1
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 09:38:21 -0400 (EDT)
Received: by qyk37 with SMTP id 37so1210269qyk.8
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 06:38:21 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [RESEND][PATCH] __isolate_lru_page:skip unneeded "not"
Date: Thu,  1 Apr 2010 21:37:35 +0800
Message-Id: <1270129055-3656-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

PageActive(page) will return int 0 or 1, mode is also int 0 or 1,
they are comparible so "not" is unneeded to be sure to boolean
values.
I also collected the ISOLATE_BOTH check together.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/vmscan.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e0e5f15..ce9ee85 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -862,16 +862,11 @@ int __isolate_lru_page(struct page *page, int mode, int file)
 	if (!PageLRU(page))
 		return ret;
 
-	/*
-	 * When checking the active state, we need to be sure we are
-	 * dealing with comparible boolean values.  Take the logical not
-	 * of each.
-	 */
-	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
-		return ret;
-
-	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
-		return ret;
+	if (mode != ISOLATE_BOTH) {
+		if ((PageActive(page) != mode) ||
+			(page_is_file_cache(page) != file))
+				return ret;
+	}
 
 	/*
 	 * When this function is being called for lumpy reclaim, we
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
