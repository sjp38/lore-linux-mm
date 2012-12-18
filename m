Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 57F296B002B
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 15:18:13 -0500 (EST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [RFC 1/2] virtio_balloon: move locking to the balloon thread
Date: Tue, 18 Dec 2012 18:17:29 -0200
Message-Id: <1355861850-2702-2-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1355861850-2702-1-git-send-email-lcapitulino@redhat.com>
References: <1355861850-2702-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, riel@redhat.com, aquini@redhat.com, mst@redhat.com, amit.shah@redhat.com, agl@us.ibm.com

Today, the balloon_lock mutex is taken and released by fill_balloon()
and leak_balloon() when both functions are entered and when they
return.

This commit moves the locking to the caller instead, which is
the balloon() thread. The balloon thread is the sole caller of those
functions today.

The reason for this move is that the next commit will introduce
a shrinker callback for the balloon driver, which will also call
leak_balloon() but will require different locking semantics.

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
---
 drivers/virtio/virtio_balloon.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 2a70558..877e695 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -133,7 +133,6 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
-	mutex_lock(&vb->balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
 	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
 		struct page *page = balloon_page_enqueue(vb_dev_info);
@@ -155,7 +154,6 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 	/* Did we get any? */
 	if (vb->num_pfns != 0)
 		tell_host(vb, vb->inflate_vq);
-	mutex_unlock(&vb->balloon_lock);
 }
 
 static void release_pages_by_pfn(const u32 pfns[], unsigned int num)
@@ -177,7 +175,6 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
-	mutex_lock(&vb->balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
 	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
 		page = balloon_page_dequeue(vb_dev_info);
@@ -193,7 +190,6 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
 	 * is true, we *have* to do it in this order
 	 */
 	tell_host(vb, vb->deflate_vq);
-	mutex_unlock(&vb->balloon_lock);
 	release_pages_by_pfn(vb->pfns, vb->num_pfns);
 }
 
@@ -306,11 +302,13 @@ static int balloon(void *_vballoon)
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
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
