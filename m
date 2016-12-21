Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97C516B0371
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 01:58:43 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 5so351773214pgi.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 22:58:43 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m25si25519639pli.104.2016.12.20.22.58.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 22:58:42 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v6 kernel 2/5] virtio-balloon: define new feature bit and head struct
Date: Wed, 21 Dec 2016 14:52:25 +0800
Message-Id: <1482303148-22059-3-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, amit.shah@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, pbonzini@redhat.com, mst@redhat.com, david@redhat.com, aarcange@redhat.com, dgilbert@redhat.com, quintela@redhat.com, Liang Li <liang.z.li@intel.com>

Add a new feature which supports sending the page information
with range array. The current implementation uses PFNs array,
which is not very efficient. Using ranges can improve the
performance of inflating/deflating significantly.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Hildenbrand <david@redhat.com>
---
 include/uapi/linux/virtio_balloon.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 343d7dd..2f850bf 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -34,10 +34,14 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_PAGE_RANGE	3 /* Send page info with ranges */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
 
+/* Bits width for the length of the pfn range */
+#define VIRTIO_BALLOON_NR_PFN_BITS 12
+
 struct virtio_balloon_config {
 	/* Number of pages host wants Guest to give up. */
 	__u32 num_pages;
@@ -82,4 +86,12 @@ struct virtio_balloon_stat {
 	__virtio64 val;
 } __attribute__((packed));
 
+/* Response header structure */
+struct virtio_balloon_resp_hdr {
+	__le64 cmd : 8; /* Distinguish different requests type */
+	__le64 flag: 8; /* Mark status for a specific request type */
+	__le64 id : 16; /* Distinguish requests of a specific type */
+	__le64 data_len: 32; /* Length of the following data, in bytes */
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
