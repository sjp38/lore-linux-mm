Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 571146B0073
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 18:54:08 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v6 2/3] virtio_balloon: introduce migration primitives to balloon pages
Date: Wed,  8 Aug 2012 19:53:20 -0300
Message-Id: <5f4b30060e252e557882595984a8225ba6e0c9f2.1344463786.git.aquini@redhat.com>
In-Reply-To: <cover.1344463786.git.aquini@redhat.com>
References: <cover.1344463786.git.aquini@redhat.com>
In-Reply-To: <cover.1344463786.git.aquini@redhat.com>
References: <cover.1344463786.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@redhat.com>

Memory fragmentation introduced by ballooning might reduce significantly
the number of 2MB contiguous memory blocks that can be used within a guest,
thus imposing performance penalties associated with the reduced number of
transparent huge pages that could be used by the guest workload.

Besides making balloon pages movable at allocation time and introducing
the necessary primitives to perform balloon page migration/compaction,
this patch also introduces the following locking scheme to provide the
proper synchronization and protection for struct virtio_balloon elements
against concurrent accesses due to parallel operations introduced by
memory compaction / page migration.
 - balloon_lock (mutex) : synchronizes the access demand to elements of
			  struct virtio_balloon and its queue operations;
 - pages_lock (spinlock): special protection to balloon pages list against
			  concurrent list handling operations;

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 drivers/virtio/virtio_balloon.c | 138 +++++++++++++++++++++++++++++++++++++---
 include/linux/virtio_balloon.h  |   4 ++
 2 files changed, 134 insertions(+), 8 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 0908e60..7c937a0 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -27,6 +27,7 @@
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/fs.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -35,6 +36,12 @@
  */
 #define VIRTIO_BALLOON_PAGES_PER_PAGE (PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
 
+/* Synchronizes accesses/updates to the struct virtio_balloon elements */
+DEFINE_MUTEX(balloon_lock);
+
+/* Protects 'virtio_balloon->pages' list against concurrent handling */
+DEFINE_SPINLOCK(pages_lock);
+
 struct virtio_balloon
 {
 	struct virtio_device *vdev;
@@ -51,6 +58,7 @@ struct virtio_balloon
 
 	/* Number of balloon pages we've told the Host we're not using. */
 	unsigned int num_pages;
+
 	/*
 	 * The pages we've told the Host we're not using.
 	 * Each page on this list adds VIRTIO_BALLOON_PAGES_PER_PAGE
@@ -125,10 +133,12 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
+	mutex_lock(&balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
 	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
-		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY |
-					__GFP_NOMEMALLOC | __GFP_NOWARN);
+		struct page *page = alloc_page(GFP_HIGHUSER_MOVABLE |
+						__GFP_NORETRY | __GFP_NOWARN |
+						__GFP_NOMEMALLOC);
 		if (!page) {
 			if (printk_ratelimit())
 				dev_printk(KERN_INFO, &vb->vdev->dev,
@@ -141,7 +151,10 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 		set_page_pfns(vb->pfns + vb->num_pfns, page);
 		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
 		totalram_pages--;
+		spin_lock(&pages_lock);
 		list_add(&page->lru, &vb->pages);
+		page->mapping = balloon_mapping;
+		spin_unlock(&pages_lock);
 	}
 
 	/* Didn't get any?  Oh well. */
@@ -149,6 +162,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 		return;
 
 	tell_host(vb, vb->inflate_vq);
+	mutex_unlock(&balloon_lock);
 }
 
 static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
@@ -169,10 +183,22 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
+	mutex_lock(&balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
 	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
+		/*
+		 * We can race against virtballoon_isolatepage() and end up
+		 * stumbling across a _temporarily_ empty 'pages' list.
+		 */
+		spin_lock(&pages_lock);
+		if (unlikely(list_empty(&vb->pages))) {
+			spin_unlock(&pages_lock);
+			break;
+		}
 		page = list_first_entry(&vb->pages, struct page, lru);
+		page->mapping = NULL;
 		list_del(&page->lru);
+		spin_unlock(&pages_lock);
 		set_page_pfns(vb->pfns + vb->num_pfns, page);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
@@ -182,8 +208,11 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
 	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
 	 * is true, we *have* to do it in this order
 	 */
-	tell_host(vb, vb->deflate_vq);
-	release_pages_by_pfn(vb->pfns, vb->num_pfns);
+	if (vb->num_pfns > 0) {
+		tell_host(vb, vb->deflate_vq);
+		release_pages_by_pfn(vb->pfns, vb->num_pfns);
+	}
+	mutex_unlock(&balloon_lock);
 }
 
 static inline void update_stat(struct virtio_balloon *vb, int idx,
@@ -239,6 +268,7 @@ static void stats_handle_request(struct virtio_balloon *vb)
 	struct scatterlist sg;
 	unsigned int len;
 
+	mutex_lock(&balloon_lock);
 	vb->need_stats_update = 0;
 	update_balloon_stats(vb);
 
@@ -249,6 +279,7 @@ static void stats_handle_request(struct virtio_balloon *vb)
 	if (virtqueue_add_buf(vq, &sg, 1, 0, vb, GFP_KERNEL) < 0)
 		BUG();
 	virtqueue_kick(vq);
+	mutex_unlock(&balloon_lock);
 }
 
 static void virtballoon_changed(struct virtio_device *vdev)
