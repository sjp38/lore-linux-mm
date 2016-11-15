Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE19A6B0289
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 10:17:06 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id p16so45324631qta.5
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 07:17:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r6si16870166qkr.318.2016.11.15.07.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 07:17:05 -0800 (PST)
Date: Tue, 15 Nov 2016 17:16:59 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v3 13/20] x86: DMA support for memory encryption
Message-ID: <20161115171443-mutt-send-email-mst@kernel.org>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003723.3280.62636.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161110003723.3280.62636.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Nov 09, 2016 at 06:37:23PM -0600, Tom Lendacky wrote:
> Since DMA addresses will effectively look like 48-bit addresses when the
> memory encryption mask is set, SWIOTLB is needed if the DMA mask of the
> device performing the DMA does not support 48-bits. SWIOTLB will be
> initialized to create un-encrypted bounce buffers for use by these devices.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/dma-mapping.h |    5 ++-
>  arch/x86/include/asm/mem_encrypt.h |    5 +++
>  arch/x86/kernel/pci-dma.c          |   11 ++++---
>  arch/x86/kernel/pci-nommu.c        |    2 +
>  arch/x86/kernel/pci-swiotlb.c      |    8 ++++-
>  arch/x86/mm/mem_encrypt.c          |   17 +++++++++++
>  include/linux/swiotlb.h            |    1 +
>  init/main.c                        |   13 ++++++++
>  lib/swiotlb.c                      |   58 +++++++++++++++++++++++++++++++-----
>  9 files changed, 103 insertions(+), 17 deletions(-)
> 
> diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
> index 4446162..c9cdcae 100644
> --- a/arch/x86/include/asm/dma-mapping.h
> +++ b/arch/x86/include/asm/dma-mapping.h
> @@ -12,6 +12,7 @@
>  #include <asm/io.h>
>  #include <asm/swiotlb.h>
>  #include <linux/dma-contiguous.h>
> +#include <asm/mem_encrypt.h>
>  
>  #ifdef CONFIG_ISA
>  # define ISA_DMA_BIT_MASK DMA_BIT_MASK(24)
> @@ -69,12 +70,12 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
>  
>  static inline dma_addr_t phys_to_dma(struct device *dev, phys_addr_t paddr)
>  {
> -	return paddr;
> +	return paddr | sme_me_mask;
>  }
>  
>  static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
>  {
> -	return daddr;
> +	return daddr & ~sme_me_mask;
>  }
>  #endif /* CONFIG_X86_DMA_REMAP */
>  
> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
> index d544481..a024451 100644
> --- a/arch/x86/include/asm/mem_encrypt.h
> +++ b/arch/x86/include/asm/mem_encrypt.h
> @@ -35,6 +35,11 @@ void __init sme_encrypt_ramdisk(resource_size_t paddr,
>  
>  void __init sme_early_init(void);
>  
> +/* Architecture __weak replacement functions */
> +void __init mem_encrypt_init(void);
> +
> +void swiotlb_set_mem_unenc(void *vaddr, unsigned long size);
> +
>  #define __sme_pa(x)		(__pa((x)) | sme_me_mask)
>  #define __sme_pa_nodebug(x)	(__pa_nodebug((x)) | sme_me_mask)
>  
> diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
> index d30c377..0ce28df 100644
> --- a/arch/x86/kernel/pci-dma.c
> +++ b/arch/x86/kernel/pci-dma.c
> @@ -92,9 +92,12 @@ again:
>  	/* CMA can be used only in the context which permits sleeping */
>  	if (gfpflags_allow_blocking(flag)) {
>  		page = dma_alloc_from_contiguous(dev, count, get_order(size));
> -		if (page && page_to_phys(page) + size > dma_mask) {
> -			dma_release_from_contiguous(dev, page, count);
> -			page = NULL;
> +		if (page) {
> +			addr = phys_to_dma(dev, page_to_phys(page));
> +			if (addr + size > dma_mask) {
> +				dma_release_from_contiguous(dev, page, count);
> +				page = NULL;
> +			}
>  		}
>  	}
>  	/* fallback */
> @@ -103,7 +106,7 @@ again:
>  	if (!page)
>  		return NULL;
>  
> -	addr = page_to_phys(page);
> +	addr = phys_to_dma(dev, page_to_phys(page));
>  	if (addr + size > dma_mask) {
>  		__free_pages(page, get_order(size));
>  
> diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
> index 00e71ce..922c10d 100644
> --- a/arch/x86/kernel/pci-nommu.c
> +++ b/arch/x86/kernel/pci-nommu.c
> @@ -30,7 +30,7 @@ static dma_addr_t nommu_map_page(struct device *dev, struct page *page,
>  				 enum dma_data_direction dir,
>  				 unsigned long attrs)
>  {
> -	dma_addr_t bus = page_to_phys(page) + offset;
> +	dma_addr_t bus = phys_to_dma(dev, page_to_phys(page)) + offset;
>  	WARN_ON(size == 0);
>  	if (!check_addr("map_single", dev, bus, size))
>  		return DMA_ERROR_CODE;
> diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
> index b47edb8..34a9e524 100644
> --- a/arch/x86/kernel/pci-swiotlb.c
> +++ b/arch/x86/kernel/pci-swiotlb.c
> @@ -12,6 +12,8 @@
>  #include <asm/dma.h>
>  #include <asm/xen/swiotlb-xen.h>
>  #include <asm/iommu_table.h>
> +#include <asm/mem_encrypt.h>
> +
>  int swiotlb __read_mostly;
>  
>  void *x86_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
> @@ -64,13 +66,15 @@ static struct dma_map_ops swiotlb_dma_ops = {
>   * pci_swiotlb_detect_override - set swiotlb to 1 if necessary
>   *
>   * This returns non-zero if we are forced to use swiotlb (by the boot
> - * option).
> + * option). If memory encryption is enabled then swiotlb will be set
> + * to 1 so that bounce buffers are allocated and used for devices that
> + * do not support the addressing range required for the encryption mask.
>   */
>  int __init pci_swiotlb_detect_override(void)
>  {
>  	int use_swiotlb = swiotlb | swiotlb_force;
>  
> -	if (swiotlb_force)
> +	if (swiotlb_force || sme_me_mask)
>  		swiotlb = 1;
>  
>  	return use_swiotlb;
> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
> index 41cfdf9..e351003 100644
> --- a/arch/x86/mm/mem_encrypt.c
> +++ b/arch/x86/mm/mem_encrypt.c
> @@ -13,6 +13,8 @@
>  #include <linux/linkage.h>
>  #include <linux/init.h>
>  #include <linux/mm.h>
> +#include <linux/dma-mapping.h>
> +#include <linux/swiotlb.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/fixmap.h>
> @@ -240,3 +242,18 @@ void __init sme_early_init(void)
>  	for (i = 0; i < ARRAY_SIZE(protection_map); i++)
>  		protection_map[i] = __pgprot(pgprot_val(protection_map[i]) | sme_me_mask);
>  }
> +
> +/* Architecture __weak replacement functions */
> +void __init mem_encrypt_init(void)
> +{
> +	if (!sme_me_mask)
> +		return;
> +
> +	/* Make SWIOTLB use an unencrypted DMA area */
> +	swiotlb_clear_encryption();
> +}
> +
> +void swiotlb_set_mem_unenc(void *vaddr, unsigned long size)
> +{
> +	sme_set_mem_unenc(vaddr, size);
> +}
> diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
> index 5f81f8a..5c909fc 100644
> --- a/include/linux/swiotlb.h
> +++ b/include/linux/swiotlb.h
> @@ -29,6 +29,7 @@ int swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose);
>  extern unsigned long swiotlb_nr_tbl(void);
>  unsigned long swiotlb_size_or_default(void);
>  extern int swiotlb_late_init_with_tbl(char *tlb, unsigned long nslabs);
> +extern void __init swiotlb_clear_encryption(void);
>  
>  /*
>   * Enumeration for sync targets
> diff --git a/init/main.c b/init/main.c
> index a8a58e2..ae37f0d 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -458,6 +458,10 @@ void __init __weak thread_stack_cache_init(void)
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
> @@ -598,6 +602,15 @@ asmlinkage __visible void __init start_kernel(void)
>  	 */
>  	locking_selftest();
>  
> +	/*
> +	 * This needs to be called before any devices perform DMA
> +	 * operations that might use the swiotlb bounce buffers.
> +	 * This call will mark the bounce buffers as un-encrypted so
> +	 * that their usage will not cause "plain-text" data to be
> +	 * decrypted when accessed.
> +	 */
> +	mem_encrypt_init();
> +
>  #ifdef CONFIG_BLK_DEV_INITRD
>  	if (initrd_start && !initrd_below_start_ok &&
>  	    page_to_pfn(virt_to_page((void *)initrd_start)) < min_low_pfn) {
> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
> index 22e13a0..638e99c 100644
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
> @@ -131,6 +132,17 @@ unsigned long swiotlb_size_or_default(void)
>  	return size ? size : (IO_TLB_DEFAULT_SIZE);
>  }
>  
> +void __weak swiotlb_set_mem_unenc(void *vaddr, unsigned long size)
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
> @@ -159,6 +171,31 @@ void swiotlb_print_info(void)
>  	       bytes >> 20, vstart, vend - 1);
>  }
>  
> +/*
> + * If memory encryption is active, the DMA address for an encrypted page may
> + * be beyond the range of the device. If bounce buffers are required be sure
> + * that they are not on an encrypted page. This should be called before the
> + * iotlb area is used.

Makes sense, but I think at least a dmesg warning here
might be a good idea.

A boot flag that says "don't enable devices that don't support
encryption" might be a good idea, too, since most people
don't read dmesg output and won't notice the message.


> + */
> +void __init swiotlb_clear_encryption(void)
> +{
> +	void *vaddr;
> +	unsigned long bytes;
> +
> +	if (no_iotlb_memory || !io_tlb_start || late_alloc)
> +		return;
> +
> +	vaddr = phys_to_virt(io_tlb_start);
> +	bytes = PAGE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT);
> +	swiotlb_set_mem_unenc(vaddr, bytes);
> +	memset(vaddr, 0, bytes);
> +
> +	vaddr = phys_to_virt(io_tlb_overflow_buffer);
> +	bytes = PAGE_ALIGN(io_tlb_overflow);
> +	swiotlb_set_mem_unenc(vaddr, bytes);
> +	memset(vaddr, 0, bytes);
> +}
> +
>  int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
>  {
>  	void *v_overflow_buffer;
> @@ -294,6 +331,8 @@ swiotlb_late_init_with_tbl(char *tlb, unsigned long nslabs)
>  	io_tlb_start = virt_to_phys(tlb);
>  	io_tlb_end = io_tlb_start + bytes;
>  
> +	/* Keep TLB in unencrypted memory if memory encryption is active */
> +	swiotlb_set_mem_unenc(tlb, bytes);
>  	memset(tlb, 0, bytes);
>  
>  	/*
> @@ -304,6 +343,9 @@ swiotlb_late_init_with_tbl(char *tlb, unsigned long nslabs)
>  	if (!v_overflow_buffer)
>  		goto cleanup2;
>  
> +	/* Keep overflow in unencrypted memory if memory encryption is active */
> +	swiotlb_set_mem_unenc(v_overflow_buffer, io_tlb_overflow);
> +	memset(v_overflow_buffer, 0, io_tlb_overflow);
>  	io_tlb_overflow_buffer = virt_to_phys(v_overflow_buffer);
>  
>  	/*
> @@ -541,7 +583,7 @@ static phys_addr_t
>  map_single(struct device *hwdev, phys_addr_t phys, size_t size,
>  	   enum dma_data_direction dir)
>  {
> -	dma_addr_t start_dma_addr = phys_to_dma(hwdev, io_tlb_start);
> +	dma_addr_t start_dma_addr = swiotlb_phys_to_dma(hwdev, io_tlb_start);
>  
>  	return swiotlb_tbl_map_single(hwdev, start_dma_addr, phys, size, dir);
>  }
> @@ -659,7 +701,7 @@ swiotlb_alloc_coherent(struct device *hwdev, size_t size,
>  			goto err_warn;
>  
>  		ret = phys_to_virt(paddr);
> -		dev_addr = phys_to_dma(hwdev, paddr);
> +		dev_addr = swiotlb_phys_to_dma(hwdev, paddr);
>  
>  		/* Confirm address can be DMA'd by device */
>  		if (dev_addr + size - 1 > dma_mask) {
> @@ -758,15 +800,15 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
>  	map = map_single(dev, phys, size, dir);
>  	if (map == SWIOTLB_MAP_ERROR) {
>  		swiotlb_full(dev, size, dir, 1);
> -		return phys_to_dma(dev, io_tlb_overflow_buffer);
> +		return swiotlb_phys_to_dma(dev, io_tlb_overflow_buffer);
>  	}
>  
> -	dev_addr = phys_to_dma(dev, map);
> +	dev_addr = swiotlb_phys_to_dma(dev, map);
>  
>  	/* Ensure that the address returned is DMA'ble */
>  	if (!dma_capable(dev, dev_addr, size)) {
>  		swiotlb_tbl_unmap_single(dev, map, size, dir);
> -		return phys_to_dma(dev, io_tlb_overflow_buffer);
> +		return swiotlb_phys_to_dma(dev, io_tlb_overflow_buffer);
>  	}
>  
>  	return dev_addr;
> @@ -901,7 +943,7 @@ swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
>  				sg_dma_len(sgl) = 0;
>  				return 0;
>  			}
> -			sg->dma_address = phys_to_dma(hwdev, map);
> +			sg->dma_address = swiotlb_phys_to_dma(hwdev, map);
>  		} else
>  			sg->dma_address = dev_addr;
>  		sg_dma_len(sg) = sg->length;
> @@ -985,7 +1027,7 @@ EXPORT_SYMBOL(swiotlb_sync_sg_for_device);
>  int
>  swiotlb_dma_mapping_error(struct device *hwdev, dma_addr_t dma_addr)
>  {
> -	return (dma_addr == phys_to_dma(hwdev, io_tlb_overflow_buffer));
> +	return (dma_addr == swiotlb_phys_to_dma(hwdev, io_tlb_overflow_buffer));
>  }
>  EXPORT_SYMBOL(swiotlb_dma_mapping_error);
>  
> @@ -998,6 +1040,6 @@ EXPORT_SYMBOL(swiotlb_dma_mapping_error);
>  int
>  swiotlb_dma_supported(struct device *hwdev, u64 mask)
>  {
> -	return phys_to_dma(hwdev, io_tlb_end - 1) <= mask;
> +	return swiotlb_phys_to_dma(hwdev, io_tlb_end - 1) <= mask;
>  }
>  EXPORT_SYMBOL(swiotlb_dma_supported);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
