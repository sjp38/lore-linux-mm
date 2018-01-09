Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 056AD6B026A
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 06:29:40 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id w7so10377126pfd.4
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 03:29:39 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m72si249531pga.397.2018.01.09.03.29.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jan 2018 03:29:38 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v21 5/5] virtio-balloon: don't report free pages when page poisoning is enabled
Date: Tue,  9 Jan 2018 19:11:02 +0800
Message-Id: <1515496262-7533-6-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1515496262-7533-1-git-send-email-wei.w.wang@intel.com>
References: <1515496262-7533-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

The guest free pages should not be discarded by the live migration thread
when page poisoning is enabled with PAGE_POISONING_NO_SANITY=n, because
skipping the transfer of such poisoned free pages will trigger false
positive when new pages are allocated and checked on the destination.
This patch adds a config field, poison_val. Guest writes to the config
field to tell the host about the poisoning value. The value will be 0 in
the following cases:
1) PAGE_POISONING_NO_SANITY is enabled;
2) page poisoning is disabled; or
3) PAGE_POISONING_ZERO is enabled.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Suggested-by: Michael S. Tsirkin <mst@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
---
 drivers/virtio/virtio_balloon.c     | 8 ++++++++
 include/uapi/linux/virtio_balloon.h | 2 ++
 2 files changed, 10 insertions(+)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index f7e8830..7429894 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -859,6 +859,7 @@ static struct file_system_type balloon_fs = {
 static int virtballoon_probe(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb;
+	__u32 poison_val;
 	int err;
 
 	if (!vdev->config->get) {
@@ -896,6 +897,13 @@ static int virtballoon_probe(struct virtio_device *vdev)
 					WQ_FREEZABLE | WQ_CPU_INTENSIVE, 0);
 		INIT_WORK(&vb->report_free_page_work, report_free_page);
 		vb->stop_cmd_id = VIRTIO_BALLOON_FREE_PAGE_REPORT_STOP_ID;
+		if (IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY) ||
+		    !page_poisoning_enabled())
+			poison_val = 0;
+		else
+			poison_val = PAGE_POISON;
+		virtio_cwrite(vb->vdev, struct virtio_balloon_config,
+			      poison_val, &poison_val);
 	}
 
 	vb->nb.notifier_call = virtballoon_oom_notify;
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 58f1274..f270e9e 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -48,6 +48,8 @@ struct virtio_balloon_config {
 	__u32 actual;
 	/* Free page report command id, readonly by guest */
 	__u32 free_page_report_cmd_id;
+	/* Stores PAGE_POISON if page poisoning with sanity check is in use */
+	__u32 poison_val;
 };
 
 #define VIRTIO_BALLOON_S_SWAP_IN  0   /* Amount of memory swapped in */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
