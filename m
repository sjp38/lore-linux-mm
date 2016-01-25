Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6D95E6B0253
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 05:03:27 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l65so56912840wmf.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 02:03:27 -0800 (PST)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id bf2si1137150wjb.6.2016.01.25.02.03.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 02:03:25 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 519A39899A
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:03:25 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 1/2] mm: filemap: Remove redundant code in do_read_cache_page
Date: Mon, 25 Jan 2016 10:03:23 +0000
Message-Id: <1453716204-20409-2-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1453716204-20409-1-git-send-email-mgorman@techsingularity.net>
References: <1453716204-20409-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

do_read_cache_page and __read_cache_page duplicates page filler code
when filling the page for the first time. This patch simply removes the
duplicate logic.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
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
