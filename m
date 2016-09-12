From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC PATCH v2 14/20] x86: DMA support for memory encryption
Date: Mon, 12 Sep 2016 12:58:15 +0200
Message-ID: <20160912105815.3z5bvzbcfjcj4ku7@pd.tnic>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
	<20160822223807.29880.69294.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160822223807.29880.69294.stgit-qCXWGYdRb2BnqfbPTmsdiZQ+2ll4COg0XqFh9Ls21Oc@public.gmane.org>
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

On Mon, Aug 22, 2016 at 05:38:07PM -0500, Tom Lendacky wrote:
> Since DMA addresses will effectively look like 48-bit addresses when the
> memory encryption mask is set, SWIOTLB is needed if the DMA mask of the
> device performing the DMA does not support 48-bits. SWIOTLB will be
> initialized to create un-encrypted bounce buffers for use by these devices.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>
> ---
>  arch/x86/include/asm/dma-mapping.h |    5 ++-
>  arch/x86/include/asm/mem_encrypt.h |    6 +++
>  arch/x86/kernel/pci-dma.c          |   11 ++++--
>  arch/x86/kernel/pci-nommu.c        |    2 +
>  arch/x86/kernel/pci-swiotlb.c      |    8 +++--
>  arch/x86/mm/mem_encrypt.c          |   22 ++++++++++++
>  include/linux/swiotlb.h            |    1 +
>  init/main.c                        |   13 +++++++
>  lib/swiotlb.c                      |   64 ++++++++++++++++++++++++++++++++----
>  9 files changed, 115 insertions(+), 17 deletions(-)

...

> @@ -172,3 +174,23 @@ void __init sme_early_init(void)
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
> +unsigned long swiotlb_get_me_mask(void)

This could just as well be named to something more generic:

swiotlb_get_clear_dma_mask() or so which basically means the mask of
bits which get cleared before returning DMA addresses...

> +{
> +	return sme_me_mask;
> +}
> +
> +void swiotlb_set_mem_dec(void *vaddr, unsigned long size)
> +{
> +	sme_set_mem_dec(vaddr, size);
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
> index a8a58e2..82c7cd9 100644
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
> +	 * that the usage of them will not cause "plain-text" data

	...that their usage will not cause ...

> +	 * to be decrypted when accessed.
> +	 */
> +	mem_encrypt_init();
> +
>  #ifdef CONFIG_BLK_DEV_INITRD
>  	if (initrd_start && !initrd_below_start_ok &&
>  	    page_to_pfn(virt_to_page((void *)initrd_start)) < min_low_pfn) {
> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
> index 22e13a0..15d5741 100644
> --- a/lib/swiotlb.c
> +++ b/lib/swiotlb.c
> @@ -131,6 +131,26 @@ unsigned long swiotlb_size_or_default(void)
>  	return size ? size : (IO_TLB_DEFAULT_SIZE);
>  }
>  
> +/*
> + * Support for memory encryption. If memory encryption is supported, then an
> + * override to these functions will be provided.
> + */

No need for that comment.

> +unsigned long __weak swiotlb_get_me_mask(void)
> +{
> +	return 0;
> +}
> +
> +void __weak swiotlb_set_mem_dec(void *vaddr, unsigned long size)
> +{
> +}
> +
> +/* For swiotlb, clear memory encryption mask from dma addresses */
> +static dma_addr_t swiotlb_phys_to_dma(struct device *hwdev,
> +				      phys_addr_t address)
> +{
> +	return phys_to_dma(hwdev, address) & ~swiotlb_get_me_mask();
> +}
> +
>  /* Note that this doesn't work with highmem page */
>  static dma_addr_t swiotlb_virt_to_bus(struct device *hwdev,
>  				      volatile void *address)
> @@ -159,6 +179,30 @@ void swiotlb_print_info(void)
>  	       bytes >> 20, vstart, vend - 1);
>  }
>  
> +/*
> + * If memory encryption is active, the DMA address for an encrypted page may
> + * be beyond the range of the device. If bounce buffers are required be sure
> + * that they are not on an encrypted page. This should be called before the
> + * iotlb area is used.
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
> +	swiotlb_set_mem_dec(vaddr, bytes);
> +	memset(vaddr, 0, bytes);

io_tlb_start is cleared...

> +
> +	vaddr = phys_to_virt(io_tlb_overflow_buffer);
> +	bytes = PAGE_ALIGN(io_tlb_overflow);
> +	swiotlb_set_mem_dec(vaddr, bytes);

... but io_tlb_overflow_buffer isn't? I don't see the difference here.

> +}
> +
>  int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
>  {
>  	void *v_overflow_buffer;
-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
