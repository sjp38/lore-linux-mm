Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3F886B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 00:41:50 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r140-v6so12945841iod.16
        for <linux-mm@kvack.org>; Tue, 01 May 2018 21:41:50 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m31-v6si5375462iti.94.2018.05.01.21.41.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 May 2018 21:41:49 -0700 (PDT)
Subject: Re: [PATCH] memcg, hugetlb: pages allocated for hugetlb's overcommit
 will be charged to memcg
References: <ecb737e9-ccec-2d7e-45d9-91884a669b58@ascade.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <dc21a4ac-b57f-59a8-f97a-90a59d5a59cd@oracle.com>
Date: Tue, 1 May 2018 21:41:24 -0700
MIME-Version: 1.0
In-Reply-To: <ecb737e9-ccec-2d7e-45d9-91884a669b58@ascade.co.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: TSUKADA Koutaro <tsukada@ascade.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On 05/01/2018 06:19 PM, TSUKADA Koutaro wrote:
> If nr_overcommit_hugepages is assumed to be infinite, allocating pages for
> hugetlb's overcommit from buddy pool is all unlimited even if being limited
> by memcg. The purpose of this patch is that if we allocate the hugetlb page
> from the boddy pool, that means we should charge it to memcg.
> 
> A straightforward way for user applications to use hugetlb pages is to
> create the pool(nr_hugepages), but root privileges is required. For example,
> assuming the field of HPC, it can be said that giving root privs to general
> users is difficult. Also, the way to the creating pool is that we need to
> estimate exactly how much use hugetlb, and it feels a bit troublesome.
> 
> In such a case, using hugetlb's overcommit feature, considered to let the
> user use hugetlb page only with overcommit without creating the any pool.
> However, as mentioned earlier, the page can be allocated limitelessly in
> overcommit in the current implementation. Therefore, by introducing memcg
> charging, I wanted to be able to manage the memory resources used by the
> user application only with memcg's limitation.
> 
> This patch targets RHELSA(kernel-alt-4.11.0-45.6.1.el7a.src.rpm).

It would be very helpful to rebase this patch on a recent mainline kernel.
The code to allocate surplus huge pages has been significantly changed in
recent kernels.

I have no doubt that this is a real issue and we are not correctly charging
surplus to a memcg.  But your patch will be hard to evaluate when based on
an older distro kernel.

>                                                                   The patch
> does the following things.
> 
> When allocating the page from buddy at __hugetlb_alloc_buddy_huge_page,
> set the flag of HUGETLB_OVERCOMMIT on that page[1].private. When actually
> use the page which HUGETLB_OVERCOMMIT is set(at hugepage_add_new_anon_rmap
> or huge_add_to_page_cache), it tries to charge to memcg. If the charge is
> successful, add the flag of HUGETLB_OVERCOMMIT_CHARGED on that page[1].

What is the reason for not charging pages at allocation/reserve time?  I am
not an expert in memcg accounting, but I would think the pages should be
charged at allocation time.  Otherwise, a task could allocate a large number
of (reserved) pages that are not charged to a memcg.  memcg charges in other
code paths seem to happen at huge page allocation time.

-- 
Mike Kravetz

