Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8EEE66B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:01:39 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s63so36665514wme.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:01:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qc8si4074565wjc.37.2016.04.27.05.01.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Apr 2016 05:01:26 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 3/3] mm, page_alloc: don't duplicate code in free_pcp_prepare
Date: Wed, 27 Apr 2016 14:01:16 +0200
Message-Id: <1461758476-450-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1461758476-450-1-git-send-email-vbabka@suse.cz>
References: <5720A987.7060507@suse.cz>
 <1461758476-450-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

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
---
 mm/page_alloc.c | 34 ++++++----------------------------
 1 file changed, 6 insertions(+), 28 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 163d08ea43f0..b23f641348ab 100644
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
 
@@ -1023,7 +1024,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	}
 	if (PageAnonHead(page))
 		page->mapping = NULL;
-	if (free_pages_check(page)) {
+	if (check_free && free_pages_check(page)) {
 		bad++;
 	} else {
 		page_cpupid_reset_last(page);
@@ -1050,7 +1051,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 #ifdef CONFIG_DEBUG_VM
 static inline bool free_pcp_prepare(struct page *page)
 {
-	return free_pages_prepare(page, 0);
+	return free_pages_prepare(page, 0, true);
 }
 
 static inline bool bulkfree_pcp_prepare(struct page *page)
@@ -1060,30 +1061,7 @@ static inline bool bulkfree_pcp_prepare(struct page *page)
 #else
 static bool free_pcp_prepare(struct page *page)
 {
-	VM_BUG_ON_PAGE(PageTail(page), page);
-
-	trace_mm_page_free(page, 0);
-	kmemcheck_free_shadow(page, 0);
-	kasan_free_pages(page, 0);
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
@@ -1260,7 +1238,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	int migratetype;
 	unsigned long pfn = page_to_pfn(page);
 
-	if (!free_pages_prepare(page, order))
+	if (!free_pages_prepare(page, order, true))
 		return;
 
 	migratetype = get_pfnblock_migratetype(page, pfn);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
