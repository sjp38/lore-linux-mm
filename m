Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9F5CE6B01F4
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 06:24:07 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3FAO7ZH002775
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 15 Apr 2010 19:24:07 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 65DAA45DE4F
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 19:24:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EAD545DE53
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 19:24:07 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E6F9FE08008
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 19:24:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 969E1E08002
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 19:24:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/4] [cleanup] mm: introduce free_pages_prepare
In-Reply-To: <20100415185310.D1A1.A69D9226@jp.fujitsu.com>
References: <20100415085420.GT2493@dastard> <20100415185310.D1A1.A69D9226@jp.fujitsu.com>
Message-Id: <20100415192310.D1A7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 15 Apr 2010 19:24:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch is used from [3/4]

===================================
Free_hot_cold_page() and __free_pages_ok() have very similar
freeing preparation. This patch make consolicate it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/page_alloc.c |   40 +++++++++++++++++++++-------------------
 1 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 88513c0..ba9aea7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -599,20 +599,23 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
 	spin_unlock(&zone->lock);
 }
 
-static void __free_pages_ok(struct page *page, unsigned int order)
+static int free_pages_prepare(struct page *page, unsigned int order)
 {
-	unsigned long flags;
 	int i;
 	int bad = 0;
-	int wasMlocked = __TestClearPageMlocked(page);
 
 	trace_mm_page_free_direct(page, order);
 	kmemcheck_free_shadow(page, order);
 
-	for (i = 0 ; i < (1 << order) ; ++i)
-		bad += free_pages_check(page + i);
+	for (i = 0 ; i < (1 << order) ; ++i) {
+		struct page *pg = page + i;
+
+		if (PageAnon(pg))
+			pg->mapping = NULL;
+		bad += free_pages_check(pg);
+	}
 	if (bad)
-		return;
+		return -EINVAL;
 
 	if (!PageHighMem(page)) {
 		debug_check_no_locks_freed(page_address(page),PAGE_SIZE<<order);
@@ -622,6 +625,17 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	arch_free_page(page, order);
 	kernel_map_pages(page, 1 << order, 0);
 
+	return 0;
+}
+
+static void __free_pages_ok(struct page *page, unsigned int order)
+{
+	unsigned long flags;
+	int wasMlocked = __TestClearPageMlocked(page);
+
+	if (free_pages_prepare(page, order))
+		return;
+
 	local_irq_save(flags);
 	if (unlikely(wasMlocked))
 		free_page_mlock(page);
@@ -1107,21 +1121,9 @@ void free_hot_cold_page(struct page *page, int cold)
 	int migratetype;
 	int wasMlocked = __TestClearPageMlocked(page);
 
-	trace_mm_page_free_direct(page, 0);
-	kmemcheck_free_shadow(page, 0);
-
-	if (PageAnon(page))
-		page->mapping = NULL;
-	if (free_pages_check(page))
+	if (free_pages_prepare(page, 0))
 		return;
 
-	if (!PageHighMem(page)) {
-		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
-		debug_check_no_obj_freed(page_address(page), PAGE_SIZE);
-	}
-	arch_free_page(page, 0);
-	kernel_map_pages(page, 1, 0);
-
 	migratetype = get_pageblock_migratetype(page);
 	set_page_private(page, migratetype);
 	local_irq_save(flags);
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
