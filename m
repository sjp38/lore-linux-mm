Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 110006B0008
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 04:19:19 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id s1-v6so1756999pfm.22
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 01:19:19 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id t7-v6si21504807pgp.18.2018.08.16.01.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 01:19:17 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v4 2/3] virtio-balloon: kzalloc the vb struct
Date: Thu, 16 Aug 2018 15:50:57 +0800
Message-Id: <1534405858-27085-3-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1534405858-27085-1-git-send-email-wei.w.wang@intel.com>
References: <1534405858-27085-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp
Cc: wei.w.wang@intel.com

Zero all the vb fields at alloaction, so that we don't need to
zero-initialize each field one by one later.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/virtio/virtio_balloon.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 8100e77..d97d73c 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -561,7 +561,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		return -EINVAL;
 	}
 
-	vdev->priv = vb = kmalloc(sizeof(*vb), GFP_KERNEL);
+	vdev->priv = vb = kzalloc(sizeof(*vb), GFP_KERNEL);
 	if (!vb) {
 		err = -ENOMEM;
 		goto out;
@@ -570,8 +570,6 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	INIT_WORK(&vb->update_balloon_stats_work, update_balloon_stats_func);
 	INIT_WORK(&vb->update_balloon_size_work, update_balloon_size_func);
 	spin_lock_init(&vb->stop_update_lock);
-	vb->stop_update = false;
-	vb->num_pages = 0;
 	mutex_init(&vb->balloon_lock);
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
@@ -602,7 +600,6 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		err = PTR_ERR(vb->vb_dev_info.inode);
 		kern_unmount(balloon_mnt);
 		unregister_oom_notifier(&vb->nb);
-		vb->vb_dev_info.inode = NULL;
 		goto out_del_vqs;
 	}
 	vb->vb_dev_info.inode->i_mapping->a_ops = &balloon_aops;
-- 
2.7.4
