Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0E156B0069
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 09:17:13 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id r85so5236683ywg.6
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 06:17:13 -0700 (PDT)
Received: from st11p00im-asmtp003.me.com (st11p00im-asmtp003.me.com. [17.172.80.97])
        by mx.google.com with ESMTPS id q5si1668631ywe.122.2017.10.01.06.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Oct 2017 06:17:12 -0700 (PDT)
Received: from process-dkim-sign-daemon.st11p00im-asmtp003.me.com by
 st11p00im-asmtp003.me.com
 (Oracle Communications Messaging Server 8.0.1.2.20170607 64bit (built Jun  7
 2017)) id <0OX500J00ASW2000@st11p00im-asmtp003.me.com> for linux-mm@kvack.org;
 Sun, 01 Oct 2017 13:17:01 +0000 (GMT)
MIME-version: 1.0
Content-transfer-encoding: 8BIT
Content-type: text/plain; charset=UTF-8
Message-id: <1506863811.1916.1.camel@icloud.com>
Subject: Re: [PATCH v16 0/5] Virtio-balloon Enhancement
From: Damian Tometzki <damian.tometzki@icloud.com>
Date: Sun, 01 Oct 2017 15:16:51 +0200
In-reply-to: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

Hello,

where i can found the patch in git.kernel.org ?


