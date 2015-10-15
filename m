Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1F67C82F64
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 05:09:32 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so82192868pab.0
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 02:09:31 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id fm3si20089075pab.106.2015.10.15.02.09.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Oct 2015 02:09:29 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [RFC v2 2/3] zsmalloc: mark its page "PageMigration"
Date: Thu, 15 Oct 2015 17:09:01 +0800
Message-ID: <1444900142-1996-3-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1444900142-1996-1-git-send-email-zhuhui@xiaomi.com>
References: <1444900142-1996-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey
 Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal
 Hocko <mhocko@suse.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jennifer Herbert <jennifer.herbert@citrix.com>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil
 Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, "Steven Rostedt (Red Hat)" <rostedt@goodmis.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <wanpeng.li@hotmail.com>, Geert Uytterhoeven <geert+renesas@glider.be>, Greg
 Thelen <gthelen@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

Most of idea is same with prev version that mark zsmalloc's page
"PageMigration" and introduce the function for the interfaces
zs_isolatepage, zs_isolatepage and zs_migratepage.

But I put data of zs from struct page to struct migration.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 include/linux/migrate.h |  13 ++
 mm/zsmalloc.c           | 605 ++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 578 insertions(+), 40 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 8b8caba..b8f9448 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -32,6 +32,19 @@ struct migration {
 	void (*put)(struct page *page);
 	int (*move)(struct page *page, struct page *newpage, int force,
 		       enum migrate_mode mode);
+#ifdef CONFIG_ZSMALLOC
+	struct {
+		/* For all zs_page.  */
+		struct list_head zs_lru;
+		struct page *zs_page;
+		void *zs_class;
+
+		/* For all zs_page first_page.  */
+		int zs_fg;
+		unsigned zs_inuse;
+		unsigned zs_objects;
+	};
+#endif
 };
 
 #define PAGE_MIGRATION_MAPCOUNT_VALUE (-512)
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 3134a37..5282a03 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -21,8 +21,11 @@
  *		starting in this page. For the first page, this is
  *		always 0, so we use this field (aka freelist) to point
  *		to the first free object in zspage.
- *	page->lru: links together all component pages (except the first page)
- *		of a zspage
+ *	zs_page_lru(page): links together all component pages (except the
+		first page) of a zspage
+ *	page->migration->zs_class (CONFIG_MIGRATION): class of the zspage
+ *	page->migration->zs_fg (CONFIG_MIGRATION): fullness group
+ *		of the zspage
  *
  *	For _first_ page only:
  *
@@ -33,11 +36,12 @@
  *	page->freelist: points to the first free object in zspage.
  *		Free objects are linked together using in-place
  *		metadata.
- *	page->objects: maximum number of objects we can store in this
+ *	zs_page_objects(page): maximum number of objects we can store in this
  *		zspage (class->zspage_order * PAGE_SIZE / class->size)
- *	page->lru: links together first pages of various zspages.
+ *	zs_page_lru(page): links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
- *	page->mapping: class index and fullness group of the zspage
+ *	page->mapping(no CONFIG_MIGRATION): class index and fullness group
+ *		of the zspage
  *
  * Usage of struct page flags:
  *	PG_private: identifies the first component page
@@ -64,6 +68,9 @@
 #include <linux/debugfs.h>
 #include <linux/zsmalloc.h>
 #include <linux/zpool.h>
