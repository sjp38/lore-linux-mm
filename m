Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AFD746B3E05
	for <linux-mm@kvack.org>; Sun, 26 Aug 2018 22:02:08 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h65-v6so10349426pfk.18
        for <linux-mm@kvack.org>; Sun, 26 Aug 2018 19:02:08 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id h17-v6si12964984pgj.214.2018.08.26.19.02.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Aug 2018 19:02:07 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v37 0/3] Virtio-balloon: support free page reporting
Date: Mon, 27 Aug 2018 09:32:16 +0800
Message-Id: <1535333539-32420-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, dgilbert@redhat.com
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com, quintela@redhat.com

The new feature, VIRTIO_BALLOON_F_FREE_PAGE_HINT, implemented by this
series enables the virtio-balloon driver to report hints of guest free
pages to host. It can be used to accelerate virtual machine (VM) live
migration. Here is an introduction of this usage:

Live migration needs to transfer the VM's memory from the source machine
to the destination round by round. For the 1st round, all the VM's memory
is transferred. From the 2nd round, only the pieces of memory that were
written by the guest (after the 1st round) are transferred. One method
that is popularly used by the hypervisor to track which part of memory is
written is to have the hypervisor write-protect all the guest memory.

This feature enables the optimization by skipping the transfer of guest
free pages during VM live migration. It is not concerned that the memory
pages are used after they are given to the hypervisor as a hint of the
free pages, because they will be tracked by the hypervisor and transferred
in the subsequent round if they are used and written.

* Tests
1 Test Environment
    Host: Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz
    Migration setup: migrate_set_speed 100G, migrate_set_downtime 400ms

2 Test Results (results are averaged over several repeated runs)
    2.1 Guest setup: 8G RAM, 4 vCPU
        2.1.1 Idle guest live migration time
            Optimization v.s. Legacy = 620ms vs 2970ms
            --> ~79% reduction
        2.1.2 Guest live migration with Linux compilation workload
          (i.e. make bzImage -j4) running
          1) Live Migration Time:
             Optimization v.s. Legacy = 2273ms v.s. 4502ms
             --> ~50% reduction
          2) Linux Compilation Time:
             Optimization v.s. Legacy = 8min42s v.s. 8min43s
             --> no obvious difference

    2.2 Guest setup: 128G RAM, 4 vCPU
        2.2.1 Idle guest live migration time
            Optimization v.s. Legacy = 5294ms vs 41651ms
            --> ~87% reduction
        2.2.2 Guest live migration with Linux compilation workload
          1) Live Migration Time:
            Optimization v.s. Legacy = 8816ms v.s. 54201ms
            --> 84% reduction
          2) Linux Compilation Time:
             Optimization v.s. Legacy = 8min30s v.s. 8min36s
             --> no obvious difference

ChangeLog:
v36->v37:
    - free the reported pages to mm when receives a DONE cmd from host.
      Please see patch 1's commit log for reasons. Please see patch 1's
      commit for detailed explanations.

For ChangeLogs from v22 to v36, please reference
https://lkml.org/lkml/2018/7/20/199

For ChangeLogs before v21, please reference
https://lwn.net/Articles/743660/

Wei Wang (3):
  virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
  mm/page_poison: expose page_poisoning_enabled to kernel modules
  virtio-balloon: VIRTIO_BALLOON_F_PAGE_POISON

 drivers/virtio/virtio_balloon.c     | 374 ++++++++++++++++++++++++++++++++----
 include/uapi/linux/virtio_balloon.h |   8 +
 mm/page_poison.c                    |   6 +
 3 files changed, 355 insertions(+), 33 deletions(-)

-- 
2.7.4
