Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F19DF6B004D
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 08:40:24 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7ECZsuT027876
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 06:35:54 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7ECeL8O210406
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 06:40:22 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7ECeL2i025164
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 06:40:21 -0600
Date: Fri, 14 Aug 2009 13:40:16 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH 2/3] Add MAP_HUGETLB for mmaping pseudo-anonymous huge
	page regions V2
Message-ID: <20090814124016.GB6180@us.ibm.com>
References: <cover.1250156841.git.ebmunson@us.ibm.com> <e9b02974a0cca308927ff3a4a0765b93faa6d12f.1250156841.git.ebmunson@us.ibm.com> <83949d066e2a7221a25dd74d12d6dcf7e8b4e9ba.1250156841.git.ebmunson@us.ibm.com> <alpine.DEB.2.00.0908131443350.9805@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZfOjI3PrQbgiZnxM"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0908131443350.9805@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, mtk.manpages@gmail.com
List-ID: <linux-mm.kvack.org>


--ZfOjI3PrQbgiZnxM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 13 Aug 2009, David Rientjes wrote:

> On Thu, 13 Aug 2009, Eric B Munson wrote:
>=20
> > This patch adds a flag for mmap that will be used to request a huge
> > page region that will look like anonymous memory to user space.  This
> > is accomplished by using a file on the internal vfsmount.  MAP_HUGETLB
> > is a modifier of MAP_ANONYMOUS and so must be specified with it.  The
> > region will behave the same as a MAP_ANONYMOUS region using small pages.
> >=20
> > Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
> > ---
> > Changes from V1
> >  Rebase to newest linux-2.6 tree
> >  Rename MAP_LARGEPAGE to MAP_HUGETLB to match flag name for huge page s=
hm
> >=20
> >  include/asm-generic/mman-common.h |    1 +
> >  include/linux/hugetlb.h           |    7 +++++++
> >  mm/mmap.c                         |   16 ++++++++++++++++
> >  3 files changed, 24 insertions(+), 0 deletions(-)
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
> > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > index 78b6ddf..b84361c 100644
> > --- a/include/linux/hugetlb.h
> > +++ b/include/linux/hugetlb.h
> > @@ -109,12 +109,19 @@ static inline void hugetlb_report_meminfo(struct =
seq_file *m)
> > =20
> >  #endif /* !CONFIG_HUGETLB_PAGE */
> > =20
> > +#define HUGETLB_ANON_FILE "anon_hugepage"
> > +
> >  enum {
> >  	/*
> >  	 * The file will be used as an shm file so shmfs accounting rules
> >  	 * apply
> >  	 */
> >  	HUGETLB_SHMFS_INODE     =3D 0x01,
> > +	/*
> > +	 * The file is being created on the internal vfs mount and shmfs
> > +	 * accounting rules do not apply
> > +	 */
> > +	HUGETLB_ANONHUGE_INODE  =3D 0x02,
> >  };
> > =20
> >  #ifdef CONFIG_HUGETLBFS
>=20
> While I think it's appropriate to use an enum here, these two "flags"=20
> can't be used together so it would probably be better to avoid the=20
> hexadecimal.
>=20
> If flags were ever needed in the future, you could reserve the upper eigh=
t=20
> bits of the int for such purposes similiar to mempolicy flags.
>=20
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index 34579b2..3612b20 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -29,6 +29,7 @@
> >  #include <linux/rmap.h>
> >  #include <linux/mmu_notifier.h>
> >  #include <linux/perf_counter.h>
> > +#include <linux/hugetlb.h>
> > =20
> >  #include <asm/uaccess.h>
> >  #include <asm/cacheflush.h>
> > @@ -954,6 +955,21 @@ unsigned long do_mmap_pgoff(struct file *file, uns=
igned long addr,
> >  	if (mm->map_count > sysctl_max_map_count)
> >  		return -ENOMEM;
> > =20
> > +	if (flags & MAP_HUGETLB) {
> > +		if (file)
> > +			return -EINVAL;
> > +
> > +		/*
> > +		 * VM_NORESERVE is used because the reservations will be
> > +		 * taken when vm_ops->mmap() is called
> > +		 */
> > +		len =3D ALIGN(len, huge_page_size(&default_hstate));
> > +		file =3D hugetlb_file_setup(HUGETLB_ANON_FILE, len, VM_NORESERVE,
> > +						HUGETLB_ANONHUGE_INODE);
> > +		if (IS_ERR(file))
> > +			return -ENOMEM;
> > +	}
> > +
> >  	/* Obtain the address to map to. we verify (or select) it and ensure
> >  	 * that it represents a valid section of the address space.
> >  	 */
>=20
> hugetlb_file_setup() can fail for reasons other than failing to reserve=
=20
> pages, so maybe it would be better to return PTR_ERR(file) instead of=20
> hardcoding -ENOMEM?
>=20

I will make these changes for V3, thanks for your review.

--=20
Eric B Munson
IBM Linux Technology Center
ebmunson@us.ibm.com


--ZfOjI3PrQbgiZnxM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkqFWzAACgkQsnv9E83jkzraCwCfSxw/vg/lKXE6ehhsKrwWhofz
0IYAoLLmmZPku0Q6Dxd9glh3pRa0rmg2
=e186
-----END PGP SIGNATURE-----

--ZfOjI3PrQbgiZnxM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
