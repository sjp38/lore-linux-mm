Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E2BF16B0038
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 05:51:44 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id x12so460112wgg.36
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 02:51:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id he2si1880386wib.94.2014.11.19.02.51.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Nov 2014 02:51:43 -0800 (PST)
Message-ID: <546C761D.6050407@redhat.com>
Date: Wed, 19 Nov 2014 11:51:09 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/19] mm: store mapcount for compound page separate
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com> <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="R8VRbbkpPxWnhP61RVncFILskrLpB81Me"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--R8VRbbkpPxWnhP61RVncFILskrLpB81Me
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 11/05/2014 03:49 PM, Kirill A. Shutemov wrote:
> We're going to allow mapping of individual 4k pages of THP compound and=

> we need a cheap way to find out how many time the compound page is
> mapped with PMD -- compound_mapcount() does this.
>=20
> page_mapcount() counts both: PTE and PMD mappings of the page.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/mm.h   | 17 +++++++++++++++--
>  include/linux/rmap.h |  4 ++--
>  mm/huge_memory.c     | 23 ++++++++++++++---------
>  mm/hugetlb.c         |  4 ++--
>  mm/memory.c          |  2 +-
>  mm/migrate.c         |  2 +-
>  mm/page_alloc.c      | 13 ++++++++++---
>  mm/rmap.c            | 50 +++++++++++++++++++++++++++++++++++++++++++-=
------
>  8 files changed, 88 insertions(+), 27 deletions(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 1825c468f158..aef03acff228 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -435,6 +435,19 @@ static inline struct page *compound_head(struct pa=
ge *page)
>  	return page;
>  }
> =20
> +static inline atomic_t *compound_mapcount_ptr(struct page *page)
> +{
> +	return (atomic_t *)&page[1].mapping;
> +}

IIUC your patch overloads the unused mapping field of the first tail
page to store the PMD mapcount. That's a non obvious trick. Why not make
it more explicit by adding a new field (say compound_mapcount - and the
appropriate comment of course) to the union to which mapping already belo=
ng?
The patch description would benefit from more explanation too.

Jerome

