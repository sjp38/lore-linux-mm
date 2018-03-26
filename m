Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7C06B000D
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 17:41:26 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v8so10081347pgs.9
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 14:41:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32-v6sor7124924plb.6.2018.03.26.14.41.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 14:41:25 -0700 (PDT)
Date: Mon, 26 Mar 2018 14:41:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 23/24] x86/mm: Add speculative pagefault handling
In-Reply-To: <1520963994-28477-24-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1803261440130.255554@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-24-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 13 Mar 2018, Laurent Dufour wrote:

> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index e6af2b464c3d..a73cf227edd6 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1239,6 +1239,9 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>  		unsigned long address)
>  {
>  	struct vm_area_struct *vma;
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	struct vm_area_struct *spf_vma = NULL;
> +#endif
>  	struct task_struct *tsk;
>  	struct mm_struct *mm;
>  	int fault, major = 0;
> @@ -1332,6 +1335,27 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>  	if (error_code & X86_PF_INSTR)
>  		flags |= FAULT_FLAG_INSTRUCTION;
>  
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	if ((error_code & X86_PF_USER) && (atomic_read(&mm->mm_users) > 1)) {
> +		fault = handle_speculative_fault(mm, address, flags,
> +						 &spf_vma);
> +
> +		if (!(fault & VM_FAULT_RETRY)) {
> +			if (!(fault & VM_FAULT_ERROR)) {
> +				perf_sw_event(PERF_COUNT_SW_SPF, 1,
> +					      regs, address);
> +				goto done;
> +			}
> +			/*
> +			 * In case of error we need the pkey value, but
> +			 * can't get it from the spf_vma as it is only returned
> +			 * when VM_FAULT_RETRY is returned. So we have to
> +			 * retry the page fault with the mmap_sem grabbed.
> +			 */
> +		}
> +	}
> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */

All the comments from the powerpc version will apply here as well, the 
only interesting point is whether VM_FAULT_FALLBACK can be returned from 
handle_speculative_fault() to indicate its not possible.

> +
>  	/*
>  	 * When running in the kernel we expect faults to occur only to
>  	 * addresses in user space.  All other faults represent errors in
> @@ -1365,7 +1389,16 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>  		might_sleep();
>  	}
>  
> -	vma = find_vma(mm, address);
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +	if (spf_vma) {
> +		if (can_reuse_spf_vma(spf_vma, address))
> +			vma = spf_vma;
> +		else
> +			vma = find_vma(mm, address);
> +		spf_vma = NULL;
> +	} else
> +#endif
> +		vma = find_vma(mm, address);
>  	if (unlikely(!vma)) {
>  		bad_area(regs, error_code, address);
>  		return;
> @@ -1451,6 +1484,9 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
>  		return;
>  	}
>  
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +done:
> +#endif
>  	/*
>  	 * Major/minor page fault accounting. If any of the events
>  	 * returned VM_FAULT_MAJOR, we account it as a major fault.
