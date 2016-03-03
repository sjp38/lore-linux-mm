Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2883D828E5
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:53:24 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id 63so13009968pfe.3
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:53:24 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 7si64960825pfm.127.2016.03.03.02.53.23
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 02:53:23 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [RFC kernel 2/2] virtio-balloon: extend balloon driver to support a new feature
Date: Thu,  3 Mar 2016 18:46:59 +0800
Message-Id: <1457002019-15998-3-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1457002019-15998-1-git-send-email-liang.z.li@intel.com>
References: <1457002019-15998-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, pbonzini@redhat.com, rth@twiddle.net, ehabkost@redhat.com, quintela@redhat.com, amit.shah@redhat.com, qemu-devel@nongnu.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, dgilbert@redhat.com, Liang Li <liang.z.li@intel.com>

Extend the virio balloon to support the new feature
VIRTIO_BALLOON_F_GET_FREE_PAGES, so that we can use it to send the
free pages information from guest to QEMU, and then optimize the
live migration process.

Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 drivers/virtio/virtio_balloon.c     | 106 ++++++++++++++++++++++++++++++++++--
 include/uapi/linux/virtio_balloon.h |   1 +
 2 files changed, 102 insertions(+), 5 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 0c3691f..7461d3e 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -45,9 +45,18 @@ static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
 module_param(oom_pages, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
 
+extern void get_free_pages(unsigned long *free_page_bitmap,
+			unsigned long *free_pages_num,
+			unsigned long lowmem);
+extern unsigned long get_total_pages_count(unsigned long lowmem);
+
+struct mem_layout {
+	unsigned long low_mem;
+};
+
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_pages_vq;
 
 	/* Where the ballooning thread waits for config to change. */
 	wait_queue_head_t config_change;
@@ -75,6 +84,11 @@ struct virtio_balloon {
 	unsigned int num_pfns;
 	u32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
 
+	unsigned long *free_pages;
+	unsigned long free_pages_len;
+	unsigned long free_pages_num;
+	struct mem_layout mem_config;
+
 	/* Memory statistics */
 	int need_stats_update;
 	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
@@ -245,6 +259,34 @@ static void update_balloon_stats(struct virtio_balloon *vb)
 				pages_to_bytes(i.totalram));
 }
 
+static void update_free_pages_stats(struct virtio_balloon *vb)
+{
+	unsigned long total_page_count, bitmap_bytes;
+
+	total_page_count = get_total_pages_count(vb->mem_config.low_mem);
+	bitmap_bytes = ALIGN(total_page_count, BITS_PER_LONG) / 8;
+
+	if (!vb->free_pages)
+		vb->free_pages = kzalloc(bitmap_bytes, GFP_KERNEL);
+	else {
+		if (bitmap_bytes < vb->free_pages_len)
+			memset(vb->free_pages, 0, bitmap_bytes);
+		else {
+			kfree(vb->free_pages);
+			vb->free_pages = kzalloc(bitmap_bytes, GFP_KERNEL);
+		}
+	}
+	if (!vb->free_pages) {
+		vb->free_pages_len = 0;
+		vb->free_pages_num = 0;
+		return;
+	}
+
+	vb->free_pages_len = bitmap_bytes;
+	get_free_pages(vb->free_pages, &vb->free_pages_num,
+		       vb->mem_config.low_mem);
+}
+
 /*
  * While most virtqueues communicate guest-initiated requests to the hypervisor,
  * the stats queue operates in reverse.  The driver initializes the virtqueue
@@ -278,6 +320,39 @@ static void stats_handle_request(struct virtio_balloon *vb)
 	virtqueue_kick(vq);
 }
 
+static void free_pages_handle_rq(struct virtio_balloon *vb)
+{
+	struct virtqueue *vq;
+	struct scatterlist sg[3];
+	unsigned int len;
+	struct mem_layout *ptr_mem_layout;
+	struct scatterlist sg_in;
+
+	vq = vb->free_pages_vq;
+	ptr_mem_layout = virtqueue_get_buf(vq, &len);
+
+	if (!ptr_mem_layout)
+		return;
+	update_free_pages_stats(vb);
+	sg_init_table(sg, 3);
+	sg_set_buf(&sg[0], &(vb->free_pages_num), sizeof(vb->free_pages_num));
+	sg_set_buf(&sg[1], &(vb->free_pages_len), sizeof(vb->free_pages_len));
+	sg_set_buf(&sg[2], vb->free_pages, vb->free_pages_len);
+
+	sg_init_one(&sg_in, &vb->mem_config, sizeof(vb->mem_config));
+
+	virtqueue_add_outbuf(vq, &sg[0], 3, vb, GFP_KERNEL);
+	virtqueue_add_inbuf(vq, &sg_in, 1, &vb->mem_config, GFP_KERNEL);
+	virtqueue_kick(vq);
+}
+
+static void free_pages_rq(struct virtqueue *vq)
+{
+	struct virtio_balloon *vb = vq->vdev->priv;
+
+	free_pages_handle_rq(vb);
+}
+
 static void virtballoon_changed(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb = vdev->priv;
@@ -386,16 +461,22 @@ static int balloon(void *_vballoon)
 
 static int init_vqs(struct virtio_balloon *vb)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
-	static const char * const names[] = { "inflate", "deflate", "stats" };
+	struct virtqueue *vqs[4];
+	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack,
+					 stats_request, free_pages_rq };
+	const char *names[] = { "inflate", "deflate", "stats", "free_pages" };
 	int err, nvqs;
 
 	/*
 	 * We expect two virtqueues: inflate and deflate, and
 	 * optionally stat.
 	 */
-	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_GET_FREE_PAGES))
+		nvqs = 4;
+	else
+		nvqs = virtio_has_feature(vb->vdev,
+					  VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
+
 	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names);
 	if (err)
 		return err;
@@ -416,6 +497,16 @@ static int init_vqs(struct virtio_balloon *vb)
 			BUG();
 		virtqueue_kick(vb->stats_vq);
 	}
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_GET_FREE_PAGES)) {
+		struct scatterlist sg_in;
+
+		vb->free_pages_vq = vqs[3];
+		sg_init_one(&sg_in, &vb->mem_config, sizeof(vb->mem_config));
+		if (virtqueue_add_inbuf(vb->free_pages_vq, &sg_in, 1,
+		    &vb->mem_config, GFP_KERNEL) < 0)
+			BUG();
+		virtqueue_kick(vb->free_pages_vq);
+	}
 	return 0;
 }
 
@@ -505,6 +596,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
 	vb->need_stats_update = 0;
+	vb->free_pages_num = 0;
+	vb->free_pages_len = 0;
+	vb->free_pages = NULL;
 
 	balloon_devinfo_init(&vb->vb_dev_info);
 #ifdef CONFIG_BALLOON_COMPACTION
@@ -561,6 +655,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	unregister_oom_notifier(&vb->nb);
 	kthread_stop(vb->thread);
 	remove_common(vb);
+	kfree(vb->free_pages);
 	kfree(vb);
 }
 
@@ -599,6 +694,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_GET_FREE_PAGES,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index d7f1cbc..54aaf20 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -34,6 +34,7 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_GET_FREE_PAGES	3 /* Get free pages bitmap */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
