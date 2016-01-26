Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 05AC46B0009
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:09:34 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id b14so132315653wmb.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 06:09:33 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id mb1si2023572wjb.176.2016.01.26.06.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 06:09:32 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id B2A281C1D10
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 14:09:31 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/2] mm: filemap: Remove redundant code in do_read_cache_page
Date: Tue, 26 Jan 2016 14:09:29 +0000
Message-Id: <1453817370-10399-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1453817370-10399-1-git-send-email-mgorman@techsingularity.net>
References: <1453817370-10399-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

do_read_cache_page and __read_cache_page duplicates page filler code
when filling the page for the first time. This patch simply removes the
duplicate logic.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 mm/filemap.c | 43 ++++++++++++-------------------------------
 1 file changed, 12 insertions(+), 31 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index bc943867d68c..aa38593d0cd5 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2283,7 +2283,7 @@ static struct page *wait_on_page_read(struct page *page)
 	return page;
 }
 
-static struct page *__read_cache_page(struct address_space *mapping,
+static struct page *do_read_cache_page(struct address_space *mapping,
 				pgoff_t index,
 				int (*filler)(void *, struct page *),
 				void *data,
@@ -2305,31 +2305,19 @@ static struct page *__read_cache_page(struct address_space *mapping,
 			/* Presumably ENOMEM for radix tree node */
 			return ERR_PTR(err);
 		}
+
+filler:
 		err = filler(data, page);
 		if (err < 0) {
 			page_cache_release(page);
-			page = ERR_PTR(err);
-		} else {
-			page = wait_on_page_read(page);
+			return ERR_PTR(err);
 		}
-	}
-	return page;
-}
-
-static struct page *do_read_cache_page(struct address_space *mapping,
-				pgoff_t index,
-				int (*filler)(void *, struct page *),
-				void *data,
-				gfp_t gfp)
-
-{
-	struct page *page;
-	int err;
 
-retry:
-	page = __read_cache_page(mapping, index, filler, data, gfp);
-	if (IS_ERR(page))
-		return page;
+		page = wait_on_page_read(page);
+		if (IS_ERR(page))
+			return page;
+		goto out;
+	}
 	if (PageUptodate(page))
 		goto out;
 
@@ -2337,21 +2325,14 @@ static struct page *do_read_cache_page(struct address_space *mapping,
 	if (!page->mapping) {
 		unlock_page(page);
 		page_cache_release(page);
-		goto retry;
+		goto repeat;
 	}
 	if (PageUptodate(page)) {
 		unlock_page(page);
 		goto out;
 	}
-	err = filler(data, page);
-	if (err < 0) {
-		page_cache_release(page);
-		return ERR_PTR(err);
-	} else {
-		page = wait_on_page_read(page);
-		if (IS_ERR(page))
-			return page;
-	}
+	goto filler;
+
 out:
 	mark_page_accessed(page);
 	return page;
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
