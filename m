Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3F76B0038
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 06:32:52 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so21829461wms.7
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 03:32:52 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id gr7si32827411wjb.113.2016.11.16.03.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 03:32:51 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id g23so10165784wme.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 03:32:51 -0800 (PST)
Date: Wed, 16 Nov 2016 14:32:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 02/21] mm: Use vmf->address instead of of
 vmf->virtual_address
Message-ID: <20161116113248.GB27027@node.shutemov.name>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-3-git-send-email-jack@suse.cz>
 <20161115215531.GB23021@node>
 <20161116110505.GF21785@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161116110505.GF21785@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Nov 16, 2016 at 12:05:05PM +0100, Jan Kara wrote:
> On Wed 16-11-16 00:55:31, Kirill A. Shutemov wrote:
> > On Fri, Nov 04, 2016 at 05:24:58AM +0100, Jan Kara wrote:
> > > Every single user of vmf->virtual_address typed that entry to unsigned
> > > long before doing anything with it so the type of virtual_address does
> > > not really provide us any additional safety. Just use masked
> > > vmf->address which already has the appropriate type.
> > > 
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > > ---
> > >  arch/powerpc/platforms/cell/spufs/file.c     |  4 ++--
> > >  arch/x86/entry/vdso/vma.c                    |  4 ++--
> > >  drivers/char/agp/alpha-agp.c                 |  2 +-
> > >  drivers/char/mspec.c                         |  2 +-
> > >  drivers/dax/dax.c                            |  2 +-
> > >  drivers/gpu/drm/armada/armada_gem.c          |  2 +-
> > >  drivers/gpu/drm/drm_vm.c                     | 11 ++++++-----
> > >  drivers/gpu/drm/etnaviv/etnaviv_gem.c        |  7 +++----
> > >  drivers/gpu/drm/exynos/exynos_drm_gem.c      |  6 +++---
> > >  drivers/gpu/drm/gma500/framebuffer.c         |  2 +-
> > >  drivers/gpu/drm/gma500/gem.c                 |  5 ++---
> > >  drivers/gpu/drm/i915/i915_gem.c              |  2 +-
> > >  drivers/gpu/drm/msm/msm_gem.c                |  7 +++----
> > >  drivers/gpu/drm/omapdrm/omap_gem.c           | 20 +++++++++-----------
> > >  drivers/gpu/drm/tegra/gem.c                  |  4 ++--
> > >  drivers/gpu/drm/ttm/ttm_bo_vm.c              |  2 +-
> > >  drivers/gpu/drm/udl/udl_gem.c                |  5 ++---
> > >  drivers/gpu/drm/vgem/vgem_drv.c              |  2 +-
> > >  drivers/media/v4l2-core/videobuf-dma-sg.c    |  5 ++---
> > >  drivers/misc/cxl/context.c                   |  2 +-
> > >  drivers/misc/sgi-gru/grumain.c               |  2 +-
> > >  drivers/staging/android/ion/ion.c            |  2 +-
> > >  drivers/staging/lustre/lustre/llite/vvp_io.c |  9 ++++++---
> > >  drivers/xen/privcmd.c                        |  2 +-
> > >  fs/dax.c                                     |  4 ++--
> > >  include/linux/mm.h                           |  2 --
> > >  mm/memory.c                                  |  7 +++----
> > >  27 files changed, 59 insertions(+), 65 deletions(-)
> > > 
> > > diff --git a/arch/powerpc/platforms/cell/spufs/file.c b/arch/powerpc/platforms/cell/spufs/file.c
> > > index 06254467e4dd..e8a31fffcdda 100644
> > > --- a/arch/powerpc/platforms/cell/spufs/file.c
> > > +++ b/arch/powerpc/platforms/cell/spufs/file.c
> > > @@ -236,7 +236,7 @@ static int
> > >  spufs_mem_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> > >  {
> > >  	struct spu_context *ctx	= vma->vm_file->private_data;
> > > -	unsigned long address = (unsigned long)vmf->virtual_address;
> > > +	unsigned long address = vmf->address & PAGE_MASK;
> > 
> > These "& PAGE_MASK" everewhere look unnecesary. I don't think we ever
> > need sub-page address, do we?
> 
> Usually not AFAICT but I was not really sure in some cases (e.g. is
> vm_insert_pfn() and friends really safe to call with unaligned address) so
> I've decided to do a simple search-and-replace for such a wide-scale patch.
> Later we can remove unnecessary masking from places where we are sure it is
> not needed.

I think it should be fine just to zero out ~PAGE_MASK bits of the address
on entrance into handle_mm_fault() or where vmf is initialized.

I believe we only care about these bits on SIGBUS/SEGV/etc. which is
handled by caller.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
