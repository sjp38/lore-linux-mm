Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 4F7A16B0071
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 12:39:00 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v10 3/5] virtio_balloon: introduce migration primitives to balloon pages
Date: Mon, 17 Sep 2012 13:38:18 -0300
Message-Id: <39738cbd4b596714210e453440833db7cca73172.1347897793.git.aquini@redhat.com>
In-Reply-To: <cover.1347897793.git.aquini@redhat.com>
References: <cover.1347897793.git.aquini@redhat.com>
In-Reply-To: <cover.1347897793.git.aquini@redhat.com>
References: <cover.1347897793.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, aquini@redhat.com

Memory fragmentation introduced by ballooning might reduce significantly
the number of 2MB contiguous memory blocks that can be used within a guest,
thus imposing performance penalties associated with the reduced number of
transparent huge pages that could be used by the guest workload.

Besides making balloon pages movable at allocation time and introducing
the necessary primitives to perform balloon page migration/compaction,
this patch also introduces the following locking scheme, in order to
enhance the syncronization methods for accessing elements of struct
virtio_balloon, thus providing protection against concurrent access
introduced by parallel memory compaction threads.

 - balloon_lock (mutex) : synchronizes the access demand to elements of
                          struct virtio_balloon and its queue operations;
 - pages_lock (spinlock): special protection to balloon's pages bookmarking
                          elements (list and atomic counters) against the
                          potential memory compaction concurrency;

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 drivers/virtio/virtio_balloon.c | 305 +++++++++++++++++++++++++++++++++++++---
 1 file changed, 286 insertions(+), 19 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 0908e60..a52c768 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -27,6 +27,7 @@
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/balloon_compaction.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -34,6 +35,7 @@
  * page units.
  */
 #define VIRTIO_BALLOON_PAGES_PER_PAGE (PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
+#define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
 
 struct virtio_balloon
 {
@@ -46,11 +48,24 @@ struct virtio_balloon
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
 
+	/* Protect pages list, and pages bookeeping counters */
+	spinlock_t pages_lock;
+
+	/* Number of balloon pages isolated from 'pages' list for compaction */
+	unsigned int num_isolated_pages;
+
 	/* Number of balloon pages we've told the Host we're not using. */
 	unsigned int num_pages;
+
 	/*
 	 * The pages we've told the Host we're not using.
 	 * Each page on this list adds VIRTIO_BALLOON_PAGES_PER_PAGE
@@ -60,7 +75,7 @@ struct virtio_balloon
 
 	/* The array of pfns we tell the Host about. */
 	unsigned int num_pfns;
-	u32 pfns[256];
+	u32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
 
 	/* Memory statistics */
 	int need_stats_update;
@@ -122,13 +137,17 @@ static void set_page_pfns(u32 pfns[], struct page *page)
 
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
@@ -139,9 +158,15 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 			break;
 		}
 		set_page_pfns(vb->pfns + vb->num_pfns, page);
-		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
 		totalram_pages--;
+
+		BUG_ON(!trylock_page(page));
+		spin_lock(&vb->pages_lock);
 		list_add(&page->lru, &vb->pages);
+		assign_balloon_mapping(page, vb->mapping);
+		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
+		spin_unlock(&vb->pages_lock);
+		unlock_page(page);
 	}
 
 	/* Didn't get any?  Oh well. */
@@ -149,6 +174,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 		return;
 
 	tell_host(vb, vb->inflate_vq);
+	mutex_unlock(&vb->balloon_lock);
 }
 
 static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
@@ -162,19 +188,64 @@ static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
 	}
 }
 
