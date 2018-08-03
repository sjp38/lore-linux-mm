Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 624636B0266
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 05:01:00 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d22-v6so3332946pfn.3
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 02:01:00 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b5-v6si4633098pfa.116.2018.08.03.02.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 02:00:58 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v3 2/2] virtio_balloon: replace oom notifier with shrinker
Date: Fri,  3 Aug 2018 16:32:26 +0800
Message-Id: <1533285146-25212-3-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1533285146-25212-1-git-send-email-wei.w.wang@intel.com>
References: <1533285146-25212-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp
Cc: wei.w.wang@intel.com

The OOM notifier is getting deprecated to use for the reasons:
- As a callout from the oom context, it is too subtle and easy to
  generate bugs and corner cases which are hard to track;
- It is called too late (after the reclaiming has been performed).
  Drivers with large amuont of reclaimable memory is expected to
  release them at an early stage of memory pressure;
- The notifier callback isn't aware of oom contrains;
Link: https://lkml.org/lkml/2018/7/12/314

This patch replaces the virtio-balloon oom notifier with a shrinker
to release balloon pages on memory pressure. The balloon pages are
given back to mm adaptively by returning the number of pages that the
reclaimer is asking for (i.e. sc->nr_to_scan).

Currently the max possible value of sc->nr_to_scan passed to the balloon
shrinker is SHRINK_BATCH, which is 128. This is smaller than the
limitation that only VIRTIO_BALLOON_ARRAY_PFNS_MAX (256) pages can be
returned via one invocation of leak_balloon. But this patch still
considers the case that SHRINK_BATCH or shrinker->batch could be changed
to a value larger than VIRTIO_BALLOON_ARRAY_PFNS_MAX, which will need to
do multiple invocations of leak_balloon.

Historically, the feature VIRTIO_BALLOON_F_DEFLATE_ON_OOM has been used
to release balloon pages on OOM. We continue to use this feature bit for
the shrinker, so the shrinker is only registered when this feature bit
has been negotiated with host.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 drivers/virtio/virtio_balloon.c | 111 ++++++++++++++++++++++------------------
 1 file changed, 60 insertions(+), 51 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 8100e77..612a359 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -27,7 +27,6 @@
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/balloon_compaction.h>
-#include <linux/oom.h>
 #include <linux/wait.h>
 #include <linux/mm.h>
 #include <linux/mount.h>
@@ -40,13 +39,8 @@
  */
 #define VIRTIO_BALLOON_PAGES_PER_PAGE (unsigned)(PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
 #define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
-#define OOM_VBALLOON_DEFAULT_PAGES 256
 #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
 
-static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
-module_param(oom_pages, int, S_IRUSR | S_IWUSR);
-MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
-
 #ifdef CONFIG_BALLOON_COMPACTION
 static struct vfsmount *balloon_mnt;
 #endif
@@ -86,8 +80,8 @@ struct virtio_balloon {
 	/* Memory statistics */
 	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
 
-	/* To register callback in oom notifier call chain */
-	struct notifier_block nb;
+	/* To register a shrinker to shrink memory upon memory pressure */
+	struct shrinker shrinker;
 };
 
 static struct virtio_device_id id_table[] = {
@@ -365,38 +359,6 @@ static void update_balloon_size(struct virtio_balloon *vb)
 		      &actual);
 }
 
