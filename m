From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v2 20/20] x86: Add support to make use of Secure
	Memory Encryption
Date: Mon, 12 Sep 2016 19:08:56 +0200
Message-ID: <20160912170856.2uklaoc4vxmkgnkq@pd.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
	<20160822223908.29880.50365.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160822223908.29880.50365.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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
Cc: linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

On Mon, Aug 22, 2016 at 05:39:08PM -0500, Tom Lendacky wrote:
> This patch adds the support to check if SME has been enabled and if the
> mem_encrypt=on command line option is set. If both of these conditions
> are true, then the encryption mask is set and the kernel is encrypted
> "in place."
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  Documentation/kernel-parameters.txt |    3 
>  arch/x86/kernel/asm-offsets.c       |    2 
>  arch/x86/kernel/mem_encrypt.S       |  302 +++++++++++++++++++++++++++++++++++
>  arch/x86/mm/mem_encrypt.c           |    2 
>  4 files changed, 309 insertions(+)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 46c030a..a1986c8 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -2268,6 +2268,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			memory contents and reserves bad memory
>  			regions that are detected.
>  
> +	mem_encrypt=on	[X86_64] Enable memory encryption on processors
> +			that support this feature.
> +
>  	meye.*=		[HW] Set MotionEye Camera parameters
>  			See Documentation/video4linux/meye.txt.
>  
> diff --git a/arch/x86/kernel/asm-offsets.c b/arch/x86/kernel/asm-offsets.c
> index 2bd5c6f..e485ada 100644
> --- a/arch/x86/kernel/asm-offsets.c
> +++ b/arch/x86/kernel/asm-offsets.c
> @@ -85,6 +85,8 @@ void common(void) {
>  	OFFSET(BP_init_size, boot_params, hdr.init_size);
>  	OFFSET(BP_pref_address, boot_params, hdr.pref_address);
>  	OFFSET(BP_code32_start, boot_params, hdr.code32_start);
> +	OFFSET(BP_cmd_line_ptr, boot_params, hdr.cmd_line_ptr);
> +	OFFSET(BP_ext_cmd_line_ptr, boot_params, ext_cmd_line_ptr);
>  
>  	BLANK();
>  	DEFINE(PTREGS_SIZE, sizeof(struct pt_regs));
> diff --git a/arch/x86/kernel/mem_encrypt.S b/arch/x86/kernel/mem_encrypt.S
> index f2e0536..bf9f6a9 100644
> --- a/arch/x86/kernel/mem_encrypt.S
> +++ b/arch/x86/kernel/mem_encrypt.S
> @@ -12,13 +12,230 @@
>  
>  #include <linux/linkage.h>
>  
> +#include <asm/processor-flags.h>
> +#include <asm/pgtable.h>
> +#include <asm/page.h>
> +#include <asm/msr.h>
> +#include <asm/asm-offsets.h>
> +
>  	.text
>  	.code64
>  ENTRY(sme_enable)
> +#ifdef CONFIG_AMD_MEM_ENCRYPT
> +	/* Check for AMD processor */
> +	xorl	%eax, %eax
> +	cpuid
> +	cmpl    $0x68747541, %ebx	# AuthenticAMD
> +	jne     .Lmem_encrypt_exit
> +	cmpl    $0x69746e65, %edx
> +	jne     .Lmem_encrypt_exit
> +	cmpl    $0x444d4163, %ecx
> +	jne     .Lmem_encrypt_exit
> +
> +	/* Check for memory encryption leaf */
> +	movl	$0x80000000, %eax
> +	cpuid
> +	cmpl	$0x8000001f, %eax
> +	jb	.Lmem_encrypt_exit
> +
> +	/*
> +	 * Check for memory encryption feature:
> +	 *   CPUID Fn8000_001F[EAX] - Bit 0
> +	 *     Secure Memory Encryption support
> +	 *   CPUID Fn8000_001F[EBX] - Bits 5:0
> +	 *     Pagetable bit position used to indicate encryption
> +	 *   CPUID Fn8000_001F[EBX] - Bits 11:6
> +	 *     Reduction in physical address space (in bits) when enabled
> +	 */
> +	movl	$0x8000001f, %eax
> +	cpuid
> +	bt	$0, %eax
> +	jnc	.Lmem_encrypt_exit
> +
> +	/* Check if BIOS/UEFI has allowed memory encryption */
> +	movl	$MSR_K8_SYSCFG, %ecx
> +	rdmsr
> +	bt	$MSR_K8_SYSCFG_MEM_ENCRYPT_BIT, %eax
> +	jnc	.Lmem_encrypt_exit

Like other people suggested, it would be great if this were in C. Should be
actually readable :)

> +
> +	/* Check for the mem_encrypt=on command line option */
> +	push	%rsi			/* Save RSI (real_mode_data) */
> +	push	%rbx			/* Save CPUID information */
> +	movl	BP_ext_cmd_line_ptr(%rsi), %ecx
> +	shlq	$32, %rcx
> +	movl	BP_cmd_line_ptr(%rsi), %edi
> +	addq	%rcx, %rdi
> +	leaq	mem_encrypt_enable_option(%rip), %rsi
> +	call	cmdline_find_option_bool
> +	pop	%rbx			/* Restore CPUID information */
> +	pop	%rsi			/* Restore RSI (real_mode_data) */
> +	testl	%eax, %eax
> +	jz	.Lno_mem_encrypt

This too.

> +
> +	/* Set memory encryption mask */
> +	movl	%ebx, %ecx
> +	andl	$0x3f, %ecx
> +	bts	%ecx, sme_me_mask(%rip)
> +
> +.Lno_mem_encrypt:
> +	/*
> +	 * BIOS/UEFI has allowed memory encryption so we need to set
> +	 * the amount of physical address space reduction even if
> +	 * the user decides not to use memory encryption.
> +	 */
> +	movl	%ebx, %ecx
> +	shrl	$6, %ecx
> +	andl	$0x3f, %ecx
> +	movb	%cl, sme_me_loss(%rip)
> +
> +.Lmem_encrypt_exit:
> +#endif	/* CONFIG_AMD_MEM_ENCRYPT */
> +
>  	ret
>  ENDPROC(sme_enable)
>  
>  ENTRY(sme_encrypt_kernel)

This should be doable too but I guess you'll have to try it to see.

...

> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index 2f28d87..1154353 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -183,6 +183,8 @@ void __init mem_encrypt_init(void)
>  
>  	/* Make SWIOTLB use an unencrypted DMA area */
>  	swiotlb_clear_encryption();
> +
> +	pr_info("memory encryption active\n");

Let's make it more official with nice caps and so on...

	pr_info("AMD Secure Memory Encryption active.\n");

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
