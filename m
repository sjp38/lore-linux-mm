Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 9F48E6B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 08:53:20 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Date: Wed, 22 Aug 2012 14:52:28 +0200
Subject: Re: [RFC 2/4] ARM: dma-mapping: IOMMU allocates pages from pool
 with GFP_ATOMIC
Message-ID: <20120822.155228.1203479129187316092.hdoyu@nvidia.com>
References: <1345630830-9586-1-git-send-email-hdoyu@nvidia.com><1345630830-9586-3-git-send-email-hdoyu@nvidia.com><005a01cd8061$d58998c0$809cca40$%szyprowski@samsung.com>
In-Reply-To: <005a01cd8061$d58998c0$809cca40$%szyprowski@samsung.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "subashrp@gmail.com" <subashrp@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>

Marek Szyprowski <m.szyprowski@samsung.com> wrote @ Wed, 22 Aug 2012 14:29:=
47 +0200:

> Hello,
>=20
> On Wednesday, August 22, 2012 12:20 PM Hiroshi Doyu wrote:
>=20
> > Makes use of the same atomic pool from DMA, and skips kernel page
> > mapping which can involves sleep'able operation at allocating a kernel
> > page table.
> >=20
> > Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
> > ---
> >  arch/arm/mm/dma-mapping.c |   22 ++++++++++++++++++----
> >  1 files changed, 18 insertions(+), 4 deletions(-)
> >=20
> > diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> > index aec0c06..9260107 100644
> > --- a/arch/arm/mm/dma-mapping.c
> > +++ b/arch/arm/mm/dma-mapping.c
> > @@ -1028,7 +1028,6 @@ static struct page **__iommu_alloc_buffer(struct =
device *dev, size_t
> > size,
> >  	struct page **pages;
> >  	int count =3D size >> PAGE_SHIFT;
> >  	int array_size =3D count * sizeof(struct page *);
> > -	int err;
> >=20
> >  	if (array_size <=3D PAGE_SIZE)
> >  		pages =3D kzalloc(array_size, gfp);
> > @@ -1037,9 +1036,20 @@ static struct page **__iommu_alloc_buffer(struct=
 device *dev, size_t
> > size,
> >  	if (!pages)
> >  		return NULL;
> >=20
> > -	err =3D __alloc_fill_pages(&pages, count, gfp);
> > -	if (err)
> > -		goto error
> > +	if (gfp & GFP_ATOMIC) {
> > +		struct page *page;
> > +		int i;
> > +		void *addr =3D __alloc_from_pool(size, &page);
> > +		if (!addr)
> > +			goto err_out;
> > +
> > +		for (i =3D 0; i < count; i++)
> > +			pages[i] =3D page + i;
> > +	} else {
> > +		int err =3D __alloc_fill_pages(&pages, count, gfp);
> > +		if (err)
> > +			goto error;
> > +	}
> >=20
> >  	return pages;
> >  error:
> > @@ -1055,6 +1065,10 @@ static int __iommu_free_buffer(struct device *de=
v, struct page **pages,
> > size_t s
> >  	int count =3D size >> PAGE_SHIFT;
> >  	int array_size =3D count * sizeof(struct page *);
> >  	int i;
> > +
> > +	if (__free_from_pool(page_address(pages[0]), size))
> > +		return 0;
>=20
> You leak memory here. pages array should be also freed.

Right, I'll fix as below:

	Modified arch/arm/mm/dma-mapping.c
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 47c4978..4656c0f 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1121,11 +1121,12 @@ static int __iommu_free_buffer(struct device *dev, =
struct page **pages, size_t s
 	int i;
=20
 	if (__free_from_pool(page_address(pages[0]), size))
-		return 0;
+		goto out;
=20
 	for (i =3D 0; i < count; i++)
 		if (pages[i])
 			__free_pages(pages[i], 0);
+out:
 	if (array_size <=3D PAGE_SIZE)
 		kfree(pages);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
