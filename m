Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id BB1756B0261
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:10:47 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id 4so34908349pfd.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:10:47 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id zo2si4325358pac.221.2016.03.30.00.10.37
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 00:10:38 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 04/16] mm/balloon: use general movable page feature into balloon
Date: Wed, 30 Mar 2016 16:12:03 +0900
Message-Id: <1459321935-3655-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1459321935-3655-1-git-send-email-minchan@kernel.org>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>, Gioh Kim <gurugio@hanmail.net>

Now, VM has a feature to migrate non-lru movable pages so
balloon doesn't need custom migration hooks in migrate.c
and compact.c. Instead, this patch implements page->mapping
->{isolate|migrate|putback} functions.

With that, we could remove hooks for ballooning in general
migration functions and make balloon compaction simple.

Cc: virtualization@lists.linux-foundation.org
Cc: Rafael Aquini <aquini@redhat.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Signed-off-by: Gioh Kim <gurugio@hanmail.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/virtio/virtio_balloon.c    |  53 ++++++++++++++++---
 include/linux/balloon_compaction.h |  49 ++++--------------
 include/linux/page-flags.h         |  56 +++++++++++---------
 include/uapi/linux/magic.h         |   1 +
 mm/balloon_compaction.c            | 101 ++++++++-----------------------------
 mm/compaction.c                    |   7 ---
 mm/migrate.c                       |  22 ++------
 mm/vmscan.c                        |   2 +-
 8 files changed, 119 insertions(+), 172 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 7b6d74f0c72f..0c16192d2684 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -30,6 +30,7 @@
 #include <linux/oom.h>
 #include <linux/wait.h>
 #include <linux/mm.h>
+#include <linux/mount.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -45,6 +46,10 @@ static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
 module_param(oom_pages, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
 
+#ifdef CONFIG_BALLOON_COMPACTION
+static struct vfsmount *balloon_mnt;
+#endif
+
 struct virtio_balloon {
 	struct virtio_device *vdev;
 	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
@@ -482,10 +487,29 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 
 	mutex_unlock(&vb->balloon_lock);
 
+	ClearPageIsolated(page);
 	put_page(page); /* balloon reference */
 
 	return MIGRATEPAGE_SUCCESS;
 }
+
+static struct dentry *balloon_mount(struct file_system_type *fs_type,
+		int flags, const char *dev_name, void *data)
+{
+	static const struct dentry_operations ops = {
+		.d_dname = simple_dname,
+	};
+
+	return mount_pseudo(fs_type, "balloon-kvm:", NULL, &ops,
+				BALLOON_KVM_MAGIC);
+}
+
+static struct file_system_type balloon_fs = {
+	.name           = "balloon-kvm",
+	.mount          = balloon_mount,
+	.kill_sb        = kill_anon_super,
+};
+
 #endif /* CONFIG_BALLOON_COMPACTION */
 
 static int virtballoon_probe(struct virtio_device *vdev)
@@ -515,10 +539,6 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	vb->vdev = vdev;
 
 	balloon_devinfo_init(&vb->vb_dev_info);
-#ifdef CONFIG_BALLOON_COMPACTION
-	vb->vb_dev_info.migratepage = virtballoon_migratepage;
-#endif
-
 	err = init_vqs(vb);
 	if (err)
 		goto out_free_vb;
@@ -527,13 +547,32 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
 	err = register_oom_notifier(&vb->nb);
 	if (err < 0)
-		goto out_oom_notify;
+		goto out_del_vqs;
+
+#ifdef CONFIG_BALLOON_COMPACTION
+	balloon_mnt = kern_mount(&balloon_fs);
+	if (IS_ERR(balloon_mnt)) {
+		err = PTR_ERR(balloon_mnt);
+		unregister_oom_notifier(&vb->nb);
+		goto out_del_vqs;
+	}
 
+	vb->vb_dev_info.migratepage = virtballoon_migratepage;
+	vb->vb_dev_info.inode = alloc_anon_inode(balloon_mnt->mnt_sb);
+	if (IS_ERR(vb->vb_dev_info.inode)) {
+		err = PTR_ERR(vb->vb_dev_info.inode);
+		kern_unmount(balloon_mnt);
+		unregister_oom_notifier(&vb->nb);
+		vb->vb_dev_info.inode = NULL;
+		goto out_del_vqs;
+	}
+	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
+#endif
 	virtio_device_ready(vdev);
 
 	return 0;
 
-out_oom_notify:
+out_del_vqs:
 	vdev->config->del_vqs(vdev);
 out_free_vb:
 	kfree(vb);
@@ -567,6 +606,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	cancel_work_sync(&vb->update_balloon_stats_work);
 
 	remove_common(vb);
+	if (vb->vb_dev_info.inode)
+		iput(vb->vb_dev_info.inode);
 	kfree(vb);
 }
 
diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index 9b0a15d06a4f..4c693bf3abdf 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -48,6 +48,7 @@
 #include <linux/migrate.h>
 #include <linux/gfp.h>
 #include <linux/err.h>
+#include <linux/fs.h>
 
 /*
  * Balloon device information descriptor.
@@ -62,6 +63,7 @@ struct balloon_dev_info {
 	struct list_head pages;		/* Pages enqueued & handled to Host */
 	int (*migratepage)(struct balloon_dev_info *, struct page *newpage,
 			struct page *page, enum migrate_mode mode);
+	struct inode *inode;
 };
 
 extern struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info);
@@ -73,45 +75,19 @@ static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
 	spin_lock_init(&balloon->pages_lock);
 	INIT_LIST_HEAD(&balloon->pages);
 	balloon->migratepage = NULL;
+	balloon->inode = NULL;
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
-extern bool balloon_page_isolate(struct page *page);
+extern const struct address_space_operations balloon_aops;
+extern bool balloon_page_isolate(struct page *page,
+				isolate_mode_t mode);
 extern void balloon_page_putback(struct page *page);
-extern int balloon_page_migrate(struct page *newpage,
+extern int balloon_page_migrate(struct address_space *mapping,
+				struct page *newpage,
 				struct page *page, enum migrate_mode mode);
 
 /*
- * __is_movable_balloon_page - helper to perform @page PageBalloon tests
- */
-static inline bool __is_movable_balloon_page(struct page *page)
-{
-	return PageBalloon(page);
-}
-
-/*
- * balloon_page_movable - test PageBalloon to identify balloon pages
- *			  and PagePrivate to check that the page is not
- *			  isolated and can be moved by compaction/migration.
- *
- * As we might return false positives in the case of a balloon page being just
- * released under us, this need to be re-tested later, under the page lock.
- */
-static inline bool balloon_page_movable(struct page *page)
-{
-	return PageBalloon(page) && PagePrivate(page);
-}
-
-/*
- * isolated_balloon_page - identify an isolated balloon page on private
- *			   compaction/migration page lists.
- */
-static inline bool isolated_balloon_page(struct page *page)
-{
-	return PageBalloon(page);
-}
-
-/*
  * balloon_page_insert - insert a page into the balloon's page list and make
  *			 the page->private assignment accordingly.
  * @balloon : pointer to balloon device
@@ -123,8 +99,7 @@ static inline bool isolated_balloon_page(struct page *page)
 static inline void balloon_page_insert(struct balloon_dev_info *balloon,
 				       struct page *page)
 {
-	__SetPageBalloon(page);
-	SetPagePrivate(page);
+	__SetPageBalloon(page, balloon->inode->i_mapping);
 	set_page_private(page, (unsigned long)balloon);
 	list_add(&page->lru, &balloon->pages);
 }
@@ -141,10 +116,8 @@ static inline void balloon_page_delete(struct page *page)
 {
 	__ClearPageBalloon(page);
 	set_page_private(page, 0);
-	if (PagePrivate(page)) {
-		ClearPagePrivate(page);
+	if (!PageIsolated(page))
 		list_del(&page->lru);
-	}
 }
 
 /*
@@ -166,7 +139,7 @@ static inline gfp_t balloon_mapping_gfp_mask(void)
 static inline void balloon_page_insert(struct balloon_dev_info *balloon,
 				       struct page *page)
 {
-	__SetPageBalloon(page);
+	__SetPageBalloon(page, NULL);
 	list_add(&page->lru, &balloon->pages);
 }
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 77ebf8fdbc6e..603c47752126 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -599,32 +599,13 @@ static inline void __ClearPageBuddy(struct page *page)
 
 extern bool is_free_buddy_page(struct page *page);
 
-#define PAGE_BALLOON_MAPCOUNT_VALUE (-256)
-
-static inline int PageBalloon(struct page *page)
-{
-	return atomic_read(&page->_mapcount) == PAGE_BALLOON_MAPCOUNT_VALUE;
-}
-
-static inline void __SetPageBalloon(struct page *page)
-{
-	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
-	atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
-}
-
-static inline void __ClearPageBalloon(struct page *page)
-{
-	VM_BUG_ON_PAGE(!PageBalloon(page), page);
-	atomic_set(&page->_mapcount, -1);
-}
-
-#define PAGE_MOVABLE_MAPCOUNT_VALUE (-255)
+#define PAGE_MOVABLE_MAPCOUNT_VALUE (-256)
+#define PAGE_BALLOON_MAPCOUNT_VALUE PAGE_MOVABLE_MAPCOUNT_VALUE
 
 static inline int PageMovable(struct page *page)
 {
-	return ((test_bit(PG_movable, &(page)->flags) &&
-		atomic_read(&page->_mapcount) == PAGE_MOVABLE_MAPCOUNT_VALUE)
-		|| PageBalloon(page));
+	return (test_bit(PG_movable, &(page)->flags) &&
+		atomic_read(&page->_mapcount) == PAGE_MOVABLE_MAPCOUNT_VALUE);
 }
 
 /* Caller should hold a PG_lock */
@@ -645,6 +626,35 @@ static inline void __ClearPageMovable(struct page *page)
 
 PAGEFLAG(Isolated, isolated, PF_ANY);
 
+static inline int PageBalloon(struct page *page)
+{
+	return atomic_read(&page->_mapcount) == PAGE_BALLOON_MAPCOUNT_VALUE
+		&& PagePrivate2(page);
+}
+
+static inline void __SetPageBalloon(struct page *page,
+				struct address_space *mapping)
+{
+	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);
+#ifdef CONFIG_BALLOON_COMPACTION
+	__SetPageMovable(page, mapping);
+#else
+	atomic_set(&page->_mapcount, PAGE_BALLOON_MAPCOUNT_VALUE);
+#endif
+	SetPagePrivate2(page);
+}
+
+static inline void __ClearPageBalloon(struct page *page)
+{
+	VM_BUG_ON_PAGE(!PageBalloon(page), page);
+#ifdef CONFIG_BALLOON_COMPACTION
+	__ClearPageMovable(page);
+#else
+	atomic_set(&page->_mapcount, -1);
+#endif
+	ClearPagePrivate2(page);
+}
+
 /*
  * If network-based swap is enabled, sl*b must keep track of whether pages
  * were allocated from pfmemalloc reserves.
diff --git a/include/uapi/linux/magic.h b/include/uapi/linux/magic.h
index 0de181ad73d5..e1fbe72c39c0 100644
--- a/include/uapi/linux/magic.h
+++ b/include/uapi/linux/magic.h
@@ -78,5 +78,6 @@
 #define BTRFS_TEST_MAGIC	0x73727279
 #define NSFS_MAGIC		0x6e736673
 #define BPF_FS_MAGIC		0xcafe4a11
+#define BALLOON_KVM_MAGIC	0x13661366
 
 #endif /* __LINUX_MAGIC_H__ */
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 57b3e9bd6bc5..1fbc7fb387bb 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -70,7 +70,7 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
 		 */
 		if (trylock_page(page)) {
 #ifdef CONFIG_BALLOON_COMPACTION
-			if (!PagePrivate(page)) {
+			if (PageIsolated(page)) {
 				/* raced with isolation */
 				unlock_page(page);
 				continue;
@@ -106,110 +106,53 @@ EXPORT_SYMBOL_GPL(balloon_page_dequeue);
 
 #ifdef CONFIG_BALLOON_COMPACTION
 
-static inline void __isolate_balloon_page(struct page *page)
+/* __isolate_lru_page() counterpart for a ballooned page */
+bool balloon_page_isolate(struct page *page, isolate_mode_t mode)
 {
 	struct balloon_dev_info *b_dev_info = balloon_page_device(page);
 	unsigned long flags;
 
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
-	ClearPagePrivate(page);
 	list_del(&page->lru);
 	b_dev_info->isolated_pages++;
 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
+	SetPageIsolated(page);
+
+	return true;
 }
 
-static inline void __putback_balloon_page(struct page *page)
+/* putback_lru_page() counterpart for a ballooned page */
+void balloon_page_putback(struct page *page)
 {
 	struct balloon_dev_info *b_dev_info = balloon_page_device(page);
 	unsigned long flags;
 
+	ClearPageIsolated(page);
 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
-	SetPagePrivate(page);
 	list_add(&page->lru, &b_dev_info->pages);
 	b_dev_info->isolated_pages--;
 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
 }
 
-/* __isolate_lru_page() counterpart for a ballooned page */
-bool balloon_page_isolate(struct page *page)
-{
-	/*
-	 * Avoid burning cycles with pages that are yet under __free_pages(),
-	 * or just got freed under us.
-	 *
-	 * In case we 'win' a race for a balloon page being freed under us and
-	 * raise its refcount preventing __free_pages() from doing its job
-	 * the put_page() at the end of this block will take care of
-	 * release this page, thus avoiding a nasty leakage.
-	 */
-	if (likely(get_page_unless_zero(page))) {
-		/*
-		 * As balloon pages are not isolated from LRU lists, concurrent
-		 * compaction threads can race against page migration functions
-		 * as well as race against the balloon driver releasing a page.
-		 *
-		 * In order to avoid having an already isolated balloon page
-		 * being (wrongly) re-isolated while it is under migration,
-		 * or to avoid attempting to isolate pages being released by
-		 * the balloon driver, lets be sure we have the page lock
-		 * before proceeding with the balloon page isolation steps.
-		 */
-		if (likely(trylock_page(page))) {
-			/*
-			 * A ballooned page, by default, has PagePrivate set.
-			 * Prevent concurrent compaction threads from isolating
-			 * an already isolated balloon page by clearing it.
-			 */
-			if (balloon_page_movable(page)) {
-				__isolate_balloon_page(page);
-				unlock_page(page);
-				return true;
-			}
-			unlock_page(page);
-		}
-		put_page(page);
-	}
-	return false;
-}
-
-/* putback_lru_page() counterpart for a ballooned page */
-void balloon_page_putback(struct page *page)
-{
-	/*
-	 * 'lock_page()' stabilizes the page and prevents races against
-	 * concurrent isolation threads attempting to re-isolate it.
-	 */
-	lock_page(page);
-
-	if (__is_movable_balloon_page(page)) {
-		__putback_balloon_page(page);
-		/* drop the extra ref count taken for page isolation */
-		put_page(page);
-	} else {
-		WARN_ON(1);
-		dump_page(page, "not movable balloon page");
-	}
-	unlock_page(page);
-}
-
 /* move_to_new_page() counterpart for a ballooned page */
-int balloon_page_migrate(struct page *newpage,
-			 struct page *page, enum migrate_mode mode)
+int balloon_page_migrate(struct address_space *mapping,
+		struct page *newpage, struct page *page,
+		enum migrate_mode mode)
 {
 	struct balloon_dev_info *balloon = balloon_page_device(page);
-	int rc = -EAGAIN;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
+	VM_BUG_ON_PAGE(!PageMovable(page), page);
+	VM_BUG_ON_PAGE(!PageIsolated(page), page);
 
-	if (WARN_ON(!__is_movable_balloon_page(page))) {
-		dump_page(page, "not movable balloon page");
-		return rc;
-	}
-
-	if (balloon && balloon->migratepage)
-		rc = balloon->migratepage(balloon, newpage, page, mode);
-
-	return rc;
+	return balloon->migratepage(balloon, newpage, page, mode);
 }
+
+const struct address_space_operations balloon_aops = {
+	.migratepage = balloon_page_migrate,
+	.isolate_page = balloon_page_isolate,
+	.putback_page = balloon_page_putback,
+};
+EXPORT_SYMBOL_GPL(balloon_aops);
 #endif /* CONFIG_BALLOON_COMPACTION */
diff --git a/mm/compaction.c b/mm/compaction.c
index 7557aedddaee..e336c620fd7b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -708,13 +708,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		 */
 		is_lru = PageLRU(page);
 		if (!is_lru) {
-			if (unlikely(balloon_page_movable(page))) {
-				if (balloon_page_isolate(page)) {
-					/* Successfully isolated */
-					goto isolate_success;
-				}
-			}
-
 			if (unlikely(PageMovable(page)) &&
 					!PageIsolated(page)) {
 				if (locked) {
diff --git a/mm/migrate.c b/mm/migrate.c
index b56bf2b3fe8c..028814625eea 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -157,8 +157,8 @@ void putback_movable_page(struct page *page)
  * from where they were once taken off for compaction/migration.
  *
  * This function shall be used whenever the isolated pageset has been
- * built from lru, balloon, hugetlbfs page. See isolate_migratepages_range()
- * and isolate_huge_page().
+ * built from lru, movable, hugetlbfs page.
+ * See isolate_migratepages_range() and isolate_huge_page().
  */
 void putback_movable_pages(struct list_head *l)
 {
@@ -173,9 +173,7 @@ void putback_movable_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		if (unlikely(isolated_balloon_page(page))) {
-			balloon_page_putback(page);
-		} else if (unlikely(PageMovable(page))) {
+		if (unlikely(PageMovable(page))) {
 			if (PageIsolated(page)) {
 				putback_movable_page(page);
 			} else {
@@ -977,18 +975,6 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	if (unlikely(!trylock_page(newpage)))
 		goto out_unlock;
 
-	if (unlikely(isolated_balloon_page(page))) {
-		/*
-		 * A ballooned page does not need any special attention from
-		 * physical to virtual reverse mapping procedures.
-		 * Skip any attempt to unmap PTEs or to remap swap cache,
-		 * in order to avoid burning cycles at rmap level, and perform
-		 * the page migration right away (proteced by page lock).
-		 */
-		rc = balloon_page_migrate(newpage, page, mode);
-		goto out_unlock_both;
-	}
-
 	/*
 	 * Corner case handling:
 	 * 1. When a new swap-cache page is read into, it is added to the LRU
@@ -1033,7 +1019,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 out:
 	/* If migration is successful, move newpage to right list */
 	if (rc == MIGRATEPAGE_SUCCESS) {
-		if (unlikely(__is_movable_balloon_page(newpage)))
+		if (unlikely(PageMovable(newpage)))
 			put_page(newpage);
 		else
 			putback_lru_page(newpage);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d82196244340..c7696a2e11c7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1254,7 +1254,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 
 	list_for_each_entry_safe(page, next, page_list, lru) {
 		if (page_is_file_cache(page) && !PageDirty(page) &&
-		    !isolated_balloon_page(page)) {
+		    !PageIsolated(page)) {
 			ClearPageActive(page);
 			list_move(&page->lru, &clean_pages);
 		}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