+#include <linux/migrate.h>
+#include <linux/rwlock.h>
+#include <linux/mm.h>
 
 /*
  * This must be power of 2 and greater than of equal to sizeof(link_free).
@@ -214,6 +221,8 @@ struct size_class {
 
 	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
 	bool huge;
+
+	atomic_t count;
 };
 
 /*
@@ -279,6 +288,12 @@ struct mapping_area {
 	bool huge;
 };
 
+#ifdef CONFIG_MIGRATION
+static rwlock_t zs_class_rwlock;
+static rwlock_t zs_tag_rwlock;
+struct kmem_cache *zs_migration_cachep;
+#endif
+
 static int create_handle_cache(struct zs_pool *pool)
 {
 	pool->handle_cachep = kmem_cache_create("zs_handle", ZS_HANDLE_SIZE,
@@ -294,7 +309,7 @@ static void destroy_handle_cache(struct zs_pool *pool)
 static unsigned long alloc_handle(struct zs_pool *pool)
 {
 	return (unsigned long)kmem_cache_alloc(pool->handle_cachep,
-		pool->flags & ~__GFP_HIGHMEM);
+		pool->flags & ~(__GFP_HIGHMEM | __GFP_MOVABLE));
 }
 
 static void free_handle(struct zs_pool *pool, unsigned long handle)
@@ -307,6 +322,41 @@ static void record_obj(unsigned long handle, unsigned long obj)
 	*(unsigned long *)handle = obj;
 }
 
+#ifdef CONFIG_MIGRATION
+#define zs_page_lru(page)	((page)->migration->zs_lru)
+#define zs_page_inuse(page)	((page)->migration->zs_inuse)
+#define zs_page_objects(page)	((page)->migration->zs_objects)
+
+static struct migration *alloc_migration(gfp_t flags)
+{
+	return (struct migration *)kmem_cache_alloc(zs_migration_cachep,
+		flags & ~(__GFP_HIGHMEM | __GFP_MOVABLE));
+}
+
+static void free_migration(struct migration *migration)
+{
+	kmem_cache_free(zs_migration_cachep, (void *)migration);
+}
+
+void zs_put_page(struct page *page)
+{
+	if (put_page_testzero(page)) {
+		if (page->migration) {
+			free_migration(page->migration);
+			page->migration = NULL;
+		}
+		free_hot_cold_page(page, 0);
+	}
+}
+
+#else
+#define zs_page_lru(page)	((page)->lru)
+#define zs_page_inuse(page)	((page)->inuse)
+#define zs_page_objects(page)	((page)->objects)
+
+#define zs_put_page(page)	put_page(page)
+#endif
+
 /* zpool driver */
 
 #ifdef CONFIG_ZPOOL
@@ -404,6 +454,7 @@ static int is_last_page(struct page *page)
 	return PagePrivate2(page);
 }
 
+#ifndef CONFIG_MIGRATION
 static void get_zspage_mapping(struct page *page, unsigned int *class_idx,
 				enum fullness_group *fullness)
 {
@@ -425,6 +476,7 @@ static void set_zspage_mapping(struct page *page, unsigned int class_idx,
 			(fullness & FULLNESS_MASK);
 	page->mapping = (struct address_space *)m;
 }
+#endif
 
 /*
  * zsmalloc divides the pool into various size classes where each
@@ -612,8 +664,8 @@ static enum fullness_group get_fullness_group(struct page *page)
 	enum fullness_group fg;
 	BUG_ON(!is_first_page(page));
 
-	inuse = page->inuse;
-	max_objects = page->objects;
+	inuse = zs_page_inuse(page);
+	max_objects = zs_page_objects(page);
 
 	if (inuse == 0)
 		fg = ZS_EMPTY;
@@ -656,8 +708,8 @@ static void insert_zspage(struct page *page, struct size_class *class,
 	 * We want to see more ZS_FULL pages and less almost
 	 * empty/full. Put pages with higher ->inuse first.
 	 */
-	list_add_tail(&page->lru, &(*head)->lru);
-	if (page->inuse >= (*head)->inuse)
+	list_add_tail(&zs_page_lru(page), &zs_page_lru(*head));
+	if (zs_page_inuse(page) >= zs_page_inuse(*head))
 		*head = page;
 }
 
