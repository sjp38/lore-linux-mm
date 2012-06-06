Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 8655B6B009A
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 06:54:38 -0400 (EDT)
Received: by mail-yw0-f41.google.com with SMTP id 47so6180655yhr.14
        for <linux-mm@kvack.org>; Wed, 06 Jun 2012 03:54:38 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 10/11] mm: frontswap: split out function to clear a page out
Date: Wed,  6 Jun 2012 12:55:14 +0200
Message-Id: <1338980115-2394-10-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: konrad.wilk@oracle.com, dan.magenheimer@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index c0cd8bc..92e2e7b 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -99,6 +99,12 @@ void __frontswap_init(unsigned type)
 }
 EXPORT_SYMBOL(__frontswap_init);
 
+static inline void __frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
+{
+	frontswap_clear(sis, offset);
+	atomic_dec(&sis->frontswap_pages);
+}
+
 /*
  * "Put" data from a page to frontswap and associate it with the page's
  * swaptype and offset.  Page must be locked and in the swap cache.
@@ -131,10 +137,8 @@ int __frontswap_put_page(struct page *page)
 		  the (older) page from frontswap
 		 */
 		frontswap_failed_puts++;
-		if (dup) {
-			frontswap_clear(sis, offset);
-			atomic_dec(&sis->frontswap_pages);
-		}
+		if (dup)
+			__frontswap_clear(sis, offset);
 	}
 	if (frontswap_writethrough_enabled)
 		/* report failure so swap also writes to swap device */
@@ -179,8 +183,7 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
 	trace_frontswap_invalidate_page(type, offset, sis, frontswap_test(sis, offset));
 	if (frontswap_test(sis, offset)) {
 		frontswap_ops.invalidate_page(type, offset);
-		atomic_dec(&sis->frontswap_pages);
-		frontswap_clear(sis, offset);
+		__frontswap_clear(sis, offset);
 		frontswap_invalidates++;
 	}
 }
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
