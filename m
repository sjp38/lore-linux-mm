Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 768BB6B0008
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 01:08:42 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id n3-v6so2936274pgp.21
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 22:08:42 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m89-v6si6984006pfi.236.2018.06.14.22.08.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jun 2018 22:08:41 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v33 2/4] virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
Date: Fri, 15 Jun 2018 12:43:11 +0800
Message-Id: <1529037793-35521-3-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

Negotiation of the VIRTIO_BALLOON_F_FREE_PAGE_HINT feature indicates the
support of reporting hints of guest free pages to host via virtio-balloon.

Host requests the guest to report free page hints by sending a command
to the guest via setting the VIRTIO_BALLOON_HOST_CMD_FREE_PAGE_HINT bit
of the host_cmd config register.

As the first step here, virtio-balloon only reports free page hints from
the max order (10) free page list to host. This has generated similar good
results as reporting all free page hints during our tests.

TODO:
- support reporting free page hints from smaller order free page lists
  when there is a need/request from users.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 drivers/virtio/virtio_balloon.c     | 187 +++++++++++++++++++++++++++++-------
 include/uapi/linux/virtio_balloon.h |  13 +++
 2 files changed, 163 insertions(+), 37 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 6b237e3..582a03b 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -43,6 +43,9 @@
 #define OOM_VBALLOON_DEFAULT_PAGES 256
 #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
 
