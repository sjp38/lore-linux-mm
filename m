Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A29AE6B61F3
	for <linux-mm@kvack.org>; Sun,  2 Dec 2018 01:13:27 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id ay11so7490900plb.20
        for <linux-mm@kvack.org>; Sat, 01 Dec 2018 22:13:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p2sor12651339pgn.83.2018.12.01.22.13.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 01 Dec 2018 22:13:25 -0800 (PST)
Date: Sun, 2 Dec 2018 11:47:07 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v2 0/9] Use vm_insert_range
Message-ID: <20181202061707.GA3070@jordon-HP-15-Notebook-PC>
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
be generalized by creating a new function and use it across
the drivers.

vm_insert_range is the new API which will be used to map a
range of kernel memory/pages to user vma.

All the applicable places are converted to use new vm_insert_range
in this patch series.

v1 -> v2:
	Address review comment on mm/memory.c. Add EXPORT_SYMBOL
	for vm_insert_range and corrected the documentation part
	for this API.

	In drivers/gpu/drm/xen/xen_drm_front_gem.c, replace err
	with ret as suggested.

	In drivers/iommu/dma-iommu.c, handle the scenario of partial
	mmap() of large buffer by passing *pages + vma->vm_pgoff* to
	vm_insert_range().

Souptick Joarder (9):
  mm: Introduce new vm_insert_range API
  arch/arm/mm/dma-mapping.c: Convert to use vm_insert_range
  drivers/firewire/core-iso.c: Convert to use vm_insert_range
  drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
  drm/xen/xen_drm_front_gem.c: Convert to use vm_insert_range
  iommu/dma-iommu.c: Convert to use vm_insert_range
  videobuf2/videobuf2-dma-sg.c: Convert to use vm_insert_range
  xen/gntdev.c: Convert to use vm_insert_range
  xen/privcmd-buf.c: Convert to use vm_insert_range

 arch/arm/mm/dma-mapping.c                         | 21 +++++--------
 drivers/firewire/core-iso.c                       | 15 ++-------
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c       | 20 ++----------
 drivers/gpu/drm/xen/xen_drm_front_gem.c           | 20 ++++--------
 drivers/iommu/dma-iommu.c                         | 13 ++------
 drivers/media/common/videobuf2/videobuf2-dma-sg.c | 23 +++++---------
 drivers/xen/gntdev.c                              | 11 +++----
 drivers/xen/privcmd-buf.c                         |  8 ++---
 include/linux/mm_types.h                          |  3 ++
 mm/memory.c                                       | 38 +++++++++++++++++++++++
 mm/nommu.c                                        |  7 +++++
 11 files changed, 81 insertions(+), 98 deletions(-)

-- 
1.9.1
