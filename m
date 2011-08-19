Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F23276B016C
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 03:49:05 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p7J7n3l0006708
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:49:03 -0700
Received: from gyd12 (gyd12.prod.google.com [10.243.49.204])
	by hpaq5.eem.corp.google.com with ESMTP id p7J7moqM012628
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:49:02 -0700
Received: by gyd12 with SMTP id 12so2279809gyd.32
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:49:01 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 9/9] mm: make sure tail page counts are stable before splitting THP pages
Date: Fri, 19 Aug 2011 00:48:31 -0700
Message-Id: <1313740111-27446-10-git-send-email-walken@google.com>
In-Reply-To: <1313740111-27446-1-git-send-email-walken@google.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

As described in the page_cache_get_speculative() comment
in pagemap.h, the count of all pages coming out of the allocator
must be considered unstable unless an RCU grace period has passed
since the pages were allocated.

This is an issue for THP because __split_huge_page_refcount()
depends on tail page counts being stable.

By setting a cookie on THP pages when they are allocated, we are able
to ensure the tail page counts are stable before splitting such pages.
In the typical case, the THP page should be old enough by the time we
try to split it, so that we won't have to wait.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/huge_memory.c |   33 +++++++++++++++++++++++++++++----
 1 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 81532f2..46c0c0b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -657,15 +657,23 @@ static inline struct page *alloc_hugepage_vma(int defrag,
 					      unsigned long haddr, int nd,
 					      gfp_t extra_gfp)
 {
-	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag, extra_gfp),
+	struct page *page;
+	page = alloc_pages_vma(alloc_hugepage_gfpmask(defrag, extra_gfp),
 			       HPAGE_PMD_ORDER, vma, haddr, nd);
+	if (page)
+		page_get_gp_cookie(page);
+	return page;
 }
 
 #ifndef CONFIG_NUMA
 static inline struct page *alloc_hugepage(int defrag)
 {
-	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
+	struct page *page;
+	page = alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
 			   HPAGE_PMD_ORDER);
+	if (page)
+		page_get_gp_cookie(page);
+	return page;
 }
 #endif
 
@@ -1209,7 +1217,7 @@ static void __split_huge_page_refcount(struct page *page)
 		BUG_ON(page_mapcount(page_tail));
 		page_tail->_mapcount = page->_mapcount;
 
-		BUG_ON(page_tail->mapping);
+		BUG_ON(page_tail->mapping);  /* see page_clear_gp_cookie() */
 		page_tail->mapping = page->mapping;
 
 		page_tail->index = ++head_index;
@@ -1387,9 +1395,11 @@ static void __split_huge_page(struct page *page,
 int split_huge_page(struct page *page)
 {
 	struct anon_vma *anon_vma;
-	int ret = 1;
+	int ret;
 
+retry:
 	BUG_ON(!PageAnon(page));
+	ret = 1;
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
 		goto out;
@@ -1397,6 +1407,21 @@ int split_huge_page(struct page *page)
 	if (!PageCompound(page))
 		goto out_unlock;
 
+	/*
+	 * Make sure the tail page counts are stable before splitting the page.
+	 * See the page_cache_get_speculative() comment in pagemap.h.
+	 */
+	if (!page_gp_cookie_elapsed(page)) {
+		page_unlock_anon_vma(anon_vma);
+		synchronize_rcu();
+		goto retry;
+	}
+
+	/*
+	 * Make sure page_tail->mapping is cleared before we split up the page.
+	 */
+	page_clear_gp_cookie(page);
+
 	BUG_ON(!PageSwapBacked(page));
 	__split_huge_page(page, anon_vma);
 	count_vm_event(THP_SPLIT);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
