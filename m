Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A2F466B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:33:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i85so67158543pfa.5
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 00:33:27 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0067.outbound.protection.outlook.com. [104.47.41.67])
        by mx.google.com with ESMTPS id y81si13169396pfk.239.2016.10.13.00.33.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 00:33:26 -0700 (PDT)
Subject: Re: [PATCH 00/10] mm: adjust get_user_pages* functions to explicitly
 pass FOLL_* flags
References: <20161013002020.3062-1-lstoakes@gmail.com>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <914b917f-6871-2ba3-95ba-981dd2855743@amd.com>
Date: Thu, 13 Oct 2016 09:32:51 +0200
MIME-Version: 1.0
In-Reply-To: <20161013002020.3062-1-lstoakes@gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm@kvack.org
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-sh@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, dri-devel@lists.freedesktop.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>, linux-media@vger.kernel.org, Rik van Riel <riel@redhat.com>, intel-gfx@lists.freedesktop.org, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

Am 13.10.2016 um 02:20 schrieb Lorenzo Stoakes:
> This patch series adjusts functions in the get_user_pages* family such that
> desired FOLL_* flags are passed as an argument rather than implied by flags.
>
> The purpose of this change is to make the use of FOLL_FORCE explicit so it is
> easier to grep for and clearer to callers that this flag is being used. The use
> of FOLL_FORCE is an issue as it overrides missing VM_READ/VM_WRITE flags for the
> VMA whose pages we are reading from/writing to, which can result in surprising
> behaviour.
>
> The patch series came out of the discussion around commit 38e0885, which
> addressed a BUG_ON() being triggered when a page was faulted in with PROT_NONE
> set but having been overridden by FOLL_FORCE. do_numa_page() was run on the
> assumption the page _must_ be one marked for NUMA node migration as an actual
> PROT_NONE page would have been dealt with prior to this code path, however
> FOLL_FORCE introduced a situation where this assumption did not hold.
>
> See https://marc.info/?l=linux-mm&m=147585445805166 for the patch proposal.
>
> Lorenzo Stoakes (10):
>    mm: remove write/force parameters from __get_user_pages_locked()
>    mm: remove write/force parameters from __get_user_pages_unlocked()
>    mm: replace get_user_pages_unlocked() write/force parameters with gup_flags
>    mm: replace get_user_pages_locked() write/force parameters with gup_flags
>    mm: replace get_vaddr_frames() write/force parameters with gup_flags
>    mm: replace get_user_pages() write/force parameters with gup_flags
>    mm: replace get_user_pages_remote() write/force parameters with gup_flags
>    mm: replace __access_remote_vm() write parameter with gup_flags
>    mm: replace access_remote_vm() write parameter with gup_flags
>    mm: replace access_process_vm() write parameter with gup_flags

Patch number 6 in this series (which touches drivers I co-maintain) is 
Acked-by: Christian KA?nig <christian.koenig@amd.com>.

In general looks like a very nice cleanup to me, but I'm not enlightened 
enough to full judge.

Regards,
Christian.

>
>   arch/alpha/kernel/ptrace.c                         |  9 ++--
>   arch/blackfin/kernel/ptrace.c                      |  5 ++-
>   arch/cris/arch-v32/drivers/cryptocop.c             |  4 +-
>   arch/cris/arch-v32/kernel/ptrace.c                 |  4 +-
>   arch/ia64/kernel/err_inject.c                      |  2 +-
>   arch/ia64/kernel/ptrace.c                          | 14 +++---
>   arch/m32r/kernel/ptrace.c                          | 15 ++++---
>   arch/mips/kernel/ptrace32.c                        |  5 ++-
>   arch/mips/mm/gup.c                                 |  2 +-
>   arch/powerpc/kernel/ptrace32.c                     |  5 ++-
>   arch/s390/mm/gup.c                                 |  3 +-
>   arch/score/kernel/ptrace.c                         | 10 +++--
>   arch/sh/mm/gup.c                                   |  3 +-
>   arch/sparc/kernel/ptrace_64.c                      | 24 +++++++----
>   arch/sparc/mm/gup.c                                |  3 +-
>   arch/x86/kernel/step.c                             |  3 +-
>   arch/x86/mm/gup.c                                  |  2 +-
>   arch/x86/mm/mpx.c                                  |  5 +--
>   arch/x86/um/ptrace_32.c                            |  3 +-
>   arch/x86/um/ptrace_64.c                            |  3 +-
>   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |  7 ++-
>   drivers/gpu/drm/etnaviv/etnaviv_gem.c              |  7 ++-
>   drivers/gpu/drm/exynos/exynos_drm_g2d.c            |  3 +-
>   drivers/gpu/drm/i915/i915_gem_userptr.c            |  6 ++-
>   drivers/gpu/drm/radeon/radeon_ttm.c                |  3 +-
>   drivers/gpu/drm/via/via_dmablit.c                  |  4 +-
>   drivers/infiniband/core/umem.c                     |  6 ++-
>   drivers/infiniband/core/umem_odp.c                 |  7 ++-
>   drivers/infiniband/hw/mthca/mthca_memfree.c        |  2 +-
>   drivers/infiniband/hw/qib/qib_user_pages.c         |  3 +-
>   drivers/infiniband/hw/usnic/usnic_uiom.c           |  5 ++-
>   drivers/media/pci/ivtv/ivtv-udma.c                 |  4 +-
>   drivers/media/pci/ivtv/ivtv-yuv.c                  |  5 ++-
>   drivers/media/platform/omap/omap_vout.c            |  2 +-
>   drivers/media/v4l2-core/videobuf-dma-sg.c          |  7 ++-
>   drivers/media/v4l2-core/videobuf2-memops.c         |  6 ++-
>   drivers/misc/mic/scif/scif_rma.c                   |  3 +-
>   drivers/misc/sgi-gru/grufault.c                    |  2 +-
>   drivers/platform/goldfish/goldfish_pipe.c          |  3 +-
>   drivers/rapidio/devices/rio_mport_cdev.c           |  3 +-
>   drivers/scsi/st.c                                  |  5 +--
>   .../interface/vchiq_arm/vchiq_2835_arm.c           |  3 +-
>   .../vc04_services/interface/vchiq_arm/vchiq_arm.c  |  3 +-
>   drivers/video/fbdev/pvr2fb.c                       |  4 +-
>   drivers/virt/fsl_hypervisor.c                      |  4 +-
>   fs/exec.c                                          |  9 +++-
>   fs/proc/base.c                                     | 19 +++++---
>   include/linux/mm.h                                 | 18 ++++----
>   kernel/events/uprobes.c                            |  6 ++-
>   kernel/ptrace.c                                    | 16 ++++---
>   mm/frame_vector.c                                  |  9 ++--
>   mm/gup.c                                           | 50 ++++++++++------------
>   mm/memory.c                                        | 16 ++++---
>   mm/mempolicy.c                                     |  2 +-
>   mm/nommu.c                                         | 38 +++++++---------
>   mm/process_vm_access.c                             |  7 ++-
>   mm/util.c                                          |  8 ++--
>   net/ceph/pagevec.c                                 |  2 +-
>   security/tomoyo/domain.c                           |  2 +-
>   virt/kvm/async_pf.c                                |  3 +-
>   virt/kvm/kvm_main.c                                | 11 +++--
>   61 files changed, 260 insertions(+), 187 deletions(-)
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
