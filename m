Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5001F6B025E
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 03:58:17 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c4so295501222pfb.7
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 00:58:17 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id o187si63334020pga.227.2016.11.30.00.58.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 00:58:16 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH kernel v5 2/5] virtio-balloon: define new feature bit and head struct
Date: Wed, 30 Nov 2016 16:43:14 +0800
Message-Id: <1480495397-23225-3-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, mst@redhat.com, jasowang@redhat.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, pbonzini@redhat.com, Liang Li <liang.z.li@intel.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

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
index 343d7dd..1be4b1f 100644
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
 
+/* Response header structure */
+struct virtio_balloon_resp_hdr {
+	__le64 cmd : 8; /* Distinguish different requests type */
+	__le64 flag: 8; /* Mark status for a specific request type */
+	__le64 id : 16; /* Distinguish requests of a specific type */
+	__le64 data_len: 32; /* Length of the following data, in bytes */
+};
+
+/* Page bitmap header structure */
+struct virtio_balloon_bmap_hdr {
+	struct {
+		__le64 start_pfn : 52; /* start pfn for the bitmap */
+		__le64 page_shift : 6; /* page shift width, in bytes */
+		__le64 bmap_len : 6;  /* bitmap length, in bytes */
+	} head;
+	__le64 bmap[0];
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
