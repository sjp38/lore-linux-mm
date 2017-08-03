Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7C86B065B
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 02:48:34 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v77so5359860pgb.15
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 23:48:34 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z66si1004619pff.284.2017.08.02.23.48.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 23:48:33 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v13 0/5] Virtio-balloon Enhancement
Date: Thu,  3 Aug 2017 14:38:14 +0800
Message-Id: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, mawilcox@microsoft.com, akpm@linux-foundation.org
Cc: virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

This patch series enhances the existing virtio-balloon with the following
new features:
1) fast ballooning: transfer ballooned pages between the guest and host in
chunks using sgs, instead of one by one; and
2) free_page_vq: a new virtqueue to report guest free pages to the host.

The second feature can be used to accelerate live migration of VMs. Here
are some details:

Live migration needs to transfer the VM's memory from the source machine
to the destination round by round. For the 1st round, all the VM's memory
is transferred. From the 2nd round, only the pieces of memory that were
written by the guest (after the 1st round) are transferred. One method
that is popularly used by the hypervisor to track which part of memory is
written is to write-protect all the guest memory.

The second feature  enables the optimization of the 1st round memory
transfer - the hypervisor can skip the transfer of guest free pages in the
1st round. It is not concerned that the memory pages are used after they
are given to the hypervisor as a hint of the free pages, because they will
be tracked by the hypervisor and transferred in the next round if they are
used and written.

Change Log:
v12->v13:
1) mm: use a callback function to handle the the free page blocks from the
report function. This avoids exposing the zone internal to a kernel module.
2) virtio-balloon: send balloon pages or a free page block using a single sg
each time. This has the benefits of simpler implementation with no new APIs.
3) virtio-balloon: the free_page_vq is used to report free pages only (no
multiple usages interleaving)
4) virtio-balloon: Balloon pages and free page blocks are sent via input sgs,
and the completion signal to the host is sent via an output sg.

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

Matthew Wilcox (1):
  Introduce xbitmap

Wei Wang (4):
  xbitmap: add xb_find_next_bit() and xb_zero()
  virtio-balloon: VIRTIO_BALLOON_F_SG
  mm: support reporting free page blocks
  virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ

 drivers/virtio/virtio_balloon.c     | 302 +++++++++++++++++++++++++++++++-----
 include/linux/mm.h                  |   7 +
 include/linux/mmzone.h              |   5 +
 include/linux/radix-tree.h          |   2 +
 include/linux/xbitmap.h             |  53 +++++++
 include/uapi/linux/virtio_balloon.h |   2 +
 lib/radix-tree.c                    | 167 +++++++++++++++++++-
 mm/page_alloc.c                     | 109 +++++++++++++
 8 files changed, 609 insertions(+), 38 deletions(-)
 create mode 100644 include/linux/xbitmap.h

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
