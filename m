Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6C0D8E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 08:14:49 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id l9so9887490plt.7
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 05:14:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e188sor51650919pgc.19.2018.12.24.05.14.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 05:14:48 -0800 (PST)
Date: Mon, 24 Dec 2018 18:48:41 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v5 0/9] Use vm_insert_range
Message-ID: <20181224131841.GA22017@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@surriel.com, sfr@canb.auug.org.au, rppt@linux.vnet.ibm.com, peterz@infradead.org, linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, kyungmin.park@samsung.com, mchehab@kernel.org, boris.ostrovsky@oracle.com, jgross@suse.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

v1 -> v2:
        Address review comment on mm/memory.c. Add EXPORT_SYMBOL
        for vm_insert_range and corrected the documentation part
        for this API.

        In drivers/gpu/drm/xen/xen_drm_front_gem.c, replace err
        with ret as suggested.

        In drivers/iommu/dma-iommu.c, handle the scenario of partial
        mmap() of large buffer by passing *pages + vma->vm_pgoff* to
        vm_insert_range().

v2 -> v3:
        Declaration of vm_insert_range() moved to include/linux/mm.h

v3 -> v4:
	Address review comments.

	In mm/memory.c. Added error check.

	In arch/arm/mm/dma-mapping.c, remove part of error check as the
	similar is checked inside vm_insert_range.

	In rockchip/rockchip_drm_gem.c, vma->vm_pgoff is respected as
	this might be passed as non zero value considering partial
	mapping of large buffer.

	In iommu/dma-iommu.c, count is modifed as (count - vma->vm_pgoff)
	to handle partial mapping scenario in v2.

v4 -> v5:
	Address review comment on [2/9] and [4/9]

	In arch/arm/mm/dma-mapping.c, added the error check which was removed
	in v4, as without those error check we might end up overrun the page
	array.

	In rockchip/rockchip_drm_gem.c, added error check which was removed in
	v1, as without this it might overrun page array. Adjusted page_count
	parameter before passing it to vm_insert_range().

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

 arch/arm/mm/dma-mapping.c                         | 18 ++++------
 drivers/firewire/core-iso.c                       | 15 ++-------
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c       | 14 ++------
 drivers/gpu/drm/xen/xen_drm_front_gem.c           | 20 ++++-------
 drivers/iommu/dma-iommu.c                         | 13 ++-----
 drivers/media/common/videobuf2/videobuf2-dma-sg.c | 23 ++++---------
 drivers/xen/gntdev.c                              | 11 +++---
 drivers/xen/privcmd-buf.c                         |  8 ++---
 include/linux/mm.h                                |  2 ++
 mm/memory.c                                       | 41 +++++++++++++++++++++++
 mm/nommu.c                                        |  7 ++++
 11 files changed, 83 insertions(+), 89 deletions(-)

-- 
1.9.1
