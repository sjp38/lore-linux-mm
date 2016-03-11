Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id E30826B0254
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 02:36:04 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id g203so135574430iof.2
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 23:36:04 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 38si9734010ios.62.2016.03.10.23.29.53
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 23:29:54 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 16/19] zsmalloc: migrate head page of zspage
Date: Fri, 11 Mar 2016 16:30:20 +0900
Message-Id: <1457681423-26664-17-git-send-email-minchan@kernel.org>
In-Reply-To: <1457681423-26664-1-git-send-email-minchan@kernel.org>
References: <1457681423-26664-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, rknize@motorola.com, Rik van Riel <riel@redhat.com>, Gioh Kim <gurugio@hanmail.net>, Minchan Kim <minchan@kernel.org>

This patch introduces run-time migration feature for zspage.
To begin with, it supports only head page migration for
easy review(later patches will support tail page migration).

For migration, it supports three functions

* zs_page_isolate

It isolates a zspage which includes a subpage VM want to migrate
from class so anyone cannot allocate new object from the zspage.
IOW, allocation freeze

* zs_page_migrate

First of all, it freezes zspage to prevent zspage destrunction
so anyone cannot free object. Then, It copies content from oldpage
to newpage and create new page-chain with new page.
If it was successful, drop the refcount of old page to free
and putback new zspage to right data structure of zsmalloc.
Lastly, unfreeze zspages so we allows object allocation/free
from now on.

* zs_page_putback

It returns isolated zspage to right fullness_group list
if it fails to migrate a page.

NOTE: A hurdle to support migration is that destroying zspage
while migration is going on. Once a zspage is isolated,
anyone cannot allocate object from the zspage but can deallocate
object freely so a zspage could be destroyed until all of objects
in zspage are freezed to prevent deallocation. The problem is
large window betwwen zs_page_isolate and freeze_zspage
in zs_page_migrate so the zspage could be destroyed.

A easy approach to solve the problem is that object freezing
in zs_page_isolate but it has a drawback that any object cannot
be deallocated until migration fails after isolation. However,
There is large time gab between isolation and migration so
any object freeing in other CPU should spin by pin_tag which
would cause big latency. So, this patch introduces lock_zspage
which holds PG_lock of all pages in a zspage right before
freeing the zspage. VM migration locks the page, too right
before calling ->migratepage so such race doesn't exist any more.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 291 +++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 280 insertions(+), 11 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 43ab16affa68..8eb785000069 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -56,6 +56,8 @@
 #include <linux/debugfs.h>
 #include <linux/zsmalloc.h>
 #include <linux/zpool.h>
