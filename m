Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACD076B0003
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 01:07:36 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id h15so2527126qti.22
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 22:07:36 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id p205si594975qke.91.2018.03.20.22.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 22:07:35 -0700 (PDT)
Subject: Re: [PATCH 13/15] mm/hmm: factor out pte and pmd handling to simplify
 hmm_vma_walk_pmd()
References: <20180320020038.3360-1-jglisse@redhat.com>
 <20180320020038.3360-14-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <e0fd4348-8b8c-90b2-a9d8-91a30768fddc@nvidia.com>
Date: Tue, 20 Mar 2018 22:07:29 -0700
MIME-Version: 1.0
In-Reply-To: <20180320020038.3360-14-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/19/2018 07:00 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> No functional change, just create one function to handle pmd and one
> to handle pte (hmm_vma_handle_pmd() and hmm_vma_handle_pte()).
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  mm/hmm.c | 174 +++++++++++++++++++++++++++++++++++++--------------------=
------
>  1 file changed, 102 insertions(+), 72 deletions(-)
>=20
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 52cdceb35733..dc703e9c3a95 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -351,6 +351,99 @@ static int hmm_vma_walk_hole(unsigned long addr,
>  	return hmm_vma_walk->fault ? -EAGAIN : 0;
>  }
> =20
> +static int hmm_vma_handle_pmd(struct mm_walk *walk,
> +			      unsigned long addr,
> +			      unsigned long end,
> +			      uint64_t *pfns,

Hi Jerome,

Nice cleanup, it makes it much easier to follow the code now.

Let's please rename the pfns argument above to "pfn", because in this
helper (and the _pte helper too), there is only one pfn involved, rather
than an array of them.

> +			      pmd_t pmd)
> +{
> +	struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
> +	unsigned long pfn, i;
> +	uint64_t flag =3D 0;
> +
> +	if (pmd_protnone(pmd))
> +		return hmm_vma_walk_hole(addr, end, walk);
> +
> +	if ((hmm_vma_walk->fault & hmm_vma_walk->write) && !pmd_write(pmd))
> +		return hmm_vma_walk_hole(addr, end, walk);
> +
> +	pfn =3D pmd_pfn(pmd) + pte_index(addr);
> +	flag |=3D pmd_write(pmd) ? HMM_PFN_WRITE : 0;
> +	for (i =3D 0; addr < end; addr +=3D PAGE_SIZE, i++, pfn++)
> +		pfns[i] =3D hmm_pfn_from_pfn(pfn) | flag;
> +	hmm_vma_walk->last =3D end;
> +	return 0;
> +}
> +
> +static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
> +			      unsigned long end, pmd_t *pmdp, pte_t *ptep,
> +			      uint64_t *pfns)

Same thing here: rename pfns --> pfn.

I moved diffs around to attempt to confirm that this is just a refactoring,
and it does look the same. It's easy to overlook things here, but:

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

