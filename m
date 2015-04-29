Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6F11B6B006C
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 12:00:51 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so134544963wic.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 09:00:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ab3si463299wid.70.2015.04.29.09.00.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 09:00:49 -0700 (PDT)
Message-ID: <5541001A.9080108@redhat.com>
Date: Wed, 29 Apr 2015 18:00:26 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 09/28] thp: rename split_huge_page_pmd() to split_huge_pmd()
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1429823043-157133-10-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="hdG5ILdUQX24MQIjGXJx3J6NT6NqnStCL"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--hdG5ILdUQX24MQIjGXJx3J6NT6NqnStCL
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> We are going to decouple splitting THP PMD from splitting underlying
> compound page.
>=20
> This patch renames split_huge_page_pmd*() functions to split_huge_pmd*(=
)
> to reflect the fact that it doesn't imply page splitting, only PMD.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Jerome Marchand <jmarchan@redhat.com>

> ---
>  arch/powerpc/mm/subpage-prot.c |  2 +-
>  arch/x86/kernel/vm86_32.c      |  6 +++++-
>  include/linux/huge_mm.h        |  8 ++------
>  mm/gup.c                       |  2 +-
>  mm/huge_memory.c               | 32 +++++++++++---------------------
>  mm/madvise.c                   |  2 +-
>  mm/memory.c                    |  2 +-
>  mm/mempolicy.c                 |  2 +-
>  mm/mprotect.c                  |  2 +-
>  mm/mremap.c                    |  2 +-
>  mm/pagewalk.c                  |  2 +-
>  11 files changed, 26 insertions(+), 36 deletions(-)
>=20
> diff --git a/arch/powerpc/mm/subpage-prot.c b/arch/powerpc/mm/subpage-p=
rot.c
> index fa9fb5b4c66c..d5543514c1df 100644
> --- a/arch/powerpc/mm/subpage-prot.c
> +++ b/arch/powerpc/mm/subpage-prot.c
> @@ -135,7 +135,7 @@ static int subpage_walk_pmd_entry(pmd_t *pmd, unsig=
ned long addr,
>  				  unsigned long end, struct mm_walk *walk)
>  {
>  	struct vm_area_struct *vma =3D walk->vma;
> -	split_huge_page_pmd(vma, addr, pmd);
> +	split_huge_pmd(vma, pmd, addr);
>  	return 0;
>  }
> =20
> diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
> index e8edcf52e069..883160599965 100644
> --- a/arch/x86/kernel/vm86_32.c
> +++ b/arch/x86/kernel/vm86_32.c
> @@ -182,7 +182,11 @@ static void mark_screen_rdonly(struct mm_struct *m=
m)
>  	if (pud_none_or_clear_bad(pud))
>  		goto out;
>  	pmd =3D pmd_offset(pud, 0xA0000);
> -	split_huge_page_pmd_mm(mm, 0xA0000, pmd);
> +
> +	if (pmd_trans_huge(*pmd)) {
> +		struct vm_area_struct *vma =3D find_vma(mm, 0xA0000);
> +		split_huge_pmd(vma, pmd, 0xA0000);
> +	}
>  	if (pmd_none_or_clear_bad(pmd))
>  		goto out;
>  	pte =3D pte_offset_map_lock(mm, pmd, 0xA0000, &ptl);
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 44a840a53974..34bbf769d52e 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -104,7 +104,7 @@ static inline int split_huge_page(struct page *page=
)
>  }
>  extern void __split_huge_page_pmd(struct vm_area_struct *vma,
>  		unsigned long address, pmd_t *pmd);
> -#define split_huge_page_pmd(__vma, __address, __pmd)			\
> +#define split_huge_pmd(__vma, __pmd, __address)				\
>  	do {								\
>  		pmd_t *____pmd =3D (__pmd);				\
>  		if (unlikely(pmd_trans_huge(*____pmd)))			\
> @@ -119,8 +119,6 @@ extern void __split_huge_page_pmd(struct vm_area_st=
ruct *vma,
>  		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
>  		       pmd_trans_huge(*____pmd));			\
>  	} while (0)
> -extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long=
 address,