@@ -677,13 +729,23 @@ static void remove_zspage(struct page *page, struct size_class *class,
 
 	head = &class->fullness_list[fullness];
 	BUG_ON(!*head);
-	if (list_empty(&(*head)->lru))
+	if (list_empty(&zs_page_lru(*head)))
 		*head = NULL;
-	else if (*head == page)
-		*head = (struct page *)list_entry((*head)->lru.next,
+	else if (*head == page) {
+#ifdef CONFIG_MIGRATION
+		struct migration *migration;
+
+		migration = (struct migration *)
+				list_entry(zs_page_lru(*head).next,
+					   struct migration, zs_lru);
+		*head = migration->zs_page;
+#else
+		*head = (struct page *)list_entry(zs_page_lru(*head).next,
 					struct page, lru);
+#endif
+	}
 
-	list_del_init(&page->lru);
+	list_del_init(&zs_page_lru(page));
 	zs_stat_dec(class, fullness == ZS_ALMOST_EMPTY ?
 			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
 }
@@ -700,19 +762,29 @@ static void remove_zspage(struct page *page, struct size_class *class,
 static enum fullness_group fix_fullness_group(struct size_class *class,
 						struct page *page)
 {
+#ifndef CONFIG_MIGRATION
 	int class_idx;
+#endif
 	enum fullness_group currfg, newfg;
 
 	BUG_ON(!is_first_page(page));
 
+#ifdef CONFIG_MIGRATION
+	currfg = page->migration->zs_fg;
+#else
 	get_zspage_mapping(page, &class_idx, &currfg);
+#endif
 	newfg = get_fullness_group(page);
 	if (newfg == currfg)
 		goto out;
 
 	remove_zspage(page, class, currfg);
 	insert_zspage(page, class, newfg);
+#ifdef CONFIG_MIGRATION
+	page->migration->zs_fg = newfg;
+#else
 	set_zspage_mapping(page, class_idx, newfg);
+#endif
 
 out:
 	return newfg;
@@ -775,8 +847,18 @@ static struct page *get_next_page(struct page *page)
 		next = NULL;
 	else if (is_first_page(page))
 		next = (struct page *)page_private(page);
-	else
-		next = list_entry(page->lru.next, struct page, lru);
+	else {
+#ifdef CONFIG_MIGRATION
+		struct migration *migration;
+
+		migration = (struct migration *)
+				list_entry(zs_page_lru(page).next,
+					   struct migration, zs_lru);
+		next = migration->zs_page;
+#else
+		next = list_entry(zs_page_lru(page).next, struct page, lru);
+#endif
+	}
 
 	return next;
 }
@@ -809,9 +891,14 @@ static void *location_to_obj(struct page *page, unsigned long obj_idx)
 static void obj_to_location(unsigned long obj, struct page **page,
 				unsigned long *obj_idx)
 {
-	obj >>= OBJ_TAG_BITS;
-	*page = pfn_to_page(obj >> OBJ_INDEX_BITS);
-	*obj_idx = (obj & OBJ_INDEX_MASK);
+	if (obj == 0) {
+		*page = NULL;
+		*obj_idx = 0;
+	} else {
+		obj >>= OBJ_TAG_BITS;
+		*page = pfn_to_page(obj >> OBJ_INDEX_BITS);
+		*obj_idx = (obj & OBJ_INDEX_MASK);
+	}
 }
 
 static unsigned long handle_to_obj(unsigned long handle)
@@ -859,39 +946,59 @@ static void unpin_tag(unsigned long handle)
 	clear_bit_unlock(HANDLE_PIN_BIT, ptr);
 }
 
+
 static void reset_page(struct page *page)
 {
+#ifdef CONFIG_MIGRATION
+	/* Lock the page to protect the atomic access of page->migration.  */
+	lock_page(page);
+#endif
 	clear_bit(PG_private, &page->flags);
 	clear_bit(PG_private_2, &page->flags);
 	set_page_private(page, 0);
+#ifndef CONFIG_MIGRATION
 	page->mapping = NULL;
+#endif
 	page->freelist = NULL;
 	page_mapcount_reset(page);
+#ifdef CONFIG_MIGRATION
+	unlock_page(page);
+#endif
 }
 
 static void free_zspage(struct page *first_page)
 {
-	struct page *nextp, *tmp, *head_extra;
+#ifdef CONFIG_MIGRATION
+	struct migration *tmp, *nextm;
+#else
+	struct page *tmp;
+#endif
+	struct page *nextp, *head_extra;
 
 	BUG_ON(!is_first_page(first_page));
-	BUG_ON(first_page->inuse);
+	BUG_ON(zs_page_inuse(first_page));
 
 	head_extra = (struct page *)page_private(first_page);
 
 	reset_page(first_page);
-	__free_page(first_page);
+	zs_put_page(first_page);
 
 	/* zspage with only 1 system page */
 	if (!head_extra)
 		return;
-
-	list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
-		list_del(&nextp->lru);
+#ifdef CONFIG_MIGRATION
+	list_for_each_entry_safe(nextm, tmp, &zs_page_lru(head_extra),
+				 zs_lru) {
+		nextp = nextm->zs_page;
+#else
+	list_for_each_entry_safe(nextp, tmp, &zs_page_lru(head_extra), lru) {
+#endif
+		list_del(&zs_page_lru(nextp));
 		reset_page(nextp);
-		__free_page(nextp);
+		zs_put_page(nextp);
 	}
 	reset_page(head_extra);
-	__free_page(head_extra);
+	zs_put_page(head_extra);
 }
 
 /* Initialize a newly allocated zspage */
@@ -937,6 +1044,311 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 	}
 }
 
+#ifdef CONFIG_MIGRATION
+static void
+get_class(struct size_class *class)
+{
+	atomic_inc(&class->count);
+}
+
+static void
+put_class(struct size_class *class)
+{
+	if (atomic_dec_and_test(&class->count))
+		kfree(class);
+}
+
+static int zs_isolatepage(struct page *page)
+{
+	int ret = -EBUSY;
+
+	if (!get_page_unless_zero(page))
+		return -EBUSY;
+
+	read_lock(&zs_class_rwlock);
+	lock_page(page);
+
+	if (page_count(page) != 2)
+		goto put_out;
+	if (!page->migration)
+		goto put_out;
+	get_class(page->migration->zs_class);
+
+	ret = 0;
+out:
+	unlock_page(page);
+	read_unlock(&zs_class_rwlock);
+	return ret;
+
+put_out:
+	zs_put_page(page);
+	goto out;
+}
+
+static void zs_putpage(struct page *page)
+{
+	put_class(page->migration->zs_class);
+	zs_put_page(page);
+}
+
+struct zspage_loop_struct {
+	struct size_class *class;
+	struct page *page;
+	struct page *newpage;
+	void *newaddr;
+
+	struct page *cur_page;
+	void *cur_addr;
+
+	unsigned long offset;
+	unsigned int idx;
+};
+
+static void
+zspage_migratepage_obj_callback(unsigned long head,
+				struct zspage_loop_struct *zls)
+{
+	BUG_ON(zls == NULL);
+
+	if (head & OBJ_ALLOCATED_TAG) {
+		unsigned long copy_size;
+		unsigned long newobj;
+		unsigned long handle;
+
+		/* Migratepage allocated just need handle the zls->page.  */
+		if (zls->cur_page != zls->page)
+			return;
+
+		copy_size = zls->class->size;
+
+		if (zls->offset + copy_size > PAGE_SIZE)
+			copy_size = PAGE_SIZE - zls->offset;
+
+		newobj = (unsigned long)location_to_obj(zls->newpage, zls->idx);
+
+		/* Remove OBJ_ALLOCATED_TAG will get the real handle.  */
+		handle = head & ~OBJ_ALLOCATED_TAG;
+		record_obj(handle, newobj);
+
+		/* Copy allocated chunk to allocated chunk.
+		 * Handle is included in it.
+		 */
+		memcpy(zls->newaddr + zls->offset,
+		       zls->cur_addr + zls->offset, copy_size);
+	} else {
+		struct link_free *link;
+		unsigned long obj;
+		unsigned long tmp_idx;
+		struct page *tmp_page;
+
+		link = (struct link_free *)(zls->cur_addr + zls->offset);
+		obj = (unsigned long)link->next;
+
+		obj_to_location(obj, &tmp_page, &tmp_idx);
+		if (tmp_page == zls->page) {
+			/* Update new obj with newpage to current link.  */
+			obj = (unsigned long)location_to_obj(zls->newpage,
+							     tmp_idx);
+			link->next = (void *)obj;
+		}
+
+		if (zls->cur_page == zls->page) {
+			/* Update obj to link of newaddr.  */
+			link = (struct link_free *)(zls->newaddr + zls->offset);
+			link->next = (void *)obj;
+		}
+	}
+}
+
+static void
+zspage_loop_1(struct size_class *class, struct page *cur_page,
+	      struct zspage_loop_struct *zls,
+	      void (*callback)(unsigned long head,
+			       struct zspage_loop_struct *zls))
+{
+	void *addr;
+	unsigned long m_offset = 0;
+	unsigned int obj_idx = 0;
+
+	if (!is_first_page(cur_page))
+		m_offset = cur_page->index;
+
+	addr = kmap_atomic(cur_page);
+
+	if (zls) {
+		zls->cur_page = cur_page;
+		zls->cur_addr = addr;
+	}
+
+	while (m_offset < PAGE_SIZE) {
+		unsigned long head = obj_to_head(class, cur_page,
+						 addr + m_offset);
+
+		if (zls) {
+			zls->offset = m_offset;
+			zls->idx = obj_idx;
+		}
+
+		callback(head, zls);
+
+		m_offset += class->size;
+		obj_idx++;
+	}
+
+	kunmap_atomic(addr);
+}
+
+static void
+zspage_loop(struct size_class *class, struct page *first_page,
+	    struct page *page, struct page *newpage,
+	    void (*callback)(unsigned long head,
+			     struct zspage_loop_struct *zls))
+{
+	struct page *cur_page;
+	struct zspage_loop_struct zl;
+	struct zspage_loop_struct *zls = NULL;
+
+	BUG_ON(!is_first_page(first_page));
+
+	if (page) {
+		zls = &zl;
+		zls->class = class;
+		zls->page = page;
+		zls->newpage = newpage;
+		zls->newaddr = kmap_atomic(zls->newpage);
+	}
+
+	cur_page = first_page;
+	while (cur_page) {
+		zspage_loop_1(class, cur_page, zls, callback);
+		cur_page = get_next_page(cur_page);
+	}
+
+	if (zls)
+		kunmap_atomic(zls->newaddr);
+}
+
+static int
+zs_movepage(struct page *page, struct page *newpage, int force,
+	    enum migrate_mode mode)
+{
+	int ret = -EAGAIN;
+	struct size_class *class = page->migration->zs_class;
+	struct page *first_page;
+
+	write_lock(&zs_tag_rwlock);
+	spin_lock(&class->lock);
+
+	if (page_count(page) <= 1)
+		goto out;
+
+	first_page = get_first_page(page);
+
+	INIT_LIST_HEAD(&newpage->lru);
+	if (page == first_page) {	/* first page */
+		struct page **head;
+
+		newpage->freelist = page->freelist;
+		SetPagePrivate(newpage);
+
+		if (class->huge) {
+			unsigned long handle = page_private(page);
+			unsigned long obj
+				= (unsigned long)location_to_obj(newpage, 0);
+
+			if (handle != 0) {
+				void *addr, *newaddr;
+
+				/* The page is allocated.  */
+				handle = handle & ~OBJ_ALLOCATED_TAG;
+				record_obj(handle, obj);
+				addr = kmap_atomic(page);
+				newaddr = kmap_atomic(newpage);
+				memcpy(newaddr, addr, class->size);
+				kunmap_atomic(newaddr);
+				kunmap_atomic(addr);
+			} else
+				newpage->freelist = (void *)obj;
+			set_page_private(newpage, handle);
+		} else {
+			struct page *head_extra
+				= (struct page *)page_private(page);
+
+			if (head_extra) {
+				struct migration *nextm;
+
+				head_extra->first_page = newpage;
+				list_for_each_entry(nextm,
+						    &zs_page_lru(head_extra),
+						    zs_lru)
+					nextm->zs_page->first_page = newpage;
+			}
+			set_page_private(newpage, (unsigned long)head_extra);
+		}
+
+		head = &class->fullness_list[first_page->migration->zs_fg];
+		BUG_ON(!*head);
+		if (*head == page)
+			*head = newpage;
+	} else {
+		void *addr, *newaddr;
+
+		newpage->first_page = page->first_page;
+		newpage->index = page->index;
+
+		if (page->index > 0) {
+			addr = kmap_atomic(page);
+			newaddr = kmap_atomic(newpage);
+			memcpy(newaddr, addr, page->index);
+			kunmap_atomic(newaddr);
+			kunmap_atomic(addr);
+		}
+	}
+	if (is_last_page(page))	/* last page */
+		SetPagePrivate2(newpage);
+
+	if (!class->huge) {
+		zspage_loop(class, first_page, page, newpage,
+			    zspage_migratepage_obj_callback);
+	}
+
+	/* Add newpage to zspage.  */
+	if (first_page == page)
+		first_page = newpage;
+	else {
+		if ((struct page *)page_private(first_page) == page)
+			set_page_private(first_page, (unsigned long)newpage);
+	}
+	newpage->migration = page->migration;
+	newpage->migration->zs_page = newpage;
+
+	if (!class->huge) {
+		struct page *tmp_page;
+		unsigned long tmp_idx;
+
+		/* Update first_page->freelist if need.  */
+		obj_to_location((unsigned long)first_page->freelist,
+				&tmp_page, &tmp_idx);
+		if (tmp_page == page)
+			first_page->freelist = location_to_obj(newpage,
+							       tmp_idx);
+	}
+
+	get_page(newpage);
+	__SetPageMigration(newpage);
+
+	page->migration = NULL;
+	reset_page(page);
+	zs_put_page(page);
+
+	ret = MIGRATEPAGE_SUCCESS;
+out:
+	spin_unlock(&class->lock);
+	write_unlock(&zs_tag_rwlock);
+	return ret;
+}
+#endif
+
 /*
  * Allocate a zspage for the given size class
  */
@@ -948,11 +1360,12 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	/*
 	 * Allocate individual pages and link them together as:
 	 * 1. first page->private = first sub-page
-	 * 2. all sub-pages are linked together using page->lru
+	 * 2. all sub-pages are linked together using zs_page_lru
 	 * 3. each sub-page is linked to the first page using page->first_page
 	 *
 	 * For each size class, First/Head pages are linked together using
-	 * page->lru. Also, we set PG_private to identify the first page
+	 * zs_page_lru.
+	 * Also, we set PG_private to identify the first page
 	 * (i.e. no other sub-page has this flag set) and PG_private_2 to
 	 * identify the last page.
 	 */
@@ -963,20 +1376,35 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 		page = alloc_page(flags);
 		if (!page)
 			goto cleanup;
+#ifdef CONFIG_MIGRATION
+		page->migration = alloc_migration(flags);
+		if (!page->migration) {
+			__free_page(page);
+			goto cleanup;
+		}
+#endif
 
 		INIT_LIST_HEAD(&page->lru);
+#ifdef CONFIG_MIGRATION
+		page->migration->isolate = zs_isolatepage;
+		page->migration->put = zs_putpage;
+		page->migration->move = zs_movepage;
+		INIT_LIST_HEAD(&page->migration->zs_lru);
+		page->migration->zs_page = page;
+		page->migration->zs_class = class;
+#endif
 		if (i == 0) {	/* first page */
 			SetPagePrivate(page);
 			set_page_private(page, 0);
 			first_page = page;
-			first_page->inuse = 0;
+			zs_page_inuse(first_page) = 0;
 		}
 		if (i == 1)
 			set_page_private(first_page, (unsigned long)page);
 		if (i >= 1)
 			page->first_page = first_page;
 		if (i >= 2)
-			list_add(&page->lru, &prev_page->lru);
+			list_add(&zs_page_lru(page), &zs_page_lru(prev_page));
 		if (i == class->pages_per_zspage - 1)	/* last page */
 			SetPagePrivate2(page);
 		prev_page = page;
@@ -986,7 +1414,8 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 	first_page->freelist = location_to_obj(first_page, 0);
 	/* Maximum number of objects we can store in this zspage */
-	first_page->objects = class->pages_per_zspage * PAGE_SIZE / class->size;
+	zs_page_objects(first_page)
+		= class->pages_per_zspage * PAGE_SIZE / class->size;
 
 	error = 0; /* Success */
 
@@ -1221,7 +1650,7 @@ static bool zspage_full(struct page *page)
 {
 	BUG_ON(!is_first_page(page));
 
-	return page->inuse == page->objects;
+	return zs_page_inuse(page) == zs_page_objects(page);
 }
 
 unsigned long zs_get_total_pages(struct zs_pool *pool)
@@ -1250,12 +1679,15 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	struct page *page;
 	unsigned long obj, obj_idx, off;
 
+#ifndef CONFIG_MIGRATION
 	unsigned int class_idx;
+#endif
 	enum fullness_group fg;
 	struct size_class *class;
 	struct mapping_area *area;
 	struct page *pages[2];
 	void *ret;
+	struct page *first_page;
 
 	BUG_ON(!handle);
 
@@ -1267,12 +1699,22 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	BUG_ON(in_interrupt());
 
 	/* From now on, migration cannot move the object */
+#ifdef CONFIG_MIGRATION
+	read_lock(&zs_tag_rwlock);
+#endif
 	pin_tag(handle);
 
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &page, &obj_idx);
-	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
+	first_page = get_first_page(page);
+#ifdef CONFIG_MIGRATION
+	fg = first_page->migration->zs_fg;
+	class = first_page->migration->zs_class;
+#else
+	get_zspage_mapping(first_page, &class_idx, &fg);
 	class = pool->size_class[class_idx];
