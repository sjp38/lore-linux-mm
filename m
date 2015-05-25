Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id D0B316B0283
	for <linux-mm@kvack.org>; Mon, 25 May 2015 02:28:04 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so64666090pac.2
        for <linux-mm@kvack.org>; Sun, 24 May 2015 23:28:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id dp4si14726434pbb.222.2015.05.24.23.28.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 24 May 2015 23:28:03 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t4P6S03c005722
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 25 May 2015 15:28:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/2] mm/hugetlb: compute/return the number of regions
 added by region_add()
Date: Mon, 25 May 2015 06:19:25 +0000
Message-ID: <20150525061922.GA3751@hori1.linux.bs1.fc.nec.co.jp>
References: <1432353304-12767-1-git-send-email-mike.kravetz@oracle.com>
 <1432353304-12767-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1432353304-12767-2-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5E0125B91C9A7C4BB5C72848992A6F19@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, May 22, 2015 at 08:55:03PM -0700, Mike Kravetz wrote:
> Modify region_add() to keep track of regions(pages) added to the
> reserve map and return this value.  The return value can be
> compared to the return value of region_chg() to determine if the
> map was modified between calls.
>=20
> Add documentation to the reserve/region map routines.
>=20
> Make vma_commit_reservation() also pass along the return value of
> region_add().  In the normal case, we want vma_commit_reservation
> to return the same value as the preceding call to vma_needs_reservation.
> Create a common __vma_reservation_common routine to help keep the
> special case return values in sync
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/hugetlb.c | 120 ++++++++++++++++++++++++++++++++++++++++++++++-------=
------
>  1 file changed, 94 insertions(+), 26 deletions(-)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 54f129d..3855889 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -212,8 +212,16 @@ static inline struct hugepage_subpool *subpool_vma(s=
truct vm_area_struct *vma)
>   * Region tracking -- allows tracking of reservations and instantiated p=
ages
>   *                    across the pages in a mapping.
>   *
> - * The region data structures are embedded into a resv_map and
> - * protected by a resv_map's lock
> + * The region data structures are embedded into a resv_map and protected
> + * by a resv_map's lock.  The set of regions within the resv_map represe=
nt
> + * reservations for huge pages, or huge pages that have already been
> + * instantiated within the map.

>  The from and to elements are huge page
> + * indicies into the associated mapping.  from indicates the starting in=
dex
> + * of the region.  to represents the first index past the end of  the re=
gion.
> + * For example, a file region structure with from =3D=3D 0 and to =3D=3D=
 4 represents
> + * four huge pages in a mapping.  It is important to note that the to el=
ement
> + * represents the first element past the end of the region. This is used=
 in
> + * arithmetic as 4(to) - 0(from) =3D 4 huge pages in the region.

How about just saying "[from, to)", which implies "from" is inclusive and "=
to"
is exclusive. I hope this mathematical notation is widely accepted among ke=
rnel
developers.

