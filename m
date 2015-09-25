Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id B6B256B0255
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 08:15:59 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so19319618wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 05:15:59 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTPS id s4si4457476wjx.172.2015.09.25.05.15.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Sep 2015 05:15:56 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
Subject: [PATCH 2/4] dma-mapping: Tidy up dma_parms default handling
Date: Fri, 25 Sep 2015 13:15:44 +0100
Message-Id: <003734bc1b15a4dd4f4fc1a32109f448509ed846.1443178314.git.robin.murphy@arm.com>
In-Reply-To: <cover.1443178314.git.robin.murphy@arm.com>
References: <cover.1443178314.git.robin.murphy@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: arnd@arndb.de, m.szyprowski@samsung.com, sumit.semwal@linaro.org, sakari.ailus@iki.fi, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

Many DMA controllers and other devices set max_segment_size to
indicate their scatter-gather capability, but have no interest in
segment_boundary_mask. However, the existence of a dma_parms structure
precludes the use of any default value, leaving them as zeros (assuming
a properly kzalloc'ed structure). If a well-behaved IOMMU (or SWIOTLB)
then tries to respect this by ensuring a mapped segment does not cross
a zero-byte boundary, hilarity ensues.

Since zero is a nonsensical value for either parameter, treat it as an
indicator for "default", as might be expected. In the process, clean up
a bit by replacing the bare constants with slightly more meaningful
macros and removing the superfluous "else" statements.

Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Sumit Semwal <sumit.semwal@linaro.org>
Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---
 include/linux/dma-mapping.h | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index ac07ff0..ac9af22 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -145,7 +145,9 @@ static inline void arch_teardown_dma_ops(struct device =
*dev) { }
=20
 static inline unsigned int dma_get_max_seg_size(struct device *dev)
 {
-=09return dev->dma_parms ? dev->dma_parms->max_segment_size : 65536;
+=09if (dev->dma_parms && dev->dma_parms->max_segment_size)
+=09=09return dev->dma_parms->max_segment_size;
+=09return SZ_64K;
 }
=20
 static inline unsigned int dma_set_max_seg_size(struct device *dev,
@@ -154,14 +156,15 @@ static inline unsigned int dma_set_max_seg_size(struc=
t device *dev,
 =09if (dev->dma_parms) {
 =09=09dev->dma_parms->max_segment_size =3D size;
 =09=09return 0;
-=09} else
-=09=09return -EIO;
+=09}
+=09return -EIO;
 }
=20
 static inline unsigned long dma_get_seg_boundary(struct device *dev)
 {
-=09return dev->dma_parms ?
-=09=09dev->dma_parms->segment_boundary_mask : 0xffffffff;
+=09if (dev->dma_parms && dev->dma_parms->segment_boundary_mask)
+=09=09return dev->dma_parms->segment_boundary_mask;
+=09return DMA_BIT_MASK(32);
 }
=20
 static inline int dma_set_seg_boundary(struct device *dev, unsigned long m=
ask)
@@ -169,8 +172,8 @@ static inline int dma_set_seg_boundary(struct device *d=
ev, unsigned long mask)
 =09if (dev->dma_parms) {
 =09=09dev->dma_parms->segment_boundary_mask =3D mask;
 =09=09return 0;
-=09} else
-=09=09return -EIO;
+=09}
+=09return -EIO;
 }
=20
 #ifndef dma_max_pfn
--=20
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
