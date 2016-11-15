Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7D66B02BC
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:55:36 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so9398604wma.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 13:55:36 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 186si4593158wmu.126.2016.11.15.13.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 13:55:35 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id m203so4543397wma.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 13:55:35 -0800 (PST)
Date: Wed, 16 Nov 2016 00:55:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 02/21] mm: Use vmf->address instead of of
 vmf->virtual_address
Message-ID: <20161115215531.GB23021@node>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-3-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-3-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:24:58AM +0100, Jan Kara wrote:
> Every single user of vmf->virtual_address typed that entry to unsigned
> long before doing anything with it so the type of virtual_address does
> not really provide us any additional safety. Just use masked
> vmf->address which already has the appropriate type.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  arch/powerpc/platforms/cell/spufs/file.c     |  4 ++--
>  arch/x86/entry/vdso/vma.c                    |  4 ++--
>  drivers/char/agp/alpha-agp.c                 |  2 +-
>  drivers/char/mspec.c                         |  2 +-
>  drivers/dax/dax.c                            |  2 +-
>  drivers/gpu/drm/armada/armada_gem.c          |  2 +-
>  drivers/gpu/drm/drm_vm.c                     | 11 ++++++-----
>  drivers/gpu/drm/etnaviv/etnaviv_gem.c        |  7 +++----
>  drivers/gpu/drm/exynos/exynos_drm_gem.c      |  6 +++---
>  drivers/gpu/drm/gma500/framebuffer.c         |  2 +-
>  drivers/gpu/drm/gma500/gem.c                 |  5 ++---
>  drivers/gpu/drm/i915/i915_gem.c              |  2 +-
>  drivers/gpu/drm/msm/msm_gem.c                |  7 +++----
>  drivers/gpu/drm/omapdrm/omap_gem.c           | 20 +++++++++-----------
>  drivers/gpu/drm/tegra/gem.c                  |  4 ++--
>  drivers/gpu/drm/ttm/ttm_bo_vm.c              |  2 +-
>  drivers/gpu/drm/udl/udl_gem.c                |  5 ++---
>  drivers/gpu/drm/vgem/vgem_drv.c              |  2 +-
>  drivers/media/v4l2-core/videobuf-dma-sg.c    |  5 ++---
>  drivers/misc/cxl/context.c                   |  2 +-
>  drivers/misc/sgi-gru/grumain.c               |  2 +-
>  drivers/staging/android/ion/ion.c            |  2 +-
>  drivers/staging/lustre/lustre/llite/vvp_io.c |  9 ++++++---
>  drivers/xen/privcmd.c                        |  2 +-
>  fs/dax.c                                     |  4 ++--
>  include/linux/mm.h                           |  2 --
>  mm/memory.c                                  |  7 +++----
>  27 files changed, 59 insertions(+), 65 deletions(-)
> 
> diff --git a/arch/powerpc/platforms/cell/spufs/file.c b/arch/powerpc/platforms/cell/spufs/file.c
> index 06254467e4dd..e8a31fffcdda 100644
> --- a/arch/powerpc/platforms/cell/spufs/file.c
> +++ b/arch/powerpc/platforms/cell/spufs/file.c
> @@ -236,7 +236,7 @@ static int
>  spufs_mem_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
>  	struct spu_context *ctx	= vma->vm_file->private_data;
> -	unsigned long address = (unsigned long)vmf->virtual_address;
> +	unsigned long address = vmf->address & PAGE_MASK;

These "& PAGE_MASK" everewhere look unnecesary. I don't think we ever
need sub-page address, do we?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
