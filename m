Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id DDB6A6B0255
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 07:13:44 -0500 (EST)
Received: by padhx2 with SMTP id hx2so114047860pad.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:13:44 -0800 (PST)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id tr2si16118332pac.112.2015.11.27.04.13.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 Nov 2015 04:13:41 -0800 (PST)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH 2/3] zsmalloc: make its page "PageMobile"
Date: Fri, 27 Nov 2015 20:12:30 +0800
Message-ID: <1448626351-27380-3-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1448626351-27380-1-git-send-email-zhuhui@xiaomi.com>
References: <1448626351-27380-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey
 Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

The idea of this patch is same with prev version [1].  But it use the
migration frame in [1].

[1] http://comments.gmane.org/gmane.linux.kernel.mm/140014
[2] https://lkml.org/lkml/2015/7/7/21

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/zsmalloc.c | 214 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 209 insertions(+), 5 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 57c91a5..5034aac 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -53,10 +53,13 @@
 #include <linux/vmalloc.h>
 #include <linux/hardirq.h>
 #include <linux/spinlock.h>
+#include <linux/rwlock.h>
 #include <linux/types.h>
 #include <linux/debugfs.h>
 #include <linux/zsmalloc.h>
 #include <linux/zpool.h>
+#include <linux/migrate.h>
+#include <linux/anon_inodes.h>
 
 /*
  * This must be power of 2 and greater than of equal to sizeof(link_free).
@@ -217,6 +220,8 @@ struct size_class {
 
 	/* huge object: pages_per_zspage == 1 && maxobj_per_zspage == 1 */
 	bool huge;
+
+	atomic_t count;
 };
 
 /*
@@ -281,6 +286,10 @@ struct zs_migration {
 #define ZS_MIGRATION(p) ((struct zs_migration *)((p)->freelist))
 #define ZS_META(p) ((struct zs_meta *)&(ZS_MIGRATION(p)->index))
 
+static struct inode *zs_inode;
+static DEFINE_SPINLOCK(zs_migration_lock);
+static DEFINE_RWLOCK(zs_tag_rwlock);
+
 struct mapping_area {
 #ifdef CONFIG_PGTABLE_MAPPING
 	struct vm_struct *vm; /* vm area for mapping object that span pages */
@@ -307,7 +316,7 @@ static void destroy_handle_cache(struct zs_pool *pool)
 static unsigned long alloc_handle(struct zs_pool *pool)
 {
 	return (unsigned long)kmem_cache_alloc(pool->handle_cachep,
-		pool->flags & ~__GFP_HIGHMEM);
+		pool->flags & ~(__GFP_HIGHMEM | __GFP_MOVABLE));
 }
 
 static void free_handle(struct zs_pool *pool, unsigned long handle)
@@ -914,9 +923,12 @@ static void reset_page(struct page *page)
 	clear_bit(PG_private, &page->flags);
 	clear_bit(PG_private_2, &page->flags);
 	set_page_private(page, 0);
-	free_migration(page->freelist);
-	page->freelist = NULL;
+	if (page->freelist) {
+		free_migration(page->freelist);
+		page->freelist = NULL;
+	}
 	page_mapcount_reset(page);
+	page->mapping = NULL;
 }
 
 static void free_zspage(struct page *first_page)
@@ -927,6 +939,8 @@ static void free_zspage(struct page *first_page)
 	BUG_ON(!is_first_page(first_page));
 	BUG_ON(get_inuse_obj(first_page));
 
+	spin_lock(&zs_migration_lock);
+
 	head_extra = (struct page *)page_private(first_page);
 
 	reset_page(first_page);
@@ -934,7 +948,7 @@ static void free_zspage(struct page *first_page)
 
 	/* zspage with only 1 system page */
 	if (!head_extra)
-		return;
+		goto out;
 
 	list_for_each_entry_safe(nextm, tmp, &ZS_MIGRATION(head_extra)->lru,
 				 lru) {
@@ -945,6 +959,9 @@ static void free_zspage(struct page *first_page)
 	}
 	reset_page(head_extra);
 	__free_page(head_extra);
