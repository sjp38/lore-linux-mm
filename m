Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC4286B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 00:30:48 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id f2so72048607uaf.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 21:30:48 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id w21si2005883uaa.56.2017.02.07.21.30.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 21:30:47 -0800 (PST)
From: Yisheng Xie <xieyisheng1@huawei.com>
Subject: [PATCH] mm balloon: umount balloon_mnt when remove vb device
Date: Wed, 8 Feb 2017 13:21:58 +0800
Message-ID: <1486531318-35189-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, minchan@kernel.org, aquini@redhat.com, koct9i@gmail.com, gi-oh.kim@profitbricks.com, vbabka@suse.cz, mhocko@kernel.org, mst@redhat.com, jasowang@redhat.com, guohanjun@huawei.com, qiuxishi@huawei.com, liubo95@huawei.com

With CONFIG_BALLOON_COMPACTION=y, it will mount balloon_mnt for
balloon page migration when probe a virtio_balloon device, however
do not unmount it when remove the device, fix it.

Fixes: b1123ea6d3b3 ("mm: balloon: use general non-lru movable page feature")
Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
---
 drivers/virtio/virtio_balloon.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 181793f..9d2738e 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -615,8 +615,12 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	cancel_work_sync(&vb->update_balloon_stats_work);
 
 	remove_common(vb);
+#ifdef CONFIG_BALLOON_COMPACTION
 	if (vb->vb_dev_info.inode)
 		iput(vb->vb_dev_info.inode);
+
+	kern_unmount(balloon_mnt);
+#endif
 	kfree(vb);
 }
 
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
