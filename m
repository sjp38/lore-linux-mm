From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v2 07/20] x86: Provide general kernel support for
	memory encryption
Date: Tue, 6 Sep 2016 11:31:13 +0200
Message-ID: <20160906093113.GA18319@pd.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
	<20160822223646.29880.28794.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160822223646.29880.28794.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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

On Mon, Aug 22, 2016 at 05:36:46PM -0500, Tom Lendacky wrote:
> Adding general kernel support for memory encryption includes:
> - Modify and create some page table macros to include the Secure Memory
>   Encryption (SME) memory encryption mask
> - Update kernel boot support to call an SME routine that checks for and
>   sets the SME capability (the SME routine will grow later and for now
>   is just a stub routine)
> - Update kernel boot support to call an SME routine that encrypts the
>   kernel (the SME routine will grow later and for now is just a stub
>   routine)
> - Provide an SME initialization routine to update the protection map with
>   the memory encryption mask so that it is used by default
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>

...

> diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
> index 54a2372..88c7bae 100644
> --- a/arch/x86/kernel/head64.c
> +++ b/arch/x86/kernel/head64.c
> @@ -28,6 +28,7 @@
>  #include <asm/bootparam_utils.h>
>  #include <asm/microcode.h>
>  #include <asm/kasan.h>
> +#include <asm/mem_encrypt.h>
>  
>  /*
>   * Manage page tables very early on.
> @@ -42,7 +43,7 @@ static void __init reset_early_page_tables(void)
>  {
>  	memset(early_level4_pgt, 0, sizeof(pgd_t)*(PTRS_PER_PGD-1));
>  	next_early_pgt = 0;
> -	write_cr3(__pa_nodebug(early_level4_pgt));
> +	write_cr3(__sme_pa_nodebug(early_level4_pgt));
>  }
>  
>  /* Create a new PMD entry */
> @@ -54,7 +55,7 @@ int __init early_make_pgtable(unsigned long address)
>  	pmdval_t pmd, *pmd_p;
>  
>  	/* Invalid address or early pgt is done ?  */
> -	if (physaddr >= MAXMEM || read_cr3() != __pa_nodebug(early_level4_pgt))
> +	if (physaddr >= MAXMEM || read_cr3() != __sme_pa_nodebug(early_level4_pgt))
>  		return -1;
>  
>  again:
> @@ -157,6 +158,11 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
>  
>  	clear_page(init_level4_pgt);
>  
> +	/* Update the early_pmd_flags with the memory encryption mask */
> +	early_pmd_flags |= _PAGE_ENC;
> +
> +	sme_early_init();
> +

So maybe this comes later but you're setting _PAGE_ENC unconditionally
*before* sme_early_init().

I think you should set it in sme_early_init() and iff SME is enabled.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
