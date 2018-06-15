Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 13B016B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 15:21:29 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o68-v6so8314781qte.0
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 12:21:29 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p4-v6si5590617qtb.276.2018.06.15.12.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 12:21:26 -0700 (PDT)
Date: Fri, 15 Jun 2018 15:21:20 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v33 0/4] Virtio-balloon: support free page reporting
Message-ID: <20180615152120.0c4a47e3@doriath>
In-Reply-To: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On Fri, 15 Jun 2018 12:43:09 +0800
Wei Wang <wei.w.wang@intel.com> wrote:

> This patch series is separated from the previous "Virtio-balloon
> Enhancement" series. The new feature, VIRTIO_BALLOON_F_FREE_PAGE_HINT,  
> implemented by this series enables the virtio-balloon driver to report
> hints of guest free pages to the host. It can be used to accelerate live
> migration of VMs. Here is an introduction of this usage:

So, we have two page hinting solutions being proposed. One is this
series, the other one by Nitesh is intended to improve host memory
utilization by letting the host use unused guest memory[1].

Instead of merging two similar solutions, do we want a more generic
one that solves both problems? Or maybe an unified solution?

[1] https://www.spinics.net/lists/kvm/msg170113.html

> Live migration needs to transfer the VM's memory from the source machine
> to the destination round by round. For the 1st round, all the VM's memory
> is transferred. From the 2nd round, only the pieces of memory that were
> written by the guest (after the 1st round) are transferred. One method
> that is popularly used by the hypervisor to track which part of memory is
> written is to write-protect all the guest memory.
> 
> This feature enables the optimization by skipping the transfer of guest
> free pages during VM live migration. It is not concerned that the memory
> pages are used after they are given to the hypervisor as a hint of the
> free pages, because they will be tracked by the hypervisor and transferred
> in the subsequent round if they are used and written.
> 
> * Tests
> - Test Environment
>     Host: Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz
>     Guest: 8G RAM, 4 vCPU
>     Migration setup: migrate_set_speed 100G, migrate_set_downtime 2 second
> 
> - Test Results
>     - Idle Guest Live Migration Time (results are averaged over 10 runs):
>         - Optimization v.s. Legacy = 278ms vs 1757ms --> ~84% reduction
>     - Guest with Linux Compilation Workload (make bzImage -j4):
>         - Live Migration Time (average)
>           Optimization v.s. Legacy = 1408ms v.s. 2528ms --> ~44% reduction
>         - Linux Compilation Time
>           Optimization v.s. Legacy = 5min3s v.s. 5min12s
>           --> no obvious difference  
> 
> ChangeLog:
> v32->v33:
>     - mm/get_from_free_page_list: The new implementation to get free page
>       hints based on the suggestions from Linus:
>       https://lkml.org/lkml/2018/6/11/764
>       This avoids the complex call chain, and looks more prudent.
>     - virtio-balloon: 
>       - use a fix-sized buffer to get free page hints;
>       - remove the cmd id related interface. Now host can just send a free
>         page hint command to the guest (via the host_cmd config register)
>         to start the reporting. Currentlty the guest reports only the max
>         order free page hints to host, which has generated similar good
>         results as before. But the interface used by virtio-balloon to
>         report can support reporting more orders in the future when there
>         is a need.
> v31->v32:
>     - virtio-balloon:
>         - rename cmd_id_use to cmd_id_active;
>         - report_free_page_func: detach used buffers after host sends a vq
>           interrupt, instead of busy waiting for used buffers.
> v30->v31:
>     - virtio-balloon:
>         - virtio_balloon_send_free_pages: return -EINTR rather than 1 to
>           indicate an active stop requested by host; and add more
>           comments to explain about access to cmd_id_received without
>           locks;
>         -  add_one_sg: add TODO to comments about possible improvement.
> v29->v30:
>     - mm/walk_free_mem_block: add cond_sched() for each order
> v28->v29:
>     - mm/page_poison: only expose page_poison_enabled(), rather than more
>       changes did in v28, as we are not 100% confident about that for now.
>     - virtio-balloon: use a separate buffer for the stop cmd, instead of
>       having the start and stop cmd use the same buffer. This avoids the
>       corner case that the start cmd is overridden by the stop cmd when
>       the host has a delay in reading the start cmd.
> v27->v28:
>     - mm/page_poison: Move PAGE_POISON to page_poison.c and add a function
>       to expose page poison val to kernel modules.
> v26->v27:
>     - add a new patch to expose page_poisoning_enabled to kernel modules
>     - virtio-balloon: set poison_val to 0xaaaaaaaa, instead of 0xaa
> v25->v26: virtio-balloon changes only
>     - remove kicking free page vq since the host now polls the vq after
>       initiating the reporting
>     - report_free_page_func: detach all the used buffers after sending
>       the stop cmd id. This avoids leaving the detaching burden (i.e.
>       overhead) to the next cmd id. Detaching here isn't considered
>       overhead since the stop cmd id has been sent, and host has already
>       moved formard.
> v24->v25:
>     - mm: change walk_free_mem_block to return 0 (instead of true) on
>           completing the report, and return a non-zero value from the
>           callabck, which stops the reporting.
>     - virtio-balloon:
>         - use enum instead of define for VIRTIO_BALLOON_VQ_INFLATE etc.
>         - avoid __virtio_clear_bit when bailing out;
>         - a new method to avoid reporting the some cmd id to host twice
>         - destroy_workqueue can cancel free page work when the feature is
>           negotiated;
>         - fail probe when the free page vq size is less than 2.
> v23->v24:
>     - change feature name VIRTIO_BALLOON_F_FREE_PAGE_VQ to
>       VIRTIO_BALLOON_F_FREE_PAGE_HINT
>     - kick when vq->num_free < half full, instead of "= half full"
>     - replace BUG_ON with bailing out
>     - check vb->balloon_wq in probe(), if null, bail out
>     - add a new feature bit for page poisoning
>     - solve the corner case that one cmd id being sent to host twice
> v22->v23:
>     - change to kick the device when the vq is half-way full;
>     - open-code batch_free_page_sg into add_one_sg;
>     - change cmd_id from "uint32_t" to "__virtio32";
>     - reserver one entry in the vq for the driver to send cmd_id, instead
>       of busywaiting for an available entry;
>     - add "stop_update" check before queue_work for prudence purpose for
>       now, will have a separate patch to discuss this flag check later;
>     - init_vqs: change to put some variables on stack to have simpler
>       implementation;
>     - add destroy_workqueue(vb->balloon_wq);
> v21->v22:
>     - add_one_sg: some code and comment re-arrangement
>     - send_cmd_id: handle a cornercase
> 
> For previous ChangeLog, please reference
> https://lwn.net/Articles/743660/
> 
> Wei Wang (4):
>   mm: add a function to get free page blocks
>   virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
>   mm/page_poison: expose page_poisoning_enabled to kernel modules
>   virtio-balloon: VIRTIO_BALLOON_F_PAGE_POISON
> 
>  drivers/virtio/virtio_balloon.c     | 197 +++++++++++++++++++++++++++++-------
>  include/linux/mm.h                  |   1 +
>  include/uapi/linux/virtio_balloon.h |  16 +++
>  mm/page_alloc.c                     |  52 ++++++++++
>  mm/page_poison.c                    |   6 ++
>  5 files changed, 235 insertions(+), 37 deletions(-)
> 
