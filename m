Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 45CCB6B0006
	for <linux-mm@kvack.org>; Wed,  2 May 2018 10:46:06 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id v40-v6so7172988ote.0
        for <linux-mm@kvack.org>; Wed, 02 May 2018 07:46:06 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r32-v6si4260934ota.40.2018.05.02.07.46.04
        for <linux-mm@kvack.org>;
        Wed, 02 May 2018 07:46:04 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH 2/2] arm64/mm: add speculative page fault
References: <1525247672-2165-1-git-send-email-opensource.ganesh@gmail.com>
	<1525247672-2165-2-git-send-email-opensource.ganesh@gmail.com>
Date: Wed, 02 May 2018 15:46:02 +0100
In-Reply-To: <1525247672-2165-2-git-send-email-opensource.ganesh@gmail.com>
	(Ganesh Mahendran's message of "Wed, 2 May 2018 15:54:32 +0800")
Message-ID: <871seunmj9.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: ldufour@linux.vnet.ibm.com, catalin.marinas@arm.com, will.deacon@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Ganesh,

I was looking at evaluating speculative page fault handling on arm64 and
noticed your patch.

Some comments below -

Ganesh Mahendran <opensource.ganesh@gmail.com> writes:

> This patch enables the speculative page fault on the arm64
> architecture.
>
> I completed spf porting in 4.9. From the test result,
> we can see app launching time improved by about 10% in average.
> For the apps which have more than 50 threads, 15% or even more
> improvement can be got.
>
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ---
> This patch is on top of Laurent's v10 spf
> ---
>  arch/arm64/mm/fault.c | 38 +++++++++++++++++++++++++++++++++++---
>  1 file changed, 35 insertions(+), 3 deletions(-)
>
> diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
> index 4165485..e7992a3 100644
> --- a/arch/arm64/mm/fault.c
> +++ b/arch/arm64/mm/fault.c
> @@ -322,11 +322,13 @@ static void do_bad_area(unsigned long addr, unsigned int esr, struct pt_regs *re
>  
>  static int __do_page_fault(struct mm_struct *mm, unsigned long addr,
>  			   unsigned int mm_flags, unsigned long vm_flags,
> -			   struct task_struct *tsk)
> +			   struct task_struct *tsk, struct vm_area_struct *vma)
>  {
> -	struct vm_area_struct *vma;
>  	int fault;
>  
> +	if (!vma || !can_reuse_spf_vma(vma, addr))
> +		vma = find_vma(mm, addr);
> +

It would be better to move this hunk to do_page_fault().

It'll help localise the fact that handle_speculative_fault() is a
stateful call which needs a corresponding can_reuse_spf_vma() to
properly update the vma reference counting.


>  	vma = find_vma(mm, addr);

Remember to drop this call in the next version. As it stands the call
the find_vma() needlessly gets duplicated.

>  	fault = VM_FAULT_BADMAP;
>  	if (unlikely(!vma))
> @@ -371,6 +373,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>  	int fault, major = 0;
>  	unsigned long vm_flags = VM_READ | VM_WRITE;
>  	unsigned int mm_flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
> +	struct vm_area_struct *vma;
>  
>  	if (notify_page_fault(regs, esr))
>  		return 0;
> @@ -409,6 +412,25 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>  
>  	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, addr);
>  
> +	if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT)) {

You don't need the IS_ENABLED() check. The alternate implementation of
handle_speculative_fault() when CONFIG_SPECULATIVE_PAGE_FAULT is not
enabled takes care of this.

> +		fault = handle_speculative_fault(mm, addr, mm_flags, &vma);
> +		/*
> +		 * Page fault is done if VM_FAULT_RETRY is not returned.
> +		 * But if the memory protection keys are active, we don't know
> +		 * if the fault is due to key mistmatch or due to a
> +		 * classic protection check.
> +		 * To differentiate that, we will need the VMA we no
> +		 * more have, so let's retry with the mmap_sem held.
> +		 */

As there is no support for memory protection keys on arm64 most of this
comment can be dropped.

> +		if (fault != VM_FAULT_RETRY &&
> +			 fault != VM_FAULT_SIGSEGV) {

Not sure if you need the VM_FAULT_SIGSEGV here.

> +			perf_sw_event(PERF_COUNT_SW_SPF, 1, regs, addr);
> +			goto done;
> +		}
> +	} else {
> +		vma = NULL;
> +	}
> +

If vma is initiliased to NULL during declaration, the else part can be
dropped.

>  	/*
>  	 * As per x86, we may deadlock here. However, since the kernel only
>  	 * validly references user space from well defined areas of the code,
> @@ -431,7 +453,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>  #endif
>  	}
>  
> -	fault = __do_page_fault(mm, addr, mm_flags, vm_flags, tsk);
> +	fault = __do_page_fault(mm, addr, mm_flags, vm_flags, tsk, vma);
>  	major |= fault & VM_FAULT_MAJOR;
>  
>  	if (fault & VM_FAULT_RETRY) {
> @@ -454,11 +476,21 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
>  		if (mm_flags & FAULT_FLAG_ALLOW_RETRY) {
>  			mm_flags &= ~FAULT_FLAG_ALLOW_RETRY;
>  			mm_flags |= FAULT_FLAG_TRIED;
> +
> +			/*
> +			 * Do not try to reuse this vma and fetch it
> +			 * again since we will release the mmap_sem.
> +			 */
> +			if (IS_ENABLED(CONFIG_SPECULATIVE_PAGE_FAULT))
> +				vma = NULL;

Please drop the IS_ENABLED() check.

Thanks,
Punit

> +
>  			goto retry;
>  		}
>  	}
>  	up_read(&mm->mmap_sem);
>  
> +done:
> +
>  	/*
>  	 * Handle the "normal" (no error) case first.
>  	 */
