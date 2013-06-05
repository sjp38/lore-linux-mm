Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 16D656B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 06:35:44 -0400 (EDT)
From: Frank Mehnert <frank.mehnert@oracle.com>
Subject: Re: Handling NUMA page migration
Date: Wed, 5 Jun 2013 12:35:35 +0200
References: <201306040922.10235.frank.mehnert@oracle.com> <20130604115807.GF3672@sgi.com> <20130605101019.GA18242@suse.de>
In-Reply-To: <20130605101019.GA18242@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1742548.6Bb9FW9k8G";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201306051235.35678.frank.mehnert@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

--nextPart1742548.6Bb9FW9k8G
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Wednesday 05 June 2013 12:10:19 Mel Gorman wrote:
> On Tue, Jun 04, 2013 at 06:58:07AM -0500, Robin Holt wrote:
> > > B) 1. allocate memory with alloc_pages()
> > >=20
> > >    2. SetPageReserved()
> > >    3. vm_mmap() to allocate a userspace mapping
> > >    4. vm_insert_page()
> > >    5. vm_flags |=3D (VM_DONTEXPAND | VM_DONTDUMP)
> > >   =20
> > >       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND |
> > >       0xff)
> > >=20
> > > At least the memory allocated like B) is affected by automatic NUMA
> > > page migration. I'm not sure about A).
> > >=20
> > > 1. How can I prevent automatic NUMA page migration on this memory?
> > > 2. Can NUMA page migration also be handled on such kind of memory
> > > without
> > >=20
> > >    preventing migration?
>=20
> Page migration does not expect a PageReserved && PageLRU page. The only
> reserved check that is made by migration is for the zero page and that
> happens in the syscall path for move_pages() which is not used by either
> compaction or automatic balancing.
>=20
> At some point you must have a driver that is setting PageReserved on
> anonymous pages that is later encountered by automatic numa balancing
> during a NUMA hinting fault.  I expect this is an out-of-tree driver or
> a custom kernel of some sort. Memory should be pinned by elevating the
> reference count of the page, not setting PageReserved.

Yes, this is ring 0 code from VirtualBox. The VBox ring 0 driver does the
steps which are shown above. Setting PageReserved is not only for pinning
but also for fork() protection. I've tried to do get_page() as well but
it did not help preventing the migration during NUMA balancing.

As I wrote, the code for allocating + mapping the memory assumes that
the memory is finally pinned and will be never unmapped. That assumption
might be wrong or wrong under certain/rare conditions. I would like to
know these conditions and how we can prevent them from happening or how
we can handle them correctly.

> It's not particularly clear how you avoid hitting the same bug due to THP
> and memory compaction to be honest but maybe your setup hits a steady
> state that simply never hit the problem or it happens rarely and it was
> not identified.

I'm currently using the stock Ubuntu 13.04 generic kernel (3.8.0-23),
patched with some additional logging code. It is true that this problem
could also be triggered by other kernel mechanisms as you described.

Thanks,

=46rank
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

--nextPart1742548.6Bb9FW9k8G
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iEYEABECAAYFAlGvFHcACgkQ6z8pigLf3Ee+fQCfRn5LVuyryamvUHGqfh/eEd0H
kS0AoJccisiMGUwpRLMfqExEWxkZ+MLc
=JvuG
-----END PGP SIGNATURE-----

--nextPart1742548.6Bb9FW9k8G--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
