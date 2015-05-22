Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8AAAA82997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 04:10:26 -0400 (EDT)
Received: by pdea3 with SMTP id a3so13782199pde.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 01:10:26 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id br4si2340329pbb.47.2015.05.22.01.10.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 01:10:25 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC v3 PATCH 06/10] hugetlbfs: truncate_hugepages() takes a
 range of pages
Date: Fri, 22 May 2015 08:08:12 +0000
Message-ID: <20150522080810.GC21526@hori1.linux.bs1.fc.nec.co.jp>
References: <1432223264-4414-1-git-send-email-mike.kravetz@oracle.com>
 <1432223264-4414-7-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1432223264-4414-7-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <2562AE1E5DEA6F46AF20906D89FE79F0@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christoph Hellwig <hch@infradead.org>

On Thu, May 21, 2015 at 08:47:40AM -0700, Mike Kravetz wrote:
> Modify truncate_hugepages() to take a range of pages (start, end)
> instead of simply start. If an end value of -1 is passed, the
> current "truncate" functionality is maintained. Existing callers
> are modified to pass -1 as end of range. By keying off end =3D=3D -1,
> the routine behaves differently for truncate and hole punch.
> Page removal is now synchronized with page allocation via faults
> by using the fault mutex table. The hole punch case can experience
> the rare region_del error and must handle accordingly.
>=20
> Since the routine handles more than just the truncate case, it is
> renamed to remove_inode_hugepages().  To be consistent, the routine
> truncate_huge_page() is renamed remove_huge_page().
>=20
> Downstream of remove_inode_hugepages(), the routine
> hugetlb_unreserve_pages() is also modified to take a range of pages.
> hugetlb_unreserve_pages is modified to detect an error from
> region_del and pass it back to the caller.
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  fs/hugetlbfs/inode.c    | 88 +++++++++++++++++++++++++++++++++++++++++++=
------
>  include/linux/hugetlb.h |  3 +-
>  mm/hugetlb.c            | 17 ++++++++--
>  3 files changed, 94 insertions(+), 14 deletions(-)
>=20
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index dda529c..dfa88a5 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -317,26 +317,53 @@ static int hugetlbfs_write_end(struct file *file, s=
truct address_space *mapping,
>  	return -EINVAL;
>  }
> =20
> -static void truncate_huge_page(struct page *page)
> +static void remove_huge_page(struct page *page)
>  {
>  	cancel_dirty_page(page, /* No IO accounting for huge pages? */0);
>  	ClearPageUptodate(page);
>  	delete_from_page_cache(page);
>  }
> =20
> -static void truncate_hugepages(struct inode *inode, loff_t lstart)
> +/*
> + * remove_inode_hugepages handles two distinct cases: truncation and hol=
e punch
> + * truncation is indicated by end of range being -1
> + *	In this case, we first scan the range and release found pages.
> + *	After releasing pages, hugetlb_unreserve_pages cleans up region/reser=
v
> + *	maps and global counts.
> + * hole punch is indicated if end is not -1
> + *	In the hole punch case we scan the range and release found pages.
> + *	Only when releasing a page is the associated region/reserv map
> + *	deleted.  The region/reserv map for ranges without associated
> + *	pages are not modified.

If lend is not -1 but large enough to go beyond the end of file, which
should it be handled by truncate operation or hole punch operation?
If it makes no difference or never happens, it's OK with some comments.

Thanks,
Naoya Horiguchi

> + */
> +static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
> +				   loff_t lend)
>  {
>  	struct hstate *h =3D hstate_inode(inode);
>  	struct address_space *mapping =3D &inode->i_data;
>  	const pgoff_t start =3D lstart >> huge_page_shift(h);
> +	const pgoff_t end =3D lend >> huge_page_shift(h);
>  	struct pagevec pvec;
>  	pgoff_t next;
>  	int i, freed =3D 0;
> +	long lookup_nr =3D PAGEVEC_SIZE;
> +	bool truncate_op =3D (lend =3D=3D -1);
> =20
>  	pagevec_init(&pvec, 0);
>  	next =3D start;
> -	while (1) {
> -		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
> +	while (next < end) {
> +		/*
> +		 * Make sure to never grab more pages that we
> +		 * might possibly need.
> +		 */
> +		if (end - next < lookup_nr)
> +			lookup_nr =3D end - next;
> +
> +		/*
> +		 * This pagevec_lookup() may return pages past 'end',
> +		 * so we must check for page->index > end.
> +		 */
> +		if (!pagevec_lookup(&pvec, mapping, next, lookup_nr)) {
>  			if (next =3D=3D start)
>  				break;
>  			next =3D start;
> @@ -345,26 +372,67 @@ static void truncate_hugepages(struct inode *inode,=
 loff_t lstart)
> =20
>  		for (i =3D 0; i < pagevec_count(&pvec); ++i) {
>  			struct page *page =3D pvec.pages[i];
> +			u32 hash;
> +
> +			hash =3D hugetlb_fault_mutex_shared_hash(mapping, next);
> +			hugetlb_fault_mutex_lock(hash);
> =20
>  			lock_page(page);
> +			if (page->index >=3D end) {
> +				unlock_page(page);
> +				hugetlb_fault_mutex_unlock(hash);
> +				next =3D end;	/* we are done */
> +				break;
> +			}
> +
> +			/*
> +			 * If page is mapped, it was faulted in after being
> +			 * unmapped.  Do nothing in this race case.  In the
> +			 * normal case page is not mapped.
> +			 */
> +			if (!page_mapped(page)) {
> +				bool rsv_on_error =3D !PagePrivate(page);
> +				/*
> +				 * We must free the huge page and remove
> +				 * from page cache (remove_huge_page) BEFORE
> +				 * removing the region/reserve map
> +				 * (hugetlb_unreserve_pages).  In rare out
> +				 * of memory conditions, removal of the
> +				 * region/reserve map could fail.  Before
> +				 * free'ing the page, note PagePrivate which
> +				 * is used in case of error.
> +				 */
> +				remove_huge_page(page);
> +				freed++;
> +				if (!truncate_op) {
> +					if (unlikely(hugetlb_unreserve_pages(
> +							inode, next,
> +							next + 1, 1)))
> +						hugetlb_fix_reserve_counts(
> +							inode, rsv_on_error);
> +				}
> +			}
> +
>  			if (page->index > next)
>  				next =3D page->index;
> +
>  			++next;
> -			truncate_huge_page(page);
>  			unlock_page(page);
> -			freed++;
> +
> +			hugetlb_fault_mutex_unlock(hash);
>  		}
>  		huge_pagevec_release(&pvec);
>  	}
> -	BUG_ON(!lstart && mapping->nrpages);
> -	hugetlb_unreserve_pages(inode, start, freed);
> +
> +	if (truncate_op)
> +		(void)hugetlb_unreserve_pages(inode, start, end, freed);
>  }
> =20
>  static void hugetlbfs_evict_inode(struct inode *inode)
>  {
>  	struct resv_map *resv_map;
> =20
> -	truncate_hugepages(inode, 0);
> +	remove_inode_hugepages(inode, 0, -1);
>  	resv_map =3D (struct resv_map *)inode->i_mapping->private_data;
>  	/* root inode doesn't have the resv_map, so we should check it */
>  	if (resv_map)
> @@ -421,7 +489,7 @@ static int hugetlb_vmtruncate(struct inode *inode, lo=
ff_t offset)
>  	if (!RB_EMPTY_ROOT(&mapping->i_mmap))
>  		hugetlb_vmdelete_list(&mapping->i_mmap, pgoff, 0);
>  	i_mmap_unlock_write(mapping);
> -	truncate_hugepages(inode, offset);
> +	remove_inode_hugepages(inode, offset, -1);
>  	return 0;
>  }
> =20
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index d0d033e..4c2856e 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -75,7 +75,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_=
struct *vma,
>  int hugetlb_reserve_pages(struct inode *inode, long from, long to,
>  						struct vm_area_struct *vma,
>  						vm_flags_t vm_flags);
> -void hugetlb_unreserve_pages(struct inode *inode, long offset, long free=
d);
> +long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
> +						long freed);
>  int dequeue_hwpoisoned_huge_page(struct page *page);
>  bool isolate_huge_page(struct page *page, struct list_head *list);
>  void putback_active_hugepage(struct page *page);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index df0d32a..0cf0622 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3628,21 +3628,32 @@ out_err:
>  	return ret;
>  }
> =20
> -void hugetlb_unreserve_pages(struct inode *inode, long offset, long free=
d)
> +long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
> +								long freed)
>  {
>  	struct hstate *h =3D hstate_inode(inode);
>  	struct resv_map *resv_map =3D inode_resv_map(inode);
>  	long chg =3D 0;
>  	struct hugepage_subpool *spool =3D subpool_inode(inode);
> =20
> -	if (resv_map)
> -		chg =3D region_del(resv_map, offset, -1);
> +	if (resv_map) {
> +		chg =3D region_del(resv_map, start, end);
> +		/*
> +		 * region_del() can fail in the rare case where a region
> +		 * must be split and another region descriptor can not be
> +		 * allocated.  If end =3D=3D -1, it will not fail.
> +		 */
> +		if (chg < 0)
> +			return chg;
> +	}
>  	spin_lock(&inode->i_lock);
>  	inode->i_blocks -=3D (blocks_per_huge_page(h) * freed);
>  	spin_unlock(&inode->i_lock);
> =20
>  	hugepage_subpool_put_pages(spool, (chg - freed));
>  	hugetlb_acct_memory(h, -(chg - freed));
> +
> +	return 0;
>  }
> =20
>  #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
> --=20
> 2.1.0
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
