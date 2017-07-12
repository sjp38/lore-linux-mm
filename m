Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E06C06B0514
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 08:47:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s4so23694690pgr.3
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 05:47:24 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id j10si1876028pfc.13.2017.07.12.05.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 05:47:23 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v12 0/8] Virtio-balloon Enhancement
Date: Wed, 12 Jul 2017 20:40:13 +0800
Message-Id: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com
Cc: virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

This patch series enhances the existing virtio-balloon with the following new
features:
1) fast ballooning: transfer ballooned pages between the guest and host in
chunks using sgs, instead of one by one; and
2) cmdq: a new virtqueue to send commands between the device and driver.
Currently, it supports commands to report memory stats (replace the old statq
mechanism) and report guest unused pages.

Change Log:

v11->v12:
1) xbitmap: use the xbitmap from Matthew Wilcox to record ballooned pages.
2) virtio-ring: enable the driver to build up a desc chain using vring desc.
3) virtio-ring: Add locking to the existing START_USE() and END_USE() macro
to lock/unlock the vq when a vq operation starts/ends.
4) virtio-ring: add virtqueue_kick_sync() and virtqueue_kick_async()
5) virtio-balloon: describe chunks of ballooned pages and free pages blocks
directly using one or more chains of desc from the vq.

v10->v11:
1) virtio_balloon: use vring_desc to describe a chunk;
2) virtio_ring: support to add an indirect desc table to virtqueue;
3)  virtio_balloon: use cmdq to report guest memory statistics.

v9->v10:
1) mm: put report_unused_page_block() under CONFIG_VIRTIO_BALLOON;
2) virtio-balloon: add virtballoon_validate();
3) virtio-balloon: msg format change;
4) virtio-balloon: move miscq handling to a task on system_freezable_wq;
5) virtio-balloon: code cleanup.

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

Matthew Wilcox (1):
  Introduce xbitmap

Wei Wang (6):
  virtio-balloon: coding format cleanup
  xbitmap: add xb_find_next_bit() and xb_zero()
  virtio-balloon: VIRTIO_BALLOON_F_SG
  mm: support reporting free page blocks
  mm: export symbol of next_zone and first_online_pgdat
  virtio-balloon: VIRTIO_BALLOON_F_CMD_VQ

 drivers/virtio/virtio_balloon.c     | 414 ++++++++++++++++++++++++++++++++----
 drivers/virtio/virtio_ring.c        | 224 +++++++++++++++++--
 include/linux/mm.h                  |   5 +
 include/linux/radix-tree.h          |   2 +
 include/linux/virtio.h              |  22 ++
 include/linux/xbitmap.h             |  53 +++++
 include/uapi/linux/virtio_balloon.h |  11 +
 lib/radix-tree.c                    | 164 +++++++++++++-
 mm/mmzone.c                         |   2 +
 mm/page_alloc.c                     |  96 +++++++++
 10 files changed, 926 insertions(+), 67 deletions(-)
 create mode 100644 include/linux/xbitmap.h

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
