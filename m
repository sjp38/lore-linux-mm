Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25A092802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 23:24:26 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id h64so46137214iod.9
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 20:24:26 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id m26si9239517iod.162.2017.06.30.20.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Jun 2017 20:24:24 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id m19so4783298ioe.1
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 20:24:24 -0700 (PDT)
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <884F0682-1AF6-4C23-806F-480C86A2A036@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_D42131B6-8100-4BB3-AD69-AA0910ACEC25";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] vmalloc: respect the GFP_NOIO and GFP_NOFS flags
Date: Fri, 30 Jun 2017 21:25:02 -0600
In-Reply-To: <alpine.LRH.2.02.1706292221250.21823@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1706292221250.21823@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, John Hubbard <jhubbard@nvidia.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org


--Apple-Mail=_D42131B6-8100-4BB3-AD69-AA0910ACEC25
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jun 29, 2017, at 8:25 PM, Mikulas Patocka <mpatocka@redhat.com> =
wrote:
>=20
> The __vmalloc function has a parameter gfp_mask with the allocation =
flags,
> however it doesn't fully respect the GFP_NOIO and GFP_NOFS flags. The
> pages are allocated with the specified gfp flags, but the pagetables =
are
> always allocated with GFP_KERNEL. This allocation can cause unexpected
> recursion into the filesystem or I/O subsystem.
>=20
> It is not practical to extend page table allocation routines with gfp
> flags because it would require modification of architecture-specific =
code
> in all architecturs. However, the process can temporarily request that =
all
> allocations are done with GFP_NOFS or GFP_NOIO with with the functions
> memalloc_nofs_save and memalloc_noio_save.
>=20
> This patch makes the vmalloc code use memalloc_nofs_save or
> memalloc_noio_save if the supplied gfp flags do not contain __GFP_FS =
or
> __GFP_IO. It fixes some possible deadlocks in drivers/mtd/ubi/io.c,
> fs/gfs2/, fs/btrfs/free-space-tree.c, fs/ubifs/,
> fs/nfs/blocklayout/extent_tree.c where __vmalloc is used with the =
GFP_NOFS
> flag.
>=20
> The patch also simplifies code in dm-bufio.c, dm-ioctl.c and =
fs/xfs/kmem.c
> by removing explicit calls to memalloc_nofs_save and =
memalloc_noio_save
> before the call to __vmalloc.
>=20
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
>=20
> ---
> drivers/md/dm-bufio.c |   24 +-----------------------
> drivers/md/dm-ioctl.c |    6 +-----
> fs/xfs/kmem.c         |   14 --------------
> mm/util.c             |    6 +++---
> mm/vmalloc.c          |   18 +++++++++++++++++-
> 5 files changed, 22 insertions(+), 46 deletions(-)
>=20
> Index: linux-2.6/mm/vmalloc.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/vmalloc.c
> +++ linux-2.6/mm/vmalloc.c
> @@ -31,6 +31,7 @@
> #include <linux/compiler.h>
> #include <linux/llist.h>
> #include <linux/bitops.h>
> +#include <linux/sched/mm.h>
>=20
> #include <linux/uaccess.h>
> #include <asm/tlbflush.h>
> @@ -1670,6 +1671,8 @@ static void *__vmalloc_area_node(struct
> 	unsigned int nr_pages, array_size, i;
> 	const gfp_t nested_gfp =3D (gfp_mask & GFP_RECLAIM_MASK) | =
__GFP_ZERO;
> 	const gfp_t alloc_mask =3D gfp_mask | __GFP_HIGHMEM | =
__GFP_NOWARN;
> +	unsigned noio_flag;
> +	int r;
>=20
> 	nr_pages =3D get_vm_area_size(area) >> PAGE_SHIFT;
> 	array_size =3D (nr_pages * sizeof(struct page *));
> @@ -1712,8 +1715,21 @@ static void *__vmalloc_area_node(struct
> 			cond_resched();
> 	}
>=20
> -	if (map_vm_area(area, prot, pages))
> +	if (unlikely(!(gfp_mask & __GFP_IO)))
> +		noio_flag =3D memalloc_noio_save();
> +	else if (unlikely(!(gfp_mask & __GFP_FS)))
> +		noio_flag =3D memalloc_nofs_save();
> +
> +	r =3D map_vm_area(area, prot, pages);
> +
> +	if (unlikely(!(gfp_mask & __GFP_IO)))
> +		memalloc_noio_restore(noio_flag);
> +	else if (unlikely(!(gfp_mask & __GFP_FS)))
> +		memalloc_nofs_restore(noio_flag);

Is this really an "else if"?  I think it should just a separate "if".

Cheers, Andreas

> +
> +	if (unlikely(r))
> 		goto fail;
> +
> 	return area->addr;
>=20
> fail:
> Index: linux-2.6/mm/util.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/util.c
> +++ linux-2.6/mm/util.c
> @@ -351,10 +351,10 @@ void *kvmalloc_node(size_t size, gfp_t f
> 	void *ret;
>=20
> 	/*
> -	 * vmalloc uses GFP_KERNEL for some internal allocations (e.g =
page tables)
> -	 * so the given set of flags has to be compatible.
> +	 * vmalloc uses blocking allocations for some internal =
allocations
> +	 * (e.g page tables) so the given set of flags has to be =
compatible.
> 	 */
> -	WARN_ON_ONCE((flags & GFP_KERNEL) !=3D GFP_KERNEL);
> +	WARN_ON_ONCE(!gfpflags_allow_blocking(flags));
>=20
> 	/*
> 	 * We want to attempt a large physically contiguous block first =
because
> Index: linux-2.6/drivers/md/dm-bufio.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/drivers/md/dm-bufio.c
> +++ linux-2.6/drivers/md/dm-bufio.c
> @@ -386,9 +386,6 @@ static void __cache_size_refresh(void)
> static void *alloc_buffer_data(struct dm_bufio_client *c, gfp_t =
gfp_mask,
> 			       enum data_mode *data_mode)
> {
> -	unsigned noio_flag;
> -	void *ptr;
> -
> 	if (c->block_size <=3D DM_BUFIO_BLOCK_SIZE_SLAB_LIMIT) {
> 		*data_mode =3D DATA_MODE_SLAB;
> 		return kmem_cache_alloc(DM_BUFIO_CACHE(c), gfp_mask);
> @@ -402,26 +399,7 @@ static void *alloc_buffer_data(struct dm
> 	}
>=20
> 	*data_mode =3D DATA_MODE_VMALLOC;
> -
> -	/*
> -	 * __vmalloc allocates the data pages and auxiliary structures =
with
> -	 * gfp_flags that were specified, but pagetables are always =
allocated
> -	 * with GFP_KERNEL, no matter what was specified as gfp_mask.
> -	 *
> -	 * Consequently, we must set per-process flag PF_MEMALLOC_NOIO =
so that
> -	 * all allocations done by this process (including pagetables) =
are done
> -	 * as if GFP_NOIO was specified.
> -	 */
> -
> -	if (gfp_mask & __GFP_NORETRY)
> -		noio_flag =3D memalloc_noio_save();
> -
> -	ptr =3D __vmalloc(c->block_size, gfp_mask, PAGE_KERNEL);
> -
> -	if (gfp_mask & __GFP_NORETRY)
> -		memalloc_noio_restore(noio_flag);
> -
> -	return ptr;
> +	return __vmalloc(c->block_size, gfp_mask, PAGE_KERNEL);
> }
>=20
> /*
> Index: linux-2.6/drivers/md/dm-ioctl.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/drivers/md/dm-ioctl.c
> +++ linux-2.6/drivers/md/dm-ioctl.c
> @@ -1691,7 +1691,6 @@ static int copy_params(struct dm_ioctl _
> 	struct dm_ioctl *dmi;
> 	int secure_data;
> 	const size_t minimum_data_size =3D offsetof(struct dm_ioctl, =
data);
> -	unsigned noio_flag;
>=20
> 	if (copy_from_user(param_kernel, user, minimum_data_size))
> 		return -EFAULT;
> @@ -1714,10 +1713,7 @@ static int copy_params(struct dm_ioctl _
> 	 * suspended and the ioctl is needed to resume it.
> 	 * Use kmalloc() rather than vmalloc() when we can.
> 	 */
> -	dmi =3D NULL;
> -	noio_flag =3D memalloc_noio_save();
> -	dmi =3D kvmalloc(param_kernel->data_size, GFP_KERNEL | =
__GFP_HIGH);
> -	memalloc_noio_restore(noio_flag);
> +	dmi =3D kvmalloc(param_kernel->data_size, GFP_NOIO | =
__GFP_HIGH);
>=20
> 	if (!dmi) {
> 		if (secure_data && clear_user(user, =
param_kernel->data_size))
> Index: linux-2.6/fs/xfs/kmem.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/fs/xfs/kmem.c
> +++ linux-2.6/fs/xfs/kmem.c
> @@ -48,7 +48,6 @@ kmem_alloc(size_t size, xfs_km_flags_t f
> void *
> kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
> {
> -	unsigned nofs_flag =3D 0;
> 	void	*ptr;
> 	gfp_t	lflags;
>=20
> @@ -56,22 +55,9 @@ kmem_zalloc_large(size_t size, xfs_km_fl
> 	if (ptr)
> 		return ptr;
>=20
> -	/*
> -	 * __vmalloc() will allocate data pages and auxillary structures =
(e.g.
> -	 * pagetables) with GFP_KERNEL, yet we may be under GFP_NOFS =
context
> -	 * here. Hence we need to tell memory reclaim that we are in =
such a
> -	 * context via PF_MEMALLOC_NOFS to prevent memory reclaim =
re-entering
> -	 * the filesystem here and potentially deadlocking.
> -	 */
> -	if (flags & KM_NOFS)
> -		nofs_flag =3D memalloc_nofs_save();
> -
> 	lflags =3D kmem_flags_convert(flags);
> 	ptr =3D __vmalloc(size, lflags | __GFP_ZERO, PAGE_KERNEL);
>=20
> -	if (flags & KM_NOFS)
> -		memalloc_nofs_restore(nofs_flag);
> -
> 	return ptr;
> }
>=20


Cheers, Andreas






--Apple-Mail=_D42131B6-8100-4BB3-AD69-AA0910ACEC25
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFZVxYQpIg59Q01vtYRAsGwAJ9L8Y/1BSlhXOvJZMFAA9QQHyJ5UACfceWV
gsULdFFigkVPTw0cT/0R9GM=
=OCMD
-----END PGP SIGNATURE-----

--Apple-Mail=_D42131B6-8100-4BB3-AD69-AA0910ACEC25--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
