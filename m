Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4E56F6B0008
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 19:12:25 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f3-v6so7006486plf.1
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 16:12:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e91-v6sor643552plb.133.2018.04.02.16.12.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 16:12:24 -0700 (PDT)
Date: Mon, 2 Apr 2018 16:12:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 14/24] mm: Introduce __maybe_mkwrite()
In-Reply-To: <1520963994-28477-15-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1804021611590.102694@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-15-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 13 Mar 2018, Laurent Dufour wrote:

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index dfa81a638b7c..a84ddc218bbd 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -684,13 +684,18 @@ void free_compound_page(struct page *page);
>   * pte_mkwrite.  But get_user_pages can cause write faults for mappings
>   * that do not have writing enabled, when used by access_process_vm.
>   */
> -static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
> +static inline pte_t __maybe_mkwrite(pte_t pte, unsigned long vma_flags)
>  {
> -	if (likely(vma->vm_flags & VM_WRITE))
> +	if (likely(vma_flags & VM_WRITE))
>  		pte = pte_mkwrite(pte);
>  	return pte;
>  }
>  
> +static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
> +{
> +	return __maybe_mkwrite(pte, vma->vm_flags);
> +}
> +
>  int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
>  		struct page *page);
>  int finish_fault(struct vm_fault *vmf);
> diff --git a/mm/memory.c b/mm/memory.c
> index 0a0a483d9a65..af0338fbc34d 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2472,7 +2472,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
>  
>  	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
>  	entry = pte_mkyoung(vmf->orig_pte);
> -	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +	entry = __maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
>  	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
>  		update_mmu_cache(vma, vmf->address, vmf->pte);
>  	pte_unmap_unlock(vmf->pte, vmf->ptl);
> @@ -2549,8 +2549,8 @@ static int wp_page_copy(struct vm_fault *vmf)
>  			inc_mm_counter_fast(mm, MM_ANONPAGES);
>  		}
>  		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
> -		entry = mk_pte(new_page, vma->vm_page_prot);
> -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		entry = mk_pte(new_page, vmf->vma_page_prot);
> +		entry = __maybe_mkwrite(pte_mkdirty(entry), vmf->vma_flags);
>  		/*
>  		 * Clear the pte entry and flush it first, before updating the
>  		 * pte with the new entry. This will avoid a race condition

Don't you also need to do this in do_swap_page()?

diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3067,9 +3067,9 @@ int do_swap_page(struct vm_fault *vmf)
 
 	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
-	pte = mk_pte(page, vma->vm_page_prot);
+	pte = mk_pte(page, vmf->vma_page_prot);
 	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
-		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		pte = __maybe_mkwrite(pte_mkdirty(pte), vmf->vma_flags);
 		vmf->flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = RMAP_EXCLUSIVE;
