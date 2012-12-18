Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id EA5CD6B0044
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 15:18:14 -0500 (EST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [RFC 2/2] virtio_balloon: add auto-ballooning support
Date: Tue, 18 Dec 2012 18:17:30 -0200
Message-Id: <1355861850-2702-3-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1355861850-2702-1-git-send-email-lcapitulino@redhat.com>
References: <1355861850-2702-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, riel@redhat.com, aquini@redhat.com, mst@redhat.com, amit.shah@redhat.com, agl@us.ibm.com

The auto-ballooning feature automatically performs balloon inflate or
deflate based on host and guest memory pressure. This can help to
avoid swapping or worse in both, host and guest.

Auto-ballooning has a host and a guest part. The host performs
automatic inflate by requesting the guest to inflate its balloon
when the host is facing memory pressure. The guest performs
automatic deflate when it's facing memory pressure itself. It's
expected that auto-inflate and auto-deflate will balance each
other over time.

This commit implements the guest side of auto-ballooning.

To perform automatic deflate, the virtio_balloon driver registers
a shrinker callback, which will try to deflate the guest's balloon
on guest memory pressure just like if it were a cache. The shrinker
callback is only registered if the host supports the
VIRTIO_BALLOON_F_AUTO_BALLOON feature bit.

FIXMEs

 o the guest kernel seems to spin when the host is performing a long
   auto-inflate

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
---
 drivers/virtio/virtio_balloon.c     | 54 +++++++++++++++++++++++++++++++++++++
 include/uapi/linux/virtio_balloon.h |  1 +
 2 files changed, 55 insertions(+)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 877e695..12fb70e 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -71,6 +71,9 @@ struct virtio_balloon
 	/* Memory statistics */
 	int need_stats_update;
 	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
+
+	/* Memory shrinker */
+	struct shrinker shrinker;
 };
 
 static struct virtio_device_id id_table[] = {
@@ -286,6 +289,46 @@ static void update_balloon_size(struct virtio_balloon *vb)
 			      &actual, sizeof(actual));
 }
 
+static unsigned long balloon_get_nr_pages(const struct virtio_balloon *vb)
+{
+	return vb->num_pages / VIRTIO_BALLOON_PAGES_PER_PAGE;
+}
+
+static int balloon_shrinker(struct shrinker *shrinker,struct shrink_control *sc)
+{
+	unsigned int nr_pages, new_target;
+	struct virtio_balloon *vb;
+
+	vb = container_of(shrinker, struct virtio_balloon, shrinker);
+	if (!mutex_trylock(&vb->balloon_lock)) {
+		return -1;
+	}
+
+	nr_pages = balloon_get_nr_pages(vb);
+	if (!sc->nr_to_scan || !nr_pages) {
+		goto out;
+	}
+
+	/*
+	 * If the current balloon size is greater than the number of
+	 * pages being reclaimed by the kernel, deflate only the needed
+	 * amount. Otherwise deflate everything we have.
+	 */
+	if (nr_pages > sc->nr_to_scan) {
+		new_target = nr_pages - sc->nr_to_scan;
+	} else {
+		new_target = 0;
+	}
+
+	leak_balloon(vb, new_target);
+	update_balloon_size(vb);
+	nr_pages = balloon_get_nr_pages(vb);
+
+out:
+	mutex_unlock(&vb->balloon_lock);
+	return nr_pages;
+}
+
 static int balloon(void *_vballoon)
 {
 	struct virtio_balloon *vb = _vballoon;
@@ -472,6 +515,13 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		goto out_del_vqs;
 	}
 
+	memset(&vb->shrinker, 0, sizeof(vb->shrinker));
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_AUTO_BALLOON)) {
+		vb->shrinker.shrink = balloon_shrinker;
+		vb->shrinker.seeks = DEFAULT_SEEKS;
+		register_shrinker(&vb->shrinker);
+	}
+
 	return 0;
 
 out_del_vqs:
@@ -488,6 +538,9 @@ out:
 
 static void remove_common(struct virtio_balloon *vb)
 {
+	if (vb->shrinker.shrink)
+		unregister_shrinker(&vb->shrinker);
+
 	/* There might be pages left in the balloon: free them. */
 	while (vb->num_pages)
 		leak_balloon(vb, vb->num_pages);
@@ -542,6 +595,7 @@ static int virtballoon_restore(struct virtio_device *vdev)
 static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
+	VIRTIO_BALLOON_F_AUTO_BALLOON,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 652dc8b..3764cac 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -31,6 +31,7 @@
 /* The feature bitmap for virtio balloon */
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
+#define VIRTIO_BALLOON_F_AUTO_BALLOON	2 /* Automatic ballooning */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
