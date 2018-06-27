Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D48E76B0010
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 07:06:40 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id s63-v6so1652300qkc.7
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 04:06:40 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f5-v6si3448540qvi.257.2018.06.27.04.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 04:06:36 -0700 (PDT)
Subject: Re: [PATCH v34 0/4] Virtio-balloon: support free page reporting
References: <1529928312-30500-1-git-send-email-wei.w.wang@intel.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <c4dd0a13-91fb-c0f5-b41f-54421fdacca9@redhat.com>
Date: Wed, 27 Jun 2018 13:06:32 +0200
MIME-Version: 1.0
In-Reply-To: <1529928312-30500-1-git-send-email-wei.w.wang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On 25.06.2018 14:05, Wei Wang wrote:
> This patch series is separated from the previous "Virtio-balloon
> Enhancement" series. The new feature, VIRTIO_BALLOON_F_FREE_PAGE_HINT,  
> implemented by this series enables the virtio-balloon driver to report
> hints of guest free pages to the host. It can be used to accelerate live
> migration of VMs. Here is an introduction of this usage:
> 
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
>         - Optimization v.s. Legacy = 284ms vs 1757ms --> ~84% reduction
>     - Guest with Linux Compilation Workload (make bzImage -j4):
>         - Live Migration Time (average)
>           Optimization v.s. Legacy = 1402ms v.s. 2528ms --> ~44% reduction
>         - Linux Compilation Time
>           Optimization v.s. Legacy = 5min6s v.s. 5min12s
>           --> no obvious difference
> 

Being in version 34 already, this whole thing still looks and feels like
a big hack to me. It might just be me, but especially if I read about
assumptions like "QEMU will not hotplug memory during migration". This
does not feel like a clean solution.

I am still not sure if we really need this interface, especially as real
free page hinting might be on its way.

a) we perform free page hinting by setting all free pages
(arch_free_page()) to zero. Migration will detect zero pages and
minimize #pages to migrate. I don't think this is a good idea but Michel
suggested to do a performance evaluation and Nitesh is looking into that
right now.

b) we perform free page hinting using something that Nitesh proposed. We
get in QEMU blocks of free pages that we can MADV_FREE. In addition we
could e.g. clear the dirty bit of these pages in the dirty bitmap, to
hinder them from getting migrated. Right now the hinting mechanism is
synchronous (called from arch_free_page()) but we might be able to
convert it into something asynchronous.

So we might be able to completely get rid of this interface. And looking
at all the discussions and problems that already happened during the
development of this series, I think we should rather look into how clean
free page hinting might solve the same problem.

If it can't be solved using free page hinting, fair enough.


> ChangeLog:
> v33->v34:
>     - mm:
>         - add a new API max_free_page_blocks, which estimates the max
>           number of free page blocks that a free page list may have
>         - get_from_free_page_list: store addresses to multiple arrays,
>           instead of just one array. This removes the limitation of being
>           able to report only 2TB free memory (the largest array memory
>           that can be allocated on x86 is 4MB, which can store 2^19
>           addresses of 4MB free page blocks).
>     - virtio-balloon:
>         - Allocate multiple arrays to load free page hints;
>         - Use the same method in v32 to do guest/host interaction, the
>           differeces are
>               - the hints are tranferred array by array, instead of
>                 one by one.
> 	      - send the free page block size of a hint along with the cmd
>                 id to host, so that host knows each address represents e.g.
>                 a 4MB memory in our case. 
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
> 
> 
> Wei Wang (4):
>   mm: support to get hints of free page blocks
>   virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
>   mm/page_poison: expose page_poisoning_enabled to kernel modules
>   virtio-balloon: VIRTIO_BALLOON_F_PAGE_POISON
> 
>  drivers/virtio/virtio_balloon.c     | 357 ++++++++++++++++++++++++++++++++----
>  include/linux/mm.h                  |   3 +
>  include/uapi/linux/virtio_balloon.h |  14 ++
>  mm/page_alloc.c                     |  82 +++++++++
>  mm/page_poison.c                    |   6 +
>  5 files changed, 426 insertions(+), 36 deletions(-)
> 


-- 

Thanks,

David / dhildenb