>   */
>  struct file_region {
>  	struct list_head link;
> @@ -221,10 +229,23 @@ struct file_region {
>  	long to;
>  };
> =20
> +/*
> + * Add the huge page range represented by indicies f (from)
> + * and t (to) to the reserve map.  Existing regions will be
> + * expanded to accommodate the specified range.  We know only
> + * existing regions need to be expanded, because region_add
> + * is only called after region_chg(with the same range).  If
> + * a new file_region structure must be allocated, it is done
> + * in region_chg.
> + *
> + * Return the number of new huge pages added to the map.  This
> + * number is greater than or equal to zero.
> + */
>  static long region_add(struct resv_map *resv, long f, long t)
>  {
>  	struct list_head *head =3D &resv->regions;
>  	struct file_region *rg, *nrg, *trg;
> +	long add =3D 0;
> =20
>  	spin_lock(&resv->lock);
>  	/* Locate the region we are either in or before. */
> @@ -250,16 +271,44 @@ static long region_add(struct resv_map *resv, long =
f, long t)
>  		if (rg->to > t)
>  			t =3D rg->to;
>  		if (rg !=3D nrg) {
> +			/* Decrement return value by the deleted range.
> +			 * Another range will span this area so that by
> +			 * end of routine add will be >=3D zero
> +			 */
> +			add -=3D (rg->to - rg->from);

I can't say how, but if file_region data were broken for some reason (mainl=
y
due to bug,) this could return negative value, so how about asserting add >=
=3D0
with VM_BUG_ON() at the end of this function?

>  			list_del(&rg->link);
>  			kfree(rg);
>  		}
>  	}
> +
> +	add +=3D (nrg->from - f);		/* Added to beginning of region */
>  	nrg->from =3D f;
> +	add +=3D t - nrg->to;		/* Added to end of region */
>  	nrg->to =3D t;
> +
>  	spin_unlock(&resv->lock);
> -	return 0;
> +	return add;
>  }
> =20
> +/*
> + * Examine the existing reserve map and determine how many
> + * huge pages in the specified range (f, t) are NOT currently

"[f, t)" would be better.

> + * represented.  This routine is called before a subsequent
> + * call to region_add that will actually modify the reserve
> + * map to add the specified range (f, t).  region_chg does
> + * not change the number of huge pages represented by the
> + * map.  However, if the existing regions in the map can not
> + * be expanded to represent the new range, a new file_region
> + * structure is added to the map as a placeholder.  This is
> + * so that the subsequent region_add call will have all
> + * regions it needs and will not fail.
> + *
> + * Returns the number of huge pages that need to be added
> + * to the existing reservation map for the range (f, t).
> + * This number is greater or equal to zero.  -ENOMEM is
> + * returned if a new  file_region structure can not be
> + * allocated.
> + */
>  static long region_chg(struct resv_map *resv, long f, long t)
>  {
>  	struct list_head *head =3D &resv->regions;
> @@ -326,6 +375,11 @@ out_nrg:
>  	return chg;
>  }
> =20
> +/*
> + * Truncate the reserve map at index 'end'.  Modify/truncate any
> + * region which contains end.  Delete any regions past end.
> + * Return the number of huge pages removed from the map.
> + */
>  static long region_truncate(struct resv_map *resv, long end)
>  {
>  	struct list_head *head =3D &resv->regions;
> @@ -361,6 +415,10 @@ out:
>  	return chg;
>  }
> =20
> +/*
> + * Count and return the number of huge pages in the reserve map
> + * that intersect with the range (f, t).
> + */
>  static long region_count(struct resv_map *resv, long f, long t)
>  {
>  	struct list_head *head =3D &resv->regions;
> @@ -1424,46 +1482,56 @@ static void return_unused_surplus_pages(struct hs=
tate *h,
>  }
> =20
>  /*
> - * Determine if the huge page at addr within the vma has an associated
> - * reservation.  Where it does not we will need to logically increase
> - * reservation and actually increase subpool usage before an allocation
> - * can occur.  Where any new reservation would be required the
> - * reservation change is prepared, but not committed.  Once the page
> - * has been allocated from the subpool and instantiated the change shoul=
d
> - * be committed via vma_commit_reservation.  No action is required on
> - * failure.
> + * vma_needs_reservation and vma_commit_reservation are used by the huge
> + * page allocation routines to manage reservations.
> + *
> + * vma_needs_reservation is called to determine if the huge page at addr
> + * within the vma has an associated reservation.  If a reservation is
> + * needed, the value 1 is returned.  The caller is then responsible for
> + * managing the global reservation and subpool usage counts.  After
> + * the huge page has been allocated, vma_commit_reservation is called
> + * to add the page to the reservation map.
> + *
> + * In the normal case, vma_commit_reservation should return the same val=
ue
> + * as the preceding vma_needs_reservation call.  The only time this is
> + * not the case is if a reserve map was changed between calls.  It is th=
e
> + * responsibility of the caller to notice the difference and take approp=
riate
> + * action.
>   */
> -static long vma_needs_reservation(struct hstate *h,
> -			struct vm_area_struct *vma, unsigned long addr)
> +static long __vma_reservation_common(struct hstate *h,
> +				struct vm_area_struct *vma, unsigned long addr,
> +				bool needs)
>  {
>  	struct resv_map *resv;
>  	pgoff_t idx;
> -	long chg;
> +	long ret;
> =20
>  	resv =3D vma_resv_map(vma);
>  	if (!resv)
>  		return 1;
> =20
>  	idx =3D vma_hugecache_offset(h, vma, addr);
> -	chg =3D region_chg(resv, idx, idx + 1);
> +	if (needs)
> +		ret =3D region_chg(resv, idx, idx + 1);
> +	else
> +		ret =3D region_add(resv, idx, idx + 1);

This code sharing is OK, but the name "needs" looks a bit unclear to me.
I feel that it's more readable if we name "commit" (or "commits") to the bo=
ol
parameter and call region_add() if "commit" is true.

> =20
>  	if (vma->vm_flags & VM_MAYSHARE)
> -		return chg;
> +		return ret;
>  	else
> -		return chg < 0 ? chg : 0;
> +		return ret < 0 ? ret : 0;
>  }
> -static void vma_commit_reservation(struct hstate *h,
> +
> +static long vma_needs_reservation(struct hstate *h,
>  			struct vm_area_struct *vma, unsigned long addr)
>  {
> -	struct resv_map *resv;
> -	pgoff_t idx;
> -
> -	resv =3D vma_resv_map(vma);
> -	if (!resv)
> -		return;
> +	return __vma_reservation_common(h, vma, addr, (bool)1);

You can simply use literal "true"?

Thanks,
Naoya Horiguchi

> +}
> =20
> -	idx =3D vma_hugecache_offset(h, vma, addr);
> -	region_add(resv, idx, idx + 1);
> +static long vma_commit_reservation(struct hstate *h,
> +			struct vm_area_struct *vma, unsigned long addr)
> +{
> +	return __vma_reservation_common(h, vma, addr, (bool)0);
>  }
> =20
>  static struct page *alloc_huge_page(struct vm_area_struct *vma,
> --=20
> 2.1.0
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
