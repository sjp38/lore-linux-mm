Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 628A46B0069
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 08:48:16 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v8 3/5] virtio_balloon: introduce migration primitives to balloon pages
Date: Tue, 21 Aug 2012 09:47:46 -0300
Message-Id: <c5f02c618c99b0da11240c1b504672de6f70a074.1345519422.git.aquini@redhat.com>
In-Reply-To: <cover.1345519422.git.aquini@redhat.com>
References: <cover.1345519422.git.aquini@redhat.com>
In-Reply-To: <cover.1345519422.git.aquini@redhat.com>
References: <cover.1345519422.git.aquini@redhat.com>
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
 - virtio_baloon->pages list handling sync by RCU operations;

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 drivers/virtio/virtio_balloon.c | 210 +++++++++++++++++++++++++++++++++++++---
 1 file changed, 199 insertions(+), 11 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 0908e60..bda7bb0 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -27,6 +27,7 @@
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/balloon_compaction.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -35,6 +36,12 @@
  */
 #define VIRTIO_BALLOON_PAGES_PER_PAGE (PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
 
+/* flags used to hint compaction procedures about the balloon device status */
+enum balloon_status_flags {
+	BALLOON_REMOVAL = 0,	/* balloon device is under removal steps */
+	BALLOON_OK,		/* balloon device is up and running */
+};
+
 struct virtio_balloon
 {
 	struct virtio_device *vdev;
@@ -46,11 +53,24 @@ struct virtio_balloon
 	/* The thread servicing the balloon. */
 	struct task_struct *thread;
 
+	/* balloon special page->mapping */
+	struct address_space *mapping;
+
+	/* Synchronize access/update to this struct virtio_balloon elements */
+	struct mutex balloon_lock;
+
 	/* Waiting for host to ack the pages we released. */
 	wait_queue_head_t acked;
 
 	/* Number of balloon pages we've told the Host we're not using. */
 	unsigned int num_pages;
+
+	/* balloon device status flag */
+	unsigned short balloon_status;
+
+	/* Protect 'pages' list against concurrent handling */
+	spinlock_t pages_lock;
+
 	/*
 	 * The pages we've told the Host we're not using.
 	 * Each page on this list adds VIRTIO_BALLOON_PAGES_PER_PAGE
@@ -122,13 +142,17 @@ static void set_page_pfns(u32 pfns[], struct page *page)
 
 static void fill_balloon(struct virtio_balloon *vb, size_t num)
 {
+	/* Get the proper GFP alloc mask from vb->mapping flags */
+	gfp_t vb_gfp_mask = mapping_gfp_mask(vb->mapping);
+
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
+	mutex_lock(&vb->balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
 	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
-		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY |
-					__GFP_NOMEMALLOC | __GFP_NOWARN);
+		struct page *page = alloc_page(vb_gfp_mask | __GFP_NORETRY |
+					       __GFP_NOWARN | __GFP_NOMEMALLOC);
 		if (!page) {
 			if (printk_ratelimit())
 				dev_printk(KERN_INFO, &vb->vdev->dev,
@@ -141,7 +165,10 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 		set_page_pfns(vb->pfns + vb->num_pfns, page);
 		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
 		totalram_pages--;
-		list_add(&page->lru, &vb->pages);
+		spin_lock(&vb->pages_lock);
+		list_add_rcu(&page->lru, &vb->pages);
+		assign_balloon_mapping(page, vb->mapping);
+		spin_unlock(&vb->pages_lock);
 	}
 
 	/* Didn't get any?  Oh well. */
@@ -149,6 +176,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 		return;
 
 	tell_host(vb, vb->inflate_vq);
+	mutex_unlock(&vb->balloon_lock);
 }
 
 static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
@@ -169,21 +197,48 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
+	mutex_lock(&vb->balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
 	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
-		page = list_first_entry(&vb->pages, struct page, lru);
-		list_del(&page->lru);
+		/*
+		 * We can race against 'virtballoon_isolatepage()' and end up
+		 * stumbling across a _temporarily_ empty 'pages' list.
+		 */
+		spin_lock(&vb->pages_lock);
+		page = list_first_or_null_rcu(&vb->pages, struct page, lru);
+		if (!page) {
+			spin_unlock(&vb->pages_lock);
+			break;
+		}
+		/*
+		 * It is safe now to drop page->mapping and delete this page
+		 * from balloon page list, since we are grabbing 'pages_lock'
+		 * which prevents 'virtballoon_isolatepage()' from acting.
+		 */
+		clear_balloon_mapping(page);
+		list_del_rcu(&page->lru);
+		spin_unlock(&vb->pages_lock);
 		set_page_pfns(vb->pfns + vb->num_pfns, page);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
+	/*
+	 * Syncrhonize RCU grace period and wait for all RCU read critical side
+	 * sections to finish before proceeding with page release steps.
+	 * This avoids compaction/migration callback races against balloon
+	 * device removal steps.
+	 */
+	synchronize_rcu();
 
 	/*
 	 * Note that if
 	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
 	 * is true, we *have* to do it in this order
 	 */
-	tell_host(vb, vb->deflate_vq);
-	release_pages_by_pfn(vb->pfns, vb->num_pfns);
+	if (vb->num_pfns > 0) {
+		tell_host(vb, vb->deflate_vq);
+		release_pages_by_pfn(vb->pfns, vb->num_pfns);
+	}
+	mutex_unlock(&vb->balloon_lock);
 }
 
 static inline void update_stat(struct virtio_balloon *vb, int idx,
@@ -239,6 +294,7 @@ static void stats_handle_request(struct virtio_balloon *vb)
 	struct scatterlist sg;
 	unsigned int len;
 
+	mutex_lock(&vb->balloon_lock);
 	vb->need_stats_update = 0;
 	update_balloon_stats(vb);
 
@@ -249,6 +305,7 @@ static void stats_handle_request(struct virtio_balloon *vb)
 	if (virtqueue_add_buf(vq, &sg, 1, 0, vb, GFP_KERNEL) < 0)
 		BUG();
 	virtqueue_kick(vq);
+	mutex_unlock(&vb->balloon_lock);
 }
 
 static void virtballoon_changed(struct virtio_device *vdev)
@@ -261,22 +318,27 @@ static void virtballoon_changed(struct virtio_device *vdev)
 static inline s64 towards_target(struct virtio_balloon *vb)
 {
 	__le32 v;
-	s64 target;
+	s64 target, actual;
 
+	mutex_lock(&vb->balloon_lock);
+	actual = vb->num_pages;
 	vb->vdev->config->get(vb->vdev,
 			      offsetof(struct virtio_balloon_config, num_pages),
 			      &v, sizeof(v));
 	target = le32_to_cpu(v);
-	return target - vb->num_pages;
+	mutex_unlock(&vb->balloon_lock);
+	return target - actual;
 }
 
 static void update_balloon_size(struct virtio_balloon *vb)
 {
-	__le32 actual = cpu_to_le32(vb->num_pages);
-
+	__le32 actual;
+	mutex_lock(&vb->balloon_lock);
+	actual = cpu_to_le32(vb->num_pages);
 	vb->vdev->config->set(vb->vdev,
 			      offsetof(struct virtio_balloon_config, actual),
 			      &actual, sizeof(actual));
+	mutex_unlock(&vb->balloon_lock);
 }
 
 static int balloon(void *_vballoon)
@@ -339,9 +401,117 @@ static int init_vqs(struct virtio_balloon *vb)
 	return 0;
 }
 
