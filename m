Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8A09F6B0055
	for <linux-mm@kvack.org>; Tue, 26 May 2009 08:53:35 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4QCrhNr028378
	for <linux-mm@kvack.org>; Tue, 26 May 2009 06:53:43 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4QCsLmj208532
	for <linux-mm@kvack.org>; Tue, 26 May 2009 06:54:21 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4QCsJh3019295
	for <linux-mm@kvack.org>; Tue, 26 May 2009 06:54:20 -0600
Date: Tue, 26 May 2009 13:54:16 +0100
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [PATCH] Determine if mapping is MAP_SHARED using VM_MAYSHARE
	and not VM_SHARED in hugetlbfs
Message-ID: <20090526125416.GA13200@us.ibm.com>
References: <20090519083619.GD19146@csn.ul.ie> <Pine.LNX.4.64.0905252122370.8557@sister.anvils> <20090526101245.GA4345@csn.ul.ie>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/9DWx/yDrRhgMJTb"
Content-Disposition: inline
In-Reply-To: <20090526101245.GA4345@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, npiggin@suse.de, apw@shadowen.org, agl@us.ibm.com, andi@firstfloor.org, david@gibson.dropbear.id.au, kenchen@google.com, wli@holomorphy.com, akpm@linux-foundation.org, starlight@binnacle.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

<snip>
> Here is V2 of the patch. Starlight, can you confirm this patch fixes
> your problem for 2.6.29.4? Eric, can you confirm this passes
> libhugetlbfs tests and not screw something else up?
>=20
> Thanks

This patch passes all libhugetlbfs tests on x86_64 and ppc64 using kernels
2.6.29.4 and 2.6.30-rc7.

Tested-by: Eric B Munson <ebmunson@us.ibm.com>
>=20
> =3D=3D=3D=3D CUT HERE =3D=3D=3D=3D
> From 3ea2ed7c5f307bc4b53cfe2ceddd90c8e1298078 Mon Sep 17 00:00:00 2001
> From: Mel Gorman <mel@csn.ul.ie>
> Date: Tue, 26 May 2009 10:47:09 +0100
> Subject: [PATCH] Account for MAP_SHARED mappings using VM_MAYSHARE and no=
t VM_SHARED in hugetlbfs V2
>=20
> Changelog since V1
>   o Convert follow_hugetlb_page to use VM_MAYSHARE
>=20
> hugetlbfs reserves huge pages and accounts for them differently depending=
 on
> whether the mapping was mapped MAP_SHARED or MAP_PRIVATE. For MAP_SHARED
> mappings, hugepages are reserved when mmap() is first called and are
> tracked based on information associated with the inode. MAP_PRIVATE track
> the reservations based on the VMA created as part of the mmap() operation.
>=20
> However, the check hugetlbfs makes when determining if a VMA is MAP_SHARED
> is with the VM_SHARED flag and not VM_MAYSHARE.  For file-backed mappings,
> such as hugetlbfs, VM_SHARED is set only if the mapping is MAP_SHARED
> and the file was opened read-write. If a shared memory mapping was mapped
> shared-read-write for populating of data and mapped shared-read-only by
> other processes, then hugetlbfs gets inconsistent on how it accounts for
> the creation of reservations and how they are consumed.
>=20
> This patch alters mm/hugetlb.c and replaces VM_SHARED with VM_MAYSHARE wh=
en
> the intent of the code was to check whether the VMA was mapped MAP_SHARED
> or MAP_PRIVATE.
>=20
> If this patch passes review, it's needed for 2.6.30 and -stable.
>=20
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---=20
>  mm/hugetlb.c |   28 ++++++++++++++--------------
>  1 file changed, 14 insertions(+), 14 deletions(-)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 28c655b..3687f42 100644
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
> @@ -2168,7 +2168,7 @@ int follow_hugetlb_page(struct mm_struct *mm, struc=
t vm_area_struct *vma,
>  	int remainder =3D *length;
>  	struct hstate *h =3D hstate_vma(vma);
>  	int zeropage_ok =3D 0;
> -	int shared =3D vma->vm_flags & VM_SHARED;
> +	int shared =3D vma->vm_flags & VM_MAYSHARE;
>=20
>  	spin_lock(&mm->page_table_lock);
>  	while (vaddr < vma->vm_end && remainder) {
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


--/9DWx/yDrRhgMJTb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkob5ngACgkQsnv9E83jkzoEmQCguSz9VoS+DkEXfm3bFwcP7Bs9
I7cAn2sq7vZBoOA8DCIVsn2lDcnpd9Ir
=5FlT
-----END PGP SIGNATURE-----

--/9DWx/yDrRhgMJTb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