> -		pmd_t *pmd);
>  #if HPAGE_PMD_ORDER >=3D MAX_ORDER
>  #error "hugepages can't be allocated by the buddy allocator"
>  #endif
> @@ -187,11 +185,9 @@ static inline int split_huge_page(struct page *pag=
e)
>  {
>  	return 0;
>  }
> -#define split_huge_page_pmd(__vma, __address, __pmd)	\
> -	do { } while (0)
>  #define wait_split_huge_page(__anon_vma, __pmd)	\
>  	do { } while (0)
> -#define split_huge_page_pmd_mm(__mm, __address, __pmd)	\
> +#define split_huge_pmd(__vma, __pmd, __address)	\
>  	do { } while (0)
>  static inline int hugepage_madvise(struct vm_area_struct *vma,
>  				   unsigned long *vm_flags, int advice)
> diff --git a/mm/gup.c b/mm/gup.c
> index 7334eb24f414..19e01f156abb 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -220,7 +220,7 @@ struct page *follow_page_mask(struct vm_area_struct=
 *vma,
>  		if (is_huge_zero_page(page)) {
>  			spin_unlock(ptl);
>  			ret =3D 0;
> -			split_huge_page_pmd(vma, address, pmd);
> +			split_huge_pmd(vma, pmd, address);
>  		} else {
>  			get_page(page);
>  			spin_unlock(ptl);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index ffc30e4462c1..ccbfacf07160 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1136,13 +1136,13 @@ alloc:
> =20
>  	if (unlikely(!new_page)) {
>  		if (!page) {
> -			split_huge_page_pmd(vma, address, pmd);
> +			split_huge_pmd(vma, pmd, address);
>  			ret |=3D VM_FAULT_FALLBACK;
>  		} else {
>  			ret =3D do_huge_pmd_wp_page_fallback(mm, vma, address,
>  					pmd, orig_pmd, page, haddr);
>  			if (ret & VM_FAULT_OOM) {
> -				split_huge_page(page);
> +				split_huge_pmd(vma, pmd, address);
>  				ret |=3D VM_FAULT_FALLBACK;
>  			}
>  			put_user_huge_page(page);
> @@ -1155,10 +1155,10 @@ alloc:
>  					&memcg, true))) {
>  		put_page(new_page);
>  		if (page) {
> -			split_huge_page(page);
> +			split_huge_pmd(vma, pmd, address);
>  			put_user_huge_page(page);
>  		} else
> -			split_huge_page_pmd(vma, address, pmd);
> +			split_huge_pmd(vma, pmd, address);
>  		ret |=3D VM_FAULT_FALLBACK;
>  		count_vm_event(THP_FAULT_FALLBACK);
>  		goto out;
> @@ -2985,17 +2985,7 @@ again:
>  		goto again;
>  }
> =20
> -void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long addres=
s,
> -		pmd_t *pmd)
> -{
> -	struct vm_area_struct *vma;
> -
> -	vma =3D find_vma(mm, address);
> -	BUG_ON(vma =3D=3D NULL);
> -	split_huge_page_pmd(vma, address, pmd);
> -}
> -
> -static void split_huge_page_address(struct mm_struct *mm,
> +static void split_huge_pmd_address(struct vm_area_struct *vma,
>  				    unsigned long address)
>  {
>  	pgd_t *pgd;
> @@ -3004,7 +2994,7 @@ static void split_huge_page_address(struct mm_str=
uct *mm,
> =20
>  	VM_BUG_ON(!(address & ~HPAGE_PMD_MASK));
> =20
> -	pgd =3D pgd_offset(mm, address);
> +	pgd =3D pgd_offset(vma->vm_mm, address);
>  	if (!pgd_present(*pgd))
>  		return;
> =20
> @@ -3013,13 +3003,13 @@ static void split_huge_page_address(struct mm_s=
truct *mm,
>  		return;
> =20
>  	pmd =3D pmd_offset(pud, address);
> -	if (!pmd_present(*pmd))
> +	if (!pmd_present(*pmd) || !pmd_trans_huge(*pmd))
>  		return;
>  	/*
>  	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
>  	 * materialize from under us.
>  	 */
> -	split_huge_page_pmd_mm(mm, address, pmd);
> +	__split_huge_page_pmd(vma, address, pmd);
>  }
> =20
>  void __vma_adjust_trans_huge(struct vm_area_struct *vma,
> @@ -3035,7 +3025,7 @@ void __vma_adjust_trans_huge(struct vm_area_struc=
t *vma,
>  	if (start & ~HPAGE_PMD_MASK &&
>  	    (start & HPAGE_PMD_MASK) >=3D vma->vm_start &&
>  	    (start & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <=3D vma->vm_end)
> -		split_huge_page_address(vma->vm_mm, start);
> +		split_huge_pmd_address(vma, start);
> =20
>  	/*
>  	 * If the new end address isn't hpage aligned and it could
> @@ -3045,7 +3035,7 @@ void __vma_adjust_trans_huge(struct vm_area_struc=
t *vma,
>  	if (end & ~HPAGE_PMD_MASK &&
>  	    (end & HPAGE_PMD_MASK) >=3D vma->vm_start &&
>  	    (end & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <=3D vma->vm_end)
> -		split_huge_page_address(vma->vm_mm, end);
> +		split_huge_pmd_address(vma, end);
> =20
>  	/*
>  	 * If we're also updating the vma->vm_next->vm_start, if the new
> @@ -3059,6 +3049,6 @@ void __vma_adjust_trans_huge(struct vm_area_struc=
t *vma,
>  		if (nstart & ~HPAGE_PMD_MASK &&
>  		    (nstart & HPAGE_PMD_MASK) >=3D next->vm_start &&
>  		    (nstart & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <=3D next->vm_end)
> -			split_huge_page_address(next->vm_mm, nstart);
> +			split_huge_pmd_address(next, nstart);
>  	}
>  }
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 22b86daf6b94..f5a81ca0dca7 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -281,7 +281,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsig=
ned long addr,
>  	next =3D pmd_addr_end(addr, end);
>  	if (pmd_trans_huge(*pmd)) {
>  		if (next - addr !=3D HPAGE_PMD_SIZE)
> -			split_huge_page_pmd(vma, addr, pmd);
> +			split_huge_pmd(vma, pmd, addr);
>  		else if (!madvise_free_huge_pmd(tlb, vma, pmd, addr))
>  			goto next;
>  		/* fall through */
> diff --git a/mm/memory.c b/mm/memory.c
> index 8bbd3f88544b..61e7ed722760 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1201,7 +1201,7 @@ static inline unsigned long zap_pmd_range(struct =
mmu_gather *tlb,
>  					BUG();
>  				}
>  #endif
> -				split_huge_page_pmd(vma, addr, pmd);
> +				split_huge_pmd(vma, pmd, addr);
>  			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
>  				goto next;
>  			/* fall through */
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 8badb84c013e..aac490fdc91f 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -493,7 +493,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsign=
ed long addr,
>  	pte_t *pte;
>  	spinlock_t *ptl;
> =20
> -	split_huge_page_pmd(vma, addr, pmd);
> +	split_huge_pmd(vma, pmd, addr);
>  	if (pmd_trans_unstable(pmd))
>  		return 0;
> =20
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 88584838e704..714d2fbbaafd 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -158,7 +158,7 @@ static inline unsigned long change_pmd_range(struct=
 vm_area_struct *vma,
> =20
>  		if (pmd_trans_huge(*pmd)) {
>  			if (next - addr !=3D HPAGE_PMD_SIZE)
> -				split_huge_page_pmd(vma, addr, pmd);
> +				split_huge_pmd(vma, pmd, addr);
>  			else {
>  				int nr_ptes =3D change_huge_pmd(vma, pmd, addr,
>  						newprot, prot_numa);
> diff --git a/mm/mremap.c b/mm/mremap.c
> index afa3ab740d8c..3e40ea27edc4 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -208,7 +208,7 @@ unsigned long move_page_tables(struct vm_area_struc=
t *vma,
>  				need_flush =3D true;
>  				continue;
>  			} else if (!err) {
> -				split_huge_page_pmd(vma, old_addr, old_pmd);
> +				split_huge_pmd(vma, old_pmd, old_addr);
>  			}
>  			VM_BUG_ON(pmd_trans_huge(*old_pmd));
>  		}
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index 29f2f8b853ae..207244489a68 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -58,7 +58,7 @@ again:
>  		if (!walk->pte_entry)
>  			continue;
> =20
> -		split_huge_page_pmd_mm(walk->mm, addr, pmd);
> +		split_huge_pmd(walk->vma, pmd, addr);
>  		if (pmd_trans_unstable(pmd))
>  			goto again;
>  		err =3D walk_pte_range(pmd, addr, next, walk);
>=20



--hdG5ILdUQX24MQIjGXJx3J6NT6NqnStCL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVQQAaAAoJEHTzHJCtsuoCP94H/04YgLIC62C+Sr+ubJiVFdpF
sazu74g7/6ZjfhfhXKQHLB0+Ub0TIeCBFs1WsdWiEIChSvfu53zCgESYd4XLX2ip
+FecxsOOyxJUKsDR9FJ+CkklUtqTRCT04L5q8c2YqQB4H/z/OTd/C9M/4SkaZsIa
7H0Cjl923ZjoDaBbhSrbejLcI7nH4UkLPIXr46mkqsZDgYyPjFSfmrxfmFPIZDfA
y6UL7Sxhp3cQa4kTWn92Ib5F5zpokEdGaNXOiyK7JMZrLgOwSjFj5YE2mQiLlW73
tCILZLvgjQqMckz1P4BHwDU3616xM63fyfT/fJiG9obIp8TXm3BONsN5jnSCcSY=
=RjhT
-----END PGP SIGNATURE-----

--hdG5ILdUQX24MQIjGXJx3J6NT6NqnStCL--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
