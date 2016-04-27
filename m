Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B724F828E1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 03:47:40 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so77243192pfb.0
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 00:47:40 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id kn6si4003294pab.70.2016.04.27.00.47.38
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 00:47:39 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 11/12] zsmalloc: page migration support
Date: Wed, 27 Apr 2016 16:48:24 +0900
Message-Id: <1461743305-19970-12-git-send-email-minchan@kernel.org>
In-Reply-To: <1461743305-19970-1-git-send-email-minchan@kernel.org>
References: <1461743305-19970-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

This patch introduces run-time migration feature for zspage.

For migration, VM uses page.lru field so it would be better to not use
page.next field for own purpose. For that, firstly, we can get first
object offset of the page via runtime calculation instead of
page->index so we can use page->index as link for page chaining.
In case of huge object, it stores handle rather than page chaining.
To identify huge object, we uses PG_owner_priv_1 flag.

For migration, it supports three functions

* zs_page_isolate

It isolates a zspage which includes a subpage VM want to migrate from
class so anyone cannot allocate new object from the zspage if it's first
isolation on subpages of zspage. Thus, further isolation on other
subpages cannot isolate zspage from class list.

* zs_page_migrate

First of all, it holds write-side zspage->lock to prevent migrate other
subpage in zspage. Then, lock all objects in the page VM want to migrate.
The reason we should lock all objects in the page is due to race between
zs_map_object and zs_page_migrate.

zs_map_object				zs_page_migrate

pin_tag(handle)
obj = handle_to_obj(handle)
obj_to_location(obj, &page, &obj_idx);

					write_lock(&zspage->lock)
					if (!trypin_tag(handle))
						goto unpin_object

zspage = get_zspage(page);
read_lock(&zspage->lock);

If zs_page_migrate doesn't do trypin_tag, zs_map_object's page can
be stale so go crash.

If it locks all of objects successfully, it copies content from old page
create new one, finally, create new page chain with new page.
If it's last isolated page in the zspage, put the zspage back to class.

* zs_page_putback

It returns isolated zspage to right fullness_group list if it fails to
migrate a page.

Lastly, this patch introduces asynchronous zspage free. The reason
we need it is we need page_lock to clear PG_movable but unfortunately,
zs_free path should be atomic so the apporach is try to grab page_lock
with preemption disabled. If it got page_lock of all of pages
successfully, it can free zspage in the context. Otherwise, it queues
the free request and free zspage via workqueue in process context.

Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/uapi/linux/magic.h |   1 +
 mm/zsmalloc.c              | 552 +++++++++++++++++++++++++++++++++++++++------
 2 files changed, 487 insertions(+), 66 deletions(-)

diff --git a/include/uapi/linux/magic.h b/include/uapi/linux/magic.h
index e1fbe72c39c0..93b1affe4801 100644
--- a/include/uapi/linux/magic.h
+++ b/include/uapi/linux/magic.h
@@ -79,5 +79,6 @@
 #define NSFS_MAGIC		0x6e736673
 #define BPF_FS_MAGIC		0xcafe4a11
 #define BALLOON_KVM_MAGIC	0x13661366
+#define ZSMALLOC_MAGIC		0x58295829
 
 #endif /* __LINUX_MAGIC_H__ */
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 8d82e44c4644..042793015ecf 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -17,15 +17,14 @@
  *
  * Usage of struct page fields:
  *	page->private: points to zspage
- *	page->index: offset of the first object starting in this page.
- *		For the first page, this is always 0, so we use this field
- *		to store handle for huge object.
- *	page->next: links together all component pages of a zspage
+ *	page->freelist: links together all component pages of a zspage
+ *		For the huge page, this is always 0, so we use this field
+ *		to store handle.
  *
  * Usage of struct page flags:
  *	PG_private: identifies the first component page
  *	PG_private2: identifies the last component page
- *
+ *	PG_owner_priv_1: indentifies the huge component page
  */
 
 #include <linux/module.h>
