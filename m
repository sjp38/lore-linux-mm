Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 0D69C6B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 07:40:23 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Date: Fri, 24 Aug 2012 13:39:55 +0200
Subject: Re: [v3 2/4] ARM: dma-mapping: Refactor out to introduce
 __in_atomic_pool
Message-ID: <20120824.143955.659265444078193982.hdoyu@nvidia.com>
References: <1345796945-21115-1-git-send-email-hdoyu@nvidia.com><1345796945-21115-3-git-send-email-hdoyu@nvidia.com><20120824111455.GC11007@konrad-lan.dumpdata.com>
In-Reply-To: <20120824111455.GC11007@konrad-lan.dumpdata.com>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
Cc: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kyungmin.park@samsung.com" <kyungmin.park@samsung.com>, "arnd@arndb.de" <arnd@arndb.de>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "chunsang.jeong@linaro.org" <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, "subashrp@gmail.com" <subashrp@gmail.com>, "minchan@kernel.org" <minchan@kernel.org>, "pullip.cho@samsung.com" <pullip.cho@samsung.com>

Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote @ Fri, 24 Aug 2012 13:=
14:55 +0200:

> On Fri, Aug 24, 2012 at 11:29:03AM +0300, Hiroshi Doyu wrote:
> > Check the given range("start", "size") is included in "atomic_pool" or =
not.
> >=20
> > Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
> > ---
> >  arch/arm/mm/dma-mapping.c |   25 +++++++++++++++++++------
> >  1 files changed, 19 insertions(+), 6 deletions(-)
> >=20
> > diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
> > index b14ee64..508fde1 100644
> > --- a/arch/arm/mm/dma-mapping.c
> > +++ b/arch/arm/mm/dma-mapping.c
> > @@ -501,19 +501,32 @@ static void *__alloc_from_pool(size_t size, struc=
t page **ret_page)
> >  	return ptr;
> >  }
> > =20
> > +static bool __in_atomic_pool(void *start, size_t size)
> > +{
> > +	struct dma_pool *pool =3D &atomic_pool;
> > +	void *end =3D start + size;
> > +	void *pool_start =3D pool->vaddr;
> > +	void *pool_end =3D pool->vaddr + pool->size;
> > +
> > +	if (start < pool_start || start > pool_end)
> > +		return false;
> > +
> > +	if (end > pool_end) {
> > +		WARN(1, "freeing wrong coherent size from pool\n");
>=20
> That does not tell what size or from what pool. Perhaps you should
> include some details, such as the 'size' value, the pool used, the
> range of the pool, etc. Something that will help _you_in the field
> be able to narrow down what might be wrong.

True. I'll.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
