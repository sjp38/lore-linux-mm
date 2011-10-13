Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 811986B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 20:18:55 -0400 (EDT)
From: Krishna Reddy <vdumpa@nvidia.com>
Date: Wed, 12 Oct 2011 17:18:00 -0700
Subject: RE: [Linaro-mm-sig] [PATCH 1/2] ARM: initial proof-of-concept IOMMU
 mapper for DMA-mapping
Message-ID: <401E54CE964CD94BAE1EB4A729C7087E3722519EAE@HQMAIL04.nvidia.com>
References: <1314971786-15140-1-git-send-email-m.szyprowski@samsung.com>
	<1314971786-15140-2-git-send-email-m.szyprowski@samsung.com>
	<594816116217195c28de13accaf1f9f2.squirrel@www.codeaurora.org>
	<001f01cc786d$d55222c0$7ff66840$%szyprowski@samsung.com>
	<401E54CE964CD94BAE1EB4A729C7087E37225197F8@HQMAIL04.nvidia.com>
	<00b101cc87ee$8976c410$9c644c30$%szyprowski@samsung.com>
	<401E54CE964CD94BAE1EB4A729C7087E3722519A1F@HQMAIL04.nvidia.com>
	<401E54CE964CD94BAE1EB4A729C7087E3722519BF4@HQMAIL04.nvidia.com>
	<00e501cc88a2$b82fc680$288f5380$%szyprowski@samsung.com>
 <401E54CE964CD94BAE1EB4A729C7087E3722519C65@HQMAIL04.nvidia.com>
In-Reply-To: <401E54CE964CD94BAE1EB4A729C7087E3722519C65@HQMAIL04.nvidia.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Here a patch v2 that has updates/fixes to DMA IOMMU code. With these change=
s, the nvidia device is able to boot with all its platform drivers as DMA I=
OMMU clients.

Here is the overview of changes.

1. Converted the mutex to spinlock to handle atomic context calls and used =
spinlock in necessary places.
2. Implemented arm_iommu_map_page and arm_iommu_unmap_page, which are used =
by MMC host stack.
3. Separated creation of dma_iommu_mapping from arm_iommu_attach_device in =
order to share mapping.
4. Fixed various bugs identified in DMA IOMMU code during testing.




[PATCH] ARM: dma-mapping: Add iommu map_page/unmap_page and fix issues.

Signed-off-by: Krishna Reddy <vdumpa@nvidia.com>
---
 arch/arm/include/asm/dma-iommu.h |   14 ++-
 arch/arm/mm/dma-mapping.c        |  229 +++++++++++++++++++++++++---------=
----
 2 files changed, 161 insertions(+), 82 deletions(-)

diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-io=
mmu.h
index 0b2677e..5f4e37f 100644
--- a/arch/arm/include/asm/dma-iommu.h
+++ b/arch/arm/include/asm/dma-iommu.h
@@ -7,6 +7,8 @@
 #include <linux/scatterlist.h>
 #include <linux/dma-debug.h>
 #include <linux/kmemcheck.h>
+#include <linux/spinlock_types.h>
+#include <linux/kref.h>

 #include <asm/memory.h>

@@ -19,11 +21,17 @@ struct dma_iommu_mapping {
        unsigned int            order;
        dma_addr_t              base;

-       struct mutex            lock;
+       spinlock_t              lock;
+       struct kref             kref;
 };

-int arm_iommu_attach_device(struct device *dev, dma_addr_t base,
-                           dma_addr_t size, int order);
+struct dma_iommu_mapping *arm_iommu_create_mapping(dma_addr_t base,
+                                                   size_t size, int order)=
;
+
+void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping);
+
+int arm_iommu_attach_device(struct device *dev,
+                           struct dma_iommu_mapping *mapping);

 #endif /* __KERNEL__ */
 #endif
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 020bde1..721b7c0 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -739,32 +739,42 @@ fs_initcall(dma_debug_do_init);

 /* IOMMU */