@@ -47,6 +46,10 @@
 #include <linux/debugfs.h>
 #include <linux/zsmalloc.h>
 #include <linux/zpool.h>
+#include <linux/mount.h>
+#include <linux/migrate.h>
+
+#define ZSPAGE_MAGIC	0x58
 
 /*
  * This must be power of 2 and greater than of equal to sizeof(link_free).
@@ -128,8 +131,33 @@
  *  ZS_MIN_ALLOC_SIZE and ZS_SIZE_CLASS_DELTA must be multiple of ZS_ALIGN
  *  (reason above)
  */
+
+/*
+ * A zspage's class index and fullness group
+ * are encoded in its (first)page->mapping
+ */
+#define FULLNESS_BITS	2
+#define CLASS_BITS	8
+#define ISOLATED_BITS	3
+#define MAGIC_VAL_BITS	8
+
+
 #define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> CLASS_BITS)
 
+struct zspage {
+	struct {
+		unsigned int fullness:FULLNESS_BITS;
+		unsigned int class:CLASS_BITS;
+		unsigned int isolated:ISOLATED_BITS;
+		unsigned int magic:MAGIC_VAL_BITS;
+	};
+	unsigned int inuse;
+	unsigned int freeobj;
+	struct page *first_page;
+	struct list_head list; /* fullness list */
+	rwlock_t lock;
+};
+
 /*
  * We do not maintain any list for completely empty or full pages
  */
