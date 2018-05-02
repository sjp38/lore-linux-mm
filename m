Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2A696B0006
	for <linux-mm@kvack.org>; Wed,  2 May 2018 05:07:17 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t130so10480366qke.11
        for <linux-mm@kvack.org>; Wed, 02 May 2018 02:07:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w36-v6si1174712qtb.19.2018.05.02.02.07.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 02:07:16 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4292P1v143489
	for <linux-mm@kvack.org>; Wed, 2 May 2018 05:07:15 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hq8wskw0g-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 02 May 2018 05:07:15 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 2 May 2018 10:07:12 +0100
Subject: Re: [PATCH 2/2] arm64/mm: add speculative page fault
References: <1525247672-2165-1-git-send-email-opensource.ganesh@gmail.com>
 <1525247672-2165-2-git-send-email-opensource.ganesh@gmail.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 2 May 2018 11:07:08 +0200
MIME-Version: 1.0
In-Reply-To: <1525247672-2165-2-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <9e7ab02c-a9af-71ed-afda-108e3b26b2ef@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>, catalin.marinas@arm.com, will.deacon@arm.com
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Punit Agrawal <punitagrawal@gmail.com>

On 02/05/2018 09:54, Ganesh Mahendran wrote:
> This patch enables the speculative page fault on the arm64
> architecture.
> 
> I completed spf porting in 4.9. From the test result,
> we can see app launching time improved by about 10% in average.
> For the apps which have more than 50 threads, 15% or even more
> improvement can be got.

Thanks Ganesh,

That's a great improvement, could you please provide details about the apps and
the hardware you used ?

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
>  	vma = find_vma(mm, addr);
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

As suggested by Punit in his v10's review, the test on
CONFIG_SPECULATIVE_PAGE_FAULT is not needed as handle_speculative_fault() is
defined to return VM_FAULT_RETRY is the config is not set.

> +		fault = handle_speculative_fault(mm, addr, mm_flags, &vma);
> +		/*
> +		 * Page fault is done if VM_FAULT_RETRY is not returned.
> +		 * But if the memory protection keys are active, we don't know
> +		 * if the fault is due to key mistmatch or due to a
> +		 * classic protection check.
> +		 * To differentiate that, we will need the VMA we no
> +		 * more have, so let's retry with the mmap_sem held.
> +		 */

The check of VM_FAULT_SIGSEGV was needed on ppc64 because of the memory
protection key support, but as far as I know, this is not the case on arm64.
Isn't it ?

> +		if (fault != VM_FAULT_RETRY &&
> +			 fault != VM_FAULT_SIGSEGV) {
> +			perf_sw_event(PERF_COUNT_SW_SPF, 1, regs, addr);
> +			goto done;
> +		}
> +	} else {
> +		vma = NULL;
> +	}
> +
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
> 
