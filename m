Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 97E506B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 14:55:45 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id y6so4544015qka.12
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 11:55:45 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b126si595792qka.42.2018.02.08.11.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 11:55:44 -0800 (PST)
Date: Thu, 8 Feb 2018 21:55:38 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v28 0/4] Virtio-balloon: support free page reporting
Message-ID: <20180208215048-mutt-send-email-mst@kernel.org>
References: <1518083420-11108-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1518083420-11108-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

On Thu, Feb 08, 2018 at 05:50:16PM +0800, Wei Wang wrote:
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
> This feature enables the optimization of the 1st round memory transfer -
> the hypervisor can skip the transfer of guest free pages in the 1st round.
> It is not concerned that the memory pages are used after they are given
> to the hypervisor as a hint of the free pages, because they will be
> tracked by the hypervisor and transferred in the next round if they are
> used and written.

At this point I think it's a good idea to focus on the qemu
side, that code is still not really ready yet.

> * Tests
> - Migration time improvement
> Result:
> Live migration time is reduced to 14% with this optimization.
> Details:
> Local live migration of 8GB idle guest, the legacy live migration takes
> ~1817ms. With this optimization, it takes ~254ms, which reduces the time
> to 14%.



> - Workload tests
> Results:
> Running this feature has no impact on the linux compilation workload
> running inside the guest.

I think you should try something memory intensive. Try asking
qemu migration guys for hints on a good test to run.


> Details:
> Set up a Ping-Pong local live migration, where the guest ceaselessy
> migrates between the source and destination. Linux compilation,
> i.e. make bzImage -j4, is performed during the Ping-Pong migration. The
> legacy case takes 5min14s to finish the compilation. With this
> optimization patched, it takes 5min12s.

How is migration time affected in this case?
 
> ChangeLog:
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
> 
> v21->v22:
>     - add_one_sg: some code and comment re-arrangement
>     - send_cmd_id: handle a cornercase
> 
> For previous ChangeLog, please reference
> https://lwn.net/Articles/743660/
> 
> Wei Wang (4):
>   mm: support reporting free page blocks
>   virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
>   mm/page_poison: add a function to expose page poison val to kernel
>     modules
>   virtio-balloon: VIRTIO_BALLOON_F_PAGE_POISON
> 
>  drivers/virtio/virtio_balloon.c     | 258 +++++++++++++++++++++++++++++++-----
>  include/linux/mm.h                  |   8 ++
>  include/linux/poison.h              |   7 -
>  include/uapi/linux/virtio_balloon.h |   7 +
>  mm/page_alloc.c                     |  96 ++++++++++++++
>  mm/page_poison.c                    |  24 ++++
>  6 files changed, 357 insertions(+), 43 deletions(-)
> 
> -- 
> 2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
