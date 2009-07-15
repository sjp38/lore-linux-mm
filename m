Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 08D406B005D
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 06:10:10 -0400 (EDT)
Date: Wed, 15 Jul 2009 11:48:34 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] mm: Warn once when a page is freed with PG_mlocked set
	(resend)
Message-ID: <20090715104833.GB9267@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Jiri Slaby <jirislaby@gmail.com>
List-ID: <linux-mm.kvack.org>

When a page is freed with the PG_mlocked set, it is considered an unexpected
but recoverable situation. A counter records how often this event happens
but it is easy to miss that this event has occured at all. This patch warns
once when PG_mlocked is set to prompt debuggers to check the counter to
see how often it is happening.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/page_alloc.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index caa9268..f8902e7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -495,8 +495,16 @@ static inline void free_page_mlock(struct page *page)
 static void free_page_mlock(struct page *page) { }
 #endif
 
-static inline int free_pages_check(struct page *page)
-{
+static inline int free_pages_check(struct page *page, int wasMlocked)
+{
+	if (unlikely(wasMlocked)) {
+		WARN_ONCE(1, KERN_WARNING
+			"Page flag mlocked set for process %s at pfn:%05lx\n"
+			"page:%p flags:0x%lX\n",
+			current->comm, page_to_pfn(page),
+			page, page->flags|__PG_MLOCKED);
+	}
+
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
 		(atomic_read(&page->_count) != 0) |
@@ -562,7 +570,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	kmemcheck_free_shadow(page, order);
 
 	for (i = 0 ; i < (1 << order) ; ++i)
-		bad += free_pages_check(page + i);
+		bad += free_pages_check(page + i, wasMlocked);
 	if (bad)
 		return;
 
@@ -1027,7 +1035,7 @@ static void free_hot_cold_page(struct page *page, int cold)
 
 	if (PageAnon(page))
 		page->mapping = NULL;
-	if (free_pages_check(page))
+	if (free_pages_check(page, wasMlocked))
 		return;
 
 	if (!PageHighMem(page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