> +{
> +	struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
> +	struct vm_area_struct *vma =3D walk->vma;
> +	pte_t pte =3D *ptep;
> +
> +	*pfns =3D 0;
> +
> +	if (pte_none(pte)) {
> +		*pfns =3D 0;
> +		if (hmm_vma_walk->fault)
> +			goto fault;
> +		return 0;
> +	}
> +
> +	if (!pte_present(pte)) {
> +		swp_entry_t entry =3D pte_to_swp_entry(pte);
> +
> +		if (!non_swap_entry(entry)) {
> +			if (hmm_vma_walk->fault)
> +				goto fault;
> +			return 0;
> +		}
> +
> +		/*
> +		 * This is a special swap entry, ignore migration, use
> +		 * device and report anything else as error.
> +		 */
> +		if (is_device_private_entry(entry)) {
> +			*pfns =3D hmm_pfn_from_pfn(swp_offset(entry));
> +			if (is_write_device_private_entry(entry)) {
> +				*pfns |=3D HMM_PFN_WRITE;
> +			} else if ((hmm_vma_walk->fault & hmm_vma_walk->write))
> +				goto fault;
> +			*pfns |=3D HMM_PFN_DEVICE_PRIVATE;
> +			return 0;
> +		}
> +
> +		if (is_migration_entry(entry)) {
> +			if (hmm_vma_walk->fault) {
> +				pte_unmap(ptep);
> +				hmm_vma_walk->last =3D addr;
> +				migration_entry_wait(vma->vm_mm,
> +						pmdp, addr);
> +				return -EAGAIN;
> +			}
> +			return 0;
> +		}
> +
> +		/* Report error for everything else */
> +		*pfns =3D HMM_PFN_ERROR;
> +		return -EFAULT;
> +	}
> +
> +	if ((hmm_vma_walk->fault & hmm_vma_walk->write) && !pte_write(pte))
> +		goto fault;
> +
> +	*pfns =3D hmm_pfn_from_pfn(pte_pfn(pte));
> +	*pfns |=3D pte_write(pte) ? HMM_PFN_WRITE : 0;
> +	return 0;
> +
> +fault:
> +	pte_unmap(ptep);
> +	/* Fault any virtual address we were ask to fault */
> +	return hmm_vma_walk_hole(addr, end, walk);
> +}
> +
>  static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  			    unsigned long start,
>  			    unsigned long end,
> @@ -358,25 +451,20 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  {
>  	struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
>  	struct hmm_range *range =3D hmm_vma_walk->range;
> -	struct vm_area_struct *vma =3D walk->vma;
>  	uint64_t *pfns =3D range->pfns;
>  	unsigned long addr =3D start, i;
> -	bool write_fault;
>  	pte_t *ptep;
> =20
>  	i =3D (addr - range->start) >> PAGE_SHIFT;
> -	write_fault =3D hmm_vma_walk->fault & hmm_vma_walk->write;
> =20
>  again:
>  	if (pmd_none(*pmdp))
>  		return hmm_vma_walk_hole(start, end, walk);
> =20
> -	if (pmd_huge(*pmdp) && vma->vm_flags & VM_HUGETLB)
> +	if (pmd_huge(*pmdp) && (range->vma->vm_flags & VM_HUGETLB))
>  		return hmm_pfns_bad(start, end, walk);
> =20
>  	if (pmd_devmap(*pmdp) || pmd_trans_huge(*pmdp)) {
> -		unsigned long pfn;
> -		uint64_t flag =3D 0;
>  		pmd_t pmd;
> =20
>  		/*
> @@ -392,17 +480,8 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  		barrier();
>  		if (!pmd_devmap(pmd) && !pmd_trans_huge(pmd))
>  			goto again;
> -		if (pmd_protnone(pmd))
> -			return hmm_vma_walk_hole(start, end, walk);
> =20
> -		if (write_fault && !pmd_write(pmd))
> -			return hmm_vma_walk_hole(start, end, walk);
> -
> -		pfn =3D pmd_pfn(pmd) + pte_index(addr);
> -		flag |=3D pmd_write(pmd) ? HMM_PFN_WRITE : 0;
> -		for (; addr < end; addr +=3D PAGE_SIZE, i++, pfn++)
> -			pfns[i] =3D hmm_pfn_from_pfn(pfn) | flag;
> -		return 0;
> +		return hmm_vma_handle_pmd(walk, addr, end, &pfns[i], pmd);
>  	}
> =20
>  	if (pmd_bad(*pmdp))
> @@ -410,67 +489,18 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
> =20
>  	ptep =3D pte_offset_map(pmdp, addr);
>  	for (; addr < end; addr +=3D PAGE_SIZE, ptep++, i++) {
> -		pte_t pte =3D *ptep;
> +		int r;
> =20
> -		pfns[i] =3D 0;
> -
> -		if (pte_none(pte)) {
> -			pfns[i] =3D 0;
> -			if (hmm_vma_walk->fault)
> -				goto fault;
> -			continue;
> -		}
> -
> -		if (!pte_present(pte)) {
> -			swp_entry_t entry =3D pte_to_swp_entry(pte);
> -
> -			if (!non_swap_entry(entry)) {
> -				if (hmm_vma_walk->fault)
> -					goto fault;
> -				continue;
> -			}
> -
> -			/*
> -			 * This is a special swap entry, ignore migration, use
> -			 * device and report anything else as error.
> -			 */
> -			if (is_device_private_entry(entry)) {
> -				pfns[i] =3D hmm_pfn_from_pfn(swp_offset(entry));
> -				if (is_write_device_private_entry(entry)) {
> -					pfns[i] |=3D HMM_PFN_WRITE;
> -				} else if (write_fault)
> -					goto fault;
> -				pfns[i] |=3D HMM_PFN_DEVICE_PRIVATE;
> -			} else if (is_migration_entry(entry)) {
> -				if (hmm_vma_walk->fault) {
> -					pte_unmap(ptep);
> -					hmm_vma_walk->last =3D addr;
> -					migration_entry_wait(vma->vm_mm,
> -							     pmdp, addr);
> -					return -EAGAIN;
> -				}
> -				continue;
> -			} else {
> -				/* Report error for everything else */
> -				pfns[i] =3D HMM_PFN_ERROR;
> -			}
> -			continue;
> +		r =3D hmm_vma_handle_pte(walk, addr, end, pmdp, ptep, &pfns[i]);
> +		if (r) {
> +			/* hmm_vma_handle_pte() did unmap pte directory */
> +			hmm_vma_walk->last =3D addr;
> +			return r;
>  		}
> -
> -		if (write_fault && !pte_write(pte))
> -			goto fault;
> -
> -		pfns[i] =3D hmm_pfn_from_pfn(pte_pfn(pte));
> -		pfns[i] |=3D pte_write(pte) ? HMM_PFN_WRITE : 0;
> -		continue;
> -
> -fault:
> -		pte_unmap(ptep);
> -		/* Fault any virtual address we were ask to fault */
> -		return hmm_vma_walk_hole(start, end, walk);
>  	}
>  	pte_unmap(ptep - 1);
> =20
> +	hmm_vma_walk->last =3D addr;
>  	return 0;
>  }
> =20
>=20
