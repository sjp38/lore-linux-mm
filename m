Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 866296B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 09:02:32 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6GD2UXj024653
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 16 Jul 2009 22:02:30 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 267F645DE57
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 22:02:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EA6F945DE51
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 22:02:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A7DF91DB8038
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 22:02:29 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D43CE38002
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 22:02:29 +0900 (JST)
Message-ID: <eb603fae09005e4a23c9e84da316ff68.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090716210028.07a8e1f7.minchan.kim@barrios-desktop>
References: <20090709122428.8c2d4232.kamezawa.hiroyu@jp.fujitsu.com>
    <20090716180134.3393acde.kamezawa.hiroyu@jp.fujitsu.com>
    <20090716180424.eb4c44ce.kamezawa.hiroyu@jp.fujitsu.com>
    <20090716210028.07a8e1f7.minchan.kim@barrios-desktop>
Date: Thu, 16 Jul 2009 22:02:28 +0900 (JST)
Subject: Re: [PATCH 2/2] ZERO PAGE based on pte_special
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
>
> Hi, Kame.
>
> On Thu, 16 Jul 2009 18:04:24 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> ZERO_PAGE for anonymous private mapping is useful when an application
>> requires large continuous memory but write sparsely or some other
>> usages.
>> It was removed in 2.6.24 but this patch tries to re-add it.
>> (Because there are some use cases..)
>>
>> In past, ZERO_PAGE was removed because heavy cache line contention in
>> ZERO_PAGE's refcounting, this version of ZERO_PAGE avoid to refcnt it.
>> Then, implementation is changed as following.
>>
>>   - Use of ZERO_PAGE is limited to PRIVATE mapping. Then, VM_MAYSHARE is
>>     checked as VM_SHARED.
>>
>>   - pte_special(), _PAGE_SPECIAL bit in pte is used for indicating
>> ZERO_PAGE.
>>
>>   - vm_normal_page() eats FOLL_XXX flag. If FOLL_NOZERO is set,
>>     NULL is returned even if ZERO_PAGE is found.
>>
>>   - __get_user_pages() eats one more flag as GUP_FLAGS_IGNORE_ZERO. If
>> set,
>>     __get_user_page() returns NULL even if ZERO_PAGE is found.
>>
>> Note:
>>   - no changes to get_user_pages(). ZERO_PAGE can be returned when
>>     vma is ANONYMOUS && PRIVATE and the access is READ.
>>
>> Changelog v3->v4
>>  - FOLL_NOZERO is directly passed to vm_normal_page()
>>
>> Changelog v2->v3
>>  - totally renewed.
>>  - use pte_special()
>>  - added new argument to vm_normal_page().
>>  - MAYSHARE is checked.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>  fs/proc/task_mmu.c |    8 +--
>>  include/linux/mm.h |    3 -
>>  mm/fremap.c        |    2
>>  mm/internal.h      |    1
>>  mm/memory.c        |  136
>> +++++++++++++++++++++++++++++++++++++++++------------
>>  mm/mempolicy.c     |    8 +--
>>  mm/migrate.c       |    6 +-
>>  mm/mlock.c         |    2
>>  mm/rmap.c          |    6 +-
>>  9 files changed, 128 insertions(+), 44 deletions(-)
>>
>> Index: mmotm-2.6.31-Jul15/mm/memory.c
>> ===================================================================
>> --- mmotm-2.6.31-Jul15.orig/mm/memory.c
>> +++ mmotm-2.6.31-Jul15/mm/memory.c
>> @@ -442,6 +442,27 @@ static inline int is_cow_mapping(unsigne
>>  }
>>
>>  /*
>> + * Can we use ZERO_PAGE at fault ? or Can we do the FOLL_ANON
>> optimization ?
>> + */
>> +static inline int use_zero_page(struct vm_area_struct *vma)
>> +{
>> +	/*
>> +	 * We don't want to optimize FOLL_ANON for make_pages_present()
>> +	 * when it tries to page in a VM_LOCKED region. As to VM_SHARED,
>> +	 * we want to get the page from the page tables to make sure
>> +	 * that we serialize and update with any other user of that
>> +	 * mapping. At doing page fault, VM_MAYSHARE should be also check for
>> +	 * avoiding possible changes to VM_SHARED.
>> +	 */
>> +	if (vma->vm_flags & (VM_LOCKED | VM_SHARED | VM_MAYSHARE))
>> +		return 0;
>> +	/*
>> +	 * And if we have a fault routine, it's not an anonymous region.
>> +	 */
>> +	return !vma->vm_ops || !vma->vm_ops->fault;
>> +}
>> +
>> +/*
>>   * vm_normal_page -- This function gets the "struct page" associated
>> with a pte.
>>   *
>>   * "Special" mappings do not wish to be associated with a "struct page"
>> (either
>> @@ -488,16 +509,33 @@ static inline int is_cow_mapping(unsigne
>>  #else
>>  # define HAVE_PTE_SPECIAL 0
>>  #endif
>> +
>> +#ifdef CONFIG_SUPPORT_ANON_ZERO_PAGE
>> +# define HAVE_ANON_ZERO 1
>> +#else
>> +# define HAVE_ANON_ZERO 0
>> +#endif
>>  struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long
>> addr,
>> -				pte_t pte)
>> +			    pte_t pte, unsigned int flags)
>>  {
>>  	unsigned long pfn = pte_pfn(pte);
>>
>>  	if (HAVE_PTE_SPECIAL) {
>>  		if (likely(!pte_special(pte)))
>>  			goto check_pfn;
>> -		if (!(vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP)))
>> -			print_bad_pte(vma, addr, pte, NULL);
>> +
>> +		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
>> +			return NULL;
>> +		/*
>> +		 * ZERO PAGE ? If vma is shared or has page fault handler,
>> +		 * Using ZERO PAGE is bug.
>> +		 */
>> +		if (HAVE_ANON_ZERO && use_zero_page(vma)) {
>> +			if (flags & FOLL_NOZERO)
>> +				return NULL;
>> +			return ZERO_PAGE(0);
>> +		}
>> +		print_bad_pte(vma, addr, pte, NULL);
>>  		return NULL;
>>  	}
>>
>> @@ -591,8 +629,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
>>  	if (vm_flags & VM_SHARED)
>>  		pte = pte_mkclean(pte);
>>  	pte = pte_mkold(pte);
>> -
>> -	page = vm_normal_page(vma, addr, pte);
>> +	page = vm_normal_page(vma, addr, pte, FOLL_NOZERO);
>>  	if (page) {
>>  		get_page(page);
>>  		page_dup_rmap(page, vma, addr);
>> @@ -783,7 +820,7 @@ static unsigned long zap_pte_range(struc
>>  		if (pte_present(ptent)) {
>>  			struct page *page;
>>
>> -			page = vm_normal_page(vma, addr, ptent);
>> +			page = vm_normal_page(vma, addr, ptent, FOLL_NOZERO);
>>  			if (unlikely(details) && page) {
>>  				/*
>>  				 * unmap_shared_mapping_pages() wants to
>> @@ -1141,7 +1178,7 @@ struct page *follow_page(struct vm_area_
>>  		goto no_page;
>>  	if ((flags & FOLL_WRITE) && !pte_write(pte))
>>  		goto unlock;
>> -	page = vm_normal_page(vma, address, pte);
>> +	page = vm_normal_page(vma, address, pte, flags);
>>  	if (unlikely(!page))
>>  		goto bad_page;
>>
>> @@ -1186,23 +1223,6 @@ no_page_table:
>>  	return page;
>>  }
>>
>> -/* Can we do the FOLL_ANON optimization? */
>> -static inline int use_zero_page(struct vm_area_struct *vma)
>> -{
>> -	/*
>> -	 * We don't want to optimize FOLL_ANON for make_pages_present()
>> -	 * when it tries to page in a VM_LOCKED region. As to VM_SHARED,
>> -	 * we want to get the page from the page tables to make sure
>> -	 * that we serialize and update with any other user of that
>> -	 * mapping.
>> -	 */
>> -	if (vma->vm_flags & (VM_LOCKED | VM_SHARED))
>> -		return 0;
>> -	/*
>> -	 * And if we have a fault routine, it's not an anonymous region.
>> -	 */
>> -	return !vma->vm_ops || !vma->vm_ops->fault;
>> -}
>>
>>
>>
>> @@ -1216,6 +1236,7 @@ int __get_user_pages(struct task_struct
>>  	int force = !!(flags & GUP_FLAGS_FORCE);
>>  	int ignore = !!(flags & GUP_FLAGS_IGNORE_VMA_PERMISSIONS);
>>  	int ignore_sigkill = !!(flags & GUP_FLAGS_IGNORE_SIGKILL);
>> +	int ignore_zero = !!(flags & GUP_FLAGS_IGNORE_ZERO);
>>
>>  	if (nr_pages <= 0)
>>  		return 0;
>> @@ -1259,7 +1280,12 @@ int __get_user_pages(struct task_struct
>>  				return i ? : -EFAULT;
>>  			}
>>  			if (pages) {
>> -				struct page *page = vm_normal_page(gate_vma, start, *pte);
>> +				struct page *page;
>> +				/*
>> +				 * this is not anon vma...don't haddle zero page
>> +				 * related flags.
>> +				 */
>> +				page = vm_normal_page(gate_vma, start, *pte, 0);
>>  				pages[i] = page;
>>  				if (page)
>>  					get_page(page);
>> @@ -1287,8 +1313,13 @@ int __get_user_pages(struct task_struct
>>  		foll_flags = FOLL_TOUCH;
>>  		if (pages)
>>  			foll_flags |= FOLL_GET;
>> -		if (!write && use_zero_page(vma))
>> -			foll_flags |= FOLL_ANON;
>> +		if (!write) {
>> +			if (use_zero_page(vma))
>> +				foll_flags |= FOLL_ANON;
>> +			else
>> +				ignore_zero = 0;
>> +		} else
>> +			ignore_zero = 0;
>
> Hmm. nested condition is not good for redabililty.
>
> How about this ?
> if (!write && use_zero_page(vma))
> 	foll_flags |= FOLL_ANON;
> else
> 	ignore_zero = 0;
>
Ah, yes. yours seems better.
I'll post updated one, later.

Thank you
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
