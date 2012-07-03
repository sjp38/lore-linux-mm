Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 3099B6B00A9
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 19:49:57 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v3 3/4] virtio_balloon: introduce migration primitives to balloon pages
Date: Tue,  3 Jul 2012 20:48:51 -0300
Message-Id: <ece5b03ce1d45805a11459303bd8e7e40cbd2be6.1341353014.git.aquini@redhat.com>
In-Reply-To: <cover.1341353014.git.aquini@redhat.com>
References: <cover.1341353014.git.aquini@redhat.com>
In-Reply-To: <cover.1341353014.git.aquini@redhat.com>
References: <cover.1341353014.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@redhat.com>

This patch makes balloon pages movable at allocation time and introduces the
infrastructure needed to perform the balloon page migration operation.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 drivers/virtio/virtio_balloon.c |   96 ++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_balloon.h  |    4 ++
 2 files changed, 98 insertions(+), 2 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index d47c5c2..53386aa 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -27,6 +27,8 @@
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/pagemap.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -140,8 +142,9 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 	spin_lock(&vb->pfn_list_lock);
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
@@ -154,6 +157,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
 		totalram_pages--;
 		list_add(&page->lru, &vb->pages);
+		page->mapping = balloon_mapping;
 	}
 
 	/* Didn't get any?  Oh well. */
@@ -195,6 +199,7 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
 	for (vb->num_pfns = 0; vb->num_pfns < num;
 	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
 		page = list_first_entry(&vb->pages, struct page, lru);
+		page->mapping = NULL;
 		list_del(&page->lru);
 		set_page_pfns(vb->pfns + vb->num_pfns, page);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
@@ -365,6 +370,77 @@ static int init_vqs(struct virtio_balloon *vb)
 	return 0;
 }
 
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
+	struct virtio_balloon *vb = (void *)mapping->backing_dev_info;
+	struct scatterlist sg;
+
+	/* balloon's page migration 1st step */
+	spin_lock(&vb->pfn_list_lock);
+	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+	list_add(&newpage->lru, &vb->pages);
+	set_page_pfns(vb->pfns, newpage);
+	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+	spin_unlock(&vb->pfn_list_lock);
+	tell_host(vb, vb->inflate_vq, &sg);
+
+	/* balloon's page migration 2nd step */
+	spin_lock(&vb->pfn_list_lock);
+	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+	set_page_pfns(vb->pfns, page);
+	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+	spin_unlock(&vb->pfn_list_lock);
+	tell_host(vb, vb->deflate_vq, &sg);
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
+	struct address_space *mapping = page->mapping;
+	struct virtio_balloon *vb = (void *)mapping->backing_dev_info;
+	spin_lock(&vb->pfn_list_lock);
+	list_del(&page->lru);
+	spin_unlock(&vb->pfn_list_lock);
+}
+
+/*
+ * Populate balloon_mapping->a_ops->freepage method to help compaction on
+ * re-inserting an isolated page into the balloon page list.
+ */
+void virtballoon_putbackpage(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	struct virtio_balloon *vb = (void *)mapping->backing_dev_info;
+	spin_lock(&vb->pfn_list_lock);
+	list_add(&page->lru, &vb->pages);
+	spin_unlock(&vb->pfn_list_lock);
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
@@ -384,6 +460,19 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	vb->vdev = vdev;
 	vb->need_stats_update = 0;
 
+	/* Init the ballooned page->mapping special balloon_mapping */
+	balloon_mapping = kmalloc(sizeof(*balloon_mapping), GFP_KERNEL);
+	if (!balloon_mapping) {
+		err = -ENOMEM;
+		goto out_free_mapping;
+	}
+
+	INIT_RADIX_TREE(&balloon_mapping->page_tree, GFP_ATOMIC | __GFP_NOWARN);
+	INIT_LIST_HEAD(&balloon_mapping->i_mmap_nonlinear);
+	spin_lock_init(&balloon_mapping->tree_lock);
+	balloon_mapping->a_ops = &virtio_balloon_aops;
+	balloon_mapping->backing_dev_info = (void *)vb;
+
 	err = init_vqs(vb);
 	if (err)
 		goto out_free_vb;
@@ -398,6 +487,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
 
 out_del_vqs:
 	vdev->config->del_vqs(vdev);
+out_free_mapping:
+	kfree(balloon_mapping);
 out_free_vb:
 	kfree(vb);
 out:
@@ -424,6 +515,7 @@ static void __devexit virtballoon_remove(struct virtio_device *vdev)
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
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