+/* The size of memory in bytes allocated for reporting free page hints */
+#define FREE_PAGE_HINT_MEM_SIZE (PAGE_SIZE * 16)
+
 static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
 module_param(oom_pages, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
@@ -51,9 +54,22 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
 static struct vfsmount *balloon_mnt;
 #endif
 
+enum virtio_balloon_vq {
+	VIRTIO_BALLOON_VQ_INFLATE,
+	VIRTIO_BALLOON_VQ_DEFLATE,
+	VIRTIO_BALLOON_VQ_STATS,
+	VIRTIO_BALLOON_VQ_FREE_PAGE,
+	VIRTIO_BALLOON_VQ_MAX
+};
+
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
+
+	/* Balloon's own wq for cpu-intensive work items */
+	struct workqueue_struct *balloon_wq;
+	/* The free page reporting work item submitted to the balloon wq */
+	struct work_struct report_free_page_work;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
@@ -63,6 +79,8 @@ struct virtio_balloon {
 	spinlock_t stop_update_lock;
 	bool stop_update;
 
+	struct virtio_balloon_free_page_hints *hints;
+
 	/* Waiting for host to ack the pages we released. */
 	wait_queue_head_t acked;
 
@@ -326,17 +344,6 @@ static void stats_handle_request(struct virtio_balloon *vb)
 	virtqueue_kick(vq);
 }
 
-static void virtballoon_changed(struct virtio_device *vdev)
-{
-	struct virtio_balloon *vb = vdev->priv;
-	unsigned long flags;
-
-	spin_lock_irqsave(&vb->stop_update_lock, flags);
-	if (!vb->stop_update)
-		queue_work(system_freezable_wq, &vb->update_balloon_size_work);
-	spin_unlock_irqrestore(&vb->stop_update_lock, flags);
-}
-
 static inline s64 towards_target(struct virtio_balloon *vb)
 {
 	s64 target;
@@ -353,6 +360,32 @@ static inline s64 towards_target(struct virtio_balloon *vb)
 	return target - vb->num_pages;
 }
 
+static void virtballoon_changed(struct virtio_device *vdev)
+{
+	struct virtio_balloon *vb = vdev->priv;
+	unsigned long flags;
+	uint32_t host_cmd;
+	s64 diff = towards_target(vb);
+
+	if (diff) {
+		spin_lock_irqsave(&vb->stop_update_lock, flags);
+		if (!vb->stop_update)
+			queue_work(system_freezable_wq,
+				   &vb->update_balloon_size_work);
+		spin_unlock_irqrestore(&vb->stop_update_lock, flags);
+	}
+
+	virtio_cread(vdev, struct virtio_balloon_config, host_cmd, &host_cmd);
+	if ((host_cmd & VIRTIO_BALLOON_HOST_CMD_FREE_PAGE_HINT) &&
+	     virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+		spin_lock_irqsave(&vb->stop_update_lock, flags);
+		if (!vb->stop_update)
+			queue_work(vb->balloon_wq,
+				   &vb->report_free_page_work);
+		spin_unlock_irqrestore(&vb->stop_update_lock, flags);
+	}
+}
+
 static void update_balloon_size(struct virtio_balloon *vb)
 {
 	u32 actual = vb->num_pages;
@@ -425,44 +458,98 @@ static void update_balloon_size_func(struct work_struct *work)
 		queue_work(system_freezable_wq, work);
 }
 
+static void free_page_vq_cb(struct virtqueue *vq)
+{
+	unsigned int unused;
+
+	while (virtqueue_get_buf(vq, &unused))
+		;
+}
+
 static int init_vqs(struct virtio_balloon *vb)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
-	static const char * const names[] = { "inflate", "deflate", "stats" };
-	int err, nvqs;
+	struct virtqueue *vqs[VIRTIO_BALLOON_VQ_MAX];
+	vq_callback_t *callbacks[VIRTIO_BALLOON_VQ_MAX];
+	const char *names[VIRTIO_BALLOON_VQ_MAX];
+	struct scatterlist sg;
+	int ret;
 
 	/*
-	 * We expect two virtqueues: inflate and deflate, and
-	 * optionally stat.
+	 * Inflateq and deflateq are used unconditionally. The names[]
+	 * will be NULL if the related feature is not enabled, which will
+	 * cause no allocation for the corresponding virtqueue in find_vqs.
 	 */
-	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
-	err = virtio_find_vqs(vb->vdev, nvqs, vqs, callbacks, names, NULL);
-	if (err)
-		return err;
+	callbacks[VIRTIO_BALLOON_VQ_INFLATE] = balloon_ack;
+	names[VIRTIO_BALLOON_VQ_INFLATE] = "inflate";
+	callbacks[VIRTIO_BALLOON_VQ_DEFLATE] = balloon_ack;
+	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
+	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
+	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
 
-	vb->inflate_vq = vqs[0];
-	vb->deflate_vq = vqs[1];
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
-		struct scatterlist sg;
-		unsigned int num_stats;
-		vb->stats_vq = vqs[2];
+		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
+		callbacks[VIRTIO_BALLOON_VQ_STATS] = stats_request;
+	}
 
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+		names[VIRTIO_BALLOON_VQ_FREE_PAGE] = "free_page_vq";
+		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = free_page_vq_cb;
+	}
+
+	ret = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
+					 vqs, callbacks, names, NULL, NULL);
+	if (ret)
+		return ret;
+
+	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
+	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
+		vb->stats_vq = vqs[VIRTIO_BALLOON_VQ_STATS];
 		/*
 		 * Prime this virtqueue with one buffer so the hypervisor can
 		 * use it to signal us later (it can't be broken yet!).
 		 */
-		num_stats = update_balloon_stats(vb);
-
-		sg_init_one(&sg, vb->stats, sizeof(vb->stats[0]) * num_stats);
-		if (virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb, GFP_KERNEL)
-		    < 0)
-			BUG();
+		sg_init_one(&sg, vb->stats, sizeof(vb->stats));
+		ret = virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb,
+					   GFP_KERNEL);
+		if (ret) {
+			dev_warn(&vb->vdev->dev, "%s: add stat_vq failed\n",
+				 __func__);
+			return ret;
+		}
 		virtqueue_kick(vb->stats_vq);
 	}
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
+		vb->free_page_vq = vqs[VIRTIO_BALLOON_VQ_FREE_PAGE];
+
 	return 0;
 }
 
