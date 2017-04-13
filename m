Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D18E6B03A4
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:40:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id m89so28558158pfi.14
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:40:19 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q7si23444825pfq.336.2017.04.13.02.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 02:40:18 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v9 5/5] virtio-balloon: VIRTIO_BALLOON_F_MISC_VQ
Date: Thu, 13 Apr 2017 17:35:08 +0800
Message-Id: <1492076108-117229-6-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

Add a new vq, miscq, to handle miscellaneous requests between the device
and the driver.

This patch implemnts the VIRTIO_BALLOON_MISCQ_INQUIRE_UNUSED_PAGES
request sent from the device. Upon receiving this request from the
miscq, the driver offers to the device the guest unused pages.

Tests have shown that skipping the transfer of unused pages of a 32G
guest can get the live migration time reduced to 1/8.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 drivers/virtio/virtio_balloon.c     | 209 +++++++++++++++++++++++++++++++++---
 include/uapi/linux/virtio_balloon.h |   8 ++
 2 files changed, 204 insertions(+), 13 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 5e2e7cc..95c703e 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -56,11 +56,12 @@ static struct vfsmount *balloon_mnt;
 
 /* Types of pages to chunk */
 #define PAGE_CHUNK_TYPE_BALLOON 0
+#define PAGE_CHUNK_TYPE_UNUSED 1
 
 #define MAX_PAGE_CHUNKS 4096
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *miscq;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
@@ -94,6 +95,19 @@ struct virtio_balloon {
 	struct virtio_balloon_page_chunk_hdr *balloon_page_chunk_hdr;
 	struct virtio_balloon_page_chunk *balloon_page_chunk;
 
+	/*
+	 * Buffer for PAGE_CHUNK_TYPE_UNUSED:
+	 * virtio_balloon_miscq_hdr +
+	 * virtio_balloon_page_chunk_hdr +
+	 * virtio_balloon_page_chunk * MAX_PAGE_CHUNKS
+	 */
+	struct virtio_balloon_miscq_hdr *miscq_out_hdr;
+	struct virtio_balloon_page_chunk_hdr *unused_page_chunk_hdr;
+	struct virtio_balloon_page_chunk *unused_page_chunk;
+
+	/* Buffer for host to send cmd to miscq */
+	struct virtio_balloon_miscq_hdr *miscq_in_hdr;
+
 	/* Bitmap used to record pages */
 	unsigned long *page_bmap[PAGE_BMAP_COUNT_MAX];
 	/* Number of the allocated page_bmap */
@@ -220,6 +234,10 @@ static void send_page_chunks(struct virtio_balloon *vb, struct virtqueue *vq,
 		hdr = vb->balloon_page_chunk_hdr;
 		len = 0;
 		break;
+	case PAGE_CHUNK_TYPE_UNUSED:
+		hdr = vb->unused_page_chunk_hdr;
+		len = sizeof(struct virtio_balloon_miscq_hdr);
+		break;
 	default:
 		dev_warn(&vb->vdev->dev, "%s: chunk %d of unknown pages\n",
 			 __func__, type);
@@ -254,6 +272,10 @@ static void add_one_chunk(struct virtio_balloon *vb, struct virtqueue *vq,
 		hdr = vb->balloon_page_chunk_hdr;
 		chunk = vb->balloon_page_chunk;
 		break;
+	case PAGE_CHUNK_TYPE_UNUSED:
+		hdr = vb->unused_page_chunk_hdr;
+		chunk = vb->unused_page_chunk;
+		break;
 	default:
 		dev_warn(&vb->vdev->dev, "%s: chunk %d of unknown pages\n",
 			 __func__, type);
@@ -686,28 +708,139 @@ static void update_balloon_size_func(struct work_struct *work)
 		queue_work(system_freezable_wq, work);
 }
 
+static void miscq_in_hdr_add(struct virtio_balloon *vb)
+{
+	struct scatterlist sg_in;
+
+	sg_init_one(&sg_in, vb->miscq_in_hdr,
+		    sizeof(struct virtio_balloon_miscq_hdr));
+	if (virtqueue_add_inbuf(vb->miscq, &sg_in, 1, vb->miscq_in_hdr,
+	    GFP_KERNEL) < 0) {
+		__virtio_clear_bit(vb->vdev,
+				   VIRTIO_BALLOON_F_MISC_VQ);
+		dev_warn(&vb->vdev->dev, "%s: add miscq_in_hdr err\n",
+			 __func__);
+		return;
+	}
+	virtqueue_kick(vb->miscq);
+}
+
+static void miscq_send_unused_pages(struct virtio_balloon *vb)
+{
+	struct virtio_balloon_miscq_hdr *miscq_out_hdr = vb->miscq_out_hdr;
+	struct virtqueue *vq = vb->miscq;
+	int ret = 0;
+	unsigned int order = 0, migratetype = 0;
+	struct zone *zone = NULL;
+	struct page *page = NULL;
+	u64 pfn;
+
+	miscq_out_hdr->cmd =  VIRTIO_BALLOON_MISCQ_INQUIRE_UNUSED_PAGES;
+	miscq_out_hdr->flags = 0;
+
+	for_each_populated_zone(zone) {
+		for (order = MAX_ORDER - 1; order > 0; order--) {
+			for (migratetype = 0; migratetype < MIGRATE_TYPES;
+			     migratetype++) {
+				do {
+					ret = inquire_unused_page_block(zone,
+						order, migratetype, &page);
+					if (!ret) {
+						pfn = (u64)page_to_pfn(page);
+						add_one_chunk(vb, vq,
+							PAGE_CHUNK_TYPE_UNUSED,
+							pfn,
+							(u64)(1 << order));
+					}
+				} while (!ret);
+			}
+		}
+	}
+	miscq_out_hdr->flags |= VIRTIO_BALLOON_MISCQ_F_COMPLETE;
+	send_page_chunks(vb, vq, PAGE_CHUNK_TYPE_UNUSED, true);
+}
+
+static void miscq_handle(struct virtqueue *vq)
+{
+	struct virtio_balloon *vb = vq->vdev->priv;
+	struct virtio_balloon_miscq_hdr *hdr;
+	unsigned int len;
+
+	hdr = virtqueue_get_buf(vb->miscq, &len);
+	if (!hdr || len != sizeof(struct virtio_balloon_miscq_hdr)) {
+		dev_warn(&vb->vdev->dev, "%s: invalid miscq hdr len\n",
+			 __func__);
+		miscq_in_hdr_add(vb);
+		return;
+	}
+	switch (hdr->cmd) {
+	case VIRTIO_BALLOON_MISCQ_INQUIRE_UNUSED_PAGES:
+		miscq_send_unused_pages(vb);
+		break;
+	default:
+		dev_warn(&vb->vdev->dev, "%s: miscq cmd %d not supported\n",
+			 __func__, hdr->cmd);
+	}
+	miscq_in_hdr_add(vb);
+}
+
 static int init_vqs(struct virtio_balloon *vb)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
-	static const char * const names[] = { "inflate", "deflate", "stats" };
-	int err, nvqs;
+	struct virtqueue **vqs;
+	vq_callback_t **callbacks;
+	const char **names;
+	int err = -ENOMEM;
+	int i, nvqs;
+
+	 /* Inflateq and deflateq are used unconditionally */
+	nvqs = 2;
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
+		nvqs++;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_MISC_VQ))
+		nvqs++;
+
+	/* Allocate space for find_vqs parameters */
+	vqs = kcalloc(nvqs, sizeof(*vqs), GFP_KERNEL);
+	if (!vqs)
+		goto err_vq;
+	callbacks = kmalloc_array(nvqs, sizeof(*callbacks), GFP_KERNEL);
+	if (!callbacks)
+		goto err_callback;
+	names = kmalloc_array(nvqs, sizeof(*names), GFP_KERNEL);
+	if (!names)
+		goto err_names;
+
+	callbacks[0] = balloon_ack;
+	names[0] = "inflate";
+	callbacks[1] = balloon_ack;
+	names[1] = "deflate";
+
+	i = 2;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
+		callbacks[i] = stats_request;
+		names[i] = "stats";
+		i++;
+	}
 
