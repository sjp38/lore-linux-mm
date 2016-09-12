From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v2 16/20] x86: Check for memory encryption on the APs
Date: Mon, 12 Sep 2016 14:17:40 +0200
Message-ID: <20160912121739.rwuumwpwo5megmd7@pd.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
	<20160822223829.29880.10341.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160822223829.29880.10341.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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

On Mon, Aug 22, 2016 at 05:38:29PM -0500, Tom Lendacky wrote:
> Add support to check if memory encryption is active in the kernel and that
> it has been enabled on the AP. If memory encryption is active in the kernel
> but has not been enabled on the AP then do not allow the AP to continue
> start up.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  arch/x86/include/asm/msr-index.h     |    2 ++
>  arch/x86/include/asm/realmode.h      |   12 ++++++++++++
>  arch/x86/realmode/init.c             |    4 ++++
>  arch/x86/realmode/rm/trampoline_64.S |   19 +++++++++++++++++++
>  4 files changed, 37 insertions(+)

...

> diff --git a/arch/x86/realmode/rm/trampoline_64.S b/arch/x86/realmode/rm/trampoline_64.S
> index dac7b20..94e29f4 100644
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
> @@ -92,6 +93,23 @@ ENTRY(startup_32)
>  	movl	%edx, %fs
>  	movl	%edx, %gs
>  
> +	/* Check for memory encryption support */
> +	bt	$TH_FLAGS_SME_ENABLE_BIT, pa_tr_flags
> +	jnc	.Ldone
> +	movl	$MSR_K8_SYSCFG, %ecx
> +	rdmsr
> +	bt	$MSR_K8_SYSCFG_MEM_ENCRYPT_BIT, %eax
> +	jc	.Ldone
> +
> +	/*
> +	 * Memory encryption is enabled but the MSR has not been set on this
> +	 * CPU so we can't continue

Hmm, let me try to parse this correctly: BSP has SME enabled but the
BIOS might not've set this on the AP? Really? Is that even possible?

Because if SME is enabled, that means that MSR_K8_SYSCFG[23] on the BSP
is set, right?

Also, I want to rule out here simple BIOS idiocy: if the only problem
with the bit not being set in the AP is because some BIOS monkey forgot
to do so, then we should try to set it ourselves and not die for no real
reason.

Or is there another issue?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
