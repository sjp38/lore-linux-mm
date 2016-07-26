Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6CC786B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:22:12 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id u25so485170426ioi.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:22:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l143si13280073iol.251.2016.07.25.17.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 17:22:11 -0700 (PDT)
Message-ID: <1469492520.30053.123.camel@redhat.com>
Subject: Re: [PATCH v4 12/12] mm: SLUB hardened usercopy support
From: Rik van Riel <riel@redhat.com>
Date: Mon, 25 Jul 2016 20:22:00 -0400
In-Reply-To: <9fca8a3c-da82-d609-79bb-4f5a779cbc1b@redhat.com>
References: <1469046427-12696-1-git-send-email-keescook@chromium.org>
 <1469046427-12696-13-git-send-email-keescook@chromium.org>
 <0f980e84-b587-3d9e-3c26-ad57f947c08b@redhat.com>
 <1469482923.30053.122.camel@redhat.com>
	 <9fca8a3c-da82-d609-79bb-4f5a779cbc1b@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-8qqetdyYF8mCBLlKELUz"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com
Cc: Laura Abbott <labbott@fedoraproject.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S.
 Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--=-8qqetdyYF8mCBLlKELUz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-07-25 at 16:29 -0700, Laura Abbott wrote:
> On 07/25/2016 02:42 PM, Rik van Riel wrote:
> > On Mon, 2016-07-25 at 12:16 -0700, Laura Abbott wrote:
> > > On 07/20/2016 01:27 PM, Kees Cook wrote:
> > > > Under CONFIG_HARDENED_USERCOPY, this adds object size checking
> > > > to
> > > > the
> > > > SLUB allocator to catch any copies that may span objects.
> > > > Includes
> > > > a
> > > > redzone handling fix discovered by Michael Ellerman.
> > > >=20
> > > > Based on code from PaX and grsecurity.
> > > >=20
> > > > Signed-off-by: Kees Cook <keescook@chromium.org>
> > > > Tested-by: Michael Ellerman <mpe@ellerman.id.au>
> > > > ---
> > > > =C2=A0init/Kconfig |=C2=A0=C2=A01 +
> > > > =C2=A0mm/slub.c=C2=A0=C2=A0=C2=A0=C2=A0| 36 +++++++++++++++++++++++=
+++++++++++++
> > > > =C2=A02 files changed, 37 insertions(+)
> > > >=20
> > > > diff --git a/init/Kconfig b/init/Kconfig
> > > > index 798c2020ee7c..1c4711819dfd 100644
> > > > --- a/init/Kconfig
> > > > +++ b/init/Kconfig
> > > > @@ -1765,6 +1765,7 @@ config SLAB
> > > >=20
> > > > =C2=A0config SLUB
> > > > =C2=A0	bool "SLUB (Unqueued Allocator)"
> > > > +	select HAVE_HARDENED_USERCOPY_ALLOCATOR
> > > > =C2=A0	help
> > > > =C2=A0	=C2=A0=C2=A0=C2=A0SLUB is a slab allocator that minimizes ca=
che line
> > > > usage
> > > > =C2=A0	=C2=A0=C2=A0=C2=A0instead of managing queues of cached objec=
ts (SLAB
> > > > approach).
> > > > diff --git a/mm/slub.c b/mm/slub.c
> > > > index 825ff4505336..7dee3d9a5843 100644
> > > > --- a/mm/slub.c
> > > > +++ b/mm/slub.c
> > > > @@ -3614,6 +3614,42 @@ void *__kmalloc_node(size_t size, gfp_t
> > > > flags, int node)
> > > > =C2=A0EXPORT_SYMBOL(__kmalloc_node);
> > > > =C2=A0#endif
> > > >=20
> > > > +#ifdef CONFIG_HARDENED_USERCOPY
> > > > +/*
> > > > + * Rejects objects that are incorrectly sized.
> > > > + *
> > > > + * Returns NULL if check passes, otherwise const char * to
> > > > name of
> > > > cache
> > > > + * to indicate an error.
> > > > + */
> > > > +const char *__check_heap_object(const void *ptr, unsigned long
> > > > n,
> > > > +				struct page *page)
> > > > +{
> > > > +	struct kmem_cache *s;
> > > > +	unsigned long offset;
> > > > +	size_t object_size;
> > > > +
> > > > +	/* Find object and usable object size. */
> > > > +	s =3D page->slab_cache;
> > > > +	object_size =3D slab_ksize(s);
> > > > +
> > > > +	/* Find offset within object. */
> > > > +	offset =3D (ptr - page_address(page)) % s->size;
> > > > +
> > > > +	/* Adjust for redzone and reject if within the
> > > > redzone. */
> > > > +	if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE) {
> > > > +		if (offset < s->red_left_pad)
> > > > +			return s->name;
> > > > +		offset -=3D s->red_left_pad;
> > > > +	}
> > > > +
> > > > +	/* Allow address range falling entirely within object
> > > > size. */
> > > > +	if (offset <=3D object_size && n <=3D object_size -
> > > > offset)
> > > > +		return NULL;
> > > > +
> > > > +	return s->name;
> > > > +}
> > > > +#endif /* CONFIG_HARDENED_USERCOPY */
> > > > +
> > >=20
> > > I compared this against what check_valid_pointer does for
> > > SLUB_DEBUG
> > > checking. I was hoping we could utilize that function to avoid
> > > duplication but a) __check_heap_object needs to allow accesses
> > > anywhere
> > > in the object, not just the beginning b) accessing page->objects
> > > is racy without the addition of locking in SLUB_DEBUG.
> > >=20
> > > Still, the ptr < page_address(page) check from
> > > __check_heap_object
> > > would
> > > be good to add to avoid generating garbage large offsets and
> > > trying
> > > to
> > > infer C math.
> > >=20
> > > diff --git a/mm/slub.c b/mm/slub.c
> > > index 7dee3d9..5370e4f 100644
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > @@ -3632,6 +3632,9 @@ const char *__check_heap_object(const void
> > > *ptr, unsigned long n,
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0s =3D page->sla=
b_cache;
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0object_size =3D=
 slab_ksize(s);
> > >=20
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (ptr < page_address(pag=
e))
> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0return s->name;
> > > +
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* Find offset =
within object. */
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0offset =3D (ptr=
 - page_address(page)) % s->size;
> > >=20
> >=20
> > I don't get it, isn't that already guaranteed because we
> > look for the page that ptr is in, before __check_heap_object
> > is called?
> >=20
> > Specifically, in patch 3/12:
> >=20
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0page =3D virt_to_head_page(p=
tr);
> > +
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* Check slab allocator for =
flags and size. */
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (PageSlab(page))
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0return __check_heap_object(ptr, n, page);
> >=20
> > How can that generate a ptr that is not inside the page?
> >=20
> > What am I overlooking?=C2=A0=C2=A0And, should it be in the changelog or
> > a comment? :)
> >=20
>=20
>=20
> I ran into the subtraction issue when the vmalloc detection wasn't
> working on ARM64, somehow virt_to_head_page turned into a page
> that happened to have PageSlab set. I agree if everything is working
> properly this is redundant but given the type of feature this is, a
> little bit of redundancy against a system running off into the weeds
> or bad patches might be warranted.
>=C2=A0
That's fair. =C2=A0I have no objection to the check, but would
like to see it documented, since it does look a little out
of place.

--=20

All Rights Reversed.
--=-8qqetdyYF8mCBLlKELUz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXlq0pAAoJEM553pKExN6Dv5IIALtZxgoQj8M9YOmCa4BjHZtJ
R5FYg7nvY19D598u4s6f88QF92Xf7D7iqkCugZOU6/Te6x54VypAx83ud2zP828U
4qmIudPyyhX+VGlc71cVJ2gy12Xx5G7u9H5/+Qgyp/Y4bxithElDidjQN4VTpS8g
6y4hwd34ADw7ah+yVR65GNIq+eZTdRjH0wTCE0vrcdgl4yCWQ5vm3uv4LzAkbRPH
QWRmKt4D5ubSb5cPqK6EnUUc+0SYkydVSNII4DoG+NGNYynklhlptGEFdrrIG/sS
Gb++LQw7kb4XrQ2/Jg6jy1yqimXo2OeQ8ZZXo86zz82ByleVjvWRnxsvcHEqk8o=
=kQY+
-----END PGP SIGNATURE-----

--=-8qqetdyYF8mCBLlKELUz--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
