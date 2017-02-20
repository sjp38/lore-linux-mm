From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v4 10/28] x86: Insure that boot memory areas are
	mapped properly
Date: Mon, 20 Feb 2017 20:45:29 +0100
Message-ID: <20170220194529.7dekuruclq7hfyhk@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
	<20170216154411.19244.99258.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170216154411.19244.99258.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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

On Thu, Feb 16, 2017 at 09:44:11AM -0600, Tom Lendacky wrote:
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

...

> diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
> index 182a4c7..03f8e74 100644
> --- a/arch/x86/kernel/head64.c
> +++ b/arch/x86/kernel/head64.c
> @@ -46,13 +46,18 @@ static void __init reset_early_page_tables(void)
>  	write_cr3(__sme_pa_nodebug(early_level4_pgt));
>  }
>  
> +void __init __early_pgtable_flush(void)
> +{
> +	write_cr3(__sme_pa_nodebug(early_level4_pgt));
> +}

Move that to mem_encrypt.c where it is used and make it static. The diff
below, ontop of this patch, seems to build fine here.

Also, aren't those mappings global so that you need to toggle CR4.PGE
for that?

PAGE_KERNEL at least has _PAGE_GLOBAL set.

> +
>  /* Create a new PMD entry */
> -int __init early_make_pgtable(unsigned long address)
> +int __init __early_make_pgtable(unsigned long address, pmdval_t pmd)

__early_make_pmd() then, since it creates a PMD entry.

>  	unsigned long physaddr = address - __PAGE_OFFSET;
>  	pgdval_t pgd, *pgd_p;
>  	pudval_t pud, *pud_p;
> -	pmdval_t pmd, *pmd_p;
> +	pmdval_t *pmd_p;
>  
>  	/* Invalid address or early pgt is done ?  */
>  	if (physaddr >= MAXMEM || read_cr3() != __sme_pa_nodebug(early_level4_pgt))

...

> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index ac3565c..ec548e9 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -16,8 +16,12 @@
>  
>  #include <asm/tlbflush.h>
>  #include <asm/fixmap.h>
> +#include <asm/setup.h>
> +#include <asm/bootparam.h>
>  
>  extern pmdval_t early_pmd_flags;
> +int __init __early_make_pgtable(unsigned long, pmdval_t);
> +void __init __early_pgtable_flush(void);

What's with the forward declarations?

Those should be in some header AFAICT.

>   * Since SME related variables are set early in the boot process they must
> @@ -103,6 +107,76 @@ void __init sme_early_decrypt(resource_size_t paddr, unsigned long size)
>  	__sme_early_enc_dec(paddr, size, false);
>  }

...

---
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 03f8e74c7223..c47500d72330 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -46,11 +46,6 @@ static void __init reset_early_page_tables(void)
 	write_cr3(__sme_pa_nodebug(early_level4_pgt));
 }
 
-void __init __early_pgtable_flush(void)
-{
-	write_cr3(__sme_pa_nodebug(early_level4_pgt));
-}
-
 /* Create a new PMD entry */
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd)
 {
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index ec548e9a76f1..0af020b36232 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -21,7 +21,7 @@
 
 extern pmdval_t early_pmd_flags;
 int __init __early_make_pgtable(unsigned long, pmdval_t);
-void __init __early_pgtable_flush(void);
+extern pgd_t early_level4_pgt[PTRS_PER_PGD];
 
 /*
  * Since SME related variables are set early in the boot process they must
@@ -34,6 +34,11 @@ EXPORT_SYMBOL_GPL(sme_me_mask);
 /* Buffer used for early in-place encryption by BSP, no locking needed */
 static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
 
+static void __init early_pgtable_flush(void)
+{
+	write_cr3(__sme_pa_nodebug(early_level4_pgt));
+}
+
 /*
  * This routine does not change the underlying encryption setting of the
  * page(s) that map this memory. It assumes that eventually the memory is
@@ -158,7 +163,7 @@ void __init sme_unmap_bootdata(char *real_mode_data)
 	 */
 	__sme_map_unmap_bootdata(real_mode_data, false);
 
-	__early_pgtable_flush();
+	early_pgtable_flush();
 }
 
 void __init sme_map_bootdata(char *real_mode_data)
@@ -174,7 +179,7 @@ void __init sme_map_bootdata(char *real_mode_data)
 	 */
 	__sme_map_unmap_bootdata(real_mode_data, true);
 
-	__early_pgtable_flush();
+	early_pgtable_flush();
 }
 
 void __init sme_early_init(void)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
