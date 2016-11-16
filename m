From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v3 08/20] x86: Add support for early
 encryption/decryption of memory
Date: Wed, 16 Nov 2016 11:46:56 +0100
Message-ID: <20161116104656.qz5wp33zzyja373r@pd.tnic>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003610.3280.22043.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-efi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161110003610.3280.22043.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
Sender: linux-efi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Matt Fleming <matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org>, Joerg Roedel <joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org>, Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Larry Woodman <lwoodman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: linux-mm.kvack.org

Btw, for your next submission, this patch can be split in two exactly
like the commit message paragraphs are:

On Wed, Nov 09, 2016 at 06:36:10PM -0600, Tom Lendacky wrote:
> Add support to be able to either encrypt or decrypt data in place during
> the early stages of booting the kernel. This does not change the memory
> encryption attribute - it is used for ensuring that data present in either
> an encrypted or un-encrypted memory area is in the proper state (for
> example the initrd will have been loaded by the boot loader and will not be
> encrypted, but the memory that it resides in is marked as encrypted).

Patch 2: users of the new memmap change

> The early_memmap support is enhanced to specify encrypted and un-encrypted
> mappings with and without write-protection. The use of write-protection is
> necessary when encrypting data "in place". The write-protect attribute is
> considered cacheable for loads, but not stores. This implies that the
> hardware will never give the core a dirty line with this memtype.

Patch 1: change memmap

This makes this aspect of the patchset much clearer and is better for
bisection.

> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  arch/x86/include/asm/fixmap.h        |    9 +++
>  arch/x86/include/asm/mem_encrypt.h   |   15 +++++
>  arch/x86/include/asm/pgtable_types.h |    8 +++
>  arch/x86/mm/ioremap.c                |   28 +++++++++
>  arch/x86/mm/mem_encrypt.c            |  102 ++++++++++++++++++++++++++++++++++
>  include/asm-generic/early_ioremap.h  |    2 +
>  mm/early_ioremap.c                   |   15 +++++
>  7 files changed, 179 insertions(+)

...

> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index d642cc5..06235b4 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -14,6 +14,9 @@
>  #include <linux/init.h>
>  #include <linux/mm.h>
>  
> +#include <asm/tlbflush.h>
> +#include <asm/fixmap.h>
> +
>  extern pmdval_t early_pmd_flags;
>  
>  /*
> @@ -24,6 +27,105 @@ extern pmdval_t early_pmd_flags;
>  unsigned long sme_me_mask __section(.data) = 0;
>  EXPORT_SYMBOL_GPL(sme_me_mask);
>  
> +/* Buffer used for early in-place encryption by BSP, no locking needed */
> +static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
> +
> +/*
> + * This routine does not change the underlying encryption setting of the
> + * page(s) that map this memory. It assumes that eventually the memory is
> + * meant to be accessed as encrypted but the contents are currently not
> + * encrypted.
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
> +		len = min_t(size_t, sizeof(sme_early_buffer), size);
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
> +		memcpy(sme_early_buffer, src, len);
> +		memcpy(dst, sme_early_buffer, len);

I still am missing the short explanation why we need the temporary buffer.


Oh, and we can save us the code duplication a little. Diff ontop of yours:

---
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 06235b477d7c..50e2c4fc7338 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -36,7 +36,8 @@ static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
  * meant to be accessed as encrypted but the contents are currently not
  * encrypted.
  */
-void __init sme_early_mem_enc(resource_size_t paddr, unsigned long size)
+static void __init noinline
+__mem_enc_dec(resource_size_t paddr, unsigned long size, bool enc)
 {
 	void *src, *dst;
 	size_t len;
@@ -54,15 +55,15 @@ void __init sme_early_mem_enc(resource_size_t paddr, unsigned long size)
 	while (size) {
 		len = min_t(size_t, sizeof(sme_early_buffer), size);
 
-		/* Create a mapping for non-encrypted write-protected memory */
-		src = early_memremap_dec_wp(paddr, len);
+		src = (enc ? early_memremap_dec_wp(paddr, len)
+			   : early_memremap_enc_wp(paddr, len));
 
-		/* Create a mapping for encrypted memory */
-		dst = early_memremap_enc(paddr, len);
+		dst = (enc ? early_memremap_enc(paddr, len)
+			   : early_memremap_dec(paddr, len));
 
 		/*
-		 * If a mapping can't be obtained to perform the encryption,
-		 * then encrypted access to that area will end up causing
+		 * If a mapping can't be obtained to perform the dec/encryption,
+		 * then (un-)encrypted access to that area will end up causing
 		 * a crash.
 		 */
 		BUG_ON(!src || !dst);
@@ -78,52 +79,14 @@ void __init sme_early_mem_enc(resource_size_t paddr, unsigned long size)
 	}
 }
 
-/*
- * This routine does not change the underlying encryption setting of the
- * page(s) that map this memory. It assumes that eventually the memory is
- * meant to be accessed as not encrypted but the contents are currently
- * encrypted.
- */
-void __init sme_early_mem_dec(resource_size_t paddr, unsigned long size)
+void __init sme_early_mem_enc(resource_size_t paddr, unsigned long size)
 {
-	void *src, *dst;
-	size_t len;
-
-	if (!sme_me_mask)
-		return;
-
-	local_flush_tlb();
-	wbinvd();
-
-	/*
-	 * There are limited number of early mapping slots, so map (at most)
-	 * one page at time.
-	 */
-	while (size) {
-		len = min_t(size_t, sizeof(sme_early_buffer), size);
-
-		/* Create a mapping for encrypted write-protected memory */
-		src = early_memremap_enc_wp(paddr, len);
-
-		/* Create a mapping for non-encrypted memory */
-		dst = early_memremap_dec(paddr, len);
-
-		/*
-		 * If a mapping can't be obtained to perform the decryption,
-		 * then un-encrypted access to that area will end up causing
-		 * a crash.
-		 */
-		BUG_ON(!src || !dst);
-
-		memcpy(sme_early_buffer, src, len);
-		memcpy(dst, sme_early_buffer, len);
-
-		early_memunmap(dst, len);
-		early_memunmap(src, len);
+	return __mem_enc_dec(paddr, size, true);
+}
 
-		paddr += len;
-		size -= len;
-	}
+void __init sme_early_mem_dec(resource_size_t paddr, unsigned long size)
+{
+	return __mem_enc_dec(paddr, size, false);
 }
 
 void __init sme_early_init(void)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
