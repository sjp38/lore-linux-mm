Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0D96B006C
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 02:36:14 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so59241178pab.3
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 23:36:13 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id t2si2693352pbs.233.2015.06.14.23.36.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 14 Jun 2015 23:36:13 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC v4 PATCH 6/9] mm/hugetlb: alloc_huge_page handle areas
 hole punched by fallocate
Date: Mon, 15 Jun 2015 06:34:44 +0000
Message-ID: <20150615063444.GA26050@hori1.linux.bs1.fc.nec.co.jp>
References: <1434056500-2434-1-git-send-email-mike.kravetz@oracle.com>
 <1434056500-2434-7-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1434056500-2434-7-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <0973F4C9DF3D014497DE3B4EE258431B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On Thu, Jun 11, 2015 at 02:01:37PM -0700, Mike Kravetz wrote:
> Areas hole punched by fallocate will not have entries in the
> region/reserve map.  However, shared mappings with min_size subpool
> reservations may still have reserved pages.  alloc_huge_page needs
> to handle this special case and do the proper accounting.
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/hugetlb.c | 48 +++++++++++++++++++++++++++---------------------
>  1 file changed, 27 insertions(+), 21 deletions(-)
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ecbaffe..9c295c9 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -692,19 +692,9 @@ static int vma_has_reserves(struct vm_area_struct *v=
ma, long chg)
>  			return 0;
>  	}
> =20
> -	if (vma->vm_flags & VM_MAYSHARE) {
> -		/*
> -		 * We know VM_NORESERVE is not set.  Therefore, there SHOULD
> -		 * be a region map for all pages.  The only situation where
> -		 * there is no region map is if a hole was punched via
> -		 * fallocate.  In this case, there really are no reverves to
> -		 * use.  This situation is indicated if chg !=3D 0.
> -		 */
> -		if (chg)
> -			return 0;
> -		else
> -			return 1;
> -	}
> +	/* Shared mappings always use reserves */
> +	if (vma->vm_flags & VM_MAYSHARE)
> +		return 1;

This change completely reverts 5/9, so can you omit 5/9?

> =20
>  	/*
>  	 * Only the process that called mmap() has reserves for
> @@ -1601,6 +1591,7 @@ static struct page *alloc_huge_page(struct vm_area_=
struct *vma,
>  	struct hstate *h =3D hstate_vma(vma);
>  	struct page *page;
>  	long chg, commit;
> +	long gbl_chg;
>  	int ret, idx;
>  	struct hugetlb_cgroup *h_cg;
> =20
> @@ -1608,24 +1599,39 @@ static struct page *alloc_huge_page(struct vm_are=
a_struct *vma,
>  	/*
>  	 * Processes that did not create the mapping will have no
>  	 * reserves and will not have accounted against subpool
> -	 * limit. Check that the subpool limit can be made before
> -	 * satisfying the allocation MAP_NORESERVE mappings may also
> -	 * need pages and subpool limit allocated allocated if no reserve
> -	 * mapping overlaps.
> +	 * limit. Check that the subpool limit will not be exceeded
> +	 * before performing the allocation.  Allocations for
> +	 * MAP_NORESERVE mappings also need to be checked against
> +	 * any subpool limit.
> +	 *
> +	 * NOTE: Shared mappings with holes punched via fallocate
> +	 * may still have reservations, even without entries in the
> +	 * reserve map as indicated by vma_needs_reservation.  This
> +	 * would be the case if hugepage_subpool_get_pages returns
> +	 * zero to indicate no changes to the global reservation count
> +	 * are necessary.  In this case, pass the output of
> +	 * hugepage_subpool_get_pages (zero) to dequeue_huge_page_vma
> +	 * so that the page is not counted against the global limit.
> +	 * For MAP_NORESERVE mappings always pass the output of
> +	 * vma_needs_reservation.  For race detection and error cleanup
> +	 * use output of vma_needs_reservation as well.
>  	 */
> -	chg =3D vma_needs_reservation(h, vma, addr);
> +	chg =3D gbl_chg =3D vma_needs_reservation(h, vma, addr);
>  	if (chg < 0)
>  		return ERR_PTR(-ENOMEM);
> -	if (chg || avoid_reserve)
> -		if (hugepage_subpool_get_pages(spool, 1) < 0)
> +	if (chg || avoid_reserve) {
> +		gbl_chg =3D hugepage_subpool_get_pages(spool, 1);
> +		if (gbl_chg < 0)
>  			return ERR_PTR(-ENOSPC);
> +	}
> =20
>  	ret =3D hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg=
);
>  	if (ret)
>  		goto out_subpool_put;
> =20
>  	spin_lock(&hugetlb_lock);
> -	page =3D dequeue_huge_page_vma(h, vma, addr, avoid_reserve, chg);
> +	page =3D dequeue_huge_page_vma(h, vma, addr, avoid_reserve,
> +					avoid_reserve ? chg : gbl_chg);

You use chg or gbl_chg depending on avoid_reserve here, and below this line
there's code like below

	commit =3D vma_commit_reservation(h, vma, addr);
	if (unlikely(chg > commit)) {
		...
	}

This also need to be changed to use chg or gbl_chg depending on avoid_reser=
ve?

# I feel that this reserve-handling code in alloc_huge_page() is too compli=
cated
# and hard to understand, so some cleanup like separating reserve parts int=
o
# other new routine(s) might be helpful...

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
