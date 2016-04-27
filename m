Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D45C6B025F
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 10:57:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s63so42389597wme.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 07:57:31 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id g69si9543069wme.83.2016.04.27.07.57.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 07:57:25 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id E916E1C15AC
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 15:57:24 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 6/6] mm, page_alloc: don't duplicate code in free_pcp_prepare
Date: Wed, 27 Apr 2016 15:57:23 +0100
Message-Id: <1461769043-28337-7-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1461769043-28337-1-git-send-email-mgorman@techsingularity.net>
References: <1461769043-28337-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The new free_pcp_prepare() function shares a lot of code with
free_pages_prepare(), which makes this a maintenance risk when some future
patch modifies only one of them. We should be able to achieve the same effect
(skipping free_pages_check() from !DEBUG_VM configs) by adding a parameter to
free_pages_prepare() and making it inline, so the checks (and the order != 0
parts) are eliminated from the call from free_pcp_prepare().

!DEBUG_VM: bloat-o-meter reports no difference, as my gcc was already inlining
free_pages_prepare() and the elimination seems to work as expected

DEBUG_VM bloat-o-meter:

add/remove: 0/1 grow/shrink: 2/0 up/down: 1035/-778 (257)
function                                     old     new   delta
__free_pages_ok                              297    1060    +763
free_hot_cold_page                           480     752    +272
free_pages_prepare                           778       -    -778

Here inlining didn't occur before, and added some code, but it's ok for a debug
option.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 35 +++++++----------------------------
 1 file changed, 7 insertions(+), 28 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b823f00c275b..bc4160bfb36b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -990,7 +990,8 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 	return ret;
 }
 
-static bool free_pages_prepare(struct page *page, unsigned int order)
+static __always_inline bool free_pages_prepare(struct page *page, unsigned int order,
+						bool check_free)
 {
 	int bad = 0;
 
@@ -1022,7 +1023,8 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	}
 	if (PageAnonHead(page))
 		page->mapping = NULL;
-	bad += free_pages_check(page);
+	if (check_free)
+		bad += free_pages_check(page);
 	if (bad)
 		return false;
 
@@ -1046,7 +1048,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 #ifdef CONFIG_DEBUG_VM
 static inline bool free_pcp_prepare(struct page *page)
 {
-	return free_pages_prepare(page, 0);
+	return free_pages_prepare(page, 0, true);
 }
 
 static inline bool bulkfree_pcp_prepare(struct page *page)
@@ -1056,30 +1058,7 @@ static inline bool bulkfree_pcp_prepare(struct page *page)
 #else
 static bool free_pcp_prepare(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageTail(page), page);
-
-	trace_mm_page_free(page, 0);
-	kmemcheck_free_shadow(page, 0);
-	kasan_poison_free_pages(page, 0);
-
-	if (PageAnonHead(page))
-		page->mapping = NULL;
-
-	reset_page_owner(page, 0);
-
-	if (!PageHighMem(page)) {
-		debug_check_no_locks_freed(page_address(page),
-					   PAGE_SIZE);
-		debug_check_no_obj_freed(page_address(page),
-					   PAGE_SIZE);
-	}
-	arch_free_page(page, 0);
-	kernel_poison_pages(page, 0, 0);
-	kernel_map_pages(page, 0, 0);
-
-	page_cpupid_reset_last(page);
-	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
-	return true;
+	return free_pages_prepare(page, 0, false);
 }
 
 static bool bulkfree_pcp_prepare(struct page *page)
@@ -1257,7 +1236,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	int migratetype;
 	unsigned long pfn = page_to_pfn(page);
 
-	if (!free_pages_prepare(page, order))
+	if (!free_pages_prepare(page, order, true))
 		return;
 
 	migratetype = get_pfnblock_migratetype(page, pfn);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
