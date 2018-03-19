Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id B192A6B0008
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:06:14 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id e205so8514523qkb.8
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 16:06:14 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id e131si1203156qkb.302.2018.03.19.16.06.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 16:06:13 -0700 (PDT)
Subject: Re: [PATCH 09/14] mm/hmm: do not differentiate between empty entry or
 missing directory
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-10-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <680af8e7-0f6d-85cb-f259-8a6a1d1dc9c3@nvidia.com>
Date: Mon, 19 Mar 2018 16:06:11 -0700
MIME-Version: 1.0
In-Reply-To: <20180316191414.3223-10-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/16/2018 12:14 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> There is no point in differentiating between a range for which there
> is not even a directory (and thus entries) and empty entry (pte_none()
> or pmd_none() returns true).
>=20
> Simply drop the distinction ie remove HMM_PFN_EMPTY flag and merge now
> duplicate hmm_vma_walk_hole() and hmm_vma_walk_clear() functions.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/hmm.h |  8 +++-----
>  mm/hmm.c            | 45 +++++++++++++++------------------------------
>  2 files changed, 18 insertions(+), 35 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 78b3ed6d7977..6d2b6bf6da4b 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -84,7 +84,6 @@ struct hmm;
>   * HMM_PFN_VALID: pfn is valid
>   * HMM_PFN_WRITE: CPU page table has write permission set
>   * HMM_PFN_ERROR: corresponding CPU page table entry points to poisoned =
memory
> - * HMM_PFN_EMPTY: corresponding CPU page table entry is pte_none()
>   * HMM_PFN_SPECIAL: corresponding CPU page table entry is special; i.e.,=
 the
