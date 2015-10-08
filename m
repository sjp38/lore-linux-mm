Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE1D6B0253
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 02:36:10 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so45231500pab.3
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 23:36:10 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id qp7si63996015pbc.93.2015.10.07.23.36.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Oct 2015 23:36:09 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH 2/3] zsmalloc: mark its page "PG_movable"
Date: Thu, 8 Oct 2015 14:35:51 +0800
Message-ID: <1444286152-30175-3-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1444286152-30175-1-git-send-email-zhuhui@xiaomi.com>
References: <1444286152-30175-1-git-send-email-zhuhui@xiaomi.com>
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

This patch mark zsmalloc's page "PG_movable" and introduce the function
for the interfaces zs_isolatepage, zs_isolatepage and zs_migratepage.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 include/linux/mm_types.h |   5 +
 mm/zsmalloc.c            | 416 ++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 402 insertions(+), 19 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 132afb0..3975249 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -202,6 +202,11 @@ struct page {
 	void (*put)(struct page *page);
 	int (*migrate)(struct page *page, struct page *newpage, int force,
 		       enum migrate_mode mode);
+
+#ifdef CONFIG_ZSMALLOC
+	void *zs_class;
+	struct list_head zs_lru;
+#endif
 }
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index f135b1b..ded3134 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -21,8 +21,8 @@
  *		starting in this page. For the first page, this is
  *		always 0, so we use this field (aka freelist) to point
  *		to the first free object in zspage.
- *	page->lru: links together all component pages (except the first page)
- *		of a zspage
+ *	page->zs_lru: links together all component pages (except the first
+ *		page) of a zspage
  *
  *	For _first_ page only:
  *
@@ -35,7 +35,7 @@
  *		metadata.
  *	page->objects: maximum number of objects we can store in this
  *		zspage (class->zspage_order * PAGE_SIZE / class->size)
- *	page->lru: links together first pages of various zspages.
+ *	page->zs_lru: links together first pages of various zspages.
  *		Basically forming list of zspages in a fullness group.
  *	page->mapping: class index and fullness group of the zspage
  *
@@ -64,6 +64,9 @@
 #include <linux/debugfs.h>
 #include <linux/zsmalloc.h>
 #include <linux/zpool.h>
+#include <linux/migrate.h>
+#include <linux/rwlock.h>
+#include <linux/mm.h>
 
 /*
  * This must be power of 2 and greater than of equal to sizeof(link_free).
@@ -214,6 +217,8 @@ struct size_class {
 
 	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
 	bool huge;
+
+	atomic_t count;
 };
 
 /*
@@ -279,6 +284,9 @@ struct mapping_area {
 	bool huge;
 };
 
+static rwlock_t zs_class_rwlock;
+static rwlock_t zs_tag_rwlock;
+
 static int create_handle_cache(struct zs_pool *pool)
 {
 	pool->handle_cachep = kmem_cache_create("zs_handle", ZS_HANDLE_SIZE,
@@ -656,7 +664,7 @@ static void insert_zspage(struct page *page, struct size_class *class,
 	 * We want to see more ZS_FULL pages and less almost
 	 * empty/full. Put pages with higher ->inuse first.
 	 */
-	list_add_tail(&page->lru, &(*head)->lru);
+	list_add_tail(&page->zs_lru, &(*head)->zs_lru);
 	if (page->inuse >= (*head)->inuse)
 		*head = page;
 }
@@ -677,17 +685,38 @@ static void remove_zspage(struct page *page, struct size_class *class,
 
 	head = &class->fullness_list[fullness];
 	BUG_ON(!*head);
-	if (list_empty(&(*head)->lru))
+	if (list_empty(&(*head)->zs_lru))
 		*head = NULL;
 	else if (*head == page)
-		*head = (struct page *)list_entry((*head)->lru.next,
-					struct page, lru);
+		*head = (struct page *)list_entry((*head)->zs_lru.next,
+					struct page, zs_lru);
 
-	list_del_init(&page->lru);
+	list_del_init(&page->zs_lru);
 	zs_stat_dec(class, fullness == ZS_ALMOST_EMPTY ?
 			CLASS_ALMOST_EMPTY : CLASS_ALMOST_FULL, 1);
 }
 
