Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA266B0260
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 21:31:01 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ca5so13208813pac.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 18:31:01 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ai2si3394839pad.98.2016.07.26.18.30.59
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 18:30:59 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v2 repost 2/7] virtio-balloon: define new feature bit and page bitmap head
Date: Wed, 27 Jul 2016 09:23:31 +0800
Message-Id: <1469582616-5729-3-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, Liang Li <liang.z.li@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

Add a new feature which supports sending the page information with
a bitmap. The current implementation uses PFNs array, which is not
very efficient. Using bitmap can improve the performance of
inflating/deflating significantly

The page bitmap header will used to tell the host some information
about the page bitmap. e.g. the page size, page bitmap length and
start pfn.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
---
 include/uapi/linux/virtio_balloon.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 343d7dd..d3b182a 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -34,6 +34,7 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_PAGE_BITMAP	3 /* Send page info with bitmap */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -82,4 +83,22 @@ struct virtio_balloon_stat {
 	__virtio64 val;
 } __attribute__((packed));
 
+/* Page bitmap header structure */
+struct balloon_bmap_hdr {
+	/* Used to distinguish different request */
+	__virtio16 cmd;
+	/* Shift width of page in the bitmap */
+	__virtio16 page_shift;
+	/* flag used to identify different status */
+	__virtio16 flag;
+	/* Reserved */
+	__virtio16 reserved;
+	/* ID of the request */
+	__virtio64 req_id;
+	/* The pfn of 0 bit in the bitmap */
+	__virtio64 start_pfn;
+	/* The length of the bitmap, in bytes */
+	__virtio64 bmap_len;
+};
+
 #endif /* _LINUX_VIRTIO_BALLOON_H */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
