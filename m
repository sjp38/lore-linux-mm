Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3158D6B0092
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 08:15:02 -0400 (EDT)
From: Frank Mehnert <frank.mehnert@oracle.com>
Subject: Re: Handling NUMA page migration
Date: Tue, 4 Jun 2013 14:14:45 +0200
References: <201306040922.10235.frank.mehnert@oracle.com> <20130604115807.GF3672@sgi.com>
In-Reply-To: <20130604115807.GF3672@sgi.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4158253.W4x4OHcdpD";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201306041414.52237.frank.mehnert@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

--nextPart4158253.W4x4OHcdpD
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Tuesday 04 June 2013 13:58:07 Robin Holt wrote:
> This is probably more appropriate to be directed at the linux-mm
> mailing list.
>=20
> On Tue, Jun 04, 2013 at 09:22:10AM +0200, Frank Mehnert wrote:
> > Hi,
> >=20
> > our memory management on Linux hosts conflicts with NUMA page migration.
> > I assume this problem existed for a longer time but Linux 3.8 introduced
> > automatic NUMA page balancing which makes the problem visible on
> > multi-node hosts leading to kernel oopses.
> >=20
> > NUMA page migration means that the physical address of a page changes.
> > This is fatal if the application assumes that this never happens for
> > that page as it was supposed to be pinned.
> >=20
> > We have two kind of pinned memory:
> >=20
> > A) 1. allocate memory in userland with mmap()
> >=20
> >    2. madvise(MADV_DONTFORK)
> >    3. pin with get_user_pages().
> >    4. flush dcache_page()
> >    5. vm_flags |=3D (VM_DONTCOPY | VM_LOCKED)
> >   =20
> >       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND |
> >      =20
> >        VM_DONTCOPY | VM_LOCKED | 0xff)
>=20
> I don't think this type of allocation should be affected.  The
> get_user_pages() call should elevate the pages reference count which
> should prevent migration from completing.  I would, however, wait for
> a more definitive answer.

Thanks Robin! Actually case B) is more important for us so I'm waiting
for more feedback :)

=46rank

> > B) 1. allocate memory with alloc_pages()
> >=20
> >    2. SetPageReserved()
> >    3. vm_mmap() to allocate a userspace mapping
> >    4. vm_insert_page()
> >    5. vm_flags |=3D (VM_DONTEXPAND | VM_DONTDUMP)
> >   =20
> >       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND |
> >       0xff)
> >=20
> > At least the memory allocated like B) is affected by automatic NUMA page
> > migration. I'm not sure about A).
> >=20
> > 1. How can I prevent automatic NUMA page migration on this memory?
> > 2. Can NUMA page migration also be handled on such kind of memory witho=
ut
> >=20
> >    preventing migration?
> >=20
> > Thanks,
> >=20
> > Frank
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

=2D-=20
Dr.-Ing. Frank Mehnert | Software Development Director, VirtualBox
ORACLE Deutschland B.V. & Co. KG | Werkstr. 24 | 71384 Weinstadt, Germany

Hauptverwaltung: Riesstr. 25, D-80992 M=FCnchen
Registergericht: Amtsgericht M=FCnchen, HRA 95603
Gesch=E4ftsf=FChrer: J=FCrgen Kunz

Komplement=E4rin: ORACLE Deutschland Verwaltung B.V.
Hertogswetering 163/167, 3543 AS Utrecht, Niederlande
Handelsregister der Handelskammer Midden-Niederlande, Nr. 30143697
Gesch=E4ftsf=FChrer: Alexander van der Ven, Astrid Kepper, Val Maher

--nextPart4158253.W4x4OHcdpD
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iEYEABECAAYFAlGt2jwACgkQ6z8pigLf3EeBhACfWdr/FHrGL56lylmiX4Vuhb4I
5iUAn1y2LOnXJpRbvKAcKDFUBv640YH6
=l1BW
-----END PGP SIGNATURE-----

--nextPart4158253.W4x4OHcdpD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
