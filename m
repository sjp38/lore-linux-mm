Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD2B36B025E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 19:50:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so263384648pfe.3
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 16:50:07 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0094.outbound.protection.outlook.com. [157.56.110.94])
        by mx.google.com with ESMTPS id c127si18911598pfa.69.2016.04.29.16.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Apr 2016 16:50:06 -0700 (PDT)
Subject: Re: [RFC PATCH v1 13/18] x86: DMA support for memory encryption
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225812.13567.91220.stgit@tlendack-t1.amdoffice.net>
 <20160429071743.GC11592@char.us.oracle.com> <572379ED.9050404@amd.com>
 <20160429162757.GA1191@char.us.oracle.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <5723F324.9040909@amd.com>
Date: Fri, 29 Apr 2016 18:49:56 -0500
MIME-Version: 1.0
In-Reply-To: <20160429162757.GA1191@char.us.oracle.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 04/29/2016 11:27 AM, Konrad Rzeszutek Wilk wrote:
> On Fri, Apr 29, 2016 at 10:12:45AM -0500, Tom Lendacky wrote:
>> On 04/29/2016 02:17 AM, Konrad Rzeszutek Wilk wrote:
>>> On Tue, Apr 26, 2016 at 05:58:12PM -0500, Tom Lendacky wrote:
>>>> Since DMA addresses will effectively look like 48-bit addresses when the
>>>> memory encryption mask is set, SWIOTLB is needed if the DMA mask of the
>>>> device performing the DMA does not support 48-bits. SWIOTLB will be
>>>> initialized to create un-encrypted bounce buffers for use by these devices.
>>>>
>>>
>>>
>>> I presume the sme_me_mask does not use the lower 48 bits?
>>
>> The sme_me_mask will actually be bit 47. So, when applied, the address
>> will become a 48-bit address.
>>
>>>
>>>
>>> ..snip..
>>>> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
>>>> index 7d56d1b..594dc65 100644
>>>> --- a/arch/x86/mm/mem_encrypt.c
>>>> +++ b/arch/x86/mm/mem_encrypt.c
>>>> @@ -12,6 +12,8 @@
>>>>  
>>>>  #include <linux/init.h>
>>>>  #include <linux/mm.h>
>>>> +#include <linux/dma-mapping.h>
>>>> +#include <linux/swiotlb.h>
>>>>  
>>>>  #include <asm/mem_encrypt.h>
>>>>  #include <asm/cacheflush.h>
>>>> @@ -168,6 +170,25 @@ void __init sme_early_init(void)
>>>>  }
>>>>  
>>>>  /* Architecture __weak replacement functions */
>>>> +void __init mem_encrypt_init(void)
>>>> +{
>>>> +	if (!sme_me_mask)
>>>> +		return;
>>>> +
>>>> +	/* Make SWIOTLB use an unencrypted DMA area */
>>>> +	swiotlb_clear_encryption();
>>>> +}
>>>> +
>>>> +unsigned long swiotlb_get_me_mask(void)
>>>> +{
>>>> +	return sme_me_mask;
>>>> +}
>>>> +
>>>> +void swiotlb_set_mem_dec(void *vaddr, unsigned long size)
>>>> +{
>>>> +	sme_set_mem_dec(vaddr, size);
>>>> +}
>>>> +
>>>>  void __init *efi_me_early_memremap(resource_size_t paddr,
>>>>  				   unsigned long size)
>>>>  {
>>>> diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
>>>> index 017fced..121b9de 100644
>>>> --- a/include/linux/swiotlb.h
>>>> +++ b/include/linux/swiotlb.h
>>>> @@ -30,6 +30,7 @@ int swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose);
>>>>  extern unsigned long swiotlb_nr_tbl(void);
>>>>  unsigned long swiotlb_size_or_default(void);
>>>>  extern int swiotlb_late_init_with_tbl(char *tlb, unsigned long nslabs);
>>>> +extern void __init swiotlb_clear_encryption(void);
>>>>  
>>>>  /*
>>>>   * Enumeration for sync targets
>>>> diff --git a/init/main.c b/init/main.c
>>>> index b3c6e36..1013d1c 100644
>>>> --- a/init/main.c
>>>> +++ b/init/main.c
>>>> @@ -458,6 +458,10 @@ void __init __weak thread_info_cache_init(void)
>>>>  }
>>>>  #endif
>>>>  
>>>> +void __init __weak mem_encrypt_init(void)
>>>> +{
>>>> +}
>>>> +
>>>>  /*
>>>>   * Set up kernel memory allocators
>>>>   */
>>>> @@ -597,6 +601,8 @@ asmlinkage __visible void __init start_kernel(void)
>>>>  	 */
>>>>  	locking_selftest();
>>>>  
>>>> +	mem_encrypt_init();
>>>> +
>>>>  #ifdef CONFIG_BLK_DEV_INITRD
>>>>  	if (initrd_start && !initrd_below_start_ok &&
>>>>  	    page_to_pfn(virt_to_page((void *)initrd_start)) < min_low_pfn) {
>>>
>>> What happens if devices use the bounce buffer before mem_encrypt_init()?
>>
>> The call to mem_encrypt_init is early in the boot process, I may have
>> overlooked something, but what devices would be performing DMA before
>> this?
> 
> I am not saying that you overlooked. Merely wondering if somebody re-orders these
> calls what would happen. It maybe also good to have a comment right before
> mem_encrpyt_init stating what will happen if the device does DMA before the function
> is called.
> 

Ah, ok. Before mem_encrypt_init is called the bounce buffers will be
marked as encrypted in the page tables. The use of the bounce buffers
will not have the memory encryption bit as part of the DMA address so a
device will DMA into memory in the clear. When the bounce buffer is
copied to the original buffer it will be accessed by a virtual address
that has the memory encryption bit set in the page tables. So the
plaintext data that was DMA'd in will be decrypted resulting in invalid
data in the destination buffer.

I'll be sure to add a comment before the call.

Thanks,
Tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
