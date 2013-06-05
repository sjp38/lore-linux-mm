Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id C58696B0034
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 04:56:32 -0400 (EDT)
From: Frank Mehnert <frank.mehnert@oracle.com>
Subject: Re: Handling NUMA page migration
Date: Wed, 5 Jun 2013 10:56:22 +0200
References: <201306040922.10235.frank.mehnert@oracle.com> <20130605075454.GD15997@dhcp22.suse.cz> <201306051034.19959.frank.mehnert@oracle.com>
In-Reply-To: <201306051034.19959.frank.mehnert@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart25383825.ZHbH6Qegqm";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201306051056.22716.frank.mehnert@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

--nextPart25383825.ZHbH6Qegqm
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Wednesday 05 June 2013 10:34:13 Frank Mehnert wrote:
> On Wednesday 05 June 2013 09:54:54 Michal Hocko wrote:
> > On Tue 04-06-13 23:54:45, Frank Mehnert wrote:
> > > On Tuesday 04 June 2013 20:17:02 Frank Mehnert wrote:
> > > > On Tuesday 04 June 2013 16:02:30 Michal Hocko wrote:
> > > > > On Tue 04-06-13 14:14:45, Frank Mehnert wrote:
> > > > > > On Tuesday 04 June 2013 13:58:07 Robin Holt wrote:
> > > > > > > This is probably more appropriate to be directed at the
> > > > > > > linux-mm mailing list.
> > > > > > >=20
> > > > > > > On Tue, Jun 04, 2013 at 09:22:10AM +0200, Frank Mehnert wrote:
> > > > > > > > Hi,
> > > > > > > >=20
> > > > > > > > our memory management on Linux hosts conflicts with NUMA pa=
ge
> > > > > > > > migration. I assume this problem existed for a longer time
> > > > > > > > but Linux 3.8 introduced automatic NUMA page balancing which
> > > > > > > > makes the problem visible on multi-node hosts leading to
> > > > > > > > kernel oopses.
> > > > > > > >=20
> > > > > > > > NUMA page migration means that the physical address of a pa=
ge
> > > > > > > > changes. This is fatal if the application assumes that this
> > > > > > > > never happens for that page as it was supposed to be pinned.
> > > > > > > >=20
> > > > > > > > We have two kind of pinned memory:

Just to repeat it for reference:

A) 1. allocate memory in userland with mmap()
   2. madvise(MADV_DONTFORK)
   3. pin with get_user_pages().
   4. flush dcache_page()
   5. vm_flags |=3D (VM_DONTCOPY | VM_LOCKED)
      (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND |
       VM_DONTCOPY | VM_LOCKED | 0xff)

B) 1. allocate memory with alloc_pages()
   2. SetPageReserved()
   3. vm_mmap() to allocate a userspace mapping
   4. vm_insert_page()
   5. vm_flags |=3D (VM_DONTEXPAND | VM_DONTDUMP)
      (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND | 0xff)

The frequent case is B.

I've just disabled CONFIG_TRANSPARENT_HUGEPAGE for testing purposes and
the Oops is still triggered when running my testcase.

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

--nextPart25383825.ZHbH6Qegqm
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iEYEABECAAYFAlGu/TYACgkQ6z8pigLf3EfSHQCfegpVhzfJlHNzLka5jaPxcyQ8
snsAn3m5QLi6aQ2TC61723ktVN4NqGWJ
=G1tK
-----END PGP SIGNATURE-----

--nextPart25383825.ZHbH6Qegqm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
