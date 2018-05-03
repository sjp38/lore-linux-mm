Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6EAE16B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 22:33:32 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v12so787953wmc.1
        for <linux-mm@kvack.org>; Wed, 02 May 2018 19:33:32 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id n6-v6si2579757edn.259.2018.05.02.19.33.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 19:33:30 -0700 (PDT)
Subject: Re: [PATCH] memcg, hugetlb: pages allocated for hugetlb's overcommit
 will be charged to memcg
References: <ecb737e9-ccec-2d7e-45d9-91884a669b58@ascade.co.jp>
 <dc21a4ac-b57f-59a8-f97a-90a59d5a59cd@oracle.com>
 <c9019050-7c89-86c3-93fc-9beb64e43ed3@ascade.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <249d53f4-225d-8a11-d557-b915fa4fa9cb@oracle.com>
Date: Wed, 2 May 2018 19:33:01 -0700
MIME-Version: 1.0
In-Reply-To: <c9019050-7c89-86c3-93fc-9beb64e43ed3@ascade.co.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: TSUKADA Koutaro <tsukada@ascade.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On 05/01/2018 11:54 PM, TSUKADA Koutaro wrote:
> On 2018/05/02 13:41, Mike Kravetz wrote:
>> What is the reason for not charging pages at allocation/reserve time?  I am
>> not an expert in memcg accounting, but I would think the pages should be
>> charged at allocation time.  Otherwise, a task could allocate a large number
>> of (reserved) pages that are not charged to a memcg.  memcg charges in other
>> code paths seem to happen at huge page allocation time.
> 
> If we charge to memcg at page allocation time, the new page is not yet
> registered in rmap, so it will be accounted as 'cache' inside the memcg. Then,
> after being registered in rmap, memcg will account as 'RSS' if the task moves
> cgroup, so I am worried about the possibility of inconsistency in statistics
> (memory.stat).
> 
> As you said, in this patch, there may be a problem that a memory leak occurs
> due to unused pages after being reserved.
> 
>>> This patch targets RHELSA(kernel-alt-4.11.0-45.6.1.el7a.src.rpm).
>>
>> It would be very helpful to rebase this patch on a recent mainline kernel.
>> The code to allocate surplus huge pages has been significantly changed in
>> recent kernels.
>>
>> I have no doubt that this is a real issue and we are not correctly charging
>> surplus to a memcg.  But your patch will be hard to evaluate when based on
>> an older distro kernel.
> I apologize for the patch of the old kernel. The patch was rewritten
> for 4.17-rc2(6d08b06).

Thank you very much for rebasing the patch.

I did not look closely at your patch until now.  My first thought was that
you  were changing/expanding the existing accounting.  However, it appears
that you want to account for hugetlb surplus pages in the memory cgroup.
Is there any reason why the hugetlb cgroup resource controller does not meet
your needs?  It a quick look at the code, it does appear to handle surplus
pages correctly.
-- 
Mike Kravetz

