Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3D382997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 02:23:48 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so11526687pab.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 23:23:48 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id cr2si1956948pdb.74.2015.05.21.23.23.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 May 2015 23:23:47 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC v3 PATCH 03/10] mm/hugetlb: add region_del() to delete a
 specific range of entries
Date: Fri, 22 May 2015 06:21:52 +0000
Message-ID: <20150522062151.GA21526@hori1.linux.bs1.fc.nec.co.jp>
References: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
 <1432223264-4414-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1432223264-4414-4-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <1AE9840382DB924890F3F5DFDFB56D43@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On Thu, May 21, 2015 at 08:47:37AM -0700, Mike Kravetz wrote:
> fallocate hole punch will want to remove a specific range of pages.
> The existing region_truncate() routine deletes all region/reserve
> map entries after a specified offset.  region_del() will provide
> this same functionality if the end of region is specified as -1.
> Hence, region_del() can replace region_truncate().
>=20
> Unlike region_truncate(), region_del() can return an error in the
> rare case where it can not allocate memory for a region descriptor.
> This ONLY happens in the case where an existing region must be split.
> Current callers passing -1 as end of range will never experience
> this error and do not need to deal with error handling.  Future
> callers of region_del() (such as fallocate hole punch) will need to
> handle this error.  A routine hugetlb_fix_reserve_counts() is added
> to assist in cleaning up if fallocate hole punch experiences this
> type of error in region_del().
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  include/linux/hugetlb.h |  1 +
>  mm/hugetlb.c            | 99 ++++++++++++++++++++++++++++++++++++++-----=
------
>  2 files changed, 79 insertions(+), 21 deletions(-)
>=20
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 7b57850..fd337f2 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -81,6 +81,7 @@ bool isolate_huge_page(struct page *page, struct list_h=
ead *list);
>  void putback_active_hugepage(struct page *page);
>  bool is_hugepage_active(struct page *page);
>  void free_huge_page(struct page *page);
> +void hugetlb_fix_reserve_counts(struct inode *inode, bool restore_reserv=
e);

This function is used in patch 6/10 for the first time,
so is it better to move the definition to that patch?
(this temporarily introduces "defined but not used" warning...)

