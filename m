Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48EF76B025E
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:08:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p87so10025414pfj.21
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:08:25 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i85si704365pfj.398.2017.10.20.05.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:08:24 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v1 2/3] virtio-balloon: deflate up to oom_pages on OOM
Date: Fri, 20 Oct 2017 19:54:25 +0800
Message-Id: <1508500466-21165-3-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>
References: <1508500466-21165-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org
Cc: Wei Wang <wei.w.wang@intel.com>

The current implementation only deflates 256 pages even when a user
specifies more than that via the oom_pages module param. This patch
enables the deflating of up to oom_pages pages if there are enough
inflated pages.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/virtio/virtio_balloon.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 1ecd15a..ab55cf8 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -43,8 +43,8 @@
 #define OOM_VBALLOON_DEFAULT_PAGES 256
 #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
 
-static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
-module_param(oom_pages, int, S_IRUSR | S_IWUSR);
+static unsigned int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
+module_param(oom_pages, uint, 0600);
 MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
 
 #ifdef CONFIG_BALLOON_COMPACTION
@@ -359,16 +359,20 @@ static int virtballoon_oom_notify(struct notifier_block *self,
 {
 	struct virtio_balloon *vb;
 	unsigned long *freed;
-	unsigned num_freed_pages;
+	unsigned int npages = oom_pages;
 
 	vb = container_of(self, struct virtio_balloon, nb);
 	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
 		return NOTIFY_OK;
 
 	freed = parm;
-	num_freed_pages = leak_balloon(vb, oom_pages);
+
+	/* Don't deflate more than the number of inflated pages */
+	while (npages && atomic64_read(&vb->num_pages))
+		npages -= leak_balloon(vb, npages);
+
 	update_balloon_size(vb);
-	*freed += num_freed_pages;
+	*freed += oom_pages - npages;
 
 	return NOTIFY_OK;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
