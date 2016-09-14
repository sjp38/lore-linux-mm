Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DDA6C6B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 09:37:03 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q188so43966062oia.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 06:37:03 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0052.outbound.protection.outlook.com. [104.47.42.52])
        by mx.google.com with ESMTPS id a67si9868812oic.250.2016.09.14.06.36.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 06:36:45 -0700 (PDT)
Subject: Re: [RFC PATCH v2 14/20] x86: DMA support for memory encryption
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223807.29880.69294.stgit@tlendack-t1.amdoffice.net>
 <20160912105815.3z5bvzbcfjcj4ku7@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <cb3e6b91-44f7-ee01-6da1-82eb32243b85@amd.com>
Date: Wed, 14 Sep 2016 08:36:30 -0500
MIME-Version: 1.0
In-Reply-To: <20160912105815.3z5bvzbcfjcj4ku7@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/12/2016 05:58 AM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:38:07PM -0500, Tom Lendacky wrote:
>> Since DMA addresses will effectively look like 48-bit addresses when the
>> memory encryption mask is set, SWIOTLB is needed if the DMA mask of the
>> device performing the DMA does not support 48-bits. SWIOTLB will be
>> initialized to create un-encrypted bounce buffers for use by these devices.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/dma-mapping.h |    5 ++-
>>  arch/x86/include/asm/mem_encrypt.h |    6 +++
>>  arch/x86/kernel/pci-dma.c          |   11 ++++--
>>  arch/x86/kernel/pci-nommu.c        |    2 +
>>  arch/x86/kernel/pci-swiotlb.c      |    8 +++--
>>  arch/x86/mm/mem_encrypt.c          |   22 ++++++++++++
>>  include/linux/swiotlb.h            |    1 +
>>  init/main.c                        |   13 +++++++
>>  lib/swiotlb.c                      |   64 ++++++++++++++++++++++++++++++++----
>>  9 files changed, 115 insertions(+), 17 deletions(-)
> 
> ...
> 
>> @@ -172,3 +174,23 @@ void __init sme_early_init(void)
>>  	for (i = 0; i < ARRAY_SIZE(protection_map); i++)
>>  		protection_map[i] = __pgprot(pgprot_val(protection_map[i]) | sme_me_mask);
>>  }
>> +
>> +/* Architecture __weak replacement functions */
>> +void __init mem_encrypt_init(void)
>> +{
>> +	if (!sme_me_mask)
>> +		return;
>> +
>> +	/* Make SWIOTLB use an unencrypted DMA area */
>> +	swiotlb_clear_encryption();
>> +}
>> +
>> +unsigned long swiotlb_get_me_mask(void)
> 
> This could just as well be named to something more generic:
> 
> swiotlb_get_clear_dma_mask() or so which basically means the mask of
> bits which get cleared before returning DMA addresses...

Ok.

> 
>> +{
>> +	return sme_me_mask;
>> +}
>> +
>> +void swiotlb_set_mem_dec(void *vaddr, unsigned long size)
>> +{
>> +	sme_set_mem_dec(vaddr, size);
>> +}
>> diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
>> index 5f81f8a..5c909fc 100644
>> --- a/include/linux/swiotlb.h
>> +++ b/include/linux/swiotlb.h
>> @@ -29,6 +29,7 @@ int swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose);
>>  extern unsigned long swiotlb_nr_tbl(void);
>>  unsigned long swiotlb_size_or_default(void);
>>  extern int swiotlb_late_init_with_tbl(char *tlb, unsigned long nslabs);
>> +extern void __init swiotlb_clear_encryption(void);
>>  
>>  /*
>>   * Enumeration for sync targets
>> diff --git a/init/main.c b/init/main.c
>> index a8a58e2..82c7cd9 100644
>> --- a/init/main.c
>> +++ b/init/main.c
>> @@ -458,6 +458,10 @@ void __init __weak thread_stack_cache_init(void)
>>  }
>>  #endif
>>  
>> +void __init __weak mem_encrypt_init(void)
>> +{
>> +}
>> +
>>  /*
>>   * Set up kernel memory allocators
>>   */
>> @@ -598,6 +602,15 @@ asmlinkage __visible void __init start_kernel(void)
>>  	 */
>>  	locking_selftest();
>>  
>> +	/*
>> +	 * This needs to be called before any devices perform DMA
>> +	 * operations that might use the swiotlb bounce buffers.
>> +	 * This call will mark the bounce buffers as un-encrypted so
>> +	 * that the usage of them will not cause "plain-text" data
> 
> 	...that their usage will not cause ...

Ok.

> 
>> +	 * to be decrypted when accessed.
>> +	 */
>> +	mem_encrypt_init();
>> +
>>  #ifdef CONFIG_BLK_DEV_INITRD
>>  	if (initrd_start && !initrd_below_start_ok &&
>>  	    page_to_pfn(virt_to_page((void *)initrd_start)) < min_low_pfn) {
>> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
>> index 22e13a0..15d5741 100644
>> --- a/lib/swiotlb.c
>> +++ b/lib/swiotlb.c
>> @@ -131,6 +131,26 @@ unsigned long swiotlb_size_or_default(void)
>>  	return size ? size : (IO_TLB_DEFAULT_SIZE);
>>  }
>>  
>> +/*
>> + * Support for memory encryption. If memory encryption is supported, then an
>> + * override to these functions will be provided.
>> + */
> 
> No need for that comment.

Ok.

> 
>> +unsigned long __weak swiotlb_get_me_mask(void)
>> +{
>> +	return 0;
>> +}
>> +
>> +void __weak swiotlb_set_mem_dec(void *vaddr, unsigned long size)
>> +{
>> +}
>> +
>> +/* For swiotlb, clear memory encryption mask from dma addresses */
>> +static dma_addr_t swiotlb_phys_to_dma(struct device *hwdev,
>> +				      phys_addr_t address)
>> +{
>> +	return phys_to_dma(hwdev, address) & ~swiotlb_get_me_mask();
>> +}
>> +
>>  /* Note that this doesn't work with highmem page */
>>  static dma_addr_t swiotlb_virt_to_bus(struct device *hwdev,
>>  				      volatile void *address)
>> @@ -159,6 +179,30 @@ void swiotlb_print_info(void)
>>  	       bytes >> 20, vstart, vend - 1);
>>  }
>>  
>> +/*
>> + * If memory encryption is active, the DMA address for an encrypted page may
>> + * be beyond the range of the device. If bounce buffers are required be sure
>> + * that they are not on an encrypted page. This should be called before the
>> + * iotlb area is used.
>> + */
>> +void __init swiotlb_clear_encryption(void)
>> +{
>> +	void *vaddr;
>> +	unsigned long bytes;
>> +
>> +	if (no_iotlb_memory || !io_tlb_start || late_alloc)
>> +		return;
>> +
>> +	vaddr = phys_to_virt(io_tlb_start);
>> +	bytes = PAGE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT);
>> +	swiotlb_set_mem_dec(vaddr, bytes);
>> +	memset(vaddr, 0, bytes);
> 
> io_tlb_start is cleared...
> 
>> +
>> +	vaddr = phys_to_virt(io_tlb_overflow_buffer);
>> +	bytes = PAGE_ALIGN(io_tlb_overflow);
>> +	swiotlb_set_mem_dec(vaddr, bytes);
> 
> ... but io_tlb_overflow_buffer isn't? I don't see the difference here.

Yup, I missed that one.  Will memset this as well.

Thanks,
Tom

> 
>> +}
>> +
>>  int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
>>  {
>>  	void *v_overflow_buffer;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
