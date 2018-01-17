Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54ED928027D
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 00:28:26 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id j3so7596099pld.0
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 21:28:26 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f90si2020199plb.641.2018.01.16.21.28.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 21:28:25 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v22 0/3] Virtio-balloon: support free page reporting
Date: Wed, 17 Jan 2018 13:10:09 +0800
Message-Id: <1516165812-3995-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

This patch series is separated from the previous "Virtio-balloon
Enhancement" series. The new feature, VIRTIO_BALLOON_F_FREE_PAGE_VQ,  
implemented by this series enables the virtio-balloon driver to report
hints of guest free pages to the host. It can be used to accelerate live
migration of VMs. Here is an introduction of this usage:

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
v21-v22:
    - add_one_sg: some code and comment re-arrangement
    - send_cmd_id: handle a cornercase

For precious ChangeLog, please reference
https://lwn.net/Articles/743660/

Wei Wang (3):
  mm: support reporting free page blocks
  virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_VQ
  virtio-balloon: don't report free pages when page poisoning is enabled

 drivers/virtio/virtio_balloon.c     | 250 +++++++++++++++++++++++++++++++-----
 include/linux/mm.h                  |   6 +
 include/uapi/linux/virtio_balloon.h |   6 +
 mm/page_alloc.c                     |  91 +++++++++++++
 4 files changed, 321 insertions(+), 32 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
