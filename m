Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 428D06B0008
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 17:39:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i127so8782345pgc.22
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 14:39:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4-v6sor7175194plr.96.2018.03.26.14.39.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 14:39:20 -0700 (PDT)
Date: Mon, 26 Mar 2018 14:39:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 24/24] powerpc/mm: Add speculative page fault
In-Reply-To: <1520963994-28477-25-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1803261431330.255554@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-25-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 13 Mar 2018, Laurent Dufour wrote:

> diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
> index 866446cf2d9a..104f3cc86b51 100644
> --- a/arch/powerpc/mm/fault.c
> +++ b/arch/powerpc/mm/fault.c
> @@ -392,6 +392,9 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
>  			   unsigned long error_code)
>  {
>  	struct vm_area_struct * vma;
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	struct vm_area_struct *spf_vma = NULL;
> +#endif
>  	struct mm_struct *mm = current->mm;
>  	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
>   	int is_exec = TRAP(regs) == 0x400;
> @@ -459,6 +462,20 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
>  	if (is_exec)
>  		flags |= FAULT_FLAG_INSTRUCTION;
>  
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	if (is_user && (atomic_read(&mm->mm_users) > 1)) {
> +		/* let's try a speculative page fault without grabbing the
> +		 * mmap_sem.
> +		 */
> +		fault = handle_speculative_fault(mm, address, flags, &spf_vma);
> +		if (!(fault & VM_FAULT_RETRY)) {
> +			perf_sw_event(PERF_COUNT_SW_SPF, 1,
> +				      regs, address);
> +			goto done;
> +		}
> +	}
> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
> +

Can't you elimiate all #ifdef's in this patch if 
handle_speculative_fault() can be passed is_user and return some error 
code that fallback is needed?  Maybe reuse VM_FAULT_FALLBACK?

>  	/* When running in the kernel we expect faults to occur only to
>  	 * addresses in user space.  All other faults represent errors in the
>  	 * kernel and should generate an OOPS.  Unfortunately, in the case of an
> @@ -489,7 +506,16 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
>  		might_sleep();
>  	}
>  
> -	vma = find_vma(mm, address);
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	if (spf_vma) {
> +		if (can_reuse_spf_vma(spf_vma, address))
> +			vma = spf_vma;
> +		else
> +			vma =  find_vma(mm, address);
> +		spf_vma = NULL;
> +	} else
> +#endif
> +		vma = find_vma(mm, address);
>  	if (unlikely(!vma))
>  		return bad_area(regs, address);
>  	if (likely(vma->vm_start <= address))

I think the code quality here could be improved such that you can pass mm, 
&spf_vma, and address and some helper function would return spf_vma if 
can_reuse_spf_vma() is true (and do *spf_vma to NULL) or otherwise return 
find_vma(mm, address).

Also, spf_vma is being set to NULL because of VM_FAULT_RETRY, but does it 
make sense to retry handle_speculative_fault() in this case since we've 
dropped mm->mmap_sem and there may have been a writer queued behind it?

> @@ -568,6 +594,9 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
>  
>  	up_read(&current->mm->mmap_sem);
>  
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +done:
> +#endif
>  	if (unlikely(fault & VM_FAULT_ERROR))
>  		return mm_fault_error(regs, address, fault);
>  

And things like this are trivially handled by doing

done: __maybe_unused
