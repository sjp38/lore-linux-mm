Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E0FB6B0261
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 03:58:25 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y71so10147575pgd.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 00:58:25 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 91si34823411ply.117.2016.11.30.00.58.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 00:58:24 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH kernel v5 4/5] virtio-balloon: define flags and head for host request vq
Date: Wed, 30 Nov 2016 16:43:16 +0800
Message-Id: <1480495397-23225-5-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, mst@redhat.com, jasowang@redhat.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, pbonzini@redhat.com, Liang Li <liang.z.li@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

Define the flags and head struct for a new host request virtual
queue. Guest can get requests from host and then responds to them on
this new virtual queue.
Host can make use of this virtual queue to request the guest do some
operations, e.g. drop page cache, synchronize file system, etc.
And the hypervisor can get some of guest's runtime information
through this virtual queue too, e.g. the guest's unused page
information, which can be used for live migration optimization.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 include/uapi/linux/virtio_balloon.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 1be4b1f..5ac3a40 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -35,6 +35,7 @@
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_PAGE_BITMAP	3 /* Send page info with bitmap */
+#define VIRTIO_BALLOON_F_HOST_REQ_VQ	4 /* Host request virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -101,4 +102,25 @@ struct virtio_balloon_bmap_hdr {
 	__le64 bmap[0];
 };
 
+enum virtio_balloon_req_id {
+	/* Get unused page information */
+	BALLOON_GET_UNUSED_PAGES,
+};
+
+enum virtio_balloon_flag {
+	/* Have more data for a request */
+	BALLOON_FLAG_CONT,
+	/* No more data for a request */
+	BALLOON_FLAG_DONE,
+};
+
+struct virtio_balloon_req_hdr {
+	/* Used to distinguish different requests */
+	__le16 cmd;
+	/* Reserved */
+	__le16 reserved[3];
+	/* Request parameter */
+	__le64 param;
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
