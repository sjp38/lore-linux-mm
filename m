Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 41F886B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 08:47:12 -0400 (EDT)
Received: by wiun10 with SMTP id n10so96570107wiu.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 05:47:11 -0700 (PDT)
Received: from smarthost01d.mail.zen.net.uk (smarthost01d.mail.zen.net.uk. [212.23.1.7])
        by mx.google.com with ESMTP id fp9si23982300wib.116.2015.04.09.05.47.10
        for <linux-mm@kvack.org>;
        Thu, 09 Apr 2015 05:47:11 -0700 (PDT)
Message-ID: <552674C8.7010104@cantab.net>
Date: Thu, 09 Apr 2015 13:47:04 +0100
From: David Vrabel <dvrabel@cantab.net>
MIME-Version: 1.0
References: <1428562542-28488-1-git-send-email-jgross@suse.com> <1428562542-28488-11-git-send-email-jgross@suse.com>
In-Reply-To: <1428562542-28488-11-git-send-email-jgross@suse.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Subject: Re: [Xen-devel] [Patch V2 10/15] xen: check pre-allocated page tables
 for conflict with memory map
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org

On 09/04/2015 07:55, Juergen Gross wrote:
> Check whether the page tables built by the domain builder are at
> memory addresses which are in conflict with the target memory map.
> If this is the case just panic instead of running into problems
> later.
> 
> Signed-off-by: Juergen Gross <jgross@suse.com>
> ---
>  arch/x86/xen/mmu.c     | 19 ++++++++++++++++---
>  arch/x86/xen/setup.c   |  6 ++++++
>  arch/x86/xen/xen-ops.h |  1 +
>  3 files changed, 23 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
> index 1ca5197..41aeb1c 100644
> --- a/arch/x86/xen/mmu.c
> +++ b/arch/x86/xen/mmu.c
> @@ -116,6 +116,7 @@ static pud_t level3_user_vsyscall[PTRS_PER_PUD] __page_aligned_bss;
>  DEFINE_PER_CPU(unsigned long, xen_cr3);	 /* cr3 stored as physaddr */
>  DEFINE_PER_CPU(unsigned long, xen_current_cr3);	 /* actual vcpu cr3 */
>  
> +static phys_addr_t xen_pt_base, xen_pt_size;

These be __init, but the use of globals in this way is confusing.

>  
>  /*
>   * Just beyond the highest usermode address.  STACK_TOP_MAX has a
> @@ -1998,7 +1999,9 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
>  		check_pt_base(&pt_base, &pt_end, addr[i]);
>  
>  	/* Our (by three pages) smaller Xen pagetable that we are using */
> -	memblock_reserve(PFN_PHYS(pt_base), (pt_end - pt_base) * PAGE_SIZE);
> +	xen_pt_base = PFN_PHYS(pt_base);
> +	xen_pt_size = (pt_end - pt_base) * PAGE_SIZE;
> +	memblock_reserve(xen_pt_base, xen_pt_size);

Why not provide a xen_memblock_check_and_reserve() call that has the
xen_is_e820_reserved() check and the memblock_reserve() call?  This may
also be useful for patch #9 as well.

> +void __init xen_pt_check_e820(void)
> +{
> +	if (xen_chk_e820_reserved(xen_pt_base, xen_pt_size)) {
> +		xen_raw_console_write("Xen hypervisor allocated page table memory conflicts with E820 map\n");
> +		BUG();
> +	}
> +}
> +
>  static unsigned char dummy_mapping[PAGE_SIZE] __page_aligned_bss;

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
