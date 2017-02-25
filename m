Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C827D6B0038
	for <linux-mm@kvack.org>; Sat, 25 Feb 2017 12:11:07 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id k202so22588338lfe.7
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 09:11:07 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id d204si6142837lfd.69.2017.02.25.09.11.05
        for <linux-mm@kvack.org>;
        Sat, 25 Feb 2017 09:11:06 -0800 (PST)
Date: Sat, 25 Feb 2017 18:10:24 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC PATCH v4 18/28] x86: DMA support for memory encryption
Message-ID: <20170225171024.xzlfox56rbbflxfo@pd.tnic>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154604.19244.69522.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170216154604.19244.69522.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On Thu, Feb 16, 2017 at 09:46:04AM -0600, Tom Lendacky wrote:
> Since DMA addresses will effectively look like 48-bit addresses when the
> memory encryption mask is set, SWIOTLB is needed if the DMA mask of the
> device performing the DMA does not support 48-bits. SWIOTLB will be
> initialized to create decrypted bounce buffers for use by these devices.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---

Just nitpicks below...

> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index ec548e9..a46bcf4 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -13,11 +13,14 @@
>  #include <linux/linkage.h>
>  #include <linux/init.h>
>  #include <linux/mm.h>
> +#include <linux/dma-mapping.h>
> +#include <linux/swiotlb.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/fixmap.h>
>  #include <asm/setup.h>
>  #include <asm/bootparam.h>
> +#include <asm/cacheflush.h>
>  
>  extern pmdval_t early_pmd_flags;
>  int __init __early_make_pgtable(unsigned long, pmdval_t);
> @@ -192,3 +195,22 @@ void __init sme_early_init(void)
>  	for (i = 0; i < ARRAY_SIZE(protection_map); i++)
>  		protection_map[i] = pgprot_encrypted(protection_map[i]);
>  }
> +
> +/* Architecture __weak replacement functions */
> +void __init mem_encrypt_init(void)
> +{
> +	if (!sme_me_mask)

	    !sme_active()

no?

Unless we're going to be switching SME dynamically at run time?

> +		return;
> +
> +	/* Call into SWIOTLB to update the SWIOTLB DMA buffers */
> +	swiotlb_update_mem_attributes();
> +}
> +
> +void swiotlb_set_mem_attributes(void *vaddr, unsigned long size)
> +{
> +	WARN(PAGE_ALIGN(size) != size,
> +	     "size is not page aligned (%#lx)\n", size);

"page-aligned" I guess.

> +
> +	/* Make the SWIOTLB buffer area decrypted */
> +	set_memory_decrypted((unsigned long)vaddr, size >> PAGE_SHIFT);
> +}
> diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
> index 4ee479f..15e7160 100644
> --- a/include/linux/swiotlb.h
> +++ b/include/linux/swiotlb.h
> @@ -35,6 +35,7 @@ enum swiotlb_force {
>  extern unsigned long swiotlb_nr_tbl(void);
>  unsigned long swiotlb_size_or_default(void);
>  extern int swiotlb_late_init_with_tbl(char *tlb, unsigned long nslabs);
> +extern void __init swiotlb_update_mem_attributes(void);
>  
>  /*
>   * Enumeration for sync targets
> diff --git a/init/main.c b/init/main.c
> index 8222caa..ba13f8f 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -466,6 +466,10 @@ void __init __weak thread_stack_cache_init(void)
>  }
>  #endif
>  
> +void __init __weak mem_encrypt_init(void)
> +{
> +}
> +
>  /*
>   * Set up kernel memory allocators
>   */
> @@ -614,6 +618,15 @@ asmlinkage __visible void __init start_kernel(void)
>  	 */
>  	locking_selftest();
>  
> +	/*
> +	 * This needs to be called before any devices perform DMA
> +	 * operations that might use the swiotlb bounce buffers.

					 SWIOTLB

> +	 * This call will mark the bounce buffers as decrypted so
> +	 * that their usage will not cause "plain-text" data to be
> +	 * decrypted when accessed.
> +	 */
> +	mem_encrypt_init();
> +
>  #ifdef CONFIG_BLK_DEV_INITRD
>  	if (initrd_start && !initrd_below_start_ok &&
>  	    page_to_pfn(virt_to_page((void *)initrd_start)) < min_low_pfn) {
> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
> index a8d74a7..c463067 100644
> --- a/lib/swiotlb.c
> +++ b/lib/swiotlb.c
> @@ -30,6 +30,7 @@
>  #include <linux/highmem.h>
>  #include <linux/gfp.h>
>  #include <linux/scatterlist.h>
> +#include <linux/mem_encrypt.h>
>  
>  #include <asm/io.h>
>  #include <asm/dma.h>
> @@ -155,6 +156,17 @@ unsigned long swiotlb_size_or_default(void)
>  	return size ? size : (IO_TLB_DEFAULT_SIZE);
>  }
>  
> +void __weak swiotlb_set_mem_attributes(void *vaddr, unsigned long size)
> +{
> +}
> +
> +/* For swiotlb, clear memory encryption mask from dma addresses */
> +static dma_addr_t swiotlb_phys_to_dma(struct device *hwdev,
> +				      phys_addr_t address)
> +{
> +	return phys_to_dma(hwdev, address) & ~sme_me_mask;
> +}
> +
>  /* Note that this doesn't work with highmem page */
>  static dma_addr_t swiotlb_virt_to_bus(struct device *hwdev,
>  				      volatile void *address)
> @@ -183,6 +195,31 @@ void swiotlb_print_info(void)
>  	       bytes >> 20, vstart, vend - 1);
>  }
>  
> +/*
> + * Early SWIOTLB allocation may be to early to allow an architecture to

				      too

> + * perform the desired operations.  This function allows the architecture to
> + * call SWIOTLB when the operations are possible.  This function needs to be

s/This function/It/

> + * called before the SWIOTLB memory is used.
> + */
> +void __init swiotlb_update_mem_attributes(void)
> +{
> +	void *vaddr;
> +	unsigned long bytes;
> +
> +	if (no_iotlb_memory || late_alloc)
> +		return;
> +
> +	vaddr = phys_to_virt(io_tlb_start);
> +	bytes = PAGE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT);
> +	swiotlb_set_mem_attributes(vaddr, bytes);
> +	memset(vaddr, 0, bytes);
> +
> +	vaddr = phys_to_virt(io_tlb_overflow_buffer);
> +	bytes = PAGE_ALIGN(io_tlb_overflow);
> +	swiotlb_set_mem_attributes(vaddr, bytes);
> +	memset(vaddr, 0, bytes);
> +}
> +
>  int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
>  {
>  	void *v_overflow_buffer;

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
