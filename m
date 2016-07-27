Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 28A03828E4
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 21:31:11 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id pp5so12563877pac.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 18:31:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id x69si3370749pfi.273.2016.07.26.18.31.10
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 18:31:10 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v2 repost 5/7] virtio-balloon: define feature bit and head for misc virt queue
Date: Wed, 27 Jul 2016 09:23:34 +0800
Message-Id: <1469582616-5729-6-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, Liang Li <liang.z.li@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

Define a new feature bit which supports a new virtual queue. This
new virtual qeuque is for information exchange between hypervisor
and guest. The VMM hypervisor can make use of this virtual queue
to request the guest do some operations, e.g. drop page cache,
synchronize file system, etc. And the VMM hypervisor can get some
of guest's runtime information through this virtual queue, e.g. the
guest's free page information, which can be used for live migration
optimization.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
---
 include/uapi/linux/virtio_balloon.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index d3b182a..be4880f 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -35,6 +35,7 @@
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_PAGE_BITMAP	3 /* Send page info with bitmap */
+#define VIRTIO_BALLOON_F_MISC_VQ	4 /* Misc info virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -101,4 +102,25 @@ struct balloon_bmap_hdr {
 	__virtio64 bmap_len;
 };
 
+enum balloon_req_id {
+	/* Get free pages information */
+	BALLOON_GET_FREE_PAGES,
+};
+
+enum balloon_flag {
+	/* Have more data for a request */
+	BALLOON_FLAG_CONT,
+	/* No more data for a request */
+	BALLOON_FLAG_DONE,
+};
+
+struct balloon_req_hdr {
+	/* Used to distinguish different request */
+	__virtio16 cmd;
+	/* Reserved */
+	__virtio16 reserved[3];
+	/* Request parameter */
+	__virtio64 param;
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
