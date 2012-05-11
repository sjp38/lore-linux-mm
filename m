Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 1994B6B00E7
	for <linux-mm@kvack.org>; Thu, 10 May 2012 22:02:03 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id hn9so1034409wib.8
        for <linux-mm@kvack.org>; Thu, 10 May 2012 19:02:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALYq+qQA9HAME8Fg5cLopCzkLLMB5G3V_UOni-eWp2UGrcMqNQ@mail.gmail.com>
References: <CALYq+qQA9HAME8Fg5cLopCzkLLMB5G3V_UOni-eWp2UGrcMqNQ@mail.gmail.com>
Date: Fri, 11 May 2012 11:02:02 +0900
Message-ID: <CALYq+qR15JYChs8LLuc4sFf1neXD3-1B949aefg=JXxtjGVuYQ@mail.gmail.com>
Subject: [Linaro-mm-sig] [PATCH 3/3] [RFC] Kernel Virtual Memory allocation
 issue in dma-mapping framework
From: Abhinav Kochhar <kochhar.abhinav@gmail.com>
Content-Type: multipart/alternative; boundary=0016e6d58f0055e8c304bfb91f1a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>

--0016e6d58f0055e8c304bfb91f1a
Content-Type: text/plain; charset=ISO-8859-1

With this we can do a run time check on the allocation type for either
kernel or user using the dma attribute passed to dma-mapping iommu ops.

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c

index 2d11aa0..1f454cc 100644

--- a/arch/arm/mm/dma-mapping.c

+++ b/arch/arm/mm/dma-mapping.c

@@ -428,6 +428,7 @@ static void __dma_free_remap(void *cpu_addr, size_t
size)

        arm_vmregion_free(&consistent_head, c);

 }

+

 #else  /* !CONFIG_MMU */

 #define __dma_alloc_remap(page, size, gfp, prot, c)    page_address(page)

@@ -894,6 +895,35 @@ __iommu_alloc_remap(struct page **pages, size_t size,
gfp_t gfp, pgprot_t prot)

        size_t align;

        size_t count = size >> PAGE_SHIFT;

        int bit;

+        unsigned long mem_type = (unsigned long)gfp;

+

+

+       if(mem_type){

+

+               struct page_infodma *pages_in;

+

+               pages_in = kzalloc( sizeof(struct page_infodma*),
GFP_KERNEL);

+               if(!pages_in)

+                        return NULL;

+

+               pages_in->nr_pages = count;

+

+               return (void*)pages_in;

+

+       }

+

+       /*

+         * Align the virtual region allocation - maximum alignment is

+         * a section size, minimum is a page size.  This helps reduce

+         * fragmentation of the DMA space, and also prevents allocations

+         * smaller than a section from crossing a section boundary.

+         */

+

+        bit = fls(size - 1);

+        if (bit > SECTION_SHIFT)

+                bit = SECTION_SHIFT;

+        align = 1 << bit;

+

        if (!consistent_pte[0]) {

                pr_err("%s: not initialised\n", __func__);

@@ -901,16 +931,6 @@ __iommu_alloc_remap(struct page **pages, size_t size,
gfp_t gfp, pgprot_t prot)

                return NULL;

        }

-       /*

-        * Align the virtual region allocation - maximum alignment is

-        * a section size, minimum is a page size.  This helps reduce

-        * fragmentation of the DMA space, and also prevents allocations

-        * smaller than a section from crossing a section boundary.

-        */

-       bit = fls(size - 1);

-       if (bit > SECTION_SHIFT)

-               bit = SECTION_SHIFT;

-       align = 1 << bit;

        /*

         * Allocate a virtual address in the consistent mapping region.

@@ -946,6 +966,7 @@ __iommu_alloc_remap(struct page **pages, size_t size,
gfp_t gfp, pgprot_t prot)

        return NULL;

 }

+

 /*

  * Create a mapping in device IO address space for specified pages

  */

@@ -973,13 +994,16 @@ __iommu_create_mapping(struct device *dev, struct
page **pages, size_t size)

                len = (j - i) << PAGE_SHIFT;

                ret = iommu_map(mapping->domain, iova, phys, len, 0);

+

                if (ret < 0)

                        goto fail;

+

                iova += len;

                i = j;

        }

        return dma_addr;

 fail:

+

        iommu_unmap(mapping->domain, dma_addr, iova-dma_addr);

        __free_iova(mapping, dma_addr, size);

        return DMA_ERROR_CODE;

