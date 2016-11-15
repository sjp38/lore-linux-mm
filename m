Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91CB76B02A9
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 13:17:46 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id j49so47072885qta.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 10:17:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c33si12698075qte.33.2016.11.15.10.17.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 10:17:45 -0800 (PST)
Date: Tue, 15 Nov 2016 19:17:36 +0100
From: Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>
Subject: Re: [RFC PATCH v3 13/20] x86: DMA support for memory encryption
Message-ID: <20161115181736.GA14060@potion>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003723.3280.62636.stgit@tlendack-t1.amdoffice.net>
 <20161115143943.GC2185@potion>
 <d5ebd13d-1278-8714-3f03-8ee7f04a2b38@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d5ebd13d-1278-8714-3f03-8ee7f04a2b38@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

2016-11-15 11:02-0600, Tom Lendacky:
> On 11/15/2016 8:39 AM, Radim KrA?mA!A? wrote:
>> 2016-11-09 18:37-0600, Tom Lendacky:
>>> Since DMA addresses will effectively look like 48-bit addresses when the
>>> memory encryption mask is set, SWIOTLB is needed if the DMA mask of the
>>> device performing the DMA does not support 48-bits. SWIOTLB will be
>>> initialized to create un-encrypted bounce buffers for use by these devices.
>>>
>>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>>> ---
>>> diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
>>> @@ -64,13 +66,15 @@ static struct dma_map_ops swiotlb_dma_ops = {
>>>   * pci_swiotlb_detect_override - set swiotlb to 1 if necessary
>>>   *
>>>   * This returns non-zero if we are forced to use swiotlb (by the boot
>>> - * option).
>>> + * option). If memory encryption is enabled then swiotlb will be set
>>> + * to 1 so that bounce buffers are allocated and used for devices that
>>> + * do not support the addressing range required for the encryption mask.
>>>   */
>>>  int __init pci_swiotlb_detect_override(void)
>>>  {
>>>  	int use_swiotlb = swiotlb | swiotlb_force;
>>>  
>>> -	if (swiotlb_force)
>>> +	if (swiotlb_force || sme_me_mask)
>>>  		swiotlb = 1;
>>>  
>>>  	return use_swiotlb;
>> 
>> We want to return 1 even if only sme_me_mask is 1, because the return
>> value is used for detection.  The following would be less obscure, IMO:
>> 
>> 	if (swiotlb_force || sme_me_mask)
>> 		swiotlb = 1;
>> 
>> 	return swiotlb;
> 
> If we do that then all DMA would go through the swiotlb bounce buffers.

No, that is decided for example in swiotlb_map_page() and we need to
call pci_swiotlb_init() to register that function.

> By setting swiotlb to 1 we indicate that the bounce buffers will be
> needed for those devices that can't support the addressing range when
> the encryption bit is set (48 bit DMA). But if the device can support
> the addressing range we won't use the bounce buffers.

If we return 0 here, then pci_swiotlb_init() will not be called =>
dma_ops won't be set to swiotlb_dma_ops => we won't use bounce buffers.

>> We setup encrypted swiotlb and then decrypt it, but sometimes set it up
>> decrypted (late_alloc) ... why isn't the swiotlb set up decrypted
>> directly?
> 
> When swiotlb is allocated in swiotlb_init(), it is too early to make
> use of the api to the change the page attributes. Because of this,
> the callback to make those changes is needed.

Thanks. (I don't know page table setup enough to see a lesser evil. :])

>>> @@ -541,7 +583,7 @@ static phys_addr_t
>>>  map_single(struct device *hwdev, phys_addr_t phys, size_t size,
>>>  	   enum dma_data_direction dir)
>>>  {
>>> -	dma_addr_t start_dma_addr = phys_to_dma(hwdev, io_tlb_start);
>>> +	dma_addr_t start_dma_addr = swiotlb_phys_to_dma(hwdev, io_tlb_start);
>> 
>> We have decrypted io_tlb_start before, so shouldn't its physical address
>> be saved without the sme bit?  (Which changes a lot ...)
> 
> I'm not sure what you mean here, can you elaborate a bit more?

The C-bit (sme bit) is a part of the physical address.
If we know that a certain physical page should be accessed as
unencrypted (the bounce buffer) then the C-bit is 0.
I'm wondering why we save the physical address with the C-bit set when
we know that it can't be accessed that way (because we remove it every
time).

The naming is a bit confusing, because physical addresses are actually
virtualized by SME -- maybe we should be calling them SME addresses?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
