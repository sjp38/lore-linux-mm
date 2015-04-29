Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC4E6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 11:58:35 -0400 (EDT)
Received: by wizk4 with SMTP id k4so185959873wiz.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 08:58:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u19si44568623wjq.76.2015.04.29.08.58.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 08:58:33 -0700 (PDT)
Message-ID: <5540FF92.2060706@redhat.com>
Date: Wed, 29 Apr 2015 17:58:10 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 07/28] thp, mlock: do not allow huge pages in mlocked
 area
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-8-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="t5GwGCslIfa7TsR6XBklQBTiWW0fLVSPb"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--t5GwGCslIfa7TsR6XBklQBTiWW0fLVSPb
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> With new refcounting THP can belong to several VMAs. This makes tricky
> to track THP pages, when they partially mlocked. It can lead to leaking=

> mlocked pages to non-VM_LOCKED vmas and other problems.
>=20
> With this patch we will split all pages on mlock and avoid
> fault-in/collapse new THP in VM_LOCKED vmas.
>=20
> I've tried alternative approach: do not mark THP pages mlocked and keep=

> them on normal LRUs. This way vmscan could try to split huge pages on
> memory pressure and free up subpages which doesn't belong to VM_LOCKED
> vmas.  But this is user-visible change: we screw up Mlocked accouting
> reported in meminfo, so I had to leave this approach aside.
>=20
> We can bring something better later, but this should be good enough for=

> now.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  mm/gup.c         |  2 ++
>  mm/huge_memory.c |  5 ++++-
>  mm/memory.c      |  3 ++-
>  mm/mlock.c       | 51 +++++++++++++++++++-----------------------------=
---
>  4 files changed, 27 insertions(+), 34 deletions(-)
>=20
> diff --git a/mm/gup.c b/mm/gup.c
> index eaeeae15006b..7334eb24f414 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -882,6 +882,8 @@ long populate_vma_page_range(struct vm_area_struct =
*vma,
>  	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
> =20
>  	gup_flags =3D FOLL_TOUCH | FOLL_POPULATE;
> +	if (vma->vm_flags & VM_LOCKED)
> +		gup_flags |=3D FOLL_SPLIT;
>  	/*
>  	 * We want to touch writable mappings with a write fault in order
>  	 * to break COW, except for shared mappings because these don't COW
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index fd8af5b9917f..fa3d4f78b716 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -796,6 +796,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm=
, struct vm_area_struct *vma,
> =20
>  	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
>  		return VM_FAULT_FALLBACK;
> +	if (vma->vm_flags & VM_LOCKED)
> +		return VM_FAULT_FALLBACK;
>  	if (unlikely(anon_vma_prepare(vma)))
>  		return VM_FAULT_OOM;
>  	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
> @@ -2467,7 +2469,8 @@ static bool hugepage_vma_check(struct vm_area_str=
uct *vma)
>  	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
>  	    (vma->vm_flags & VM_NOHUGEPAGE))
>  		return false;
> -
> +	if (vma->vm_flags & VM_LOCKED)
> +		return false;
>  	if (!vma->anon_vma || vma->vm_ops)
>  		return false;
>  	if (is_vma_temporary_stack(vma))
> diff --git a/mm/memory.c b/mm/memory.c
> index 559c6651d6b6..8bbd3f88544b 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2156,7 +2156,8 @@ static int wp_page_copy(struct mm_struct *mm, str=
uct vm_area_struct *vma,
> =20
>  	pte_unmap_unlock(page_table, ptl);
>  	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> -	if (old_page) {
> +	/* THP pages are never mlocked */
> +	if (old_page && !PageTransCompound(old_page)) {
>  		/*
>  		 * Don't let another task, with possibly unlocked vma,
>  		 * keep the mlocked page.
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 6fd2cf15e868..76cde3967483 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -443,39 +443,26 @@ void munlock_vma_pages_range(struct vm_area_struc=
t *vma,
>  		page =3D follow_page_mask(vma, start, FOLL_GET | FOLL_DUMP,
>  				&page_mask);
> =20
> -		if (page && !IS_ERR(page)) {
> -			if (PageTransHuge(page)) {
> -				lock_page(page);
> -				/*
> -				 * Any THP page found by follow_page_mask() may
> -				 * have gotten split before reaching
> -				 * munlock_vma_page(), so we need to recompute
> -				 * the page_mask here.
> -				 */
> -				page_mask =3D munlock_vma_page(page);
> -				unlock_page(page);
> -				put_page(page); /* follow_page_mask() */
> -			} else {
> -				/*
> -				 * Non-huge pages are handled in batches via
> -				 * pagevec. The pin from follow_page_mask()
> -				 * prevents them from collapsing by THP.
> -				 */
> -				pagevec_add(&pvec, page);
> -				zone =3D page_zone(page);
> -				zoneid =3D page_zone_id(page);
> +		if (page && !IS_ERR(page) && !PageTransCompound(page)) {
> +			/*
> +			 * Non-huge pages are handled in batches via
> +			 * pagevec. The pin from follow_page_mask()
> +			 * prevents them from collapsing by THP.
> +			 */
> +			pagevec_add(&pvec, page);
> +			zone =3D page_zone(page);
> +			zoneid =3D page_zone_id(page);
> =20
> -				/*
> -				 * Try to fill the rest of pagevec using fast
> -				 * pte walk. This will also update start to
> -				 * the next page to process. Then munlock the
> -				 * pagevec.
> -				 */
> -				start =3D __munlock_pagevec_fill(&pvec, vma,
> -						zoneid, start, end);
> -				__munlock_pagevec(&pvec, zone);
> -				goto next;
> -			}
> +			/*
> +			 * Try to fill the rest of pagevec using fast
> +			 * pte walk. This will also update start to
> +			 * the next page to process. Then munlock the
> +			 * pagevec.
> +			 */
> +			start =3D __munlock_pagevec_fill(&pvec, vma,
> +					zoneid, start, end);
> +			__munlock_pagevec(&pvec, zone);
> +			goto next;
>  		}
>  		/* It's a bug to munlock in the middle of a THP page */
>  		VM_BUG_ON((start >> PAGE_SHIFT) & page_mask);
>=20



--t5GwGCslIfa7TsR6XBklQBTiWW0fLVSPb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVQP+SAAoJEHTzHJCtsuoCZ5gH/3I69ZhWEmlf7V/wTsER5w4q
vSlrxPlV/RNL3mCM1xn7US6p/FyakhPmUcekdKDB2hjHtRFbOsLYrHEPQhv/eDcE
PMx4j4ZZ+8siFfA0ThRqkwerkOp3l90j5Pl53T0sT7G9iap+Gnrsd1b1aIqwXdP5
L8AuuNyS3D/+kw+xlsLun6DdCciZmUTHSQyF5EbsNNJwVk8CwUKSRL1tDQNmtPx9
J72nmCUKKPMRLk27BodT84CXpZxzXy0Rg3hK52a1uSjTOdAFhxnzDYVZDeabISHv
utSgYBfZxw5Bvd+U+pLqHdJuXL7mXR0HaSluFTH4thmV/oh802Zd62DP550f04g=
=Uc/j
-----END PGP SIGNATURE-----

--t5GwGCslIfa7TsR6XBklQBTiWW0fLVSPb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
