Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D14056B0253
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 19:40:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so137911686pfa.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 16:40:14 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id d20si2563552pfk.240.2016.06.22.16.40.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 16:40:13 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id t190so22139214pfb.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 16:40:13 -0700 (PDT)
Date: Wed, 22 Jun 2016 16:40:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, compaction: abort free scanner if split fails
In-Reply-To: <20160622145902.9f07aa13048d4782c881cb6c@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1606221636440.8004@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1606211447001.43430@chino.kir.corp.google.com> <alpine.DEB.2.10.1606211820350.97086@chino.kir.corp.google.com> <20160622145617.79197acff1a7e617b9d9d393@linux-foundation.org>
 <20160622145902.9f07aa13048d4782c881cb6c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, 22 Jun 2016, Andrew Morton wrote:

> And
> mm-compaction-split-freepages-without-holding-the-zone-lock-fix.patch
> churns things around some more.  Now this:
> 
> 
> 		/* Found a free page, will break it into order-0 pages */
> 		order = page_order(page);
> 		isolated = __isolate_free_page(page, order);
> 		set_page_private(page, order);
> 		total_isolated += isolated;
> 		list_add_tail(&page->lru, freelist);
> 		cc->nr_freepages += isolated;
> 		if (!strict && cc->nr_migratepages <= cc->nr_freepages) {
> 			blockpfn += isolated;
> 			break;
> 		}
> 		/* Advance to the end of split page */
> 		blockpfn += isolated - 1;
> 		cursor += isolated - 1;
> 		continue;
> 
> isolate_fail:
> 
> and things are looking a bit better...
> 

This looks like it's missing the

	if (!isolated)
		break;

check from mm-compaction-abort-free-scanner-if-split-fails.patch which is 
needed to properly terminate when the low watermark fails (and adding to 
freelist as Minchan mentioned before I saw this patch).

I rebased 
mm-compaction-split-freepages-without-holding-the-zone-lock.patch as I 
thought it should be done and folded 
mm-compaction-split-freepages-without-holding-the-zone-lock-fix.patch into 
it for simplicity.  I think this should replace 
mm-compaction-split-freepages-without-holding-the-zone-lock.patch in -mm.


From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

We don't need to split freepages with holding the zone lock.  It will
cause more contention on zone lock so not desirable.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -537,7 +537,6 @@ void __put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
 
 void split_page(struct page *page, unsigned int order);
-int split_free_page(struct page *page);
 
 /*
  * Compound pages have a destructor function.  Provide a
diff --git a/mm/compaction.c b/mm/compaction.c
index ab21497..9d17b21 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -65,13 +65,31 @@ static unsigned long release_freepages(struct list_head *freelist)
 
 static void map_pages(struct list_head *list)
 {
-	struct page *page;
+	unsigned int i, order, nr_pages;
+	struct page *page, *next;
+	LIST_HEAD(tmp_list);
+
+	list_for_each_entry_safe(page, next, list, lru) {
+		list_del(&page->lru);
 
-	list_for_each_entry(page, list, lru) {
-		arch_alloc_page(page, 0);
-		kernel_map_pages(page, 1, 1);
-		kasan_alloc_pages(page, 0);
+		order = page_private(page);
+		nr_pages = 1 << order;
+		set_page_private(page, 0);
+		set_page_refcounted(page);
+
+		arch_alloc_page(page, order);
+		kernel_map_pages(page, nr_pages, 1);
+		kasan_alloc_pages(page, order);
+		if (order)
+			split_page(page, order);
+
+		for (i = 0; i < nr_pages; i++) {
+			list_add(&page->lru, &tmp_list);
+			page++;
+		}
 	}
+
+	list_splice(&tmp_list, list);
 }
 
 static inline bool migrate_async_suitable(int migratetype)
@@ -406,12 +424,13 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	unsigned long flags = 0;
 	bool locked = false;
 	unsigned long blockpfn = *start_pfn;
+	unsigned int order;
 
 	cursor = pfn_to_page(blockpfn);
 
 	/* Isolate free pages. */
 	for (; blockpfn < end_pfn; blockpfn++, cursor++) {
-		int isolated, i;
+		int isolated;
 		struct page *page = cursor;
 
 		/*
@@ -477,17 +496,17 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 				goto isolate_fail;
 		}
 
-		/* Found a free page, break it into order-0 pages */
-		isolated = split_free_page(page);
+		/* Found a free page, will break it into order-0 pages */
+		order = page_order(page);
+		isolated = __isolate_free_page(page, order);
 		if (!isolated)
 			break;
+		set_page_private(page, order);
 
 		total_isolated += isolated;
 		cc->nr_freepages += isolated;
-		for (i = 0; i < isolated; i++) {
-			list_add(&page->lru, freelist);
-			page++;
-		}
+		list_add_tail(&page->lru, freelist);
+
 		if (!strict && cc->nr_migratepages <= cc->nr_freepages) {
 			blockpfn += isolated;
 			break;
@@ -606,7 +625,7 @@ isolate_freepages_range(struct compact_control *cc,
 		 */
 	}
 
-	/* split_free_page does not map the pages */
+	/* __isolate_free_page() does not map the pages */
 	map_pages(&freelist);
 
 	if (pfn < end_pfn) {
@@ -1113,7 +1132,7 @@ static void isolate_freepages(struct compact_control *cc)
 		}
 	}
 
-	/* split_free_page does not map the pages */
+	/* __isolate_free_page() does not map the pages */
 	map_pages(freelist);
 
 	/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2560,33 +2560,6 @@ int __isolate_free_page(struct page *page, unsigned int order)
 }
 
 /*
- * Similar to split_page except the page is already free. As this is only
- * being used for migration, the migratetype of the block also changes.
- * As this is called with interrupts disabled, the caller is responsible
- * for calling arch_alloc_page() and kernel_map_page() after interrupts
- * are enabled.
- *
- * Note: this is probably too low level an operation for use in drivers.
- * Please consult with lkml before using this in your driver.
- */
-int split_free_page(struct page *page)
-{
-	unsigned int order;
-	int nr_pages;
-
-	order = page_order(page);
-
-	nr_pages = __isolate_free_page(page, order);
-	if (!nr_pages)
-		return 0;
-
-	/* Split into individual pages */
-	set_page_refcounted(page);
-	split_page(page, order);
-	return nr_pages;
-}
-
-/*
  * Update NUMA hit/miss statistics
  *
  * Must be called with interrupts disabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
