Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 02D716B002F
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 17:50:15 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v8so8488619pgs.9
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 14:50:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h9sor3944445pgc.222.2018.03.25.14.50.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Mar 2018 14:50:13 -0700 (PDT)
Date: Sun, 25 Mar 2018 14:50:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 04/24] mm: Prepare for FAULT_FLAG_SPECULATIVE
In-Reply-To: <1520963994-28477-5-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1803251426120.80485@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-5-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 13 Mar 2018, Laurent Dufour wrote:

> From: Peter Zijlstra <peterz@infradead.org>
> 
> When speculating faults (without holding mmap_sem) we need to validate
> that the vma against which we loaded pages is still valid when we're
> ready to install the new PTE.
> 
> Therefore, replace the pte_offset_map_lock() calls that (re)take the
> PTL with pte_map_lock() which can fail in case we find the VMA changed
> since we started the fault.
> 

Based on how its used, I would have suspected this to be named 
pte_map_trylock().

> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> 
> [Port to 4.12 kernel]
> [Remove the comment about the fault_env structure which has been
>  implemented as the vm_fault structure in the kernel]
> [move pte_map_lock()'s definition upper in the file]
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  include/linux/mm.h |  1 +
>  mm/memory.c        | 56 ++++++++++++++++++++++++++++++++++++++----------------
>  2 files changed, 41 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4d02524a7998..2f3e98edc94a 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -300,6 +300,7 @@ extern pgprot_t protection_map[16];
>  #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
>  #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
>  #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
> +#define FAULT_FLAG_SPECULATIVE	0x200	/* Speculative fault, not holding mmap_sem */
>  
>  #define FAULT_FLAG_TRACE \
>  	{ FAULT_FLAG_WRITE,		"WRITE" }, \

I think FAULT_FLAG_SPECULATIVE should be introduced in the patch that 
actually uses it.

> diff --git a/mm/memory.c b/mm/memory.c
> index e0ae4999c824..8ac241b9f370 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2288,6 +2288,13 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>  }
>  EXPORT_SYMBOL_GPL(apply_to_page_range);
>  
> +static bool pte_map_lock(struct vm_fault *vmf)

inline?

> +{
> +	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
> +				       vmf->address, &vmf->ptl);
> +	return true;
> +}
> +
>  /*
>   * handle_pte_fault chooses page fault handler according to an entry which was
>   * read non-atomically.  Before making any commitment, on those architectures
> @@ -2477,6 +2484,7 @@ static int wp_page_copy(struct vm_fault *vmf)
>  	const unsigned long mmun_start = vmf->address & PAGE_MASK;
>  	const unsigned long mmun_end = mmun_start + PAGE_SIZE;
>  	struct mem_cgroup *memcg;
> +	int ret = VM_FAULT_OOM;
>  
>  	if (unlikely(anon_vma_prepare(vma)))
>  		goto oom;
> @@ -2504,7 +2512,11 @@ static int wp_page_copy(struct vm_fault *vmf)
>  	/*
>  	 * Re-check the pte - we dropped the lock
>  	 */
> -	vmf->pte = pte_offset_map_lock(mm, vmf->pmd, vmf->address, &vmf->ptl);
> +	if (!pte_map_lock(vmf)) {
> +		mem_cgroup_cancel_charge(new_page, memcg, false);
> +		ret = VM_FAULT_RETRY;
> +		goto oom_free_new;
> +	}

Ugh, but we aren't oom here, so maybe rename oom_free_new so that it makes 
sense for return values other than VM_FAULT_OOM?

>  	if (likely(pte_same(*vmf->pte, vmf->orig_pte))) {
>  		if (old_page) {
>  			if (!PageAnon(old_page)) {
> @@ -2596,7 +2608,7 @@ static int wp_page_copy(struct vm_fault *vmf)
>  oom:
>  	if (old_page)
>  		put_page(old_page);
> -	return VM_FAULT_OOM;
> +	return ret;
>  }
>  
>  /**
> @@ -2617,8 +2629,8 @@ static int wp_page_copy(struct vm_fault *vmf)
>  int finish_mkwrite_fault(struct vm_fault *vmf)
>  {
>  	WARN_ON_ONCE(!(vmf->vma->vm_flags & VM_SHARED));
> -	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address,
> -				       &vmf->ptl);
> +	if (!pte_map_lock(vmf))
> +		return VM_FAULT_RETRY;
>  	/*
>  	 * We might have raced with another page fault while we released the
>  	 * pte_offset_map_lock.
> @@ -2736,8 +2748,11 @@ static int do_wp_page(struct vm_fault *vmf)
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
>  			if (!pte_same(*vmf->pte, vmf->orig_pte)) {
>  				unlock_page(vmf->page);
>  				pte_unmap_unlock(vmf->pte, vmf->ptl);
> @@ -2947,8 +2962,10 @@ int do_swap_page(struct vm_fault *vmf)
>  			 * Back out if somebody else faulted in this pte
>  			 * while we released the pte lock.
>  			 */

Comment needs updating, pte_same() isn't the only reason to bail out here.

> -			vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
> -					vmf->address, &vmf->ptl);
> +			if (!pte_map_lock(vmf)) {
> +				delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> +				return VM_FAULT_RETRY;
> +			}
>  			if (likely(pte_same(*vmf->pte, vmf->orig_pte)))
>  				ret = VM_FAULT_OOM;
>  			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);

Not crucial, but it would be nice if this could do goto out instead, 
otherwise this is the first mid function return.

> @@ -3003,8 +3020,11 @@ int do_swap_page(struct vm_fault *vmf)
>  	/*
>  	 * Back out if somebody else already faulted in this pte.
>  	 */

Same as above.

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

mem_cgroup_try_charge() is done before grabbing pte_offset_map_lock(), why 
does the out_nomap exit path do mem_cgroup_cancel_charge(); 
pte_unmap_unlock()?  If the pte lock can be droppde first, there's no need 
to embed the mem_cgroup_cancel_charge() here.

> @@ -3133,8 +3153,8 @@ static int do_anonymous_page(struct vm_fault *vmf)
>  			!mm_forbids_zeropage(vma->vm_mm)) {
>  		entry = pte_mkspecial(pfn_pte(my_zero_pfn(vmf->address),
>  						vma->vm_page_prot));
> -		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
> -				vmf->address, &vmf->ptl);
> +		if (!pte_map_lock(vmf))
> +			return VM_FAULT_RETRY;
>  		if (!pte_none(*vmf->pte))
>  			goto unlock;
>  		ret = check_stable_address_space(vma->vm_mm);
> @@ -3169,8 +3189,11 @@ static int do_anonymous_page(struct vm_fault *vmf)
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

This is more spaghetti, can the exit path be fixed up so we order things 
consistently for all gotos?

> @@ -3294,8 +3317,9 @@ static int pte_alloc_one_map(struct vm_fault *vmf)
>  	 * pte_none() under vmf->ptl protection when we return to
>  	 * alloc_set_pte().
>  	 */
> -	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
> -			&vmf->ptl);
> +	if (!pte_map_lock(vmf))
> +		return VM_FAULT_RETRY;
> +
>  	return 0;
>  }
>  