+static void replace_zspage_first_page(struct size_class *class,
+				      struct page *page,
+				      struct page *newpage)
+{
+	struct page **head;
+	int class_idx;
+	enum fullness_group fg;
+
+	BUG_ON(!is_first_page(page));
+	BUG_ON(!is_first_page(newpage));
+
+	get_zspage_mapping(page, &class_idx, &fg);
+
+	head = &class->fullness_list[fg];
+	BUG_ON(!*head);
+	if (*head == page)
+		*head = newpage;
+
+	list_replace(&page->zs_lru, &newpage->zs_lru);
+}
+
 /*
  * Each size class maintains zspages in different fullness groups depending
  * on the number of live objects they contain. When allocating or freeing
@@ -776,7 +805,7 @@ static struct page *get_next_page(struct page *page)
 	else if (is_first_page(page))
 		next = (struct page *)page_private(page);
 	else
-		next = list_entry(page->lru.next, struct page, lru);
+		next = list_entry(page->zs_lru.next, struct page, zs_lru);
 
 	return next;
 }
@@ -809,9 +838,14 @@ static void *location_to_obj(struct page *page, unsigned long obj_idx)
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
@@ -859,6 +893,8 @@ static void unpin_tag(unsigned long handle)
 	clear_bit_unlock(HANDLE_PIN_BIT, ptr);
 }
 
+/* This function must be called when hold class->lock.  */
+
 static void reset_page(struct page *page)
 {
 	clear_bit(PG_private, &page->flags);
@@ -885,8 +921,8 @@ static void free_zspage(struct page *first_page)
 	if (!head_extra)
 		return;
 
-	list_for_each_entry_safe(nextp, tmp, &head_extra->lru, lru) {
-		list_del(&nextp->lru);
+	list_for_each_entry_safe(nextp, tmp, &head_extra->zs_lru, zs_lru) {
+		list_del(&nextp->zs_lru);
 		reset_page(nextp);
 		__free_page(nextp);
 	}
@@ -937,6 +973,314 @@ static void init_zspage(struct page *first_page, struct size_class *class)
 	}
 }
 
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
+	struct size_class *class;
+
+	read_lock(&zs_class_rwlock);
+	class = page->zs_class;
+	/* Make suse the class is get before the page is released by
+	 * free_zspage.
+	 * Then the class is must available because it must be released
+	 * after page is released.
+	 */
+	smp_mb();
+	if (!get_page_unless_zero(page))
+		goto out;
+	if (page_count(page) != 2) {
+		put_page(page);
+		goto out;
+	}
+
+	BUG_ON(class == NULL);
+	get_class(class);
+	spin_lock(&class->lock);
+	if (page->mapping != NULL)
+		ret = 0;
+	spin_unlock(&class->lock);
+
+out:
+	read_unlock(&zs_class_rwlock);
+	return ret;
+}
+
+static void zs_putpage(struct page *page)
+{
+	put_class(page->zs_class);
+	put_page(page);
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
+/* If cur_page is newpage, it will be set to page.
+ * Set page and newpage to NULL to close this function.
+ */
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
+		if (cur_page == newpage)
+			cur_page = page;
+
+		zspage_loop_1(class, cur_page, zls, callback);
+
+		if (cur_page == page)
+			cur_page = newpage;
+
+		cur_page = get_next_page(cur_page);
+	}
+
+	if (zls)
+		kunmap_atomic(zls->newaddr);
+}
+
+int zs_migratepage(struct page *page, struct page *newpage, int force,
+		   enum migrate_mode mode)
+{
+	struct size_class *class = page->zs_class;
+	struct page *first_page;
+	struct page *tmp_page;
+	unsigned long tmp_idx;
+
+	write_lock(&zs_tag_rwlock);
+
+	BUG_ON(class == NULL);
+
+	spin_lock(&class->lock);
+	BUG_ON(page->mapping == NULL);
+
+	first_page = get_first_page(page);
+
+	newpage->zs_class = page->zs_class;
+	INIT_LIST_HEAD(&newpage->lru);
+	INIT_LIST_HEAD(&newpage->zs_lru);
+	page->isolate = zs_isolatepage;
+	page->put = zs_putpage;
+	page->migrate = zs_migratepage;
+
+	if (page == first_page) {	/* first page */
+		newpage->inuse = page->inuse;
+		newpage->freelist = page->freelist;
+		newpage->objects = page->objects;
+		newpage->mapping = page->mapping;
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
+				first_page->freelist = (void *)obj;
+			set_page_private(newpage, handle);
+		} else {
+			struct page *head_extra
+				= (struct page *)page_private(page);
+
+			if (head_extra) {
+				struct page *nextp;
+
+				head_extra->first_page = newpage;
+				list_for_each_entry(nextp, &head_extra->zs_lru,
+						    zs_lru)
+					nextp->first_page = newpage;
+			}
+			set_page_private(newpage, (unsigned long)head_extra);
+		}
+		replace_zspage_first_page(class, page, newpage);
+		first_page = newpage;
+	} else {
+		void *addr, *newaddr;
+
+		newpage->first_page = page->first_page;
+		newpage->index = page->index;
+
+		if ((struct page *)page_private(first_page) == page)
+			set_page_private(first_page, (unsigned long)newpage);
+		list_replace(&page->zs_lru, &newpage->zs_lru);
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
+	SetPageMovable(newpage);
+
+	reset_page(page);
+	put_page(page);
+
+	spin_unlock(&class->lock);
+	write_unlock(&zs_tag_rwlock);
+	return MIGRATEPAGE_SUCCESS;
+}
+
 /*
  * Allocate a zspage for the given size class
  */