+#endif
+
 	off = obj_idx_to_offset(page, obj_idx, class->size);
 
 	area = &get_cpu_var(zs_map_area);
@@ -1302,18 +1744,26 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 {
 	struct page *page;
 	unsigned long obj, obj_idx, off;
-
+#ifndef CONFIG_MIGRATION
 	unsigned int class_idx;
+#endif
 	enum fullness_group fg;
 	struct size_class *class;
 	struct mapping_area *area;
+	struct page *first_page;
 
 	BUG_ON(!handle);
 
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &page, &obj_idx);
-	get_zspage_mapping(get_first_page(page), &class_idx, &fg);
+	first_page = get_first_page(page);
+#ifdef CONFIG_MIGRATION
+	fg = first_page->migration->zs_fg;
+	class = first_page->migration->zs_class;
+#else
+	get_zspage_mapping(first_page, &class_idx, &fg);
 	class = pool->size_class[class_idx];
+#endif
 	off = obj_idx_to_offset(page, obj_idx, class->size);
 
 	area = this_cpu_ptr(&zs_map_area);
@@ -1330,6 +1780,9 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	}
 	put_cpu_var(zs_map_area);
 	unpin_tag(handle);
+#ifdef CONFIG_MIGRATION
+	read_unlock(&zs_tag_rwlock);
+#endif
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
 
