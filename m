Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5198D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 18:40:26 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp08.in.ibm.com (8.14.4/8.13.1) with ESMTP id o9SMB5kS031090
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 03:41:05 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9SMeKEQ3567766
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 04:10:20 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9SMeKQE016945
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 09:40:20 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 29 Oct 2010 04:10:19 +0530
Message-Id: <20101028224019.32626.91855.sendpatchset@localhost.localdomain>
In-Reply-To: <20101028224002.32626.13015.sendpatchset@localhost.localdomain>
References: <20101028224002.32626.13015.sendpatchset@localhost.localdomain>
Subject: [RFC][PATCH 3/3] QEmu changes to provide balloon hint
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, qemu-devel@nongnu.org
List-ID: <linux-mm.kvack.org>

Provide memory hint during ballooning

From: Balbir Singh <balbir@linux.vnet.ibm.com>

This patch adds an optional hint to the qemu monitor balloon
command. The hint tells the guest operating system to consider
a class of memory during reclaim. Currently the supported
hint is cached memory. The design is generic and can be extended
to provide other hints in the future if required.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 balloon.c           |   18 ++++++++++++++----
 balloon.h           |    4 +++-
 hmp-commands.hx     |    7 +++++--
 hw/virtio-balloon.c |   15 +++++++++++----
 hw/virtio-balloon.h |    3 +++
 qmp-commands.hx     |    7 ++++---
 6 files changed, 40 insertions(+), 14 deletions(-)


diff --git a/balloon.c b/balloon.c
index 0021fef..b2bdda5 100644
--- a/balloon.c
+++ b/balloon.c
@@ -41,11 +41,13 @@ void qemu_add_balloon_handler(QEMUBalloonEvent *func, void *opaque)
     qemu_balloon_event_opaque = opaque;
 }
 
