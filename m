Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 542AC6B04BE
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 13:13:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t190so410634wmt.6
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 10:13:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 48si707148wrb.131.2017.09.05.10.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Sep 2017 10:13:25 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v85H8rel141907
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 13:13:24 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2csweqghv0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 05 Sep 2017 13:13:23 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 5 Sep 2017 18:13:21 +0100
Subject: Re: [HMM-v25 10/19] mm/memcontrol: support MEMORY_DEVICE_PRIVATE v4
References: <20170817000548.32038-1-jglisse@redhat.com>
 <20170817000548.32038-11-jglisse@redhat.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 5 Sep 2017 19:13:15 +0200
MIME-Version: 1.0
In-Reply-To: <20170817000548.32038-11-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <f239d1c2-7006-5ce4-7848-7d82e67533a9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

On 17/08/2017 02:05, JA(C)rA'me Glisse wrote:
> HMM pages (private or public device pages) are ZONE_DEVICE page and
> thus need special handling when it comes to lru or refcount. This
> patch make sure that memcontrol properly handle those when it face
> them. Those pages are use like regular pages in a process address
> space either as anonymous page or as file back page. So from memcg
> point of view we want to handle them like regular page for now at
> least.
> 
> Changed since v3:
>   - remove public support and move those chunk to separate patch
> Changed since v2:
>   - s/host/public
> Changed since v1:
>   - s/public/host
>   - add comments explaining how device memory behave and why
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Acked-by: Balbir Singh <bsingharora@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: cgroups@vger.kernel.org
> ---
>  kernel/memremap.c |  1 +
>  mm/memcontrol.c   | 52 ++++++++++++++++++++++++++++++++++++++++++++++++----
>  2 files changed, 49 insertions(+), 4 deletions(-)
> 
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 398630c1fba3..f42d7483e886 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -492,6 +492,7 @@ void put_zone_device_private_page(struct page *page)
>  		__ClearPageWaiters(page);
> 
>  		page->mapping = NULL;
> +		mem_cgroup_uncharge(page);
> 
>  		page->pgmap->page_free(page, page->pgmap->data);
>  	} else if (!count)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 604fb3ca8028..977d1cf3493a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4407,12 +4407,13 @@ enum mc_target_type {
>  	MC_TARGET_NONE = 0,
>  	MC_TARGET_PAGE,
>  	MC_TARGET_SWAP,
> +	MC_TARGET_DEVICE,
>  };
> 
>  static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
>  						unsigned long addr, pte_t ptent)
>  {
> -	struct page *page = vm_normal_page(vma, addr, ptent);
> +	struct page *page = _vm_normal_page(vma, addr, ptent, true);

Hi JA(C)rA'me,

As _vm_normal_page() is defined later in the patch 18, so this patch should
 break the bisectability.

Cheers,
Laurent.

> 
>  	if (!page || !page_mapped(page))
>  		return NULL;
> @@ -4429,7 +4430,7 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
>  	return page;
>  }
> 
> -#ifdef CONFIG_SWAP
> +#if defined(CONFIG_SWAP) || defined(CONFIG_DEVICE_PRIVATE)
>  static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
>  			pte_t ptent, swp_entry_t *entry)
>  {
> @@ -4438,6 +4439,23 @@ static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
> 
>  	if (!(mc.flags & MOVE_ANON) || non_swap_entry(ent))
>  		return NULL;
> +
> +	/*
> +	 * Handle MEMORY_DEVICE_PRIVATE which are ZONE_DEVICE page belonging to
> +	 * a device and because they are not accessible by CPU they are store
> +	 * as special swap entry in the CPU page table.
> +	 */
> +	if (is_device_private_entry(ent)) {
> +		page = device_private_entry_to_page(ent);
> +		/*
> +		 * MEMORY_DEVICE_PRIVATE means ZONE_DEVICE page and which have
> +		 * a refcount of 1 when free (unlike normal page)
> +		 */
> +		if (!page_ref_add_unless(page, 1, 1))
> +			return NULL;
> +		return page;
> +	}
> +
>  	/*
>  	 * Because lookup_swap_cache() updates some statistics counter,
>  	 * we call find_get_page() with swapper_space directly.
> @@ -4598,6 +4616,12 @@ static int mem_cgroup_move_account(struct page *page,
>   *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
>   *     target for charge migration. if @target is not NULL, the entry is stored
>   *     in target->ent.
> + *   3(MC_TARGET_DEVICE): like MC_TARGET_PAGE  but page is MEMORY_DEVICE_PRIVATE
> + *     (so ZONE_DEVICE page and thus not on the lru). For now we such page is
> + *     charge like a regular page would be as for all intent and purposes it is
> + *     just special memory taking the place of a regular page.
> + *
> + *     See Documentations/vm/hmm.txt and include/linux/hmm.h
>   *
>   * Called with pte lock held.
>   */
> @@ -4626,6 +4650,8 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
>  		 */
>  		if (page->mem_cgroup == mc.from) {
>  			ret = MC_TARGET_PAGE;
> +			if (is_device_private_page(page))
> +				ret = MC_TARGET_DEVICE;
>  			if (target)
>  				target->page = page;
>  		}
> @@ -4693,6 +4719,11 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
> 
>  	ptl = pmd_trans_huge_lock(pmd, vma);
>  	if (ptl) {
> +		/*
> +		 * Note their can not be MC_TARGET_DEVICE for now as we do not
> +		 * support transparent huge page with MEMORY_DEVICE_PUBLIC or
> +		 * MEMORY_DEVICE_PRIVATE but this might change.
> +		 */
>  		if (get_mctgt_type_thp(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
>  			mc.precharge += HPAGE_PMD_NR;
>  		spin_unlock(ptl);
> @@ -4908,6 +4939,14 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
>  				putback_lru_page(page);
>  			}
>  			put_page(page);
> +		} else if (target_type == MC_TARGET_DEVICE) {
> +			page = target.page;
> +			if (!mem_cgroup_move_account(page, true,
> +						     mc.from, mc.to)) {
> +				mc.precharge -= HPAGE_PMD_NR;
> +				mc.moved_charge += HPAGE_PMD_NR;
> +			}
> +			put_page(page);
>  		}
>  		spin_unlock(ptl);
>  		return 0;
> @@ -4919,12 +4958,16 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
>  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  	for (; addr != end; addr += PAGE_SIZE) {
>  		pte_t ptent = *(pte++);
> +		bool device = false;
>  		swp_entry_t ent;
> 
>  		if (!mc.precharge)
>  			break;
> 
>  		switch (get_mctgt_type(vma, addr, ptent, &target)) {
> +		case MC_TARGET_DEVICE:
> +			device = true;
> +			/* fall through */
>  		case MC_TARGET_PAGE:
>  			page = target.page;
>  			/*
> @@ -4935,7 +4978,7 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
>  			 */
>  			if (PageTransCompound(page))
>  				goto put;
> -			if (isolate_lru_page(page))
> +			if (!device && isolate_lru_page(page))
>  				goto put;
>  			if (!mem_cgroup_move_account(page, false,
>  						mc.from, mc.to)) {
> @@ -4943,7 +4986,8 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
>  				/* we uncharge from mc.from later. */
>  				mc.moved_charge++;
>  			}
> -			putback_lru_page(page);
> +			if (!device)
> +				putback_lru_page(page);
>  put:			/* get_mctgt_type() gets the page */
>  			put_page(page);
>  			break;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