-static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping, s=
ize_t size)
+static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
+                                       size_t size)
 {
-       unsigned int order =3D get_order(size);
        unsigned int align =3D 0;
        unsigned int count, start;
+       unsigned long flags;

-       if (order > mapping->order)
-               align =3D (1 << (order - mapping->order)) - 1;
+       count =3D ((PAGE_ALIGN(size) >> PAGE_SHIFT) +
+                (1 << mapping->order) - 1) >> mapping->order;

-       count =3D ((size >> PAGE_SHIFT) + (1 << mapping->order) - 1) >> map=
ping->order;
-
-       start =3D bitmap_find_next_zero_area(mapping->bitmap, mapping->bits=
, 0, count, align);
-       if (start > mapping->bits)
+       spin_lock_irqsave(&mapping->lock, flags);
+       start =3D bitmap_find_next_zero_area(mapping->bitmap, mapping->bits=
,
+                                           0, count, align);
+       if (start > mapping->bits) {
+               spin_unlock_irqrestore(&mapping->lock, flags);
                return ~0;
+       }

        bitmap_set(mapping->bitmap, start, count);
+       spin_unlock_irqrestore(&mapping->lock, flags);

        return mapping->base + (start << (mapping->order + PAGE_SHIFT));
 }

-static inline void __free_iova(struct dma_iommu_mapping *mapping, dma_addr=
_t addr, size_t size)
+static inline void __free_iova(struct dma_iommu_mapping *mapping,
+                               dma_addr_t addr, size_t size)
 {
-       unsigned int start =3D (addr - mapping->base) >> (mapping->order + =
PAGE_SHIFT);
-       unsigned int count =3D ((size >> PAGE_SHIFT) + (1 << mapping->order=
) - 1) >> mapping->order;
+       unsigned int start =3D (addr - mapping->base) >>
+                            (mapping->order + PAGE_SHIFT);
+       unsigned int count =3D ((PAGE_ALIGN(size) >> PAGE_SHIFT) +
+                             (1 << mapping->order) - 1) >> mapping->order;
+       unsigned long flags;

+       spin_lock_irqsave(&mapping->lock, flags);
        bitmap_clear(mapping->bitmap, start, count);
+       spin_unlock_irqrestore(&mapping->lock, flags);
 }

 static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,=
 gfp_t gfp)
