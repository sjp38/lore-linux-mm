Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id E203A6B00A7
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 19:49:53 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v3 2/4] virtio_balloon: handle concurrent accesses to virtio_balloon struct elements
Date: Tue,  3 Jul 2012 20:48:50 -0300
Message-Id: <e5f3c6d456f04adeac9fd714a6278424d71a97a0.1341353014.git.aquini@redhat.com>
In-Reply-To: <cover.1341353014.git.aquini@redhat.com>
References: <cover.1341353014.git.aquini@redhat.com>
In-Reply-To: <cover.1341353014.git.aquini@redhat.com>
References: <cover.1341353014.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Rafael Aquini <aquini@redhat.com>

This patch introduces access sychronization to critical elements of struct
virtio_balloon, in order to allow the thread concurrency compaction/migration
bits might ended up imposing to the balloon driver on several situations.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 drivers/virtio/virtio_balloon.c |   45 +++++++++++++++++++++++++++++----------
 1 file changed, 34 insertions(+), 11 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index bfbc15c..d47c5c2 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -51,6 +51,10 @@ struct virtio_balloon
 
 	/* Number of balloon pages we've told the Host we're not using. */
 	unsigned int num_pages;
+
+	/* Protect 'pages', 'pfns' & 'num_pnfs' against concurrent updates */
+	spinlock_t pfn_list_lock;
+
 	/*
 	 * The pages we've told the Host we're not using.
 	 * Each page on this list adds VIRTIO_BALLOON_PAGES_PER_PAGE
@@ -97,21 +101,23 @@ static void balloon_ack(struct virtqueue *vq)
 		complete(&vb->acked);
 }
 
-static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
-{
-	struct scatterlist sg;
-
-	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+/* Protection for concurrent accesses to balloon virtqueues and vb->acked */
+DEFINE_MUTEX(vb_queue_completion);
 
+static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq,
+		      struct scatterlist *sg)
+{
+	mutex_lock(&vb_queue_completion);
 	init_completion(&vb->acked);
 
 	/* We should always be able to add one buffer to an empty queue. */
-	if (virtqueue_add_buf(vq, &sg, 1, 0, vb, GFP_KERNEL) < 0)
+	if (virtqueue_add_buf(vq, sg, 1, 0, vb, GFP_KERNEL) < 0)
 		BUG();
 	virtqueue_kick(vq);
 
 	/* When host has read buffer, this completes via balloon_ack */
 	wait_for_completion(&vb->acked);
+	mutex_unlock(&vb_queue_completion);
 }
 
 static void set_page_pfns(u32 pfns[], struct page *page)
@@ -126,9 +132,12 @@ static void set_page_pfns(u32 pfns[], struct page *page)
 
 static void fill_balloon(struct virtio_balloon *vb, size_t num)
 {
+	struct scatterlist sg;
+	int alloc_failed = 0;
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
+	spin_lock(&vb->pfn_list_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
 	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
 		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY |
@@ -138,8 +147,7 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 				dev_printk(KERN_INFO, &vb->vdev->dev,
 					   "Out of puff! Can't get %zu pages\n",
 					   num);
-			/* Sleep for at least 1/5 of a second before retry. */
-			msleep(200);
+			alloc_failed = 1;
 			break;
 		}
 		set_page_pfns(vb->pfns + vb->num_pfns, page);
@@ -149,10 +157,19 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 	}
 
 	/* Didn't get any?  Oh well. */
-	if (vb->num_pfns == 0)
+	if (vb->num_pfns == 0) {
+		spin_unlock(&vb->pfn_list_lock);
 		return;
+	}
+
+	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+	spin_unlock(&vb->pfn_list_lock);
 
-	tell_host(vb, vb->inflate_vq);
+	/* alloc_page failed, sleep for at least 1/5 of a sec before retry. */
+	if (alloc_failed)
+		msleep(200);
+
+	tell_host(vb, vb->inflate_vq, &sg);
 }
 
 static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
@@ -169,10 +186,12 @@ static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
 static void leak_balloon(struct virtio_balloon *vb, size_t num)
 {
 	struct page *page;
+	struct scatterlist sg;
 
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
+	spin_lock(&vb->pfn_list_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
 	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
 		page = list_first_entry(&vb->pages, struct page, lru);
@@ -180,13 +199,15 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
 		set_page_pfns(vb->pfns + vb->num_pfns, page);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
+	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+	spin_unlock(&vb->pfn_list_lock);
 
 	/*
 	 * Note that if
 	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
 	 * is true, we *have* to do it in this order
 	 */
-	tell_host(vb, vb->deflate_vq);
+	tell_host(vb, vb->deflate_vq, &sg);
 	release_pages_by_pfn(vb->pfns, vb->num_pfns);
 }
 
@@ -356,6 +377,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	}
 
 	INIT_LIST_HEAD(&vb->pages);
+	spin_lock_init(&vb->pfn_list_lock);
+
 	vb->num_pages = 0;
 	init_waitqueue_head(&vb->config_change);
 	vb->vdev = vdev;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