+
+out:
+	spin_unlock(&zs_migration_lock);
 }
 
 /* Initialize a newly allocated zspage */
@@ -1018,6 +1035,7 @@ static struct page *alloc_zspage(struct size_class *class, gfp_t flags)
 		page = alloc_page(flags);
 		if (!page)
 			goto cleanup;
+		page->mapping = zs_inode->i_mapping;
 		page->freelist = alloc_migration(flags);
 		if (!page->freelist) {
 			__free_page(page);
@@ -1327,6 +1345,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 	BUG_ON(in_interrupt());
 
 	/* From now on, migration cannot move the object */
+	read_lock(&zs_tag_rwlock);
 	pin_tag(handle);
 
 	obj = handle_to_obj(handle);
@@ -1395,6 +1414,7 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	}
 	put_cpu_var(zs_map_area);
 	unpin_tag(handle);
+	read_unlock(&zs_tag_rwlock);
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
 
@@ -1431,6 +1451,16 @@ static unsigned long obj_malloc(struct page *first_page,
 }
 
 
+static void set_zspage_mobile(struct size_class *class, struct page *page)
+{
+	BUG_ON(!is_first_page(page));
+
+	while (page) {
+		__SetPageMobile(page);
+		page = get_next_page(page);
+	}
+}
+
 /**
  * zs_malloc - Allocate block of given size from pool.
  * @pool: pool to allocate from
@@ -1474,6 +1504,7 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 					&pool->pages_allocated);
 
 		spin_lock(&class->lock);
+		set_zspage_mobile(class, first_page);
 		zs_stat_inc(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
 				class->size, class->pages_per_zspage));
 	}
@@ -1526,6 +1557,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	if (unlikely(!handle))
 		return;
 
+	read_lock(&zs_tag_rwlock);
 	pin_tag(handle);
 	obj = handle_to_obj(handle);
 
@@ -1546,6 +1578,7 @@ void zs_free(struct zs_pool *pool, unsigned long handle)
 	}
 	spin_unlock(&class->lock);
 	unpin_tag(handle);
+	read_unlock(&zs_tag_rwlock);
 
 	free_handle(pool, handle);
 }
@@ -1919,6 +1952,19 @@ static int zs_register_shrinker(struct zs_pool *pool)
 	return register_shrinker(&pool->shrinker);
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
 /**
  * zs_create_pool - Creates an allocation pool to work from.
  * @flags: allocation flags used to allocate pool metadata
@@ -1995,6 +2041,8 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
 			get_maxobj_per_zspage(size, pages_per_zspage) == 1)
 			class->huge = true;
 		spin_lock_init(&class->lock);
+		atomic_set(&class->count, 0);
+		get_class(class);
 		pool->size_class[i] = class;
 
 		prev_class = class;
@@ -2042,7 +2090,9 @@ void zs_destroy_pool(struct zs_pool *pool)
 					class->size, fg);
 			}
 		}
-		kfree(class);
+		spin_lock(&zs_migration_lock);
+		put_class(class);
+		spin_unlock(&zs_migration_lock);
 	}
 
 	destroy_handle_cache(pool);
@@ -2052,6 +2102,151 @@ void zs_destroy_pool(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_destroy_pool);
 
+bool zs_isolatepage(struct page *page, isolate_mode_t mode)
+{
+	bool ret = false;
+
+	spin_lock(&zs_migration_lock);
+
+	if (!get_page_unless_zero(page))
+		/* The zspage is released.  */
+		goto out;
+	if (page_count(page) != 2)
+		/* The page is isolated by others or just freed.  */
+		goto put_out;
+	if (page->freelist == NULL)
+		goto put_out;
+
+	ret = true;
+out:
+	spin_unlock(&zs_migration_lock);
+	return ret;
+
+put_out:
+	put_page(page);
+	goto out;
+}
+
+void zs_putbackpage(struct page *page)
+{
+	put_page(page);
+}
+
+int
+zs_migratepage(struct address_space *mapping,
+	       struct page *newpage, struct page *page,
+	       enum migrate_mode mode)
+{
+	int ret = -EAGAIN;
+	struct size_class *class;
+	struct page *first_page;
+
+	/* Get class.  */
+	spin_lock(&zs_migration_lock);
+	if (page->freelist == NULL || page_count(page) <= 1) {
+		spin_unlock(&zs_migration_lock);
+		return ret;
+	}
+	class = ZS_MIGRATION(page)->class;
+	get_class(class);
+	spin_unlock(&zs_migration_lock);
+
+	write_lock(&zs_tag_rwlock);
+	spin_lock(&class->lock);
+
+	if (page->freelist == NULL || page_count(page) <= 1)
+		goto out;	/* The zspage is released.  */
+
+	first_page = get_first_page(page);
+
+	INIT_LIST_HEAD(&ZS_MIGRATION(newpage)->lru);
+	newpage->mapping = zs_inode->i_mapping;
+	if (page == first_page) {	/* first page */
+		struct page **head;
+
+		SetPagePrivate(newpage);
+
+		if (class->huge) {
+			unsigned long handle = page_private(page);
+
+			if (handle != 0) {
+				void *addr, *newaddr;
+				unsigned long obj = obj_idx_to_obj(newpage, 0);
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
+				set_free_obj_idx(first_page, 0);
+			set_page_private(newpage, handle);
+		} else {
+			struct page *tmp_page = get_next_page(page);
+
+			while (tmp_page) {
+				tmp_page->first_page = newpage;
+				tmp_page = get_next_page(tmp_page);
+			}
+			set_page_private(newpage, page_private(page));
+		}
+
+		head = &class->fullness_list[ZS_META(first_page)->fullness];
+		BUG_ON(!*head);
+		if (*head == page)
+			*head = newpage;
+	} else
+		newpage->first_page = page->first_page;
+
+	if (is_last_page(page))	/* last page */
+		SetPagePrivate2(newpage);
+
+	if (!class->huge) {
+		void *addr, *newaddr;
+
+		addr = kmap_atomic(page);
+		newaddr = kmap_atomic(newpage);
+		copy_page(newaddr, addr);
+		kunmap_atomic(newaddr);
+		kunmap_atomic(addr);
+	}
+
+	/* Add newpage to zspage.  */
+	if (first_page == page)
+		first_page = newpage;
+	else {
+		if ((struct page *)page_private(first_page) == page)
+			set_page_private(first_page, (unsigned long)newpage);
+	}
+	newpage->freelist = page->freelist;
+	ZS_MIGRATION(newpage)->page = newpage;
+
+	get_page(newpage);
+	__SetPageMobile(newpage);
+
+	spin_lock(&zs_migration_lock);
+	page->freelist = NULL;
+	reset_page(page);
+	put_page(page);
+	spin_unlock(&zs_migration_lock);
+
+	ret = MIGRATEPAGE_SUCCESS;
+out:
+	spin_unlock(&class->lock);
+	write_unlock(&zs_tag_rwlock);
+	put_class(class);
+	return ret;
+}
+
+const struct address_space_operations zs_mobile_aops = {
+	.migratepage = zs_migratepage,
+	.isolatepage = zs_isolatepage,
+	.putbackpage = zs_putbackpage,
+};
+
 static int __init zs_init(void)
 {
 	int ret = zs_register_cpu_notifier();
@@ -2082,6 +2277,13 @@ static int __init zs_init(void)
 		goto stat_fail;
 	}
 
+	zs_inode = anon_inode_new();
+	if (IS_ERR(zs_inode)) {
+		pr_err("zs inode initialization failed\n");
+		ret = PTR_ERR(zs_inode);
+	}
+	zs_inode->i_mapping->a_ops = &zs_mobile_aops;
+
 	return 0;
 
 stat_fail:
@@ -2096,6 +2298,8 @@ notifier_fail:
 
 static void __exit zs_exit(void)
 {
+	iput(zs_inode);
+
 	kmem_cache_destroy(zs_migration_cachep);
 
 #ifdef CONFIG_ZPOOL
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