@@ -867,7 +877,7 @@ __iommu_alloc_remap(struct page **pages, size_t size, g=
fp_t gfp, pgprot_t prot)
 static dma_addr_t __iommu_create_mapping(struct device *dev, struct page *=
*pages, size_t size)
 {
        struct dma_iommu_mapping *mapping =3D dev->archdata.mapping;
-       unsigned int count =3D size >> PAGE_SHIFT;
+       unsigned int count =3D PAGE_ALIGN(size) >> PAGE_SHIFT;
        dma_addr_t dma_addr, iova;
        int i, ret =3D ~0;

@@ -892,13 +902,12 @@ fail:
 static int __iommu_remove_mapping(struct device *dev, dma_addr_t iova, siz=
e_t size)
 {
        struct dma_iommu_mapping *mapping =3D dev->archdata.mapping;
-       unsigned int count =3D size >> PAGE_SHIFT;
+       unsigned int count =3D PAGE_ALIGN(size) >> PAGE_SHIFT;
        int i;

-       for (i=3D0; i<count; i++) {
-               iommu_unmap(mapping->domain, iova, 0);
-               iova +=3D PAGE_SIZE;
-       }
+       iova =3D iova & PAGE_MASK;
+       for (i =3D 0; i < count; i++)
+               iommu_unmap(mapping->domain, iova + (i << PAGE_SHIFT), 0);
        __free_iova(mapping, iova, size);
        return 0;
 }
@@ -906,7 +915,6 @@ static int __iommu_remove_mapping(struct device *dev, d=
ma_addr_t iova, size_t si
 static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
            dma_addr_t *handle, gfp_t gfp, struct dma_attrs *attrs)
 {
-       struct dma_iommu_mapping *mapping =3D dev->archdata.mapping;
        pgprot_t prot =3D __get_dma_pgprot(attrs, pgprot_kernel);
        struct page **pages;
        void *addr =3D NULL;
@@ -914,11 +922,9 @@ static void *arm_iommu_alloc_attrs(struct device *dev,=
 size_t size,
        *handle =3D ~0;
        size =3D PAGE_ALIGN(size);

-       mutex_lock(&mapping->lock);
-
        pages =3D __iommu_alloc_buffer(dev, size, gfp);
        if (!pages)
-               goto err_unlock;
+               goto exit;

        *handle =3D __iommu_create_mapping(dev, pages, size);
        if (*handle =3D=3D ~0)
@@ -928,15 +934,13 @@ static void *arm_iommu_alloc_attrs(struct device *dev=
, size_t size,
        if (!addr)
                goto err_mapping;

-       mutex_unlock(&mapping->lock);
        return addr;

 err_mapping:
        __iommu_remove_mapping(dev, *handle, size);
 err_buffer:
        __iommu_free_buffer(dev, pages, size);
-err_unlock:
-       mutex_unlock(&mapping->lock);
+exit:
        return NULL;
 }

@@ -944,11 +948,9 @@ static int arm_iommu_mmap_attrs(struct device *dev, st=
ruct vm_area_struct *vma,
                    void *cpu_addr, dma_addr_t dma_addr, size_t size,
                    struct dma_attrs *attrs)
 {
-       unsigned long user_size;
        struct arm_vmregion *c;

        vma->vm_page_prot =3D __get_dma_pgprot(attrs, vma->vm_page_prot);
-       user_size =3D (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;

        c =3D arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
        if (c) {
@@ -981,11 +983,9 @@ static int arm_iommu_mmap_attrs(struct device *dev, st=
ruct vm_area_struct *vma,
 void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
                          dma_addr_t handle, struct dma_attrs *attrs)
 {
-       struct dma_iommu_mapping *mapping =3D dev->archdata.mapping;
        struct arm_vmregion *c;
        size =3D PAGE_ALIGN(size);

-       mutex_lock(&mapping->lock);
        c =3D arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
        if (c) {
                struct page **pages =3D c->priv;
@@ -993,7 +993,6 @@ void arm_iommu_free_attrs(struct device *dev, size_t si=
ze, void *cpu_addr,
                __iommu_remove_mapping(dev, handle, size);
                __iommu_free_buffer(dev, pages, size);
        }
-       mutex_unlock(&mapping->lock);
 }

 static int __map_sg_chunk(struct device *dev, struct scatterlist *sg,
@@ -1001,80 +1000,118 @@ static int __map_sg_chunk(struct device *dev, stru=
ct scatterlist *sg,
                          enum dma_data_direction dir)
 {
        struct dma_iommu_mapping *mapping =3D dev->archdata.mapping;
-       dma_addr_t dma_addr, iova;
+       dma_addr_t iova;
        int ret =3D 0;
+       unsigned int count, i;
+       struct scatterlist *s;

+       size =3D PAGE_ALIGN(size);
        *handle =3D ~0;
-       mutex_lock(&mapping->lock);

-       iova =3D dma_addr =3D __alloc_iova(mapping, size);
-       if (dma_addr =3D=3D 0)
-               goto fail;
+       iova =3D __alloc_iova(mapping, size);
+       if (iova =3D=3D 0)
+               return -ENOMEM;

-       while (size) {
-               unsigned int phys =3D page_to_phys(sg_page(sg));
-               unsigned int len =3D sg->offset + sg->length;
+       for (count =3D 0, s =3D sg; count < (size >> PAGE_SHIFT); s =3D sg_=
next(s)) {
+               phys_addr_t phys =3D page_to_phys(sg_page(s));
+               unsigned int len =3D PAGE_ALIGN(s->offset + s->length);

                if (!arch_is_coherent())
-                       __dma_page_cpu_to_dev(sg_page(sg), sg->offset, sg->=
length, dir);
+                       __dma_page_cpu_to_dev(sg_page(s), s->offset,
+                                               s->length, dir);

-               while (len) {
-                       ret =3D iommu_map(mapping->domain, iova, phys, 0, 0=
);
+               for (i =3D 0; i < (len >> PAGE_SHIFT); i++) {
+                       ret =3D iommu_map(mapping->domain,
+                               iova + (count << PAGE_SHIFT),
+                               phys + (i << PAGE_SHIFT), 0, 0);
                        if (ret < 0)
                                goto fail;
-                       iova +=3D PAGE_SIZE;
-                       len -=3D PAGE_SIZE;
-                       size -=3D PAGE_SIZE;
+                       count++;
                }
-               sg =3D sg_next(sg);
        }
-
-       *handle =3D dma_addr;
-       mutex_unlock(&mapping->lock);
+       *handle =3D iova;

        return 0;
 fail:
+       while (count--)
+               iommu_unmap(mapping->domain, iova + count * PAGE_SIZE, 0);
        __iommu_remove_mapping(dev, iova, size);
-       mutex_unlock(&mapping->lock);
        return ret;
 }

+static dma_addr_t arm_iommu_map_page(struct device *dev, struct page *page=
,
+            unsigned long offset, size_t size, enum dma_data_direction dir=
,
+            struct dma_attrs *attrs)
+{
+       dma_addr_t dma_addr;
+
+       if (!arch_is_coherent())
+               __dma_page_cpu_to_dev(page, offset, size, dir);
+
+       BUG_ON((offset+size) > PAGE_SIZE);
+       dma_addr =3D __iommu_create_mapping(dev, &page, PAGE_SIZE);
+       return dma_addr + offset;
+}
+
+static void arm_iommu_unmap_page(struct device *dev, dma_addr_t handle,
+               size_t size, enum dma_data_direction dir,
+               struct dma_attrs *attrs)
+{
+       struct dma_iommu_mapping *mapping =3D dev->archdata.mapping;
+       phys_addr_t phys;
+
+       phys =3D iommu_iova_to_phys(mapping->domain, handle);
+       __iommu_remove_mapping(dev, handle, size);
+       if (!arch_is_coherent())
+               __dma_page_dev_to_cpu(pfn_to_page(__phys_to_pfn(phys)),
+                                     phys & ~PAGE_MASK, size, dir);
+}
+
 int arm_iommu_map_sg(struct device *dev, struct scatterlist *sg, int nents=
,
                     enum dma_data_direction dir, struct dma_attrs *attrs)
 {
        struct scatterlist *s =3D sg, *dma =3D sg, *start =3D sg;
-       int i, count =3D 1;
+       int i, count =3D 0;
        unsigned int offset =3D s->offset;
        unsigned int size =3D s->offset + s->length;

+       s->dma_address =3D ~0;
+       s->dma_length =3D 0;
+
        for (i =3D 1; i < nents; i++) {
+               s =3D sg_next(s);
                s->dma_address =3D ~0;
                s->dma_length =3D 0;

-               s =3D sg_next(s);
-
-               if (s->offset || (size & (PAGE_SIZE - 1))) {
-                       if (__map_sg_chunk(dev, start, size, &dma->dma_addr=
ess, dir) < 0)
+               if (s->offset || size & ~PAGE_MASK ||
+                   size + s->length > dma_get_max_seg_size(dev)) {
+                       if (__map_sg_chunk(dev, start, size,
+                                           &dma->dma_address, dir) < 0)
                                goto bad_mapping;

                        dma->dma_address +=3D offset;
-                       dma->dma_length =3D size;
+                       dma->dma_length =3D size - offset;

                        size =3D offset =3D s->offset;
                        start =3D s;
                        dma =3D sg_next(dma);
-                       count +=3D 1;
+                       count++;
                }
-               size +=3D sg->length;
+               size +=3D s->length;
        }
-       __map_sg_chunk(dev, start, size, &dma->dma_address, dir);
-       d->dma_address +=3D offset;

-       return count;
+       if (__map_sg_chunk(dev, start, size, &dma->dma_address, dir) < 0)
+               goto bad_mapping;
+       dma->dma_address +=3D offset;
+       dma->dma_length =3D size - offset;
+
+       return ++count;

 bad_mapping:
-       for_each_sg(sg, s, count-1, i)
-               __iommu_remove_mapping(dev, sg_dma_address(s), sg_dma_len(s=
));
+       for_each_sg(sg, s, count, i) {
+               __iommu_remove_mapping(dev, sg_dma_address(s),
+                                       PAGE_ALIGN(sg_dma_len(s)));
+       }
        return 0;
 }

@@ -1086,9 +1123,11 @@ void arm_iommu_unmap_sg(struct device *dev, struct s=
catterlist *sg, int nents,

        for_each_sg(sg, s, nents, i) {
                if (sg_dma_len(s))
-                       __iommu_remove_mapping(dev, sg_dma_address(s), sg_d=
ma_len(s));
+                       __iommu_remove_mapping(dev, sg_dma_address(s),
+                                               sg_dma_len(s));
                if (!arch_is_coherent())
-                       __dma_page_dev_to_cpu(sg_page(sg), sg->offset, sg->=
length, dir);
+                       __dma_page_dev_to_cpu(sg_page(s), s->offset,
+                                               s->length, dir);
        }
 }

@@ -1108,7 +1147,8 @@ void arm_iommu_sync_sg_for_cpu(struct device *dev, st=
ruct scatterlist *sg,

        for_each_sg(sg, s, nents, i)
                if (!arch_is_coherent())
-                       __dma_page_dev_to_cpu(sg_page(sg), sg->offset, sg->=
length, dir);
+                       __dma_page_dev_to_cpu(sg_page(s), s->offset,
+                                               s->length, dir);
 }

 /**
@@ -1126,20 +1166,24 @@ void arm_iommu_sync_sg_for_device(struct device *de=
v, struct scatterlist *sg,

        for_each_sg(sg, s, nents, i)
                if (!arch_is_coherent())
-                       __dma_page_cpu_to_dev(sg_page(sg), sg->offset, sg->=
length, dir);
+                       __dma_page_cpu_to_dev(sg_page(s), s->offset,
+                                               s->length, dir);
 }

 struct dma_map_ops iommu_ops =3D {
        .alloc          =3D arm_iommu_alloc_attrs,
        .free           =3D arm_iommu_free_attrs,
        .mmap           =3D arm_iommu_mmap_attrs,
+       .map_page       =3D arm_iommu_map_page,
+       .unmap_page     =3D arm_iommu_unmap_page,
        .map_sg                 =3D arm_iommu_map_sg,
        .unmap_sg               =3D arm_iommu_unmap_sg,
        .sync_sg_for_cpu        =3D arm_iommu_sync_sg_for_cpu,
        .sync_sg_for_device     =3D arm_iommu_sync_sg_for_device,
 };

-int arm_iommu_attach_device(struct device *dev, dma_addr_t base, size_t si=
ze, int order)
+struct dma_iommu_mapping *arm_iommu_create_mapping(dma_addr_t base,
+                                                   size_t size, int order)
 {
        unsigned int count =3D (size >> PAGE_SHIFT) - order;
        unsigned int bitmap_size =3D BITS_TO_LONGS(count) * sizeof(long);
@@ -1157,30 +1201,57 @@ int arm_iommu_attach_device(struct device *dev, dma=
_addr_t base, size_t size, in
        mapping->base =3D base;
        mapping->bits =3D bitmap_size;
        mapping->order =3D order;
-       mutex_init(&mapping->lock);
+       spin_lock_init(&mapping->lock);

        mapping->domain =3D iommu_domain_alloc();
        if (!mapping->domain)
                goto err3;

-       err =3D iommu_attach_device(mapping->domain, dev);
-       if (err !=3D 0)
-               goto err4;
-
-       dev->archdata.mapping =3D mapping;
-       set_dma_ops(dev, &iommu_ops);
-
-       printk(KERN_INFO "Attached IOMMU controller to %s device.\n", dev_n=
ame(dev));
-       return 0;
+       kref_init(&mapping->kref);
+       return mapping;

-err4:
-       iommu_domain_free(mapping->domain);
 err3:
        kfree(mapping->bitmap);
 err2:
        kfree(mapping);
 err:
-       return -ENOMEM;
+       return ERR_PTR(err);
+}
+EXPORT_SYMBOL(arm_iommu_create_mapping);
+
+static void release_iommu_mapping(struct kref *kref)
+{
+       struct dma_iommu_mapping *mapping =3D
+               container_of(kref, struct dma_iommu_mapping, kref);
+
+       iommu_domain_free(mapping->domain);
+       kfree(mapping->bitmap);
+       kfree(mapping);
+}
+
+void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping)
+{
+       if (mapping)
+               kref_put(&mapping->kref, release_iommu_mapping);
+}
+EXPORT_SYMBOL(arm_iommu_release_mapping);
+
+int arm_iommu_attach_device(struct device *dev,
+                           struct dma_iommu_mapping *mapping)
+{
+       int err;
+
+       err =3D iommu_attach_device(mapping->domain, dev);
+       if (err)
+               return err;
+
+       kref_get(&mapping->kref);
+       dev->archdata.mapping =3D mapping;
+       set_dma_ops(dev, &iommu_ops);
+
+       printk(KERN_INFO "*****Attached IOMMU controller to %s device.\n",
+               dev_name(dev));
+       return 0;
 }
 EXPORT_SYMBOL(arm_iommu_attach_device);

--
1.7.0.4

--
nvpublic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
