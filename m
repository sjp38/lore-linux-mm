Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 15C036B0033
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 01:51:11 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v6 2/5] zsmalloc: add more comment
Date: Wed, 14 Aug 2013 14:51:11 +0900
Message-Id: <1376459474-6495-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1376459474-6495-1-git-send-email-minchan@kernel.org>
References: <1376459474-6495-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan@kernel.org>

From: Nitin Cupta <ngupta@vflare.org>

This patch adds lots of comments and it will help others
to review and enhance.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Signed-off-by: Nitin Gupta <ngupta@vflare.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zsmalloc/zsmalloc-main.c |   66 +++++++++++++++++++++++++-----
 drivers/staging/zsmalloc/zsmalloc.h      |    9 +++-
 2 files changed, 64 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index f57258fa..52ebddd 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -10,16 +10,14 @@
  * Released under the terms of GNU General Public License Version 2.0
  */
 
-
 /*
- * This allocator is designed for use with zcache and zram. Thus, the
- * allocator is supposed to work well under low memory conditions. In
- * particular, it never attempts higher order page allocation which is
- * very likely to fail under memory pressure. On the other hand, if we
- * just use single (0-order) pages, it would suffer from very high
- * fragmentation -- any object of size PAGE_SIZE/2 or larger would occupy
- * an entire page. This was one of the major issues with its predecessor
- * (xvmalloc).
+ * This allocator is designed for use with zram. Thus, the allocator is
+ * supposed to work well under low memory conditions. In particular, it
+ * never attempts higher order page allocation which is very likely to
+ * fail under memory pressure. On the other hand, if we just use single
+ * (0-order) pages, it would suffer from very high fragmentation --
+ * any object of size PAGE_SIZE/2 or larger would occupy an entire page.
+ * This was one of the major issues with its predecessor (xvmalloc).
  *
  * To overcome these issues, zsmalloc allocates a bunch of 0-order pages
  * and links them together using various 'struct page' fields. These linked
@@ -27,6 +25,21 @@
  * page boundaries. The code refers to these linked pages as a single entity
  * called zspage.
  *
+ * For simplicity, zsmalloc can only allocate objects of size up to PAGE_SIZE
+ * since this satisfies the requirements of all its current users (in the
+ * worst case, page is incompressible and is thus stored "as-is" i.e. in
+ * uncompressed form). For allocation requests larger than this size, failure
+ * is returned (see zs_malloc).
+ *
+ * Additionally, zs_malloc() does not return a dereferenceable pointer.
+ * Instead, it returns an opaque handle (unsigned long) which encodes actual
+ * location of the allocated object. The reason for this indirection is that
+ * zsmalloc does not keep zspages permanently mapped since that would cause
+ * issues on 32-bit systems where the VA region for kernel space mappings
+ * is very small. So, before using the allocating memory, the object has to
+ * be mapped using zs_map_object() to get a usable pointer and subsequently
+ * unmapped using zs_unmap_object().
+ *
  * Following is how we use various fields and flags of underlying
  * struct page(s) to form a zspage.
  *
@@ -98,7 +111,7 @@
 
 /*
  * Object location (<PFN>, <obj_idx>) is encoded as
- * as single (void *) handle value.
+ * as single (unsigned long) handle value.
  *
  * Note that object index <obj_idx> is relative to system
  * page <PFN> it is stored in, so for each sub-page belonging
@@ -264,6 +277,13 @@ static void set_zspage_mapping(struct page *page, unsigned int class_idx,
 	page->mapping = (struct address_space *)m;
 }
 
+/*
+ * zsmalloc divides the pool into various size classes where each
+ * class maintains a list of zspages where each zspage is divided
+ * into equal sized chunks. Each allocation falls into one of these
+ * classes depending on its size. This function returns index of the
+ * size class which has chunk size big enough to hold the give size.
+ */
 static int get_size_class_index(int size)
 {
 	int idx = 0;
@@ -275,6 +295,13 @@ static int get_size_class_index(int size)
 	return idx;
 }
 
+/*
+ * For each size class, zspages are divided into different groups
+ * depending on how "full" they are. This was done so that we could
+ * easily find empty or nearly empty zspages when we try to shrink
+ * the pool (not yet implemented). This function returns fullness
+ * status of the given page.
+ */
 static enum fullness_group get_fullness_group(struct page *page)
 {
 	int inuse, max_objects;
@@ -296,6 +323,12 @@ static enum fullness_group get_fullness_group(struct page *page)
 	return fg;
 }
 
+/*
+ * Each size class maintains various freelists and zspages are assigned
+ * to one of these freelists based on the number of live objects they
+ * have. This functions inserts the given zspage into the freelist
+ * identified by <class, fullness_group>.
+ */
 static void insert_zspage(struct page *page, struct size_class *class,
 				enum fullness_group fullness)
 {
@@ -313,6 +346,10 @@ static void insert_zspage(struct page *page, struct size_class *class,
 	*head = page;
 }
 
+/*
+ * This function removes the given zspage from the freelist identified
+ * by <class, fullness_group>.
+ */
 static void remove_zspage(struct page *page, struct size_class *class,
 				enum fullness_group fullness)
 {
@@ -334,6 +371,15 @@ static void remove_zspage(struct page *page, struct size_class *class,
 	list_del_init(&page->lru);
 }
 
+/*
+ * Each size class maintains zspages in different fullness groups depending
+ * on the number of live objects they contain. When allocating or freeing
+ * objects, the fullness status of the page can change, say, from ALMOST_FULL
+ * to ALMOST_EMPTY when freeing an object. This function checks if such
+ * a status change has occurred for the given page and accordingly moves the
+ * page from the freelist of the old fullness group to that of the new
+ * fullness group.
+ */
 static enum fullness_group fix_fullness_group(struct zs_pool *pool,
 						struct page *page)
 {
diff --git a/drivers/staging/zsmalloc/zsmalloc.h b/drivers/staging/zsmalloc/zsmalloc.h
index fbe6bec..c2eb174 100644
--- a/drivers/staging/zsmalloc/zsmalloc.h
+++ b/drivers/staging/zsmalloc/zsmalloc.h
@@ -18,12 +18,19 @@
 /*
  * zsmalloc mapping modes
  *
- * NOTE: These only make a difference when a mapped object spans pages
+ * NOTE: These only make a difference when a mapped object spans pages.
+ * They also have no effect when PGTABLE_MAPPING is selected.
  */
 enum zs_mapmode {
 	ZS_MM_RW, /* normal read-write mapping */
 	ZS_MM_RO, /* read-only (no copy-out at unmap time) */
 	ZS_MM_WO /* write-only (no copy-in at map time) */
+	/*
+	 * NOTE: ZS_MM_WO should only be used for initializing new
+	 * (uninitialized) allocations.  Partial writes to already
+	 * initialized allocations should use ZS_MM_RW to preserve the
+	 * existing data.
+	 */
 };
 
 struct zs_pool;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
