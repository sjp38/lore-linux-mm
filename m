Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E19786B03A1
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 06:25:18 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y190so30755024pgb.3
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 03:25:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q74si666453pfg.490.2017.08.08.03.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 03:25:17 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78AO427079199
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 06:25:16 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2c785pk8a3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 06:25:16 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 20:25:14 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v78AP4R630539930
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 20:25:12 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v78AOd1I021010
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 20:24:39 +1000
Subject: Re: [RFC v5 02/11] mm: Prepare for FAULT_FLAG_SPECULATIVE
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1497635555-25679-3-git-send-email-ldufour@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 8 Aug 2017 15:54:01 +0530
MIME-Version: 1.0
In-Reply-To: <1497635555-25679-3-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <7e770060-32b2-c136-5d34-2f078800df21@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On 06/16/2017 11:22 PM, Laurent Dufour wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> 
> When speculating faults (without holding mmap_sem) we need to validate
> that the vma against which we loaded pages is still valid when we're
> ready to install the new PTE.
> 
> Therefore, replace the pte_offset_map_lock() calls that (re)take the
> PTL with pte_map_lock() which can fail in case we find the VMA changed
> since we started the fault.

Where we are checking if VMA has changed or not since the fault ?

> 
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> 
> [Port to 4.12 kernel]
> [Remove the comment about the fault_env structure which has been
>  implemented as the vm_fault structure in the kernel]
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  include/linux/mm.h |  1 +
>  mm/memory.c        | 55 ++++++++++++++++++++++++++++++++++++++----------------
>  2 files changed, 40 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b892e95d4929..6b7ec2a76953 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -286,6 +286,7 @@ extern pgprot_t protection_map[16];
>  #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
>  #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
>  #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
> +#define FAULT_FLAG_SPECULATIVE	0x200	/* Speculative fault, not holding mmap_sem */

We are not using this yet, may be can wait till late in the series.

>  
>  #define FAULT_FLAG_TRACE \
>  	{ FAULT_FLAG_WRITE,		"WRITE" }, \
> diff --git a/mm/memory.c b/mm/memory.c
> index fd952f05e016..40834444ea0d 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2240,6 +2240,12 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
>  	pte_unmap_unlock(vmf->pte, vmf->ptl);
>  }
>  
> +static bool pte_map_lock(struct vm_fault *vmf)
> +{
> +	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address, &vmf->ptl);
> +	return true;
> +}

This is always true ? Then we should not have all these if (!pte_map_lock(vmf))
check blocks down below.

