Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C4F7B6B01EF
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 22:40:34 -0400 (EDT)
Received: by qyk33 with SMTP id 33so4927784qyk.28
        for <linux-mm@kvack.org>; Mon, 05 Apr 2010 19:40:32 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] __isolate_lru_page: change code style
Date: Tue,  6 Apr 2010 10:40:22 +0800
Message-Id: <1270521622-8551-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

As Andrew said:
"
it wouldn't be a good and maintainable change -
one point in using enumerations such as ISOLATE_* is to hide their real
values.  Adding code which implicitly "knows" that a particular
enumerated identifier has a particular underlying value is rather
grubby and fragile.
It's also a bit fragile to assume that a true/false-returning C
function (PageActive) will always return 0 or 1.  It's a common C idiom
for such functions to return 0 or non-zero (not necessarily 1).

So a clean and maintainable implementation of

       if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
               return ret;

would be

       if (mode != ISOLATE_BOTH &&
                       ((PageActive(page) && mode == ISOLATE_ACTIVE) ||
                        (!PageActive(page) && mode ==
ISOLATE_INACTIVE)))
               return ret;
"
I changed my "skip unneeded 'not' patch" following his idea.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/vmscan.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e0e5f15..9d1e52a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -862,12 +862,9 @@ int __isolate_lru_page(struct page *page, int mode, int file)
 	if (!PageLRU(page))
 		return ret;
 
-	/*
-	 * When checking the active state, we need to be sure we are
-	 * dealing with comparible boolean values.  Take the logical not
-	 * of each.
-	 */
-	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
+	if (mode != ISOLATE_BOTH &&
+		((PageActive(page) && mode == ISOLATE_ACTIVE) ||
+		 (!PageActive(page) && mode == ISOLATE_INACTIVE)))
 		return ret;
 
 	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
