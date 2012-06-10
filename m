Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id BDA446B0075
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 06:50:18 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id jm19so3841575bkc.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 03:50:18 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 09/10] mm: frontswap: split out function to clear a page out
Date: Sun, 10 Jun 2012 12:51:07 +0200
Message-Id: <1339325468-30614-10-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, konrad.wilk@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 mm/frontswap.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index 7da55a3..c056f6e 100644
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
