Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id E45CD6B026D
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:11:05 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id 4so34914318pfd.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:11:05 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id sk8si4410299pac.44.2016.03.30.00.10.41
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 00:10:42 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 13/16] zsmalloc: migrate head page of zspage
Date: Wed, 30 Mar 2016 16:12:12 +0900
Message-Id: <1459321935-3655-14-git-send-email-minchan@kernel.org>
In-Reply-To: <1459321935-3655-1-git-send-email-minchan@kernel.org>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

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
 include/uapi/linux/magic.h |   1 +
 mm/zsmalloc.c              | 332 +++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 318 insertions(+), 15 deletions(-)

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
index ac8ca7b10720..f6c9138c3be0 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -56,6 +56,8 @@
 #include <linux/debugfs.h>
 #include <linux/zsmalloc.h>
 #include <linux/zpool.h>
+#include <linux/mount.h>
+#include <linux/migrate.h>
 
 /*
  * This must be power of 2 and greater than of equal to sizeof(link_free).
@@ -182,6 +184,8 @@ struct zs_size_stat {
 static struct dentry *zs_stat_root;
 #endif
 
+static struct vfsmount *zsmalloc_mnt;
+
 /*
  * number of size_classes
  */
@@ -263,6 +267,7 @@ struct zs_pool {
 #ifdef CONFIG_ZSMALLOC_STAT
 	struct dentry *stat_dentry;
 #endif
+	struct inode *inode;
 };
 
 struct zs_meta {
@@ -412,6 +417,29 @@ static int is_last_page(struct page *page)
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
@@ -783,8 +811,11 @@ static enum fullness_group fix_fullness_group(struct size_class *class,
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
@@ -950,12 +981,31 @@ static void unpin_tag(unsigned long handle)
 
 static void reset_page(struct page *page)
 {
+	if (!PageIsolated(page))
+		__ClearPageMovable(page);
+	ClearPageIsolated(page);
 	clear_bit(PG_private, &page->flags);
 	clear_bit(PG_private_2, &page->flags);
 	set_page_private(page, 0);
 	page->freelist = NULL;
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
@@ -963,26 +1013,31 @@ static void free_zspage(struct zs_pool *pool, struct page *first_page)
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
-		__free_page(nextp);
+		unlock_page(nextp);
+		put_page(nextp);
 	}
 	reset_page(head_extra);
-	__free_page(head_extra);
+	unlock_page(head_extra);
+	put_page(head_extra);
+out:
+	reset_page(first_page);
+	unlock_page(first_page);
+	put_page(first_page);
 }
 
 /* Initialize a newly allocated zspage */
-static void init_zspage(struct size_class *class, struct page *first_page)
+static void init_zspage(struct size_class *class, struct page *first_page,
+			struct address_space *mapping)
 {
 	int freeobj = 1;
 	unsigned long off = 0;
@@ -991,6 +1046,9 @@ static void init_zspage(struct size_class *class, struct page *first_page)
 	first_page->freelist = NULL;
 	INIT_LIST_HEAD(&first_page->lru);
 	set_zspage_inuse(first_page, 0);
+	BUG_ON(!trylock_page(first_page));
+	__SetPageMovable(first_page, mapping);
+	unlock_page(first_page);
 
 	while (page) {
 		struct page *next_page;
@@ -1065,10 +1123,45 @@ static void create_page_chain(struct page *pages[], int nr_pages)
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
+	__SetPageMovable(newpage, oldpage->mapping);
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
 	struct page *first_page = NULL;
@@ -1088,7 +1181,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 	for (i = 0; i < class->pages_per_zspage; i++) {
 		struct page *page;
 
-		page = alloc_page(flags);
+		page = alloc_page(pool->flags);
 		if (!page) {
 			while (--i >= 0)
 				__free_page(pages[i]);
@@ -1100,7 +1193,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 
 	create_page_chain(pages, class->pages_per_zspage);
 	first_page = pages[0];
-	init_zspage(class, first_page);
+	init_zspage(class, first_page, pool->inode->i_mapping);
 
 	return first_page;
 }
@@ -1499,7 +1592,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 
 	if (!first_page) {
 		spin_unlock(&class->lock);
-		first_page = alloc_zspage(class, pool->flags);
+		first_page = alloc_zspage(pool, class);
 		if (unlikely(!first_page)) {
 			free_handle(pool, handle);
 			return 0;
@@ -1559,6 +1652,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	if (unlikely(!handle))
 		return;
 
+	/* Once handle is pinned, page|object migration cannot work */
 	pin_tag(handle);
 	obj = handle_to_obj(handle);
 	obj_to_location(obj, &f_page, &f_objidx);
@@ -1714,6 +1808,9 @@ static enum fullness_group putback_zspage(struct size_class *class,
 {
 	enum fullness_group fullness;
 
+	VM_BUG_ON_PAGE(!list_empty(&first_page->lru), first_page);
+	VM_BUG_ON_PAGE(ZsPageIsolate(first_page), first_page);
+
 	fullness = get_fullness_group(class, first_page);
 	insert_zspage(class, fullness, first_page);
 	set_zspage_mapping(first_page, class->index, fullness);
@@ -2059,6 +2156,173 @@ static int zs_register_shrinker(struct zs_pool *pool)
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
+	ClearPageIsolated(page);
+	reset_page(page);
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
@@ -2145,6 +2409,15 @@ struct zs_pool *zs_create_pool(const char *name, gfp_t flags)
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
@@ -2164,6 +2437,8 @@ void zs_destroy_pool(struct zs_pool *pool)
 	int i;
 
 	zs_unregister_shrinker(pool);
+	if (pool->inode)
+		iput(pool->inode);
 	zs_pool_stat_destroy(pool);
 
 	for (i = 0; i < zs_size_classes; i++) {
@@ -2192,10 +2467,33 @@ void zs_destroy_pool(struct zs_pool *pool)
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
+
+	zsmalloc_mnt = kern_mount(&zsmalloc_fs);
+	if (IS_ERR(zsmalloc_mnt)) {
+		ret = PTR_ERR(zsmalloc_mnt);
+		goto out;
+	}
 
+	ret = zs_register_cpu_notifier();
 	if (ret)
 		goto notifier_fail;
 
@@ -2218,6 +2516,7 @@ static int __init zs_init(void)
 		pr_err("zs stat initialization failed\n");
 		goto stat_fail;
 	}
+
 	return 0;
 
 stat_fail:
@@ -2226,7 +2525,8 @@ static int __init zs_init(void)
 #endif
 notifier_fail:
 	zs_unregister_cpu_notifier();
-
+	kern_unmount(zsmalloc_mnt);
+out:
 	return ret;
 }
 
@@ -2237,6 +2537,8 @@ static void __exit zs_exit(void)
 #endif
 	zs_unregister_cpu_notifier();
 
+	kern_unmount(zsmalloc_mnt);
+
 	zs_stat_exit();
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