+#ifdef CONFIG_BALLOON_COMPACTION
+/*
+ * Populate balloon_mapping->a_ops callback method to perform the balloon
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
+	struct virtio_balloon *vb = (void *)__page_balloon_device(page);
+
+	/* at this point, besides very unlikely, a NULL *vb is a serious bug */
+	BUG_ON(!vb);
+
+	/*
+	 * Skip page migration step if the memory balloon device is under its
+	 * removal procedure, to avoid racing against module unload.
+	 *
+	 * If there still are isolated (balloon) pages under migration lists,
+	 * 'virtballoon_putbackpage()' will take care of them properly, before
+	 * the module unload finishes.
+	 */
+	if (vb->balloon_status == BALLOON_REMOVAL)
+		return -EAGAIN;
+
+	mutex_lock(&vb->balloon_lock);
+
+	/* balloon's page migration 1st step */
+	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+	spin_lock(&vb->pages_lock);
+	list_add_rcu(&newpage->lru, &vb->pages);
+	spin_unlock(&vb->pages_lock);
+	set_page_pfns(vb->pfns, newpage);
+	tell_host(vb, vb->inflate_vq);
+
+	/* balloon's page migration 2nd step */
+	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+	set_page_pfns(vb->pfns, page);
+	tell_host(vb, vb->deflate_vq);
+
+	mutex_unlock(&vb->balloon_lock);
+	return 0;
+}
+
+/*
+ * Populate balloon_mapping->a_ops callback method to help compaction on
+ * isolating a page from the balloon page list for posterior migration.
+ */
+int virtballoon_isolatepage(struct page *page)
+{
+	struct virtio_balloon *vb = (void *)__page_balloon_device(page);
+	int ret = 0;
+	/*
+	 * If we stumble across a NULL *vb here, it means this page has been
+	 * already released by 'leak_balloon()'.
+	 *
+	 * We also skip the page isolation step if the memory balloon device is
+	 * under its removal procedure, to avoid racing against module unload.
+	 */
+	if (vb && (vb->balloon_status != BALLOON_REMOVAL)) {
+		spin_lock(&vb->pages_lock);
+		/*
+		 * virtballoon_isolatepage() can race against leak_balloon(),
+		 * and (wrongly) isolate a page that is about to be freed.
+		 * Test page->mapping under pages_lock to close that window.
+		 */
+		if (rcu_access_pointer(page->mapping) == vb->mapping) {
+			/* It is safe to isolate this page, now */
+			list_del_rcu(&page->lru);
+			ret = 1;
+		}
+		spin_unlock(&vb->pages_lock);
+	}
+	return ret;
+}
+
+/*
+ * Populate balloon_mapping->a_ops callback method to help compaction on
+ * re-inserting a not-migrated isolated page into the balloon page list.
+ */
+void virtballoon_putbackpage(struct page *page)
+{
+	struct virtio_balloon *vb = (void *)__page_balloon_device(page);
+
+	/* at this point, besides very unlikely, a NULL *vb is a serious bug */
+	BUG_ON(!vb);
+
+	spin_lock(&vb->pages_lock);
+	list_add_rcu(&page->lru, &vb->pages);
+	spin_unlock(&vb->pages_lock);
+}
+#endif /* CONFIG_BALLOON_COMPACTION */
+
+/* define the balloon_mapping->a_ops callbacks to allow compaction/migration */
+static DEFINE_BALLOON_MAPPING_AOPS(virtio_balloon_aops,
+				   virtballoon_migratepage,
+				   virtballoon_isolatepage,
+				   virtballoon_putbackpage);
+
 static int virtballoon_probe(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb;
+	struct address_space *vb_mapping;
 	int err;
 
 	vdev->priv = vb = kmalloc(sizeof(*vb), GFP_KERNEL);
@@ -351,12 +521,24 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	}
 
 	INIT_LIST_HEAD(&vb->pages);