@@ -161,6 +189,8 @@ struct zs_size_stat {
 static struct dentry *zs_stat_root;
 #endif
 
+static struct vfsmount *zsmalloc_mnt;
+
 /*
  * number of size_classes
  */
@@ -243,24 +273,10 @@ struct zs_pool {
 #ifdef CONFIG_ZSMALLOC_STAT
 	struct dentry *stat_dentry;
 #endif
-};
-
-/*
- * A zspage's class index and fullness group
- * are encoded in its (first)page->mapping
- */
-#define FULLNESS_BITS	2
-#define CLASS_BITS	8
-
-struct zspage {
-	struct {
-		unsigned int fullness:FULLNESS_BITS;
-		unsigned int class:CLASS_BITS;
-	};
-	unsigned int inuse;
-	unsigned int freeobj;
-	struct page *first_page;
-	struct list_head list; /* fullness list */
+	struct inode *inode;
+	spinlock_t free_lock;
+	struct work_struct free_work;
+	struct list_head free_zspage;
 };
 
 struct mapping_area {
@@ -312,8 +328,11 @@ static struct zspage *cache_alloc_zspage(struct zs_pool *pool, gfp_t flags)
 	struct zspage *zspage;
 
 	zspage = kmem_cache_alloc(pool->zspage_cachep, flags & ~__GFP_HIGHMEM);
-	if (zspage)
+	if (zspage) {
 		memset(zspage, 0, sizeof(struct zspage));
+		zspage->magic = ZSPAGE_MAGIC;
+		rwlock_init(&zspage->lock);
+	}
 	return zspage;
 };
 
@@ -419,11 +438,27 @@ static unsigned int get_maxobj_per_zspage(int size, int pages_per_zspage)
 /* per-cpu VM mapping areas for zspage accesses that cross page boundaries */
 static DEFINE_PER_CPU(struct mapping_area, zs_map_area);
 
+static void inc_zspage_isolation(struct zspage *zspage)
+{
+	zspage->isolated++;
+}
+
+static void dec_zspage_isolation(struct zspage *zspage)
+{
+	zspage->isolated--;
+}
+
+static int get_zspage_isolation(struct zspage *zspage)
+{
+	return zspage->isolated;
+}
+
 static int is_first_page(struct page *page)
 {
 	return PagePrivate(page);
 }
 
+/* Protected by class->lock */
 static inline int get_zspage_inuse(struct zspage *zspage)
 {
 	return zspage->inuse;
@@ -439,20 +474,12 @@ static inline void mod_zspage_inuse(struct zspage *zspage, int val)
 	zspage->inuse += val;
 }
 
-static inline int get_first_obj_offset(struct page *page)
+static inline struct page *get_first_page(struct zspage *zspage)
 {
-	if (is_first_page(page))
-		return 0;
+	struct page *first_page = zspage->first_page;
 
-	return page->index;
-}
-
-static inline void set_first_obj_offset(struct page *page, int offset)
-{
-	if (is_first_page(page))
-		return;
-
-	page->index = offset;
+	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
+	return first_page;
 }
 
 static inline unsigned int get_freeobj(struct zspage *zspage)
@@ -469,6 +496,8 @@ static void get_zspage_mapping(struct zspage *zspage,
 				unsigned int *class_idx,
 				enum fullness_group *fullness)
 {
+	VM_BUG_ON(zspage->magic != ZSPAGE_MAGIC);
+
 	*fullness = zspage->fullness;
 	*class_idx = zspage->class;
 }
@@ -738,6 +767,7 @@ static void remove_zspage(struct size_class *class,
 		return;
 
 	VM_BUG_ON(list_empty(&class->fullness_list[fullness]));
+	VM_BUG_ON(get_zspage_isolation(zspage));
 
 	list_del_init(&zspage->list);
 	zs_stat_dec(class, fullness == ZS_ALMOST_EMPTY ?
@@ -764,8 +794,10 @@ static enum fullness_group fix_fullness_group(struct size_class *class,
 	if (newfg == currfg)
 		goto out;
 
-	remove_zspage(class, zspage, currfg);
-	insert_zspage(class, zspage, newfg);
+	if (!get_zspage_isolation(zspage)) {
+		remove_zspage(class, zspage, currfg);
+		insert_zspage(class, zspage, newfg);
+	}
 	set_zspage_mapping(zspage, class_idx, newfg);
 
 out:
@@ -808,19 +840,47 @@ static int get_pages_per_zspage(int class_size)
 	return max_usedpc_order;
 }
 
-static struct page *get_first_page(struct zspage *zspage)
+static struct zspage *get_zspage(struct page *page)
 {
-	return zspage->first_page;
+	struct zspage *zspage = (struct zspage *)page->private;
+
+	VM_BUG_ON(zspage->magic != ZSPAGE_MAGIC);
+	return zspage;
 }
 
-static struct zspage *get_zspage(struct page *page)
+static struct page *get_next_page(struct page *page)
 {
-	return (struct zspage *)page->private;
+	if (PageOwnerPriv1(page))
+		return NULL;
+
+	return page->freelist;
 }
 
-static struct page *get_next_page(struct page *page)
+/* Get byte offset of first object in the @page */
+static int get_first_obj_offset(struct size_class *class,
+				struct page *first_page, struct page *page)
 {
-	return page->next;
+	int pos, bound;
+	int page_idx = 0;
+	int ofs = 0;
+	struct page *cursor = first_page;
+
+	if (first_page == page)
+		goto out;
+
+	while (page != cursor) {
+		page_idx++;
+		cursor = get_next_page(cursor);
+	}
+
+	bound = PAGE_SIZE * page_idx;
+	pos = (((class->objs_per_zspage * class->size) *
+		page_idx / class->pages_per_zspage) / class->size
+	      ) * class->size;
+
+	ofs = (pos + class->size) % PAGE_SIZE;
+out:
+	return ofs;
 }
 
 /**
@@ -867,6 +927,11 @@ static unsigned long obj_to_head(struct size_class *class, struct page *page,
 		return *(unsigned long *)obj;
 }
 
+static inline int testpin_tag(unsigned long handle)
+{
+	return bit_spin_is_locked(HANDLE_PIN_BIT, (unsigned long *)handle);
+}
+
 static inline int trypin_tag(unsigned long handle)
 {
 	return bit_spin_trylock(HANDLE_PIN_BIT, (unsigned long *)handle);
@@ -884,22 +949,60 @@ static void unpin_tag(unsigned long handle)
 
 static void reset_page(struct page *page)
 {
+	__ClearPageMovable(page);
 	clear_bit(PG_private, &page->flags);
 	clear_bit(PG_private_2, &page->flags);
+	ClearPageOwnerPriv1(page);
 	set_page_private(page, 0);
-	page->index = 0;
+	page->freelist = NULL;
 }
 
-static void free_zspage(struct zs_pool *pool, struct zspage *zspage)
+/*
+ * To prevent zspage destroy during migration, zspage freeing should
+ * hold locks of all pages in the zspage.
+ */
+void lock_zspage(struct zspage *zspage)
+{
+	struct page *page = get_first_page(zspage);
+
+	do {
+		lock_page(page);
+	} while ((page = get_next_page(page)) != NULL);
+}
+
+int trylock_zspage(struct zspage *zspage)
+{
+	struct page *cursor, *fail;
+
+	for (cursor = get_first_page(zspage); cursor != NULL; cursor =
+					get_next_page(cursor)) {
+		if (!trylock_page(cursor)) {
+			fail = cursor;
+			goto unlock;
+		}
+	}
+
+	return 1;
+unlock:
+	for (cursor = get_first_page(zspage); cursor != fail; cursor =
+					get_next_page(cursor))
+		unlock_page(cursor);
+
+	return 0;
+}
+
+static void __free_zspage(struct zs_pool *pool, struct zspage *zspage)
 {
 	struct page *page, *next;
 
 	VM_BUG_ON(get_zspage_inuse(zspage));
 
-	next = page = zspage->first_page;
+	next = page = get_first_page(zspage);
 	do {
-		next = page->next;
+		VM_BUG_ON_PAGE(!PageLocked(page), page);
+		next = get_next_page(page);
 		reset_page(page);
+		unlock_page(page);
 		put_page(page);
 		page = next;
 	} while (page != NULL);
@@ -907,20 +1010,34 @@ static void free_zspage(struct zs_pool *pool, struct zspage *zspage)
 	cache_free_zspage(pool, zspage);
 }
 
+static void free_zspage(struct zs_pool *pool, struct zspage *zspage)
+{
+	VM_BUG_ON(get_zspage_inuse(zspage));
+
+	if (!trylock_zspage(zspage)) {
+		spin_lock(&pool->free_lock);
+		VM_BUG_ON(!list_empty(&zspage->list));
+		list_add(&zspage->list, &pool->free_zspage);
+		spin_unlock(&pool->free_lock);
+		schedule_work(&pool->free_work);
+		return;
+	}
+
+	__free_zspage(pool, zspage);
+}
+
 /* Initialize a newly allocated zspage */
 static void init_zspage(struct size_class *class, struct zspage *zspage)
 {
 	unsigned int freeobj = 1;
 	unsigned long off = 0;
-	struct page *page = zspage->first_page;
+	struct page *page = get_first_page(zspage);
 
 	while (page) {
 		struct page *next_page;
 		struct link_free *link;
 		void *vaddr;
 
-		set_first_obj_offset(page, off);
-
 		vaddr = kmap_atomic(page);
 		link = (struct link_free *)vaddr + off / sizeof(*link);
 
@@ -952,16 +1069,17 @@ static void init_zspage(struct size_class *class, struct zspage *zspage)
 	set_freeobj(zspage, 0);
 }
 
-static void create_page_chain(struct zspage *zspage, struct page *pages[],
-				int nr_pages)
+static void create_page_chain(struct size_class *class, struct zspage *zspage,
+				struct page *pages[])
 {
 	int i;
 	struct page *page;
 	struct page *prev_page = NULL;
+	int nr_pages = class->pages_per_zspage;
 
 	/*
 	 * Allocate individual pages and link them together as:
-	 * 1. all pages are linked together using page->next
+	 * 1. all pages are linked together using page->freelist
 	 * 2. each sub-page point to zspage using page->private
 	 *
 	 * we set PG_private to identify the first page (i.e. no other sub-page
@@ -970,20 +1088,43 @@ static void create_page_chain(struct zspage *zspage, struct page *pages[],
 	for (i = 0; i < nr_pages; i++) {
 		page = pages[i];
 		set_page_private(page, (unsigned long)zspage);
+		page->freelist = NULL;
 		if (i == 0) {
 			zspage->first_page = page;
 			SetPagePrivate(page);
+			if (class->huge)
+				SetPageOwnerPriv1(page);
 		} else {
-			prev_page->next = page;
+			prev_page->freelist = page;
 		}
-		if (i == nr_pages - 1) {
+		if (i == nr_pages - 1)
 			SetPagePrivate2(page);
-			page->next = NULL;
-		}
 		prev_page = page;
 	}
 }
 
+static void replace_sub_page(struct size_class *class, struct zspage *zspage,
+				struct page *newpage, struct page *oldpage)
+{
+	struct page *page;
+	struct page *pages[ZS_MAX_PAGES_PER_ZSPAGE] = {NULL, };
+	int idx = 0;
+
+	page = get_first_page(zspage);
+	do {
+		if (page == oldpage)
+			pages[idx] = newpage;
+		else
+			pages[idx] = page;
+		idx++;
+	} while ((page = get_next_page(page)) != NULL);
+
+	create_page_chain(class, zspage, pages);
+	if (class->huge)
+		newpage->index = oldpage->index;
+	__SetPageMovable(newpage, page_mapping(oldpage));
+}
+
 /*
  * Allocate a zspage for the given size class
  */
@@ -1010,7 +1151,7 @@ static struct zspage *alloc_zspage(struct zs_pool *pool,
 		pages[i] = page;
 	}
 
-	create_page_chain(zspage, pages, class->pages_per_zspage);
+	create_page_chain(class, zspage, pages);
 	init_zspage(class, zspage);
 
 	return zspage;
@@ -1286,6 +1427,10 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &page, &obj_idx);
 	zspage = get_zspage(page);
+
+	/* migration cannot move any subpage in this zspage */
+	read_lock(&zspage->lock);
+
 	get_zspage_mapping(zspage, &class_idx, &fg);
 	class = pool->size_class[class_idx];
 	off = (class->size * obj_idx) & ~PAGE_MASK;
@@ -1345,6 +1490,8 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 		__zs_unmap_object(area, pages, off, class->size);
 	}
 	put_cpu_var(zs_map_area);
+
+	read_unlock(&zspage->lock);
 	unpin_tag(handle);
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
@@ -1421,6 +1568,8 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 	zspage = find_get_zspage(class);
 
 	if (!zspage) {
+		struct page *page;
+
 		spin_unlock(&class->lock);
 		zspage = alloc_zspage(pool, class);
 		if (unlikely(!zspage)) {
@@ -1432,6 +1581,14 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 		atomic_long_add(class->pages_per_zspage,
 					&pool->pages_allocated);
 
+		/* We completely set up zspage so mark them as movable */
+		page = get_first_page(zspage);
+		do {
+			WARN_ON(!trylock_page(page));
+			__SetPageMovable(page, pool->inode->i_mapping);
+			unlock_page(page);
+		} while ((page = get_next_page(page)) != NULL);
+
 		spin_lock(&class->lock);
 		zs_stat_inc(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
 				class->size, class->pages_per_zspage));
@@ -1490,6 +1647,8 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	obj_to_location(obj, &f_page, &f_objidx);
 	zspage = get_zspage(f_page);
 
+	read_lock(&zspage->lock);
+
 	get_zspage_mapping(zspage, &class_idx, &fullness);
 	class = pool->size_class[class_idx];
 
@@ -1501,11 +1660,14 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 				class->size, class->pages_per_zspage));
 		atomic_long_sub(class->pages_per_zspage,
 				&pool->pages_allocated);
+		read_unlock(&zspage->lock);
 		free_zspage(pool, zspage);
+		spin_unlock(&class->lock);
+	} else {
+		read_unlock(&zspage->lock);
+		spin_unlock(&class->lock);
 	}
-	spin_unlock(&class->lock);
 	unpin_tag(handle);
-
 	cache_free_handle(pool, handle);
 }
 EXPORT_SYMBOL_GPL(zs_free);
