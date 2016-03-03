Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 98CA26B0253
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:50:37 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fl4so12947070pad.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:50:37 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id s63si11215041pfs.86.2016.03.03.02.50.36
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 02:50:36 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [RFC qemu 0/4] A PV solution for live migration optimization
Date: Thu,  3 Mar 2016 18:44:24 +0800
Message-Id: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: quintela@redhat.com, amit.shah@redhat.com, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org
Cc: mst@redhat.com, akpm@linux-foundation.org, pbonzini@redhat.com, rth@twiddle.net, ehabkost@redhat.com, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, dgilbert@redhat.com, Liang Li <liang.z.li@intel.com>

The current QEMU live migration implementation mark the all the
guest's RAM pages as dirtied in the ram bulk stage, all these pages
will be processed and that takes quit a lot of CPU cycles.

>From guest's point of view, it doesn't care about the content in free
pages. We can make use of this fact and skip processing the free
pages in the ram bulk stage, it can save a lot CPU cycles and reduce
the network traffic significantly while speed up the live migration
process obviously.

This patch set is the QEMU side implementation.

The virtio-balloon is extended so that QEMU can get the free pages
information from the guest through virtio.

After getting the free pages information (a bitmap), QEMU can use it
to filter out the guest's free pages in the ram bulk stage. This make
the live migration process much more efficient.

This RFC version doesn't take the post-copy and RDMA into
consideration, maybe both of them can benefit from this PV solution
by with some extra modifications.

Performance data
================

Test environment:

CPU: Intel (R) Xeon(R) CPU ES-2699 v3 @ 2.30GHz
Host RAM: 64GB
Host Linux Kernel:  4.2.0           Host OS: CentOS 7.1
Guest Linux Kernel:  4.5.rc6        Guest OS: CentOS 6.6
Network:  X540-AT2 with 10 Gigabit connection
Guest RAM: 8GB

Case 1: Idle guest just boots:
============================================
                    | original  |    pv    
-------------------------------------------
total time(ms)      |    1894   |   421
--------------------------------------------
transferred ram(KB) |   398017  |  353242
============================================


Case 2: The guest has ever run some memory consuming workload, the
workload is terminated just before live migration.
============================================
                    | original  |    pv    
-------------------------------------------
total time(ms)      |   7436    |   552
--------------------------------------------
transferred ram(KB) |  8146291  |  361375
============================================

Liang Li (4):
  pc: Add code to get the lowmem form PCMachineState
  virtio-balloon: Add a new feature to balloon device
  migration: not set migration bitmap in setup stage
  migration: filter out guest's free pages in ram bulk stage

 balloon.c                                       | 30 ++++++++-
 hw/i386/pc.c                                    |  5 ++
 hw/i386/pc_piix.c                               |  1 +
 hw/i386/pc_q35.c                                |  1 +
 hw/virtio/virtio-balloon.c                      | 81 ++++++++++++++++++++++++-
 include/hw/i386/pc.h                            |  3 +-
 include/hw/virtio/virtio-balloon.h              | 17 +++++-
 include/standard-headers/linux/virtio_balloon.h |  1 +
 include/sysemu/balloon.h                        | 10 ++-
 migration/ram.c                                 | 64 +++++++++++++++----
 10 files changed, 195 insertions(+), 18 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
