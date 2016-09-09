From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v2 10/20] x86: Insure that memory areas are encrypted
 when possible
Date: Fri, 9 Sep 2016 17:53:06 +0200
Message-ID: <20160909155305.bmm2fvw7ndjjhqvo@pd.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223722.29880.94331.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160822223722.29880.94331.stgit@tlendack-t1.amdoffice.net>
Sender: linux-arch-owner@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.>
List-Id: linux-mm.kvack.org

On Mon, Aug 22, 2016 at 05:37:23PM -0500, Tom Lendacky wrote:
> Encrypt memory areas in place when possible (e.g. zero page, etc.) so
> that special handling isn't needed afterwards.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/kernel/head64.c |   93 ++++++++++++++++++++++++++++++++++++++++++++--
>  arch/x86/kernel/setup.c  |    8 ++++
>  2 files changed, 96 insertions(+), 5 deletions(-)

...

> +int __init early_make_pgtable(unsigned long address)
> +{
> +	unsigned long physaddr = address - __PAGE_OFFSET;
> +	pmdval_t pmd;
> +
> +	pmd = (physaddr & PMD_MASK) + early_pmd_flags;
> +
> +	return __early_make_pgtable(address, pmd);
> +}
> +
> +static void __init create_unencrypted_mapping(void *address, unsigned long size)
> +{
> +	unsigned long physaddr = (unsigned long)address - __PAGE_OFFSET;
> +	pmdval_t pmd_flags, pmd;
> +
> +	if (!sme_me_mask)
> +		return;
> +
> +	/* Clear the encryption mask from the early_pmd_flags */
> +	pmd_flags = early_pmd_flags & ~sme_me_mask;
> +
> +	do {
> +		pmd = (physaddr & PMD_MASK) + pmd_flags;
> +		__early_make_pgtable((unsigned long)address, pmd);
> +
> +		address += PMD_SIZE;
> +		physaddr += PMD_SIZE;
> +		size = (size < PMD_SIZE) ? 0 : size - PMD_SIZE;
> +	} while (size);
> +}
> +
> +static void __init __clear_mapping(unsigned long address)

Should be called something with "pmd" in the name as it clears a PMD,
i.e. __clear_pmd_mapping or so.

> +{
> +	unsigned long physaddr = address - __PAGE_OFFSET;
> +	pgdval_t pgd, *pgd_p;
> +	pudval_t pud, *pud_p;
> +	pmdval_t *pmd_p;
> +
> +	/* Invalid address or early pgt is done ?  */
> +	if (physaddr >= MAXMEM ||
> +	    read_cr3() != __sme_pa_nodebug(early_level4_pgt))
> +		return;
> +
> +	pgd_p = &early_level4_pgt[pgd_index(address)].pgd;
> +	pgd = *pgd_p;
> +
> +	if (!pgd)
> +		return;
> +
> +	/*
> +	 * The use of __START_KERNEL_map rather than __PAGE_OFFSET here matches
> +	 * __early_make_pgtable where the entry was created.
> +	 */
> +	pud_p = (pudval_t *)((pgd & PTE_PFN_MASK) + __START_KERNEL_map - phys_base);
> +	pud_p += pud_index(address);
> +	pud = *pud_p;
> +
> +	if (!pud)
> +		return;
> +
> +	pmd_p = (pmdval_t *)((pud & PTE_PFN_MASK) + __START_KERNEL_map - phys_base);
> +	pmd_p[pmd_index(address)] = 0;
> +}
> +
> +static void __init clear_mapping(void *address, unsigned long size)
> +{
> +	if (!sme_me_mask)
> +		return;
> +
> +	do {
> +		__clear_mapping((unsigned long)address);
> +
> +		address += PMD_SIZE;
> +		size = (size < PMD_SIZE) ? 0 : size - PMD_SIZE;
> +	} while (size);
> +}
> +
> +static void __init sme_memcpy(void *dst, void *src, unsigned long size)
> +{
> +	create_unencrypted_mapping(src, size);
> +	memcpy(dst, src, size);
> +	clear_mapping(src, size);
> +}
> +

In any case, this whole functionality is SME-specific and should be
somewhere in an SME-specific file. arch/x86/mm/mem_encrypt.c or so...

>  /* Don't add a printk in there. printk relies on the PDA which is not initialized 
>     yet. */
>  static void __init clear_bss(void)
> @@ -122,12 +205,12 @@ static void __init copy_bootdata(char *real_mode_data)
>  	char * command_line;
>  	unsigned long cmd_line_ptr;
>  
> -	memcpy(&boot_params, real_mode_data, sizeof boot_params);
> +	sme_memcpy(&boot_params, real_mode_data, sizeof boot_params);

checkpatch.pl:

WARNING: sizeof boot_params should be sizeof(boot_params)
#155: FILE: arch/x86/kernel/head64.c:208:
+       sme_memcpy(&boot_params, real_mode_data, sizeof boot_params);

>  	sanitize_boot_params(&boot_params);
>  	cmd_line_ptr = get_cmd_line_ptr();
>  	if (cmd_line_ptr) {
>  		command_line = __va(cmd_line_ptr);
> -		memcpy(boot_command_line, command_line, COMMAND_LINE_SIZE);
> +		sme_memcpy(boot_command_line, command_line, COMMAND_LINE_SIZE);
>  	}
>  }
>  
> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index 1489da8..1fdaa11 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -114,6 +114,7 @@
>  #include <asm/microcode.h>
>  #include <asm/mmu_context.h>
>  #include <asm/kaslr.h>
> +#include <asm/mem_encrypt.h>
>  
>  /*
>   * max_low_pfn_mapped: highest direct mapped pfn under 4GB
> @@ -376,6 +377,13 @@ static void __init reserve_initrd(void)
>  	    !ramdisk_image || !ramdisk_size)
>  		return;		/* No initrd provided by bootloader */
>  
> +	/*
> +	 * This memory is marked encrypted by the kernel but the ramdisk
> +	 * was loaded in the clear by the bootloader, so make sure that
> +	 * the ramdisk image is encrypted.
> +	 */
> +	sme_early_mem_enc(ramdisk_image, ramdisk_end - ramdisk_image);

What happens if we go and relocate the ramdisk? I.e., the function above
this one: relocate_initrd(). We have to encrypt it then too, I presume.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
