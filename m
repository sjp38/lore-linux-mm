Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D37BC6B0269
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 05:56:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g26-v6so10947114pfo.7
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 02:56:54 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id r3-v6si15637780pgo.606.2018.07.10.02.56.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 02:56:53 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v35 2/5] virtio-balloon: remove BUG() in init_vqs
Date: Tue, 10 Jul 2018 17:31:04 +0800
Message-Id: <1531215067-35472-3-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
References: <1531215067-35472-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

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
