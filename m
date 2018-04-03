Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8242C6B0008
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 04:28:46 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id q12-v6so6725106plr.17
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 01:28:46 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n34-v6si9875pld.603.2018.04.03.01.28.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 01:28:45 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v30 0/4] Virtio-balloon: support free page reporting
Date: Wed,  4 Apr 2018 00:10:01 +0800
Message-Id: <1522771805-78927-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

This patch series is separated from the previous "Virtio-balloon
Enhancement" series. The new feature, VIRTIO_BALLOON_F_FREE_PAGE_HINT,  
implemented by this series enables the virtio-balloon driver to report
hints of guest free pages to the host. It can be used to accelerate live
migration of VMs. Here is an introduction of this usage:

Live migration needs to transfer the VM's memory from the source machine
to the destination round by round. For the 1st round, all the VM's memory
is transferred. From the 2nd round, only the pieces of memory that were
written by the guest (after the 1st round) are transferred. One method
that is popularly used by the hypervisor to track which part of memory is
written is to write-protect all the guest memory.

This feature enables the optimization by skipping the transfer of guest
free pages during VM live migration. It is not concerned that the memory
pages are used after they are given to the hypervisor as a hint of the
free pages, because they will be tracked by the hypervisor and transferred
in the subsequent round if they are used and written.

* Tests
- Test Environment
    Host: Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz
    Guest: 8G RAM, 4 vCPU
    Migration setup: migrate_set_speed 100G, migrate_set_downtime 2 second

- Test Results
    - Idle Guest Live Migration Time (results are averaged over 10 runs):
        - Optimization v.s. Legacy = 271ms vs 1769ms --> ~86% reduction
    - Guest with Linux Compilation Workload (make bzImage -j4):
        - Live Migration Time (average)
          Optimization v.s. Legacy = 1265ms v.s. 2634ms --> ~51% reduction
        - Linux Compilation Time
          Optimization v.s. Legacy = 4min56s v.s. 5min3s
          --> no obvious difference

ChangeLog:
v29->v30:
    - mm/walk_free_mem_block: add cond_sched() for each order
v28->v29:
    - mm/page_poison: only expose page_poison_enabled(), rather than more
      changes did in v28, as we are not 100% confident about that for now.
    - virtio-balloon: use a separate buffer for the stop cmd, instead of
      having the start and stop cmd use the same buffer. This avoids the
      corner case that the start cmd is overridden by the stop cmd when
      the host has a delay in reading the start cmd.
v27->v28:
    - mm/page_poison: Move PAGE_POISON to page_poison.c and add a function
      to expose page poison val to kernel modules.
v26->v27:
    - add a new patch to expose page_poisoning_enabled to kernel modules
    - virtio-balloon: set poison_val to 0xaaaaaaaa, instead of 0xaa
v25->v26: virtio-balloon changes only
    - remove kicking free page vq since the host now polls the vq after
      initiating the reporting
    - report_free_page_func: detach all the used buffers after sending
      the stop cmd id. This avoids leaving the detaching burden (i.e.
      overhead) to the next cmd id. Detaching here isn't considered
      overhead since the stop cmd id has been sent, and host has already
      moved formard.
v24->v25:
    - mm: change walk_free_mem_block to return 0 (instead of true) on
          completing the report, and return a non-zero value from the
          callabck, which stops the reporting.
    - virtio-balloon:
        - use enum instead of define for VIRTIO_BALLOON_VQ_INFLATE etc.
        - avoid __virtio_clear_bit when bailing out;
        - a new method to avoid reporting the some cmd id to host twice
        - destroy_workqueue can cancel free page work when the feature is
          negotiated;
        - fail probe when the free page vq size is less than 2.
v23->v24:
    - change feature name VIRTIO_BALLOON_F_FREE_PAGE_VQ to
      VIRTIO_BALLOON_F_FREE_PAGE_HINT
    - kick when vq->num_free < half full, instead of "= half full"
    - replace BUG_ON with bailing out
    - check vb->balloon_wq in probe(), if null, bail out
    - add a new feature bit for page poisoning
    - solve the corner case that one cmd id being sent to host twice
v22->v23:
    - change to kick the device when the vq is half-way full;
    - open-code batch_free_page_sg into add_one_sg;
    - change cmd_id from "uint32_t" to "__virtio32";
    - reserver one entry in the vq for the driver to send cmd_id, instead
      of busywaiting for an available entry;
    - add "stop_update" check before queue_work for prudence purpose for
      now, will have a separate patch to discuss this flag check later;
    - init_vqs: change to put some variables on stack to have simpler
      implementation;
    - add destroy_workqueue(vb->balloon_wq);
v21->v22:
    - add_one_sg: some code and comment re-arrangement
    - send_cmd_id: handle a cornercase

For previous ChangeLog, please reference
https://lwn.net/Articles/743660/

Wei Wang (4):
  mm: support reporting free page blocks
  virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
  mm/page_poison: expose page_poisoning_enabled to kernel modules
  virtio-balloon: VIRTIO_BALLOON_F_PAGE_POISON

 drivers/virtio/virtio_balloon.c     | 267 +++++++++++++++++++++++++++++++-----
 include/linux/mm.h                  |   6 +
 include/uapi/linux/virtio_balloon.h |   7 +
 mm/page_alloc.c                     |  97 +++++++++++++
 mm/page_poison.c                    |   6 +
 5 files changed, 347 insertions(+), 36 deletions(-)

-- 
1.8.3.1