> +
> +static inline int compound_mapcount(struct page *page)
> +{
> +	if (!PageCompound(page))
> +		return 0;
> +	page =3D compound_head(page);
> +	return atomic_read(compound_mapcount_ptr(page)) + 1;
> +}
> +
>  /*
>   * The atomic page->_mapcount, starts from -1: so that transitions
>   * both from it and to it can be tracked, using atomic_inc_and_test
> @@ -447,7 +460,7 @@ static inline void page_mapcount_reset(struct page =
*page)
> =20
>  static inline int page_mapcount(struct page *page)
>  {
> -	return atomic_read(&(page)->_mapcount) + 1;
> +	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) + 1;=

>  }
> =20
>  static inline int page_count(struct page *page)
> @@ -1017,7 +1030,7 @@ static inline pgoff_t page_file_index(struct page=
 *page)
>   */
>  static inline int page_mapped(struct page *page)
>  {
> -	return atomic_read(&(page)->_mapcount) >=3D 0;
> +	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >=3D=
 0;
>  }
> =20
>  /*
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index ef09ca48c789..a9499ad8c037 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -180,9 +180,9 @@ void hugepage_add_anon_rmap(struct page *, struct v=
m_area_struct *,
>  void hugepage_add_new_anon_rmap(struct page *, struct vm_area_struct *=
,
>  				unsigned long);
> =20
> -static inline void page_dup_rmap(struct page *page)
> +static inline void page_dup_rmap(struct page *page, bool compound)
>  {
> -	atomic_inc(&page->_mapcount);
> +	atomic_inc(compound ? compound_mapcount_ptr(page) : &page->_mapcount)=
;
>  }
> =20
>  /*
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 9c53800c4eea..869f9bcf481e 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -904,7 +904,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct =
mm_struct *src_mm,
>  	src_page =3D pmd_page(pmd);
>  	VM_BUG_ON_PAGE(!PageHead(src_page), src_page);
>  	get_page(src_page);
> -	page_dup_rmap(src_page);
> +	page_dup_rmap(src_page, true);
>  	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
> =20
>  	pmdp_set_wrprotect(src_mm, addr, src_pmd);
> @@ -1763,8 +1763,8 @@ static void __split_huge_page_refcount(struct pag=
e *page,
>  		struct page *page_tail =3D page + i;
> =20
>  		/* tail_page->_mapcount cannot change */
> -		BUG_ON(page_mapcount(page_tail) < 0);
> -		tail_count +=3D page_mapcount(page_tail);
> +		BUG_ON(atomic_read(&page_tail->_mapcount) + 1 < 0);
> +		tail_count +=3D atomic_read(&page_tail->_mapcount) + 1;
>  		/* check for overflow */
>  		BUG_ON(tail_count < 0);
>  		BUG_ON(atomic_read(&page_tail->_count) !=3D 0);
> @@ -1781,8 +1781,7 @@ static void __split_huge_page_refcount(struct pag=
e *page,
>  		 * atomic_set() here would be safe on all archs (and
>  		 * not only on x86), it's safer to use atomic_add().
>  		 */
> -		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
> -			   &page_tail->_count);
> +		atomic_add(page_mapcount(page_tail) + 1, &page_tail->_count);
> =20
>  		/* after clearing PageTail the gup refcount can be released */
>  		smp_mb__after_atomic();
> @@ -1819,15 +1818,18 @@ static void __split_huge_page_refcount(struct p=
age *page,
>  		 * status is achieved setting a reserved bit in the
>  		 * pmd, not by clearing the present bit.
>  		*/
> -		page_tail->_mapcount =3D page->_mapcount;
> +		atomic_set(&page_tail->_mapcount, compound_mapcount(page) - 1);
> =20
> -		BUG_ON(page_tail->mapping);
> -		page_tail->mapping =3D page->mapping;
> +		/* ->mapping in first tail page is compound_mapcount */
> +		if (i !=3D 1) {
> +			BUG_ON(page_tail->mapping);
> +			page_tail->mapping =3D page->mapping;
> +			BUG_ON(!PageAnon(page_tail));
> +		}
> =20
>  		page_tail->index =3D page->index + i;
>  		page_cpupid_xchg_last(page_tail, page_cpupid_last(page));
> =20
> -		BUG_ON(!PageAnon(page_tail));
>  		BUG_ON(!PageUptodate(page_tail));
>  		BUG_ON(!PageDirty(page_tail));
>  		BUG_ON(!PageSwapBacked(page_tail));
> @@ -1837,6 +1839,9 @@ static void __split_huge_page_refcount(struct pag=
e *page,
>  	atomic_sub(tail_count, &page->_count);
>  	BUG_ON(atomic_read(&page->_count) <=3D 0);
> =20
> +	page->_mapcount =3D *compound_mapcount_ptr(page);
> +	page[1].mapping =3D page->mapping;
> +
>  	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
> =20
>  	ClearPageCompound(page);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index dad8e0732922..445db64a8b08 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2603,7 +2603,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst=
, struct mm_struct *src,
>  			entry =3D huge_ptep_get(src_pte);
>  			ptepage =3D pte_page(entry);
>  			get_page(ptepage);
> -			page_dup_rmap(ptepage);
> +			page_dup_rmap(ptepage, true);
>  			set_huge_pte_at(dst, addr, dst_pte, entry);
>  		}
>  		spin_unlock(src_ptl);
> @@ -3058,7 +3058,7 @@ retry:
>  		ClearPagePrivate(page);
>  		hugepage_add_new_anon_rmap(page, vma, address);
>  	} else
> -		page_dup_rmap(page);
> +		page_dup_rmap(page, true);
>  	new_pte =3D make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
>  				&& (vma->vm_flags & VM_SHARED)));
>  	set_huge_pte_at(mm, address, ptep, new_pte);
> diff --git a/mm/memory.c b/mm/memory.c
> index 6f84c8a51cc0..1b17a72dc93f 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -872,7 +872,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_st=
ruct *src_mm,
>  	page =3D vm_normal_page(vma, addr, pte);
>  	if (page) {
>  		get_page(page);
> -		page_dup_rmap(page);
> +		page_dup_rmap(page, false);
>  		if (PageAnon(page))
>  			rss[MM_ANONPAGES]++;
>  		else
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 6b9413df1661..f1a12ced2531 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -161,7 +161,7 @@ static int remove_migration_pte(struct page *new, s=
truct vm_area_struct *vma,
>  		if (PageAnon(new))
>  			hugepage_add_anon_rmap(new, vma, addr);
>  		else
> -			page_dup_rmap(new);
> +			page_dup_rmap(new, false);
>  	} else if (PageAnon(new))
>  		page_add_anon_rmap(new, vma, addr, false);
>  	else
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d0e3d2fee585..b19d1e69ca12 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -369,6 +369,7 @@ void prep_compound_page(struct page *page, unsigned=
 long order)
> =20
>  	set_compound_page_dtor(page, free_compound_page);
>  	set_compound_order(page, order);
> +	atomic_set(compound_mapcount_ptr(page), -1);
>  	__SetPageHead(page);
>  	for (i =3D 1; i < nr_pages; i++) {
>  		struct page *p =3D page + i;
> @@ -643,7 +644,9 @@ static inline int free_pages_check(struct page *pag=
e)
> =20
>  	if (unlikely(page_mapcount(page)))
>  		bad_reason =3D "nonzero mapcount";
> -	if (unlikely(page->mapping !=3D NULL))
> +	if (unlikely(compound_mapcount(page)))
> +		bad_reason =3D "nonzero compound_mapcount";
> +	if (unlikely(page->mapping !=3D NULL) && !PageTail(page))
>  		bad_reason =3D "non-NULL mapping";
>  	if (unlikely(atomic_read(&page->_count) !=3D 0))
>  		bad_reason =3D "nonzero _count";
> @@ -760,6 +763,8 @@ static bool free_pages_prepare(struct page *page, u=
nsigned int order)
>  		bad +=3D free_pages_check(page + i);
>  	if (bad)
>  		return false;
> +	if (order)
> +		page[1].mapping =3D NULL;
> =20
>  	if (!PageHighMem(page)) {
>  		debug_check_no_locks_freed(page_address(page),
> @@ -6632,10 +6637,12 @@ static void dump_page_flags(unsigned long flags=
)
>  void dump_page_badflags(struct page *page, const char *reason,
>  		unsigned long badflags)
>  {
> -	printk(KERN_ALERT
> -	       "page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
> +	pr_alert("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
>  		page, atomic_read(&page->_count), page_mapcount(page),
>  		page->mapping, page->index);
> +	if (PageCompound(page))
> +		printk(" compound_mapcount: %d", compound_mapcount(page));
> +	printk("\n");
>  	dump_page_flags(page->flags);
>  	if (reason)
>  		pr_alert("page dumped because: %s\n", reason);
> diff --git a/mm/rmap.c b/mm/rmap.c
> index f706a6af1801..eecc9301847d 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -986,9 +986,30 @@ void page_add_anon_rmap(struct page *page,
>  void do_page_add_anon_rmap(struct page *page,
>  	struct vm_area_struct *vma, unsigned long address, int flags)
>  {
> -	int first =3D atomic_inc_and_test(&page->_mapcount);
> +	bool compound =3D flags & RMAP_COMPOUND;
> +	bool first;
> +
> +	VM_BUG_ON_PAGE(!PageLocked(compound_head(page)), page);
> +
> +	if (PageTransCompound(page)) {
> +		struct page *head_page =3D compound_head(page);
> +
> +		if (compound) {
> +			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> +			first =3D atomic_inc_and_test(compound_mapcount_ptr(page));
> +		} else {
> +			/* Anon THP always mapped first with PMD */
> +			first =3D 0;
> +			VM_BUG_ON_PAGE(!compound_mapcount(head_page),
> +					head_page);
> +			atomic_inc(&page->_mapcount);
> +		}
> +	} else {
> +		VM_BUG_ON_PAGE(compound, page);
> +		first =3D atomic_inc_and_test(&page->_mapcount);
> +	}
> +
>  	if (first) {
> -		bool compound =3D flags & RMAP_COMPOUND;
>  		int nr =3D compound ? hpage_nr_pages(page) : 1;
>  		/*
>  		 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
> @@ -1006,7 +1027,6 @@ void do_page_add_anon_rmap(struct page *page,
>  	if (unlikely(PageKsm(page)))
>  		return;
> =20
> -	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	/* address might be in next vma when migration races vma_adjust */
>  	if (first)
>  		__page_set_anon_rmap(page, vma, address,
> @@ -1032,10 +1052,19 @@ void page_add_new_anon_rmap(struct page *page,
> =20
>  	VM_BUG_ON(address < vma->vm_start || address >=3D vma->vm_end);
>  	SetPageSwapBacked(page);
> -	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */=

>  	if (compound) {
> +		atomic_t *compound_mapcount;
> +
>  		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> +		compound_mapcount =3D (atomic_t *)&page[1].mapping;
> +		/* increment count (starts at -1) */
> +		atomic_set(compound_mapcount, 0);
>  		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
> +	} else {
> +		/* Anon THP always mapped first with PMD */
> +		VM_BUG_ON_PAGE(PageTransCompound(page), page);
> +		/* increment count (starts at -1) */
> +		atomic_set(&page->_mapcount, 0);
>  	}
>  	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
>  	__page_set_anon_rmap(page, vma, address, 1);
> @@ -1081,7 +1110,9 @@ void page_remove_rmap(struct page *page, bool com=
pound)
>  		mem_cgroup_begin_update_page_stat(page, &locked, &flags);
> =20
>  	/* page still mapped by someone else? */
> -	if (!atomic_add_negative(-1, &page->_mapcount))
> +	if (!atomic_add_negative(-1, compound ?
> +				compound_mapcount_ptr(page) :
> +				&page->_mapcount))
>  		goto out;
> =20
>  	/*
> @@ -1098,9 +1129,14 @@ void page_remove_rmap(struct page *page, bool co=
mpound)
>  	if (anon) {
>  		int nr =3D compound ? hpage_nr_pages(page) : 1;
>  		if (compound) {
> +			int i;
>  			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
>  			__dec_zone_page_state(page,
>  					NR_ANON_TRANSPARENT_HUGEPAGES);
> +			/* The page can be mapped with ptes */
> +			for (i =3D 0; i < HPAGE_PMD_NR; i++)
> +				if (page_mapcount(page + i))
> +					nr--;
>  		}
>  		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
>  	} else {
> @@ -1749,7 +1785,7 @@ void hugepage_add_anon_rmap(struct page *page,
>  	BUG_ON(!PageLocked(page));
>  	BUG_ON(!anon_vma);
>  	/* address might be in next vma when migration races vma_adjust */
> -	first =3D atomic_inc_and_test(&page->_mapcount);
> +	first =3D atomic_inc_and_test(compound_mapcount_ptr(page));
>  	if (first)
>  		__hugepage_set_anon_rmap(page, vma, address, 0);
>  }
> @@ -1758,7 +1794,7 @@ void hugepage_add_new_anon_rmap(struct page *page=
,
>  			struct vm_area_struct *vma, unsigned long address)
>  {
>  	BUG_ON(address < vma->vm_start || address >=3D vma->vm_end);
> -	atomic_set(&page->_mapcount, 0);
> +	atomic_set(compound_mapcount_ptr(page), 0);
>  	__hugepage_set_anon_rmap(page, vma, address, 1);
>  }
>  #endif /* CONFIG_HUGETLB_PAGE */
>=20



--R8VRbbkpPxWnhP61RVncFILskrLpB81Me
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUbHYdAAoJEHTzHJCtsuoCEdMH/1hnEGmXawsc8W+FpC75LPcT
xtbtCaVkbxpifTg3AZlLvXavXvyl8w3xUBbEThHRtT76chPEfOPYIqQQh6wThPPJ
oZZFG4fGSnj8uDvzFK/wLVezol3Vy7o0rhckL9tcfi9MHdmkp/pGocqEKenJ8/I4
r4ECwgItEaiicB8crj/7VNoleGdDB+TRo+TxrlULxec67NMOdtV54vpwymLrmnZY
w6RxJeYh18a7o/3OAEkz3OMbfw6YBslcvXi2tE0Axinvgeh88Fvr1cVWPMOxtKMA
SmBl/AvUP6ELBuDH6iMr1TS3oD+o6C96xMaRw48lQsHkfAzZCCsVoKk6sK6Erag=
=axmb
-----END PGP SIGNATURE-----

--R8VRbbkpPxWnhP61RVncFILskrLpB81Me--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
