Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 97C886B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 17:56:59 -0400 (EDT)
From: Krishna Reddy <vdumpa@nvidia.com>
Date: Mon, 10 Oct 2011 14:56:31 -0700
Subject: RE: [Linaro-mm-sig] [PATCH 1/2] ARM: initial proof-of-concept IOMMU
 mapper for DMA-mapping
Message-ID: <401E54CE964CD94BAE1EB4A729C7087E37225197F8@HQMAIL04.nvidia.com>
References: <1314971786-15140-1-git-send-email-m.szyprowski@samsung.com>
	<1314971786-15140-2-git-send-email-m.szyprowski@samsung.com>
	<594816116217195c28de13accaf1f9f2.squirrel@www.codeaurora.org>
 <001f01cc786d$d55222c0$7ff66840$%szyprowski@samsung.com>
In-Reply-To: <001f01cc786d$d55222c0$7ff66840$%szyprowski@samsung.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, 'Laura Abbott' <lauraa@codeaurora.org>

Marek,
Here is a patch that has fixes to get SDHC driver work as a DMA IOMMU clien=
t. Here is the overview of changes.

1. Converted the mutex to spinlock to handle atomic context calls and used =
spinlock in necessary places.
2. Implemented arm_iommu_map_page and arm_iommu_unmap_page, which are used =
by MMC host stack.
3. Fixed the bugs identified during testing with SDHC driver.

From: Krishna Reddy <vdumpa@nvidia.com>
Date: Fri, 7 Oct 2011 17:25:59 -0700
Subject: [PATCH] ARM: dma-mapping: Implement arm_iommu_map_page/unmap_page =
and fix issues.

Change-Id: I47a1a0065538fa0a161dd6d551b38079bd8f84fd
---
 arch/arm/include/asm/dma-iommu.h |    3 +-
 arch/arm/mm/dma-mapping.c        |  182 +++++++++++++++++++++-------------=
----
 2 files changed, 102 insertions(+), 83 deletions(-)

diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-io=
mmu.h
index 0b2677e..ad1a4d9 100644
--- a/arch/arm/include/asm/dma-iommu.h
+++ b/arch/arm/include/asm/dma-iommu.h
@@ -7,6 +7,7 @@
 #include <linux/scatterlist.h>
 #include <linux/dma-debug.h>
 #include <linux/kmemcheck.h>
+#include <linux/spinlock_types.h>
=20
 #include <asm/memory.h>
=20
@@ -19,7 +20,7 @@ struct dma_iommu_mapping {
 	unsigned int		order;
 	dma_addr_t		base;
=20
-	struct mutex		lock;
+	spinlock_t		lock;
 };
=20
 int arm_iommu_attach_device(struct device *dev, dma_addr_t base,
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 020bde1..0befd88 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -739,32 +739,42 @@ fs_initcall(dma_debug_do_init);
=20
 /* IOMMU */
=20
-static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping, s=
ize_t size)
+static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
+					size_t size)
 {
-	unsigned int order =3D get_order(size);
 	unsigned int align =3D 0;
 	unsigned int count, start;
+	unsigned long flags;
=20
-	if (order > mapping->order)
-		align =3D (1 << (order - mapping->order)) - 1;
+	count =3D ((PAGE_ALIGN(size) >> PAGE_SHIFT) +
+		 (1 << mapping->order) - 1) >> mapping->order;
=20
-	count =3D ((size >> PAGE_SHIFT) + (1 << mapping->order) - 1) >> mapping->=
order;
-
-	start =3D bitmap_find_next_zero_area(mapping->bitmap, mapping->bits, 0, c=
ount, align);
-	if (start > mapping->bits)
+	spin_lock_irqsave(&mapping->lock, flags);
+	start =3D bitmap_find_next_zero_area(mapping->bitmap, mapping->bits,
+					    0, count, align);
+	if (start > mapping->bits) {
+		spin_unlock_irqrestore(&mapping->lock, flags);
 		return ~0;
+	}
=20
 	bitmap_set(mapping->bitmap, start, count);
+	spin_unlock_irqrestore(&mapping->lock, flags);
=20
 	return mapping->base + (start << (mapping->order + PAGE_SHIFT));
 }
