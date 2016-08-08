Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 857B36B0263
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 02:43:28 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so582133024pac.3
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 23:43:28 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id d10si35396154pag.94.2016.08.07.23.43.27
        for <linux-mm@kvack.org>;
        Sun, 07 Aug 2016 23:43:27 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v3 kernel 6/7] virtio-balloon: define feature bit and head for misc virt queue
Date: Mon,  8 Aug 2016 14:35:33 +0800
Message-Id: <1470638134-24149-7-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
References: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, Liang Li <liang.z.li@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

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
Cc: Dave Hansen <dave.hansen@intel.com>
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
