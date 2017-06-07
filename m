Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA4386B02F3
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 18:07:31 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id p77so7058188ioe.11
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 15:07:31 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f73si3821225itf.0.2017.06.07.15.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 15:07:30 -0700 (PDT)
Subject: Re: [PATCH v6 10/34] x86, x86/mm, x86/xen, olpc: Use __va() against
 just the physical address in cr3
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191453.28645.92256.stgit@tlendack-t1.amdoffice.net>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <b15e8924-4069-b5fa-adb2-86c164b1dd36@oracle.com>
Date: Wed, 7 Jun 2017 18:06:50 -0400
MIME-Version: 1.0
In-Reply-To: <20170607191453.28645.92256.stgit@tlendack-t1.amdoffice.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, xen-devel <xen-devel@lists.xen.org>

On 06/07/2017 03:14 PM, Tom Lendacky wrote:
> The cr3 register entry can contain the SME encryption bit that indicates
> the PGD is encrypted.  The encryption bit should not be used when creating
> a virtual address for the PGD table.
>
> Create a new function, read_cr3_pa(), that will extract the physical
> address from the cr3 register. This function is then used where a virtual
> address of the PGD needs to be created/used from the cr3 register.
>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/special_insns.h |    9 +++++++++
>  arch/x86/kernel/head64.c             |    2 +-
>  arch/x86/mm/fault.c                  |   10 +++++-----
>  arch/x86/mm/ioremap.c                |    2 +-
>  arch/x86/platform/olpc/olpc-xo1-pm.c |    2 +-
>  arch/x86/power/hibernate_64.c        |    2 +-
>  arch/x86/xen/mmu_pv.c                |    6 +++---
>  7 files changed, 21 insertions(+), 12 deletions(-)
>
> diff --git a/arch/x86/include/asm/special_insns.h b/arch/x86/include/asm/special_insns.h
> index 12af3e3..d8e8ace 100644
> --- a/arch/x86/include/asm/special_insns.h
> +++ b/arch/x86/include/asm/special_insns.h
> @@ -234,6 +234,15 @@ static inline void clwb(volatile void *__p)
>  
>  #define nop() asm volatile ("nop")
>  
> +static inline unsigned long native_read_cr3_pa(void)
> +{
> +	return (native_read_cr3() & PHYSICAL_PAGE_MASK);
> +}
> +
> +static inline unsigned long read_cr3_pa(void)
> +{
> +	return (read_cr3() & PHYSICAL_PAGE_MASK);
> +}
>  
>  #endif /* __KERNEL__ */
>  
> diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
> index 43b7002..dc03624 100644
> --- a/arch/x86/kernel/head64.c
> +++ b/arch/x86/kernel/head64.c
> @@ -55,7 +55,7 @@ int __init early_make_pgtable(unsigned long address)
>  	pmdval_t pmd, *pmd_p;
>  
>  	/* Invalid address or early pgt is done ?  */
> -	if (physaddr >= MAXMEM || read_cr3() != __pa_nodebug(early_level4_pgt))
> +	if (physaddr >= MAXMEM || read_cr3_pa() != __pa_nodebug(early_level4_pgt))
>  		return -1;
>  
>  again:
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 8ad91a0..2a1fa10c 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -346,7 +346,7 @@ static noinline int vmalloc_fault(unsigned long address)
>  	 * Do _not_ use "current" here. We might be inside
>  	 * an interrupt in the middle of a task switch..
>  	 */
> -	pgd_paddr = read_cr3();
> +	pgd_paddr = read_cr3_pa();
>  	pmd_k = vmalloc_sync_one(__va(pgd_paddr), address);
>  	if (!pmd_k)
>  		return -1;
> @@ -388,7 +388,7 @@ static bool low_pfn(unsigned long pfn)
>  
>  static void dump_pagetable(unsigned long address)
>  {
> -	pgd_t *base = __va(read_cr3());
> +	pgd_t *base = __va(read_cr3_pa());
>  	pgd_t *pgd = &base[pgd_index(address)];
>  	p4d_t *p4d;
>  	pud_t *pud;
> @@ -451,7 +451,7 @@ static noinline int vmalloc_fault(unsigned long address)
>  	 * happen within a race in page table update. In the later
>  	 * case just flush:
>  	 */
> -	pgd = (pgd_t *)__va(read_cr3()) + pgd_index(address);
> +	pgd = (pgd_t *)__va(read_cr3_pa()) + pgd_index(address);
>  	pgd_ref = pgd_offset_k(address);
>  	if (pgd_none(*pgd_ref))
>  		return -1;
> @@ -555,7 +555,7 @@ static int bad_address(void *p)
>  
>  static void dump_pagetable(unsigned long address)
>  {
> -	pgd_t *base = __va(read_cr3() & PHYSICAL_PAGE_MASK);
> +	pgd_t *base = __va(read_cr3_pa());
>  	pgd_t *pgd = base + pgd_index(address);
>  	p4d_t *p4d;
>  	pud_t *pud;
> @@ -700,7 +700,7 @@ static int is_f00f_bug(struct pt_regs *regs, unsigned long address)
>  		pgd_t *pgd;
>  		pte_t *pte;
>  
> -		pgd = __va(read_cr3() & PHYSICAL_PAGE_MASK);
> +		pgd = __va(read_cr3_pa());
>  		pgd += pgd_index(address);
>  
>  		pte = lookup_address_in_pgd(pgd, address, &level);
> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
> index 2a0fa89..e6305dd 100644
> --- a/arch/x86/mm/ioremap.c
> +++ b/arch/x86/mm/ioremap.c
> @@ -427,7 +427,7 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
>  static inline pmd_t * __init early_ioremap_pmd(unsigned long addr)
>  {
>  	/* Don't assume we're using swapper_pg_dir at this point */
> -	pgd_t *base = __va(read_cr3());
> +	pgd_t *base = __va(read_cr3_pa());
>  	pgd_t *pgd = &base[pgd_index(addr)];
>  	p4d_t *p4d = p4d_offset(pgd, addr);
>  	pud_t *pud = pud_offset(p4d, addr);
> diff --git a/arch/x86/platform/olpc/olpc-xo1-pm.c b/arch/x86/platform/olpc/olpc-xo1-pm.c
> index c5350fd..0668aaf 100644
> --- a/arch/x86/platform/olpc/olpc-xo1-pm.c
> +++ b/arch/x86/platform/olpc/olpc-xo1-pm.c
> @@ -77,7 +77,7 @@ static int xo1_power_state_enter(suspend_state_t pm_state)
>  
>  asmlinkage __visible int xo1_do_sleep(u8 sleep_state)
>  {
> -	void *pgd_addr = __va(read_cr3());
> +	void *pgd_addr = __va(read_cr3_pa());
>  
>  	/* Program wakeup mask (using dword access to CS5536_PM1_EN) */
>  	outl(wakeup_mask << 16, acpi_base + CS5536_PM1_STS);
> diff --git a/arch/x86/power/hibernate_64.c b/arch/x86/power/hibernate_64.c
> index a6e21fe..0a7650d 100644
> --- a/arch/x86/power/hibernate_64.c
> +++ b/arch/x86/power/hibernate_64.c
> @@ -150,7 +150,7 @@ static int relocate_restore_code(void)
>  	memcpy((void *)relocated_restore_code, &core_restore_code, PAGE_SIZE);
>  
>  	/* Make the page containing the relocated code executable */
> -	pgd = (pgd_t *)__va(read_cr3()) + pgd_index(relocated_restore_code);
> +	pgd = (pgd_t *)__va(read_cr3_pa()) + pgd_index(relocated_restore_code);
>  	p4d = p4d_offset(pgd, relocated_restore_code);
>  	if (p4d_large(*p4d)) {
>  		set_p4d(p4d, __p4d(p4d_val(*p4d) & ~_PAGE_NX));
> diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
> index 1f386d7..2dc5243 100644
> --- a/arch/x86/xen/mmu_pv.c
> +++ b/arch/x86/xen/mmu_pv.c
> @@ -2022,7 +2022,7 @@ static phys_addr_t __init xen_early_virt_to_phys(unsigned long vaddr)
>  	pmd_t pmd;
>  	pte_t pte;
>  
> -	pa = read_cr3();
> +	pa = read_cr3_pa();
>  	pgd = native_make_pgd(xen_read_phys_ulong(pa + pgd_index(vaddr) *
>  						       sizeof(pgd)));
>  	if (!pgd_present(pgd))
> @@ -2102,7 +2102,7 @@ void __init xen_relocate_p2m(void)
>  	pt_phys = pmd_phys + PFN_PHYS(n_pmd);
>  	p2m_pfn = PFN_DOWN(pt_phys) + n_pt;
>  
> -	pgd = __va(read_cr3());
> +	pgd = __va(read_cr3_pa());
>  	new_p2m = (unsigned long *)(2 * PGDIR_SIZE);
>  	idx_p4d = 0;
>  	save_pud = n_pud;
> @@ -2209,7 +2209,7 @@ static void __init xen_write_cr3_init(unsigned long cr3)
>  {
>  	unsigned long pfn = PFN_DOWN(__pa(swapper_pg_dir));
>  
> -	BUG_ON(read_cr3() != __pa(initial_page_table));
> +	BUG_ON(read_cr3_pa() != __pa(initial_page_table));
>  	BUG_ON(cr3 != __pa(swapper_pg_dir));
>  
>  	/*


(Please copy Xen maintainers when modifying xen-related files.)

Given that page tables for Xen PV guests are controlled by the
hypervisor I don't think this change (although harmless) is necessary.
What may be needed is making sure X86_FEATURE_SME is not set for PV guests.

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
