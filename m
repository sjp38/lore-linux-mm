Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id BE7D86B02AE
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 05:03:59 -0400 (EDT)
Received: by padck2 with SMTP id ck2so57452981pad.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 02:03:59 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id ph10si17548391pbb.174.2015.07.17.02.03.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 02:03:58 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 01/10] mm/hugetlb: add cache of descriptors to
 resv_map for region_add
Date: Fri, 17 Jul 2015 09:02:14 +0000
Message-ID: <20150717090213.GB32135@hori1.linux.bs1.fc.nec.co.jp>
References: <1436761268-6397-1-git-send-email-mike.kravetz@oracle.com>
 <1436761268-6397-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1436761268-6397-2-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <BA73B62C4D15DB429B0C4EF6D7AE5134@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>

On Sun, Jul 12, 2015 at 09:20:59PM -0700, Mike Kravetz wrote:
> fallocate hole punch will want to remove a specific range of
> pages.  When pages are removed, their associated entries in
> the region/reserve map will also be removed.  This will break
> an assumption in the region_chg/region_add calling sequence.
> If a new region descriptor must be allocated, it is done as
> part of the region_chg processing.  In this way, region_add
> can not fail because it does not need to attempt an allocation.
>=20
> To prepare for fallocate hole punch, create a "cache" of
> descriptors that can be used by region_add if necessary.
> region_chg will ensure there are sufficient entries in the
> cache.  It will be necessary to track the number of in progress
> add operations to know a sufficient number of descriptors
> reside in the cache.  A new routine region_abort is added to
> adjust this in progress count when add operations are aborted.
> vma_abort_reservation is also added for callers creating
> reservations with vma_needs_reservation/vma_commit_reservation.
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  include/linux/hugetlb.h |   3 +
>  mm/hugetlb.c            | 169 ++++++++++++++++++++++++++++++++++++++++++=
------
>  2 files changed, 153 insertions(+), 19 deletions(-)
>=20
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index d891f94..667cf44 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -35,6 +35,9 @@ struct resv_map {
>  	struct kref refs;
>  	spinlock_t lock;
>  	struct list_head regions;
> +	long adds_in_progress;
> +	struct list_head rgn_cache;
> +	long rgn_cache_count;
>  };
>  extern struct resv_map *resv_map_alloc(void);
>  void resv_map_release(struct kref *ref);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a8c3087..241d16d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -240,11 +240,14 @@ struct file_region {
> =20
>  /*
>   * Add the huge page range represented by [f, t) to the reserve
> - * map.  Existing regions will be expanded to accommodate the
> - * specified range.  We know only existing regions need to be
> - * expanded, because region_add is only called after region_chg
> - * with the same range.  If a new file_region structure must
> - * be allocated, it is done in region_chg.
> + * map.  In the normal case, existing regions will be expanded
> + * to accommodate the specified range.  Sufficient regions should
> + * exist for expansion due to the previous call to region_chg
> + * with the same range.  However, it is possible that region_del
> + * could have been called after region_chg and modifed the map
> + * in such a way that no region exists to be expanded.  In this
> + * case, pull a region descriptor from the cache associated with
> + * the map and use that for the new range.
>   *
>   * Return the number of new huge pages added to the map.  This
>   * number is greater than or equal to zero.
> @@ -261,6 +264,27 @@ static long region_add(struct resv_map *resv, long f=
, long t)
>  		if (f <=3D rg->to)
>  			break;
> =20
> +	if (&rg->link =3D=3D head || t < rg->from) {
> +		/*
> +		 * No region exists which can be expanded to include the
> +		 * specified range.  Pull a region descriptor from the
> +		 * cache, and use it for this range.
> +		 */

This comment mentions this if-block, not the VM_BUG_ON below, so it had
better be put the above if-line.

> +		VM_BUG_ON(!resv->rgn_cache_count);

resv->rgn_cache_count <=3D 0 might be safer.

...
> @@ -3236,11 +3360,14 @@ retry:
>  	 * any allocations necessary to record that reservation occur outside
>  	 * the spinlock.
>  	 */
> -	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED))
> +	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
>  		if (vma_needs_reservation(h, vma, address) < 0) {
>  			ret =3D VM_FAULT_OOM;
>  			goto backout_unlocked;
>  		}
> +		/* Just decrements count, does not deallocate */
> +		vma_abort_reservation(h, vma, address);
> +	}

This is not "abort reservation" operation, but you use "abort reservation"
routine, which might confusing and makes future maintenance hard. I think
this should be done in a simplified variant of vma_commit_reservation()
(maybe just an alias of your vma_abort_reservation()) or fast path in
vma_commit_reservation().

Thanks,
Naoya Horiguchi

> =20
>  	ptl =3D huge_pte_lockptr(h, mm, ptep);
>  	spin_lock(ptl);
> @@ -3387,6 +3514,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_a=
rea_struct *vma,
>  			ret =3D VM_FAULT_OOM;
>  			goto out_mutex;
>  		}
> +		/* Just decrements count, does not deallocate */
> +		vma_abort_reservation(h, vma, address);
> =20
>  		if (!(vma->vm_flags & VM_MAYSHARE))
>  			pagecache_page =3D hugetlbfs_pagecache_page(h,
> @@ -3726,6 +3855,8 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	}
>  	return 0;
>  out_err:
> +	if (!vma || vma->vm_flags & VM_MAYSHARE)
> +		region_abort(resv_map, from, to);
>  	if (vma && is_vma_resv_set(vma, HPAGE_RESV_OWNER))
>  		kref_put(&resv_map->refs, resv_map_release);
>  	return ret;
> --=20
> 2.1.0
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
