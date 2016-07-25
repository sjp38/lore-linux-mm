Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA64F6B025E
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:42:15 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j124so211419397ith.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 14:42:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c84si22203621iod.42.2016.07.25.14.42.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 14:42:15 -0700 (PDT)
Message-ID: <1469482923.30053.122.camel@redhat.com>
Subject: Re: [PATCH v4 12/12] mm: SLUB hardened usercopy support
From: Rik van Riel <riel@redhat.com>
Date: Mon, 25 Jul 2016 17:42:03 -0400
In-Reply-To: <0f980e84-b587-3d9e-3c26-ad57f947c08b@redhat.com>
References: <1469046427-12696-1-git-send-email-keescook@chromium.org>
 <1469046427-12696-13-git-send-email-keescook@chromium.org>
	 <0f980e84-b587-3d9e-3c26-ad57f947c08b@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-4nNy0NdtJWS4930kcKBo"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com
Cc: Laura Abbott <labbott@fedoraproject.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S.
 Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--=-4nNy0NdtJWS4930kcKBo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-07-25 at 12:16 -0700, Laura Abbott wrote:
> On 07/20/2016 01:27 PM, Kees Cook wrote:
> > Under CONFIG_HARDENED_USERCOPY, this adds object size checking to
> > the
> > SLUB allocator to catch any copies that may span objects. Includes
> > a
> > redzone handling fix discovered by Michael Ellerman.
> >=20
> > Based on code from PaX and grsecurity.
> >=20
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > Tested-by: Michael Ellerman <mpe@ellerman.id.au>
> > ---
> > =C2=A0init/Kconfig |=C2=A0=C2=A01 +
> > =C2=A0mm/slub.c=C2=A0=C2=A0=C2=A0=C2=A0| 36 +++++++++++++++++++++++++++=
+++++++++
> > =C2=A02 files changed, 37 insertions(+)
> >=20
> > diff --git a/init/Kconfig b/init/Kconfig
> > index 798c2020ee7c..1c4711819dfd 100644
> > --- a/init/Kconfig
> > +++ b/init/Kconfig
> > @@ -1765,6 +1765,7 @@ config SLAB
> >=20
> > =C2=A0config SLUB
> > =C2=A0	bool "SLUB (Unqueued Allocator)"
> > +	select HAVE_HARDENED_USERCOPY_ALLOCATOR
> > =C2=A0	help
> > =C2=A0	=C2=A0=C2=A0=C2=A0SLUB is a slab allocator that minimizes cache =
line
> > usage
> > =C2=A0	=C2=A0=C2=A0=C2=A0instead of managing queues of cached objects (=
SLAB
> > approach).
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 825ff4505336..7dee3d9a5843 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -3614,6 +3614,42 @@ void *__kmalloc_node(size_t size, gfp_t
> > flags, int node)
> > =C2=A0EXPORT_SYMBOL(__kmalloc_node);
> > =C2=A0#endif
> >=20
> > +#ifdef CONFIG_HARDENED_USERCOPY
> > +/*
> > + * Rejects objects that are incorrectly sized.
> > + *
> > + * Returns NULL if check passes, otherwise const char * to name of
> > cache
> > + * to indicate an error.
> > + */
> > +const char *__check_heap_object(const void *ptr, unsigned long n,
> > +				struct page *page)
> > +{
> > +	struct kmem_cache *s;
> > +	unsigned long offset;
> > +	size_t object_size;
> > +
> > +	/* Find object and usable object size. */
> > +	s =3D page->slab_cache;
> > +	object_size =3D slab_ksize(s);
> > +
> > +	/* Find offset within object. */
> > +	offset =3D (ptr - page_address(page)) % s->size;
> > +
> > +	/* Adjust for redzone and reject if within the redzone. */
> > +	if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE) {
> > +		if (offset < s->red_left_pad)
> > +			return s->name;
> > +		offset -=3D s->red_left_pad;
> > +	}
> > +
> > +	/* Allow address range falling entirely within object
> > size. */
> > +	if (offset <=3D object_size && n <=3D object_size - offset)
> > +		return NULL;
> > +
> > +	return s->name;
> > +}
> > +#endif /* CONFIG_HARDENED_USERCOPY */
> > +
>=20
> I compared this against what check_valid_pointer does for SLUB_DEBUG
> checking. I was hoping we could utilize that function to avoid
> duplication but a) __check_heap_object needs to allow accesses
> anywhere
> in the object, not just the beginning b) accessing page->objects
> is racy without the addition of locking in SLUB_DEBUG.
>=20
> Still, the ptr < page_address(page) check from __check_heap_object
> would
> be good to add to avoid generating garbage large offsets and trying
> to
> infer C math.
>=20
> diff --git a/mm/slub.c b/mm/slub.c
> index 7dee3d9..5370e4f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3632,6 +3632,9 @@ const char *__check_heap_object(const void
> *ptr, unsigned long n,
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s =3D page->slab_ca=
che;
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0object_size =3D sla=
b_ksize(s);
> =C2=A0=C2=A0
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (ptr < page_address(page))
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0return s->name;
> +
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* Find offset with=
in object. */
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0offset =3D (ptr - p=
age_address(page)) % s->size;
>=C2=A0

I don't get it, isn't that already guaranteed because we
look for the page that ptr is in, before __check_heap_object
is called?

Specifically, in patch 3/12:

+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0page =3D virt_to_head_page(ptr);
+
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* Check slab allocator for flag=
s and size. */
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (PageSlab(page))
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0return __check_heap_object(ptr, n, page);

How can that generate a ptr that is not inside the page?

What am I overlooking? =C2=A0And, should it be in the changelog or
a comment? :)

--=20

All Rights Reversed.
--=-4nNy0NdtJWS4930kcKBo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXloesAAoJEM553pKExN6DQ10H/j1zT06MVuOCz6p/bB+kEVn1
eqrh2adrHpfOL7vsnrXm6VoGwgcHYPohW2t+tIEDlwI72rnj0bFJ+yULZAru9BDD
f9+PZHtdKXr5MmZANCFyNTn6y8paSvbEzj4KhMFkOuR1cMYtgk5X37ta8HxgW8g+
aR+FgPxUO0iONyxSp+2hercLK9+xuWZ6u4JBRfrZ5jL7HxoOWlSP+e3+X0UMW0jZ
TmyzQeirSi3d0486aEyPql2I825w3MmX9ujFtHkdFZbQGrD4PeVDcd8MLyGn+4w0
QG1CopRBEnmO2Aaz8dXs5HaA+LfzYMrzwzravXcCmZLN9AR5BpYaszTabSe/LzE=
=hTcV
-----END PGP SIGNATURE-----

--=-4nNy0NdtJWS4930kcKBo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
