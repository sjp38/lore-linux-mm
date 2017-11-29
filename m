Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76FD46B025F
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:11:15 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a10so2225520pgq.3
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:11:15 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id l70si1306764pge.568.2017.11.29.06.11.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 06:11:13 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v18 00/10] Virtio-balloon Enhancement
Date: Wed, 29 Nov 2017 21:55:16 +0800
Message-Id: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com, nilal@redhat.com, riel@redhat.com

This patch series enhances the existing virtio-balloon with the following
new features:
1) fast ballooning: transfer ballooned pages between the guest and host in
chunks using sgs, instead of one array each time; and
2) free page block reporting: a new virtqueue to report guest free pages
to the host.

The second feature can be used to accelerate live migration of VMs. Here
are some details:

Live migration needs to transfer the VM's memory from the source machine
to the destination round by round. For the 1st round, all the VM's memory
is transferred. From the 2nd round, only the pieces of memory that were
written by the guest (after the 1st round) are transferred. One method
that is popularly used by the hypervisor to track which part of memory is
written is to write-protect all the guest memory.

The second feature enables the optimization of the 1st round memory
transfer - the hypervisor can skip the transfer of guest free pages in the
1st round. It is not concerned that the memory pages are used after they
are given to the hypervisor as a hint of the free pages, because they will
be tracked by the hypervisor and transferred in the next round if they are
used and written.

ChangeLog:
v17->v18:
1) patch 1-2: new to solve some tools related compilation issues
2) patch 3: revert to the original xbitmap implementation from Matthew
Wilcox with some minor changes (e.g. comments added to the exported
functions)
3) patch 4: summarize the changes we want to make to patch 3
4) patch 5: add the developer notes as a reminder for users to avoid
concurrent accesses to the ida bitmap
5) patch 6: a new vring API to allow users to directly pass in a physical
address to a vring desc
6) patch 7: ballooning time is reduced from ~490ms to ~440ms with the new
implementation
	- use the new API from patch 6 to send balloon pages
	- xb_preload with "GFP_NOWAIT | __GFP_NOWARN" flag;
	- handle the case when xb_set_page() fails to avoid memory leak;
	- put xb_set_page() under the balloon lock
7) patch 9: simper implementation
	- start free page reporting by sending a new cmd id from the host
	- guest acks the start or stop via adding a cmd id to the free page vq
	- use vb->report_free_page, instead of vb->report_free_page_stop
	- use WRITE_ONCE/READ_ONCE to access vb->report_free_page
	- use the new API from patch 6 to send free pages to avoid the
	  unnecessary use of kaddr.
8) patch 10: new patch to solve the page posioning issue reported by
Michael S. Tsirkin 

v16->v17:
1) patch 1: please check the commit log there;
2) patch 3: included Michael S. Tsirkin patch to fix the potential
deadlock issue;
3) patch 4: use BUG_ON if virtqueue_add_ returns error, which is
expected never to happen;
4) patch 4: add leak_balloon_sg_oom, which is used in the oom case when
VIRTIO_BALLOON_F_SG is in use;
5) patch 6: use config registers, instead of a vq, as the command channel
between the host and guest;
6) patch 6: add the command sequence id support.

v15->v16:
1) mm: stop reporting the free pfn range if the callback returns false;
2) mm: move some implementaion of walk_free_mem_block into a function to
make the code layout looks better;
3) xbitmap: added some optimizations suggested by Matthew, please refer to
the ChangLog in the xbitmap patch for details.
4) xbitmap: added a test suite
5) virtio-balloon: bail out with a warning when virtqueue_add_inbuf returns
an error
6) virtio-balloon: some small code re-arrangement, e.g. detachinf used buf
from the vq before adding a new buf