@@ -948,11 +1292,11 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	/*
 	 * Allocate individual pages and link them together as:
 	 * 1. first page->private = first sub-page
-	 * 2. all sub-pages are linked together using page->lru
+	 * 2. all sub-pages are linked together using page->zs_lru
 	 * 3. each sub-page is linked to the first page using page->first_page
 	 *
 	 * For each size class, First/Head pages are linked together using
-	 * page->lru. Also, we set PG_private to identify the first page
+	 * page->zs_lru. Also, we set PG_private to identify the first page
 	 * (i.e. no other sub-page has this flag set) and PG_private_2 to
 	 * identify the last page.
 	 */
@@ -965,6 +1309,11 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 			goto cleanup;
 
 		INIT_LIST_HEAD(&page->lru);
+		INIT_LIST_HEAD(&page->zs_lru);
+		page->isolate = zs_isolatepage;
+		page->put = zs_putpage;
+		page->migrate = zs_migratepage;
+		page->zs_class = class;
 		if (i == 0) {	/* first page */
 			SetPagePrivate(page);
 			set_page_private(page, 0);
@@ -973,10 +1322,12 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 		}
 		if (i == 1)
 			set_page_private(first_page, (unsigned long)page);
-		if (i >= 1)
+		if (i >= 1) {
 			page->first_page = first_page;
+			page->mapping = (void *)1;
+		}
 		if (i >= 2)
-			list_add(&page->lru, &prev_page->lru);
+			list_add(&page->zs_lru, &prev_page->zs_lru);
 		if (i == class->pages_per_zspage - 1)	/* last page */
 			SetPagePrivate2(page);
 		prev_page = page;
@@ -1267,6 +1618,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	BUG_ON(in_interrupt());
 
 	/* From now on, migration cannot move the object */
+	read_lock(&zs_tag_rwlock);
 	pin_tag(handle);
 
 	obj = handle_to_obj(handle);
@@ -1330,6 +1682,7 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	}
 	put_cpu_var(zs_map_area);
 	unpin_tag(handle);
+	read_unlock(&zs_tag_rwlock);
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
 
@@ -1365,6 +1718,21 @@ static unsigned long obj_malloc(struct page *first_page,
 }
 
 
+static void set_zspage_movable(struct size_class *class, struct page *page)
+{
+	struct page *head_extra = (struct page *)page_private(page);
+	struct page *nextp;
+
+	BUG_ON(!is_first_page(page));
+
+	SetPageMovable(page);
+	if (!class->huge && head_extra) {
+		SetPageMovable(head_extra);
+		list_for_each_entry(nextp, &head_extra->zs_lru, zs_lru)
+			SetPageMovable(nextp);
+	}
+}
+
 /**
  * zs_malloc - Allocate block of given size from pool.
  * @pool: pool to allocate from
@@ -1407,6 +1775,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 					&pool->pages_allocated);
 
 		spin_lock(&class->lock);
+		set_zspage_movable(class, first_page);
 		zs_stat_inc(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
 				class->size, class->pages_per_zspage));
 	}
@@ -1464,6 +1833,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	if (unlikely(!handle))
 		return;
 
+	read_lock(&zs_tag_rwlock);
 	pin_tag(handle);
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &f_page, &f_objidx);
@@ -1484,6 +1854,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	}
 	spin_unlock(&class->lock);
 	unpin_tag(handle);
+	read_unlock(&zs_tag_rwlock);
 
 	free_handle(pool, handle);
 }
@@ -1931,6 +2302,8 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
 			get_maxobj_per_zspage(size, pages_per_zspage) == 1)
 			class->huge = true;
 		spin_lock_init(&class->lock);
+		atomic_set(&class->count, 0);
+		get_class(class);
 		pool->size_class[i] = class;
 
 		prev_class = class;
@@ -1978,7 +2351,9 @@ void zs_destroy_pool(struct zs_pool *pool)
 					class->size, fg);
 			}
 		}
-		kfree(class);
+		write_lock(&zs_class_rwlock);
+		put_class(class);
+		write_unlock(&zs_class_rwlock);
 	}
 
 	destroy_handle_cache(pool);
@@ -1995,6 +2370,9 @@ static int __init zs_init(void)
 	if (ret)
 		goto notifier_fail;
 
+	rwlock_init(&zs_class_rwlock);
+	rwlock_init(&zs_tag_rwlock);
+
 	init_zs_size_classes();
 
 #ifdef CONFIG_ZPOOL
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