@@ -1007,6 +1031,8 @@ static void *arm_iommu_alloc_attrs(struct device
*dev, size_t size,

        pgprot_t prot = __get_dma_pgprot(attrs, pgprot_kernel);

        struct page **pages;

        void *addr = NULL;

+       struct page_infodma *page_ret;

+       unsigned long mem_type;

        *handle = DMA_ERROR_CODE;

        size = PAGE_ALIGN(size);

@@ -1019,11 +1045,19 @@ static void *arm_iommu_alloc_attrs(struct device
*dev, size_t size,

        if (*handle == DMA_ERROR_CODE)

                goto err_buffer;

-       addr = __iommu_alloc_remap(pages, size, gfp, prot);

+       mem_type = dma_get_attr(DMA_ATTR_USER_SPACE, attrs);

+

+       addr = __iommu_alloc_remap(pages, size, mem_type, prot);

        if (!addr)

                goto err_mapping;

-       return addr;

+       if(mem_type){

+               page_ret = (struct page_infodma *)addr;

+               page_ret->pages = pages;

+               return page_ret;

+       }

+       else

+               return addr;

 err_mapping:

        __iommu_remove_mapping(dev, *handle, size);

@@ -1071,18 +1105,34 @@ static int arm_iommu_mmap_attrs(struct device *dev,
struct vm_area_struct *vma,

 void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,

                          dma_addr_t handle, struct dma_attrs *attrs)

 {

-       struct arm_vmregion *c;

+

+       unsigned long mem_type = dma_get_attr(DMA_ATTR_USER_SPACE, attrs);

+

        size = PAGE_ALIGN(size);

-       c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);

-       if (c) {

-               struct page **pages = c->priv;

-               __dma_free_remap(cpu_addr, size);

-               __iommu_remove_mapping(dev, handle, size);

-               __iommu_free_buffer(dev, pages, size);

+

+       if(mem_type){

+

+               struct page_infodma *pagesin = cpu_addr;

+               if (pagesin) {

+                       struct page **pages = pagesin->pages;

+                       __iommu_remove_mapping(dev, handle, size);

+                       __iommu_free_buffer(dev, pages, size);

+                }

+       }

+       else{

+               struct arm_vmregion *c;

+               c = arm_vmregion_find(&consistent_head, (unsigned
long)cpu_addr);

+               if (c) {

+                       struct page **pages = c->priv;

+                       __dma_free_remap(cpu_addr, size);

+                       __iommu_remove_mapping(dev, handle, size);

+                       __iommu_free_buffer(dev, pages, size);

+               }

        }

 }

+

 /*

  * Map a part of the scatter-gather list into contiguous io address space

  */

--0016e6d58f0055e8c304bfb91f1a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p>With this we can do a run time check on the allocation type for either k=
ernel or user using the dma attribute passed to dma-mapping iommu ops.<br><=
br></p>
<p>diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c</p>
<p>index 2d11aa0..1f454cc 100644</p>
<p>--- a/arch/arm/mm/dma-mapping.c</p>
<p>+++ b/arch/arm/mm/dma-mapping.c</p>
<p>@@ -428,6 +428,7 @@ static void __dma_free_remap(void *cpu_addr, size_t =
size)</p>
<p>=A0 =A0 =A0 =A0 arm_vmregion_free(&amp;consistent_head, c);</p>
<p>=A0}<br></p>
<p>+</p>
<p>=A0#else =A0/* !CONFIG_MMU */<br></p>
<p>=A0#define __dma_alloc_remap(page, size, gfp, prot, c) =A0 =A0page_addre=
ss(page)</p>
<p>@@ -894,6 +895,35 @@ __iommu_alloc_remap(struct page **pages, size_t siz=
e, gfp_t gfp, pgprot_t prot)</p>
<p>=A0 =A0 =A0 =A0 size_t align;</p>
<p>=A0 =A0 =A0 =A0 size_t count =3D size &gt;&gt; PAGE_SHIFT;</p>
<p>=A0 =A0 =A0 =A0 int bit;</p>
<p>+ =A0 =A0 =A0 =A0unsigned long mem_type =3D (unsigned long)gfp;</p>
<p>+</p>
<p>+</p>
<p>+ =A0 =A0 =A0 if(mem_type){</p>
<p>+</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page_infodma *pages_in;</p>
<p>+</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages_in =3D kzalloc( sizeof(struct page_i=
nfodma*), GFP_KERNEL);</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if(!pages_in)</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;</p>
<p>+</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 pages_in-&gt;nr_pages =3D count;</p>
<p>+</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return (void*)pages_in;</p>
<p>+</p>
<p>+ =A0 =A0 =A0 }</p>
<p>+</p>
<p>+ =A0 =A0 =A0 /*</p>
<p>+ =A0 =A0 =A0 =A0 * Align the virtual region allocation - maximum alignm=
ent is</p>
<p>+ =A0 =A0 =A0 =A0 * a section size, minimum is a page size. =A0This help=
s reduce</p>
<p>+ =A0 =A0 =A0 =A0 * fragmentation of the DMA space, and also prevents al=
locations</p>
<p>+ =A0 =A0 =A0 =A0 * smaller than a section from crossing a section bound=
ary.</p>
<p>+ =A0 =A0 =A0 =A0 */</p>
<p>+</p>
<p>+ =A0 =A0 =A0 =A0bit =3D fls(size - 1);</p>
<p>+ =A0 =A0 =A0 =A0if (bit &gt; SECTION_SHIFT)</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bit =3D SECTION_SHIFT;</p>
<p>+ =A0 =A0 =A0 =A0align =3D 1 &lt;&lt; bit;</p>
<p>+<br></p>
<p>=A0 =A0 =A0 =A0 if (!consistent_pte[0]) {</p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err(&quot;%s: not initialised\n&quot;=
, __func__);</p>
<p>@@ -901,16 +931,6 @@ __iommu_alloc_remap(struct page **pages, size_t siz=
e, gfp_t gfp, pgprot_t prot)</p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;</p>
<p>=A0 =A0 =A0 =A0 }<br></p>
<p>- =A0 =A0 =A0 /*</p>
<p>- =A0 =A0 =A0 =A0* Align the virtual region allocation - maximum alignme=
nt is</p>
<p>- =A0 =A0 =A0 =A0* a section size, minimum is a page size. =A0This helps=
 reduce</p>
<p>- =A0 =A0 =A0 =A0* fragmentation of the DMA space, and also prevents all=
ocations</p>
<p>- =A0 =A0 =A0 =A0* smaller than a section from crossing a section bounda=
ry.</p>
<p>- =A0 =A0 =A0 =A0*/</p>
<p>- =A0 =A0 =A0 bit =3D fls(size - 1);</p>
<p>- =A0 =A0 =A0 if (bit &gt; SECTION_SHIFT)</p>
<p>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 bit =3D SECTION_SHIFT;</p>
<p>- =A0 =A0 =A0 align =3D 1 &lt;&lt; bit;<br></p>
<p>=A0 =A0 =A0 =A0 /*</p>
<p>=A0 =A0 =A0 =A0 =A0* Allocate a virtual address in the consistent mappin=
g region.</p>
<p>@@ -946,6 +966,7 @@ __iommu_alloc_remap(struct page **pages, size_t size=
, gfp_t gfp, pgprot_t prot)</p>
<p>=A0 =A0 =A0 =A0 return NULL;</p>
<p>=A0}<br></p>
<p>+</p>
<p>=A0/*</p>
<p>=A0 * Create a mapping in device IO address space for specified pages</p=
>
<p>=A0 */</p>
<p>@@ -973,13 +994,16 @@ __iommu_create_mapping(struct device *dev, struct =
page **pages, size_t size)<br></p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D (j - i) &lt;&lt; PAGE_SHIFT;</p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D iommu_map(mapping-&gt;domain, io=
va, phys, len, 0);</p>
<p>+</p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret &lt; 0)</p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;</p>
<p>+</p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iova +=3D len;</p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 i =3D j;</p>
<p>=A0 =A0 =A0 =A0 }</p>
<p>=A0 =A0 =A0 =A0 return dma_addr;</p>
<p>=A0fail:</p>
<p>+</p>
<p>=A0 =A0 =A0 =A0 iommu_unmap(mapping-&gt;domain, dma_addr, iova-dma_addr)=
;</p>
<p>=A0 =A0 =A0 =A0 __free_iova(mapping, dma_addr, size);</p>
<p>=A0 =A0 =A0 =A0 return DMA_ERROR_CODE;</p>
<p>@@ -1007,6 +1031,8 @@ static void *arm_iommu_alloc_attrs(struct device *=
dev, size_t size,</p>
<p>=A0 =A0 =A0 =A0 pgprot_t prot =3D __get_dma_pgprot(attrs, pgprot_kernel)=
;</p>
<p>=A0 =A0 =A0 =A0 struct page **pages;</p>
<p>=A0 =A0 =A0 =A0 void *addr =3D NULL;</p>
<p>+ =A0 =A0 =A0 struct page_infodma *page_ret;</p>
<p>+ =A0 =A0 =A0 unsigned long mem_type;<br></p>
<p>=A0 =A0 =A0 =A0 *handle =3D DMA_ERROR_CODE;</p>
<p>=A0 =A0 =A0 =A0 size =3D PAGE_ALIGN(size);</p>
<p>@@ -1019,11 +1045,19 @@ static void *arm_iommu_alloc_attrs(struct device=
 *dev, size_t size,</p>
<p>=A0 =A0 =A0 =A0 if (*handle =3D=3D DMA_ERROR_CODE)</p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_buffer;<br></p>
<p>- =A0 =A0 =A0 addr =3D __iommu_alloc_remap(pages, size, gfp, prot);</p>
<p>+ =A0 =A0 =A0 mem_type =3D dma_get_attr(DMA_ATTR_USER_SPACE, attrs);</p>
<p>+</p>
<p>+ =A0 =A0 =A0 addr =3D __iommu_alloc_remap(pages, size, mem_type, prot);=
</p>
<p>=A0 =A0 =A0 =A0 if (!addr)</p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_mapping;<br></p>
<p>- =A0 =A0 =A0 return addr;</p>
<p>+ =A0 =A0 =A0 if(mem_type){</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_ret =3D (struct page_infodma *)addr;<=
/p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_ret-&gt;pages =3D pages;</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return page_ret;</p>
<p>+ =A0 =A0 =A0 }</p>
<p>+ =A0 =A0 =A0 else</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return addr;<br></p>
<p>=A0err_mapping:</p>
<p>=A0 =A0 =A0 =A0 __iommu_remove_mapping(dev, *handle, size);</p>
<p>@@ -1071,18 +1105,34 @@ static int arm_iommu_mmap_attrs(struct device *d=
ev, struct vm_area_struct *vma,</p>
<p>=A0void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_=
addr,</p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t handle, s=
truct dma_attrs *attrs)</p>
<p>=A0{</p>
<p>- =A0 =A0 =A0 struct arm_vmregion *c;</p>
<p>+</p>
<p>+ =A0 =A0 =A0 unsigned long mem_type =3D dma_get_attr(DMA_ATTR_USER_SPAC=
E, attrs);</p>
<p>+</p>
<p>=A0 =A0 =A0 =A0 size =3D PAGE_ALIGN(size);<br></p>
<p>- =A0 =A0 =A0 c =3D arm_vmregion_find(&amp;consistent_head, (unsigned lo=
ng)cpu_addr);</p>
<p>- =A0 =A0 =A0 if (c) {</p>
<p>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page **pages =3D c-&gt;priv;</p>
<p>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_free_remap(cpu_addr, size);</p>
<p>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_remove_mapping(dev, handle, size);=
</p>
<p>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_free_buffer(dev, pages, size);</p>
<p>+</p>
<p>+ =A0 =A0 =A0 if(mem_type){</p>
<p>+</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page_infodma *pagesin =3D cpu_addr;=
</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pagesin) {</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page **pages =3D pa=
gesin-&gt;pages;</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_remove_mapping(dev=
, handle, size);</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_free_buffer(dev, p=
ages, size);</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}</p>
<p>+ =A0 =A0 =A0 }</p>
<p>+ =A0 =A0 =A0 else{</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct arm_vmregion *c;</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 c =3D arm_vmregion_find(&amp;consistent_he=
ad, (unsigned long)cpu_addr);</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (c) {</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page **pages =3D c-=
&gt;priv;</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __dma_free_remap(cpu_addr,=
 size);</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_remove_mapping(dev=
, handle, size);</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __iommu_free_buffer(dev, p=
ages, size);</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }</p>
<p>=A0 =A0 =A0 =A0 }</p>
<p>=A0}<br></p>
<p>+</p>
<p>=A0/*</p>
<p>=A0 * Map a part of the scatter-gather list into contiguous io address s=
pace</p>
<p>=A0 */<br></p>

--0016e6d58f0055e8c304bfb91f1a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
