Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5BEEC6B0005
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 05:52:49 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h5-v6so2684413pgs.13
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 02:52:49 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a61-v6si3476062plc.80.2018.07.27.02.52.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 02:52:48 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v2 1/2] virtio-balloon: remove BUG() in init_vqs
Date: Fri, 27 Jul 2018 17:24:54 +0800
Message-Id: <1532683495-31974-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com>
References: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: wei.w.wang@intel.com

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
