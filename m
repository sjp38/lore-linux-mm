From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v3 06/20] x86: Add support to enable SME during early
	boot processing
Date: Mon, 14 Nov 2016 18:29:30 +0100
Message-ID: <20161114172930.27z7p2kytmhtcbsb@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
	<20161110003543.3280.99623.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161110003543.3280.99623.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
Cc: linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Larry Woodman <lwoodman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

On Wed, Nov 09, 2016 at 06:35:43PM -0600, Tom Lendacky wrote:
> This patch adds support to the early boot code to use Secure Memory
> Encryption (SME).  Support is added to update the early pagetables with
> the memory encryption mask and to encrypt the kernel in place.
> 
> The routines to set the encryption mask and perform the encryption are
> stub routines for now with full function to be added in a later patch.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  arch/x86/kernel/Makefile           |    2 ++
>  arch/x86/kernel/head_64.S          |   35 ++++++++++++++++++++++++++++++++++-
>  arch/x86/kernel/mem_encrypt_init.c |   29 +++++++++++++++++++++++++++++
>  3 files changed, 65 insertions(+), 1 deletion(-)
>  create mode 100644 arch/x86/kernel/mem_encrypt_init.c
> 
> diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
> index 45257cf..27e22f4 100644
> --- a/arch/x86/kernel/Makefile
> +++ b/arch/x86/kernel/Makefile
> @@ -141,4 +141,6 @@ ifeq ($(CONFIG_X86_64),y)
>  
>  	obj-$(CONFIG_PCI_MMCONFIG)	+= mmconf-fam10h_64.o
>  	obj-y				+= vsmp_64.o
> +
> +	obj-y				+= mem_encrypt_init.o
>  endif
> diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
> index c98a559..9a28aad 100644
> --- a/arch/x86/kernel/head_64.S
> +++ b/arch/x86/kernel/head_64.S
> @@ -95,6 +95,17 @@ startup_64:
>  	jnz	bad_address
>  
>  	/*
> +	 * Enable Secure Memory Encryption (if available).  Save the mask
> +	 * in %r12 for later use and add the memory encryption mask to %rbp
> +	 * to include it in the page table fixups.
> +	 */
> +	push	%rsi
> +	call	sme_enable
> +	pop	%rsi

Why %rsi?

sme_enable() is void so no args in registers and returns in %rax.

/me is confused.

> +	movq	%rax, %r12
> +	addq	%r12, %rbp
> +
> +	/*
>  	 * Fixup the physical addresses in the page table
>  	 */
>  	addq	%rbp, early_level4_pgt + (L4_START_KERNEL*8)(%rip)
> @@ -117,6 +128,7 @@ startup_64:
>  	shrq	$PGDIR_SHIFT, %rax
>  
>  	leaq	(4096 + _KERNPG_TABLE)(%rbx), %rdx
> +	addq	%r12, %rdx
>  	movq	%rdx, 0(%rbx,%rax,8)
>  	movq	%rdx, 8(%rbx,%rax,8)
>  
> @@ -133,6 +145,7 @@ startup_64:
>  	movq	%rdi, %rax
>  	shrq	$PMD_SHIFT, %rdi
>  	addq	$(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL), %rax
> +	addq	%r12, %rax
>  	leaq	(_end - 1)(%rip), %rcx
>  	shrq	$PMD_SHIFT, %rcx
>  	subq	%rdi, %rcx
> @@ -163,9 +176,21 @@ startup_64:
>  	cmp	%r8, %rdi
>  	jne	1b
>  
> -	/* Fixup phys_base */
> +	/*
> +	 * Fixup phys_base, remove the memory encryption mask from %rbp
> +	 * to obtain the true physical address.
> +	 */
> +	subq	%r12, %rbp
>  	addq	%rbp, phys_base(%rip)
>  
> +	/*
> +	 * The page tables have been updated with the memory encryption mask,
> +	 * so encrypt the kernel if memory encryption is active
> +	 */
> +	push	%rsi
> +	call	sme_encrypt_kernel
> +	pop	%rsi

Ditto.

> +
>  	movq	$(early_level4_pgt - __START_KERNEL_map), %rax
>  	jmp 1f
>  ENTRY(secondary_startup_64)
> @@ -186,9 +211,17 @@ ENTRY(secondary_startup_64)
>  	/* Sanitize CPU configuration */
>  	call verify_cpu
>  
> +	push	%rsi
> +	call	sme_get_me_mask
> +	pop	%rsi

Ditto.

> +	movq	%rax, %r12
> +
>  	movq	$(init_level4_pgt - __START_KERNEL_map), %rax
>  1:
>  
> +	/* Add the memory encryption mask to RAX */

I think that should say something like:

	/*
	 * Add the memory encryption mask to init_level4_pgt's physical address
	 */

or so...

> +	addq	%r12, %rax
> +
>  	/* Enable PAE mode and PGE */
>  	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
>  	movq	%rcx, %cr4
> diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
> new file mode 100644
> index 0000000..388d6fb
> --- /dev/null
> +++ b/arch/x86/kernel/mem_encrypt_init.c

So nothing in the commit message explains why we need a separate
mem_encrypt_init.c file when we already have arch/x86/mm/mem_encrypt.c
for all memory encryption code...

> @@ -0,0 +1,29 @@
> +/*
> + * AMD Memory Encryption Support
> + *
> + * Copyright (C) 2016 Advanced Micro Devices, Inc.
> + *
> + * Author: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +
> +#include <linux/linkage.h>
> +#include <linux/init.h>
> +#include <linux/mem_encrypt.h>
> +
> +void __init sme_encrypt_kernel(void)
> +{
> +}
> +
> +unsigned long __init sme_get_me_mask(void)
> +{
> +	return sme_me_mask;
> +}
> +
> +unsigned long __init sme_enable(void)
> +{
> +	return sme_me_mask;
> +}

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
