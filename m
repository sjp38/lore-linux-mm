Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 001348E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 06:39:58 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id l12-v6so2277476ljb.11
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 03:39:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q8-v6sor897086ljg.29.2019.01.17.03.39.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 03:39:56 -0800 (PST)
MIME-Version: 1.0
References: <20190111150541.GA2670@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190111150541.GA2670@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 17 Jan 2019 17:09:43 +0530
Message-ID: <CAFqt6zYxCxzGjv3ea+dYQHcmt2P849ZgaVSH=b05m9P4=MTBEA@mail.gmail.com>
Subject: Re: [PATCH 0/9] Use vm_insert_range and vm_insert_range_buggy
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On Fri, Jan 11, 2019 at 8:31 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Previouly drivers have their own way of mapping range of
> kernel pages/memory into user vma and this was done by
> invoking vm_insert_page() within a loop.
>
> As this pattern is common across different drivers, it can
> be generalized by creating new functions and use it across
> the drivers.
>
> vm_insert_range() is the API which could be used to mapped
> kernel memory/pages in drivers which has considered vm_pgoff
>
> vm_insert_range_buggy() is the API which could be used to map
> range of kernel memory/pages in drivers which has not considered
> vm_pgoff. vm_pgoff is passed default as 0 for those drivers.
>
> We _could_ then at a later "fix" these drivers which are using
> vm_insert_range_buggy() to behave according to the normal vm_pgoff
> offsetting simply by removing the _buggy suffix on the function
> name and if that causes regressions, it gives us an easy way to revert.
>
> There is an existing bug in [7/9], where user passed length is not
> verified against object_count. For any value of length > object_count
> it will end up overrun page array which could lead to a potential bug.
> This is fixed as part of these conversion.
>
> Souptick Joarder (9):
>   mm: Introduce new vm_insert_range and vm_insert_range_buggy API
>   arch/arm/mm/dma-mapping.c: Convert to use vm_insert_range
>   drivers/firewire/core-iso.c: Convert to use vm_insert_range_buggy
>   drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
>   drm/xen/xen_drm_front_gem.c: Convert to use vm_insert_range
>   iommu/dma-iommu.c: Convert to use vm_insert_range
>   videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range_buggy
>   xen/gntdev.c: Convert to use vm_insert_range
>   xen/privcmd-buf.c: Convert to use vm_insert_range_buggy

Any further comment on these patches ?

>
>  arch/arm/mm/dma-mapping.c                         | 22 ++----
>  drivers/firewire/core-iso.c                       | 15 +----
>  drivers/gpu/drm/rockchip/rockchip_drm_gem.c       | 17 +----
>  drivers/gpu/drm/xen/xen_drm_front_gem.c           | 18 ++---
>  drivers/iommu/dma-iommu.c                         | 12 +---
>  drivers/media/common/videobuf2/videobuf2-dma-sg.c | 22 ++----
>  drivers/xen/gntdev.c                              | 16 ++---
>  drivers/xen/privcmd-buf.c                         |  8 +--
>  include/linux/mm.h                                |  4 ++
>  mm/memory.c                                       | 81 +++++++++++++++++++++++
>  mm/nommu.c                                        | 14 ++++
>  11 files changed, 129 insertions(+), 100 deletions(-)
>
> --
> 1.9.1
>