> Mark the page with overcommit at alloc_surplus_huge_page. Since the path of
> alloc_pool_huge_page is creating a pool, I do not think it is necessary to
> mark it.
> 
> Signed-off-by: TSUKADA koutaro <tsukada@ascade.co.jp>
> ---
>  include/linux/hugetlb.h |   45 +++++++++++++++++++++
>  mm/hugetlb.c            |   74 +++++++++++++++++++++++++++++++++++
>  mm/memcontrol.c         |   99 ++++++++++++++++++++++++++++++++++++++++++++++--
>  3 files changed, 214 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 36fa6a2..a92c4e2 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -532,6 +532,51 @@ static inline void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr
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
> index 2186791..fd34f15 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -36,6 +36,7 @@
>  #include <linux/node.h>
>  #include <linux/userfaultfd_k.h>
>  #include <linux/page_owner.h>
> +#include <linux/memcontrol.h>
>  #include "internal.h"
> 
>  int hugetlb_max_hstate __read_mostly;
> @@ -1236,6 +1237,17 @@ static inline void ClearPageHugeTemporary(struct page *page)
>  	page[2].mapping = NULL;
>  }
> 
> +static void hugetlb_overcommit_finalize(struct page *page)
> +{
> +	if (is_hugetlb_overcommit_charged(page)) {
> +		del_hugetlb_overcommit_charged(page);
> +		mem_cgroup_uncharge(page);
> +	}
> +
> +	if (is_hugetlb_overcommit(page))
> +		del_hugetlb_overcommit(page);
> +}
> +
>  void free_huge_page(struct page *page)
>  {
>  	/*
> @@ -1248,6 +1260,8 @@ void free_huge_page(struct page *page)
>  		(struct hugepage_subpool *)page_private(page);
>  	bool restore_reserve;
> 
> +	hugetlb_overcommit_finalize(page);
> +
>  	set_page_private(page, 0);
>  	page->mapping = NULL;
>  	VM_BUG_ON_PAGE(page_count(page), page);
> @@ -1562,6 +1576,8 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
>  	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask);
>  	if (!page)
>  		return NULL;
> +	else
> +		add_hugetlb_overcommit(page);
> 
>  	spin_lock(&hugetlb_lock);
>  	/*
> @@ -3509,6 +3525,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
>  	int ret = 0, outside_reserve = 0;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
> +	struct mem_cgroup *memcg;
> +	int memcg_charged = 0;
> 
>  	pte = huge_ptep_get(ptep);
>  	old_page = pte_page(pte);
> @@ -3575,6 +3593,15 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
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
> @@ -3610,12 +3637,18 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
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
> @@ -3664,9 +3697,18 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
>  	struct inode *inode = mapping->host;
>  	struct hstate *h = hstate_inode(inode);
>  	int err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
> +	struct mem_cgroup *memcg;
> 
>  	if (err)
>  		return err;
> +	if (page && is_hugetlb_overcommit(page)) {
> +		err = mem_cgroup_try_charge(page, current->mm, GFP_KERNEL,
> +						&memcg, true);
> +		if (err)
> +			return err;
> +		mem_cgroup_commit_charge(page, memcg, false, true);
> +		add_hugetlb_overcommit_charged(page);
> +	}
>  	ClearPagePrivate(page);
> 
>  	spin_lock(&inode->i_lock);
> @@ -3686,6 +3728,8 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	struct page *page;
>  	pte_t new_pte;
>  	spinlock_t *ptl;
> +	struct mem_cgroup *memcg;
> +	int memcg_charged = 0;
> 
>  	/*
>  	 * Currently, we are forced to kill the process in the event the
> @@ -3763,6 +3807,14 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
> @@ -3809,6 +3861,10 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
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
> @@ -3829,6 +3885,8 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  backout:
>  	spin_unlock(ptl);
>  backout_unlocked:
> +	if (memcg_charged)
> +		mem_cgroup_cancel_charge(page, memcg, true);
>  	unlock_page(page);
>  	restore_reserve_on_error(h, vma, address, page);
>  	put_page(page);
> @@ -4028,6 +4086,8 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  	spinlock_t *ptl;
>  	int ret;
>  	struct page *page;
> +	struct mem_cgroup *memcg;
> +	int memcg_charged = 0;
> 
>  	if (!*pagep) {
>  		ret = -ENOMEM;
> @@ -4082,6 +4142,14 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  			goto out_release_nounlock;
>  	}
> 
> +	if (!vm_shared && is_hugetlb_overcommit(page)) {
> +		ret = -ENOMEM;
> +		if (mem_cgroup_try_charge(page, dst_mm, GFP_KERNEL,
> +					  &memcg, true))
> +			goto out_release_nounlock;
> +		memcg_charged = 1;
> +	}
> +
>  	ptl = huge_pte_lockptr(h, dst_mm, dst_pte);
>  	spin_lock(ptl);
> 
> @@ -4108,6 +4176,10 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
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
> @@ -4135,6 +4207,8 @@ int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm,
>  	if (vm_shared)
>  		unlock_page(page);
>  out_release_nounlock:
> +	if (memcg_charged)
> +		mem_cgroup_cancel_charge(page, memcg, true);
>  	put_page(page);
>  	goto out;
>  }
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2bd3df3..3db5c32 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4483,7 +4483,7 @@ static int mem_cgroup_move_account(struct page *page,
>  				   struct mem_cgroup *to)
>  {
>  	unsigned long flags;
> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
> +	unsigned int nr_pages = compound ? (1 << compound_order(page)) : 1;
>  	int ret;
>  	bool anon;
> 
> @@ -4698,12 +4698,65 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
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
> +
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
> @@ -4977,10 +5030,48 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
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
> @@ -5417,7 +5508,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
>  			  bool compound)
>  {
>  	struct mem_cgroup *memcg = NULL;
> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
> +	unsigned int nr_pages = compound ? (1 << compound_order(page)) : 1;
>  	int ret = 0;
> 
>  	if (mem_cgroup_disabled())
> @@ -5478,7 +5569,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
>  void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
>  			      bool lrucare, bool compound)
>  {
> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
> +	unsigned int nr_pages = compound ? (1 << compound_order(page)) : 1;
> 
>  	VM_BUG_ON_PAGE(!page->mapping, page);
>  	VM_BUG_ON_PAGE(PageLRU(page) && !lrucare, page);
> @@ -5522,7 +5613,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
>  void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
>  		bool compound)
>  {
> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
> +	unsigned int nr_pages = compound ? (1 << compound_order(page)) : 1;
> 
>  	if (mem_cgroup_disabled())
>  		return;
> 
