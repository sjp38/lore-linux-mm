Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9DCB56B02A3
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 12:02:31 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id j49so46446176qta.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 09:02:31 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0056.outbound.protection.outlook.com. [104.47.37.56])
        by mx.google.com with ESMTPS id p66si2925336oib.270.2016.11.15.09.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Nov 2016 09:02:29 -0800 (PST)
Subject: Re: [RFC PATCH v3 13/20] x86: DMA support for memory encryption
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003723.3280.62636.stgit@tlendack-t1.amdoffice.net>
 <20161115143943.GC2185@potion>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <d5ebd13d-1278-8714-3f03-8ee7f04a2b38@amd.com>
Date: Tue, 15 Nov 2016 11:02:20 -0600
MIME-Version: 1.0
In-Reply-To: <20161115143943.GC2185@potion>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/15/2016 8:39 AM, Radim KrA?mA!A? wrote:
> 2016-11-09 18:37-0600, Tom Lendacky:
>> Since DMA addresses will effectively look like 48-bit addresses when the
>> memory encryption mask is set, SWIOTLB is needed if the DMA mask of the
>> device performing the DMA does not support 48-bits. SWIOTLB will be
>> initialized to create un-encrypted bounce buffers for use by these devices.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>> diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
>> @@ -30,7 +30,7 @@ static dma_addr_t nommu_map_page(struct device *dev, struct page *page,
>>  				 enum dma_data_direction dir,
>>  				 unsigned long attrs)
>>  {
>> -	dma_addr_t bus = page_to_phys(page) + offset;
>> +	dma_addr_t bus = phys_to_dma(dev, page_to_phys(page)) + offset;
>>  	WARN_ON(size == 0);
>>  	if (!check_addr("map_single", dev, bus, size))
>>  		return DMA_ERROR_CODE;
>> diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
>> @@ -12,6 +12,8 @@
>>  int swiotlb __read_mostly;
>>  
>>  void *x86_swiotlb_alloc_coherent(struct device *hwdev, size_t size,
>> @@ -64,13 +66,15 @@ static struct dma_map_ops swiotlb_dma_ops = {
>>   * pci_swiotlb_detect_override - set swiotlb to 1 if necessary
>>   *
>>   * This returns non-zero if we are forced to use swiotlb (by the boot
>> - * option).
>> + * option). If memory encryption is enabled then swiotlb will be set
>> + * to 1 so that bounce buffers are allocated and used for devices that
>> + * do not support the addressing range required for the encryption mask.
>>   */
>>  int __init pci_swiotlb_detect_override(void)
>>  {
>>  	int use_swiotlb = swiotlb | swiotlb_force;
>>  
>> -	if (swiotlb_force)
>> +	if (swiotlb_force || sme_me_mask)
>>  		swiotlb = 1;
>>  
>>  	return use_swiotlb;
> 
> We want to return 1 even if only sme_me_mask is 1, because the return
> value is used for detection.  The following would be less obscure, IMO:
> 
> 	if (swiotlb_force || sme_me_mask)
> 		swiotlb = 1;
> 
> 	return swiotlb;

If we do that then all DMA would go through the swiotlb bounce buffers.
By setting swiotlb to 1 we indicate that the bounce buffers will be
needed for those devices that can't support the addressing range when
the encryption bit is set (48 bit DMA). But if the device can support
the addressing range we won't use the bounce buffers.

> 
>> diff --git a/init/main.c b/init/main.c
>> @@ -598,6 +602,15 @@ asmlinkage __visible void __init start_kernel(void)
>>  	 */
>>  	locking_selftest();
>>  
>> +	/*
>> +	 * This needs to be called before any devices perform DMA
>> +	 * operations that might use the swiotlb bounce buffers.
>> +	 * This call will mark the bounce buffers as un-encrypted so
>> +	 * that their usage will not cause "plain-text" data to be
>> +	 * decrypted when accessed.
>> +	 */
>> +	mem_encrypt_init();
> 
> (Comments below are connected to the reason why we call this.)
> 
>> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
>> @@ -159,6 +171,31 @@ void swiotlb_print_info(void)
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
> 
> io_tlb_start seems redundant -- when can !no_iotlb_memory &&
> !io_tlb_start happen?

Yes, the io_tlb_start check can be removed.

> 
> Is the order of calls
>   1) swiotlb init
>   2) SME init
>   3) swiotlb late init 
> ?

Yes, sort of.  The swiotlb late init may not be called.

> 
> We setup encrypted swiotlb and then decrypt it, but sometimes set it up
> decrypted (late_alloc) ... why isn't the swiotlb set up decrypted
> directly?

When swiotlb is allocated in swiotlb_init(), it is too early to make
use of the api to the change the page attributes. Because of this,
the callback to make those changes is needed.

> 
>> +		return;
>> +
>> +	vaddr = phys_to_virt(io_tlb_start);
>> +	bytes = PAGE_ALIGN(io_tlb_nslabs << IO_TLB_SHIFT);
>> +	swiotlb_set_mem_unenc(vaddr, bytes);
>> +	memset(vaddr, 0, bytes);
>> +
>> +	vaddr = phys_to_virt(io_tlb_overflow_buffer);
>> +	bytes = PAGE_ALIGN(io_tlb_overflow);
>> +	swiotlb_set_mem_unenc(vaddr, bytes);
>> +	memset(vaddr, 0, bytes);
>> +}
>> +
>> @@ -541,7 +583,7 @@ static phys_addr_t
>>  map_single(struct device *hwdev, phys_addr_t phys, size_t size,
>>  	   enum dma_data_direction dir)
>>  {
>> -	dma_addr_t start_dma_addr = phys_to_dma(hwdev, io_tlb_start);
>> +	dma_addr_t start_dma_addr = swiotlb_phys_to_dma(hwdev, io_tlb_start);
> 
> We have decrypted io_tlb_start before, so shouldn't its physical address
> be saved without the sme bit?  (Which changes a lot ...)

I'm not sure what you mean here, can you elaborate a bit more?

Thanks,
Tom

> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