+	spin_lock_init(&vb->pages_lock);
+	mutex_init(&vb->balloon_lock);
+
 	vb->num_pages = 0;
 	init_waitqueue_head(&vb->config_change);
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
 	vb->need_stats_update = 0;
 
+	/* Allocate a special page->mapping for this balloon device */
+	vb_mapping = alloc_balloon_mapping((void *)vb, &virtio_balloon_aops);
+	if (!vb_mapping) {
+		err = -ENOMEM;
+		goto out_free_vb;
+	}
+	/* Store the page->mapping reference for this balloon device */
+	vb->mapping = vb_mapping;
+
 	err = init_vqs(vb);
 	if (err)
 		goto out_free_vb;
@@ -367,12 +549,14 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		goto out_del_vqs;
 	}
 
+	vb->balloon_status = BALLOON_OK;
 	return 0;
 
 out_del_vqs:
 	vdev->config->del_vqs(vdev);
 out_free_vb:
 	kfree(vb);
+	kfree(vb_mapping);
 out:
 	return err;
 }
@@ -394,8 +578,10 @@ static void __devexit virtballoon_remove(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb = vdev->priv;
 
+	vb->balloon_status = BALLOON_REMOVAL;
 	kthread_stop(vb->thread);
 	remove_common(vb);
+	kfree(vb->mapping);
 	kfree(vb);
 }
 
@@ -409,6 +595,7 @@ static int virtballoon_freeze(struct virtio_device *vdev)
 	 * function is called.
 	 */
 
+	vb->balloon_status = BALLOON_REMOVAL;
 	remove_common(vb);
 	return 0;
 }
@@ -424,6 +611,7 @@ static int virtballoon_restore(struct virtio_device *vdev)
 
 	fill_balloon(vb, towards_target(vb));
 	update_balloon_size(vb);
+	vb->balloon_status = BALLOON_OK;
 	return 0;
 }
 #endif
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
