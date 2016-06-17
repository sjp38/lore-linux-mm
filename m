Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 59104828E5
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:58:11 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a69so147582048pfa.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:58:11 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 3si7130750pfg.32.2016.06.17.00.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 00:58:10 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id i123so2732820pfg.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:58:10 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v3 8/9] mm/page_alloc: introduce post allocation processing on page allocator
Date: Fri, 17 Jun 2016 16:57:38 +0900
Message-Id: <1466150259-27727-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patch is motivated from Hugh and Vlastimil's concern [1].

There are two ways to get freepage from the allocator.  One is using
normal memory allocation API and the other is __isolate_free_page() which
is internally used for compaction and pageblock isolation.  Later usage is
rather tricky since it doesn't do whole post allocation processing done by
normal API.

One problematic thing I already know is that poisoned page would not be
checked if it is allocated by __isolate_free_page().  Perhaps, there would
be more.

We could add more debug logic for allocated page in the future and this
separation would cause more problem.  I'd like to fix this situation at
this time.  Solution is simple.  This patch commonize some logic for newly
allocated page and uses it on all sites.  This will solve the problem.

[1] http://marc.info/?i=alpine.LSU.2.11.1604270029350.7066%40eggly.anvils%3E

Link: http://lkml.kernel.org/r/1464230275-25791-7-git-send-email-iamjoonsoo.kim@lge.com
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Alexander Potapenko <glider@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@kernel.org>
---
 mm/compaction.c     |  8 +-------
 mm/internal.h       |  2 ++
 mm/page_alloc.c     | 23 ++++++++++++++---------
 mm/page_isolation.c |  4 +---
 4 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 942d6cd..199b486 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -74,14 +74,8 @@ static void map_pages(struct list_head *list)
 
 		order = page_private(page);
 		nr_pages = 1 << order;
-		set_page_private(page, 0);
-		set_page_refcounted(page);
 
-		arch_alloc_page(page, order);
-		kernel_map_pages(page, nr_pages, 1);
-		kasan_alloc_pages(page, order);
-
-		set_page_owner(page, order, __GFP_MOVABLE);
+		post_alloc_hook(page, order, __GFP_MOVABLE);
 		if (order)
 			split_page(page, order);
 
diff --git a/mm/internal.h b/mm/internal.h
index 11e8ea2..aa04f67 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -151,6 +151,8 @@ extern int __isolate_free_page(struct page *page, unsigned int order);
 extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
 					unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned int order);
+extern void post_alloc_hook(struct page *page, unsigned int order,
+					gfp_t gfp_flags);
 extern int user_min_free_kbytes;
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e3085eb..eeb3516 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1729,6 +1729,19 @@ static bool check_new_pages(struct page *page, unsigned int order)
 	return false;
 }
 
+inline void post_alloc_hook(struct page *page, unsigned int order,
+				gfp_t gfp_flags)
+{
+	set_page_private(page, 0);
+	set_page_refcounted(page);
+
+	arch_alloc_page(page, order);
+	kernel_map_pages(page, 1 << order, 1);
+	kernel_poison_pages(page, 1 << order, 1);
+	kasan_alloc_pages(page, order);
+	set_page_owner(page, order, gfp_flags);
+}
+
 static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
 							unsigned int alloc_flags)
 {
@@ -1741,13 +1754,7 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
 			poisoned &= page_is_poisoned(p);
 	}
 
-	set_page_private(page, 0);
-	set_page_refcounted(page);
-
-	arch_alloc_page(page, order);
-	kernel_map_pages(page, 1 << order, 1);
-	kernel_poison_pages(page, 1 << order, 1);
-	kasan_alloc_pages(page, order);
+	post_alloc_hook(page, order, gfp_flags);
 
 	if (!free_pages_prezeroed(poisoned) && (gfp_flags & __GFP_ZERO))
 		for (i = 0; i < (1 << order); i++)
@@ -1756,8 +1763,6 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
 	if (order && (gfp_flags & __GFP_COMP))
 		prep_compound_page(page, order);
 
-	set_page_owner(page, order, gfp_flags);
-
 	/*
 	 * page is set pfmemalloc when ALLOC_NO_WATERMARKS was necessary to
 	 * allocate the page. The expectation is that the caller is taking
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 927f5ee..4639163 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -128,9 +128,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 	if (isolated_page) {
-		kernel_map_pages(page, (1 << order), 1);
-		set_page_refcounted(page);
-		set_page_owner(page, order, __GFP_MOVABLE);
+		post_alloc_hook(page, order, __GFP_MOVABLE);
 		__free_pages(isolated_page, order);
 	}
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
