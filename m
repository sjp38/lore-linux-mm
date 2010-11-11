Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 816936B0098
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 02:55:01 -0500 (EST)
Date: Thu, 11 Nov 2010 18:54:55 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: [patch] mm: find_get_pages_contig fixlet
Message-ID: <20101111075455.GA10210@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Testing ->mapping and ->index without a ref is not stable as the page
may have been reused at this point.

Signed-off-by: Nick Piggin <npiggin@kernel.dk>
---
 mm/filemap.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2010-11-11 18:51:51.000000000 +1100
+++ linux-2.6/mm/filemap.c	2010-11-11 18:51:52.000000000 +1100
@@ -835,9 +835,6 @@ unsigned find_get_pages_contig(struct ad
 		if (radix_tree_deref_retry(page))
 			goto restart;
 
-		if (page->mapping == NULL || page->index != index)
-			break;
-
 		if (!page_cache_get_speculative(page))
 			goto repeat;
 
@@ -847,6 +844,16 @@ unsigned find_get_pages_contig(struct ad
 			goto repeat;
 		}
 
+		/*
+		 * must check mapping and index after taking the ref.
+		 * otherwise we can get both false positives and false
+		 * negatives, which is just confusing to the caller.
+		 */
+		if (page->mapping == NULL || page->index != index) {
+			page_cache_release(page);
+			break;
+		}
+
 		pages[ret] = page;
 		ret++;
 		index++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
