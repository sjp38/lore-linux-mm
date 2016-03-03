Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0E585828E5
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 05:53:10 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 124so13101040pfg.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 02:53:10 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id n3si28302940pfb.123.2016.03.03.02.53.09
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 02:53:09 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [RFC kernel 0/2]A PV solution for KVM live migration optimization 
Date: Thu,  3 Mar 2016 18:46:57 +0800
Message-Id: <1457002019-15998-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, pbonzini@redhat.com, rth@twiddle.net, ehabkost@redhat.com, quintela@redhat.com, amit.shah@redhat.com, qemu-devel@nongnu.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, dgilbert@redhat.com, Liang Li <liang.z.li@intel.com>

The current QEMU live migration implementation mark the all the
guest's RAM pages as dirtied in the ram bulk stage, all these pages
will be processed and that takes quit a lot of CPU cycles.

>From guest's point of view, it doesn't care about the content in free
pages. We can make use of this fact and skip processing the free
pages in the ram bulk stage, it can save a lot CPU cycles and reduce
the network traffic significantly while speed up the live migration
process obviously.

This patch set is the kernel side implementation.

It get the free pages information by traversing
zone->free_area[order].free_list, and construct a free pages bitmap.
The virtio-balloon driver is extended so as to send the free pages
bitmap to QEMU for live migration optimization.

Performance data
================

Test environment:

CPU: Intel (R) Xeon(R) CPU ES-2699 v3 @ 2.30GHz
Host RAM: 64GB
Host Linux Kernel:  4.2.0             Host OS: CentOS 7.1
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

Liang Li (2):
  mm: Add the functions used to get free pages information
  virtio-balloon: extend balloon driver to support a new feature

 drivers/virtio/virtio_balloon.c     | 108 ++++++++++++++++++++++++++++++++++--
 include/uapi/linux/virtio_balloon.h |   1 +
 mm/page_alloc.c                     |  58 +++++++++++++++++++
 3 files changed, 162 insertions(+), 5 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
