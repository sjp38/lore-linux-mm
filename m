Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 301996B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 02:18:02 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 63so10667859wrn.7
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 23:18:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y2si2228997wry.411.2018.02.25.23.18.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 25 Feb 2018 23:18:00 -0800 (PST)
Subject: Re: [v1 1/1] xen, mm: Allow deferred page initialization for xen pv
 domains
References: <20180223232538.4314-1-pasha.tatashin@oracle.com>
 <20180223232538.4314-2-pasha.tatashin@oracle.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <dda0457a-c16a-3440-a547-15f49e52ec95@suse.com>
Date: Mon, 26 Feb 2018 08:17:55 +0100
MIME-Version: 1.0
In-Reply-To: <20180223232538.4314-2-pasha.tatashin@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akataria@vmware.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, boris.ostrovsky@oracle.com, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, luto@kernel.org, labbott@redhat.com, kirill.shutemov@linux.intel.com, bp@suse.de, minipli@googlemail.com, jinb.park7@gmail.com, dan.j.williams@intel.com, bhe@redhat.com, zhang.jia@linux.alibaba.com, mgorman@techsingularity.net, hannes@cmpxchg.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org

On 24/02/18 00:25, Pavel Tatashin wrote:
> Juergen Gross noticed that commit
> f7f99100d8d ("mm: stop zeroing memory during allocation in vmemmap")
> broke XEN PV domains when deferred struct page initialization is enabled.
> 
> This is because the xen's PagePinned() flag is getting erased from struct
> pages when they are initialized later in boot.
> 
> Juergen fixed this problem by disabling deferred pages on xen pv domains.
> However, it is desirable to have this feature available, as it reduces boot
> time. This fix re-enables the feature for pv-dmains, and fixes the problem
> the following way:
> 
> The fix is to delay setting PagePinned flag until struct pages for all
> allocated memory are initialized (until free_all_bootmem()).
> 
> A new hypervisor op pv_init_ops.after_bootmem() is called to let xen know
> that boot allocator is done, and hence struct pages for all the allocated
> memory are now initialized. If deferred page initialization is enabled, the
> rest of struct pages are going to be initialized later in boot once
> page_alloc_init_late() is called.
> 
> xen_after_bootmem() is xen's implementation of pv_init_ops.after_bootmem(),
> we walk page table and mark every page as pinned.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  arch/x86/include/asm/paravirt.h       |  9 +++++++++
>  arch/x86/include/asm/paravirt_types.h |  3 +++
>  arch/x86/kernel/paravirt.c            |  1 +
>  arch/x86/mm/init_32.c                 |  1 +
>  arch/x86/mm/init_64.c                 |  1 +
>  arch/x86/xen/mmu_pv.c                 | 38 ++++++++++++++++++++++++-----------
>  mm/page_alloc.c                       |  4 ----
>  7 files changed, 41 insertions(+), 16 deletions(-)
> 
> diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
> index 9be2bf13825b..737e596a9836 100644
> --- a/arch/x86/include/asm/paravirt.h
> +++ b/arch/x86/include/asm/paravirt.h
> @@ -820,6 +820,11 @@ static inline notrace unsigned long arch_local_irq_save(void)
>  
>  extern void default_banner(void);
>  
> +static inline void paravirt_after_bootmem(void)
> +{
> +	pv_init_ops.after_bootmem();
> +}
> +

Putting this in the paravirt framework is overkill IMO. There is no need
to patch the callsites for optimal performance.

I'd put it into struct x86_hyper_init and pre-init it with x86_init_noop

>  #else  /* __ASSEMBLY__ */
>  
>  #define _PVSITE(ptype, clobbers, ops, word, algn)	\
> @@ -964,6 +969,10 @@ static inline void paravirt_arch_dup_mmap(struct mm_struct *oldmm,
>  static inline void paravirt_arch_exit_mmap(struct mm_struct *mm)
>  {
>  }
> +
> +static inline void paravirt_after_bootmem(void)
> +{
> +}
>  #endif /* __ASSEMBLY__ */
>  #endif /* !CONFIG_PARAVIRT */
>  #endif /* _ASM_X86_PARAVIRT_H */
> diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
> index 180bc0bff0fb..da78a3610168 100644
> --- a/arch/x86/include/asm/paravirt_types.h
> +++ b/arch/x86/include/asm/paravirt_types.h
> @@ -86,6 +86,9 @@ struct pv_init_ops {
>  	 */
>  	unsigned (*patch)(u8 type, u16 clobber, void *insnbuf,
>  			  unsigned long addr, unsigned len);
> +
> +	/* called right after we finish boot allocator */
> +	void (*after_bootmem)(void);
>  } __no_randomize_layout;
>  
>  
> diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
> index 99dc79e76bdc..7b5f931e2e3a 100644
> --- a/arch/x86/kernel/paravirt.c
> +++ b/arch/x86/kernel/paravirt.c
> @@ -315,6 +315,7 @@ struct pv_info pv_info = {
>  
>  struct pv_init_ops pv_init_ops = {
>  	.patch = native_patch,
> +	.after_bootmem = paravirt_nop,
>  };
>  
>  struct pv_time_ops pv_time_ops = {
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index 79cb066f40c0..6096d0d9ecbc 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -763,6 +763,7 @@ void __init mem_init(void)
>  	free_all_bootmem();
>  
>  	after_bootmem = 1;
> +	paravirt_after_bootmem();
>  
>  	mem_init_print_info(NULL);
>  	printk(KERN_INFO "virtual kernel memory layout:\n"
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 332f6e25977a..70b7b5093d07 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1189,6 +1189,7 @@ void __init mem_init(void)
>  	/* this will put all memory onto the freelists */
>  	free_all_bootmem();
>  	after_bootmem = 1;
> +	paravirt_after_bootmem();
>  
>  	/*
>  	 * Must be done after boot memory is put on freelist, because here we
> diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
> index d20763472920..603589809334 100644
> --- a/arch/x86/xen/mmu_pv.c
> +++ b/arch/x86/xen/mmu_pv.c
> @@ -116,6 +116,8 @@ DEFINE_PER_CPU(unsigned long, xen_current_cr3);	 /* actual vcpu cr3 */
>  
>  static phys_addr_t xen_pt_base, xen_pt_size __initdata;
>  
> +static DEFINE_STATIC_KEY_FALSE(xen_struct_pages_ready);
> +
>  /*
>   * Just beyond the highest usermode address.  STACK_TOP_MAX has a
>   * redzone above it, so round it up to a PGD boundary.
> @@ -155,11 +157,18 @@ void make_lowmem_page_readwrite(void *vaddr)
>  }
>  
>  
> +/*
> + * During early boot all pages are pinned, but we do not have struct pages,
> + * so return true until struct pages are ready.
> + */

Uuh, this comment is just not true.

The "pinned" state for Xen means it is a pv pagetable known to Xen. Such
pages are read-only for the guest and can be modified via hypercalls
only.

So either the "pinned" state will be tested for page tables only, in
which case the comment needs adjustment, or the code is wrong.


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
