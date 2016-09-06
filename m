From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v2 09/20] x86: Add support for early
	encryption/decryption of memory
Date: Tue, 6 Sep 2016 18:12:49 +0200
Message-ID: <20160906161249.3ckotvocwuukhjws@pd.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
	<20160822223710.29880.23936.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160822223710.29880.23936.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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

On Mon, Aug 22, 2016 at 05:37:10PM -0500, Tom Lendacky wrote:
> This adds support to be able to either encrypt or decrypt data during
> the early stages of booting the kernel. This does not change the memory
> encryption attribute - it is used for ensuring that data present in
> either an encrypted or un-encrypted memory area is in the proper state
> (for example the initrd will have been loaded by the boot loader and
> will not be encrypted, but the memory that it resides in is marked as
> encrypted).
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---

...

> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index 00eb705..f35a646 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -14,6 +14,107 @@
>  #include <linux/mm.h>
>  
>  #include <asm/mem_encrypt.h>
> +#include <asm/tlbflush.h>
> +#include <asm/fixmap.h>
> +
> +/* Buffer used for early in-place encryption by BSP, no locking needed */
> +static char me_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
> +
> +/*
> + * This routine does not change the underlying encryption setting of the
> + * page(s) that map this memory. It assumes that eventually the memory is
> + * meant to be accessed as encrypted but the contents are currently not
> + * encyrpted.

s/encyrpted/encrypted/

Ditto below.

> + */
> +void __init sme_early_mem_enc(resource_size_t paddr, unsigned long size)
> +{
> +	void *src, *dst;
> +	size_t len;
> +
> +	if (!sme_me_mask)
> +		return;
> +
> +	local_flush_tlb();
> +	wbinvd();
> +
> +	/*
> +	 * There are limited number of early mapping slots, so map (at most)
> +	 * one page at time.
> +	 */
> +	while (size) {
> +		len = min_t(size_t, sizeof(me_early_buffer), size);
> +
> +		/* Create a mapping for non-encrypted write-protected memory */
> +		src = early_memremap_dec_wp(paddr, len);
> +
> +		/* Create a mapping for encrypted memory */
> +		dst = early_memremap_enc(paddr, len);
> +
> +		/*
> +		 * If a mapping can't be obtained to perform the encryption,
> +		 * then encrypted access to that area will end up causing
> +		 * a crash.
> +		 */
> +		BUG_ON(!src || !dst);
> +
> +		memcpy(me_early_buffer, src, len);
> +		memcpy(dst, me_early_buffer, len);
> +
> +		early_memunmap(dst, len);
> +		early_memunmap(src, len);
> +
> +		paddr += len;
> +		size -= len;
> +	}
> +}
> +
> +/*
> + * This routine does not change the underlying encryption setting of the
> + * page(s) that map this memory. It assumes that eventually the memory is
> + * meant to be accessed as not encrypted but the contents are currently
> + * encyrpted.
> + */
> +void __init sme_early_mem_dec(resource_size_t paddr, unsigned long size)
> +{

...

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
