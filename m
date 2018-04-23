Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 801186B0007
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 06:52:47 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id i127so6290223pgc.22
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 03:52:47 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0107.outbound.protection.outlook.com. [104.47.0.107])
        by mx.google.com with ESMTPS id a90-v6si11557565plc.160.2018.04.23.03.52.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 03:52:46 -0700 (PDT)
Date: Mon, 23 Apr 2018 13:51:38 +0300
From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: Re: [PATCH 2/5] x86, pti: fix boot warning from Global-bit setting
Message-ID: <20180423105138.GB16237@ak-laptop.emea.nsn-net.net>
References: <20180420222018.E7646EE1@viggo.jf.intel.com>
 <20180420222021.1C7D2B3F@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180420222021.1C7D2B3F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mceier@gmail.com, aarcange@redhat.com, luto@kernel.org, arjan@linux.intel.com, bp@alien8.de, dan.j.williams@intel.com, dwmw2@infradead.org, gregkh@linuxfoundation.org, hughd@google.com, jpoimboe@redhat.com, jgross@suse.com, keescook@google.com, torvalds@linux-foundation.org, namit@vmware.com, peterz@infradead.org, tglx@linutronix.de

Hi,

On Fri, Apr 20, 2018 at 03:20:21PM -0700, Dave Hansen wrote:
> The pageattr.c code attempts to process "faults" when it goes looking
> for PTEs to change and finds non-present entries.  It allows these
> faults in the linear map which is "expected to have holes", but
> WARN()s about them elsewhere, like when called on the kernel image.
> 
> However, we are now calling change_page_attr_clear() on the kernel
> image in the process of trying to clear the Global bit.
> 
> This trips the warning in __cpa_process_fault() if a non-present PTE is
> encountered in the kernel image.  The "holes" in the kernel image
> result from free_init_pages()'s use of set_memory_np().  These holes
> are totally fine, and result from normal operation, just as they would
> be in the kernel linear map.
> 
> Just silence the warning when holes in the kernel image are encountered.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Fixes: 39114b7a7 (x86/pti: Never implicitly clear _PAGE_GLOBAL for kernel image)
> Reported-by: Mariusz Ceier <mceier@gmail.com>
> Reported-by: Aaro Koskinen <aaro.koskinen@nokia.com>

Tested-by: Aaro Koskinen <aaro.koskinen@nokia.com>

A.

> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Arjan van de Ven <arjan@linux.intel.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: David Woodhouse <dwmw2@infradead.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Josh Poimboeuf <jpoimboe@redhat.com>
> Cc: Juergen Gross <jgross@suse.com>
> Cc: Kees Cook <keescook@google.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Nadav Amit <namit@vmware.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: linux-mm@kvack.org
> ---
> 
>  b/arch/x86/mm/pageattr.c |   41 +++++++++++++++++++++++++++++++----------
>  1 file changed, 31 insertions(+), 10 deletions(-)
> 
> diff -puN arch/x86/mm/pageattr.c~pti-glb-warning-inpageattr arch/x86/mm/pageattr.c
> --- a/arch/x86/mm/pageattr.c~pti-glb-warning-inpageattr	2018-04-20 14:10:01.619749168 -0700
> +++ b/arch/x86/mm/pageattr.c	2018-04-20 14:10:01.623749168 -0700
> @@ -93,6 +93,18 @@ void arch_report_meminfo(struct seq_file
>  static inline void split_page_count(int level) { }
>  #endif
>  
> +static inline int
> +within(unsigned long addr, unsigned long start, unsigned long end)
> +{
> +	return addr >= start && addr < end;
> +}
> +
> +static inline int
> +within_inclusive(unsigned long addr, unsigned long start, unsigned long end)
> +{
> +	return addr >= start && addr <= end;
> +}
> +
>  #ifdef CONFIG_X86_64
>  
>  static inline unsigned long highmap_start_pfn(void)
> @@ -106,20 +118,26 @@ static inline unsigned long highmap_end_
>  	return __pa_symbol(roundup(_brk_end, PMD_SIZE) - 1) >> PAGE_SHIFT;
>  }
>  
> -#endif
> -
> -static inline int
> -within(unsigned long addr, unsigned long start, unsigned long end)
> +static bool __cpa_pfn_in_highmap(unsigned long pfn)
>  {
> -	return addr >= start && addr < end;
> +	/*
> +	 * Kernel text has an alias mapping at a high address, known
> +	 * here as "highmap".
> +	 */
> +	return within_inclusive(pfn, highmap_start_pfn(),
> +			highmap_end_pfn());
>  }
>  
> -static inline int
> -within_inclusive(unsigned long addr, unsigned long start, unsigned long end)
> +#else
> +
> +static bool __cpa_pfn_in_highmap(unsigned long pfn)
>  {
> -	return addr >= start && addr <= end;
> +	/* There is no highmap on 32-bit */
> +	return false;
>  }
>  
> +#endif
> +
>  /*
>   * Flushing functions
>   */
> @@ -1183,6 +1201,10 @@ static int __cpa_process_fault(struct cp
>  		cpa->numpages = 1;
>  		cpa->pfn = __pa(vaddr) >> PAGE_SHIFT;
>  		return 0;
> +
> +	} else if (__cpa_pfn_in_highmap(cpa->pfn)) {
> +		/* Faults in the highmap are OK, so do not warn: */
> +		return -EFAULT;
>  	} else {
>  		WARN(1, KERN_WARNING "CPA: called for zero pte. "
>  			"vaddr = %lx cpa->vaddr = %lx\n", vaddr,
> @@ -1335,8 +1357,7 @@ static int cpa_process_alias(struct cpa_
>  	 * to touch the high mapped kernel as well:
>  	 */
>  	if (!within(vaddr, (unsigned long)_text, _brk_end) &&
> -	    within_inclusive(cpa->pfn, highmap_start_pfn(),
> -			     highmap_end_pfn())) {
> +	    __cpa_pfn_in_highmap(cpa->pfn)) {
>  		unsigned long temp_cpa_vaddr = (cpa->pfn << PAGE_SHIFT) +
>  					       __START_KERNEL_map - phys_base;
>  		alias_cpa = *cpa;
> _
