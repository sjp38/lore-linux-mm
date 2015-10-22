Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 31B946B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 03:53:16 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so83671950pac.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 00:53:15 -0700 (PDT)
Received: from out11.biz.mail.alibaba.com (out11.biz.mail.alibaba.com. [205.204.114.131])
        by mx.google.com with ESMTP id vw1si19267785pbc.120.2015.10.22.00.53.13
        for <linux-mm@kvack.org>;
        Thu, 22 Oct 2015 00:53:15 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <05ec01d10c9b$4df7ba80$e9e72f80$@alibaba-inc.com>
In-Reply-To: <05ec01d10c9b$4df7ba80$e9e72f80$@alibaba-inc.com>
Subject: Re: [PATCH v11 02/14] HMM: add special swap filetype for memory migrated to device v2.
Date: Thu, 22 Oct 2015 15:52:53 +0800
Message-ID: <05f501d10c9e$a8562900$f9027b00$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?J=C3=A9r=C3=B4me_Glisse?= <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

>=20
> When migrating anonymous memory from system memory to device memory
> CPU pte are replaced with special HMM swap entry so that page fault,
> get user page (gup), fork, ... are properly redirected to HMM helpers.
>=20
> This patch only add the new swap type entry and hooks HMM helpers
> functions inside the page fault and fork code path.
>=20
> Changed since v1:

But the subject line says this work is v11

>   - Fix name when of HMM CPU page fault function.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@...hat.com>
> Signed-off-by: Sherry Cheung <SCheung@...dia.com>
> Signed-off-by: Subhash Gutti <sgutti@...dia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@...dia.com>
> Signed-off-by: John Hubbard <jhubbard@...dia.com>
> Signed-off-by: Jatin Kumar <jakumar@...dia.com>
> ---
>  include/linux/hmm.h     | 34 ++++++++++++++++++++++++++++++++++
>  include/linux/swap.h    | 13 ++++++++++++-
>  include/linux/swapops.h | 43 =
++++++++++++++++++++++++++++++++++++++++++-
>  mm/hmm.c                | 21 +++++++++++++++++++++
>  mm/memory.c             | 22 ++++++++++++++++++++++
>  5 files changed, 131 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 4bc132a..7c66513 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h

I find no hmm.h in 4.3-rc6

> @@ -272,6 +272,40 @@ void hmm_mirror_range_dirty(struct hmm_mirror =
*mirror,
>  			    unsigned long start,
>  			    unsigned long end);
>=20
> +int hmm_handle_cpu_fault(struct mm_struct *mm,
> +			struct vm_area_struct *vma,
> +			pmd_t *pmdp, unsigned long addr,
> +			unsigned flags, pte_t orig_pte);
> +
> +int hmm_mm_fork(struct mm_struct *src_mm,
> +		struct mm_struct *dst_mm,
> +		struct vm_area_struct *dst_vma,
> +		pmd_t *dst_pmd,
> +		unsigned long start,
> +		unsigned long end);
> +
> +#else /* CONFIG_HMM */
> +
> +static inline int hmm_handle_cpu_fault(struct mm_struct *mm,
> +				       struct vm_area_struct *vma,
> +				       pmd_t *pmdp, unsigned long addr,
> +				       unsigned flags, pte_t orig_pte)
> +{
> +	return VM_FAULT_SIGBUS;
> +}
> +
> +static inline int hmm_mm_fork(struct mm_struct *src_mm,
> +			      struct mm_struct *dst_mm,
> +			      struct vm_area_struct *dst_vma,
> +			      pmd_t *dst_pmd,
> +			      unsigned long start,
> +			      unsigned long end)
> +{
> +	BUG();

s/BUG/BUILD_BUG/ ?

> +	return -ENOMEM;
> +}
>=20
>  #endif /* CONFIG_HMM */
> +
> +
>  #endif
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 7ba7dcc..5c8b871 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -70,8 +70,19 @@ static inline int current_is_kswapd(void)
>  #define SWP_HWPOISON_NUM 0
>  #endif
>=20
> +/*
> + * HMM (heterogeneous memory management) used when data is in remote =
memory.
> + */
> +#ifdef CONFIG_HMM
> +#define SWP_HMM_NUM 1
> +#define SWP_HMM		(MAX_SWAPFILES + SWP_MIGRATION_NUM + =
SWP_HWPOISON_NUM)
> +#else
> +#define SWP_HMM_NUM 0
> +#endif
> +
>  #define MAX_SWAPFILES \
> -	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
> +	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - \
> +	 SWP_HWPOISON_NUM - SWP_HMM_NUM)
>=20
>  /*
>   * Magic header for a swap area. The first part of the union is
> diff --git a/include/linux/swapops.h b/include/linux/swapops.h
> index 5c3a5f3..8c6ba9f 100644
> --- a/include/linux/swapops.h
> +++ b/include/linux/swapops.h
> @@ -227,7 +227,7 @@ static inline void num_poisoned_pages_inc(void)
>  }
>  #endif
>=20
> -#if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION)
> +#if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION) || =
defined(CONFIG_HMM)
>  static inline int non_swap_entry(swp_entry_t entry)
>  {
>  	return swp_type(entry) >=3D MAX_SWAPFILES;
> @@ -239,4 +239,45 @@ static inline int non_swap_entry(swp_entry_t =
entry)
>  }
>  #endif
>=20
> +#ifdef CONFIG_HMM
> +static inline swp_entry_t make_hmm_entry(void)
> +{
> +	/* We do not store anything inside the CPU page table entry (pte). =
*/