+static void report_free_page_func(struct work_struct *work)
+{
+	struct virtio_balloon *vb;
+	struct virtqueue *vq;
+	struct virtio_balloon_free_page_hints *hints;
+	struct scatterlist sg;
+	uint32_t hdr_size, avail_entries, added_entries;
+
+	vb = container_of(work, struct virtio_balloon, report_free_page_work);
+	vq = vb->free_page_vq;
+	hints = vb->hints;
+	hdr_size = sizeof(hints->num_hints) + sizeof(hints->size);
+	avail_entries = (FREE_PAGE_HINT_MEM_SIZE - hdr_size) / sizeof(__le64);
+
+	added_entries = get_from_free_page_list(MAX_ORDER - 1, hints->buf,
+						avail_entries);
+	hints->num_hints = cpu_to_le32(added_entries);
+	hints->size = cpu_to_le32((1 << (MAX_ORDER - 1)) << PAGE_SHIFT);
+
+	sg_init_one(&sg, vb->hints, FREE_PAGE_HINT_MEM_SIZE);
+	virtqueue_add_outbuf(vq, &sg, 1, vb->hints, GFP_KERNEL);
+	virtqueue_kick(vb->free_page_vq);
+}
+
 #ifdef CONFIG_BALLOON_COMPACTION
 /*
  * virtballoon_migratepage - perform the balloon page migration on behalf of
@@ -576,18 +663,33 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (err)
 		goto out_free_vb;
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+		vb->balloon_wq = alloc_workqueue("balloon-wq",
+					WQ_FREEZABLE | WQ_CPU_INTENSIVE, 0);
+		if (!vb->balloon_wq) {
+			err = -ENOMEM;
+			goto out_del_vqs;
+		}
+		INIT_WORK(&vb->report_free_page_work, report_free_page_func);
+		vb->hints = kmalloc(FREE_PAGE_HINT_MEM_SIZE, GFP_KERNEL);
+		if (!vb->hints) {
+			err = -ENOMEM;
+			goto out_del_balloon_wq;
+		}
+	}
+
 	vb->nb.notifier_call = virtballoon_oom_notify;
 	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
 	err = register_oom_notifier(&vb->nb);
 	if (err < 0)
-		goto out_del_vqs;
+		goto out_del_free_page_hint;
 
 #ifdef CONFIG_BALLOON_COMPACTION
 	balloon_mnt = kern_mount(&balloon_fs);
 	if (IS_ERR(balloon_mnt)) {
 		err = PTR_ERR(balloon_mnt);
 		unregister_oom_notifier(&vb->nb);
-		goto out_del_vqs;
+		goto out_del_free_page_hint;
 	}
 
 	vb->vb_dev_info.migratepage = virtballoon_migratepage;
@@ -597,7 +699,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		kern_unmount(balloon_mnt);
 		unregister_oom_notifier(&vb->nb);
 		vb->vb_dev_info.inode = NULL;
-		goto out_del_vqs;
+		goto out_del_free_page_hint;
 	}
 	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
 #endif
@@ -607,7 +709,12 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (towards_target(vb))
 		virtballoon_changed(vdev);
 	return 0;
-
+out_del_free_page_hint:
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
+		kfree(vb->hints);
+out_del_balloon_wq:
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
+		destroy_workqueue(vb->balloon_wq);
 out_del_vqs:
 	vdev->config->del_vqs(vdev);
 out_free_vb:
@@ -641,6 +748,11 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	cancel_work_sync(&vb->update_balloon_size_work);
 	cancel_work_sync(&vb->update_balloon_stats_work);
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+		cancel_work_sync(&vb->report_free_page_work);
+		destroy_workqueue(vb->balloon_wq);
+	}
+
 	remove_common(vb);
 #ifdef CONFIG_BALLOON_COMPACTION
 	if (vb->vb_dev_info.inode)
@@ -692,6 +804,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 13b8cb5..99b8416 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -34,15 +34,28 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
 
+#define VIRTIO_BALLOON_HOST_CMD_FREE_PAGE_HINT (1 << 0)
 struct virtio_balloon_config {
 	/* Number of pages host wants Guest to give up. */
 	__u32 num_pages;
 	/* Number of pages we've actually got in balloon. */
 	__u32 actual;
+	/* Command sent from host */
+	__u32 host_cmd;
+};
+
+struct virtio_balloon_free_page_hints {
+	/* Number of hints in the array below */
+	__le32 num_hints;
+	/* The size of each hint in bytes */
+	__le32 size;
+	/* Buffer for the hints */
+	__le64 buf[];
 };
 
 #define VIRTIO_BALLOON_S_SWAP_IN  0   /* Amount of memory swapped in */
-- 
2.7.4
