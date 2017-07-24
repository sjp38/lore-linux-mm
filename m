Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8676B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 07:15:38 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m75so10609225wmb.12
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 04:15:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u88si9018098wrc.546.2017.07.24.04.15.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 04:15:37 -0700 (PDT)
Date: Mon, 24 Jul 2017 13:15:31 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 1/5] mm: add mkwrite param to vm_insert_mixed()
Message-ID: <20170724111531.GG652@quack2.suse.cz>
References: <20170721223956.29485-1-ross.zwisler@linux.intel.com>
 <20170721223956.29485-2-ross.zwisler@linux.intel.com>
 <CAA9_cmdoEVx88FCuCSOB1Qmom_X8uJPB4-uUx7MA3X5H4fZ=GQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmdoEVx88FCuCSOB1Qmom_X8uJPB4-uUx7MA3X5H4fZ=GQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@gmail.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, linux-doc@vger.kernel.org, David Airlie <airlied@linux.ie>, Dave Chinner <david@fromorbit.com>, dri-devel@lists.freedesktop.org, linux-mm <linux-mm@kvack.org>, Andreas Dilger <adilger.kernel@dilger.ca>, Patrik Jakobsson <patrik.r.jakobsson@gmail.com>, Christoph Hellwig <hch@lst.de>, linux-samsung-soc <linux-samsung-soc@vger.kernel.org>, Joonyoung Shim <jy0922.shim@samsung.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Tomi Valkeinen <tomi.valkeinen@ti.com>, Kyungmin Park <kyungmin.park@samsung.com>, Krzysztof Kozlowski <krzk@kernel.org>, Ingo Molnar <mingo@redhat.com>, ext4 hackers <linux-ext4@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-arm-msm@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, Inki Dae <inki.dae@samsung.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Theodore Ts'o <tytso@mit.edu>, Jonathan Corbet <corbet@lwn.net>, Seung-Woo Kim <sw0312.kim@samsung.com>, linux-xfs@vger.kernel.org, Rob Clark <robdclark@gmail.com>, Kukjin Kim <kgene@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, freedreno@lists.freedesktop.org

On Sat 22-07-17 09:21:31, Dan Williams wrote:
> On Fri, Jul 21, 2017 at 3:39 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > To be able to use the common 4k zero page in DAX we need to have our PTE
> > fault path look more like our PMD fault path where a PTE entry can be
> > marked as dirty and writeable as it is first inserted, rather than waiting
> > for a follow-up dax_pfn_mkwrite() => finish_mkwrite_fault() call.
> >
> > Right now we can rely on having a dax_pfn_mkwrite() call because we can
> > distinguish between these two cases in do_wp_page():
> >
> >         case 1: 4k zero page => writable DAX storage
> >         case 2: read-only DAX storage => writeable DAX storage
> >
> > This distinction is made by via vm_normal_page().  vm_normal_page() returns
> > false for the common 4k zero page, though, just as it does for DAX ptes.
> > Instead of special casing the DAX + 4k zero page case, we will simplify our
> > DAX PTE page fault sequence so that it matches our DAX PMD sequence, and
> > get rid of the dax_pfn_mkwrite() helper.  We will instead use
> > dax_iomap_fault() to handle write-protection faults.
> >
> > This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
> > and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set insert_pfn()
> > will do the work that was previously done by wp_page_reuse() as part of the
> > dax_pfn_mkwrite() call path.
> >
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> >  drivers/dax/device.c                    |  2 +-
> >  drivers/gpu/drm/exynos/exynos_drm_gem.c |  3 ++-
> >  drivers/gpu/drm/gma500/framebuffer.c    |  2 +-
> >  drivers/gpu/drm/msm/msm_gem.c           |  3 ++-
> >  drivers/gpu/drm/omapdrm/omap_gem.c      |  6 ++++--
> >  drivers/gpu/drm/ttm/ttm_bo_vm.c         |  2 +-
> >  fs/dax.c                                |  2 +-
> >  include/linux/mm.h                      |  2 +-
> >  mm/memory.c                             | 27 +++++++++++++++++++++------
> >  9 files changed, 34 insertions(+), 15 deletions(-)
> >
> > diff --git a/drivers/dax/device.c b/drivers/dax/device.c
> > index e9f3b3e..3973521 100644
> > --- a/drivers/dax/device.c
> > +++ b/drivers/dax/device.c
> > @@ -273,7 +273,7 @@ static int __dev_dax_pte_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
> >
> >         pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
> >
> > -       rc = vm_insert_mixed(vmf->vma, vmf->address, pfn);
> > +       rc = vm_insert_mixed(vmf->vma, vmf->address, pfn, false);
> 
> Ugh, I generally find bool flags unreadable. They place a tax on
> jumping to function definition to recall what true and false mean. If
> we want to go this 'add an argument' route can we at least add an enum
> like:
> 
> enum {
>     PTE_MKDIRTY,
>     PTE_MKCLEAN,
> };
> 
> ...to differentiate the two cases?

So how I usually deal with this is that I create e.g.:

__vm_insert_mixed() that takes the bool argument, make vm_insert_mixed()
pass false, and vm_insert_mixed_mkwrite() pass true. That way there's no
code duplication, old call sites can stay unchanged, the naming clearly
says what's going on...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