-static void leak_balloon(struct virtio_balloon *vb, size_t num)
+/*
+ * __leak_balloon - back-end for the balloon pages deflate mechanism.
+ * @vb : pointer to the balloon device descriptor we're leaking (deflating)
+ * @leak_target : how many pages we are looking to drain off balloon's list.
+ *
+ * Here we do all the heavy lifting on behalf of leak_balloon(). This function
+ * must only be called by leak_balloon(), embedded on its wait_event() callsite
+ * and under the following locking scheme:
+ *	mutex(balloon_lock)
+ *	+--spinlock(pages_lock)
+ *	   +--__leak_balloon
+ */
+static int __leak_balloon(struct virtio_balloon *vb, size_t leak_target)
 {
-	struct page *page;
-
 	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	leak_target = min(leak_target, ARRAY_SIZE(vb->pfns));
 
-	for (vb->num_pfns = 0; vb->num_pfns < num;
+	for (vb->num_pfns = 0; vb->num_pfns < leak_target;
 	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
-		page = list_first_entry(&vb->pages, struct page, lru);
+		struct page *page = NULL;
+		/*
+		 * leak_balloon() attempts to work releasing balloon pages by
+		 * groups of (at most) 'VIRTIO_BALLOON_ARRAY_PFNS_MAX' size
+		 * at each round.
+		 * When compaction isolates pages from balloon page list,
+		 * we might end up finding less pages on balloon's list than
+		 * what is our desired 'leak_target'.
+		 * When such occurrence happens, however, whe shall wrap-up
+		 * the work for this round and wait until enough pages get
+		 * inserted back into balloon's page list before proceeding.
+		 */
+		if (!list_empty(&vb->pages))
+			page = list_first_entry(&vb->pages, struct page, lru);
+
+		if (!page)
+			break;
+
+		/*
+		 * Grab the page lock to avoid racing against threads isolating
+		 * pages from, or migrating pages back to vb->pages list.
+		 * (both tasks are done under page lock protection)
+		 *
+		 * Failing to grab the page lock here means this page is being
+		 * isolated already, or its migration has not finished yet.
+		 *
+		 * We simply cannot afford to keep waiting on page lock here,
+		 * otherwise we might cause a lock inversion and remain dead-
+		 * locked with threads isolating/migrating pages.
+		 * So, we give up this round if we fail to grab the page lock.
+		 */
+		if (!trylock_page(page))
+			break;
+
+		clear_balloon_mapping(page);
 		list_del(&page->lru);
-		set_page_pfns(vb->pfns + vb->num_pfns, page);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
+		set_page_pfns(vb->pfns + vb->num_pfns, page);
+		unlock_page(page);
 	}
 
 	/*
@@ -182,8 +253,58 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
 	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
 	 * is true, we *have* to do it in this order
 	 */
-	tell_host(vb, vb->deflate_vq);
-	release_pages_by_pfn(vb->pfns, vb->num_pfns);
+	if (vb->num_pfns > 0) {
+		spin_unlock(&vb->pages_lock);
+		tell_host(vb, vb->deflate_vq);
+		release_pages_by_pfn(vb->pfns, vb->num_pfns);
+		spin_lock(&vb->pages_lock);
+	}
+
+	return vb->num_pfns;
+}
+
+/*
+ * __wait_on_isolate_pages - evaluates the condition that breaks leak_balloon()
+ *			     wait_event loop.
+ * @vb : pointer to the balloon device descriptor we're leaking (deflating)
+ * @leak_target : pointer to our leak target.
+ *
+ * This is a helper to leak_balloon() wait_event scheme. Here we test the
+ * conditions to break the wait loop, as well as we embed the call to
+ * __leak_balloon() under the proper locking scheme.
+ */
+static inline bool __wait_on_isolated_pages(struct virtio_balloon *vb,
+					    size_t *leak_target)
+{
+	bool cond = false;
+	size_t leaked = 0;
+
+	mutex_lock(&vb->balloon_lock);
+	spin_lock(&vb->pages_lock);
+	if (*leak_target <= (vb->num_pages - vb->num_isolated_pages))
+		leaked = __leak_balloon(vb, *leak_target);
+
+	/* compensate the target with the amount of pages leaked this round */
+	*leak_target -= leaked;
+	cond = (*leak_target <= (vb->num_pages - vb->num_isolated_pages));
+	spin_unlock(&vb->pages_lock);
+	mutex_unlock(&vb->balloon_lock);
+	return cond;
+}
+
+/*
+ * leak_balloon - front-end for balloon pages deflate mechanism.
+ * @vb : pointer to the balloon device descriptor we're leaking (deflating)
+ * @leak_target : how many pages we are looking to drain off balloon's list.
+ */
+static void leak_balloon(struct virtio_balloon *vb, size_t leak_target)
+{
+	/* We can only do one array worth at a time. */
+	leak_target = min(leak_target, ARRAY_SIZE(vb->pfns));
+
+	/* Deflate balloon, or wait if there are too much isolated pages */
+	wait_event(vb->config_change,
+		   __wait_on_isolated_pages(vb, &leak_target));
 }
 
 static inline void update_stat(struct virtio_balloon *vb, int idx,
@@ -239,6 +360,7 @@ static void stats_handle_request(struct virtio_balloon *vb)
 	struct scatterlist sg;
 	unsigned int len;
 
+	mutex_lock(&vb->balloon_lock);
 	vb->need_stats_update = 0;
 	update_balloon_stats(vb);
 
@@ -249,6 +371,7 @@ static void stats_handle_request(struct virtio_balloon *vb)
 	if (virtqueue_add_buf(vq, &sg, 1, 0, vb, GFP_KERNEL) < 0)
 		BUG();
 	virtqueue_kick(vq);
+	mutex_unlock(&vb->balloon_lock);
 }
 
 static void virtballoon_changed(struct virtio_device *vdev)
@@ -261,22 +384,29 @@ static void virtballoon_changed(struct virtio_device *vdev)
 static inline s64 towards_target(struct virtio_balloon *vb)
 {
 	__le32 v;
-	s64 target;
+	s64 target, actual;
 
+	spin_lock(&vb->pages_lock);
+	actual = vb->num_pages;
 	vb->vdev->config->get(vb->vdev,
 			      offsetof(struct virtio_balloon_config, num_pages),
 			      &v, sizeof(v));
 	target = le32_to_cpu(v);
-	return target - vb->num_pages;
+	spin_unlock(&vb->pages_lock);
+	return target - actual;
 }
 
 static void update_balloon_size(struct virtio_balloon *vb)
 {
-	__le32 actual = cpu_to_le32(vb->num_pages);
+	__le32 actual;
+
+	spin_lock(&vb->pages_lock);
+	actual = cpu_to_le32(vb->num_pages);
 
 	vb->vdev->config->set(vb->vdev,
 			      offsetof(struct virtio_balloon_config, actual),
 			      &actual, sizeof(actual));
+	spin_unlock(&vb->pages_lock);
 }
 
 static int balloon(void *_vballoon)
@@ -339,9 +469,121 @@ static int init_vqs(struct virtio_balloon *vb)
 	return 0;
 }
 
