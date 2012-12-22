Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 3BE166B006C
	for <linux-mm@kvack.org>; Sat, 22 Dec 2012 10:31:39 -0500 (EST)
Received: by mail-ee0-f46.google.com with SMTP id e53so2883478eek.19
        for <linux-mm@kvack.org>; Sat, 22 Dec 2012 07:31:37 -0800 (PST)
From: Michal Nazarewicz <mpn@google.com>
Subject: Re: [PATCH] cma: use unsigned type for count argument
In-Reply-To: <alpine.DEB.2.00.1212201557270.13223@chino.kir.corp.google.com>
References: <52fd3c7b677ff01f1cd6d54e38a567b463ec1294.1355938871.git.mina86@mina86.com> <20121220153525.97841100.akpm@linux-foundation.org> <alpine.DEB.2.00.1212201557270.13223@chino.kir.corp.google.com>
Date: Sat, 22 Dec 2012 16:31:29 +0100
Message-ID: <xa1tip7u14tq.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 21 2012, David Rientjes wrote:
> > Specifying negative size of buffer makes no sense and thus this commit
> > changes the type of the count argument to unsigned.
> >=20
> > --- a/arch/arm/mm/dma-mapping.c
> > +++ b/arch/arm/mm/dma-mapping.c
> > @@ -1038,9 +1038,9 @@ static struct page **__iommu_alloc_buffer(struct =
device *dev, size_t size,
> >  					  gfp_t gfp, struct dma_attrs *attrs)
> >  {
> >  	struct page **pages;
> > -	int count =3D size >> PAGE_SHIFT;
> > -	int array_size =3D count * sizeof(struct page *);
> > -	int i =3D 0;
> > +	unsigned int count =3D size >> PAGE_SHIFT;
> > +	unsigned int array_size =3D count * sizeof(struct page *);
> > +	unsigned int i =3D 0;

> I didn't ack this because there's no bounds checking on=20
> dma_alloc_from_contiguous() and bitmap_set() has a dangerous side-effect=
=20
> when called with an overflowed nr since it takes a signed argument.=20=20

Mystery solved.  I recalled that there was some reason why the count is
specified as a signed int and thought bitmap_find_next_zero_area() was
the culprit, but now it seems that bitmap_set() was the reason.

> Marek, is there some sane upper bound we can put on count?

INT_MAX would be sufficient.  After all, it maps to a 8 TiB buffer (if
page is 4 KiB).

Moreover, in reality, the few places that call
dma_alloc_from_contiguous() pass a value that cannot be higher than
INT_MAX, ie. (listings heavily stripped):

arch/arm/mm/dma-mapping.c-static void *__alloc_from_contiguous(struct devic=
e *dev, size_t size,
arch/arm/mm/dma-mapping.c-                                   pgprot_t prot,=
 struct page **ret_page)
arch/arm/mm/dma-mapping.c-{
arch/arm/mm/dma-mapping.c-      size_t count =3D size >> PAGE_SHIFT;
arch/arm/mm/dma-mapping.c:      page =3D dma_alloc_from_contiguous(dev, cou=
nt, order);
arch/arm/mm/dma-mapping.c-}

arch/arm/mm/dma-mapping.c-static void *__alloc_from_contiguous(struct devic=
e *dev, size_t size,
arch/arm/mm/dma-mapping.c-                                   pgprot_t prot,=
 struct page **ret_page)
arch/arm/mm/dma-mapping.c-{
arch/arm/mm/dma-mapping.c-      size_t count =3D size >> PAGE_SHIFT;
arch/arm/mm/dma-mapping.c:      page =3D dma_alloc_from_contiguous(dev, cou=
nt, order);
arch/arm/mm/dma-mapping.c-}

arch/arm/mm/dma-mapping.c-static struct page **__iommu_alloc_buffer(struct =
device *dev, size_t size,
arch/arm/mm/dma-mapping.c-                                        gfp_t gfp=
, struct dma_attrs *attrs)
arch/arm/mm/dma-mapping.c-{
arch/arm/mm/dma-mapping.c-      unsigned int count =3D size >> PAGE_SHIFT;
arch/arm/mm/dma-mapping.c-      if (dma_get_attr(DMA_ATTR_FORCE_CONTIGUOUS,=
 attrs)) {
arch/arm/mm/dma-mapping.c:              page =3D dma_alloc_from_contiguous(=
dev, count, order);
arch/arm/mm/dma-mapping.c-      }
arch/arm/mm/dma-mapping.c-}

arch/x86/kernel/pci-dma.c-void *dma_generic_alloc_coherent(struct device *d=
ev, size_t size,
arch/x86/kernel/pci-dma.c-                               dma_addr_t *dma_ad=
dr, gfp_t flag,
arch/x86/kernel/pci-dma.c-                               struct dma_attrs *=
attrs)
arch/x86/kernel/pci-dma.c-{
arch/x86/kernel/pci-dma.c-      unsigned int count =3D PAGE_ALIGN(size) >> =
PAGE_SHIFT;
arch/x86/kernel/pci-dma.c-      if (!(flag & GFP_ATOMIC))
arch/x86/kernel/pci-dma.c:              page =3D dma_alloc_from_contiguous(=
dev, count, get_order(size));
arch/x86/kernel/pci-dma.c-}

So I think just adding the following, should be sufficient to make
everyone happy:

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index e34e3e0..e91743b 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -320,7 +320,7 @@ struct page *dma_alloc_from_contiguous(struct device *d=
ev, unsigned int count,
 	pr_debug("%s(cma %p, count %u, align %u)\n", __func__, (void *)cma,
 		 count, align);
=20
-	if (!count)
+	if (!count || count > INT_MAX)
 		return NULL;
=20
 	mask =3D (1 << align) - 1;

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQ1dJRAAoJECBgQBJQdR/0P18P/2fpWbgSuMx3x6oOmd7qGKeS
ThE6Z4z3KoOtNVKMUh8HFU6VPmgK543WDOFTG6SoSGTE7+R/6fzB+wnHznGPnfcV
JHQYa/qAE5C3EzZurkD40Pvbl6phkdbk2zM3OkEv9U7X10boMJhWxaicsOkFZOl7
Xjs/EszA3ywqyBvpIx5OK+mXaieDsQS2negjMuPoYctun8fp3+BRRdud3pt0zkRM
WopRUVtiHUihYjrapMBCfsNgF0Np2Nj0LQc5tmJORwrH35z0948dlZ2lyerp9aON
VQsVw9LN9LrSBE+lHpXsiZv1OSCvqN4We84qXC16yvPzxdFO5i6IKENlzD1TGb6C
zjmUmnw+9FdJI0hsdgvMgnAd6la8XWXma8mMOnMcD4KJKr0rOPnDpjZp3iI3Brz6
xhJbU5IHoX4umrX+GS+BwUktgklTJlH+SrjrNND+qUcZlePPNz7N/9EaZ7x4NWQh
aBJjL8C6lebS9kD+VEJHMpplVl/OLdfCDlIgxlXNIzcNYVzuK0DENjFraNkxSBDO
GsRpl6yJwVBigOpRj1Dt6VsOMTpZwtvxdAphrcawT2nIImdZ1QGXVd6nJvJzRaU8
l4liDdtR4NqCDZ3DytIbfXdtx1kspiPuNyXHGpjSRCEKQScgybBs7ZSjWE5Zdyag
HlXaKIouslY3uvE3RoQL
=ZhUt
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
