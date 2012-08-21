Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 5F6F46B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 08:15:56 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Date: Tue, 21 Aug 2012 14:15:21 +0200
Subject: Re: [PATCHv6 2/2] ARM: dma-mapping: remove custom consistent dma
 region
Message-ID: <20120821.151521.702882672715065253.hdoyu@nvidia.com>
References: <1343636899-19508-1-git-send-email-m.szyprowski@samsung.com><1343636899-19508-3-git-send-email-m.szyprowski@samsung.com><20120821142235.97984abc9ad98d01015a3338@nvidia.com>
In-Reply-To: <20120821142235.97984abc9ad98d01015a3338@nvidia.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "subashrp@gmail.com" <subashrp@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>

Hiroshi Doyu <hdoyu@nvidia.com> wrote @ Tue, 21 Aug 2012 13:22:35 +0200:

> Hi,
>=20
> On Mon, 30 Jul 2012 10:28:19 +0200
> Marek Szyprowski <m.szyprowski@samsung.com> wrote:
>=20
> > This patch changes dma-mapping subsystem to use generic vmalloc areas
> > for all consistent dma allocations. This increases the total size limit
> > of the consistent allocations and removes platform hacks and a lot of
> > duplicated code.
> >=20
> > Atomic allocations are served from special pool preallocated on boot,
> > because vmalloc areas cannot be reliably created in atomic context.
> >=20
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
> > ---
> >  Documentation/kernel-parameters.txt |    2 +-
> >  arch/arm/include/asm/dma-mapping.h  |    2 +-
> >  arch/arm/mm/dma-mapping.c           |  486 ++++++++++++---------------=
--------
> >  arch/arm/mm/mm.h                    |    3 +
> >  include/linux/vmalloc.h             |    1 +
> >  mm/vmalloc.c                        |   10 +-
> >  6 files changed, 181 insertions(+), 323 deletions(-)
> >=20
> ...
> > @@ -1117,61 +984,32 @@ static int __iommu_free_buffer(struct device *de=
v, struct page **pages, size_t s
> >   * Create a CPU mapping for a specified pages
> >   */
> >  static void *
> > -__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgpro=
t_t prot)
> > +__iommu_alloc_remap(struct page **pages, size_t size, gfp_t gfp, pgpro=
t_t prot,
> > +                   const void *caller)
> >  {
> > -       struct arm_vmregion *c;
> > -       size_t align;
> > -       size_t count =3D size >> PAGE_SHIFT;
> > -       int bit;
> > +       unsigned int i, nr_pages =3D PAGE_ALIGN(size) >> PAGE_SHIFT;
> > +       struct vm_struct *area;
> > +       unsigned long p;
> >=20
> > -       if (!consistent_pte[0]) {
> > -               pr_err("%s: not initialised\n", __func__);
> > -               dump_stack();
> > +       area =3D get_vm_area_caller(size, VM_ARM_DMA_CONSISTENT | VM_US=
ERMAP,
> > +                                 caller);
> > +       if (!area)
>=20
> This patch replaced the custom "consistent_pte" with
> get_vm_area_caller()", which breaks the compatibility with the
> existing driver. This causes the following kernel oops(*1). That
> driver has called dma_pool_alloc() to allocate memory from the
> interrupt context, and it hits BUG_ON(in_interrpt()) in
> "get_vm_area_caller()"(*2). Regardless of the badness of allocation
> from interrupt handler in the driver, I have the following question.
>=20
> The following "__get_vm_area_node()" can take gfp_mask, it means that
> this function is expected to be called from atomic context, but why
> it's _NOT_ allowed _ONLY_ from interrupt context?
>=20
> According to the following definitions, "in_interrupt()" is in "in_atomic=
()".
>=20
> #define in_interrupt()	(preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK | =
NMI_MASK))
> #define in_atomic()	((preempt_count() & ~PREEMPT_ACTIVE) !=3D 0)
>=20
> Does anyone know why BUG_ON(in_interrupt()) is set in __get_vm_area_node(=
*3)?

For arm_dma_alloc(), it allocates from the pool if GFP_ATOMIC, but for
arm_iommu_alloc_attrs() doesn't have pre-allocate pool at all, and it
always call "get_vm_area_caller()". That's why it hits BUG(). But
still I don't understand why it's not BUG_ON(in_atomic) as Russell
already pointed out(*1).

*1: http://article.gmane.org/gmane.linux.kernel.mm/76708

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
