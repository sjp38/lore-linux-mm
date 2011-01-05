Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 056EA6B0089
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 11:44:42 -0500 (EST)
Received: by pxi12 with SMTP id 12so4151046pxi.14
        for <linux-mm@kvack.org>; Wed, 05 Jan 2011 08:44:40 -0800 (PST)
Date: Wed, 5 Jan 2011 09:44:34 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH] hugetlb: remove overcommit sysfs for 1GB pages
Message-ID: <20110105164434.GA3527@mgebm.net>
References: <20110104175630.GC3190@mgebm.net>
 <1047497160.139161.1294239721941.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k1lZvvs/B4yU6o8G"
Content-Disposition: inline
In-Reply-To: <1047497160.139161.1294239721941.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 05 Jan 2011, CAI Qian wrote:

>=20
> ----- Original Message -----
> > On Tue, 04 Jan 2011, CAI Qian wrote:
> >=20
> > > 1GB pages cannot be over-commited, attempting to do so results in
> > > corruption,
> > > so remove those files for simplicity.
> > >
> > > Symptoms:
> > > 1) setup 1gb hugepages.
> > >
> > > cat /proc/cmdline
> > > ...default_hugepagesz=3D1g hugepagesz=3D1g hugepages=3D1...
> > >
> > > cat /proc/meminfo
> > > ...
> > > HugePages_Total: 1
> > > HugePages_Free: 1
> > > HugePages_Rsvd: 0
> > > HugePages_Surp: 0
> > > Hugepagesize: 1048576 kB
> > > ...
> > >
> > > 2) set nr_overcommit_hugepages
> > >
> > > echo 1
> > > >/sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
> > > cat
> > > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
> > > 1
> > >
> > > 3) overcommit 2gb hugepages.
> > >
> > > mmap(NULL, 18446744071562067968, PROT_READ|PROT_WRITE, MAP_SHARED,
> > > 3,
> > > 	   0) =3D -1 ENOMEM (Cannot allocate memory)
> > >
> > > cat
> > > /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
> > > 18446744071589420672
> > >
> > > Signed-off-by: CAI Qian <caiqian@redhat.com>
> >=20
> > There are a couple of issues here: first, I think the overcommit value
> > being overwritten
> > is a bug and this needs to be addressed and fixed before we cover it
> > by removing the sysfs
> > file.
> >=20
> > Second, will it be easier for userspace to work with some huge page
> > sizes having the
> > overcommit file and others not or making the kernel hand EINVAL back
> > when nr_overcommit is
> > is changed for an unsupported page size?
> >=20
> > Finally, this is a problem for more than 1GB pages on x86_64. It is
> > true for all pages >
> > 1 << MAX_ORDER. Once the overcommit bug is fixed and the second issue
> > is answered, the
> > solution that is used (either EINVAL or no overcommit file) needs to
> > happen for all cases
> > where it applies, not just the 1GB case.
> I have a new patch ready to return EINVAL for both sysfs/procfs, and will
> reject changing of nr_hugepages. Do you know if nr_hugepages_mempolicy
> is supposed to be able to change in this case? It is not possible current=
ly.
>=20
> # cat /proc/sys/vm/nr_hugepages_mempolicy
> 1
> # echo 0 >/proc/sys/vm/nr_hugepages_mempolicy=20
> # cat /proc/sys/vm/nr_hugepages_mempolicy
> 1

nr_hugepages_mempolicy should follow all the same rules WRT MAX_ORDER
as nr_hugepages.  The difference is nr_hugepages_mempolicy respects
the NUMA allocation policy that is set.

I have a pair of patches that do about the same thing but instead of
altering flush_write_buffer, they make the functions that use
strict_strtoul in hugetlb.c return -EINVAL on error instead of 0.

The second patch is the same as your check for MAX_ORDER.  I think that
returning -EINVAL from hugetlb.c makes better sense than changing the
behavior of flush_write_buffer.  Patches will be on the way as soon as
I am sure they build.

--k1lZvvs/B4yU6o8G
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNJJ/yAAoJEH65iIruGRnNllMIALC0T61+IFVwJ6yIZX9quq6J
7JuvGVKLhQOaoXABKbPWZVz6Kex6aJVtb4yPTzZ9lyzsOodDX4cZS4o0HT+ACLq8
WrMC+oyic+YdEX0K/2X7tqBDZb2tmNQE/mnXqHE0//mQUn8f1aQYS5CA63KS1W34
GvjloYjyOXK+gKQRBzG169xjW4Yrwe0eESfWmkeOrxOCqe06+DaKimfa9Ww4s2DU
zJAuQP1Y9RjgqxCMn7L8QOUdm7cMHgpUPrnd1UJtb0hcTbjyGew39q2umRkqNZzo
XsIJs+BhM8QwSfeOdhExPiXYeFkaMIQylUBzCVckgkD7K7naIoIqO23Re+TEQN8=
=h/Us
-----END PGP SIGNATURE-----

--k1lZvvs/B4yU6o8G--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