> 
> The page charged to memcg will finally be uncharged at free_huge_page.
> 
> Modification of memcontrol.c is for updating of statistical information
> when the task moves cgroup. The hpage_nr_pages works correctly for thp,
> but it is not suitable for such as hugetlb which uses the contiguous bit
> of aarch64, so need to modify it.
> 
> Signed-off-by: TSUKADA Koutaro <tsukada@ascade.co.jp>
> ---
>  include/linux/hugetlb.h |   45 ++++++++++++++++++++++
>  mm/hugetlb.c            |   80 +++++++++++++++++++++++++++++++++++++++
>  mm/memcontrol.c         |   98 ++++++++++++++++++++++++++++++++++++++++++++++--
>  3 files changed, 219 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index d67675e..67991cb 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -511,6 +511,51 @@ static inline void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr
>  	set_huge_pte_at(mm, addr, ptep, pte);
>  }
>  #endif
> +
> +#define HUGETLB_OVERCOMMIT		1UL
> +#define HUGETLB_OVERCOMMIT_CHARGED	2UL
> +
> +static inline void add_hugetlb_compound_private(struct page *page,
> +						unsigned long val)
> +{
> +	page[1].private |= val;
> +}
> +
> +static inline unsigned long get_hugetlb_compound_private(struct page *page)
> +{
> +	return page_private(&page[1]);
> +}
> +
> +static inline void add_hugetlb_overcommit(struct page *page)
> +{
> +	add_hugetlb_compound_private(page, HUGETLB_OVERCOMMIT);
> +}
> +
> +static inline void del_hugetlb_overcommit(struct page *page)
> +{
> +	add_hugetlb_compound_private(page, ~(HUGETLB_OVERCOMMIT));
> +}
> +
> +static inline int is_hugetlb_overcommit(struct page *page)
> +{
> +	return (get_hugetlb_compound_private(page) & HUGETLB_OVERCOMMIT);
> +}
> +
> +static inline void add_hugetlb_overcommit_charged(struct page *page)
> +{
> +	add_hugetlb_compound_private(page, HUGETLB_OVERCOMMIT_CHARGED);
> +}
> +
> +static inline void del_hugetlb_overcommit_charged(struct page *page)
> +{
> +	add_hugetlb_compound_private(page, ~(HUGETLB_OVERCOMMIT_CHARGED));
> +}
> +
> +static inline int is_hugetlb_overcommit_charged(struct page *page)
> +{
> +	return (get_hugetlb_compound_private(page) &
> +		HUGETLB_OVERCOMMIT_CHARGED);
> +}
>  #else	/* CONFIG_HUGETLB_PAGE */
>  struct hstate {};
>  #define alloc_huge_page(v, a, r) NULL
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6191fb9..2cd91d9 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -24,6 +24,7 @@
>  #include <linux/swapops.h>
>  #include <linux/page-isolation.h>
>  #include <linux/jhash.h>
> +#include <linux/memcontrol.h>
> 
>  #include <asm/page.h>
>  #include <asm/pgtable.h>
> @@ -1227,6 +1228,17 @@ static void clear_page_huge_active(struct page *page)
>  	ClearPagePrivate(&page[1]);
>  }
> 
> +static void hugetlb_overcommit_finalize(struct page *page)
> +{
> +	if (is_hugetlb_overcommit_charged(page)) {
> +		del_hugetlb_overcommit_charged(page);
> +		mem_cgroup_uncharge(page);
> +	}
> +	if (is_hugetlb_overcommit(page)) {
> +		del_hugetlb_overcommit(page);
> +	}
> +}
> +
>  void free_huge_page(struct page *page)
>  {
>  	/*
> @@ -1239,6 +1251,8 @@ void free_huge_page(struct page *page)
>  		(struct hugepage_subpool *)page_private(page);
>  	bool restore_reserve;
> 
> +	hugetlb_overcommit_finalize(page);
> +
>  	set_page_private(page, 0);
>  	page->mapping = NULL;
>  	VM_BUG_ON_PAGE(page_count(page), page);
> @@ -1620,6 +1634,13 @@ static struct page *__alloc_buddy_huge_page(struct hstate *h,
>  	spin_unlock(&hugetlb_lock);
> 
>  	page = __hugetlb_alloc_buddy_huge_page(h, vma, addr, nid);
> +	if (page) {
> +		/*
> +		 * At this point it is impossible to judge whether it is
> +		 * mapped or just reserved, so only mark it.
> +		 */
> +		add_hugetlb_overcommit(page);
> +	}
> 
>  	spin_lock(&hugetlb_lock);
>  	if (page) {
> @@ -3486,6 +3507,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  	int ret = 0, outside_reserve = 0;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
> +	struct mem_cgroup *memcg;
> +	int memcg_charged = 0;
> 
>  	pte = huge_ptep_get(ptep);
>  	old_page = pte_page(pte);
> @@ -3552,6 +3575,15 @@ retry_avoidcopy:
>  		goto out_release_old;
>  	}
> 
> +	if (unlikely(is_hugetlb_overcommit(new_page))) {
> +		if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL,
> +						&memcg, true)) {
> +			ret = VM_FAULT_OOM;
> +			goto out_release_all;
> +		}
> +		memcg_charged = 1;
> +	}
> +
>  	/*
>  	 * When the original hugepage is shared one, it does not have
>  	 * anon_vma prepared.
> @@ -3587,12 +3619,18 @@ retry_avoidcopy:
>  				make_huge_pte(vma, new_page, 1));
>  		page_remove_rmap(old_page, true);
>  		hugepage_add_new_anon_rmap(new_page, vma, address);
> +		if (memcg_charged) {
> +			mem_cgroup_commit_charge(new_page, memcg, false, true);
> +			add_hugetlb_overcommit_charged(new_page);
> +		}
>  		/* Make the old page be freed below */
>  		new_page = old_page;
>  	}
>  	spin_unlock(ptl);
>  	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>  out_release_all:
> +	if (memcg_charged)
> +		mem_cgroup_cancel_charge(new_page, memcg, true);
>  	restore_reserve_on_error(h, vma, address, new_page);
>  	put_page(new_page);
>  out_release_old:
> @@ -3641,9 +3679,18 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
>  	struct inode *inode = mapping->host;
>  	struct hstate *h = hstate_inode(inode);
>  	int err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
> +	struct mem_cgroup *memcg;
> 
>  	if (err)
>  		return err;
> +	if (page && is_hugetlb_overcommit(page)) {
> +		err = mem_cgroup_try_charge(page, current->mm, GFP_KERNEL,
> +					    &memcg, true);
> +		if (err)
> +			return err;
> +		mem_cgroup_commit_charge(page, memcg, false, true);
> +		add_hugetlb_overcommit_charged(page);
> +	}
>  	ClearPagePrivate(page);
> 
>  	spin_lock(&inode->i_lock);
> @@ -3663,6 +3710,8 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct page *page;
>  	pte_t new_pte;
>  	spinlock_t *ptl;
> +	struct mem_cgroup *memcg;
> +	int memcg_charged = 0;
> 
>  	/*
>  	 * Currently, we are forced to kill the process in the event the
> @@ -3740,6 +3789,14 @@ retry:
>  			}
>  		} else {
>  			lock_page(page);
> +			if (unlikely(is_hugetlb_overcommit(page))) {
> +				if (mem_cgroup_try_charge(page, mm, GFP_KERNEL,
> +							  &memcg, true)) {
> +					ret = VM_FAULT_OOM;
> +					goto backout_unlocked;
> +				}
> +				memcg_charged = 1;
> +			}
>  			if (unlikely(anon_vma_prepare(vma))) {
>  				ret = VM_FAULT_OOM;
>  				goto backout_unlocked;
> @@ -3786,6 +3843,10 @@ retry:
>  	if (anon_rmap) {
>  		ClearPagePrivate(page);
>  		hugepage_add_new_anon_rmap(page, vma, address);
> +		if (memcg_charged) {
> +			mem_cgroup_commit_charge(page, memcg, false, true);
> +			add_hugetlb_overcommit_charged(page);
> +		}
>  	} else
>  		page_dup_rmap(page, true);
>  	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
> @@ -3806,6 +3867,8 @@ out:
>  backout:
>  	spin_unlock(ptl);
>  backout_unlocked:
> +	if (memcg_charged)
> +		mem_cgroup_cancel_charge(page, memcg, true);
>  	unlock_page(page);
>  	restore_reserve_on_error(h, vma, address, page);
>  	put_page(page);
> @@ -4002,6 +4065,9 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  	spinlock_t *ptl;
>  	int ret;
>  	struct page *page;
> +	struct mem_cgroup *memcg;
> +	int memcg_charged = 0;
> +
> 
>  	if (!*pagep) {
>  		ret = -ENOMEM;
> @@ -4045,6 +4111,14 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  			goto out_release_nounlock;
>  	}
> 
> +	if (!vm_shared && is_hugetlb_overcommit(page)) {
> +		ret = -ENOMEM;
> +		if (mem_cgroup_try_charge(page, dst_mm, GFP_KERNEL,
> +						&memcg, true))
> +			goto out_release_nounlock;
> +		memcg_charged = 1;
> +	}
> +
>  	ptl = huge_pte_lockptr(h, dst_mm, dst_pte);
>  	spin_lock(ptl);
> 
> @@ -4057,6 +4131,10 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  	} else {
>  		ClearPagePrivate(page);
>  		hugepage_add_new_anon_rmap(page, dst_vma, dst_addr);
> +		if (memcg_charged) {
> +			mem_cgroup_commit_charge(page, memcg, false, true);
> +			add_hugetlb_overcommit_charged(page);
> +		}
>  	}
> 
>  	_dst_pte = make_huge_pte(dst_vma, page, dst_vma->vm_flags & VM_WRITE);
> @@ -4082,6 +4160,8 @@ out:
>  out_release_unlock:
>  	spin_unlock(ptl);
>  out_release_nounlock:
> +	if (memcg_charged)
> +		mem_cgroup_cancel_charge(page, memcg, true);
>  	if (vm_shared)
>  		unlock_page(page);
>  	put_page(page);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 02cfcd9..1842693 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4531,7 +4531,7 @@ static int mem_cgroup_move_account(struct page *page,
>  				   struct mem_cgroup *to)
>  {
>  	unsigned long flags;
> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
> +	unsigned int nr_pages = compound ? 1 << compound_order(page) : 1;
>  	int ret;
>  	bool anon;
> 
> @@ -4744,12 +4744,64 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
>  	return 0;
>  }
> 
> +#ifdef CONFIG_HUGETLB_PAGE
> +static enum mc_target_type get_mctgt_type_hugetlb(struct vm_area_struct *vma,
> +			unsigned long addr, pte_t *pte, union mc_target *target)
> +{
> +	struct page *page = NULL;
> +	pte_t entry;
> +	enum mc_target_type ret = MC_TARGET_NONE;
> +
> +	if (!(mc.flags & MOVE_ANON))
> +		return ret;
> +
> +	entry = huge_ptep_get(pte);
> +	if (!pte_present(entry))
> +		return ret;
> +	page = pte_page(entry);
> +	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
> +	if (!is_hugetlb_overcommit_charged(page))
> +		return ret;
> +	if (page->mem_cgroup == mc.from) {
> +		ret = MC_TARGET_PAGE;
> +		if (target) {
> +			get_page(page);
> +			target->page = page;
> +		}
> +	}
> +
> +	return ret;
> +}
> +
> +static int hugetlb_count_precharge_pte_range(pte_t *pte, unsigned long hmask,
> +					unsigned long addr, unsigned long end,
> +					struct mm_walk *walk)
> +{
> +	struct vm_area_struct *vma = walk->vma;
> +	struct mm_struct *mm = walk->mm;
> +	spinlock_t *ptl;
> +	union mc_target target;
> +
> +	ptl = huge_pte_lock(hstate_vma(vma), mm, pte);
> +	if (get_mctgt_type_hugetlb(vma, addr, pte, &target) == MC_TARGET_PAGE) {
> +		mc.precharge += (1 << compound_order(target.page));
> +		put_page(target.page);
> +	}
> +	spin_unlock(ptl);
> +
> +	return 0;
> +}
> +#endif
> +
>  static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
>  {
>  	unsigned long precharge;
> 
>  	struct mm_walk mem_cgroup_count_precharge_walk = {
>  		.pmd_entry = mem_cgroup_count_precharge_pte_range,
> +#ifdef CONFIG_HUGETLB_PAGE
> +		.hugetlb_entry = hugetlb_count_precharge_pte_range,
> +#endif
>  		.mm = mm,
>  	};
>  	down_read(&mm->mmap_sem);
> @@ -5023,10 +5075,48 @@ put:			/* get_mctgt_type() gets the page */
>  	return ret;
>  }
> 
> +#ifdef CONFIG_HUGETLB_PAGE
> +static int hugetlb_move_charge_pte_range(pte_t *pte, unsigned long hmask,
> +					unsigned long addr, unsigned long end,
> +					struct mm_walk *walk)
> +{
> +	struct vm_area_struct *vma = walk->vma;
> +	struct mm_struct *mm = walk->mm;
> +	spinlock_t *ptl;
> +	enum mc_target_type target_type;
> +	union mc_target target;
> +	struct page *page;
> +	unsigned long nr_pages;
> +
> +	ptl = huge_pte_lock(hstate_vma(vma), mm, pte);
> +	target_type = get_mctgt_type_hugetlb(vma, addr, pte, &target);
> +	if (target_type == MC_TARGET_PAGE) {
> +		page = target.page;
> +		nr_pages = (1 << compound_order(page));
> +		if (mc.precharge < nr_pages) {
> +			put_page(page);
> +			goto unlock;
> +		}
> +		if (!mem_cgroup_move_account(page, true, mc.from, mc.to)) {
> +			mc.precharge -= nr_pages;
> +			mc.moved_charge += nr_pages;
> +		}
> +		put_page(page);
> +	}
> +unlock:
> +	spin_unlock(ptl);
> +
> +	return 0;
> +}
> +#endif
> +
>  static void mem_cgroup_move_charge(void)
>  {
>  	struct mm_walk mem_cgroup_move_charge_walk = {
>  		.pmd_entry = mem_cgroup_move_charge_pte_range,
> +#ifdef CONFIG_HUGETLB_PAGE
> +		.hugetlb_entry = hugetlb_move_charge_pte_range,
> +#endif
>  		.mm = mc.mm,
>  	};
> 
> @@ -5427,7 +5517,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
>  			  bool compound)
>  {
>  	struct mem_cgroup *memcg = NULL;
> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
> +	unsigned int nr_pages = compound ? (1 << compound_order(page)) : 1;
>  	int ret = 0;
> 
>  	if (mem_cgroup_disabled())
> @@ -5488,7 +5578,7 @@ out:
>  void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
>  			      bool lrucare, bool compound)
>  {
> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
> +	unsigned int nr_pages = compound ? (1 << compound_order(page)) : 1;
> 
>  	VM_BUG_ON_PAGE(!page->mapping, page);
>  	VM_BUG_ON_PAGE(PageLRU(page) && !lrucare, page);
> @@ -5532,7 +5622,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
>  void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
>  		bool compound)
>  {
> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
> +	unsigned int nr_pages = compound ? (1 << compound_order(page)) : 1;
> 
>  	if (mem_cgroup_disabled())
>  		return;
> 