> +
>  /*
>   * Handle the case of a page which we actually need to copy to a new page.
>   *
> @@ -2267,6 +2273,7 @@ static int wp_page_copy(struct vm_fault *vmf)
>  	const unsigned long mmun_start = vmf->address & PAGE_MASK;
>  	const unsigned long mmun_end = mmun_start + PAGE_SIZE;
>  	struct mem_cgroup *memcg;
> +	int ret = VM_FAULT_OOM;
> 

If we remove the check block over pte_map_lock(), adding VM_FAULT_OOM
becomes redundant here.

>  	if (unlikely(anon_vma_prepare(vma)))
>  		goto oom;
> @@ -2294,7 +2301,11 @@ static int wp_page_copy(struct vm_fault *vmf)
>  	/*
>  	 * Re-check the pte - we dropped the lock
>  	 */
> -	vmf->pte = pte_offset_map_lock(mm, vmf->pmd, vmf->address, &vmf->ptl);
> +	if (!pte_map_lock(vmf)) {
> +		mem_cgroup_cancel_charge(new_page, memcg, false);
> +		ret = VM_FAULT_RETRY;
> +		goto oom_free_new;
> +	}
>  	if (likely(pte_same(*vmf->pte, vmf->orig_pte))) {
>  		if (old_page) {
>  			if (!PageAnon(old_page)) {
> @@ -2382,7 +2393,7 @@ static int wp_page_copy(struct vm_fault *vmf)
>  oom:
>  	if (old_page)
>  		put_page(old_page);
> -	return VM_FAULT_OOM;
> +	return ret;
>  }
>  
>  /**
> @@ -2403,8 +2414,8 @@ static int wp_page_copy(struct vm_fault *vmf)
>  int finish_mkwrite_fault(struct vm_fault *vmf)
>  {
>  	WARN_ON_ONCE(!(vmf->vma->vm_flags & VM_SHARED));
> -	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address,
> -				       &vmf->ptl);
> +	if (!pte_map_lock(vmf))
> +		return VM_FAULT_RETRY;

Cant fail.

>  	/*
>  	 * We might have raced with another page fault while we released the
>  	 * pte_offset_map_lock.
> @@ -2522,8 +2533,11 @@ static int do_wp_page(struct vm_fault *vmf)
>  			get_page(vmf->page);
>  			pte_unmap_unlock(vmf->pte, vmf->ptl);
>  			lock_page(vmf->page);
> -			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
> -					vmf->address, &vmf->ptl);
> +			if (!pte_map_lock(vmf)) {
> +				unlock_page(vmf->page);
> +				put_page(vmf->page);
> +				return VM_FAULT_RETRY;
> +			}

Same here.

>  			if (!pte_same(*vmf->pte, vmf->orig_pte)) {
>  				unlock_page(vmf->page);
>  				pte_unmap_unlock(vmf->pte, vmf->ptl);
> @@ -2681,8 +2695,10 @@ int do_swap_page(struct vm_fault *vmf)
>  			 * Back out if somebody else faulted in this pte
>  			 * while we released the pte lock.
>  			 */
> -			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
> -					vmf->address, &vmf->ptl);
> +			if (!pte_map_lock(vmf)) {
> +				delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> +				return VM_FAULT_RETRY;
> +			}

>  			if (likely(pte_same(*vmf->pte, vmf->orig_pte)))
>  				ret = VM_FAULT_OOM;
>  			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> @@ -2738,8 +2754,11 @@ int do_swap_page(struct vm_fault *vmf)
>  	/*
>  	 * Back out if somebody else already faulted in this pte.
>  	 */
> -	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
> -			&vmf->ptl);
> +	if (!pte_map_lock(vmf)) {
> +		ret = VM_FAULT_RETRY;
> +		mem_cgroup_cancel_charge(page, memcg, false);
> +		goto out_page;
> +	}
>  	if (unlikely(!pte_same(*vmf->pte, vmf->orig_pte)))
>  		goto out_nomap;
>  
> @@ -2903,8 +2922,8 @@ static int do_anonymous_page(struct vm_fault *vmf)
>  			!mm_forbids_zeropage(vma->vm_mm)) {
>  		entry = pte_mkspecial(pfn_pte(my_zero_pfn(vmf->address),
>  						vma->vm_page_prot));
> -		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
> -				vmf->address, &vmf->ptl);
> +		if (!pte_map_lock(vmf))
> +			return VM_FAULT_RETRY;
>  		if (!pte_none(*vmf->pte))
>  			goto unlock;
>  		/* Deliver the page fault to userland, check inside PT lock */
> @@ -2936,8 +2955,11 @@ static int do_anonymous_page(struct vm_fault *vmf)
>  	if (vma->vm_flags & VM_WRITE)
>  		entry = pte_mkwrite(pte_mkdirty(entry));
>  
> -	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
> -			&vmf->ptl);
> +	if (!pte_map_lock(vmf)) {
> +		mem_cgroup_cancel_charge(page, memcg, false);
> +		put_page(page);
> +		return VM_FAULT_RETRY;
> +	}
>  	if (!pte_none(*vmf->pte))
>  		goto release;
>  
> @@ -3057,8 +3079,9 @@ static int pte_alloc_one_map(struct vm_fault *vmf)
>  	 * pte_none() under vmf->ptl protection when we return to
>  	 * alloc_set_pte().
>  	 */
> -	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
> -			&vmf->ptl);
> +	if (!pte_map_lock(vmf))
> +		return VM_FAULT_RETRY;
> +
>  	return 0;

All these 'if' blocks seem redundant, unless I am missing something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
