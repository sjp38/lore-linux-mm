Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 79DC26B005D
	for <linux-mm@kvack.org>; Wed, 20 May 2009 06:12:24 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4KA86U4014435
	for <linux-mm@kvack.org>; Wed, 20 May 2009 06:08:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4KACUnC152940
	for <linux-mm@kvack.org>; Wed, 20 May 2009 06:12:30 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4KAARWD016192
	for <linux-mm@kvack.org>; Wed, 20 May 2009 06:10:28 -0400
Date: Wed, 20 May 2009 11:12:24 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH] Determine if mapping is MAP_SHARED using VM_MAYSHARE
	and not VM_SHARED in hugetlbfs
Message-ID: <20090520101224.GA6420@us.ibm.com>
References: <20090519083619.GD19146@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xHFwDpU9dbj6ez1V"
Content-Disposition: inline
In-Reply-To: <20090519083619.GD19146@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, npiggin@suse.de, apw@shadowen.org, andi@firstfloor.org, hugh@veritas.com, avid@gibson.dropbear.id.au, kenneth.w.chen@intel.com, wli@holomorphy.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, starlight@binnacle.cx
List-ID: <linux-mm.kvack.org>


--xHFwDpU9dbj6ez1V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 19 May 2009, Mel Gorman wrote:

> hugetlbfs reserves huge pages and accounts for them differently depending
> on whether the mapping was mapped MAP_SHARED or MAP_PRIVATE. However, the
> check made against VMA->vm_flags is sometimes VM_SHARED and not VM_MAYSHA=
RE.
> For file-backed mappings, such as hugetlbfs, VM_SHARED is set only if the
> mapping is MAP_SHARED *and* it is read-write. For example, if a shared
> memory mapping was created read-write with shmget() for populating of data
> and mapped SHM_RDONLY by other processes, then hugetlbfs gets the account=
ing
> wrong and reservations leak.
>=20
> This patch alters mm/hugetlb.c and replaces VM_SHARED with VM_MAYSHARE wh=
en
> the intent of the code was to check whether the VMA was mapped MAP_SHARED
> or MAP_PRIVATE.
>=20
> The patch needs wider review as there are places where we really mean
> VM_SHARED and not VM_MAYSHARE. I believe I got all the right places, but a
> second opinion is needed. When/if this patch passes review, it'll be need=
ed
> for 2.6.30 and -stable as it partially addresses the problem reported in
> http://bugzilla.kernel.org/show_bug.cgi?id=3D13302 and
> http://bugzilla.kernel.org/show_bug.cgi?id=3D12134.
>=20
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

The libhugetlbfs test suite has a test that triggers this bug reliably, I h=
ave
run this test both with and without this patch on x86_64 and ppc64.  The bug
triggers every time wiouth the patch and does not with the patch applied.

Tested-by: Eric B Munson <ebmunson@us.ibm.com>