-	/*
-	 * We expect two virtqueues: inflate and deflate, and
-	 * optionally stat.
-	 */
-	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
-	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names);
+	if (virtio_has_feature(vb->vdev,
+				      VIRTIO_BALLOON_F_MISC_VQ)) {
+		callbacks[i] = miscq_handle;
+		names[i] = "miscq";
+	}
+
+	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks,
+					 names);
 	if (err)
-		return err;
+		goto err_find;
 
 	vb->inflate_vq = vqs[0];
 	vb->deflate_vq = vqs[1];
+	i = 2;
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
 		struct scatterlist sg;
-		vb->stats_vq = vqs[2];
 
+		vb->stats_vq = vqs[i++];
 		/*
 		 * Prime this virtqueue with one buffer so the hypervisor can
 		 * use it to signal us later (it can't be broken yet!).
@@ -718,7 +851,25 @@ static int init_vqs(struct virtio_balloon *vb)
 			BUG();
 		virtqueue_kick(vb->stats_vq);
 	}
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_MISC_VQ)) {
+		vb->miscq = vqs[i];
+		miscq_in_hdr_add(vb);
+	}
+
+	kfree(names);
+	kfree(callbacks);
+	kfree(vqs);
 	return 0;
+
+err_find:
+	kfree(names);
+err_names:
+	kfree(callbacks);
+err_callback:
+	kfree(vqs);
+err_vq:
+	return err;
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
@@ -843,6 +994,32 @@ static void balloon_page_chunk_init(struct virtio_balloon *vb)
 	}
 }
 
+static void miscq_init(struct virtio_balloon *vb)
+{
+	void *buf;
+
+	vb->miscq_in_hdr = kmalloc(sizeof(struct virtio_balloon_miscq_hdr),
+				   GFP_KERNEL);
+	buf = kmalloc(sizeof(struct virtio_balloon_miscq_hdr) +
+		      sizeof(struct virtio_balloon_page_chunk_hdr) +
+		      sizeof(struct virtio_balloon_page_chunk) *
+		      MAX_PAGE_CHUNKS, GFP_KERNEL);
+	if (!vb->miscq_in_hdr || !buf) {
+		kfree(buf);
+		kfree(vb->miscq_in_hdr);
+		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_MISC_VQ);
+		dev_warn(&vb->vdev->dev, "%s: failed\n", __func__);
+	} else {
+		vb->miscq_out_hdr = buf;
+		vb->unused_page_chunk_hdr = buf +
+				sizeof(struct virtio_balloon_miscq_hdr);
+		vb->unused_page_chunk_hdr->chunks = 0;
+		vb->unused_page_chunk = buf +
+				sizeof(struct virtio_balloon_miscq_hdr) +
+				sizeof(struct virtio_balloon_page_chunk_hdr);
+	}
+}
+
 static int virtballoon_probe(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb;
@@ -869,6 +1046,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_BALLOON_CHUNKS))
 		balloon_page_chunk_init(vb);
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_MISC_VQ))
+		miscq_init(vb);
+
 	mutex_init(&vb->balloon_lock);
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
@@ -946,6 +1126,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
 
 	remove_common(vb);
 	free_page_bmap(vb);
+	kfree(vb->miscq_out_hdr);
+	kfree(vb->miscq_in_hdr);
 	if (vb->vb_dev_info.inode)
 		iput(vb->vb_dev_info.inode);
 	kfree(vb);
@@ -987,6 +1169,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_BALLOON_CHUNKS,
+	VIRTIO_BALLOON_F_MISC_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index be317b7..96bdc86 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -35,6 +35,7 @@
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_BALLOON_CHUNKS 3 /* Inflate/Deflate pages in chunks */
+#define VIRTIO_BALLOON_F_MISC_VQ	4 /* Virtqueue for misc. requests */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -95,4 +96,11 @@ struct virtio_balloon_page_chunk {
 	__le64 size;
 };
 
+#define VIRTIO_BALLOON_MISCQ_INQUIRE_UNUSED_PAGES 0
+#define VIRTIO_BALLOON_MISCQ_F_COMPLETE 0x1
+struct virtio_balloon_miscq_hdr {
+	__le16 cmd;
+	__le16 flags;
+};
+
 #endif /* _LINUX_VIRTIO_BALLOON_H */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
