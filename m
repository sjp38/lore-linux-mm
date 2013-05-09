Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 5A4426B003D
	for <linux-mm@kvack.org>; Thu,  9 May 2013 10:54:34 -0400 (EDT)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [RFC 1/2] virtio_balloon: move balloon_lock mutex to callers
Date: Thu,  9 May 2013 10:53:48 -0400
Message-Id: <1368111229-29847-2-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1368111229-29847-1-git-send-email-lcapitulino@redhat.com>
References: <1368111229-29847-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, riel@redhat.com, aquini@redhat.com, mst@redhat.com, amit.shah@redhat.com, anton@enomsg.org

This commit moves the balloon_lock mutex out of the fill_balloon()
and leak_balloon() functions to their callers.

The reason for this change is that the next commit will introduce
a shrinker callback for the balloon driver, which will also call
leak_balloon() but will require different locking semantics.

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
---
 drivers/virtio/virtio_balloon.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index bd3ae32..9d5fe2b 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -133,7 +133,6 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
-	mutex_lock(&vb->balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
 	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
 		struct page *page = balloon_page_enqueue(vb_dev_info);
@@ -154,7 +153,6 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 	/* Did we get any? */
 	if (vb->num_pfns != 0)
 		tell_host(vb, vb->inflate_vq);
-	mutex_unlock(&vb->balloon_lock);
 }
 
 static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
@@ -176,7 +174,6 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
-	mutex_lock(&vb->balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
 	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
 		page = balloon_page_dequeue(vb_dev_info);
@@ -192,7 +189,6 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
 	 * is true, we *have* to do it in this order
 	 */
 	tell_host(vb, vb->deflate_vq);
-	mutex_unlock(&vb->balloon_lock);
 	release_pages_by_pfn(vb->pfns, vb->num_pfns);
 }
 
@@ -305,11 +301,13 @@ static int balloon(void *_vballoon)
 					 || freezing(current));
 		if (vb->need_stats_update)
 			stats_handle_request(vb);
+		mutex_lock(&vb->balloon_lock);
 		if (diff > 0)
 			fill_balloon(vb, diff);
 		else if (diff < 0)
 			leak_balloon(vb, -diff);
 		update_balloon_size(vb);
+		mutex_unlock(&vb->balloon_lock);
 	}
 	return 0;
 }
@@ -490,9 +488,11 @@ out:
 static void remove_common(struct virtio_balloon *vb)
 {
 	/* There might be pages left in the balloon: free them. */
+	mutex_lock(&vb->balloon_lock);
 	while (vb->num_pages)
 		leak_balloon(vb, vb->num_pages);
 	update_balloon_size(vb);
+	mutex_unlock(&vb->balloon_lock);
 
 	/* Now we reset the device so we can clean up the queues. */
 	vb->vdev->config->reset(vb->vdev);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
