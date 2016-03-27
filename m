Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0B7266B025F
	for <linux-mm@kvack.org>; Sun, 27 Mar 2016 15:47:52 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id n5so120862600pfn.2
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 12:47:52 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id tr1si20158132pab.135.2016.03.27.12.47.48
        for <linux-mm@kvack.org>;
        Sun, 27 Mar 2016 12:47:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/4] mm: convert make_page_accessed to use compount_page_t()
Date: Sun, 27 Mar 2016 22:47:40 +0300
Message-Id: <1459108060-69891-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459108060-69891-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20160327194649.GA9638@node.shutemov.name>
 <1459108060-69891-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Just for example, convert one function to just created interface.

This way we cut size of the function by third:

function                                     old     new   delta
mark_page_accessed                           310     203    -107

Not-yet-signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/swap.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 09fe5e97714a..1fe072ae6ee1 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -360,9 +360,10 @@ static void __lru_cache_activate_page(struct page *page)
  */
 void mark_page_accessed(struct page *page)
 {
-	page = compound_head(page);
-	if (!PageActive(page) && !PageUnevictable(page) &&
-			PageReferenced(page)) {
+	struct head_page *head = compound_head_t(page);
+	page = &head->page;
+	if (!PageActive(head) && !PageUnevictable(head) &&
+			PageReferenced(head)) {
 
 		/*
 		 * If the page is on the LRU, queue it for activation via
@@ -370,15 +371,15 @@ void mark_page_accessed(struct page *page)
 		 * pagevec, mark it active and it'll be moved to the active
 		 * LRU on the next drain.
 		 */
-		if (PageLRU(page))
+		if (PageLRU(head))
 			activate_page(page);
 		else
 			__lru_cache_activate_page(page);
-		ClearPageReferenced(page);
+		ClearPageReferenced(head);
 		if (page_is_file_cache(page))
 			workingset_activation(page);
-	} else if (!PageReferenced(page)) {
-		SetPageReferenced(page);
+	} else if (!PageReferenced(head)) {
+		SetPageReferenced(head);
 	}
 	if (page_is_idle(page))
 		clear_page_idle(page);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
