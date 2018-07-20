Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id DFFF56B026C
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 05:00:43 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x2-v6so6892488plv.0
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 02:00:43 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id w15-v6si1381027pga.30.2018.07.20.02.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 02:00:42 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v36 1/5] virtio-balloon: remove BUG() in init_vqs
Date: Fri, 20 Jul 2018 16:33:01 +0800
Message-Id: <1532075585-39067-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1532075585-39067-1-git-send-email-wei.w.wang@intel.com>
References: <1532075585-39067-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

It's a bit overkill to use BUG when failing to add an entry to the
stats_vq in init_vqs. So remove it and just return the error to the
caller to bail out nicely.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/virtio/virtio_balloon.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 6b237e3..9356a1a 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -455,9 +455,13 @@ static int init_vqs(struct virtio_balloon *vb)
 		num_stats = update_balloon_stats(vb);
 
 		sg_init_one(&sg, vb->stats, sizeof(vb->stats[0]) * num_stats);
-		if (virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb, GFP_KERNEL)
-		    < 0)
-			BUG();
+		err = virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb,
+					   GFP_KERNEL);
+		if (err) {
+			dev_warn(&vb->vdev->dev, "%s: add stat_vq failed\n",
+				 __func__);
+			return err;
+		}
 		virtqueue_kick(vb->stats_vq);
 	}
 	return 0;
-- 
2.7.4
