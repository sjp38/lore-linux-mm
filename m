Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 05D198E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:01:44 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id b17so10476163pfc.11
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 07:01:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h9sor53947593pgs.76.2019.01.11.07.01.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 07:01:42 -0800 (PST)
Date: Fri, 11 Jan 2019 20:35:41 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH 0/9] Use vm_insert_range and vm_insert_range_buggy
Message-ID: <20190111150541.GA2670@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@surriel.com, sfr@canb.auug.org.au, rppt@linux.vnet.ibm.com, peterz@infradead.org, linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, kyungmin.park@samsung.com, mchehab@kernel.org, boris.ostrovsky@oracle.com, jgross@suse.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

Previouly drivers have their own way of mapping range of
kernel pages/memory into user vma and this was done by
invoking vm_insert_page() within a loop.

As this pattern is common across different drivers, it can
be generalized by creating new functions and use it across
the drivers.

vm_insert_range() is the API which could be used to mapped
kernel memory/pages in drivers which has considered vm_pgoff

vm_insert_range_buggy() is the API which could be used to map
range of kernel memory/pages in drivers which has not considered
vm_pgoff. vm_pgoff is passed default as 0 for those drivers.

We _could_ then at a later "fix" these drivers which are using
vm_insert_range_buggy() to behave according to the normal vm_pgoff
offsetting simply by removing the _buggy suffix on the function
name and if that causes regressions, it gives us an easy way to revert.

There is an existing bug in [7/9], where user passed length is not
verified against object_count. For any value of length > object_count
it will end up overrun page array which could lead to a potential bug.
This is fixed as part of these conversion.

Souptick Joarder (9):
  mm: Introduce new vm_insert_range and vm_insert_range_buggy API
  arch/arm/mm/dma-mapping.c: Convert to use vm_insert_range
  drivers/firewire/core-iso.c: Convert to use vm_insert_range_buggy
  drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
  drm/xen/xen_drm_front_gem.c: Convert to use vm_insert_range
  iommu/dma-iommu.c: Convert to use vm_insert_range
  videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range_buggy
  xen/gntdev.c: Convert to use vm_insert_range
  xen/privcmd-buf.c: Convert to use vm_insert_range_buggy

 arch/arm/mm/dma-mapping.c                         | 22 ++----
 drivers/firewire/core-iso.c                       | 15 +----
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c       | 17 +----
 drivers/gpu/drm/xen/xen_drm_front_gem.c           | 18 ++---
 drivers/iommu/dma-iommu.c                         | 12 +---
 drivers/media/common/videobuf2/videobuf2-dma-sg.c | 22 ++----
 drivers/xen/gntdev.c                              | 16 ++---
 drivers/xen/privcmd-buf.c                         |  8 +--
 include/linux/mm.h                                |  4 ++
 mm/memory.c                                       | 81 +++++++++++++++++++++++
 mm/nommu.c                                        | 14 ++++
 11 files changed, 129 insertions(+), 100 deletions(-)

-- 
1.9.1