v14->v15:
1) mm: make the report callback return a bool value - returning 1 to stop
walking through the free page list.
2) virtio-balloon: batching sgs of balloon pages till the vq is full
3) virtio-balloon: create a new workqueue, rather than using the default
system_wq, to queue the free page reporting work item.
4) virtio-balloon: add a ctrl_vq to be a central control plane which will
handle all the future control related commands between the host and guest.
Add free page report as the first feature controlled under ctrl_vq, and
the free_page_vq is a data plane vq dedicated to the transmission of free
page blocks.

v13->v14:
1) xbitmap: move the code from lib/radix-tree.c to lib/xbitmap.c.
2) xbitmap: consolidate the implementation of xb_bit_set/clear/test into
one xb_bit_ops.
3) xbitmap: add documents for the exported APIs.
4) mm: rewrite the function to walk through free page blocks.
5) virtio-balloon: when reporting a free page blcok to the device, if the
vq is full (less likey to happen in practice), just skip reporting this
block, instead of busywaiting till an entry gets released.
6) virtio-balloon: fail the probe function if adding the signal buf in
init_vqs fails.

v12->v13:
1) mm: use a callback function to handle the the free page blocks from the
report function. This avoids exposing the zone internal to a kernel
module.
2) virtio-balloon: send balloon pages or a free page block using a single
sg each time. This has the benefits of simpler implementation with no new
APIs.
3) virtio-balloon: the free_page_vq is used to report free pages only (no
multiple usages interleaving)
4) virtio-balloon: Balloon pages and free page blocks are sent via input
sgs, and the completion signal to the host is sent via an output sg.

v11->v12:
1) xbitmap: use the xbitmap from Matthew Wilcox to record ballooned pages.
2) virtio-ring: enable the driver to build up a desc chain using vring
desc.
3) virtio-ring: Add locking to the existing START_USE() and END_USE()
macro to lock/unlock the vq when a vq operation starts/ends.
4) virtio-ring: add virtqueue_kick_sync() and virtqueue_kick_async()
5) virtio-balloon: describe chunks of ballooned pages and free pages
blocks directly using one or more chains of desc from the vq.

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
  xbitmap: Introduce xbitmap

Wei Wang (9):
  idr: add #include <linux/bug.h>
  radix tree test suite: remove ARRAY_SIZE to avoid redefinition
  xbitmap: potential improvement
  xbitmap: add more operations
  virtio_ring: add a new API, virtqueue_add_one_desc
  virtio-balloon: VIRTIO_BALLOON_F_SG
  mm: support reporting free page blocks
  virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
  virtio-balloon: don't report free pages when page poisoning is enabled

 drivers/virtio/virtio_balloon.c          | 418 +++++++++++++++++++++++++++----
 drivers/virtio/virtio_ring.c             |  94 +++++--
 include/linux/idr.h                      |   1 +
 include/linux/mm.h                       |   6 +
 include/linux/radix-tree.h               |   2 +
 include/linux/virtio.h                   |   6 +
 include/linux/xbitmap.h                  |  55 ++++
 include/uapi/linux/virtio_balloon.h      |   5 +
 lib/Makefile                             |   2 +-
 lib/radix-tree.c                         |  41 ++-
 lib/xbitmap.c                            | 361 ++++++++++++++++++++++++++
 mm/page_alloc.c                          |  91 +++++++
 tools/include/linux/bitmap.h             |  34 +++
 tools/include/linux/kernel.h             |   2 +
 tools/testing/radix-tree/Makefile        |  12 +-
 tools/testing/radix-tree/linux/kernel.h  |   2 -
 tools/testing/radix-tree/linux/xbitmap.h |   1 +
 tools/testing/radix-tree/main.c          |   4 +
 tools/testing/radix-tree/test.h          |   1 +
 19 files changed, 1063 insertions(+), 75 deletions(-)
 create mode 100644 include/linux/xbitmap.h
 create mode 100644 lib/xbitmap.c
 create mode 100644 tools/testing/radix-tree/linux/xbitmap.h

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