> ---=20
>  mm/hugetlb.c |   26 +++++++++++++-------------
>  1 file changed, 13 insertions(+), 13 deletions(-)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 28c655b..e83ad2c 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -316,7 +316,7 @@ static void resv_map_release(struct kref *ref)
>  static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> -	if (!(vma->vm_flags & VM_SHARED))
> +	if (!(vma->vm_flags & VM_MAYSHARE))
>  		return (struct resv_map *)(get_vma_private_data(vma) &
>  							~HPAGE_RESV_MASK);
>  	return NULL;
> @@ -325,7 +325,7 @@ static struct resv_map *vma_resv_map(struct vm_area_s=
truct *vma)
>  static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map=
 *map)
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> -	VM_BUG_ON(vma->vm_flags & VM_SHARED);
> +	VM_BUG_ON(vma->vm_flags & VM_MAYSHARE);
>=20
>  	set_vma_private_data(vma, (get_vma_private_data(vma) &
>  				HPAGE_RESV_MASK) | (unsigned long)map);
> @@ -334,7 +334,7 @@ static void set_vma_resv_map(struct vm_area_struct *v=
ma, struct resv_map *map)
>  static void set_vma_resv_flags(struct vm_area_struct *vma, unsigned long=
 flags)
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> -	VM_BUG_ON(vma->vm_flags & VM_SHARED);
> +	VM_BUG_ON(vma->vm_flags & VM_MAYSHARE);
>=20
>  	set_vma_private_data(vma, get_vma_private_data(vma) | flags);
>  }
> @@ -353,7 +353,7 @@ static void decrement_hugepage_resv_vma(struct hstate=
 *h,
>  	if (vma->vm_flags & VM_NORESERVE)
>  		return;
>=20
> -	if (vma->vm_flags & VM_SHARED) {
> +	if (vma->vm_flags & VM_MAYSHARE) {
>  		/* Shared mappings always use reserves */
>  		h->resv_huge_pages--;
>  	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> @@ -369,14 +369,14 @@ static void decrement_hugepage_resv_vma(struct hsta=
te *h,
>  void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> -	if (!(vma->vm_flags & VM_SHARED))
> +	if (!(vma->vm_flags & VM_MAYSHARE))
>  		vma->vm_private_data =3D (void *)0;
>  }
>=20
>  /* Returns true if the VMA has associated reserve pages */
>  static int vma_has_reserves(struct vm_area_struct *vma)
>  {
> -	if (vma->vm_flags & VM_SHARED)
> +	if (vma->vm_flags & VM_MAYSHARE)
>  		return 1;
>  	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
>  		return 1;
> @@ -924,7 +924,7 @@ static long vma_needs_reservation(struct hstate *h,
>  	struct address_space *mapping =3D vma->vm_file->f_mapping;
>  	struct inode *inode =3D mapping->host;
>=20
> -	if (vma->vm_flags & VM_SHARED) {
> +	if (vma->vm_flags & VM_MAYSHARE) {
>  		pgoff_t idx =3D vma_hugecache_offset(h, vma, addr);
>  		return region_chg(&inode->i_mapping->private_list,
>  							idx, idx + 1);
> @@ -949,7 +949,7 @@ static void vma_commit_reservation(struct hstate *h,
>  	struct address_space *mapping =3D vma->vm_file->f_mapping;
>  	struct inode *inode =3D mapping->host;
>=20
> -	if (vma->vm_flags & VM_SHARED) {
> +	if (vma->vm_flags & VM_MAYSHARE) {
>  		pgoff_t idx =3D vma_hugecache_offset(h, vma, addr);
>  		region_add(&inode->i_mapping->private_list, idx, idx + 1);
>=20
> @@ -1893,7 +1893,7 @@ retry_avoidcopy:
>  	 * at the time of fork() could consume its reserves on COW instead
>  	 * of the full address range.
>  	 */
> -	if (!(vma->vm_flags & VM_SHARED) &&
> +	if (!(vma->vm_flags & VM_MAYSHARE) &&
>  			is_vma_resv_set(vma, HPAGE_RESV_OWNER) &&
>  			old_page !=3D pagecache_page)
>  		outside_reserve =3D 1;
> @@ -2000,7 +2000,7 @@ retry:
>  		clear_huge_page(page, address, huge_page_size(h));
>  		__SetPageUptodate(page);
>=20
> -		if (vma->vm_flags & VM_SHARED) {
> +		if (vma->vm_flags & VM_MAYSHARE) {
>  			int err;
>  			struct inode *inode =3D mapping->host;
>=20
> @@ -2104,7 +2104,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_a=
rea_struct *vma,
>  			goto out_mutex;
>  		}
>=20
> -		if (!(vma->vm_flags & VM_SHARED))
> +		if (!(vma->vm_flags & VM_MAYSHARE))
>  			pagecache_page =3D hugetlbfs_pagecache_page(h,
>  								vma, address);
>  	}
> @@ -2289,7 +2289,7 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	 * to reserve the full area even if read-only as mprotect() may be
>  	 * called to make the mapping read-write. Assume !vma is a shm mapping
>  	 */
> -	if (!vma || vma->vm_flags & VM_SHARED)
> +	if (!vma || vma->vm_flags & VM_MAYSHARE)
>  		chg =3D region_chg(&inode->i_mapping->private_list, from, to);
>  	else {
>  		struct resv_map *resv_map =3D resv_map_alloc();
> @@ -2330,7 +2330,7 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	 * consumed reservations are stored in the map. Hence, nothing
>  	 * else has to be done for private mappings here
>  	 */
> -	if (!vma || vma->vm_flags & VM_SHARED)
> +	if (!vma || vma->vm_flags & VM_MAYSHARE)
>  		region_add(&inode->i_mapping->private_list, from, to);
>  	return 0;
>  }
>=20

--=20
Eric B Munson
IBM Linux Technology Center
ebmunson@us.ibm.com


--xHFwDpU9dbj6ez1V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkoT14gACgkQsnv9E83jkzpF0QCffdjUi+Mo58V9JBYh/6V8LRFH
2a8AniFJAty6tBti1IyHH5tEvzy9zbCo
=eaad
-----END PGP SIGNATURE-----

--xHFwDpU9dbj6ez1V--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
