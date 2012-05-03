Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 2D81E6B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 02:40:55 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/4] zsmalloc: rename zspage_order with zspage_pages
Date: Thu,  3 May 2012 15:40:39 +0900
Message-Id: <1336027242-372-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

zspage_order defines how many pages are needed to make a zspage.
So _order_ is rather awkward naming. It already deceive Jonathan
- http://lwn.net/Articles/477067/
" For each size, the code calculates an optimum number of pages (up to 16)"

Let's change from _order_ to _pages_ and some function names.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |   14 +++++++-------
 drivers/staging/zsmalloc/zsmalloc_int.h  |    2 +-
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index 504b6c2..8642800 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -180,7 +180,7 @@ out:
  * link together 3 PAGE_SIZE sized pages to form a zspage
  * since then we can perfectly fit in 8 such objects.
  */
-static int get_zspage_order(int class_size)
+static int get_pages_per_zspage(int class_size)
 {
 	int i, max_usedpc = 0;
 	/* zspage order which gives maximum used size per KB */
@@ -368,7 +368,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	 * identify the last page.
 	 */
 	error = -ENOMEM;
-	for (i = 0; i < class->zspage_order; i++) {
+	for (i = 0; i < class->pages_per_zspage; i++) {
 		struct page *page, *prev_page;
 
 		page = alloc_page(flags);
@@ -388,7 +388,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 			page->first_page = first_page;
 		if (i >= 2)
 			list_add(&page->lru, &prev_page->lru);
-		if (i == class->zspage_order - 1)	/* last page */
+		if (i == class->pages_per_zspage - 1)	/* last page */
 			SetPagePrivate2(page);
 		prev_page = page;
 	}
@@ -397,7 +397,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 	first_page->freelist = obj_location_to_handle(first_page, 0);
 	/* Maximum number of objects we can store in this zspage */
-	first_page->objects = class->zspage_order * PAGE_SIZE / class->size;
+	first_page->objects = class->pages_per_zspage * PAGE_SIZE / class->size;
 
 	error = 0; /* Success */
 
@@ -512,7 +512,7 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 		class->size = size;
 		class->index = i;
 		spin_lock_init(&class->lock);
-		class->zspage_order = get_zspage_order(size);
+		class->pages_per_zspage = get_pages_per_zspage(size);
 
 	}
 
@@ -603,7 +603,7 @@ void *zs_malloc(struct zs_pool *pool, size_t size)
 
 		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
 		spin_lock(&class->lock);
-		class->pages_allocated += class->zspage_order;
+		class->pages_allocated += class->pages_per_zspage;
 	}
 
 	obj = first_page->freelist;
@@ -658,7 +658,7 @@ void zs_free(struct zs_pool *pool, void *obj)
 	fullness = fix_fullness_group(pool, first_page);
 
 	if (fullness == ZS_EMPTY)
-		class->pages_allocated -= class->zspage_order;
+		class->pages_allocated -= class->pages_per_zspage;
 
 	spin_unlock(&class->lock);
 
diff --git a/drivers/staging/zsmalloc/zsmalloc_int.h b/drivers/staging/zsmalloc/zsmalloc_int.h
index 92eefc6..6fd32a9 100644
--- a/drivers/staging/zsmalloc/zsmalloc_int.h
+++ b/drivers/staging/zsmalloc/zsmalloc_int.h
@@ -124,7 +124,7 @@ struct size_class {
 	unsigned int index;
 
 	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
-	int zspage_order;
+	int pages_per_zspage;
 
 	spinlock_t lock;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
