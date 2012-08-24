Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 3FAB86B0068
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 07:52:34 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Date: Fri, 24 Aug 2012 13:52:00 +0200
Subject: Re: [v3 1/4] ARM: dma-mapping: atomic_pool with struct page **pages
Message-ID: <20120824.145200.843951079622652894.hdoyu@nvidia.com>
References: <1345796945-21115-1-git-send-email-hdoyu@nvidia.com><1345796945-21115-2-git-send-email-hdoyu@nvidia.com><20120824111323.GB11007@konrad-lan.dumpdata.com>
In-Reply-To: <20120824111323.GB11007@konrad-lan.dumpdata.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
Cc: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "subashrp@gmail.com" <subashrp@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>

Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote @ Fri, 24 Aug 2012 13:=
13:23 +0200:

> On Fri, Aug 24, 2012 at 11:29:02AM +0300, Hiroshi Doyu wrote:
> > struct page **pages is necessary to align with non atomic path in
> > __iommu_get_pages(). atomic_pool() has the intialized **pages instead
> > of just *page.
> >=20
> > Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
> > ---
> >  arch/arm/mm/dma-mapping.c |   17 +++++++++++++----
> >  1 files changed, 13 insertions(+), 4 deletions(-)
> >=20
> > diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> > index 601da7a..b14ee64 100644
> > --- a/arch/arm/mm/dma-mapping.c
> > +++ b/arch/arm/mm/dma-mapping.c
> > @@ -296,7 +296,7 @@ struct dma_pool {
> >  	unsigned long *bitmap;
> >  	unsigned long nr_pages;
> >  	void *vaddr;
> > -	struct page *page;
> > +	struct page **pages;
> >  };
> > =20
> >  static struct dma_pool atomic_pool =3D {
> > @@ -335,12 +335,16 @@ static int __init atomic_pool_init(void)
> >  	unsigned long nr_pages =3D pool->size >> PAGE_SHIFT;
> >  	unsigned long *bitmap;
> >  	struct page *page;
> > +	struct page **pages;
> >  	void *ptr;
> >  	int bitmap_size =3D BITS_TO_LONGS(nr_pages) * sizeof(long);
> > +	size_t size =3D nr_pages * sizeof(struct page *);
> > =20
> > -	bitmap =3D kzalloc(bitmap_size, GFP_KERNEL);
> > +	size +=3D bitmap_size;
> > +	bitmap =3D kzalloc(size, GFP_KERNEL);
> >  	if (!bitmap)
> >  		goto no_bitmap;
> > +	pages =3D (void *)bitmap + bitmap_size;
>=20
> So you stuck a bitmap field in front of the array then?
> Why not just define a structure where this is clearly defined
> instead of doing the casting.

I just wanted to allocate only once for the members "pool->bitmap" and
"pool->pages" at once. Since the size of a whole bitmap isn't known in
advance, I couldn't find any fixed type for this bitmap, which pointer
can be shifted without casting. IOW, they are variable length.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
