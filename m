Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0B2626B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 12:56:37 -0500 (EST)
Received: by pvc30 with SMTP id 30so3315858pvc.14
        for <linux-mm@kvack.org>; Tue, 04 Jan 2011 09:56:35 -0800 (PST)
Date: Tue, 4 Jan 2011 10:56:30 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH] hugetlb: remove overcommit sysfs for 1GB pages
Message-ID: <20110104175630.GC3190@mgebm.net>
References: <2026935485.119940.1294126785849.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <519552481.119951.1294126964024.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6zdv2QT/q3FMhpsV"
Content-Disposition: inline
In-Reply-To: <519552481.119951.1294126964024.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>


--6zdv2QT/q3FMhpsV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


On Tue, 04 Jan 2011, CAI Qian wrote:

> 1GB pages cannot be over-commited, attempting to do so results in corrupt=
ion,
> so remove those files for simplicity.
>=20
> Symptoms:
> 1) setup 1gb hugepages.
>=20
> cat /proc/cmdline
> ...default_hugepagesz=3D1g hugepagesz=3D1g hugepages=3D1...
>=20
> cat /proc/meminfo
> ...
> HugePages_Total:       1
> HugePages_Free:        1
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:    1048576 kB
> ...
>=20
> 2) set nr_overcommit_hugepages
>=20
> echo 1 >/sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepa=
ges
> cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
> 1
>=20
> 3) overcommit 2gb hugepages.
>=20
> mmap(NULL, 18446744071562067968, PROT_READ|PROT_WRITE, MAP_SHARED, 3,
> 	   0) =3D -1 ENOMEM (Cannot allocate memory)
>=20
> cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
> 18446744071589420672
>=20
> Signed-off-by: CAI Qian <caiqian@redhat.com>

There are a couple of issues here: first, I think the overcommit value bein=
g overwritten
is a bug and this needs to be addressed and fixed before we cover it by rem=
oving the sysfs
file.

Second, will it be easier for userspace to work with some huge page sizes h=
aving the
overcommit file and others not or making the kernel hand EINVAL back when n=
r_overcommit is
is changed for an unsupported page size?

Finally, this is a problem for more than 1GB pages on x86_64.  It is true f=
or all pages >
1 << MAX_ORDER.  Once the overcommit bug is fixed and the second issue is a=
nswered, the
solution that is used (either EINVAL or no overcommit file) needs to happen=
 for all cases
where it applies, not just the 1GB case.



--6zdv2QT/q3FMhpsV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNI19OAAoJEH65iIruGRnNo78H/1oxX+m8nqgLYCb1a+MEnzrP
2uUqc4hCFMJwBHMhcKit97AAotBjq2oRDSOByCaggVLrfRC8C79zqHCu8PWtaLJK
lBGjEg4sWj9HcrPSeIGHQ9LVMC9AZ6gpS4uN4RH4ROuHaelrSrPXpDjBRiTjG3g5
r53gcim9YaOMkwe5z7Qzv5Btje/30v3b7Hp5jZqnJFIHhdlkoJc8BBEI8kDRpltc
FveBEeYL+rpkt9dsPEUBZSj70R2XxEvjYjnp+UDPlIxzd+u6ADOE+O3ubSVDvZgZ
PKcPodj+RYtjCo7uhBo/cIcfEbJch0/n+ubfdiwI1ve0YMRsh4NmIn8EnD56hFo=
=I6Xz
-----END PGP SIGNATURE-----

--6zdv2QT/q3FMhpsV--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
