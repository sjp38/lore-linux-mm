Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F18B6B038A
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 00:44:14 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 10so32847475pgb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 21:44:14 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b35si9546908plh.95.2017.03.02.21.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 21:44:13 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v7 kernel 0/5] Extend virtio-balloon for fast (de)inflating & fast live migration
Date: Fri,  3 Mar 2017 13:40:25 +0800
Message-Id: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Wei Wang <wei.w.wang@intel.com>, "Michael S . Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Liang Li <liliang324@gmail.com>

Take over this work from Liang.

This patch series implements two optimizations: 1) transfer pages in chuncks
between the guest and host; 1) transfer the guest unused pages to the host so
that they can be skipped to migrate in live migration.

Please check patch 0003 for more details about optimization 1).

For an idle guest with 8GB RAM, optimization 2) can help shorten the total live
migration time from 2Sec to about 500ms in 10Gbps network
environment. For a guest with quite a lot of page cache and little
unused pages, it's possible to let the guest drop its page cache before
live migration, this case can benefit from this new feature too.

Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Liang Li <liliang324@gmail.com>
Cc: Wei Wang <wei.w.wang@intel.com>

Liang Li (5):
  virtio-balloon: rework deflate to add page to a list
  virtio-balloon: VIRTIO_BALLOON_F_CHUNK_TRANSFER
  virtio-balloon: implementation of VIRTIO_BALLOON_F_CHUNK_TRANSFER
  virtio-balloon: define flags and head for host request vq
  This patch contains two parts:

 drivers/virtio/virtio_balloon.c     | 510 ++++++++++++++++++++++++++++++++----
 include/linux/mm.h                  |   3 +
 include/uapi/linux/virtio_balloon.h |  34 +++
 mm/page_alloc.c                     | 120 +++++++++
 4 files changed, 620 insertions(+), 47 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
