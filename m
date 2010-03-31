Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4167F6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 10:10:46 -0400 (EDT)
Received: by iwn40 with SMTP id 40so98036iwn.1
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 07:10:42 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] __isolate_lru_page: skip unneeded mode check
Date: Wed, 31 Mar 2010 22:10:31 +0800
Message-Id: <1270044631-8576-1-git-send-email-user@bob-laptop>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Bob Liu <lliubbo@gmail.com>

Whether mode is ISOLATE_BOTH or not, we should compare
page_is_file_cache with argument file.

And there is no more need not when checking the active state.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/vmscan.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e0e5f15..34d7e3d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -862,15 +862,10 @@ int __isolate_lru_page(struct page *page, int mode, int file)
 	if (!PageLRU(page))
 		return ret;
 
-	/*
-	 * When checking the active state, we need to be sure we are
-	 * dealing with comparible boolean values.  Take the logical not
-	 * of each.
-	 */
-	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
+	if (mode != ISOLATE_BOTH && (PageActive(page) != mode))
 		return ret;
 
-	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
+	if (page_is_file_cache(page) != file)
 		return ret;
 
 	/*
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
