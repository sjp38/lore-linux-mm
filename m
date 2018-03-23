Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C60666B0266
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 14:34:26 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id z13so2641359pgu.5
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:34:26 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0087.outbound.protection.outlook.com. [104.47.41.87])
        by mx.google.com with ESMTPS id q12-v6si9912083pll.419.2018.03.23.11.34.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 11:34:24 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] mmu_notifier contextual information
References: <20180323171748.20359-1-jglisse@redhat.com>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <e22988c5-2d58-45bb-e2f7-c7ca7bdb9e49@amd.com>
Date: Fri, 23 Mar 2018 19:34:04 +0100
MIME-Version: 1.0
In-Reply-To: <20180323171748.20359-1-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Joerg Roedel <joro@8bytes.org>, Paolo Bonzini <pbonzini@redhat.com>, Leon Romanovsky <leonro@mellanox.com>, Artemy Kovalyov <artemyko@mellanox.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>

Am 23.03.2018 um 18:17 schrieb jglisse@redhat.com:
> From: JA(C)rA'me Glisse <jglisse@redhat.com>
>
> This patchset are the improvements to mmu_notifier i wish to discuss
> at next LSF/MM. I am sending now to give time to people to look at
> them and think about them.
>
> git://people.freedesktop.org/~glisse/linux mmu-notifier-rfc
> https://cgit.freedesktop.org/~glisse/linux/log/?h=mmu-notifier-rfc
>
> First patch just use a struct for invalidate_range_start/end arguments
> this make the other 2 patches easier and smaller.
>
> The idea is to provide more information to mmu_notifier listener on
> the context of each invalidation. When a range is invalidated this
> can be for various reasons (munmap, protection change, OOM, ...). If
> listener can distinguish between those it can take better action.
>
> For instance if device driver allocate structure to track a range of
> virtual address prior to this patch it always have to assume that it
> has to free those on each mmu_notifieir callback (having to assume it
> is a munmap) and reallocate those latter when the device try to do
> something with that range again.
>
> OOM is also an interesting case, recently a patchset was added to
> avoid OOM on a mm if a blocking mmu_notifier listener have been
> registered [1]. This can be improve by adding a new OOM event type and
> having listener take special path on those. All mmu_notifier i know
> can easily have a special path for OOM that do not block (beside
> taking a short lived, across driver, spinlock). If mmu_notifier usage
> grows (from a point of view of more process using devices that rely on
> them) then we should also make sure OOM can do its bidding.

+1 for better handling that.

The fact that the OOM killer now avoids processes which might sleep 
during their MM destruction gave me a few sleepless night recently.

Christian.

>
>
> The last part of the patchset is to allow more concurrency between a
> range being invalidated and someone wanting to look at CPU page table
> for a different range of address. I don't have any benchmark for those
> but i expect this will be common with HMM and mirror once we can run
> real workload. It can also replace lot of custom and weird counting
> of active mmu_notifier done listener side (KVM, ODP, ...) with some-
> thing cleaner.
>
>
> I have try to leverage all this in KVM but it did not seems to give any
> significant performance improvements (KVM patches at [2]). Tested with
> the host kernel using this patchset and KVM patches, and running thing
> like kernel compilation in the guest. Maybe it is not the kind of work-
> load that can benefit from this.
>
>
> [1] http://lkml.iu.edu/hypermail/linux/kernel/1712.1/02108.html
> [2] https://cgit.freedesktop.org/~glisse/linux/log/?h=mmu-notifier-rfc-kvm
>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Joerg Roedel <joro@8bytes.org>
> Cc: Christian KA?nig <christian.koenig@amd.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Leon Romanovsky <leonro@mellanox.com>
> Cc: Artemy Kovalyov <artemyko@mellanox.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
> Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: Sudeep Dutt <sudeep.dutt@intel.com>
> Cc: Ashutosh Dixit <ashutosh.dixit@intel.com>
> Cc: Dimitri Sivanich <sivanich@sgi.com>
>
> JA(C)rA'me Glisse (3):
>    mm/mmu_notifier: use struct for invalidate_range_start/end parameters
>    mm/mmu_notifier: provide context information about range invalidation
>    mm/mmu_notifier: keep track of ranges being invalidated
>
>   drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  |  17 ++---
>   drivers/gpu/drm/i915/i915_gem_userptr.c |  13 ++--
>   drivers/gpu/drm/radeon/radeon_mn.c      |  11 +--
>   drivers/infiniband/core/umem_odp.c      |  16 ++--
>   drivers/infiniband/hw/hfi1/mmu_rb.c     |  12 ++-
>   drivers/misc/mic/scif/scif_dma.c        |  10 +--
>   drivers/misc/sgi-gru/grutlbpurge.c      |  13 ++--
>   drivers/xen/gntdev.c                    |   7 +-
>   fs/dax.c                                |   8 +-
>   fs/proc/task_mmu.c                      |   8 +-
>   include/linux/mm.h                      |   3 +-
>   include/linux/mmu_notifier.h            | 129 ++++++++++++++++++++++++++------
>   kernel/events/uprobes.c                 |  11 +--
>   mm/hmm.c                                |  15 ++--
>   mm/huge_memory.c                        |  69 +++++++++--------
>   mm/hugetlb.c                            |  47 ++++++------
>   mm/khugepaged.c                         |  12 +--
>   mm/ksm.c                                |  24 +++---
>   mm/madvise.c                            |  21 +++---
>   mm/memory.c                             |  97 +++++++++++++-----------
>   mm/migrate.c                            |  47 ++++++------
>   mm/mmu_notifier.c                       |  44 +++++++++--
>   mm/mprotect.c                           |  14 ++--
>   mm/mremap.c                             |  12 +--
>   mm/oom_kill.c                           |  19 +++--
>   mm/rmap.c                               |  22 ++++--
>   virt/kvm/kvm_main.c                     |  12 +--
>   27 files changed, 420 insertions(+), 293 deletions(-)
>
