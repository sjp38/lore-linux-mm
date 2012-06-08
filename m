Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id EB6656B0081
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 15:15:03 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wd18so3738633obb.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 12:15:03 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v2 09/10] mm: frontswap: split out function to clear a page out
Date: Fri,  8 Jun 2012 21:15:18 +0200
Message-Id: <1339182919-11432-10-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
References: <1339182919-11432-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 0250c20..0930c39 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -120,6 +120,12 @@ void __frontswap_init(unsigned type)
 }
 EXPORT_SYMBOL(__frontswap_init);
 
+static inline void __frontswap_clear(struct swap_info_struct *sis, pgoff_t offset)
+{
+	frontswap_clear(sis, offset);
+	atomic_dec(&sis->frontswap_pages);
+}
+
 /*
  * "Store" data from a page to frontswap and associate it with the page's
  * swaptype and offset.  Page must be locked and in the swap cache.
@@ -152,10 +158,8 @@ int __frontswap_store(struct page *page)
 		  the (older) page from frontswap
 		 */
 		inc_frontswap_failed_stores();
-		if (dup) {
-			frontswap_clear(sis, offset);
-			atomic_dec(&sis->frontswap_pages);
-		}
+		if (dup)
+			__frontswap_clear(sis, offset);
 	}
 	if (frontswap_writethrough_enabled)
 		/* report failure so swap also writes to swap device */
@@ -200,8 +204,7 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
 	trace_frontswap_invalidate_page(type, offset, sis, frontswap_test(sis, offset));
 	if (frontswap_test(sis, offset)) {
 		frontswap_ops.invalidate_page(type, offset);
-		atomic_dec(&sis->frontswap_pages);
-		frontswap_clear(sis, offset);
+		__frontswap_clear(sis, offset);
 		inc_frontswap_invalidates();
 	}
 }
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
