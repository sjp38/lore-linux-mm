Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id DFCFF6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 06:22:59 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <201306051222.32786.frank.mehnert@oracle.com>
Date: Wed, 5 Jun 2013 03:22:32 -0700 (PDT)
From: Frank Mehnert <frank.mehnert@oracle.com>
Subject: Re: Handling NUMA page migration
References: <201306040922.10235.frank.mehnert@oracle.com>
 <201306051132.15788.frank.mehnert@oracle.com>
 <20130605095630.GL15997@dhcp22.suse.cz>
In-Reply-To: <20130605095630.GL15997@dhcp22.suse.cz>
Content-Type: multipart/signed;
 boundary="__1370427774877127954abhmt116.oracle.com";
 protocol=application/pgp-signature; micalg=pgp-sha1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

--__1370427774877127954abhmt116.oracle.com
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Wednesday 05 June 2013 11:56:30 Michal Hocko wrote:
> On Wed 05-06-13 11:32:15, Frank Mehnert wrote:
> [...]
>=20
> > Thank you very much for your help. As I said, this problem happens _onl=
y_
> > with NUMA_BALANCING enabled. I understand that you treat the VirtualBox
> > code as untrusted but the reason for the problem is that some assumption
> > is obviously not met: The VirtualBox code assumes that the memory it
> > allocates using case A and case B is
> >=20
> >  1. always present and
> >  2. will always be backed by the same phyiscal memory
> >=20
> > over the entire life time. Enabling NUMA_BALANCING seems to make this
> > assumption false. I only want to know why.
>=20
> As I said earlier. Both the manual node migration and numa_fault handler
> do not migrate pages with elevated ref count (your A case) and pages
> that are not on the LRU. So if your Referenced pages might be on the LRU
> then you probably have to look into numamigrate_isolate_page and do an
> exception for PageReserved pages. But I am a bit suspicious this is the
> cause because the reclaim doesn't consider PageReserved pages either so
> they could get reclaimed. Or maybe you have handled that path in your
> kernel.

Thanks, I will also investigate into this direction.

> Or the other option is that you depend on a timing or something like
> that which doesn't hold anymore. That would be hard to debug though.
>=20
> > I see, you don't believe me. I will add more code to the kernel logging
> > which pages were migrated.
>=20
> Simple test for PageReserved flag in numamigrate_isolate_page should
> tell you more.
>=20
> This would cover the migration part. Another potential problem could be
> that the page might get unmapped and marked for the numa fault (see
> do_numa_page). So maybe your code just assumes that the page even
> doesn't get unmapped?

Exactly, that's the assumption -- therefore all these vm_flags tricks.
If this assumption is wrong or not always true, can this requirement
(page is _never_ unmapped) be met at all?

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

--__1370427774877127954abhmt116.oracle.com
Content-Description: This is a digitally signed message part.
Content-Type: application/pgp-signature; charset=ascii; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iEYEABECAAYFAlGvEWgACgkQ6z8pigLf3EceqgCeIvCbuMlq78IuaTUXjkQZlHe8
G8sAoIEdEpsNNYwkxqKVb7FXAYfCp0Er
=9Mof
-----END PGP SIGNATURE-----

--__1370427774877127954abhmt116.oracle.com--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
