Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE766B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 08:29:49 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id p65so222978001wmp.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 05:29:49 -0700 (PDT)
Received: from mail.free-electrons.com (down.free-electrons.com. [37.187.137.238])
        by mx.google.com with ESMTP id 202si29606621wmy.77.2016.03.31.05.29.48
        for <linux-mm@kvack.org>;
        Thu, 31 Mar 2016 05:29:48 -0700 (PDT)
From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: [PATCH 0/4] scatterlist: sg_table from virtual pointer
Date: Thu, 31 Mar 2016 14:29:40 +0200
Message-Id: <1459427384-21374-1-git-send-email-boris.brezillon@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, linux-mtd@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dave Gordon <david.s.gordon@intel.com>
Cc: Mark Brown <broonie@kernel.org>, linux-spi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Vinod Koul <vinod.koul@intel.com>, Dan Williams <dan.j.williams@intel.com>, dmaengine@vger.kernel.org, Mauro Carvalho Chehab <m.chehab@samsung.com>, Hans Verkuil <hans.verkuil@cisco.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-media@vger.kernel.org, Boris Brezillon <boris.brezillon@free-electrons.com>, Richard Weinberger <richard@nod.at>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, linux-crypto@vger.kernel.org, Vignesh R <vigneshr@ti.com>, linux-mm@kvack.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org

Hello,

This series has been extracted from another series [1] adding support
for DMA operations in a NAND driver.

The reason I decided to post those patches separately is because they
are touching core stuff, and I'd like to have feedback on these specific
aspects.

The idea is to provide a generic function creating an sg_table from
a virtual pointer and a length. This operation is complicated by
the different memory regions exposed in kernel space. For example,
you have the lowmem region, which guarantees that buffers are
physically contiguous, while the vmalloc region does not.

sg_alloc_table_from_buf() detects in which memory region your buffer
reside, and takes the appropriate precautions when creating the
sg_table. This function also takes an extract parameter, allowing
one to specify extra constraints, like the maximum DMA segment size,
the required and the preferred alignment.

Patch 1 and 2 are implementing sg_alloc_table_from_buf() (patch 1
is needed to properly detect buffers residing in the highmem/kmap
area).

Patch 3 is making use of sg_alloc_table_from_buf() in the spi_map_buf()
function (hopefully, other subsystems/drivers will be able to easily
switch to this function too).

Patch 4 is implementing what I really need: generic functions
to map/unmap a virtual buffer passed through mtd->_read/_write().

I'm not exactly a DMA or MM experts, so that would be great to have
feedbacks on this approach. That's why I added so many people in Cc
even if they're not directly impacted by those patches. Let me know if
you want me to drop/add people from/to the recipient list.

Thanks.

Best Regards,

Boris

[1]http://www.spinics.net/lists/arm-kernel/msg493552.html

Boris Brezillon (4):
  mm: add is_highmem_addr() helper
  scatterlist: add sg_alloc_table_from_buf() helper
  spi: use sg_alloc_table_from_buf()
  mtd: provide helper to prepare buffers for DMA operations

 drivers/mtd/mtdcore.c       |  66 ++++++++++++++++
 drivers/spi/spi.c           |  45 ++---------
 include/linux/highmem.h     |  13 ++++
 include/linux/mtd/mtd.h     |  25 ++++++
 include/linux/scatterlist.h |  24 ++++++
 lib/scatterlist.c           | 183 ++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 316 insertions(+), 40 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
