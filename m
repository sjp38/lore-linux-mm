From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH v5 12/32] x86/mm: Insure that boot memory areas are
	mapped properly
Date: Thu, 4 May 2017 12:16:09 +0200
Message-ID: <20170504101609.vazu4tuc3gqapaqk@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
	<20170418211822.10190.67435.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170418211822.10190.67435.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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
Cc: linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Brijesh Singh <brijesh.singh-5C7GfCeVMHo@public.gmane.org>, Toshimitsu Kani <toshi.kani-ZPxbGqLxI0U@public.gmane.org>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Larry Woodman <lwoodman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Dave Young <dyoung-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, kexec-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Michael S. Tsirkin" <mst@r>
List-Id: linux-mm.kvack.org

On Tue, Apr 18, 2017 at 04:18:22PM -0500, Tom Lendacky wrote:
> The boot data and command line data are present in memory in a decrypted
> state and are copied early in the boot process.  The early page fault
> support will map these areas as encrypted, so before attempting to copy
> them, add decrypted mappings so the data is accessed properly when copied.
> 
> For the initrd, encrypt this data in place. Since the future mapping of the
> initrd area will be mapped as encrypted the data will be accessed properly.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  arch/x86/include/asm/mem_encrypt.h |   11 +++++
>  arch/x86/include/asm/pgtable.h     |    3 +
>  arch/x86/kernel/head64.c           |   30 ++++++++++++--
>  arch/x86/kernel/setup.c            |   10 +++++
>  arch/x86/mm/mem_encrypt.c          |   77 ++++++++++++++++++++++++++++++++++++
>  5 files changed, 127 insertions(+), 4 deletions(-)

...

> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index 603a166..a95800b 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -115,6 +115,7 @@
>  #include <asm/microcode.h>
>  #include <asm/mmu_context.h>
>  #include <asm/kaslr.h>
> +#include <asm/mem_encrypt.h>
>  
>  /*
>   * max_low_pfn_mapped: highest direct mapped pfn under 4GB
> @@ -374,6 +375,15 @@ static void __init reserve_initrd(void)
>  	    !ramdisk_image || !ramdisk_size)
>  		return;		/* No initrd provided by bootloader */
>  
> +	/*
> +	 * If SME is active, this memory will be marked encrypted by the
> +	 * kernel when it is accessed (including relocation). However, the
> +	 * ramdisk image was loaded decrypted by the bootloader, so make
> +	 * sure that it is encrypted before accessing it.
> +	 */
> +	if (sme_active())

That test is not needed here because __sme_early_enc_dec() already tests
sme_me_mask. There you should change that test to sme_active() instead.

> +		sme_early_encrypt(ramdisk_image, ramdisk_end - ramdisk_image);
> +
>  	initrd_start = 0;
>  
>  	mapped_size = memblock_mem_size(max_pfn_mapped);

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
