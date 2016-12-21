Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5B1D6B0377
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 01:59:03 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g1so311345502pgn.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 22:59:03 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id a62si4775236pge.65.2016.12.20.22.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 22:59:02 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v6 kernel 4/5] virtio-balloon: define flags and head for host request vq
Date: Wed, 21 Dec 2016 14:52:27 +0800
Message-Id: <1482303148-22059-5-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, amit.shah@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, pbonzini@redhat.com, mst@redhat.com, david@redhat.com, aarcange@redhat.com, dgilbert@redhat.com, quintela@redhat.com, Liang Li <liang.z.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

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
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Hildenbrand <david@redhat.com>
---
 include/uapi/linux/virtio_balloon.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 2f850bf..b367020 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -35,6 +35,7 @@
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_PAGE_RANGE	3 /* Send page info with ranges */
+#define VIRTIO_BALLOON_F_HOST_REQ_VQ	4 /* Host request virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -94,4 +95,25 @@ struct virtio_balloon_resp_hdr {
 	__le64 data_len: 32; /* Length of the following data, in bytes */
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
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