@@ -1584,8 +1746,9 @@ static unsigned long find_alloced_obj(struct size_class *class,
 	int offset = 0;
 	unsigned long handle = 0;
 	void *addr = kmap_atomic(page);
+	struct zspage *zspage = get_zspage(page);
 
-	offset = get_first_obj_offset(page);
+	offset = get_first_obj_offset(class, get_first_page(zspage), page);
 	offset += class->size * index;
 
 	while (offset < PAGE_SIZE) {
@@ -1681,6 +1844,7 @@ static struct zspage *isolate_zspage(struct size_class *class, bool source)
 		zspage = list_first_entry_or_null(&class->fullness_list[fg[i]],
 							struct zspage, list);
 		if (zspage) {
+			VM_BUG_ON(get_zspage_isolation(zspage));
 			remove_zspage(class, zspage, fg[i]);
 			return zspage;
 		}
@@ -1701,6 +1865,8 @@ static enum fullness_group putback_zspage(struct size_class *class,
 {
 	enum fullness_group fullness;
 
+	VM_BUG_ON(get_zspage_isolation(zspage));
+
 	fullness = get_fullness_group(class, zspage);
 	insert_zspage(class, zspage, fullness);
 	set_zspage_mapping(zspage, class->index, fullness);
@@ -1739,10 +1905,10 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 			break;
 
 		cc.index = 0;
-		cc.s_page = src_zspage->first_page;
+		cc.s_page = get_first_page(src_zspage);
 
 		while ((dst_zspage = isolate_zspage(class, false))) {
-			cc.d_page = dst_zspage->first_page;
+			cc.d_page = get_first_page(dst_zspage);
 			/*
 			 * If there is no more space in dst_page, resched
 			 * and see if anyone had allocated another zspage.
@@ -1859,6 +2025,218 @@ static int zs_register_shrinker(struct zs_pool *pool)
 	return register_shrinker(&pool->shrinker);
 }
 
+bool zs_page_isolate(struct page *page, isolate_mode_t mode)
+{
+	struct zs_pool *pool;
+	struct size_class *class;
+	int class_idx;
+	enum fullness_group fullness;
+	struct zspage *zspage;
+	struct address_space *mapping;
+
+	/*
+	 * Page is locked so zspage couldn't be destroyed. For detail, look at
+	 * lock_zspage in free_zspage.
+	 */
+	VM_BUG_ON_PAGE(!PageMovable(page), page);
+	VM_BUG_ON_PAGE(PageIsolated(page), page);
+
+	zspage = get_zspage(page);
+
+	/*
+	 * Without class lock, fullness could be stale while class_idx is okay
+	 * because class_idx is constant unless page is freed so we should get
+	 * fullness again under class lock.
+	 */
+	get_zspage_mapping(zspage, &class_idx, &fullness);
+	mapping = page_mapping(page);
+	pool = mapping->private_data;
+	class = pool->size_class[class_idx];
+
+	spin_lock(&class->lock);
+	if (get_zspage_inuse(zspage) == 0) {
+		spin_unlock(&class->lock);
+		return false;
+	}
+
+	/* zspage is isolated for object migration */
+	if (list_empty(&zspage->list) && !get_zspage_isolation(zspage)) {
+		spin_unlock(&class->lock);
+		return false;
+	}
+
+	/*
+	 * If this is first time isolation for the zspage, isolate zspage from
+	 * size_class to prevent further object allocation from the zspage.
+	 */
+	if (!list_empty(&zspage->list) && !get_zspage_isolation(zspage)) {
+		get_zspage_mapping(zspage, &class_idx, &fullness);
+		remove_zspage(class, zspage, fullness);
+	}
+
+	inc_zspage_isolation(zspage);
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
+	struct zspage *zspage;
+	struct page *dummy;
+	void *s_addr, *d_addr, *addr;
+	int offset, pos;
+	unsigned long handle, head;
+	unsigned long old_obj, new_obj;
+	unsigned int obj_idx;
+	int ret = -EAGAIN;
+
+	VM_BUG_ON_PAGE(!PageMovable(page), page);
+	VM_BUG_ON_PAGE(!PageIsolated(page), page);
+
+	zspage = get_zspage(page);
+
+	/* Concurrent compactor cannot migrate any subpage in zspage */
+	write_lock(&zspage->lock);
+	get_zspage_mapping(zspage, &class_idx, &fullness);
+	pool = mapping->private_data;
+	class = pool->size_class[class_idx];
+	offset = get_first_obj_offset(class, get_first_page(zspage), page);
+
+	spin_lock(&class->lock);
+	if (!get_zspage_inuse(zspage))
+		goto unlock_class;
+
+	pos = offset;
+	s_addr = kmap_atomic(page);
+	while (pos < PAGE_SIZE) {
+		head = obj_to_head(class, page, s_addr + pos);
+		if (head & OBJ_ALLOCATED_TAG) {
+			handle = head & ~OBJ_ALLOCATED_TAG;
+			if (!trypin_tag(handle))
+				goto unpin_objects;
+		}
+		pos += class->size;
+	}
+
+	/*
+	 * Here, any user cannot access all objects in the zspage so let's move.
+	 */
+	d_addr = kmap_atomic(newpage);
+	memcpy(d_addr, s_addr, PAGE_SIZE);
+	kunmap_atomic(d_addr);
+
+	for (addr = s_addr + offset; addr < s_addr + pos;
+					addr += class->size) {
+		head = obj_to_head(class, page, addr);
+		if (head & OBJ_ALLOCATED_TAG) {
+			handle = head & ~OBJ_ALLOCATED_TAG;
+			if (!testpin_tag(handle))
+				BUG();
+
+			old_obj = handle_to_obj(handle);
+			obj_to_location(old_obj, &dummy, &obj_idx);
+			new_obj = (unsigned long)location_to_obj(newpage,
+								obj_idx);
+			new_obj |= BIT(HANDLE_PIN_BIT);
+			record_obj(handle, new_obj);
+		}
+	}
+
+	replace_sub_page(class, zspage, newpage, page);
+	get_page(newpage);
+
+	dec_zspage_isolation(zspage);
+
+	/*
+	 * Page migration is done so let's putback isolated zspage to
+	 * the list if @page is final isolated subpage in the zspage.
+	 */
+	if (!get_zspage_isolation(zspage))
+		putback_zspage(class, zspage);
+
+	reset_page(page);
+	put_page(page);
+	page = newpage;
+
+	ret = MIGRATEPAGE_SUCCESS;
+unpin_objects:
+	for (addr = s_addr + offset; addr < s_addr + pos;
+						addr += class->size) {
+		head = obj_to_head(class, page, addr);
+		if (head & OBJ_ALLOCATED_TAG) {
+			handle = head & ~OBJ_ALLOCATED_TAG;
+			if (!testpin_tag(handle))
+				BUG();
+			unpin_tag(handle);
+		}
+	}
+	kunmap_atomic(s_addr);
+unlock_class:
+	spin_unlock(&class->lock);
+	write_unlock(&zspage->lock);
+
+	return ret;
+}
+
+void zs_page_putback(struct page *page)
+{
+	struct zs_pool *pool;
+	struct size_class *class;
+	int class_idx;
+	enum fullness_group dummy;
+	struct address_space *mapping;
+	struct zspage *zspage;
+
+	VM_BUG_ON_PAGE(!PageMovable(page), page);
+	VM_BUG_ON_PAGE(!PageIsolated(page), page);
+
+	zspage = get_zspage(page);
+	get_zspage_mapping(zspage, &class_idx, &dummy);
+	mapping = page_mapping(page);
+	pool = mapping->private_data;
+	class = pool->size_class[class_idx];
+
+	spin_lock(&class->lock);
+	dec_zspage_isolation(zspage);
+	if (!get_zspage_isolation(zspage))
+		putback_zspage(class, zspage);
+	spin_unlock(&class->lock);
+}
+
+const struct address_space_operations zsmalloc_aops = {
+	.isolate_page = zs_page_isolate,
+	.migratepage = zs_page_migrate,
+	.putback_page = zs_page_putback,
+};
+
+/*
+ * Caller should hold page_lock of all pages in the zspage
+ * In here, we cannot use zspage meta data.
+ */
+static void async_free_zspage(struct work_struct *work)
+{
+	struct zspage *zspage, *tmp;
+	LIST_HEAD(free_pages);
+	struct zs_pool *pool = container_of(work, struct zs_pool,
+					free_work);
+
+	spin_lock(&pool->free_lock);
+	list_splice_init(&pool->free_zspage, &free_pages);
+	spin_unlock(&pool->free_lock);
+
+	list_for_each_entry_safe(zspage, tmp, &free_pages, list) {
+		list_del(&zspage->list);
+		lock_zspage(zspage);
+		__free_zspage(pool, zspage);
+	}
+};
+
 /**
  * zs_create_pool - Creates an allocation pool to work from.
  * @flags: allocation flags used to allocate pool metadata
@@ -1879,6 +2257,10 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 	if (!pool)
 		return NULL;
 
+	INIT_WORK(&pool->free_work, async_free_zspage);
+	INIT_LIST_HEAD(&pool->free_zspage);
+	spin_lock_init(&pool->free_lock);
+
 	pool->size_class = kcalloc(zs_size_classes, sizeof(struct size_class *),
 			GFP_KERNEL);
 	if (!pool->size_class) {
@@ -1944,11 +2326,21 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
 		prev_class = class;
 	}
 
+	INIT_LIST_HEAD(&pool->free_zspage);
 	pool->flags = flags;
 
 	if (zs_pool_stat_create(pool, name))
 		goto err;
 
+	pool->inode = alloc_anon_inode(zsmalloc_mnt->mnt_sb);
+	if (IS_ERR(pool->inode)) {
+		pool->inode = NULL;
+		goto err;
+	}
+
+	pool->inode->i_mapping->a_ops = &zsmalloc_aops;
+	pool->inode->i_mapping->private_data = pool;
+
 	/*
 	 * Not critical, we still can use the pool
 	 * and user can trigger compaction manually.
@@ -1967,7 +2359,11 @@ void zs_destroy_pool(struct zs_pool *pool)
 {
 	int i;
 
+	flush_work(&pool->free_work);
+
 	zs_unregister_shrinker(pool);
+	if (pool->inode)
+		iput(pool->inode);
 	zs_pool_stat_destroy(pool);
 
 	for (i = 0; i < zs_size_classes; i++) {
@@ -1996,10 +2392,33 @@ void zs_destroy_pool(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_destroy_pool);
 
+static struct dentry *zs_mount(struct file_system_type *fs_type,
+				int flags, const char *dev_name, void *data)
+{
+	static const struct dentry_operations ops = {
+		.d_dname = simple_dname,
+	};
+
+	return mount_pseudo(fs_type, "zsmalloc:", NULL, &ops, ZSMALLOC_MAGIC);
+}
+
+static struct file_system_type zsmalloc_fs = {
+	.name		= "zsmalloc",
+	.mount		= zs_mount,
+	.kill_sb	= kill_anon_super,
+};
+
 static int __init zs_init(void)
 {
-	int ret = zs_register_cpu_notifier();
+	int ret;
 
+	zsmalloc_mnt = kern_mount(&zsmalloc_fs);
+	if (IS_ERR(zsmalloc_mnt)) {
+		ret = PTR_ERR(zsmalloc_mnt);
+		goto out;
+	}
+
+	ret = zs_register_cpu_notifier();
 	if (ret)
 		goto notifier_fail;
 
@@ -2022,7 +2441,8 @@ static int __init zs_init(void)
 #endif
 notifier_fail:
 	zs_unregister_cpu_notifier();
-
+	kern_unmount(zsmalloc_mnt);
+out:
 	return ret;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
