Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 526E86B0006
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 10:07:40 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u68-v6so548111qku.5
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 07:07:40 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n83-v6si790580qki.267.2018.07.23.07.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 07:07:38 -0700 (PDT)
Date: Mon, 23 Jul 2018 17:07:23 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v36 0/5] Virtio-balloon: support free page reporting
Message-ID: <20180723122342-mutt-send-email-mst@kernel.org>
References: <1532075585-39067-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532075585-39067-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com, dgilbert@redhat.com

On Fri, Jul 20, 2018 at 04:33:00PM +0800, Wei Wang wrote:
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
>         - Optimization v.s. Legacy = 409ms vs 1757ms --> ~77% reduction
> 	(setting page poisoning zero and enabling ksm don't affect the
>          comparison result)
>     - Guest with Linux Compilation Workload (make bzImage -j4):
>         - Live Migration Time (average)
>           Optimization v.s. Legacy = 1407ms v.s. 2528ms --> ~44% reduction
>         - Linux Compilation Time
>           Optimization v.s. Legacy = 5min4s v.s. 5min12s
>           --> no obvious difference

I'd like to see dgilbert's take on whether this kind of gain
justifies adding a PV interfaces, and what kind of guest workload
is appropriate.

Cc'd.


> ChangeLog:
> v35->v36:
>     - remove the mm patch, as Linus has a suggestion to get free page
>       addresses via allocation, instead of reading from the free page
>       list.
>     - virtio-balloon:
>         - replace oom notifier with shrinker;
>         - the guest to host communication interface remains the same as
>           v32.
> 	- allocate free page blocks and send to host one by one, and free
>           them after sending all the pages.
> 
> For ChangeLogs from v22 to v35, please reference
> https://lwn.net/Articles/759413/
> 
> For ChangeLogs before v21, please reference
> https://lwn.net/Articles/743660/
> 
> Wei Wang (5):
>   virtio-balloon: remove BUG() in init_vqs
>   virtio_balloon: replace oom notifier with shrinker
>   virtio-balloon: VIRTIO_BALLOON_F_FREE_PAGE_HINT
>   mm/page_poison: expose page_poisoning_enabled to kernel modules
>   virtio-balloon: VIRTIO_BALLOON_F_PAGE_POISON
> 
>  drivers/virtio/virtio_balloon.c     | 456 ++++++++++++++++++++++++++++++------
>  include/uapi/linux/virtio_balloon.h |   7 +
>  mm/page_poison.c                    |   6 +
>  3 files changed, 394 insertions(+), 75 deletions(-)
> 
> -- 
> 2.7.4