-int qemu_balloon(ram_addr_t target, MonitorCompletion cb, void *opaque)
+int qemu_balloon(ram_addr_t target, bool reclaim_cache_first,
+                 MonitorCompletion cb, void *opaque)
 {
     if (qemu_balloon_event) {
         trace_balloon_event(qemu_balloon_event_opaque, target);
-        qemu_balloon_event(qemu_balloon_event_opaque, target, cb, opaque);
+        qemu_balloon_event(qemu_balloon_event_opaque, target,
+                           reclaim_cache_first, cb, opaque);
         return 1;
     } else {
         return 0;
@@ -55,7 +57,7 @@ int qemu_balloon(ram_addr_t target, MonitorCompletion cb, void *opaque)
 int qemu_balloon_status(MonitorCompletion cb, void *opaque)
 {
     if (qemu_balloon_event) {
-        qemu_balloon_event(qemu_balloon_event_opaque, 0, cb, opaque);
+        qemu_balloon_event(qemu_balloon_event_opaque, 0, 0, cb, opaque);
         return 1;
     } else {
         return 0;
@@ -131,13 +133,21 @@ int do_balloon(Monitor *mon, const QDict *params,
 	       MonitorCompletion cb, void *opaque)
 {
     int ret;
+    int val;
+    const char *cache_hint;
+    int reclaim_cache_first = 0;
 
     if (kvm_enabled() && !kvm_has_sync_mmu()) {
         qerror_report(QERR_KVM_MISSING_CAP, "synchronous MMU", "balloon");
         return -1;
     }
 
-    ret = qemu_balloon(qdict_get_int(params, "value"), cb, opaque);
+    val = qdict_get_int(params, "value");
+    cache_hint = qdict_get_try_str(params, "hint");
+    if (cache_hint)
+        reclaim_cache_first = 1;
+
+    ret = qemu_balloon(val, reclaim_cache_first, cb, opaque);
     if (ret == 0) {
         qerror_report(QERR_DEVICE_NOT_ACTIVE, "balloon");
         return -1;
diff --git a/balloon.h b/balloon.h
index d478e28..65d68c1 100644
--- a/balloon.h
+++ b/balloon.h
@@ -17,11 +17,13 @@
 #include "monitor.h"
 
 typedef void (QEMUBalloonEvent)(void *opaque, ram_addr_t target,
+                                bool reclaim_cache_first,
                                 MonitorCompletion cb, void *cb_data);
 
 void qemu_add_balloon_handler(QEMUBalloonEvent *func, void *opaque);
 
-int qemu_balloon(ram_addr_t target, MonitorCompletion cb, void *opaque);
+int qemu_balloon(ram_addr_t target, bool reclaim_cache_first,
+                 MonitorCompletion cb, void *opaque);
 
 int qemu_balloon_status(MonitorCompletion cb, void *opaque);
 
diff --git a/hmp-commands.hx b/hmp-commands.hx
index 81999aa..80e42aa 100644
--- a/hmp-commands.hx
+++ b/hmp-commands.hx
@@ -925,8 +925,8 @@ ETEXI
 
     {
         .name       = "balloon",
-        .args_type  = "value:M",
-        .params     = "target",
+        .args_type  = "value:M,hint:s?",
+        .params     = "target [cache]",
         .help       = "request VM to change its memory allocation (in MB)",
         .user_print = monitor_user_noop,
         .mhandler.cmd_async = do_balloon,
@@ -937,6 +937,9 @@ STEXI
 @item balloon @var{value}
 @findex balloon
 Request VM to change its memory allocation to @var{value} (in MB).
+An optional @var{hint} can be specified to indicate if the guest
+should reclaim from the cached memory in the guest first. The
+@var{hint} may be ignored by the guest.
 ETEXI
 
     {
diff --git a/hw/virtio-balloon.c b/hw/virtio-balloon.c
index 8adddea..e363507 100644
--- a/hw/virtio-balloon.c
+++ b/hw/virtio-balloon.c
@@ -44,6 +44,7 @@ typedef struct VirtIOBalloon
     size_t stats_vq_offset;
     MonitorCompletion *stats_callback;
     void *stats_opaque_callback_data;
+    uint32_t reclaim_cache_first;
 } VirtIOBalloon;
 
 static VirtIOBalloon *to_virtio_balloon(VirtIODevice *vdev)
@@ -181,8 +182,11 @@ static void virtio_balloon_get_config(VirtIODevice *vdev, uint8_t *config_data)
 
     config.num_pages = cpu_to_le32(dev->num_pages);
     config.actual = cpu_to_le32(dev->actual);
-
-    memcpy(config_data, &config, 8);
+    if (vdev->guest_features & (1 << VIRTIO_BALLOON_F_BALLOON_HINT)) {
+        config.reclaim_cache_first = cpu_to_le32(dev->reclaim_cache_first);
+        memcpy(config_data, &config, 12);
+    } else
+        memcpy(config_data, &config, 8);
 }
 
 static void virtio_balloon_set_config(VirtIODevice *vdev,
@@ -196,11 +200,13 @@ static void virtio_balloon_set_config(VirtIODevice *vdev,
 
 static uint32_t virtio_balloon_get_features(VirtIODevice *vdev, uint32_t f)
 {
-    f |= (1 << VIRTIO_BALLOON_F_STATS_VQ);
+    f |= (1 << VIRTIO_BALLOON_F_STATS_VQ) |
+         (1 << VIRTIO_BALLOON_F_BALLOON_HINT);
     return f;
 }
 
 static void virtio_balloon_to_target(void *opaque, ram_addr_t target,
+                                     bool reclaim_cache_first,
                                      MonitorCompletion cb, void *cb_data)
 {
     VirtIOBalloon *dev = opaque;
@@ -210,6 +216,7 @@ static void virtio_balloon_to_target(void *opaque, ram_addr_t target,
 
     if (target) {
         dev->num_pages = (ram_size - target) >> VIRTIO_BALLOON_PFN_SHIFT;
+        dev->reclaim_cache_first = reclaim_cache_first;
         virtio_notify_config(&dev->vdev);
     } else {
         /* For now, only allow one request at a time.  This restriction can be
@@ -263,7 +270,7 @@ VirtIODevice *virtio_balloon_init(DeviceState *dev)
 
     s = (VirtIOBalloon *)virtio_common_init("virtio-balloon",
                                             VIRTIO_ID_BALLOON,
-                                            8, sizeof(VirtIOBalloon));
+                                            12, sizeof(VirtIOBalloon));
 
     s->vdev.get_config = virtio_balloon_get_config;
     s->vdev.set_config = virtio_balloon_set_config;
diff --git a/hw/virtio-balloon.h b/hw/virtio-balloon.h
index e20cf6b..39d1b01 100644
--- a/hw/virtio-balloon.h
+++ b/hw/virtio-balloon.h
@@ -26,6 +26,7 @@
 /* The feature bitmap for virtio balloon */
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST 0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ 1       /* Memory stats virtqueue */
+#define VIRTIO_BALLOON_F_BALLOON_HINT 2   /* Ballon hint */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -36,6 +37,8 @@ struct virtio_balloon_config
     uint32_t num_pages;
     /* Number of pages we've actually got in balloon. */
     uint32_t actual;
+    /* Hint, should we reclaim cached pages first? */
+    uint32_t reclaim_cache_first;
 };
 
 /* Memory Statistics */
diff --git a/qmp-commands.hx b/qmp-commands.hx
index 793cf1c..1da2e65 100644
--- a/qmp-commands.hx
+++ b/qmp-commands.hx
@@ -605,8 +605,8 @@ EQMP
 
     {
         .name       = "balloon",
-        .args_type  = "value:M",
-        .params     = "target",
+        .args_type  = "value:M,hint:s?",
+        .params     = "target [cache]",
         .help       = "request VM to change its memory allocation (in MB)",
         .user_print = monitor_user_noop,
         .mhandler.cmd_async = do_balloon,
@@ -622,10 +622,11 @@ Request VM to change its memory allocation (in bytes).
 Arguments:
 
 - "value": New memory allocation (json-int)
+- "hint": Optional hint (json-string, optional)
 
 Example:
 
--> { "execute": "balloon", "arguments": { "value": 536870912 } }
++-> { "execute": "balloon", "arguments": { "value": 536870912, "hint":"cache" } }
 <- { "return": {} }
 
 EQMP

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