+#ifdef CONFIG_BALLOON_COMPACTION
+/*
+ * virtballoon_isolatepage - perform the balloon page isolation on behalf of
+ *			     a compation thread.     (called under page lock)
+ * @page: the page to isolated from balloon's page list.
+ * @mode: not used for balloon page isolation.
+ *
+ * A memory compaction thread works by isolating pages from private lists,
+ * like LRUs or the balloon's page list (here), to a privative pageset that
+ * will be migrated subsequently. After the mentioned pageset gets isolated
+ * compaction relies on page migration procedures to do the heavy lifting.
+ *
+ * This function isolates a page from the balloon private page list.
+ * Called through balloon_mapping->a_ops.
+ */
+void virtballoon_isolatepage(struct page *page, unsigned long mode)
+{
+	struct virtio_balloon *vb = __page_balloon_device(page);
+
+	BUG_ON(!vb);
+
+	spin_lock(&vb->pages_lock);
+	list_del(&page->lru);
+	vb->num_isolated_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
+	spin_unlock(&vb->pages_lock);
+}
+
+/*
+ * virtballoon_migratepage - perform the balloon page migration on behalf of
+ *			     a compation thread.     (called under page lock)
+ * @mapping: the page->mapping which will be assigned to the new migrated page.
+ * @newpage: page that will replace the isolated page after migration finishes.
+ * @page   : the isolated (old) page that is about to be migrated to newpage.
+ * @mode   : compaction mode -- not used for balloon page migration.
+ *
+ * After a ballooned page gets isolated by compaction procedures, this is the
+ * function that performs the page migration on behalf of a compaction thread
+ * The page migration for virtio balloon is done in a simple swap fashion which
+ * follows these two macro steps:
+ *  1) insert newpage into vb->pages list and update the host about it;
+ *  2) update the host about the old page removed from vb->pages list;
+ *
+ * This function preforms the balloon page migration task.
+ * Called through balloon_mapping->a_ops.
+ */
+int virtballoon_migratepage(struct address_space *mapping,
+		struct page *newpage, struct page *page, enum migrate_mode mode)
+{
+	struct virtio_balloon *vb = __page_balloon_device(page);
+
+	BUG_ON(!vb);
+
+	mutex_lock(&vb->balloon_lock);
+
+	/* balloon's page migration 1st step */
+	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+	spin_lock(&vb->pages_lock);
+	list_add(&newpage->lru, &vb->pages);
+	assign_balloon_mapping(newpage, mapping);
+	vb->num_isolated_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
+	spin_unlock(&vb->pages_lock);
+	set_page_pfns(vb->pfns, newpage);
+	tell_host(vb, vb->inflate_vq);
+
+	/* balloon's page migration 2nd step */
+	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+	clear_balloon_mapping(page);
+	set_page_pfns(vb->pfns, page);
+	tell_host(vb, vb->deflate_vq);
+
+	mutex_unlock(&vb->balloon_lock);
+	wake_up(&vb->config_change);
+
+	return BALLOON_MIGRATION_RETURN;
+}
+
+/*
+ * virtballoon_putbackpage - insert an isolated page back into the list it was
+ *			     once taken off by a compaction thread.
+ *			     (called under page lock)
+ * @page: page that will be re-inserted into balloon page list.
+ *
+ * If for some reason, a compaction thread can not finish all its job in one
+ * round, and some isolated pages are still remaining at compaction's thread
+ * privative pageset (waiting for migration), then those pages will get
+ * re-inserted into their balloon private lists before compaction thread ends.
+ *
+ * This function inserts an isolated but not migrated balloon page
+ * back into private balloon list.
+ * Called through balloon_mapping->a_ops.
+ */
+void virtballoon_putbackpage(struct page *page)
+{
+	struct virtio_balloon *vb = __page_balloon_device(page);
+
+	BUG_ON(!vb);
+
+	spin_lock(&vb->pages_lock);
+	list_add(&page->lru, &vb->pages);
+	vb->num_isolated_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
+	spin_unlock(&vb->pages_lock);
+	wake_up(&vb->config_change);
+}
+#endif /* CONFIG_BALLOON_COMPACTION */
+
+/* define the balloon_mapping->a_ops callbacks to allow compaction/migration */
+static DEFINE_BALLOON_MAPPING_AOPS(virtio_balloon_aops,
+				   virtballoon_isolatepage,
+				   virtballoon_migratepage,
+				   virtballoon_putbackpage);
+
 static int virtballoon_probe(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb;
+	struct address_space *vb_mapping;
 	int err;
 
 	vdev->priv = vb = kmalloc(sizeof(*vb), GFP_KERNEL);
@@ -351,12 +593,25 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	}
 
 	INIT_LIST_HEAD(&vb->pages);
