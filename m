Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0B07280250
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 02:37:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 128so45476464pfz.1
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 23:37:21 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 3si1219178pgb.311.2016.10.20.23.37.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 23:37:20 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [RESEND PATCH v3 kernel 6/7] virtio-balloon: define feature bit and head for misc virt queue
Date: Fri, 21 Oct 2016 14:24:39 +0800
Message-Id: <1477031080-12616-7-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com, Liang Li <liang.z.li@intel.com>

Define a new feature bit which supports a new virtual queue. This
new virtual qeuque is for information exchange between hypervisor
and guest. The VMM hypervisor can make use of this virtual queue
to request the guest do some operations, e.g. drop page cache,
synchronize file system, etc. And the VMM hypervisor can get some
of guest's runtime information through this virtual queue, e.g. the
guest's unused page information, which can be used for live migration
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
index d3b182a..3a9d633 100644
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
+	/* Get unused pages information */
+	BALLOON_GET_UNUSED_PAGES,
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
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
