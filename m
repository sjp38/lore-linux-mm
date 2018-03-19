Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 252BF6B0008
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 19:20:37 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id x188so12799979qkc.12
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 16:20:37 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id u41si375444qtk.403.2018.03.19.16.20.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 16:20:36 -0700 (PDT)
Subject: Re: [PATCH 14/14] mm/hmm: use device driver encoding for HMM pfn
References: <20180316203552.4155-1-jglisse@redhat.com>
 <20180316203552.4155-5-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f1aed979-3498-f060-cfe6-31732e08c041@nvidia.com>
Date: Mon, 19 Mar 2018 16:20:34 -0700
MIME-Version: 1.0
In-Reply-To: <20180316203552.4155-5-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/16/2018 01:35 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> User of hmm_vma_fault() and hmm_vma_get_pfns() provide a flags array
> and pfn shift value allowing them to define their own encoding for HMM
> pfn that are fill inside the pfns array of the hmm_range struct. With
> this device driver can get pfn that match their own private encoding
> out of HMM without having to do any convertion.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/hmm.h | 91 ++++++++++++++++++++++++++++++++---------------=
------
>  mm/hmm.c            | 83 +++++++++++++++++++++++++++--------------------=
-
>  2 files changed, 102 insertions(+), 72 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index ee758c4e4bec..cb9af99f9371 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -80,68 +80,106 @@
>  struct hmm;
> =20
>  /*
> + * hmm_pfn_flag_e - HMM uses its own pfn type to keep several flags per =
page

OK, so here's the patch that switches over from bits to enum-based flags. B=
ut it is
still mysterious to me.

Maybe this is the place to write some details about how this array of flags=
 actually
works. At first reading it is deeply confusing.

p.s. I still need to review the large patches: #11-13. I should get to thos=
e tomorrow=20
morning.=20

thanks,
--=20
John Hubbard
NVIDIA

> + *
>   * Flags:
>   * HMM_PFN_VALID: pfn is valid
>   * HMM_PFN_WRITE: CPU page table has write permission set
>   * HMM_PFN_ERROR: corresponding CPU page table entry points to poisoned =
memory
> + * HMM_PFN_EMPTY: corresponding CPU page table entry is pte_none()
>   * HMM_PFN_SPECIAL: corresponding CPU page table entry is special; i.e.,=
 the
>   *      result of vm_insert_pfn() or vm_insert_page(). Therefore, it sho=
uld not
>   *      be mirrored by a device, because the entry will never have HMM_P=
FN_VALID
>   *      set and the pfn value is undefined.
> - * HMM_PFN_DEVICE_PRIVATE: unaddressable device memory (ZONE_DEVICE)
> + * HMM_PFN_DEVICE_PRIVATE: private device memory (ZONE_DEVICE)
> + */
> +enum hmm_pfn_flag_e {
> +	HMM_PFN_VALID =3D 0,
> +	HMM_PFN_WRITE,
> +	HMM_PFN_ERROR,
> +	HMM_PFN_NONE,
> +	HMM_PFN_SPECIAL,
> +	HMM_PFN_DEVICE_PRIVATE,
> +	HMM_PFN_FLAG_MAX
> +};
> +
> +/*
> + * struct hmm_range - track invalidation lock on virtual address range
> + *
> + * @vma: the vm area struct for the range
> + * @list: all range lock are on a list
> + * @start: range virtual start address (inclusive)
> + * @end: range virtual end address (exclusive)
> + * @pfns: array of pfns (big enough for the range)
> + * @flags: pfn flags to match device driver page table
> + * @pfn_shifts: pfn shift value (should be <=3D PAGE_SHIFT)
> + * @valid: pfns array did not change since it has been fill by an HMM fu=
nction
>   */
> -#define HMM_PFN_VALID (1 << 0)
> -#define HMM_PFN_WRITE (1 << 1)
> -#define HMM_PFN_ERROR (1 << 2)
> -#define HMM_PFN_SPECIAL (1 << 3)
> -#define HMM_PFN_DEVICE_PRIVATE (1 << 4)
> -#define HMM_PFN_SHIFT 5
> +struct hmm_range {
> +	struct vm_area_struct	*vma;
> +	struct list_head	list;
> +	unsigned long		start;
> +	unsigned long		end;
> +	uint64_t		*pfns;
> +	const uint64_t		*flags;
> +	uint8_t			pfn_shift;
> +	bool			valid;
> +};
> =20
>  /*
>   * hmm_pfn_to_page() - return struct page pointed to by a valid HMM pfn
> + * @range: range use to decode HMM pfn value
>   * @pfn: HMM pfn value to get corresponding struct page from
>   * Returns: struct page pointer if pfn is a valid HMM pfn, NULL otherwis=
e
>   *
>   * If the uint64_t is valid (ie valid flag set) then return the struct p=
age
>   * matching the pfn value stored in the HMM pfn. Otherwise return NULL.
>   */
> -static inline struct page *hmm_pfn_to_page(uint64_t pfn)
> +static inline struct page *hmm_pfn_to_page(const struct hmm_range *range=
,
> +					   uint64_t pfn)
>  {
> -	if (!(pfn & HMM_PFN_VALID))
> +	if (!(pfn & range->flags[HMM_PFN_VALID]))
>  		return NULL;
> -	return pfn_to_page(pfn >> HMM_PFN_SHIFT);
> +	return pfn_to_page(pfn >> range->pfn_shift);
>  }
> =20
>  /*
>   * hmm_pfn_to_pfn() - return pfn value store in a HMM pfn
> + * @range: range use to decode HMM pfn value
>   * @pfn: HMM pfn value to extract pfn from
>   * Returns: pfn value if HMM pfn is valid, -1UL otherwise
>   */
> -static inline unsigned long hmm_pfn_to_pfn(uint64_t pfn)
> +static inline unsigned long hmm_pfn_to_pfn(const struct hmm_range *range=
,
> +					   uint64_t pfn)
>  {
> -	if (!(pfn & HMM_PFN_VALID))
> +	if (!(pfn & range->flags[HMM_PFN_VALID]))
>  		return -1UL;
> -	return (pfn >> HMM_PFN_SHIFT);
> +	return (pfn >> range->pfn_shift);
>  }
> =20
>  /*
>   * hmm_pfn_from_page() - create a valid HMM pfn value from struct page
> + * @range: range use to encode HMM pfn value
>   * @page: struct page pointer for which to create the HMM pfn
>   * Returns: valid HMM pfn for the page
>   */
> -static inline uint64_t hmm_pfn_from_page(struct page *page)
> +static inline uint64_t hmm_pfn_from_page(const struct hmm_range *range,
> +					 struct page *page)
>  {
> -	return (page_to_pfn(page) << HMM_PFN_SHIFT) | HMM_PFN_VALID;
> +	return (page_to_pfn(page) << range->pfn_shift) |
> +		range->flags[HMM_PFN_VALID];
>  }
> =20
>  /*
>   * hmm_pfn_from_pfn() - create a valid HMM pfn value from pfn
> + * @range: range use to encode HMM pfn value
>   * @pfn: pfn value for which to create the HMM pfn
>   * Returns: valid HMM pfn for the pfn
>   */
> -static inline uint64_t hmm_pfn_from_pfn(unsigned long pfn)
> +static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
> +					unsigned long pfn)
>  {
> -	return (pfn << HMM_PFN_SHIFT) | HMM_PFN_VALID;
> +	return (pfn << range->pfn_shift) | range->flags[HMM_PFN_VALID];
>  }
> =20
> =20
> @@ -263,25 +301,6 @@ int hmm_mirror_register(struct hmm_mirror *mirror, s=
truct mm_struct *mm);
>  void hmm_mirror_unregister(struct hmm_mirror *mirror);
> =20
> =20
> -/*
> - * struct hmm_range - track invalidation lock on virtual address range
> - *
> - * @vma: the vm area struct for the range
> - * @list: all range lock are on a list
> - * @start: range virtual start address (inclusive)
> - * @end: range virtual end address (exclusive)
> - * @pfns: array of pfns (big enough for the range)
> - * @valid: pfns array did not change since it has been fill by an HMM fu=
nction
> - */
> -struct hmm_range {
> -	struct vm_area_struct	*vma;
> -	struct list_head	list;
> -	unsigned long		start;
> -	unsigned long		end;
> -	uint64_t		*pfns;
> -	bool			valid;
> -};
> -
>  /*
>   * To snapshot the CPU page table, call hmm_vma_get_pfns(), then take a =
device
>   * driver lock that serializes device page table updates, then call
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 0ea530d0fd1d..7ccca5478ea1 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -263,6 +263,7 @@ static int hmm_vma_do_fault(struct mm_walk *walk, uns=
igned long addr,
>  {
>  	unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REMOTE;
>  	struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
> +	struct hmm_range *range =3D hmm_vma_walk->range;
>  	struct vm_area_struct *vma =3D walk->vma;
>  	int r;
> =20
> @@ -272,7 +273,7 @@ static int hmm_vma_do_fault(struct mm_walk *walk, uns=
igned long addr,
>  	if (r & VM_FAULT_RETRY)
>  		return -EBUSY;
>  	if (r & VM_FAULT_ERROR) {
> -		*pfn =3D HMM_PFN_ERROR;
> +		*pfn =3D range->flags[HMM_PFN_ERROR];
>  		return -EFAULT;
>  	}
> =20
> @@ -290,7 +291,7 @@ static int hmm_pfns_bad(unsigned long addr,
> =20
>  	i =3D (addr - range->start) >> PAGE_SHIFT;
>  	for (; addr < end; addr +=3D PAGE_SIZE, i++)
> -		pfns[i] =3D HMM_PFN_ERROR;
> +		pfns[i] =3D range->flags[HMM_PFN_ERROR];
> =20
>  	return 0;
>  }
> @@ -319,7 +320,7 @@ static int hmm_vma_walk_hole_(unsigned long addr, uns=
igned long end,
>  	hmm_vma_walk->last =3D addr;
>  	i =3D (addr - range->start) >> PAGE_SHIFT;
>  	for (; addr < end; addr +=3D PAGE_SIZE, i++) {
> -		pfns[i] =3D 0;
> +		pfns[i] =3D range->flags[HMM_PFN_NONE];
>  		if (fault || write_fault) {
>  			int ret;
> =20
> @@ -337,24 +338,27 @@ static inline void hmm_pte_need_fault(const struct =
hmm_vma_walk *hmm_vma_walk,
>  				      uint64_t pfns, uint64_t cpu_flags,
>  				      bool *fault, bool *write_fault)
>  {
> +	struct hmm_range *range =3D hmm_vma_walk->range;
> +
>  	*fault =3D *write_fault =3D false;
>  	if (!hmm_vma_walk->fault)
>  		return;
> =20
>  	/* We aren't ask to do anything ... */
> -	if (!(pfns & HMM_PFN_VALID))
> +	if (!(pfns & range->flags[HMM_PFN_VALID]))
>  		return;
>  	/* If CPU page table is not valid then we need to fault */
> -	*fault =3D cpu_flags & HMM_PFN_VALID;
> +	*fault =3D cpu_flags & range->flags[HMM_PFN_VALID];
>  	/* Need to write fault ? */
> -	if ((pfns & HMM_PFN_WRITE) && !(cpu_flags & HMM_PFN_WRITE)) {
> +	if ((pfns & range->flags[HMM_PFN_WRITE]) &&
> +	    !(cpu_flags & range->flags[HMM_PFN_WRITE])) {
>  		*fault =3D *write_fault =3D false;
>  		return;
>  	}
>  	/* Do we fault on device memory ? */
> -	if ((pfns & HMM_PFN_DEVICE_PRIVATE) &&
> -	    (cpu_flags & HMM_PFN_DEVICE_PRIVATE)) {
> -		*write_fault =3D pfns & HMM_PFN_WRITE;
> +	if ((pfns & range->flags[HMM_PFN_DEVICE_PRIVATE]) &&
> +	    (cpu_flags & range->flags[HMM_PFN_DEVICE_PRIVATE])) {
> +		*write_fault =3D pfns & range->flags[HMM_PFN_WRITE];
>  		*fault =3D true;
>  	}
>  }
> @@ -396,13 +400,13 @@ static int hmm_vma_walk_hole(unsigned long addr, un=
signed long end,
>  	return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
>  }
> =20
> -static inline uint64_t pmd_to_hmm_pfn_flags(pmd_t pmd)
> +static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd=
_t pmd)
>  {
>  	if (pmd_protnone(pmd))
>  		return 0;
> -	return pmd_write(pmd) ? HMM_PFN_VALID |
> -				HMM_PFN_WRITE :
> -				HMM_PFN_VALID;
> +	return pmd_write(pmd) ? range->flags[HMM_PFN_VALID] |
> +				range->flags[HMM_PFN_WRITE] :
> +				range->flags[HMM_PFN_VALID];
>  }
> =20
>  static int hmm_vma_handle_pmd(struct mm_walk *walk,
> @@ -412,12 +416,13 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
>  			      pmd_t pmd)
>  {
>  	struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
> +	struct hmm_range *range =3D hmm_vma_walk->range;
>  	unsigned long pfn, npages, i;
> -	uint64_t flag =3D 0, cpu_flags;
>  	bool fault, write_fault;
> +	uint64_t cpu_flags;
> =20
>  	npages =3D (end - addr) >> PAGE_SHIFT;
> -	cpu_flags =3D pmd_to_hmm_pfn_flags(pmd);
> +	cpu_flags =3D pmd_to_hmm_pfn_flags(range, pmd);
>  	hmm_range_need_fault(hmm_vma_walk, pfns, npages, cpu_flags,
>  			     &fault, &write_fault);
> =20
> @@ -425,20 +430,19 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
>  		return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
> =20
>  	pfn =3D pmd_pfn(pmd) + pte_index(addr);
> -	flag |=3D pmd_write(pmd) ? HMM_PFN_WRITE : 0;
>  	for (i =3D 0; addr < end; addr +=3D PAGE_SIZE, i++, pfn++)
> -		pfns[i] =3D hmm_pfn_from_pfn(pfn) | flag;
> +		pfns[i] =3D hmm_pfn_from_pfn(range, pfn) | cpu_flags;
>  	hmm_vma_walk->last =3D end;
>  	return 0;
>  }
> =20
> -static inline uint64_t pte_to_hmm_pfn_flags(pte_t pte)
> +static inline uint64_t pte_to_hmm_pfn_flags(struct hmm_range *range, pte=
_t pte)
>  {
>  	if (pte_none(pte) || !pte_present(pte))
>  		return 0;
> -	return pte_write(pte) ? HMM_PFN_VALID |
> -				HMM_PFN_WRITE :
> -				HMM_PFN_VALID;
> +	return pte_write(pte) ? range->flags[HMM_PFN_VALID] |
> +				range->flags[HMM_PFN_WRITE] :
> +				range->flags[HMM_PFN_VALID];
>  }
> =20
>  static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
> @@ -446,18 +450,18 @@ static int hmm_vma_handle_pte(struct mm_walk *walk,=
 unsigned long addr,
>  			      uint64_t *pfns)
>  {
>  	struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
> +	struct hmm_range *range =3D hmm_vma_walk->range;
>  	struct vm_area_struct *vma =3D walk->vma;
>  	bool fault, write_fault;
>  	uint64_t cpu_flags;
>  	pte_t pte =3D *ptep;
> =20
> -	*pfns =3D 0;
> -	cpu_flags =3D pte_to_hmm_pfn_flags(pte);
> +	*pfns =3D range->flags[HMM_PFN_NONE];
> +	cpu_flags =3D pte_to_hmm_pfn_flags(range, pte);
>  	hmm_pte_need_fault(hmm_vma_walk, *pfns, cpu_flags,
>  			   &fault, &write_fault);
> =20
>  	if (pte_none(pte)) {
> -		*pfns =3D 0;
>  		if (fault || write_fault)
>  			goto fault;
>  		return 0;
> @@ -477,11 +481,16 @@ static int hmm_vma_handle_pte(struct mm_walk *walk,=
 unsigned long addr,
>  		 * device and report anything else as error.
>  		 */
>  		if (is_device_private_entry(entry)) {
> -			cpu_flags =3D HMM_PFN_VALID | HMM_PFN_DEVICE_PRIVATE;
> +			cpu_flags =3D range->flags[HMM_PFN_VALID] |
> +				    range->flags[HMM_PFN_DEVICE_PRIVATE];
>  			cpu_flags |=3D is_write_device_private_entry(entry) ?
> -					HMM_PFN_WRITE : 0;
> -			*pfns =3D hmm_pfn_from_pfn(swp_offset(entry));
> -			*pfns |=3D HMM_PFN_DEVICE_PRIVATE;
> +					range->flags[HMM_PFN_WRITE] : 0;
> +			hmm_pte_need_fault(hmm_vma_walk, *pfns, cpu_flags,
> +					   &fault, &write_fault);
> +			if (fault || write_fault)
> +				goto fault;
> +			*pfns =3D hmm_pfn_from_pfn(range, swp_offset(entry));
> +			*pfns |=3D cpu_flags;
>  			return 0;
>  		}
> =20
> @@ -504,7 +513,7 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, u=
nsigned long addr,
>  	if (fault || write_fault)
>  		goto fault;
> =20
> -	*pfns =3D hmm_pfn_from_pfn(pte_pfn(pte)) | cpu_flags;
> +	*pfns =3D hmm_pfn_from_pfn(range, pte_pfn(pte)) | cpu_flags;
>  	return 0;
> =20
>  fault:
> @@ -573,12 +582,13 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  	return 0;
>  }
> =20
> -static void hmm_pfns_clear(uint64_t *pfns,
> +static void hmm_pfns_clear(struct hmm_range *range,
> +			   uint64_t *pfns,
>  			   unsigned long addr,
>  			   unsigned long end)
>  {
>  	for (; addr < end; addr +=3D PAGE_SIZE, pfns++)
> -		*pfns =3D 0;
> +		*pfns =3D range->flags[HMM_PFN_NONE];
>  }
> =20
>  static void hmm_pfns_special(struct hmm_range *range)
> @@ -586,7 +596,7 @@ static void hmm_pfns_special(struct hmm_range *range)
>  	unsigned long addr =3D range->start, i =3D 0;
> =20
>  	for (; addr < range->end; addr +=3D PAGE_SIZE, i++)
> -		range->pfns[i] =3D HMM_PFN_SPECIAL;
> +		range->pfns[i] =3D range->flags[HMM_PFN_SPECIAL];
>  }
> =20
>  /*
> @@ -644,7 +654,7 @@ int hmm_vma_get_pfns(struct hmm_range *range)
>  		 * is not a case we care about (some operation like atomic no
>  		 * longer make sense).
>  		 */
> -		hmm_pfns_clear(range->pfns, range->start, range->end);
> +		hmm_pfns_clear(range, range->pfns, range->start, range->end);
>  		return 0;
>  	}
> =20
> @@ -788,7 +798,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block=
)
> =20
>  	hmm =3D hmm_register(vma->vm_mm);
>  	if (!hmm) {
> -		hmm_pfns_clear(range->pfns, range->start, range->end);
> +		hmm_pfns_clear(range, range->pfns, range->start, range->end);
>  		return -ENOMEM;
>  	}
>  	/* Caller must have registered a mirror using hmm_mirror_register() */
> @@ -814,7 +824,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block=
)
>  		 * is not a case we care about (some operation like atomic no
>  		 * longer make sense).
>  		 */
> -		hmm_pfns_clear(range->pfns, range->start, range->end);
> +		hmm_pfns_clear(range, range->pfns, range->start, range->end);
>  		return 0;
>  	}
> =20
> @@ -841,7 +851,8 @@ int hmm_vma_fault(struct hmm_range *range, bool block=
)
>  		unsigned long i;
> =20
>  		i =3D (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
> -		hmm_pfns_clear(&range->pfns[i], hmm_vma_walk.last, range->end);
> +		hmm_pfns_clear(range, &range->pfns[i], hmm_vma_walk.last,
> +			       range->end);
>  		hmm_vma_range_done(range);
>  	}
>  	return ret;
>=20
