Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 03BF48E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:54:54 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id w124so1850863oif.3
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 14:54:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s8sor10217417oib.42.2019.01.23.14.54.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 14:54:52 -0800 (PST)
MIME-Version: 1.0
References: <20190123222315.1122-1-jglisse@redhat.com>
In-Reply-To: <20190123222315.1122-1-jglisse@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Jan 2019 14:54:40 -0800
Message-ID: <CAPcyv4i9_T9779ZyaYt2T3b20-wQTaWA4P63+49TM=a=twtDVw@mail.gmail.com>
Subject: Re: [PATCH v4 0/9] mmu notifier provide context informations
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>, Felix Kuehling <Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, KVM list <kvm@vger.kernel.org>, Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>

On Wed, Jan 23, 2019 at 2:23 PM <jglisse@redhat.com> wrote:
>
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>
> Hi Andrew, i see that you still have my event patch in you queue [1].
> This patchset replace that single patch and is broken down in further
> step so that it is easier to review and ascertain that no mistake were
> made during mechanical changes. Here are the step:
>
>     Patch 1 - add the enum values
>     Patch 2 - coccinelle semantic patch to convert all call site of
>               mmu_notifier_range_init to default enum value and also
>               to passing down the vma when it is available
>     Patch 3 - update many call site to more accurate enum values
>     Patch 4 - add the information to the mmu_notifier_range struct
>     Patch 5 - helper to test if a range is updated to read only
>
> All the remaining patches are update to various driver to demonstrate
> how this new information get use by device driver. I build tested
> with make all and make all minus everything that enable mmu notifier
> ie building with MMU_NOTIFIER=3Dno. Also tested with some radeon,amd
> gpu and intel gpu.
>
> If they are no objections i believe best plan would be to merge the
> the first 5 patches (all mm changes) through your queue for 5.1 and
> then to delay driver update to each individual driver tree for 5.2.
> This will allow each individual device driver maintainer time to more
> thouroughly test this more then my own testing.
>
> Note that i also intend to use this feature further in nouveau and
> HMM down the road. I also expect that other user like KVM might be
> interested into leveraging this new information to optimize some of
> there secondary page table invalidation.

"Down the road" users should introduce the functionality they want to
consume. The common concern with preemptively including
forward-looking infrastructure is realizing later that the
infrastructure is not needed, or needs changing. If it has no current
consumer, leave it out.

>
> Here is an explaination on the rational for this patchset:
>
>
> CPU page table update can happens for many reasons, not only as a result
> of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
> as a result of kernel activities (memory compression, reclaim, migration,
> ...).
>
> This patch introduce a set of enums that can be associated with each of
> the events triggering a mmu notifier. Latter patches take advantages of
> those enum values.
>
> - UNMAP: munmap() or mremap()
> - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
> - PROTECTION_VMA: change in access protections for the range
> - PROTECTION_PAGE: change in access protections for page in the range
> - SOFT_DIRTY: soft dirtyness tracking
>
> Being able to identify munmap() and mremap() from other reasons why the
> page table is cleared is important to allow user of mmu notifier to
> update their own internal tracking structure accordingly (on munmap or
> mremap it is not longer needed to track range of virtual address as it
> becomes invalid).

The only context information consumed in this patch set is
MMU_NOTIFY_PROTECTION_VMA.

What is the practical benefit of these "optimize out the case when a
range is updated to read only" optimizations? Any numbers to show this
is worth the code thrash?

>
> [1] https://www.ozlabs.org/~akpm/mmotm/broken-out/mm-mmu_notifier-context=
ual-information-for-event-triggering-invalidation-v2.patch
>
> Cc: Christian K=C3=B6nig <christian.koenig@amd.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: kvm@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-fsdevel@vger.kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
>
> J=C3=A9r=C3=B4me Glisse (9):
>   mm/mmu_notifier: contextual information for event enums
>   mm/mmu_notifier: contextual information for event triggering
>     invalidation
>   mm/mmu_notifier: use correct mmu_notifier events for each invalidation
>   mm/mmu_notifier: pass down vma and reasons why mmu notifier is
>     happening
>   mm/mmu_notifier: mmu_notifier_range_update_to_read_only() helper
>   gpu/drm/radeon: optimize out the case when a range is updated to read
>     only
>   gpu/drm/amdgpu: optimize out the case when a range is updated to read
>     only
>   gpu/drm/i915: optimize out the case when a range is updated to read
>     only
>   RDMA/umem_odp: optimize out the case when a range is updated to read
>     only
>
>  drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c  | 13 ++++++++
>  drivers/gpu/drm/i915/i915_gem_userptr.c | 16 ++++++++++
>  drivers/gpu/drm/radeon/radeon_mn.c      | 13 ++++++++
>  drivers/infiniband/core/umem_odp.c      | 22 +++++++++++--
>  fs/proc/task_mmu.c                      |  3 +-
>  include/linux/mmu_notifier.h            | 42 ++++++++++++++++++++++++-
>  include/rdma/ib_umem_odp.h              |  1 +
>  kernel/events/uprobes.c                 |  3 +-
>  mm/huge_memory.c                        | 14 +++++----
>  mm/hugetlb.c                            | 11 ++++---
>  mm/khugepaged.c                         |  3 +-
>  mm/ksm.c                                |  6 ++--
>  mm/madvise.c                            |  3 +-
>  mm/memory.c                             | 25 +++++++++------
>  mm/migrate.c                            |  5 ++-
>  mm/mmu_notifier.c                       | 10 ++++++
>  mm/mprotect.c                           |  4 ++-
>  mm/mremap.c                             |  3 +-
>  mm/oom_kill.c                           |  3 +-
>  mm/rmap.c                               |  6 ++--
>  20 files changed, 171 insertions(+), 35 deletions(-)
>
> --
> 2.17.2
>