=20
-static inline void __free_iova(struct dma_iommu_mapping *mapping, dma_addr=
_t addr, size_t size)
+static inline void __free_iova(struct dma_iommu_mapping *mapping,
+				dma_addr_t addr, size_t size)
 {
-	unsigned int start =3D (addr - mapping->base) >> (mapping->order + PAGE_S=
HIFT);
-	unsigned int count =3D ((size >> PAGE_SHIFT) + (1 << mapping->order) - 1)=
 >> mapping->order;
+	unsigned int start =3D (addr - mapping->base) >>
+			     (mapping->order + PAGE_SHIFT);
+	unsigned int count =3D ((PAGE_ALIGN(size) >> PAGE_SHIFT) +
+			      (1 << mapping->order) - 1) >> mapping->order;
+	unsigned long flags;
=20
+	spin_lock_irqsave(&mapping->lock, flags);
 	bitmap_clear(mapping->bitmap, start, count);
+	spin_unlock_irqrestore(&mapping->lock, flags);
 }
=20
 static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,=
 gfp_t gfp)
@@ -867,7 +877,7 @@ __iommu_alloc_remap(struct page **pages, size_t size, g=
fp_t gfp, pgprot_t prot)
 static dma_addr_t __iommu_create_mapping(struct device *dev, struct page *=
*pages, size_t size)
 {
 	struct dma_iommu_mapping *mapping =3D dev->archdata.mapping;
-	unsigned int count =3D size >> PAGE_SHIFT;
+	unsigned int count =3D PAGE_ALIGN(size) >> PAGE_SHIFT;
 	dma_addr_t dma_addr, iova;
 	int i, ret =3D ~0;
=20
@@ -892,13 +902,12 @@ fail:
 static int __iommu_remove_mapping(struct device *dev, dma_addr_t iova, siz=
e_t size)
 {
 	struct dma_iommu_mapping *mapping =3D dev->archdata.mapping;
-	unsigned int count =3D size >> PAGE_SHIFT;
+	unsigned int count =3D PAGE_ALIGN(size) >> PAGE_SHIFT;
 	int i;
=20
-	for (i=3D0; i<count; i++) {
-		iommu_unmap(mapping->domain, iova, 0);
-		iova +=3D PAGE_SIZE;
-	}
+	iova =3D iova & PAGE_MASK;
+	for (i=3D0; i<count; i++)
+		iommu_unmap(mapping->domain, iova + i * PAGE_SIZE, 0);
 	__free_iova(mapping, iova, size);
 	return 0;
 }
@@ -906,7 +915,6 @@ static int __iommu_remove_mapping(struct device *dev, d=
ma_addr_t iova, size_t si
 static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
 	    dma_addr_t *handle, gfp_t gfp, struct dma_attrs *attrs)
 {
-	struct dma_iommu_mapping *mapping =3D dev->archdata.mapping;
 	pgprot_t prot =3D __get_dma_pgprot(attrs, pgprot_kernel);
 	struct page **pages;
 	void *addr =3D NULL;
@@ -914,11 +922,9 @@ static void *arm_iommu_alloc_attrs(struct device *dev,=
 size_t size,
 	*handle =3D ~0;
 	size =3D PAGE_ALIGN(size);
=20
-	mutex_lock(&mapping->lock);
-
 	pages =3D __iommu_alloc_buffer(dev, size, gfp);
 	if (!pages)
-		goto err_unlock;
+		goto exit;
=20
 	*handle =3D __iommu_create_mapping(dev, pages, size);
 	if (*handle =3D=3D ~0)
@@ -928,15 +934,13 @@ static void *arm_iommu_alloc_attrs(struct device *dev=
, size_t size,
 	if (!addr)
 		goto err_mapping;
=20
-	mutex_unlock(&mapping->lock);
 	return addr;
=20
 err_mapping:
 	__iommu_remove_mapping(dev, *handle, size);
 err_buffer:
 	__iommu_free_buffer(dev, pages, size);
-err_unlock:
-	mutex_unlock(&mapping->lock);
+exit:
 	return NULL;
 }
=20
@@ -944,11 +948,9 @@ static int arm_iommu_mmap_attrs(struct device *dev, st=
ruct vm_area_struct *vma,
 		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
 		    struct dma_attrs *attrs)
 {
-	unsigned long user_size;
 	struct arm_vmregion *c;
=20
 	vma->vm_page_prot =3D __get_dma_pgprot(attrs, vma->vm_page_prot);
-	user_size =3D (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
=20
 	c =3D arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
 	if (c) {
@@ -981,11 +983,9 @@ static int arm_iommu_mmap_attrs(struct device *dev, st=
ruct vm_area_struct *vma,
 void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
 			  dma_addr_t handle, struct dma_attrs *attrs)
 {
-	struct dma_iommu_mapping *mapping =3D dev->archdata.mapping;
 	struct arm_vmregion *c;
 	size =3D PAGE_ALIGN(size);
=20
-	mutex_lock(&mapping->lock);
 	c =3D arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
 	if (c) {
 		struct page **pages =3D c->priv;
@@ -993,7 +993,6 @@ void arm_iommu_free_attrs(struct device *dev, size_t si=
ze, void *cpu_addr,
 		__iommu_remove_mapping(dev, handle, size);
 		__iommu_free_buffer(dev, pages, size);
 	}
-	mutex_unlock(&mapping->lock);
 }
=20
 static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
@@ -1001,80 +1000,93 @@ static int __map_sg_chunk(struct device *dev, struc=
t scatterlist *sg,
 			  enum dma_data_direction dir)
 {
 	struct dma_iommu_mapping *mapping =3D dev->archdata.mapping;
-	dma_addr_t dma_addr, iova;
+	dma_addr_t iova;
 	int ret =3D 0;
+	unsigned long i;
+	phys_addr_t phys =3D page_to_phys(sg_page(sg));
=20
+	size =3D PAGE_ALIGN(size);
 	*handle =3D ~0;
-	mutex_lock(&mapping->lock);
=20
-	iova =3D dma_addr =3D __alloc_iova(mapping, size);
-	if (dma_addr =3D=3D 0)
-		goto fail;
-
-	while (size) {
-		unsigned int phys =3D page_to_phys(sg_page(sg));
-		unsigned int len =3D sg->offset + sg->length;
+	iova =3D __alloc_iova(mapping, size);
+	if (iova =3D=3D 0)
+		return -ENOMEM;
=20
-		if (!arch_is_coherent())
-			__dma_page_cpu_to_dev(sg_page(sg), sg->offset, sg->length, dir);
-
-		while (len) {
-			ret =3D iommu_map(mapping->domain, iova, phys, 0, 0);
-			if (ret < 0)
-				goto fail;
-			iova +=3D PAGE_SIZE;
-			len -=3D PAGE_SIZE;
-			size -=3D PAGE_SIZE;
-		}
-		sg =3D sg_next(sg);
+	if (!arch_is_coherent())
+		__dma_page_cpu_to_dev(sg_page(sg), sg->offset,
+					sg->length, dir);
+	for (i =3D 0; i < (size >> PAGE_SHIFT); i++) {
+		ret =3D iommu_map(mapping->domain, iova + i * PAGE_SIZE,
+				phys + i * PAGE_SIZE, 0, 0);
+		if (ret < 0)
+			goto fail;
 	}
-
-	*handle =3D dma_addr;
-	mutex_unlock(&mapping->lock);
+	*handle =3D iova;
=20
 	return 0;
 fail:
+	while (i--)
+		iommu_unmap(mapping->domain, iova + i * PAGE_SIZE, 0);
+
 	__iommu_remove_mapping(dev, iova, size);
-	mutex_unlock(&mapping->lock);
 	return ret;
 }
=20
+static dma_addr_t arm_iommu_map_page(struct device *dev, struct page *page=
,
+	     unsigned long offset, size_t size, enum dma_data_direction dir,
+	     struct dma_attrs *attrs)
+{
+	dma_addr_t dma_addr;
+
+	if (!arch_is_coherent())
+		__dma_page_cpu_to_dev(page, offset, size, dir);
+
+	BUG_ON((offset+size) > PAGE_SIZE);
+	dma_addr =3D __iommu_create_mapping(dev, &page, PAGE_SIZE);
+	return dma_addr + offset;
+}
+
+static void arm_iommu_unmap_page(struct device *dev, dma_addr_t handle,
+		size_t size, enum dma_data_direction dir,
+		struct dma_attrs *attrs)
+{
+	struct dma_iommu_mapping *mapping =3D dev->archdata.mapping;
+	phys_addr_t phys;
+
+	phys =3D iommu_iova_to_phys(mapping->domain, handle);
+	__iommu_remove_mapping(dev, handle, size);
+	if (!arch_is_coherent())
+		__dma_page_dev_to_cpu(pfn_to_page(__phys_to_pfn(phys)),
+				      phys & ~PAGE_MASK, size, dir);
+}
+
 int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, int nents=
,
 		     enum dma_data_direction dir, struct dma_attrs *attrs)
 {
-	struct scatterlist *s =3D sg, *dma =3D sg, *start =3D sg;
-	int i, count =3D 1;
-	unsigned int offset =3D s->offset;
-	unsigned int size =3D s->offset + s->length;
+	struct scatterlist *s;
+	unsigned int size;
+	int i, count =3D 0;
=20
-	for (i =3D 1; i < nents; i++) {
+	for_each_sg(sg, s, nents, i) {
 		s->dma_address =3D ~0;
 		s->dma_length =3D 0;
+		size =3D s->offset + s->length;
=20
-		s =3D sg_next(s);
-
-		if (s->offset || (size & (PAGE_SIZE - 1))) {
-			if (__map_sg_chunk(dev, start, size, &dma->dma_address, dir) < 0)
-				goto bad_mapping;
-
-			dma->dma_address +=3D offset;
-			dma->dma_length =3D size;
+		if (__map_sg_chunk(dev, s, size, &s->dma_address, dir) < 0)
+			goto bad_mapping;
=20
-			size =3D offset =3D s->offset;
-			start =3D s;
-			dma =3D sg_next(dma);
-			count +=3D 1;
-		}
-		size +=3D sg->length;
+		s->dma_address +=3D s->offset;
+		s->dma_length =3D s->length;
+		count++;
 	}
-	__map_sg_chunk(dev, start, size, &dma->dma_address, dir);
-	d->dma_address +=3D offset;
=20
 	return count;
=20
 bad_mapping:
-	for_each_sg(sg, s, count-1, i)
-		__iommu_remove_mapping(dev, sg_dma_address(s), sg_dma_len(s));
+	for_each_sg(sg, s, count, i) {
+		__iommu_remove_mapping(dev, sg_dma_address(s),
+					PAGE_ALIGN(sg_dma_len(s)));
+	}
 	return 0;
 }
=20
@@ -1086,9 +1098,11 @@ void arm_iommu_unmap_sg(struct device *dev, struct s=
catterlist *sg, int nents,
=20
 	for_each_sg(sg, s, nents, i) {
 		if (sg_dma_len(s))
-			__iommu_remove_mapping(dev, sg_dma_address(s), sg_dma_len(s));
+			__iommu_remove_mapping(dev, sg_dma_address(s),
+						sg_dma_len(s));
 		if (!arch_is_coherent())
-			__dma_page_dev_to_cpu(sg_page(sg), sg->offset, sg->length, dir);
+			__dma_page_dev_to_cpu(sg_page(s), s->offset,
+						s->length, dir);
 	}
 }
=20
@@ -1108,7 +1122,8 @@ void arm_iommu_sync_sg_for_cpu(struct device *dev, st=
ruct scatterlist *sg,
=20
 	for_each_sg(sg, s, nents, i)
 		if (!arch_is_coherent())
-			__dma_page_dev_to_cpu(sg_page(sg), sg->offset, sg->length, dir);
+			__dma_page_dev_to_cpu(sg_page(s), s->offset,
+						s->length, dir);
 }
=20
 /**
@@ -1126,13 +1141,16 @@ void arm_iommu_sync_sg_for_device(struct device *de=
v, struct scatterlist *sg,
=20
 	for_each_sg(sg, s, nents, i)
 		if (!arch_is_coherent())
-			__dma_page_cpu_to_dev(sg_page(sg), sg->offset, sg->length, dir);
+			__dma_page_cpu_to_dev(sg_page(s), s->offset,
+						s->length, dir);
 }
=20
 struct dma_map_ops iommu_ops =3D {
 	.alloc		=3D arm_iommu_alloc_attrs,
 	.free		=3D arm_iommu_free_attrs,
 	.mmap		=3D arm_iommu_mmap_attrs,
+	.map_page	=3D arm_iommu_map_page,
+	.unmap_page	=3D arm_iommu_unmap_page,
 	.map_sg			=3D arm_iommu_map_sg,
 	.unmap_sg		=3D arm_iommu_unmap_sg,
 	.sync_sg_for_cpu	=3D arm_iommu_sync_sg_for_cpu,
@@ -1157,7 +1175,7 @@ int arm_iommu_attach_device(struct device *dev, dma_a=
ddr_t base, size_t size, in
 	mapping->base =3D base;
 	mapping->bits =3D bitmap_size;
 	mapping->order =3D order;
-	mutex_init(&mapping->lock);
+	spin_lock_init(&mapping->lock);
=20
 	mapping->domain =3D iommu_domain_alloc();
 	if (!mapping->domain)
--=20
1.7.0.4

--
nvpublic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