+	mutex_init(&vb->balloon_lock);
+	spin_lock_init(&vb->pages_lock);
+
 	vb->num_pages = 0;
+	vb->num_isolated_pages = 0;
 	init_waitqueue_head(&vb->config_change);
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
 	vb->need_stats_update = 0;
 
+	vb_mapping = alloc_balloon_mapping(vb, &virtio_balloon_aops);
+	if (IS_ERR(vb_mapping)) {
+		err = PTR_ERR(vb_mapping);
+		if (err != -EOPNOTSUPP)
+			goto out_free_vb;
+	}
+
+	vb->mapping = vb_mapping;
+
 	err = init_vqs(vb);
 	if (err)
 		goto out_free_vb;
@@ -372,16 +627,28 @@ static int virtballoon_probe(struct virtio_device *vdev)
 out_del_vqs:
 	vdev->config->del_vqs(vdev);
 out_free_vb:
+	free_balloon_mapping(vb_mapping);
 	kfree(vb);
 out:
 	return err;
 }
 
+static inline size_t __get_num_pages(struct virtio_balloon *vb)
+{
+	size_t num_pages;
+	spin_lock(&vb->pages_lock);
+	num_pages = vb->num_pages;
+	spin_unlock(&vb->pages_lock);
+	return num_pages;
+}
+
 static void remove_common(struct virtio_balloon *vb)
 {
+	size_t num_pages;
 	/* There might be pages left in the balloon: free them. */
-	while (vb->num_pages)
-		leak_balloon(vb, vb->num_pages);
+	while ((num_pages = __get_num_pages(vb)) > 0)
+		leak_balloon(vb, num_pages);
+
 	update_balloon_size(vb);
 
 	/* Now we reset the device so we can clean up the queues. */
@@ -396,6 +663,7 @@ static void __devexit virtballoon_remove(struct virtio_device *vdev)
 
 	kthread_stop(vb->thread);
 	remove_common(vb);
+	free_balloon_mapping(vb->mapping);
 	kfree(vb);
 }
 
@@ -408,7 +676,6 @@ static int virtballoon_freeze(struct virtio_device *vdev)
 	 * The kthread is already frozen by the PM core before this
 	 * function is called.
 	 */
-
 	remove_common(vb);
 	return 0;
 }
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
