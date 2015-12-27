Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A71336B02BD
	for <linux-mm@kvack.org>; Sun, 27 Dec 2015 18:34:12 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id e65so51689845pfe.1
        for <linux-mm@kvack.org>; Sun, 27 Dec 2015 15:34:12 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id 86si38188548pfs.88.2015.12.27.15.34.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 27 Dec 2015 15:34:11 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/2] virtio_balloon: fix race by fill and leak
Date: Mon, 28 Dec 2015 08:35:12 +0900
Message-Id: <1451259313-26353-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Konstantin Khlebnikov <koct9i@gmail.com>, Rafael Aquini <aquini@redhat.com>, Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org

During my compaction-related stuff, I encountered a bug
with ballooning.

With repeated inflating and deflating cycle, guest memory(
ie, cat /proc/meminfo | grep MemTotal) is decreased and
couldn't be recovered.

The reason is balloon_lock doesn't cover release_pages_balloon
so struct virtio_balloon fields could be overwritten by race
of fill_balloon(e,g, vb->*pfns could be critical).

This patch fixes it in my test.

Cc: <stable@vger.kernel.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/virtio/virtio_balloon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 7efc32945810..7d3e5d0e9aa4 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -209,8 +209,8 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	 */
 	if (vb->num_pfns != 0)
 		tell_host(vb, vb->deflate_vq);
-	mutex_unlock(&vb->balloon_lock);
 	release_pages_balloon(vb);
+	mutex_unlock(&vb->balloon_lock);
 	return num_freed_pages;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