@@ -1350,6 +1803,8 @@ static unsigned long obj_malloc(struct page *first_page,
 
 	vaddr = kmap_atomic(m_page);
 	link = (struct link_free *)vaddr + m_offset / sizeof(*link);
+BUG_ON(first_page == NULL);
+BUG_ON(link == NULL);
 	first_page->freelist = link->next;
 	if (!class->huge)
 		/* record handle in the header of allocated chunk */
@@ -1358,13 +1813,31 @@ static unsigned long obj_malloc(struct page *first_page,
 		/* record handle in first_page->private */
 		set_page_private(first_page, handle);
 	kunmap_atomic(vaddr);
-	first_page->inuse++;
+	zs_page_inuse(first_page)++;
 	zs_stat_inc(class, OBJ_USED, 1);
 
 	return obj;
 }
 
 
+#ifdef CONFIG_MIGRATION
+static void set_zspage_migration(struct size_class *class, struct page *page)
+{
+	struct page *head_extra = (struct page *)page_private(page);
+
+	BUG_ON(!is_first_page(page));
+
+	__SetPageMigration(page);
+	if (!class->huge && head_extra) {
+		struct migration *nextm;
+
+		__SetPageMigration(head_extra);
+		list_for_each_entry(nextm, &zs_page_lru(head_extra), zs_lru)
+			__SetPageMigration(nextm->zs_page);
+	}
+}
+#endif
+
 /**
  * zs_malloc - Allocate block of given size from pool.
  * @pool: pool to allocate from
@@ -1401,16 +1874,21 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 			free_handle(pool, handle);
 			return 0;
 		}
-
+#ifdef CONFIG_MIGRATION
+		first_page->migration->zs_fg = ZS_EMPTY;
+#else
 		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
+#endif
 		atomic_long_add(class->pages_per_zspage,
 					&pool->pages_allocated);
 
 		spin_lock(&class->lock);
+#ifdef CONFIG_MIGRATION
+		set_zspage_migration(class, first_page);
+#endif
 		zs_stat_inc(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
 				class->size, class->pages_per_zspage));
 	}
-
 	obj = obj_malloc(first_page, class, handle);
 	/* Now move the zspage to another fullness group, if required */
 	fix_fullness_group(class, first_page);
@@ -1446,7 +1924,7 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
 		set_page_private(first_page, 0);
 	kunmap_atomic(vaddr);
 	first_page->freelist = (void *)obj;
-	first_page->inuse--;
+	zs_page_inuse(first_page)--;
 	zs_stat_dec(class, OBJ_USED, 1);
 }
 
