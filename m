Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id A3B866B0070
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 05:57:48 -0400 (EDT)
Received: by pdcu2 with SMTP id u2so72270477pdc.3
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 02:57:48 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id e7si49713789pdl.156.2015.06.26.02.57.45
        for <linux-mm@kvack.org>;
        Fri, 26 Jun 2015 02:57:46 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [RFCv2 3/5] mm/balloon: apply driver page migratable into balloon
Date: Fri, 26 Jun 2015 18:58:28 +0900
Message-Id: <1435312710-15108-4-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1435312710-15108-1-git-send-email-gioh.kim@lge.com>
References: <1435312710-15108-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Gioh Kim <gioh.kim@lge.com>

Apply driver page migration into balloon driver.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
---
 drivers/virtio/virtio_balloon.c        |  3 +++
 fs/proc/page.c                         |  3 +++
 include/linux/balloon_compaction.h     | 33 +++++++++++++++++++++------------
 include/uapi/linux/kernel-page-flags.h |  2 +-
 mm/balloon_compaction.c                | 19 +++++++++++++++++--
 5 files changed, 45 insertions(+), 15 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 82e80e0..c49b553 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -505,6 +505,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	balloon_devinfo_init(&vb->vb_dev_info);
 #ifdef CONFIG_BALLOON_COMPACTION
 	vb->vb_dev_info.migratepage = virtballoon_migratepage;
+	vb->vb_dev_info.inode = anon_inode_new();
+	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
+	mapping_set_migratable(vb->vb_dev_info.inode->i_mapping);
 #endif
 
 	err = init_vqs(vb);
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 7eee2d8..2dc3673 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -146,6 +146,9 @@ u64 stable_page_flags(struct page *page)
 	if (PageBalloon(page))
 		u |= 1 << KPF_BALLOON;
 
+	if (PageMigratable(page))
+		u |= 1 << KPF_MIGRATABLE;
+
 	u |= kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
 
 	u |= kpf_copy_bit(k, KPF_SLAB,		PG_slab);
diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index 9b0a15d..e8a3670 100644
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
@@ -73,24 +75,28 @@ static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
 	spin_lock_init(&balloon->pages_lock);
 	INIT_LIST_HEAD(&balloon->pages);
 	balloon->migratepage = NULL;
+	balloon->inode = NULL;
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
-extern bool balloon_page_isolate(struct page *page);
+extern const struct address_space_operations balloon_aops;
+extern bool balloon_page_isolate(struct page *page,
+				 isolate_mode_t mode);
 extern void balloon_page_putback(struct page *page);