>   *      result of vm_insert_pfn() or vm_insert_page(). Therefore, it sho=
uld not
>   *      be mirrored by a device, because the entry will never have HMM_P=
FN_VALID
> @@ -94,10 +93,9 @@ struct hmm;
>  #define HMM_PFN_VALID (1 << 0)
>  #define HMM_PFN_WRITE (1 << 1)
>  #define HMM_PFN_ERROR (1 << 2)
> -#define HMM_PFN_EMPTY (1 << 3)
> -#define HMM_PFN_SPECIAL (1 << 4)
> -#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 5)
> -#define HMM_PFN_SHIFT 6
> +#define HMM_PFN_SPECIAL (1 << 3)
> +#define HMM_PFN_DEVICE_UNADDRESSABLE (1 << 4)
> +#define HMM_PFN_SHIFT 5
> =20
>  /*
>   * hmm_pfn_to_page() - return struct page pointed to by a valid HMM pfn
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 04595a994542..2118e42cb838 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -305,6 +305,16 @@ static void hmm_pfns_clear(uint64_t *pfns,
>  		*pfns =3D 0;
>  }
> =20
> +/*
> + * hmm_vma_walk_hole() - handle a range back by no pmd or no pte


Maybe write it like this:

 * hmm_vma_walk_hole() - handle a range that is not backed by any pmd or pt=
e
=20

> + * @start: range virtual start address (inclusive)
> + * @end: range virtual end address (exclusive)
> + * @walk: mm_walk structure
> + * Returns: 0 on success, -EAGAIN after page fault, or page fault error
> + *
> + * This is an helper call whenever pmd_none() or pte_none() returns true
> + * or when there is no directory covering the range.

Instead of those two lines, how about:

 * This routine will be called whenever pmd_none() or pte_none() returns
 * true, or whenever there is no page directory covering the VA range.


> + */
>  static int hmm_vma_walk_hole(unsigned long addr,
>  			     unsigned long end,
>  			     struct mm_walk *walk)
> @@ -314,31 +324,6 @@ static int hmm_vma_walk_hole(unsigned long addr,
>  	uint64_t *pfns =3D range->pfns;
>  	unsigned long i;
> =20
> -	hmm_vma_walk->last =3D addr;
> -	i =3D (addr - range->start) >> PAGE_SHIFT;
> -	for (; addr < end; addr +=3D PAGE_SIZE, i++) {
> -		pfns[i] =3D HMM_PFN_EMPTY;
> -		if (hmm_vma_walk->fault) {
> -			int ret;
> -
> -			ret =3D hmm_vma_do_fault(walk, addr, &pfns[i]);
> -			if (ret !=3D -EAGAIN)
> -				return ret;
> -		}
> -	}
> -
> -	return hmm_vma_walk->fault ? -EAGAIN : 0;
> -}
> -
> -static int hmm_vma_walk_clear(unsigned long addr,
> -			      unsigned long end,
> -			      struct mm_walk *walk)
> -{
> -	struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
> -	struct hmm_range *range =3D hmm_vma_walk->range;
> -	uint64_t *pfns =3D range->pfns;
> -	unsigned long i;
> -

Nice consolidation!

>  	hmm_vma_walk->last =3D addr;
>  	i =3D (addr - range->start) >> PAGE_SHIFT;
>  	for (; addr < end; addr +=3D PAGE_SIZE, i++) {
> @@ -397,10 +382,10 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  		if (!pmd_devmap(pmd) && !pmd_trans_huge(pmd))
>  			goto again;
>  		if (pmd_protnone(pmd))
> -			return hmm_vma_walk_clear(start, end, walk);
> +			return hmm_vma_walk_hole(start, end, walk);
> =20
>  		if (write_fault && !pmd_write(pmd))
> -			return hmm_vma_walk_clear(start, end, walk);
> +			return hmm_vma_walk_hole(start, end, walk);
> =20
>  		pfn =3D pmd_pfn(pmd) + pte_index(addr);
>  		flag |=3D pmd_write(pmd) ? HMM_PFN_WRITE : 0;
> @@ -419,7 +404,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  		pfns[i] =3D 0;
> =20
>  		if (pte_none(pte)) {
> -			pfns[i] =3D HMM_PFN_EMPTY;
> +			pfns[i] =3D 0;

Why is this being set to zero? (0 =3D=3D HMM_PFN_VALID, btw.)
I would have expected HMM_PFN_NONE. Actually, looking through the=20
larger patchset, I think there are a couple of big questions about
these HMM_PFN_* flags. Maybe it's just that the comment documentation
has fallen completely behind, but it looks like there is an actual
problem in the code:

1. HMM_PFN_* used to be bit shifts, so setting them directly sometimes
worked. But now they are enum values, so that doesn't work anymore.
Yet they are still being set directly in places: the enum is being
treated as a flag, probably incorrectly.

Previously:=20

#define HMM_PFN_VALID (1 << 0)
#define HMM_PFN_WRITE (1 << 1)
#define HMM_PFN_ERROR (1 << 2)
#define HMM_PFN_EMPTY (1 << 3)
...

New:

enum hmm_pfn_flag_e {
	HMM_PFN_VALID =3D 0,
	HMM_PFN_WRITE,
	HMM_PFN_ERROR,
	HMM_PFN_NONE,
...

Yet we still have, for example:

    pfns =3D HMM_PFN_ERROR;

This might be accidentally working, because HMM_PFN_ERROR
has a value of 2, so only one bit is set, but...yikes.

2. The hmm_range.flags variable is a uint64_t* (pointer). And then
the patchset uses the HMM_PFN_* enum to *index* into that as an=20
array. Something is highly suspect here, because...an array that is
indexed by HMM_PFN_* enums? It's certainly not documented that way.

Examples:
    range->flags[HMM_PFN_ERROR]
=20
    range->flags[HMM_PFN_VALID]=20

I'll go through and try to point these out right next to the relevant
parts of the patchset, but because I'm taking a little longer than=20
I'd hoped to review this, I figured it's best to alert you earlier, as
soon as I spot something.

>  			if (hmm_vma_walk->fault)
>  				goto fault;
>  			continue;
> @@ -470,8 +455,8 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
> =20
>  fault:
>  		pte_unmap(ptep);
> -		/* Fault all pages in range */
> -		return hmm_vma_walk_clear(start, end, walk);
> +		/* Fault all pages in range if ask for */

Maybe this, instead (assuming I understand this correctly):

                /*
                 * Fault in each page in the range, if that page was
                 * requested.
                 */

thanks,
--=20
John Hubbard
NVIDIA

> +		return hmm_vma_walk_hole(start, end, walk);
>  	}
>  	pte_unmap(ptep - 1);
> =20
>=20