@@ -1454,20 +1932,30 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 {
 	struct page *first_page, *f_page;
 	unsigned long obj, f_objidx;
+#ifndef CONFIG_MIGRATION
 	int class_idx;
+#endif
 	struct size_class *class;
 	enum fullness_group fullness;
 
 	if (unlikely(!handle))
 		return;
 
+#ifdef CONFIG_MIGRATION
+	read_lock(&zs_tag_rwlock);
+#endif
 	pin_tag(handle);
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &f_page, &f_objidx);
 	first_page = get_first_page(f_page);
 
+#ifdef CONFIG_MIGRATION
+	fullness = first_page->migration->zs_fg;
+	class = first_page->migration->zs_class;
+#else
 	get_zspage_mapping(first_page, &class_idx, &fullness);
 	class = pool->size_class[class_idx];
+#endif
 
 	spin_lock(&class->lock);
 	obj_free(pool, class, obj);
@@ -1481,6 +1969,9 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	}
 	spin_unlock(&class->lock);
 	unpin_tag(handle);
+#ifdef CONFIG_MIGRATION
+	read_unlock(&zs_tag_rwlock);
+#endif
 
 	free_handle(pool, handle);
 }
@@ -1672,7 +2163,12 @@ static enum fullness_group putback_zspage(struct zs_pool *pool,
 
 	fullness = get_fullness_group(first_page);
 	insert_zspage(first_page, class, fullness);
+#ifdef CONFIG_MIGRATION
+	first_page->migration->zs_class = class;
+	first_page->migration->zs_fg = fullness;
+#else
 	set_zspage_mapping(first_page, class->index, fullness);
+#endif
 
 	if (fullness == ZS_EMPTY) {
 		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
@@ -1928,6 +2424,10 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
 			get_maxobj_per_zspage(size, pages_per_zspage) == 1)
 			class->huge = true;
 		spin_lock_init(&class->lock);
+		atomic_set(&class->count, 0);
+#ifdef CONFIG_MIGRATION
+		get_class(class);
+#endif
 		pool->size_class[i] = class;
 
 		prev_class = class;
@@ -1975,7 +2475,13 @@ void zs_destroy_pool(struct zs_pool *pool)
 					class->size, fg);
 			}
 		}