-extern int balloon_page_migrate(struct page *newpage,
+extern int balloon_page_migrate(struct address_space *mapping,
+				struct page *newpage,
 				struct page *page, enum migrate_mode mode);
 
 /*
- * __is_movable_balloon_page - helper to perform @page PageBalloon tests
+ * __is_movable_balloon_page - helper to perform @page PageMigratable tests
  */
 static inline bool __is_movable_balloon_page(struct page *page)
 {
-	return PageBalloon(page);
+	return PageMigratable(page);
 }
 
 /*
- * balloon_page_movable - test PageBalloon to identify balloon pages
+ * balloon_page_movable - test PageMigratable to identify balloon pages
  *			  and PagePrivate to check that the page is not
  *			  isolated and can be moved by compaction/migration.
  *
@@ -99,7 +105,7 @@ static inline bool __is_movable_balloon_page(struct page *page)
  */
 static inline bool balloon_page_movable(struct page *page)
 {
-	return PageBalloon(page) && PagePrivate(page);
+	return PageMigratable(page) && PagePrivate(page);
 }
 
 /*
@@ -108,7 +114,7 @@ static inline bool balloon_page_movable(struct page *page)
  */
 static inline bool isolated_balloon_page(struct page *page)
 {
-	return PageBalloon(page);
+	return PageMigratable(page);
 }
 
 /*
@@ -123,7 +129,8 @@ static inline bool isolated_balloon_page(struct page *page)
 static inline void balloon_page_insert(struct balloon_dev_info *balloon,
 				       struct page *page)
 {
-	__SetPageBalloon(page);
+	page->mapping = balloon->inode->i_mapping;
+	__SetPageMigratable(page);
 	SetPagePrivate(page);
 	set_page_private(page, (unsigned long)balloon);
 	list_add(&page->lru, &balloon->pages);
@@ -139,7 +146,8 @@ static inline void balloon_page_insert(struct balloon_dev_info *balloon,
  */
 static inline void balloon_page_delete(struct page *page)
 {
-	__ClearPageBalloon(page);
+	page->mapping = NULL;
+	__ClearPageMigratable(page);
 	set_page_private(page, 0);
 	if (PagePrivate(page)) {
 		ClearPagePrivate(page);
@@ -166,13 +174,13 @@ static inline gfp_t balloon_mapping_gfp_mask(void)
 static inline void balloon_page_insert(struct balloon_dev_info *balloon,
 				       struct page *page)
 {
-	__SetPageBalloon(page);
+	__SetPageMigratable(page);
 	list_add(&page->lru, &balloon->pages);
 }
 
 static inline void balloon_page_delete(struct page *page)
 {
-	__ClearPageBalloon(page);
+	__ClearPageMigratable(page);
 	list_del(&page->lru);
 }
 
@@ -191,7 +199,8 @@ static inline bool isolated_balloon_page(struct page *page)
 	return false;
 }
 
-static inline bool balloon_page_isolate(struct page *page)
+static inline bool balloon_page_isolate(struct page *page,
+					isolate_mode_t mode)
 {
 	return false;
 }
diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
index a6c4962..65db3a6 100644
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -33,6 +33,6 @@
 #define KPF_THP			22
 #define KPF_BALLOON		23
 #define KPF_ZERO_PAGE		24
-
+#define KPF_MIGRATABLE		25
 
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index fcad832..df72846 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -131,7 +131,7 @@ static inline void __putback_balloon_page(struct page *page)
 }
 
 /* __isolate_lru_page() counterpart for a ballooned page */
-bool balloon_page_isolate(struct page *page)
+bool balloon_page_isolate(struct page *page, isolate_mode_t mode)
 {
 	/*
 	 * Avoid burning cycles with pages that are yet under __free_pages(),
@@ -175,6 +175,9 @@ bool balloon_page_isolate(struct page *page)
 /* putback_lru_page() counterpart for a ballooned page */
 void balloon_page_putback(struct page *page)
 {
+	if (!isolated_balloon_page(page))
+		return;
+
 	/*
 	 * 'lock_page()' stabilizes the page and prevents races against
 	 * concurrent isolation threads attempting to re-isolate it.
@@ -193,12 +196,16 @@ void balloon_page_putback(struct page *page)
 }
 
 /* move_to_new_page() counterpart for a ballooned page */
-int balloon_page_migrate(struct page *newpage,
+int balloon_page_migrate(struct address_space *mapping,
+			 struct page *newpage,
 			 struct page *page, enum migrate_mode mode)
 {
 	struct balloon_dev_info *balloon = balloon_page_device(page);
 	int rc = -EAGAIN;
 
+	if (!isolated_balloon_page(page))
+		return rc;
+
 	/*
 	 * Block others from accessing the 'newpage' when we get around to
 	 * establishing additional references. We should be the only one
@@ -218,4 +225,12 @@ int balloon_page_migrate(struct page *newpage,
 	unlock_page(newpage);
 	return rc;
 }
+
+/* define the balloon_mapping->a_ops callback to allow balloon page migration */
+const struct address_space_operations balloon_aops = {
+	.migratepage = balloon_page_migrate,
+	.isolatepage = balloon_page_isolate,
+	.putbackpage = balloon_page_putback,
+};
+EXPORT_SYMBOL_GPL(balloon_aops);
 #endif /* CONFIG_BALLOON_COMPACTION */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
