Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 44147828F4
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 07:46:54 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p63so156517307wmp.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 04:46:54 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id d95si22955423wma.48.2016.02.09.04.46.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 04:46:53 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id c200so3230322wme.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 04:46:52 -0800 (PST)
Date: Tue, 9 Feb 2016 13:46:49 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 01/31] mm, gup: introduce concept of "foreign"
 get_user_pages()
Message-ID: <20160209124649.GA20153@gmail.com>
References: <20160129181642.98E7D468@viggo.jf.intel.com>
 <20160129181644.74134A5D@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160129181644.74134A5D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, dave.hansen@linux.intel.com, srikar@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz


* Dave Hansen <dave@sr71.net> wrote:

> 
> OK, so I've fixed up my build process to _actually_ build the
> nommu code.
> 
> One of Vlastimil's comments made me go dig back in to the uprobes
> code's use of get_user_pages().  I decided to change both of them
> to be "foreign" accesses.
> 
> This also fixes the nommu breakage that Vlastimil noted last time.
> 
> Srikar, I'd appreciate if you can have a look at the uprobes.c
> modifications, especially the comment.  I don't think this will
> change any behavior, but I want to make sure the comment is
> accurate.
> 
> ---
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> For protection keys, we need to understand whether protections
> should be enforced in software or not.  In general, we enforce
> protections when working on our own task, but not when on others.
> We call these "current" and "foreign" operations.
> 
> This patch introduces a new get_user_pages() variant:
> 
> 	get_user_pages_foreign()
> 
> We modify the vanilla get_user_pages() so it can no longer be
> used on mm/tasks other than 'current/current->mm', which is by
> far the most common way it is called.  Using it makes a few of
> the call sites look a bit nicer.
> 
> In other words, get_user_pages_foreign() is a replacement for
> when get_user_pages() is called on non-current tsk/mm.
> 
> This also switches get_user_pages_(un)locked() over to be like
> get_user_pages() and not take a tsk/mm.  There is no
> get_user_pages_foreign_(un)locked().  If someone wants that
> behavior they just have to use "__" variant and pass in
> FOLL_FOREIGN explicitly.
> 
> The uprobes is_trap_at_addr() location holds mmap_sem and
> calls get_user_pages(current->mm) on an instruction address.  This
> makes it a pretty unique gup caller.  Being an instruction access
> and also really originating from the kernel (vs. the app), I opted
> to consider this a 'foreign' access where protection keys will not
> be enforced.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Acked-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: jack@suse.cz
> ---
> 
>  b/arch/cris/arch-v32/drivers/cryptocop.c        |    8 ---
>  b/arch/ia64/kernel/err_inject.c                 |    3 -
>  b/arch/mips/mm/gup.c                            |    3 -
>  b/arch/s390/mm/gup.c                            |    4 -
>  b/arch/sh/mm/gup.c                              |    2 
>  b/arch/sparc/mm/gup.c                           |    2 
>  b/arch/x86/mm/gup.c                             |    2 
>  b/arch/x86/mm/mpx.c                             |    4 -
>  b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c       |    3 -
>  b/drivers/gpu/drm/etnaviv/etnaviv_gem.c         |    2 
>  b/drivers/gpu/drm/i915/i915_gem_userptr.c       |    2 
>  b/drivers/gpu/drm/radeon/radeon_ttm.c           |    3 -
>  b/drivers/gpu/drm/via/via_dmablit.c             |    3 -
>  b/drivers/infiniband/core/umem.c                |    2 
>  b/drivers/infiniband/core/umem_odp.c            |    8 +--
>  b/drivers/infiniband/hw/mthca/mthca_memfree.c   |    3 -
>  b/drivers/infiniband/hw/qib/qib_user_pages.c    |    3 -
>  b/drivers/infiniband/hw/usnic/usnic_uiom.c      |    2 
>  b/drivers/media/pci/ivtv/ivtv-udma.c            |    4 -
>  b/drivers/media/pci/ivtv/ivtv-yuv.c             |   10 +---
>  b/drivers/media/v4l2-core/videobuf-dma-sg.c     |    3 -
>  b/drivers/misc/mic/scif/scif_rma.c              |    2 
>  b/drivers/misc/sgi-gru/grufault.c               |    3 -
>  b/drivers/scsi/st.c                             |    2 
>  b/drivers/staging/rdma/ipath/ipath_user_pages.c |    3 -
>  b/drivers/video/fbdev/pvr2fb.c                  |    4 -
>  b/drivers/virt/fsl_hypervisor.c                 |    5 --
>  b/fs/exec.c                                     |    8 ++-
>  b/include/linux/mm.h                            |   21 +++++----
>  b/kernel/events/uprobes.c                       |   10 +++-
>  b/mm/frame_vector.c                             |    2 
>  b/mm/gup.c                                      |   52 +++++++++++++++---------
>  b/mm/ksm.c                                      |    2 
>  b/mm/memory.c                                   |    2 
>  b/mm/mempolicy.c                                |    6 +-
>  b/mm/nommu.c                                    |   30 ++++++++-----
>  b/mm/process_vm_access.c                        |   11 +++--
>  b/mm/util.c                                     |    4 -
>  b/net/ceph/pagevec.c                            |    2 
>  b/security/tomoyo/domain.c                      |    9 +++-
>  b/virt/kvm/async_pf.c                           |    7 ++-
>  b/virt/kvm/kvm_main.c                           |   10 ++--
>  42 files changed, 148 insertions(+), 123 deletions(-)

So this patch conflicts with recent upstream changes:

  patching file drivers/scsi/st.c
  can't find file to patch at input line 463

mind respinning it against v4.5-rc3 or so?

Also, please split this into three patches:

 - one patch adds the _foreign() GUP variant and applies it to code that uses it
   on remote tasks.

 - introduce the new get_user_pages() but also add macros so that both 8-parameter 
   and 7-parameter variants work without breaking the build. We can remove the 
   compatibility wrapping on v4.6 or so.

 - the third will be a large but trivial patch, which will change 8-parameter GUP 
   usage to 7-parameter usage.

... this should reduce the pain from the GUP interface change churn.

Agreed?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
