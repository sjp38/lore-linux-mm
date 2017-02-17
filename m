Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B4C474405EE
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 11:51:45 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id o64so15363338pfb.2
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:51:45 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0087.outbound.protection.outlook.com. [104.47.40.87])
        by mx.google.com with ESMTPS id i3si10773054plk.133.2017.02.17.08.51.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 17 Feb 2017 08:51:44 -0800 (PST)
Subject: Re: [RFC PATCH v4 19/28] swiotlb: Add warnings for use of bounce
 buffers with SME
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154619.19244.76653.stgit@tlendack-t1.amdoffice.net>
 <20170217155955.GK30272@char.us.ORACLE.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <17c8099a-5495-5f1d-4c8a-bd9f5d2c5e58@amd.com>
Date: Fri, 17 Feb 2017 10:51:31 -0600
MIME-Version: 1.0
In-Reply-To: <20170217155955.GK30272@char.us.ORACLE.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/17/2017 9:59 AM, Konrad Rzeszutek Wilk wrote:
> On Thu, Feb 16, 2017 at 09:46:19AM -0600, Tom Lendacky wrote:
>> Add warnings to let the user know when bounce buffers are being used for
>> DMA when SME is active.  Since the bounce buffers are not in encrypted
>> memory, these notifications are to allow the user to determine some
>> appropriate action - if necessary.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/mem_encrypt.h |   11 +++++++++++
>>  include/linux/dma-mapping.h        |   11 +++++++++++
>>  include/linux/mem_encrypt.h        |    6 ++++++
>>  lib/swiotlb.c                      |    3 +++
>>  4 files changed, 31 insertions(+)
>>
>> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
>> index 87e816f..5a17f1b 100644
>> --- a/arch/x86/include/asm/mem_encrypt.h
>> +++ b/arch/x86/include/asm/mem_encrypt.h
>> @@ -26,6 +26,11 @@ static inline bool sme_active(void)
>>  	return (sme_me_mask) ? true : false;
>>  }
>>
>> +static inline u64 sme_dma_mask(void)
>> +{
>> +	return ((u64)sme_me_mask << 1) - 1;
>> +}
>> +
>>  void __init sme_early_encrypt(resource_size_t paddr,
>>  			      unsigned long size);
>>  void __init sme_early_decrypt(resource_size_t paddr,
>> @@ -53,6 +58,12 @@ static inline bool sme_active(void)
>>  {
>>  	return false;
>>  }
>> +
>> +static inline u64 sme_dma_mask(void)
>> +{
>> +	return 0ULL;
>> +}
>> +
>>  #endif
>>
>>  static inline void __init sme_early_encrypt(resource_size_t paddr,
>> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
>> index 10c5a17..130bef7 100644
>> --- a/include/linux/dma-mapping.h
>> +++ b/include/linux/dma-mapping.h
>> @@ -10,6 +10,7 @@
>>  #include <linux/scatterlist.h>
>>  #include <linux/kmemcheck.h>
>>  #include <linux/bug.h>
>> +#include <linux/mem_encrypt.h>
>>
>>  /**
>>   * List of possible attributes associated with a DMA mapping. The semantics
>> @@ -557,6 +558,11 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
>>
>>  	if (!dev->dma_mask || !dma_supported(dev, mask))
>>  		return -EIO;
>> +
>> +	if (sme_active() && (mask < sme_dma_mask()))
>> +		dev_warn(dev,
>> +			 "SME is active, device will require DMA bounce buffers\n");
>
> You can make it one line. But I am wondering if you should use
> printk_ratelimit as this may fill the console up.

I thought the use of dma_set_mask() was mostly a one time probe/setup
thing so I didn't think we would get that many of these messages. If
dma_set_mask() is called much more often that that I can change this
to a printk_ratelimit().  I'll look into it further.

>
>> +
>>  	*dev->dma_mask = mask;
>>  	return 0;
>>  }
>> @@ -576,6 +582,11 @@ static inline int dma_set_coherent_mask(struct device *dev, u64 mask)
>>  {
>>  	if (!dma_supported(dev, mask))
>>  		return -EIO;
>> +
>> +	if (sme_active() && (mask < sme_dma_mask()))
>> +		dev_warn(dev,
>> +			 "SME is active, device will require DMA bounce buffers\n");
>
> Ditto.
>> +
>>  	dev->coherent_dma_mask = mask;
>>  	return 0;
>>  }
>> diff --git a/include/linux/mem_encrypt.h b/include/linux/mem_encrypt.h
>> index 14a7b9f..6829ff1 100644
>> --- a/include/linux/mem_encrypt.h
>> +++ b/include/linux/mem_encrypt.h
>> @@ -28,6 +28,12 @@ static inline bool sme_active(void)
>>  {
>>  	return false;
>>  }
>> +
>> +static inline u64 sme_dma_mask(void)
>> +{
>> +	return 0ULL;
>> +}
>> +
>>  #endif
>>
>>  #endif	/* CONFIG_AMD_MEM_ENCRYPT */
>> diff --git a/lib/swiotlb.c b/lib/swiotlb.c
>> index c463067..aff9353 100644
>> --- a/lib/swiotlb.c
>> +++ b/lib/swiotlb.c
>> @@ -509,6 +509,9 @@ phys_addr_t swiotlb_tbl_map_single(struct device *hwdev,
>>  	if (no_iotlb_memory)
>>  		panic("Can not allocate SWIOTLB buffer earlier and can't now provide you with the DMA bounce buffer");
>>
>> +	WARN_ONCE(sme_active(),
>> +		  "SME is active and system is using DMA bounce buffers\n");
>
> How does that help?
>
> As in what can the user do with this?

It's meant just to notify the user about the condition. The user could
then decide to use an alternative device that supports a greater DMA
range (I can probably change it to a dev_warn_once() so that a device
is identified).  I would be nice if I could issue this message once per
device that experienced this.  I didn't see anything that would do
that, though.

Thanks,
Tom

>> +
>>  	mask = dma_get_seg_boundary(hwdev);
>>
>>  	tbl_dma_addr &= mask;
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