+#ifdef CONFIG_MIGRATION
+		write_lock(&zs_class_rwlock);
+		put_class(class);
+		write_unlock(&zs_class_rwlock);
+#else
 		kfree(class);
+#endif
 	}
 
 	destroy_handle_cache(pool);
@@ -1992,6 +2498,11 @@ static int __init zs_init(void)
 	if (ret)
 		goto notifier_fail;
 
+#ifdef CONFIG_MIGRATION
+	rwlock_init(&zs_class_rwlock);
+	rwlock_init(&zs_tag_rwlock);
+#endif
+
 	init_zs_size_classes();
 
 #ifdef CONFIG_ZPOOL
@@ -2003,6 +2514,17 @@ static int __init zs_init(void)
 		pr_err("zs stat initialization failed\n");
 		goto stat_fail;
 	}
+
+#ifdef CONFIG_MIGRATION
+	zs_migration_cachep = kmem_cache_create("zs_migration",
+						sizeof(struct migration),
+						0, 0, NULL);
+	if (!zs_migration_cachep) {
+		pr_err("zs migration initialization failed\n");
+		goto stat_fail;
+	}
+#endif
+
 	return 0;
 
 stat_fail:
@@ -2017,6 +2539,9 @@ notifier_fail:
 
 static void __exit zs_exit(void)
 {
+#ifdef CONFIG_MIGRATION
+	kmem_cache_destroy(zs_migration_cachep);
+#endif
 #ifdef CONFIG_ZPOOL
 	zpool_unregister_driver(&zs_zpool_driver);
 #endif
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
