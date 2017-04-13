Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED2BD6B039F
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:40:01 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 63so20994640pgh.3
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:40:01 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q7si23444825pfq.336.2017.04.13.02.40.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 02:40:01 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v9 0/5] Extend virtio-balloon for fast (de)inflating & fast live migration
Date: Thu, 13 Apr 2017 17:35:03 +0800
Message-Id: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

This patch series implements two optimizations:
1) transfer pages in chuncks between the guest and host;
2) transfer the guest unused pages to the host so that they
can be skipped to migrate in live migration.

Changes:
v8->v9:
1) Split the two new features, VIRTIO_BALLOON_F_BALLOON_CHUNKS and
VIRTIO_BALLOON_F_MISC_VQ, which were mixed together in the previous
implementation;
2) Simpler function to get the free page block.

v7->v8:
1) Use only one chunk format, instead of two.
2) re-write the virtio-balloon implementation patch.
3) commit changes
4) patch re-org

Liang Li (1):
  virtio-balloon: deflate via a page list

Wei Wang (4):
  virtio-balloon: VIRTIO_BALLOON_F_BALLOON_CHUNKS
  mm: function to offer a page block on the free list
  mm: export symbol of next_zone and first_online_pgdat
  virtio-balloon: VIRTIO_BALLOON_F_MISC_VQ

 drivers/virtio/virtio_balloon.c     | 615 +++++++++++++++++++++++++++++++++---
 include/linux/mm.h                  |   3 +
 include/uapi/linux/virtio_balloon.h |  21 ++
 mm/mmzone.c                         |   2 +
 mm/page_alloc.c                     |  87 +++++
 5 files changed, 678 insertions(+), 50 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
