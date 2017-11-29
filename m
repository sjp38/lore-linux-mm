Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 707066B0271
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:11:51 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i14so2215825pgf.13
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:11:51 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id l70si1306764pge.568.2017.11.29.06.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 06:11:50 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v18 10/10] virtio-balloon: don't report free pages when page poisoning is enabled
Date: Wed, 29 Nov 2017 21:55:26 +0800
Message-Id: <1511963726-34070-11-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

The guest free pages should not be discarded by the live migration thread
when page poisoning is enabled with PAGE_POISONING_NO_SANITY=n, because
skipping the transfer of such poisoned free pages will trigger false
positive when new pages are allocated and checked on the destination.
This patch skips the reporting of free pages in the above case.

Reported-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Michal Hocko <mhocko@suse.com>
---
 drivers/virtio/virtio_balloon.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 035bd3a..6ac4cff 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -652,7 +652,9 @@ static void report_free_page(struct work_struct *work)
 	/* Start by sending the obtained cmd id to the host with an outbuf */
 	send_one_desc(vb, vb->free_page_vq, virt_to_phys(&vb->start_cmd_id),
 		      sizeof(uint32_t), false, true, false);
-	walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
+	if (!(page_poisoning_enabled() &&
+	    !IS_ENABLED(CONFIG_PAGE_POISONING_NO_SANITY)))
+		walk_free_mem_block(vb, 0, &virtio_balloon_send_free_pages);
 	/*
 	 * End by sending the stop id to the host with an outbuf. Use the
 	 * non-batching mode here to trigger a kick after adding the stop id.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
