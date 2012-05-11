Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id C5A936B0083
	for <linux-mm@kvack.org>; Thu, 10 May 2012 22:01:59 -0400 (EDT)
Received: by wefh52 with SMTP id h52so135945wef.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 19:01:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALYq+qSrgKqkENSL6zRaE76oraunyidJmb-KS+JRMBqihMvKLg@mail.gmail.com>
References: <CALYq+qSrgKqkENSL6zRaE76oraunyidJmb-KS+JRMBqihMvKLg@mail.gmail.com>
Date: Fri, 11 May 2012 11:01:58 +0900
Message-ID: <CALYq+qR=i56xPELGh6Lp9tOY=u-=OZv_Ljh7FMkTPWFC44k5ow@mail.gmail.com>
Subject: [Linaro-mm-sig] [PATCH 2/3] [RFC] Kernel Virtual Memory allocation
 issue in dma-mapping framework
From: Abhinav Kochhar <kochhar.abhinav@gmail.com>
Content-Type: multipart/alternative; boundary=f46d04428d2c14134e04bfb91f96
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>

--f46d04428d2c14134e04bfb91f96
Content-Type: text/plain; charset=ISO-8859-1

With this define new wrapper functions which enables to pass the new dma
attribute to IOMMU ops of dma-mapping framework

diff --git a/arch/arm/include/asm/dma-mapping.h
b/arch/arm/include/asm/dma-mapping.h

index bbef15d..7fc003a 100644

--- a/arch/arm/include/asm/dma-mapping.h

+++ b/arch/arm/include/asm/dma-mapping.h

@@ -14,6 +14,12 @@

 #define DMA_ERROR_CODE (~0)

 extern struct dma_map_ops arm_dma_ops;

+struct page_infodma {

+        struct page **pages;

+        unsigned long nr_pages;

+        unsigned long shared;

+};