@@ -261,22 +292,27 @@ static void virtballoon_changed(struct virtio_device *vdev)
 static inline s64 towards_target(struct virtio_balloon *vb)
 {
 	__le32 v;
-	s64 target;
+	s64 target, actual;
 
+	mutex_lock(&balloon_lock);
+	actual = vb->num_pages;
 	vb->vdev->config->get(vb->vdev,
 			      offsetof(struct virtio_balloon_config, num_pages),
 			      &v, sizeof(v));
 	target = le32_to_cpu(v);
-	return target - vb->num_pages;
+	mutex_unlock(&balloon_lock);
+	return target - actual;
 }
 
 static void update_balloon_size(struct virtio_balloon *vb)
 {
-	__le32 actual = cpu_to_le32(vb->num_pages);
-
+	__le32 actual;
+	mutex_lock(&balloon_lock);
+	actual = cpu_to_le32(vb->num_pages);
 	vb->vdev->config->set(vb->vdev,
 			      offsetof(struct virtio_balloon_config, actual),
 			      &actual, sizeof(actual));
+	mutex_unlock(&balloon_lock);
 }
 
 static int balloon(void *_vballoon)
@@ -339,6 +375,76 @@ static int init_vqs(struct virtio_balloon *vb)
 	return 0;
 }
 
+/*
+ * '*vb_ptr' allows virtballoon_migratepage() & virtballoon_putbackpage() to
+ * access pertinent elements from struct virtio_balloon
+ */
+struct virtio_balloon *vb_ptr;
+
+/*
+ * Populate balloon_mapping->a_ops->migratepage method to perform the balloon
+ * page migration task.
+ *
+ * After a ballooned page gets isolated by compaction procedures, this is the
+ * function that performs the page migration on behalf of move_to_new_page(),
+ * when the last calls (page)->mapping->a_ops->migratepage.
+ *
+ * Page migration for virtio balloon is done in a simple swap fashion which
+ * follows these two steps:
+ *  1) insert newpage into vb->pages list and update the host about it;
+ *  2) update the host about the removed old page from vb->pages list;
+ */
+int virtballoon_migratepage(struct address_space *mapping,
+		struct page *newpage, struct page *page, enum migrate_mode mode)
+{
+	mutex_lock(&balloon_lock);
+
+	/* balloon's page migration 1st step */
+	vb_ptr->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+	spin_lock(&pages_lock);
+	list_add(&newpage->lru, &vb_ptr->pages);
+	spin_unlock(&pages_lock);
+	set_page_pfns(vb_ptr->pfns, newpage);
+	tell_host(vb_ptr, vb_ptr->inflate_vq);
+
+	/* balloon's page migration 2nd step */
+	vb_ptr->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+	set_page_pfns(vb_ptr->pfns, page);
+	tell_host(vb_ptr, vb_ptr->deflate_vq);
+
+	mutex_unlock(&balloon_lock);
+
+	return 0;
+}
+
+/*
+ * Populate balloon_mapping->a_ops->invalidatepage method to help compaction on
+ * isolating a page from the balloon page list.
+ */
+void virtballoon_isolatepage(struct page *page, unsigned long mode)
+{
+	spin_lock(&pages_lock);
+	list_del(&page->lru);
+	spin_unlock(&pages_lock);
+}
+
+/*
+ * Populate balloon_mapping->a_ops->freepage method to help compaction on
+ * re-inserting an isolated page into the balloon page list.
+ */
+void virtballoon_putbackpage(struct page *page)
+{
+	spin_lock(&pages_lock);
+	list_add(&page->lru, &vb_ptr->pages);
+	spin_unlock(&pages_lock);
+}
+
+static const struct address_space_operations virtio_balloon_aops = {
+	.migratepage = virtballoon_migratepage,
+	.invalidatepage = virtballoon_isolatepage,
+	.freepage = virtballoon_putbackpage,
+};
+
 static int virtballoon_probe(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb;
@@ -351,11 +457,25 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	}
 
 	INIT_LIST_HEAD(&vb->pages);
+
 	vb->num_pages = 0;
 	init_waitqueue_head(&vb->config_change);
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
 	vb->need_stats_update = 0;
+	vb_ptr = vb;
+
+	/* Init the ballooned page->mapping special balloon_mapping */
+	balloon_mapping = kmalloc(sizeof(*balloon_mapping), GFP_KERNEL);
+	if (!balloon_mapping) {
+		err = -ENOMEM;
+		goto out_free_vb;
+	}
+
+	INIT_RADIX_TREE(&balloon_mapping->page_tree, GFP_ATOMIC | __GFP_NOWARN);
+	INIT_LIST_HEAD(&balloon_mapping->i_mmap_nonlinear);
+	spin_lock_init(&balloon_mapping->tree_lock);
+	balloon_mapping->a_ops = &virtio_balloon_aops;
 
 	err = init_vqs(vb);
 	if (err)
@@ -373,6 +493,7 @@ out_del_vqs:
 	vdev->config->del_vqs(vdev);
 out_free_vb:
 	kfree(vb);
+	kfree(balloon_mapping);
 out:
 	return err;
 }
@@ -397,6 +518,7 @@ static void __devexit virtballoon_remove(struct virtio_device *vdev)
 	kthread_stop(vb->thread);
 	remove_common(vb);
 	kfree(vb);
+	kfree(balloon_mapping);
 }
 
 #ifdef CONFIG_PM
diff --git a/include/linux/virtio_balloon.h b/include/linux/virtio_balloon.h
index 652dc8b..930f1b7 100644
--- a/include/linux/virtio_balloon.h
+++ b/include/linux/virtio_balloon.h
@@ -56,4 +56,8 @@ struct virtio_balloon_stat {
 	u64 val;
 } __attribute__((packed));
 
+#if !defined(CONFIG_COMPACTION)
+struct address_space *balloon_mapping;
+#endif
+
 #endif /* _LINUX_VIRTIO_BALLOON_H */
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
