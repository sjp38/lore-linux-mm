Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D579E6B025F
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 02:43:14 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h186so650858554pfg.2
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 23:43:14 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id d10si35396154pag.94.2016.08.07.23.43.14
        for <linux-mm@kvack.org>;
        Sun, 07 Aug 2016 23:43:14 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v3 kernel 2/7] virtio-balloon: define new feature bit and page bitmap head
Date: Mon,  8 Aug 2016 14:35:29 +0800
Message-Id: <1470638134-24149-3-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
References: <1470638134-24149-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, Liang Li <liang.z.li@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

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
Cc: Dave Hansen <dave.hansen@intel.com>
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
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