>  #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
>  pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *p=
ud);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 63f6d43..620cc9e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -261,38 +261,74 @@ out_nrg:
>  	return chg;
>  }
> =20
> -static long region_truncate(struct resv_map *resv, long end)
> +static long region_del(struct resv_map *resv, long f, long t)
>  {
>  	struct list_head *head =3D &resv->regions;
>  	struct file_region *rg, *trg;
> +	struct file_region *nrg =3D NULL;
>  	long chg =3D 0;
> =20
> +	/*
> +	 * Locate segments we overlap and etiher split, remove or
> +	 * trim the existing regions.  The end of region (t) =3D=3D -1
> +	 * indicates all remaining regions.  Special case t =3D=3D -1 as
> +	 * all comparisons are signed.  Also, when t =3D=3D -1 it is not
> +	 * possible to return an error (-ENOMEM) as this only happens
> +	 * when splitting a region.  Callers take advantage of this
> +	 * when calling with -1.
> +	 */
> +	if (t =3D=3D -1)
> +		t =3D LONG_MAX;
> +retry:
>  	spin_lock(&resv->lock);
> -	/* Locate the region we are either in or before. */
> -	list_for_each_entry(rg, head, link)
> -		if (end <=3D rg->to)
> +	list_for_each_entry_safe(rg, trg, head, link) {
> +		if (rg->to <=3D f)
> +			continue;
> +		if (rg->from >=3D t)
>  			break;
> -	if (&rg->link =3D=3D head)
> -		goto out;
> =20
> -	/* If we are in the middle of a region then adjust it. */
> -	if (end > rg->from) {
> -		chg =3D rg->to - end;
> -		rg->to =3D end;
> -		rg =3D list_entry(rg->link.next, typeof(*rg), link);
> -	}
> +		if (f > rg->from && t < rg->to) { /* must split region */
> +			if (!nrg) {
> +				spin_unlock(&resv->lock);
> +				nrg =3D kmalloc(sizeof(*nrg), GFP_KERNEL);
> +				if (!nrg)
> +					return -ENOMEM;
> +				goto retry;
> +			}
> =20
> -	/* Drop any remaining regions. */
> -	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
> -		if (&rg->link =3D=3D head)
> +			chg +=3D t - f;
> +
> +			/* new entry for end of split region */
> +			nrg->from =3D t;
> +			nrg->to =3D rg->to;
> +			INIT_LIST_HEAD(&nrg->link);
> +
> +			/* original entry is trimmed */
> +			rg->to =3D f;
> +
> +			list_add(&nrg->link, &rg->link);
> +			nrg =3D NULL;
>  			break;
> -		chg +=3D rg->to - rg->from;
> -		list_del(&rg->link);
> -		kfree(rg);
> +		}
> +
> +		if (f <=3D rg->from && t >=3D rg->to) { /* remove entire region */
> +			chg +=3D rg->to - rg->from;
> +			list_del(&rg->link);
> +			kfree(rg);
> +			continue;
> +		}
> +
> +		if (f <=3D rg->from) {	/* trim beginning of region */
> +			chg +=3D t - rg->from;
> +			rg->from =3D t;
> +		} else {		/* trim end of region */
> +			chg +=3D rg->to - f;
> +			rg->to =3D f;

Is it better to put "break" here?

Thanks,
Naoya Horiguchi

> +		}
>  	}
> =20
> -out:
>  	spin_unlock(&resv->lock);
> +	kfree(nrg);
>  	return chg;
>  }
> =20
> @@ -324,6 +360,27 @@ static long region_count(struct resv_map *resv, long=
 f, long t)
>  }
> =20
>  /*
> + * A rare out of memory error was encountered which prevented removal of
> + * the reserve map region for a page.  The huge page itself was free''ed
> + * and removed from the page cache.  This routine will adjust the global
> + * reserve count if needed, and the subpool usage count.  By incrementin=
g
> + * these counts, the reserve map entry which could not be deleted will
> + * appear as a "reserved" entry instead of simply dangling with incorrec=
t
> + * counts.
> + */
> +void hugetlb_fix_reserve_counts(struct inode *inode, bool restore_reserv=
e)
> +{
> +	struct hugepage_subpool *spool =3D subpool_inode(inode);
> +
> +	if (restore_reserve) {
> +		struct hstate *h =3D hstate_inode(inode);
> +
> +		h->resv_huge_pages++;
> +	}
> +	hugepage_subpool_get_pages(spool, 1);
> +}
> +
> +/*
>   * Convert the address within this vma to the page offset within
>   * the mapping, in pagecache page units; huge pages here.
>   */
> @@ -427,7 +484,7 @@ void resv_map_release(struct kref *ref)
>  	struct resv_map *resv_map =3D container_of(ref, struct resv_map, refs);
> =20
>  	/* Clear out any active regions before we release the map. */
> -	region_truncate(resv_map, 0);
> +	region_del(resv_map, 0, -1);
>  	kfree(resv_map);
>  }
> =20
> @@ -3558,7 +3615,7 @@ void hugetlb_unreserve_pages(struct inode *inode, l=
ong offset, long freed)
>  	struct hugepage_subpool *spool =3D subpool_inode(inode);
> =20
>  	if (resv_map)
> -		chg =3D region_truncate(resv_map, offset);
> +		chg =3D region_del(resv_map, offset, -1);
>  	spin_lock(&inode->i_lock);
>  	inode->i_blocks -=3D (blocks_per_huge_page(h) * freed);
>  	spin_unlock(&inode->i_lock);
> --=20
> 2.1.0
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