pte is clear enough, no?

> +	return swp_entry(SWP_HMM, 0);
> +}
> +
> +static inline swp_entry_t make_hmm_entry_locked(void)
> +{
> +	/* We do not store anything inside the CPU page table entry (pte). =
*/
> +	return swp_entry(SWP_HMM, 1);
> +}
> +
> +static inline swp_entry_t make_hmm_entry_poisonous(void)
> +{
> +	/* We do not store anything inside the CPU page table entry (pte). =
*/
> +	return swp_entry(SWP_HMM, 2);
> +}
> +
> +static inline int is_hmm_entry(swp_entry_t entry)
> +{
> +	return (swp_type(entry) =3D=3D SWP_HMM);
> +}
> +
> +static inline int is_hmm_entry_locked(swp_entry_t entry)
> +{
> +	return (swp_type(entry) =3D=3D SWP_HMM) && (swp_offset(entry) =3D=3D =
1);
> +}
> +
> +static inline int is_hmm_entry_poisonous(swp_entry_t entry)
> +{
> +	return (swp_type(entry) =3D=3D SWP_HMM) && (swp_offset(entry) =3D=3D =
2);
> +}

So SWP_HMM_LOCKED and SWP_HMM_POISON should be defined.

> +#else /* CONFIG_HMM */
> +static inline int is_hmm_entry(swp_entry_t swp)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_HMM */
> +
> +
>  #endif /* _LINUX_SWAPOPS_H */
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 9e5017a..7fb493f 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -416,6 +416,27 @@ static struct mmu_notifier_ops hmm_notifier_ops =
=3D {
>  };
>=20
>=20
> +int hmm_handle_cpu_fault(struct mm_struct *mm,
> +			struct vm_area_struct *vma,
> +			pmd_t *pmdp, unsigned long addr,
> +			unsigned flags, pte_t orig_pte)
> +{
> +	return VM_FAULT_SIGBUS;
> +}
> +EXPORT_SYMBOL(hmm_handle_cpu_fault);
> +
> +int hmm_mm_fork(struct mm_struct *src_mm,
> +		struct mm_struct *dst_mm,
> +		struct vm_area_struct *dst_vma,
> +		pmd_t *dst_pmd,
> +		unsigned long start,
> +		unsigned long end)
> +{
> +	return -ENOMEM;
> +}
> +EXPORT_SYMBOL(hmm_mm_fork);
> +
> +
>  struct mm_pt_iter {
>  	struct mm_struct	*mm;
>  	pte_t			*ptep;
> diff --git a/mm/memory.c b/mm/memory.c
> index bbab5e9..08bc37e 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -53,6 +53,7 @@
>  #include <linux/writeback.h>
>  #include <linux/memcontrol.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/hmm.h>
>  #include <linux/kallsyms.h>
>  #include <linux/swapops.h>
>  #include <linux/elf.h>
> @@ -894,9 +895,11 @@ static int copy_pte_range(struct mm_struct =
*dst_mm, struct mm_struct *src_mm,
>  	pte_t *orig_src_pte, *orig_dst_pte;
>  	pte_t *src_pte, *dst_pte;
>  	spinlock_t *src_ptl, *dst_ptl;
> +	unsigned cnt_hmm_entry =3D 0;

s/cnt_hmm_entry/hmm_ptes/ ?

>  	int progress =3D 0;
>  	int rss[NR_MM_COUNTERS];
>  	swp_entry_t entry =3D (swp_entry_t){0};
> +	unsigned long start;
>=20
>  again:
>  	init_rss_vec(rss);
> @@ -910,6 +913,7 @@ again:
>  	orig_src_pte =3D src_pte;
>  	orig_dst_pte =3D dst_pte;
>  	arch_enter_lazy_mmu_mode();
> +	start =3D addr;
>=20
>  	do {
>  		/*
> @@ -926,6 +930,12 @@ again:
>  			progress++;
>  			continue;
>  		}
> +		if (unlikely(!pte_present(*src_pte))) {
> +			entry =3D pte_to_swp_entry(*src_pte);
> +
> +			if (is_hmm_entry(entry))
> +				cnt_hmm_entry++;
> +		}
>  		entry.val =3D copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
>  							vma, addr, rss);
>  		if (entry.val)
> @@ -940,6 +950,15 @@ again:
>  	pte_unmap_unlock(orig_dst_pte, dst_ptl);
>  	cond_resched();
>=20
> +	if (cnt_hmm_entry) {
> +		int ret;
> +
> +		ret =3D hmm_mm_fork(src_mm, dst_mm, dst_vma,
> +				  dst_pmd, start, end);

Given start, s/end/addr/, no?

> +		if (ret)
> +			return ret;
> +	}
> +
>  	if (entry.val) {
>  		if (add_swap_count_continuation(entry, GFP_KERNEL) < 0)
>  			return -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
