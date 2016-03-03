Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9873F6B0258
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:50:44 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id w128so13219766pfb.2
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:50:44 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id q78si64938993pfa.198.2016.03.03.02.50.43
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 02:50:43 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [RFC qemu 2/4] virtio-balloon: Add a new feature to balloon device
Date: Thu,  3 Mar 2016 18:44:26 +0800
Message-Id: <1457001868-15949-3-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: quintela@redhat.com, amit.shah@redhat.com, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org
Cc: mst@redhat.com, akpm@linux-foundation.org, pbonzini@redhat.com, rth@twiddle.net, ehabkost@redhat.com, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, dgilbert@redhat.com, Liang Li <liang.z.li@intel.com>

Extend the virtio balloon device to support a new feature, this
new feature can help to get guest's free pages information, which
can be used for live migration optimzation.

Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 balloon.c                                       | 30 ++++++++-
 hw/virtio/virtio-balloon.c                      | 81 ++++++++++++++++++++++++-
 include/hw/virtio/virtio-balloon.h              | 17 +++++-
 include/standard-headers/linux/virtio_balloon.h |  1 +
 include/sysemu/balloon.h                        | 10 ++-
 5 files changed, 134 insertions(+), 5 deletions(-)

diff --git a/balloon.c b/balloon.c
index f2ef50c..a37717e 100644
--- a/balloon.c
+++ b/balloon.c
@@ -36,6 +36,7 @@
 
 static QEMUBalloonEvent *balloon_event_fn;
 static QEMUBalloonStatus *balloon_stat_fn;
+static QEMUBalloonFreePages *balloon_free_pages_fn;
 static void *balloon_opaque;
 static bool balloon_inhibited;
 
@@ -65,9 +66,12 @@ static bool have_balloon(Error **errp)
 }
 
 int qemu_add_balloon_handler(QEMUBalloonEvent *event_func,
-                             QEMUBalloonStatus *stat_func, void *opaque)
+                             QEMUBalloonStatus *stat_func,
+                             QEMUBalloonFreePages *free_pages_func,
+                             void *opaque)
 {
-    if (balloon_event_fn || balloon_stat_fn || balloon_opaque) {
+    if (balloon_event_fn || balloon_stat_fn || balloon_free_pages_fn
+        || balloon_opaque) {
         /* We're already registered one balloon handler.  How many can
          * a guest really have?
          */
@@ -75,6 +79,7 @@ int qemu_add_balloon_handler(QEMUBalloonEvent *event_func,
     }
     balloon_event_fn = event_func;
     balloon_stat_fn = stat_func;
+    balloon_free_pages_fn = free_pages_func;
     balloon_opaque = opaque;
     return 0;
 }
@@ -86,6 +91,7 @@ void qemu_remove_balloon_handler(void *opaque)
     }
     balloon_event_fn = NULL;
     balloon_stat_fn = NULL;
+    balloon_free_pages_fn = NULL;
     balloon_opaque = NULL;
 }
 
@@ -116,3 +122,23 @@ void qmp_balloon(int64_t target, Error **errp)
     trace_balloon_event(balloon_opaque, target);
     balloon_event_fn(balloon_opaque, target);
 }
+
+bool balloon_free_pages_support(void)
+{
+    return balloon_free_pages_fn ? true : false;
+}
+
+int balloon_get_free_pages(unsigned long *free_pages_bitmap,
+                           unsigned long *free_pages_count)
+{
+    if (!balloon_free_pages_fn) {
+        return -1;
+    }
+
+    if (!free_pages_bitmap || !free_pages_count) {
+        return -1;
+    }
+
+    return balloon_free_pages_fn(balloon_opaque,
+                                 free_pages_bitmap, free_pages_count);
+ }
diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index e9c30e9..a5b9d08 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -76,6 +76,12 @@ static bool balloon_stats_supported(const VirtIOBalloon *s)
     return virtio_vdev_has_feature(vdev, VIRTIO_BALLOON_F_STATS_VQ);
 }
 