Am Samstag, den 30.09.2017, 12:05 +0800 schrieb Wei Wang:
> This patch series enhances the existing virtio-balloon with the
> following
> new features:
> 1) fast ballooning: transfer ballooned pages between the guest and
> host in
> chunks using sgs, instead of one array each time; and
> 2) free page block reporting: a new virtqueue to report guest free
> pages
> to the host.
> 
> The second feature can be used to accelerate live migration of VMs.
> Here
> are some details:
> 
> Live migration needs to transfer the VM's memory from the source
> machine
> to the destination round by round. For the 1st round, all the VM's
> memory
> is transferred. From the 2nd round, only the pieces of memory that
> were
> written by the guest (after the 1st round) are transferred. One
> method
> that is popularly used by the hypervisor to track which part of
> memory is
> written is to write-protect all the guest memory.
> 
> The second feature enables the optimization of the 1st round memory
> transfer - the hypervisor can skip the transfer of guest free pages
> in the
> 1st round. It is not concerned that the memory pages are used after
> they
> are given to the hypervisor as a hint of the free pages, because they
> will
> be tracked by the hypervisor and transferred in the next round if
> they are
> used and written.
> 
> Change Log:
> v15->v16:
> 1) mm: stop reporting the free pfn range if the callback returns
> false;
> 2) mm: move some implementaion of walk_free_mem_block into a function
> to
> make the code layout looks better;
> 3) xbitmap: added some optimizations suggested by Matthew, please
> refer to
> the ChangLog in the xbitmap patch for details.
> 4) xbitmap: added a test suite
> 5) virtio-balloon: bail out with a warning when virtqueue_add_inbuf
> returns
> an error
> 6) virtio-balloon: some small code re-arrangement, e.g. detachinf
> used buf
> from the vq before adding a new buf
> 
> v14->v15:
> 1) mm: make the report callback return a bool value - returning 1 to
> stop
> walking through the free page list.
> 2) virtio-balloon: batching sgs of balloon pages till the vq is full
> 3) virtio-balloon: create a new workqueue, rather than using the
> default
> system_wq, to queue the free page reporting work item.
> 4) virtio-balloon: add a ctrl_vq to be a central control plane which
> will
> handle all the future control related commands between the host and
> guest.
> Add free page report as the first feature controlled under ctrl_vq,
> and
> the free_page_vq is a data plane vq dedicated to the transmission of
> free
> page blocks.
> 
> v13->v14:
> 1) xbitmap: move the code from lib/radix-tree.c to lib/xbitmap.c.
> 2) xbitmap: consolidate the implementation of xb_bit_set/clear/test
> into
> one xb_bit_ops.
> 3) xbitmap: add documents for the exported APIs.
> 4) mm: rewrite the function to walk through free page blocks.
> 5) virtio-balloon: when reporting a free page blcok to the device, if
> the
> vq is full (less likey to happen in practice), just skip reporting
> this
> block, instead of busywaiting till an entry gets released.
> 6) virtio-balloon: fail the probe function if adding the signal buf
> in
> init_vqs fails.
> 
> v12->v13:
> 1) mm: use a callback function to handle the the free page blocks
> from the
> report function. This avoids exposing the zone internal to a kernel
> module.
> 2) virtio-balloon: send balloon pages or a free page block using a
> single
> sg each time. This has the benefits of simpler implementation with no
> new
> APIs.
> 3) virtio-balloon: the free_page_vq is used to report free pages only
> (no
> multiple usages interleaving)
> 4) virtio-balloon: Balloon pages and free page blocks are sent via
> input
> sgs, and the completion signal to the host is sent via an output sg.
> 
> v11->v12:
> 1) xbitmap: use the xbitmap from Matthew Wilcox to record ballooned
> pages.
> 2) virtio-ring: enable the driver to build up a desc chain using
> vring
> desc.
> 3) virtio-ring: Add locking to the existing START_USE() and END_USE()
> macro to lock/unlock the vq when a vq operation starts/ends.
> 4) virtio-ring: add virtqueue_kick_sync() and virtqueue_kick_async()
> 5) virtio-balloon: describe chunks of ballooned pages and free pages
> blocks directly using one or more chains of desc from the vq.
> 
> v10->v11:
> 1) virtio_balloon: use vring_desc to describe a chunk;
> 2) virtio_ring: support to add an indirect desc table to virtqueue;
> 3)A A virtio_balloon: use cmdq to report guest memory statistics.
> 
> v9->v10:
> 1) mm: put report_unused_page_block() under CONFIG_VIRTIO_BALLOON;
> 2) virtio-balloon: add virtballoon_validate();
> 3) virtio-balloon: msg format change;
> 4) virtio-balloon: move miscq handling to a task on
> system_freezable_wq;
> 5) virtio-balloon: code cleanup.
> 
> v8->v9:
> 1) Split the two new features, VIRTIO_BALLOON_F_BALLOON_CHUNKS and
> VIRTIO_BALLOON_F_MISC_VQ, which were mixed together in the previous
> implementation;
> 2) Simpler function to get the free page block.
> 
> v7->v8:
> 1) Use only one chunk format, instead of two.
> 2) re-write the virtio-balloon implementation patch.
> 3) commit changes
> 4) patch re-org
> 
> Matthew Wilcox (2):
> A  lib/xbitmap: Introduce xbitmap
> A  radix tree test suite: add tests for xbitmap
> 
> Wei Wang (3):
> A  virtio-balloon: VIRTIO_BALLOON_F_SG
> A  mm: support reporting free page blocks
> A  virtio-balloon: VIRTIO_BALLOON_F_CTRL_VQ
> 
> A drivers/virtio/virtio_balloon.cA A A A A A A A A | 437
> +++++++++++++++++++++++++++++---
> A include/linux/mm.hA A A A A A A A A A A A A A A A A A A A A A |A A A 6 +
> A include/linux/radix-tree.hA A A A A A A A A A A A A A |A A A 2 +
> A include/linux/xbitmap.hA A A A A A A A A A A A A A A A A |A A 66 +++++
> A include/uapi/linux/virtio_balloon.hA A A A A |A A 16 ++
> A lib/MakefileA A A A A A A A A A A A A A A A A A A A A A A A A A A A |A A A 2 +-
> A lib/radix-tree.cA A A A A A A A A A A A A A A A A A A A A A A A |A A 42 ++-
> A lib/xbitmap.cA A A A A A A A A A A A A A A A A A A A A A A A A A A | 264 +++++++++++++++++++
> A mm/page_alloc.cA A A A A A A A A A A A A A A A A A A A A A A A A |A A 91 +++++++
> A tools/include/linux/bitmap.hA A A A A A A A A A A A |A A 34 +++
> A tools/include/linux/kernel.hA A A A A A A A A A A A |A A A 2 +
> A tools/testing/radix-tree/MakefileA A A A A A A |A A A 7 +-
> A tools/testing/radix-tree/linux/kernel.h |A A A 2 -
> A tools/testing/radix-tree/main.cA A A A A A A A A |A A A 5 +
> A tools/testing/radix-tree/test.hA A A A A A A A A |A A A 1 +
> A tools/testing/radix-tree/xbitmap.cA A A A A A | 269 ++++++++++++++++++++
> A 16 files changed, 1203 insertions(+), 43 deletions(-)
> A create mode 100644 include/linux/xbitmap.h
> A create mode 100644 lib/xbitmap.c
> A create mode 100644 tools/testing/radix-tree/xbitmap.c
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
