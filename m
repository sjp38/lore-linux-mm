From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v3 09/20] x86: Insure that boot memory areas are
	mapped properly
Date: Thu, 17 Nov 2016 13:20:15 +0100
Message-ID: <20161117122015.kxnwjtgyzitxio2p@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
	<20161110003620.3280.20613.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161110003620.3280.20613.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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

On Wed, Nov 09, 2016 at 06:36:20PM -0600, Tom Lendacky wrote:
> The boot data and command line data are present in memory in an
> un-encrypted state and are copied early in the boot process.  The early
> page fault support will map these areas as encrypted, so before attempting
> to copy them, add unencrypted mappings so the data is accessed properly
> when copied.
> 
> For the initrd, encrypt this data in place. Since the future mapping of the
> initrd area will be mapped as encrypted the data will be accessed properly.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  arch/x86/include/asm/mem_encrypt.h |   13 ++++++++
>  arch/x86/kernel/head64.c           |   21 ++++++++++++--
>  arch/x86/kernel/setup.c            |    9 ++++++
>  arch/x86/mm/mem_encrypt.c          |   56 ++++++++++++++++++++++++++++++++++++
>  4 files changed, 96 insertions(+), 3 deletions(-)

...

> @@ -122,6 +131,12 @@ static void __init copy_bootdata(char *real_mode_data)
>  	char * command_line;
>  	unsigned long cmd_line_ptr;
>  
> +	/*
> +	 * If SME is active, this will create un-encrypted mappings of the
> +	 * boot data in advance of the copy operations
						      ^
						      |
					    Fullstop--+

> +	 */
> +	sme_map_bootdata(real_mode_data);
> +
>  	memcpy(&boot_params, real_mode_data, sizeof boot_params);
>  	sanitize_boot_params(&boot_params);
>  	cmd_line_ptr = get_cmd_line_ptr();

...

> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index 06235b4..411210d 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -16,8 +16,11 @@
>  
>  #include <asm/tlbflush.h>
>  #include <asm/fixmap.h>
> +#include <asm/setup.h>
> +#include <asm/bootparam.h>
>  
>  extern pmdval_t early_pmd_flags;
> +int __init __early_make_pgtable(unsigned long, pmdval_t);
>  
>  /*
>   * Since sme_me_mask is set early in the boot process it must reside in
> @@ -126,6 +129,59 @@ void __init sme_early_mem_dec(resource_size_t paddr, unsigned long size)
>  	}
>  }
>  
> +static void __init *sme_bootdata_mapping(void *vaddr, unsigned long size)

So this could be called __sme_map_bootdata(). "sme_bootdata_mapping"
doesn't tell me what the function does as there's no verb in the name.

> +{
> +	unsigned long paddr = (unsigned long)vaddr - __PAGE_OFFSET;
> +	pmdval_t pmd_flags, pmd;
> +	void *ret = vaddr;

That *ret --->

> +
> +	/* Use early_pmd_flags but remove the encryption mask */
> +	pmd_flags = early_pmd_flags & ~sme_me_mask;
> +
> +	do {
> +		pmd = (paddr & PMD_MASK) + pmd_flags;
> +		__early_make_pgtable((unsigned long)vaddr, pmd);
> +
> +		vaddr += PMD_SIZE;
> +		paddr += PMD_SIZE;
> +		size = (size < PMD_SIZE) ? 0 : size - PMD_SIZE;

			size <= PMD_SIZE

				looks more obvious to me...

> +	} while (size);
> +
> +	return ret;

---> is simply passing vaddr out. So the function can be just as well be
void and you can do below:

	__sme_map_bootdata(real_mode_data, sizeof(boot_params));

	boot_data = (struct boot_params *)real_mode_data;

	...

> +void __init sme_map_bootdata(char *real_mode_data)
> +{
> +	struct boot_params *boot_data;
> +	unsigned long cmdline_paddr;
> +
> +	if (!sme_me_mask)
> +		return;
> +
> +	/*
> +	 * The bootdata will not be encrypted, so it needs to be mapped
> +	 * as unencrypted data so it can be copied properly.
> +	 */
> +	boot_data = sme_bootdata_mapping(real_mode_data, sizeof(boot_params));
> +
> +	/*
> +	 * Determine the command line address only after having established
> +	 * the unencrypted mapping.
> +	 */
> +	cmdline_paddr = boot_data->hdr.cmd_line_ptr |
> +			((u64)boot_data->ext_cmd_line_ptr << 32);

<---- newline here.

> +	if (cmdline_paddr)
> +		sme_bootdata_mapping(__va(cmdline_paddr), COMMAND_LINE_SIZE);
> +}
> +
> +void __init sme_encrypt_ramdisk(resource_size_t paddr, unsigned long size)
> +{
> +	if (!sme_me_mask)
> +		return;
> +
> +	sme_early_mem_enc(paddr, size);
> +}

So this one could simply be called sme_encrypt_area() and be used for
other things. There's nothing special about encrypting a ramdisk, by the
looks of it.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
