Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA79280310
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 02:59:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z96so18881094wrb.5
        for <linux-mm@kvack.org>; Sun, 20 Aug 2017 23:59:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i125si5419404wmd.70.2017.08.20.23.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Aug 2017 23:59:01 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7L6wYgU138143
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 02:59:00 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2cfjca39hc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 02:59:00 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 21 Aug 2017 16:58:57 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v7L6wtrU40042730
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 16:58:55 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v7L6wsRu007917
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 16:58:55 +1000
Subject: Re: [PATCH v2 20/20] powerpc/mm: Add speculative page fault
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-21-git-send-email-ldufour@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 21 Aug 2017 12:28:46 +0530
MIME-Version: 1.0
In-Reply-To: <1503007519-26777-21-git-send-email-ldufour@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <ebe69178-2e8b-a5b9-6268-08b82f476021@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 08/18/2017 03:35 AM, Laurent Dufour wrote:
> This patch enable the speculative page fault on the PowerPC
> architecture.
> 
> This will try a speculative page fault without holding the mmap_sem,
> if it returns with WM_FAULT_RETRY, the mmap_sem is acquired and the

s/WM_FAULT_RETRY/VM_FAULT_RETRY/

> traditional page fault processing is done.
> 
> Support is only provide for BOOK3S_64 currently because:
> - require CONFIG_PPC_STD_MMU because checks done in
>   set_access_flags_filter()

What checks are done in set_access_flags_filter() ? We are just
adding the code block in do_page_fault().


> - require BOOK3S because we can't support for book3e_hugetlb_preload()
>   called by update_mmu_cache()
> 
> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/pgtable.h |  5 +++++
>  arch/powerpc/mm/fault.c                      | 30 +++++++++++++++++++++++++++-
>  2 files changed, 34 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index 818a58fc3f4f..897f8b9f67e6 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -313,6 +313,11 @@ extern unsigned long pci_io_base;
>  /* Advertise support for _PAGE_SPECIAL */
>  #define __HAVE_ARCH_PTE_SPECIAL
>  
> +/* Advertise that we call the Speculative Page Fault handler */
> +#if defined(CONFIG_PPC_BOOK3S_64)
> +#define __HAVE_ARCH_CALL_SPF
> +#endif
> +
>  #ifndef __ASSEMBLY__
>  
>  /*
> diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
> index 4c422632047b..7b3cc4c30eab 100644
> --- a/arch/powerpc/mm/fault.c
> +++ b/arch/powerpc/mm/fault.c
> @@ -291,9 +291,36 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
>  	if (is_write && is_user)
>  		store_update_sp = store_updates_sp(regs);
>  
> -	if (is_user)
> +	if (is_user) {
>  		flags |= FAULT_FLAG_USER;
>  
> +#if defined(__HAVE_ARCH_CALL_SPF)
> +		/* let's try a speculative page fault without grabbing the
> +		 * mmap_sem.
> +		 */
> +
> +		/*
> +		 * flags is set later based on the VMA's flags, for the common
> +		 * speculative service, we need some flags to be set.
> +		 */
> +		if (is_write)
> +			flags |= FAULT_FLAG_WRITE;
> +
> +		fault = handle_speculative_fault(mm, address, flags);
> +		if (!(fault & VM_FAULT_RETRY || fault & VM_FAULT_ERROR)) {
> +			perf_sw_event(PERF_COUNT_SW_SPF_DONE, 1,
> +				      regs, address);
> +			goto done;

Why we should retry with classical page fault on VM_FAULT_ERROR ?
We should always return VM_FAULT_RETRY in case there is a clear
collision some where which requires retry with classical method
and return VM_FAULT_ERROR in cases where we know that it cannot
be retried and fail for good. Should not handle_speculative_fault()
be changed to accommodate this ?

> +		}
> +
> +		/*
> +		 * Resetting flags since the following code assumes
> +		 * FAULT_FLAG_WRITE is not set.
> +		 */
> +		flags &= ~FAULT_FLAG_WRITE;
> +#endif /* defined(__HAVE_ARCH_CALL_SPF) */

Setting and resetting of FAULT_FLAG_WRITE seems confusing. Why you
say that some flags need to be set for handle_speculative_fault()
function. Could you elaborate on this ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
