From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v4 21/28] x86: Check for memory encryption on the APs
Date: Mon, 27 Feb 2017 19:17:01 +0100
Message-ID: <20170227181701.2lynk4rm77yk4msf@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
	<20170216154647.19244.18733.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170216154647.19244.18733.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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
Cc: linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Brijesh Singh <brijesh.singh-5C7GfCeVMHo@public.gmane.org>, Toshimitsu Kani <toshi.kani-ZPxbGqLxI0U@public.gmane.org>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Larry Woodman <lwoodman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

On Thu, Feb 16, 2017 at 09:46:47AM -0600, Tom Lendacky wrote:
> Add support to check if memory encryption is active in the kernel and that
> it has been enabled on the AP. If memory encryption is active in the kernel
> but has not been enabled on the AP, then set the SYS_CFG MSR bit to enable
> memory encryption on that AP and allow the AP to continue start up.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  arch/x86/include/asm/realmode.h      |   12 ++++++++++++
>  arch/x86/realmode/init.c             |    4 ++++
>  arch/x86/realmode/rm/trampoline_64.S |   17 +++++++++++++++++
>  3 files changed, 33 insertions(+)
> 
> diff --git a/arch/x86/include/asm/realmode.h b/arch/x86/include/asm/realmode.h
> index 230e190..4f7ef53 100644
> --- a/arch/x86/include/asm/realmode.h
> +++ b/arch/x86/include/asm/realmode.h
> @@ -1,6 +1,15 @@
>  #ifndef _ARCH_X86_REALMODE_H
>  #define _ARCH_X86_REALMODE_H
>  
> +/*
> + * Flag bit definitions for use with the flags field of the trampoline header
> + * int the CONFIG_X86_64 variant.

s/int/in/

> + */
> +#define TH_FLAGS_SME_ACTIVE_BIT		0
> +#define TH_FLAGS_SME_ACTIVE		BIT(TH_FLAGS_SME_ACTIVE_BIT)
> +
> +#ifndef __ASSEMBLY__
> +
>  #include <linux/types.h>
>  #include <asm/io.h>
>  
> @@ -38,6 +47,7 @@ struct trampoline_header {
>  	u64 start;
>  	u64 efer;
>  	u32 cr4;
> +	u32 flags;
>  #endif
>  };
>  
> @@ -69,4 +79,6 @@ static inline size_t real_mode_size_needed(void)
>  void set_real_mode_mem(phys_addr_t mem, size_t size);
>  void reserve_real_mode(void);
>  
> +#endif /* __ASSEMBLY__ */
> +
>  #endif /* _ARCH_X86_REALMODE_H */
> diff --git a/arch/x86/realmode/init.c b/arch/x86/realmode/init.c
> index 21d7506..5010089 100644
> --- a/arch/x86/realmode/init.c
> +++ b/arch/x86/realmode/init.c
> @@ -102,6 +102,10 @@ static void __init setup_real_mode(void)
>  	trampoline_cr4_features = &trampoline_header->cr4;
>  	*trampoline_cr4_features = mmu_cr4_features;
>  
> +	trampoline_header->flags = 0;
> +	if (sme_active())
> +		trampoline_header->flags |= TH_FLAGS_SME_ACTIVE;
> +
>  	trampoline_pgd = (u64 *) __va(real_mode_header->trampoline_pgd);
>  	trampoline_pgd[0] = trampoline_pgd_entry.pgd;
>  	trampoline_pgd[511] = init_level4_pgt[511].pgd;
> diff --git a/arch/x86/realmode/rm/trampoline_64.S b/arch/x86/realmode/rm/trampoline_64.S
> index dac7b20..a88c3d1 100644
> --- a/arch/x86/realmode/rm/trampoline_64.S
> +++ b/arch/x86/realmode/rm/trampoline_64.S
> @@ -30,6 +30,7 @@
>  #include <asm/msr.h>
>  #include <asm/segment.h>
>  #include <asm/processor-flags.h>
> +#include <asm/realmode.h>
>  #include "realmode.h"
>  
>  	.text
> @@ -92,6 +93,21 @@ ENTRY(startup_32)
>  	movl	%edx, %fs
>  	movl	%edx, %gs
>  
> +	/* Check for memory encryption support */

Let's add some blurb here about this being a safety net in case BIOS
f*cks up. Which wouldn't be that far-fetched... :-)

> +	bt	$TH_FLAGS_SME_ACTIVE_BIT, pa_tr_flags
> +	jnc	.Ldone
> +	movl	$MSR_K8_SYSCFG, %ecx
> +	rdmsr
> +	bts	$MSR_K8_SYSCFG_MEM_ENCRYPT_BIT, %eax
> +	jc	.Ldone

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
