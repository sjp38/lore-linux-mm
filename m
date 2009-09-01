Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAEF6B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 05:46:40 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n819eNFh006065
	for <linux-mm@kvack.org>; Tue, 1 Sep 2009 05:40:23 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n819kcSs253038
	for <linux-mm@kvack.org>; Tue, 1 Sep 2009 05:46:38 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n819kcmX008138
	for <linux-mm@kvack.org>; Tue, 1 Sep 2009 05:46:38 -0400
Date: Tue, 1 Sep 2009 10:46:35 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH 2/3] Add MAP_HUGETLB for mmaping pseudo-anonymous huge
	page regions
Message-ID: <20090901094635.GA7995@us.ibm.com>
References: <cover.1251282769.git.ebmunson@us.ibm.com> <1c66a9e98a73d61c611e5cf09b276e954965046e.1251282769.git.ebmunson@us.ibm.com> <1721a3e8bdf8f311d2388951ec65a24d37b513b1.1251282769.git.ebmunson@us.ibm.com> <Pine.LNX.4.64.0908312036410.16402@sister.anvils>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vkogqOf2sHV7VnPd"
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0908312036410.16402@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 31 Aug 2009, Hugh Dickins wrote:

> On Wed, 26 Aug 2009, Eric B Munson wrote:
> > This patch adds a flag for mmap that will be used to request a huge
> > page region that will look like anonymous memory to user space.  This
> > is accomplished by using a file on the internal vfsmount.  MAP_HUGETLB
> > is a modifier of MAP_ANONYMOUS and so must be specified with it.  The
> > region will behave the same as a MAP_ANONYMOUS region using small pages.
> >=20
> > Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
> > ---
> >  include/asm-generic/mman-common.h |    1 +
> >  include/linux/hugetlb.h           |    7 +++++++
> >  mm/mmap.c                         |   19 +++++++++++++++++++
> >  3 files changed, 27 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/include/asm-generic/mman-common.h b/include/asm-generic/mm=
an-common.h
> > index 3b69ad3..12f5982 100644
> > --- a/include/asm-generic/mman-common.h
> > +++ b/include/asm-generic/mman-common.h
> > @@ -19,6 +19,7 @@
> >  #define MAP_TYPE	0x0f		/* Mask for type of mapping */
> >  #define MAP_FIXED	0x10		/* Interpret addr exactly */
> >  #define MAP_ANONYMOUS	0x20		/* don't use a file */
> > +#define MAP_HUGETLB	0x40		/* create a huge page mapping */
> > =20
> >  #define MS_ASYNC	1		/* sync memory asynchronously */
> >  #define MS_INVALIDATE	2		/* invalidate the caches */
>=20
> I'm afraid you can't put MAP_HUGETLB in mman-common.h: that is picked
> up by most or all architectures (which is of course what you wanted!)
> but conflicts with a definition in at least one of them.  When I boot
> up mmotm on powerpc, I get a warning:
>=20
> Using mlock ulimits for SHM_HUGETLB deprecated
> ------------[ cut here ]------------
> Badness at fs/hugetlbfs/inode.c:941
> NIP: c0000000001f3038 LR: c0000000001f3034 CTR: 0000000000000000
> REGS: c0000000275d7960 TRAP: 0700   Not tainted  (2.6.31-rc7-mm2)
> MSR: 9000000000029032 <EE,ME,CE,IR,DR>  CR: 24000484  XER: 00000000
> TASK =3D c000000029fa94a0[1321] 'console-kit-dae' THREAD: c0000000275d400=
0 CPU: 3
> GPR00: c0000000001f3034 c0000000275d7be0 c00000000071a908 000000000000003=
2=20
> GPR04: 0000000000000000 ffffffffffffffff ffffffffffffffff 000000000000000=
0=20
> GPR08: c0000000297dc1d0 c0000000275d4000 d00008008247fa08 000000000000000=
0=20
> GPR12: 0000000024000442 c00000000074ba00 000000000fedb9a4 000000001049cd1=
8=20
> GPR16: 00000000100365d0 00000000104a9100 000000000fefc350 00000000104a909=
8=20
> GPR20: 00000000104a9160 000000000fefc238 0000000000000000 000000000020000=
0=20
> GPR24: 0000000000000000 0000000001000000 c0000000275d7d20 000000000100000=
0=20
> GPR28: c00000000058c738 ffffffffffffffb5 c0000000006a93d0 c00000000079140=
0=20
> NIP [c0000000001f3038] .hugetlb_file_setup+0xd0/0x254
> LR [c0000000001f3034] .hugetlb_file_setup+0xcc/0x254
> Call Trace:
> [c0000000275d7be0] [c0000000001f3034] .hugetlb_file_setup+0xcc/0x254 (unr=
eliable)
> [c0000000275d7cb0] [c0000000000ee240] .do_mmap_pgoff+0x184/0x424
> [c0000000275d7d80] [c00000000000a9c8] .sys_mmap+0xc4/0x13c
> [c0000000275d7e30] [c0000000000075ac] syscall_exit+0x0/0x40
> Instruction dump:
> f89a0000 4bef7111 60000000 2c230000 41820034 e93e8018 80090014 2f800000=
=20
> 40fe0030 e87e80b0 4823ff09 60000000 <0fe00000> e93e8018 38000001 90090014=
=20
>=20
> Which won't be coming from any use of MAP_HUGETLB, but presumably
> from something using MAP_NORESERVE, defined as 0x40 in
> arch/powerpc/include/asm/mman.h.
>=20
> I think you have to put your #define MAP_HUGETLB into
> include/asm-generic/mman.h (seems used by only three architectures),
> and into the arch/whatever/include/asm/mman.h of each architecture
> which uses asm-generic/mman-common.h without asm-generic/mman.h.
>=20
> Hugh
>=20

This problem is the same that Mel Gorman reported (and fixed) in response t=
o patch
1 of this series.  I have forwarded the patch that addresses this problem o=
n,
but it has not been picked up.

The bug is not where MAP_HUGETLB is defined, rather how the patch handled
can_do_hugetlb_shm().  If MAP_HUGETLB was specified, can_do_hugetlb_shm() r=
eturned
0 forcing a call to user_shm_lock() which is responisble for the warning ab=
out
SHM_HUGETLB and mlock ulimits.  The fix is to check if the file is to be us=
ed
for SHM_HUGETLB and if not, skip the calls to can_do_hugetlb_shm() and
user_shm_lock().

--=20
Eric B Munson
IBM Linux Technology Center
ebmunson@us.ibm.com


--vkogqOf2sHV7VnPd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqc7XsACgkQsnv9E83jkzpiPwCdEkAH/N91E/5prikUSq78Z/EG
M2UAoOsh4+B7oWtVBGYgiLmZoLkxcLaf
=GM+W
-----END PGP SIGNATURE-----

--vkogqOf2sHV7VnPd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
