Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id AB7BE6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 21:18:39 -0400 (EDT)
Date: Wed, 5 Jun 2013 21:18:37 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH v2] virtio_balloon: leak_balloon(): only tell host if we got
 pages deflated
Message-ID: <20130605211837.1fc9b902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, aquini@redhat.com

The balloon_page_dequeue() function can return NULL. If it does for
the first page being freed, then leak_balloon() will create a
scatter list with len=0. Which in turn seems to generate an invalid
virtio request.

I didn't get this in practice, I found it by code review. On the other
hand, such an invalid virtio request will cause errors in QEMU and
fill_balloon() also performs the same check implemented by this commit.

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
Acked-by: Rafael Aquini <aquini@redhat.com>
---

o v2

 - Improve changelog

 drivers/virtio/virtio_balloon.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index bd3ae32..71af7b5 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -191,7 +191,8 @@ static void leak_balloon(struct virtio_balloon *vb, size_t num)
 	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
 	 * is true, we *have* to do it in this order
 	 */
-	tell_host(vb, vb->deflate_vq);
+	if (vb->num_pfns != 0)
+		tell_host(vb, vb->deflate_vq);
 	mutex_unlock(&vb->balloon_lock);
 	release_pages_by_pfn(vb->pfns, vb->num_pfns);
 }
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
