Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4D55D6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 22:56:03 -0500 (EST)
Received: by yxe10 with SMTP id 10so3555964yxe.12
        for <linux-mm@kvack.org>; Fri, 18 Dec 2009 19:56:01 -0800 (PST)
Message-ID: <4B2C4EC9.9040101@gmail.com>
Date: Sat, 19 Dec 2009 12:55:53 +0900
From: Minchan Kim <minchan.kim@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 4/4] speculative pag fault
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>	<20091216101107.GA15031@basil.fritz.box>	<20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>	<20091216102806.GC15031@basil.fritz.box>	<28c262360912160231r18db8478sf41349362360cab8@mail.gmail.com>	<20091216193315.14a508d5.kamezawa.hiroyu@jp.fujitsu.com>	<20091218093849.8ba69ad9.kamezawa.hiroyu@jp.fujitsu.com> <20091218094602.3dcd5a02.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091218094602.3dcd5a02.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



KAMEZAWA Hiroyuki wrote:
> Lookup vma in lockless style, do page fault, and check mm's version
> after takine page table lock. If racy, mm's version is invalid .
> Then, retry page fault.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  arch/x86/mm/fault.c |   28 +++++++++++++++++++++++++---
>  mm/memory.c         |   21 ++++++++++++++-------
>  2 files changed, 39 insertions(+), 10 deletions(-)
> 
> Index: mmotm-mm-accessor/arch/x86/mm/fault.c
> ===================================================================
> --- mmotm-mm-accessor.orig/arch/x86/mm/fault.c
> +++ mmotm-mm-accessor/arch/x86/mm/fault.c
> @@ -11,6 +11,7 @@
>  #include <linux/kprobes.h>		/* __kprobes, ...		*/
>  #include <linux/mmiotrace.h>		/* kmmio_handler, ...		*/
>  #include <linux/perf_event.h>		/* perf_sw_event		*/
> +#include <linux/hugetlb.h>		/* is_vm_hugetlb...*/

De we need this header file?

>  
>  #include <asm/traps.h>			/* dotraplinkage, ...		*/
>  #include <asm/pgalloc.h>		/* pgd_*(), ...			*/
> @@ -952,6 +953,7 @@ do_page_fault(struct pt_regs *regs, unsi
>  	struct mm_struct *mm;
>  	int write;
>  	int fault;
> +	int speculative;
>  
>  	tsk = current;
>  	mm = tsk->mm;
> @@ -1040,6 +1042,17 @@ do_page_fault(struct pt_regs *regs, unsi
>  		return;
>  	}
>  
> +	if ((error_code & PF_USER) && mm_version_check(mm)) {
> +		vma = lookup_vma_cache(mm, address);
> +		if (vma && mm_version_check(mm) &&
> +		   (vma->vm_start <= address) && (address < vma->vm_end)) {
> +			speculative = 1;
> +			goto found_vma;
> +		}
> +		if (vma)
> +			vma_release(vma);
> +	}
> +
>  	/*
>  	 * When running in the kernel we expect faults to occur only to
>  	 * addresses in user space.  All other faults represent errors in
> @@ -1056,6 +1069,8 @@ do_page_fault(struct pt_regs *regs, unsi
>  	 * validate the source. If this is invalid we can skip the address
>  	 * space check, thus avoiding the deadlock:
>  	 */
> +retry_with_lock:
> +	speculative = 0;
>  	if (unlikely(!mm_read_trylock(mm))) {
>  		if ((error_code & PF_USER) == 0 &&
>  		    !search_exception_tables(regs->ip)) {
> @@ -1073,6 +1088,7 @@ do_page_fault(struct pt_regs *regs, unsi
>  	}
>  
>  	vma = find_vma(mm, address);
> +found_vma:
>  	if (unlikely(!vma)) {
>  		bad_area(regs, error_code, address);
>  		return;
> @@ -1119,6 +1135,7 @@ good_area:
>  	 */
>  	fault = handle_mm_fault(mm, vma, address, write ? FAULT_FLAG_WRITE : 0);
>  
> +
>  	if (unlikely(fault & VM_FAULT_ERROR)) {
>  		mm_fault_error(regs, error_code, address, fault);
>  		return;
> @@ -1128,13 +1145,18 @@ good_area:
>  		tsk->maj_flt++;
>  		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MAJ, 1, 0,
>  				     regs, address);
> -	} else {
> +	} else if (!speculative || mm_version_check(mm)) {

How about define VM_FAULT_FAIL_SPECULATIVE_VMACACHE 
although mm guys don't like new VM_FAULT_XXX?

It would remove double check of mm_version_check. :)

It's another topic. 
How about counting failure of speculative easily and expose it in perf or statm.
During we can step into mainline, it helps our test case is good, I think.

>  		tsk->min_flt++;
>  		perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS_MIN, 1, 0,
>  				     regs, address);
> +	} else {
> +		vma_release(vma);
> +		goto retry_with_lock;
>  	}
>  
>  	check_v8086_mode(regs, address, tsk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