+#include <linux/anon_inodes.h>
+#include <linux/migrate.h>
 
 /*
  * This must be power of 2 and greater than of equal to sizeof(link_free).
@@ -263,6 +265,7 @@ struct zs_pool {
 #ifdef CONFIG_ZSMALLOC_STAT
 	struct dentry *stat_dentry;
 #endif
+	struct inode *inode;
 };
 
 struct zs_meta {
@@ -413,6 +416,29 @@ static int is_last_page(struct page *page)
 	return PagePrivate2(page);
 }
 
+/*
+ * Indicate that whether zspage is isolated for page migration.
+ * Protected by size_class lock
+ */
+static void SetZsPageIsolate(struct page *first_page)
+{
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+	SetPageUptodate(first_page);
+}
+
+static int ZsPageIsolate(struct page *first_page)
+{
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+
+	return PageUptodate(first_page);
+}
+
+static void ClearZsPageIsolate(struct page *first_page)
+{
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+	ClearPageUptodate(first_page);
+}
+
 static int get_zspage_inuse(struct page *first_page)
 {
 	struct zs_meta *m;
@@ -778,8 +804,11 @@ static enum fullness_group fix_fullness_group(struct size_class *class,
 	if (newfg == currfg)
 		goto out;
 
-	remove_zspage(class, currfg, first_page);
-	insert_zspage(class, newfg, first_page);
+	/* Later, putback will insert page to right list */
+	if (!ZsPageIsolate(first_page)) {
+		remove_zspage(class, currfg, first_page);
+		insert_zspage(class, newfg, first_page);
+	}
 	set_zspage_mapping(first_page, class_idx, newfg);
 
 out:
@@ -945,13 +974,31 @@ static void unpin_tag(unsigned long handle)
 
 static void reset_page(struct page *page)
 {
+	__ClearPageMovable(page);
 	clear_bit(PG_private, &page->flags);
 	clear_bit(PG_private_2, &page->flags);
 	set_page_private(page, 0);
 	page->freelist = NULL;
+	page->mapping = NULL;
 	page_mapcount_reset(page);
 }
 
+/**
+ * lock_zspage - lock all pages in the zspage
+ * @first_page: head page of the zspage
+ *
+ * To prevent destroy during migration, zspage freeing should
+ * hold locks of all pages in a zspage
+ */
+void lock_zspage(struct page *first_page)
+{
+	struct page *cursor = first_page;
+
+	do {
+		while (!trylock_page(cursor));
+	} while ((cursor = get_next_page(cursor)) != NULL);
+}
+
 static void free_zspage(struct zs_pool *pool, struct page *first_page)
 {
 	struct page *nextp, *tmp, *head_extra;
@@ -959,26 +1006,31 @@ static void free_zspage(struct zs_pool *pool, struct page *first_page)
 	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
 	VM_BUG_ON_PAGE(get_zspage_inuse(first_page), first_page);
 
+	lock_zspage(first_page);
 	head_extra = (struct page *)page_private(first_page);
 
-	reset_page(first_page);
-	__free_page(first_page);
-
 	/* zspage with only 1 system page */
 	if (!head_extra)
-		return;
+		goto out;
 
 	list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
 		list_del(&nextp->lru);
 		reset_page(nextp);
+		unlock_page(nextp);
 		__free_page(nextp);
 	}
 	reset_page(head_extra);
+	unlock_page(head_extra);
 	__free_page(head_extra);
+out:
+	reset_page(first_page);
+	unlock_page(first_page);
+	__free_page(first_page);
 }
 
 /* Initialize a newly allocated zspage */
-static void init_zspage(struct size_class *class, struct page *first_page)
+static void init_zspage(struct size_class *class, struct page *first_page,
+			struct address_space *mapping)
 {
 	int freeobj = 1;
 	unsigned long off = 0;
@@ -987,6 +1039,10 @@ static void init_zspage(struct size_class *class, struct page *first_page)
 	first_page->freelist = NULL;
 	INIT_LIST_HEAD(&first_page->lru);
 	set_zspage_inuse(first_page, 0);
+	BUG_ON(!trylock_page(first_page));
+	first_page->mapping = mapping;
+	__SetPageMovable(first_page);
+	unlock_page(first_page);
 
 	while (page) {
 		struct page *next_page;
@@ -1061,10 +1117,46 @@ static void create_page_chain(struct page *pages[], int nr_pages)
 	}
 }
 
+static void replace_sub_page(struct size_class *class, struct page *first_page,
+		struct page *newpage, struct page *oldpage)
+{
+	struct page *page;
+	struct page *pages[ZS_MAX_PAGES_PER_ZSPAGE] = {NULL,};
+	int idx = 0;
+
+	page = first_page;
+	do {
+		if (page == oldpage)
+			pages[idx] = newpage;
+		else
+			pages[idx] = page;
+		idx++;
+	} while ((page = get_next_page(page)) != NULL);
+
+	create_page_chain(pages, class->pages_per_zspage);
+
+	if (is_first_page(oldpage)) {
+		enum fullness_group fg;
+		int class_idx;
+
+		SetZsPageIsolate(newpage);
+		get_zspage_mapping(oldpage, &class_idx, &fg);
+		set_zspage_mapping(newpage, class_idx, fg);
+		set_freeobj(newpage, get_freeobj(oldpage));
+		set_zspage_inuse(newpage, get_zspage_inuse(oldpage));
+		if (class->huge)
+			set_page_private(newpage,  page_private(oldpage));
+	}
+
+	newpage->mapping = oldpage->mapping;
+	__SetPageMovable(newpage);
+}
+
 /*
  * Allocate a zspage for the given size class
  */
-static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
+static struct page *alloc_zspage(struct zs_pool *pool,
+				struct size_class *class)
 {
 	int i;
 	struct page *first_page = NULL, *uninitialized_var(prev_page);
@@ -1084,7 +1176,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	for (i = 0; i < class->pages_per_zspage; i++) {
 		struct page *page;
 
-		page = alloc_page(flags);
+		page = alloc_page(pool->flags);
 		if (!page) {
 			while (--i >= 0)
 				__free_page(pages[i]);
@@ -1096,7 +1188,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 	create_page_chain(pages, class->pages_per_zspage);
 	first_page = pages[0];
-	init_zspage(class, first_page);
+	init_zspage(class, first_page, pool->inode->i_mapping);
 
 	return first_page;
 }
@@ -1497,7 +1589,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 
 	if (!first_page) {
 		spin_unlock(&class->lock);
-		first_page = alloc_zspage(class, pool->flags);
+		first_page = alloc_zspage(pool, class);
 		if (unlikely(!first_page)) {
 			free_handle(pool, handle);
 			return 0;
@@ -1557,6 +1649,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	if (unlikely(!handle))
 		return;
 
+	/* Once handle is pinned, page|object migration cannot work */
 	pin_tag(handle);
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &f_page, &f_objidx);
@@ -1712,6 +1805,9 @@ static enum fullness_group putback_zspage(struct size_class *class,
 {
 	enum fullness_group fullness;
 
+	VM_BUG_ON_PAGE(!list_empty(&first_page->lru), first_page);
+	VM_BUG_ON_PAGE(ZsPageIsolate(first_page), first_page);
+
 	fullness = get_fullness_group(class, first_page);
 	insert_zspage(class, fullness, first_page);
 	set_zspage_mapping(first_page, class->index, fullness);
@@ -2057,6 +2153,173 @@ static int zs_register_shrinker(struct zs_pool *pool)
 	return register_shrinker(&pool->shrinker);
 }
 
+bool zs_page_isolate(struct page *page, isolate_mode_t mode)
+{
+	struct zs_pool *pool;
+	struct size_class *class;
+	int class_idx;
+	enum fullness_group fullness;
+	struct page *first_page;
+
+	/*
+	 * The page is locked so it couldn't be destroyed.
+	 * For detail, look at lock_zspage in free_zspage.
+	 */
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON_PAGE(PageIsolated(page), page);
+	/*
+	 * In this implementation, it allows only first page migration.
+	 */
+	VM_BUG_ON_PAGE(!is_first_page(page), page);
+	first_page = page;
+
+	/*
+	 * Without class lock, fullness is meaningless while constant
+	 * class_idx is okay. We will get it under class lock at below,
+	 * again.
+	 */
+	get_zspage_mapping(first_page, &class_idx, &fullness);
+	pool = page->mapping->private_data;
+	class = pool->size_class[class_idx];
+
+	if (!spin_trylock(&class->lock))
+		return false;
+
+	get_zspage_mapping(first_page, &class_idx, &fullness);
+	remove_zspage(class, fullness, first_page);
+	SetZsPageIsolate(first_page);
+	SetPageIsolated(page);
+	spin_unlock(&class->lock);
+
+	return true;
+}
+
+int zs_page_migrate(struct address_space *mapping, struct page *newpage,
+		struct page *page, enum migrate_mode mode)
+{
+	struct zs_pool *pool;
+	struct size_class *class;
+	int class_idx;
+	enum fullness_group fullness;
+	struct page *first_page;
+	void *s_addr, *d_addr, *addr;
+	int ret = -EBUSY;
+	int offset = 0;
+	int freezed = 0;
+
+	VM_BUG_ON_PAGE(!PageMovable(page), page);
+	VM_BUG_ON_PAGE(!PageIsolated(page), page);
+
+	first_page = page;
+	get_zspage_mapping(first_page, &class_idx, &fullness);
+	pool = page->mapping->private_data;
+	class = pool->size_class[class_idx];
+
+	/*
+	 * Get stable fullness under class->lock
+	 */
+	if (!spin_trylock(&class->lock))
+		return ret;
+
+	get_zspage_mapping(first_page, &class_idx, &fullness);
+	if (get_zspage_inuse(first_page) == 0)
+		goto out_class_unlock;
+
+	freezed = freeze_zspage(class, first_page);
+	if (freezed != get_zspage_inuse(first_page))
+		goto out_unfreeze;
+
+	/* copy contents from page to newpage */
+	s_addr = kmap_atomic(page);
+	d_addr = kmap_atomic(newpage);
+	memcpy(d_addr, s_addr, PAGE_SIZE);
+	kunmap_atomic(d_addr);
+	kunmap_atomic(s_addr);
+
+	if (!is_first_page(page))
+		offset = page->index;
+
+	addr = kmap_atomic(page);
+	do {
+		unsigned long handle;
+		unsigned long head;
+		unsigned long new_obj, old_obj;
+		unsigned long obj_idx;
+		struct page *dummy;
+
+		head = obj_to_head(class, page, addr + offset);
+		if (head & OBJ_ALLOCATED_TAG) {
+			handle = head & ~OBJ_ALLOCATED_TAG;
+			if (!testpin_tag(handle))
+				BUG();
+
+			old_obj = handle_to_obj(handle);
+			obj_to_location(old_obj, &dummy, &obj_idx);
+			new_obj = location_to_obj(newpage, obj_idx);
+			new_obj |= BIT(HANDLE_PIN_BIT);
+			record_obj(handle, new_obj);
+		}
+		offset += class->size;
+	} while (offset < PAGE_SIZE);
+	kunmap_atomic(addr);
+
+	replace_sub_page(class, first_page, newpage, page);
+	first_page = newpage;
+	get_page(newpage);
+	VM_BUG_ON_PAGE(get_fullness_group(class, first_page) ==
+			ZS_EMPTY, first_page);
+	ClearZsPageIsolate(first_page);
+	putback_zspage(class, first_page);
+
+	/* Migration complete. Free old page */
+	reset_page(page);
+	ClearPageIsolated(page);
+	put_page(page);
+	ret = MIGRATEPAGE_SUCCESS;
+
+out_unfreeze:
+	unfreeze_zspage(class, first_page, freezed);
+out_class_unlock:
+	spin_unlock(&class->lock);
+
+	return ret;
+}
+
+void zs_page_putback(struct page *page)
+{
+	struct zs_pool *pool;
+	struct size_class *class;
+	int class_idx;
+	enum fullness_group fullness;
+	struct page *first_page;
+
+	VM_BUG_ON_PAGE(!PageMovable(page), page);
+	VM_BUG_ON_PAGE(!PageIsolated(page), page);
+
+	first_page = page;
+	get_zspage_mapping(first_page, &class_idx, &fullness);
+	pool = page->mapping->private_data;
+	class = pool->size_class[class_idx];
+
+	/*
+	 * If there is race betwwen zs_free and here, free_zspage
+	 * in zs_free will wait the page lock of @page without
+	 * destroying of zspage.
+	 */
+	INIT_LIST_HEAD(&first_page->lru);
+	spin_lock(&class->lock);
+	ClearPageIsolated(page);
+	ClearZsPageIsolate(first_page);
+	putback_zspage(class, first_page);
+	spin_unlock(&class->lock);
+}
+
+const struct address_space_operations zsmalloc_aops = {
+	.isolate_page = zs_page_isolate,
+	.migratepage = zs_page_migrate,
+	.putback_page = zs_page_putback,
+};
+
 /**
  * zs_create_pool - Creates an allocation pool to work from.
  * @flags: allocation flags used to allocate pool metadata
@@ -2144,6 +2407,12 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 	if (zs_pool_stat_create(pool, name))
 		goto err;
 
+	pool->inode = anon_inode_new();
+	if (IS_ERR(pool->inode))
+		goto err;
+	pool->inode->i_mapping->a_ops = &zsmalloc_aops;
+	pool->inode->i_mapping->private_data = pool;
+
 	/*
 	 * Not critical, we still can use the pool
 	 * and user can trigger compaction manually.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