+static bool balloon_free_pages_supported(const VirtIOBalloon *s)
+{
+    VirtIODevice *vdev = VIRTIO_DEVICE(s);
+    return virtio_vdev_has_feature(vdev, VIRTIO_BALLOON_F_GET_FREE_PAGES);
+}
+
 static bool balloon_stats_enabled(const VirtIOBalloon *s)
 {
     return s->stats_poll_interval > 0;
@@ -293,6 +299,37 @@ out:
     }
 }
 
+static void virtio_balloon_get_free_pages(VirtIODevice *vdev, VirtQueue *vq)
+{
+    VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
+    VirtQueueElement *elem;
+    size_t offset = 0;
+    uint64_t bitmap_bytes = 0, free_pages_count = 0;
+
+    elem = virtqueue_pop(vq, sizeof(VirtQueueElement));
+    if (!elem) {
+        return;
+    }
+    s->free_pages_vq_elem = elem;
+
+    if (!elem->out_num) {
+        return;
+    }
+
+    iov_to_buf(elem->out_sg, elem->out_num, offset,
+               &free_pages_count, sizeof(uint64_t));
+
+    offset += sizeof(uint64_t);
+    iov_to_buf(elem->out_sg, elem->out_num, offset,
+               &bitmap_bytes, sizeof(uint64_t));
+
+    offset += sizeof(uint64_t);
+    iov_to_buf(elem->out_sg, elem->out_num, offset,
+               s->free_pages_bitmap, bitmap_bytes);
+    s->req_status = DONE;
+    s->free_pages_count = free_pages_count;
+}
+
 static void virtio_balloon_get_config(VirtIODevice *vdev, uint8_t *config_data)
 {
     VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
@@ -362,6 +399,7 @@ static uint64_t virtio_balloon_get_features(VirtIODevice *vdev, uint64_t f,
     VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
     f |= dev->host_features;
     virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
+    virtio_add_feature(&f, VIRTIO_BALLOON_F_GET_FREE_PAGES);
     return f;
 }
 
@@ -372,6 +410,45 @@ static void virtio_balloon_stat(void *opaque, BalloonInfo *info)
                                              VIRTIO_BALLOON_PFN_SHIFT);
 }
 