-/*
- * virtballoon_oom_notify - release pages when system is under severe
- *			    memory pressure (called from out_of_memory())
- * @self : notifier block struct
- * @dummy: not used
- * @parm : returned - number of freed pages
- *
- * The balancing of memory by use of the virtio balloon should not cause
- * the termination of processes while there are pages in the balloon.
- * If virtio balloon manages to release some memory, it will make the
- * system return and retry the allocation that forced the OOM killer
- * to run.
- */
-static int virtballoon_oom_notify(struct notifier_block *self,
-				  unsigned long dummy, void *parm)
-{
-	struct virtio_balloon *vb;
-	unsigned long *freed;
-	unsigned num_freed_pages;
-
-	vb = container_of(self, struct virtio_balloon, nb);
-	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
-		return NOTIFY_OK;
-
-	freed = parm;
-	num_freed_pages = leak_balloon(vb, oom_pages);
-	update_balloon_size(vb);
-	*freed += num_freed_pages;
-
-	return NOTIFY_OK;
-}
-
 static void update_balloon_stats_func(struct work_struct *work)
 {
 	struct virtio_balloon *vb;
@@ -550,6 +512,53 @@ static struct file_system_type balloon_fs = {
 
 #endif /* CONFIG_BALLOON_COMPACTION */
 
+static unsigned long virtio_balloon_shrinker_scan(struct shrinker *shrinker,
+						  struct shrink_control *sc)
+{
+	unsigned long pages_to_free, pages_freed = 0;
+	struct virtio_balloon *vb = container_of(shrinker,
+					struct virtio_balloon, shrinker);
+
+	pages_to_free = sc->nr_to_scan * VIRTIO_BALLOON_PAGES_PER_PAGE;
+
+	/*
+	 * One invocation of leak_balloon can deflate at most
+	 * VIRTIO_BALLOON_ARRAY_PFNS_MAX balloon pages, so we call it
+	 * multiple times to deflate pages till reaching pages_to_free.
+	 */
+	while (vb->num_pages && pages_to_free) {
+		pages_to_free -= pages_freed;
+		pages_freed += leak_balloon(vb, pages_to_free);
+	}
+	update_balloon_size(vb);
+
+	return pages_freed / VIRTIO_BALLOON_PAGES_PER_PAGE;
+}
+
+static unsigned long virtio_balloon_shrinker_count(struct shrinker *shrinker,
+						   struct shrink_control *sc)
+{
+	struct virtio_balloon *vb = container_of(shrinker,
+					struct virtio_balloon, shrinker);
+
+	return vb->num_pages / VIRTIO_BALLOON_PAGES_PER_PAGE;
+}
+
+static void virtio_balloon_unregister_shrinker(struct virtio_balloon *vb)
+{
+	unregister_shrinker(&vb->shrinker);
+}
+
+static int virtio_balloon_register_shrinker(struct virtio_balloon *vb)
+{
+	vb->shrinker.scan_objects = virtio_balloon_shrinker_scan;
+	vb->shrinker.count_objects = virtio_balloon_shrinker_count;
+	vb->shrinker.batch = 0;
+	vb->shrinker.seeks = DEFAULT_SEEKS;
+
+	return register_shrinker(&vb->shrinker);
+}
+
 static int virtballoon_probe(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb;
@@ -582,17 +591,10 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (err)
 		goto out_free_vb;
 
-	vb->nb.notifier_call = virtballoon_oom_notify;
-	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
-	err = register_oom_notifier(&vb->nb);
-	if (err < 0)
-		goto out_del_vqs;
-
 #ifdef CONFIG_BALLOON_COMPACTION
 	balloon_mnt = kern_mount(&balloon_fs);
 	if (IS_ERR(balloon_mnt)) {
 		err = PTR_ERR(balloon_mnt);
-		unregister_oom_notifier(&vb->nb);
 		goto out_del_vqs;
 	}
 
@@ -601,13 +603,20 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (IS_ERR(vb->vb_dev_info.inode)) {
 		err = PTR_ERR(vb->vb_dev_info.inode);
 		kern_unmount(balloon_mnt);
-		unregister_oom_notifier(&vb->nb);
 		vb->vb_dev_info.inode = NULL;
 		goto out_del_vqs;
 	}
 	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
 #endif
-
+	/*
+	 * We continue to use VIRTIO_BALLOON_F_DEFLATE_ON_OOM to decide if a
+	 * shrinker needs to be registered to relieve memory pressure.
+	 */
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM)) {
+		err = virtio_balloon_register_shrinker(vb);
+		if (err)
+			goto out_del_vqs;
+	}
 	virtio_device_ready(vdev);
 
 	if (towards_target(vb))
@@ -639,8 +648,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb = vdev->priv;
 
-	unregister_oom_notifier(&vb->nb);
-
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
+		virtio_balloon_unregister_shrinker(vb);
 	spin_lock_irq(&vb->stop_update_lock);
 	vb->stop_update = true;
 	spin_unlock_irq(&vb->stop_update_lock);
-- 
2.7.4
