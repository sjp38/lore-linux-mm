Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 46D2B6B0082
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 07:17:25 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 18/19] Do not check for compound pages during the page allocator sanity checks
Date: Tue, 24 Feb 2009 12:17:14 +0000
Message-Id: <1235477835-14500-19-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

A number of sanity checks are made on each page allocation and free
including that the page count is zero. page_count() checks for
compound pages and checks the count of the head page if true. However,
in these paths, we do not care if the page is compound or not as the
count of each tail page should also be zero.

This patch makes two changes to the use of page_count() in the free path. It
converts one check of page_count() to a VM_BUG_ON() as the count should
have been unconditionally checked earlier in the free path. It also avoids
checking for compound pages.

[mel@csn.ul.ie: Wrote changelog]
Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>
---
 mm/page_alloc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e598da8..8a8db71 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -426,7 +426,7 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 		return 0;
 
 	if (PageBuddy(buddy) && page_order(buddy) == order) {
-		BUG_ON(page_count(buddy) != 0);
+		VM_BUG_ON(page_count(buddy) != 0);
 		return 1;
 	}
 	return 0;
@@ -503,7 +503,7 @@ static inline int free_pages_check(struct page *page)
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(page_count(page) != 0)  |
+		(atomic_read(&page->_count) != 0) |
 		(page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {
 		bad_page(page);
 		return 1;
@@ -648,7 +648,7 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
-		(page_count(page) != 0)  |
+		(atomic_read(&page->_count) != 0)  |
 		(page->flags & PAGE_FLAGS_CHECK_AT_PREP))) {
 		bad_page(page);
 		return 1;
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