+

 static inline struct dma_map_ops *get_dma_ops(struct device *dev)

 {

        if (dev && dev->archdata.dma_ops)

@@ -205,6 +211,14 @@ static inline void *dma_alloc_writecombine(struct
device *dev, size_t size,

        return dma_alloc_attrs(dev, size, dma_handle, flag, &attrs);

 }

+static inline void *dma_alloc_writecombine_user(struct device *dev, size_t
size,

+                                       dma_addr_t *dma_handle, gfp_t flag)

+{

+        DEFINE_DMA_ATTRS(attrs);

+        dma_set_attr(DMA_ATTR_USER_SPACE, &attrs);

+        return dma_alloc_attrs(dev, size, dma_handle, flag, &attrs);

+}

+

 static inline void dma_free_writecombine(struct device *dev, size_t size,

                                     void *cpu_addr, dma_addr_t dma_handle)

 {

@@ -213,6 +227,14 @@ static inline void dma_free_writecombine(struct device
*dev, size_t size,

        return dma_free_attrs(dev, size, cpu_addr, dma_handle, &attrs);

 }

+static inline void dma_free_writecombine_user(struct device *dev, size_t
size,

+                                     void *cpu_addr, dma_addr_t dma_handle)

+{

+       DEFINE_DMA_ATTRS(attrs);

+       dma_set_attr(DMA_ATTR_USER_SPACE, &attrs);

+        return dma_free_attrs(dev, size, cpu_addr, dma_handle, &attrs);

+}

+

 static inline int dma_mmap_writecombine(struct device *dev, struct
vm_area_struct *vma,

                      void *cpu_addr, dma_addr_t dma_addr, size_t size)

 {

@@ -221,6 +243,14 @@ static inline int dma_mmap_writecombine(struct device
*dev, struct vm_area_struc

        return dma_mmap_attrs(dev, vma, cpu_addr, dma_addr, size, &attrs);

 }

+static inline int dma_mmap_writecombine_user(struct device *dev, struct
vm_area_struct *vma,

+                      void *cpu_addr, dma_addr_t dma_addr, size_t size)

+{

+        DEFINE_DMA_ATTRS(attrs);

+        dma_set_attr(DMA_ATTR_USER_SPACE, &attrs);

+        return dma_mmap_attrs(dev, vma, cpu_addr, dma_addr, size, &attrs);

+}

+

 /*

  * This can be called during boot to increase the size of the consistent

  * DMA region above it's default value of 2MB. It must be called before the

--f46d04428d2c14134e04bfb91f96
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p>With this define new wrapper functions which enables to pass the new dma=
 attribute to IOMMU ops of dma-mapping framework<br></p>
<p>diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/d=
ma-mapping.h</p>
<p>index bbef15d..7fc003a 100644</p>
<p>--- a/arch/arm/include/asm/dma-mapping.h</p>
<p>+++ b/arch/arm/include/asm/dma-mapping.h</p>
<p>@@ -14,6 +14,12 @@</p>
<p>=A0#define DMA_ERROR_CODE (~0)</p>
<p>=A0extern struct dma_map_ops arm_dma_ops;<br></p>
<p>+struct page_infodma {</p>
<p>+ =A0 =A0 =A0 =A0struct page **pages;</p>
<p>+ =A0 =A0 =A0 =A0unsigned long nr_pages;</p>
<p>+ =A0 =A0 =A0 =A0unsigned long shared;</p>
<p>+};</p>
<p>+</p>
<p>=A0static inline struct dma_map_ops *get_dma_ops(struct device *dev)</p>
<p>=A0{</p>
<p>=A0 =A0 =A0 =A0 if (dev &amp;&amp; dev-&gt;archdata.dma_ops)</p>
<p>@@ -205,6 +211,14 @@ static inline void *dma_alloc_writecombine(struct d=
evice *dev, size_t size,</p>
<p>=A0 =A0 =A0 =A0 return dma_alloc_attrs(dev, size, dma_handle, flag, &amp=
;attrs);</p>
<p>=A0}<br></p>
<p>+static inline void *dma_alloc_writecombine_user(struct device *dev, siz=
e_t size,</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 dma_addr_t *dma_handle, gfp_t flag)</p>
<p>+{</p>
<p>+ =A0 =A0 =A0 =A0DEFINE_DMA_ATTRS(attrs);</p>
<p>+ =A0 =A0 =A0 =A0dma_set_attr(DMA_ATTR_USER_SPACE, &amp;attrs);</p>
<p>+ =A0 =A0 =A0 =A0return dma_alloc_attrs(dev, size, dma_handle, flag, &am=
p;attrs);</p>
<p>+}</p>
<p>+</p>
<p>=A0static inline void dma_free_writecombine(struct device *dev, size_t s=
ize,</p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0void *cpu_addr, dma_addr_t dma_handle)</p>
<p>=A0{</p>
<p>@@ -213,6 +227,14 @@ static inline void dma_free_writecombine(struct dev=
ice *dev, size_t size,</p>
<p>=A0 =A0 =A0 =A0 return dma_free_attrs(dev, size, cpu_addr, dma_handle, &=
amp;attrs);</p>
<p>=A0}<br></p>
<p>+static inline void dma_free_writecombine_user(struct device *dev, size_=
t size,</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 void *cpu_addr, dma_addr_t dma_handle)</p>
<p>+{</p>
<p>+ =A0 =A0 =A0 DEFINE_DMA_ATTRS(attrs);</p>
<p>+ =A0 =A0 =A0 dma_set_attr(DMA_ATTR_USER_SPACE, &amp;attrs);</p>
<p>+ =A0 =A0 =A0 =A0return dma_free_attrs(dev, size, cpu_addr, dma_handle, =
&amp;attrs);</p>
<p>+}</p>
<p>+</p>
<p>=A0static inline int dma_mmap_writecombine(struct device *dev, struct vm=
_area_struct *vma,</p>
<p>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *cpu_addr, dma_addr_t d=
ma_addr, size_t size)</p>
<p>=A0{</p>
<p>@@ -221,6 +243,14 @@ static inline int dma_mmap_writecombine(struct devi=
ce *dev, struct vm_area_struc</p>
<p>=A0 =A0 =A0 =A0 return dma_mmap_attrs(dev, vma, cpu_addr, dma_addr, size=
, &amp;attrs);</p>
<p>=A0}<br></p>
<p>+static inline int dma_mmap_writecombine_user(struct device *dev, struct=
 vm_area_struct *vma,</p>
<p>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *cpu_addr, dma_addr_t =
dma_addr, size_t size)</p>
<p>+{</p>
<p>+ =A0 =A0 =A0 =A0DEFINE_DMA_ATTRS(attrs);</p>
<p>+ =A0 =A0 =A0 =A0dma_set_attr(DMA_ATTR_USER_SPACE, &amp;attrs);</p>
<p>+ =A0 =A0 =A0 =A0return dma_mmap_attrs(dev, vma, cpu_addr, dma_addr, siz=
e, &amp;attrs);</p>
<p>+}</p>
<p>+</p>
<p>=A0/*</p>
<p>=A0 * This can be called during boot to increase the size of the consist=
ent</p>
<p>=A0 * DMA region above it&#39;s default value of 2MB. It must be called =
before the<br></p>

--f46d04428d2c14134e04bfb91f96--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