+static int virtio_balloon_free_pages(void *opaque,
+                                     unsigned long *free_pages_bitmap,
+                                     unsigned long *free_pages_count)
+{
+    VirtIOBalloon *s = opaque;
+    VirtIODevice *vdev = VIRTIO_DEVICE(s);
+    VirtQueueElement *elem = s->free_pages_vq_elem;
+    int len;
+
+    if (!balloon_free_pages_supported(s)) {
+        return -1;
+    }
+
+    if (s->req_status == NOT_STARTED) {
+        s->free_pages_bitmap = free_pages_bitmap;
+        s->req_status = STARTED;
+        s->mem_layout.low_mem = pc_get_lowmem(PC_MACHINE(current_machine));
+        if (!elem->in_num) {
+            elem = virtqueue_pop(s->fvq, sizeof(VirtQueueElement));
+            if (!elem) {
+                return 0;
+            }
+            s->free_pages_vq_elem = elem;
+        }
+        len = iov_from_buf(elem->in_sg, elem->in_num, 0, &s->mem_layout,
+                           sizeof(s->mem_layout));
+        virtqueue_push(s->fvq, elem, len);
+        virtio_notify(vdev, s->fvq);
+        return 0;
+    } else if (s->req_status == STARTED) {
+        return 0;
+    } else if (s->req_status == DONE) {
+        *free_pages_count = s->free_pages_count;
+        s->req_status = NOT_STARTED;
+    }
+
+    return 1;
+}
+
 static void virtio_balloon_to_target(void *opaque, ram_addr_t target)
 {
     VirtIOBalloon *dev = VIRTIO_BALLOON(opaque);
@@ -429,7 +506,8 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
                 sizeof(struct virtio_balloon_config));
 
     ret = qemu_add_balloon_handler(virtio_balloon_to_target,
-                                   virtio_balloon_stat, s);
+                                   virtio_balloon_stat,
+                                   virtio_balloon_free_pages, s);
 
     if (ret < 0) {
         error_setg(errp, "Only one balloon device is supported");
@@ -440,6 +518,7 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
     s->ivq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->dvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
+    s->fvq = virtio_add_queue(vdev, 128, virtio_balloon_get_free_pages);
 
     reset_stats(s);
 
diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
index 35f62ac..fc173e4 100644
--- a/include/hw/virtio/virtio-balloon.h
+++ b/include/hw/virtio/virtio-balloon.h
@@ -23,6 +23,16 @@
 #define VIRTIO_BALLOON(obj) \
         OBJECT_CHECK(VirtIOBalloon, (obj), TYPE_VIRTIO_BALLOON)
 
+typedef enum virtio_req_status {
+    NOT_STARTED,
+    STARTED,
+    DONE,
+} VIRTIO_REQ_STATUS;
+
+typedef struct MemLayout {
+    uint64_t low_mem;
+} MemLayout;
+
 typedef struct virtio_balloon_stat VirtIOBalloonStat;
 
 typedef struct virtio_balloon_stat_modern {
@@ -33,16 +43,21 @@ typedef struct virtio_balloon_stat_modern {
 
 typedef struct VirtIOBalloon {
     VirtIODevice parent_obj;
-    VirtQueue *ivq, *dvq, *svq;
+    VirtQueue *ivq, *dvq, *svq, *fvq;
     uint32_t num_pages;
     uint32_t actual;
     uint64_t stats[VIRTIO_BALLOON_S_NR];
     VirtQueueElement *stats_vq_elem;
+    VirtQueueElement *free_pages_vq_elem;
     size_t stats_vq_offset;
     QEMUTimer *stats_timer;
     int64_t stats_last_update;
     int64_t stats_poll_interval;
     uint32_t host_features;
+    uint64_t *free_pages_bitmap;
+    uint64_t free_pages_count;
+    MemLayout mem_layout;
+    VIRTIO_REQ_STATUS req_status;
 } VirtIOBalloon;
 
 #endif
diff --git a/include/standard-headers/linux/virtio_balloon.h b/include/standard-headers/linux/virtio_balloon.h
index 2e2a6dc..95b7d0c 100644
--- a/include/standard-headers/linux/virtio_balloon.h
+++ b/include/standard-headers/linux/virtio_balloon.h
@@ -34,6 +34,7 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_GET_FREE_PAGES 3 /* Get the free pages bitmap */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
diff --git a/include/sysemu/balloon.h b/include/sysemu/balloon.h
index 3f976b4..205b272 100644
--- a/include/sysemu/balloon.h
+++ b/include/sysemu/balloon.h
@@ -18,11 +18,19 @@
 
 typedef void (QEMUBalloonEvent)(void *opaque, ram_addr_t target);
 typedef void (QEMUBalloonStatus)(void *opaque, BalloonInfo *info);
+typedef int (QEMUBalloonFreePages)(void *opaque,
+                                   unsigned long *free_pages_bitmap,
+                                   unsigned long *free_pages_count);
 
 int qemu_add_balloon_handler(QEMUBalloonEvent *event_func,
-			     QEMUBalloonStatus *stat_func, void *opaque);
+                             QEMUBalloonStatus *stat_func,
+                             QEMUBalloonFreePages *free_pages_func,
+                             void *opaque);
 void qemu_remove_balloon_handler(void *opaque);
 bool qemu_balloon_is_inhibited(void);
 void qemu_balloon_inhibit(bool state);
+bool balloon_free_pages_support(void);
+int balloon_get_free_pages(unsigned long *free_pages_bitmap,
+                           unsigned long *free_pages_count);
 
 #endif
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
