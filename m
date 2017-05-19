Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3349028071E
	for <linux-mm@kvack.org>; Fri, 19 May 2017 15:55:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e131so63185851pfh.7
        for <linux-mm@kvack.org>; Fri, 19 May 2017 12:55:39 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0066.outbound.protection.outlook.com. [104.47.36.66])
        by mx.google.com with ESMTPS id i63si8704313pge.267.2017.05.19.12.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 May 2017 12:55:38 -0700 (PDT)
Subject: Re: [PATCH v5 23/32] swiotlb: Add warnings for use of bounce buffers
 with SME
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212019.10190.24034.stgit@tlendack-t1.amdoffice.net>
 <20170516145209.ltbmaq3a2teqr2uv@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <64f72c46-75df-ce67-e81a-3b85cfe4c7d1@amd.com>
Date: Fri, 19 May 2017 14:55:29 -0500
MIME-Version: 1.0
In-Reply-To: <20170516145209.ltbmaq3a2teqr2uv@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/16/2017 9:52 AM, Borislav Petkov wrote:
> On Tue, Apr 18, 2017 at 04:20:19PM -0500, Tom Lendacky wrote:
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
>> index 0637b4b..b406df2 100644
>> --- a/arch/x86/include/asm/mem_encrypt.h
>> +++ b/arch/x86/include/asm/mem_encrypt.h
>> @@ -26,6 +26,11 @@ static inline bool sme_active(void)
>>  	return !!sme_me_mask;
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
>> @@ -50,6 +55,12 @@ static inline bool sme_active(void)
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
>> index 0977317..f825870 100644
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
>> @@ -577,6 +578,11 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
>>
>>  	if (!dev->dma_mask || !dma_supported(dev, mask))
>>  		return -EIO;
>> +
>> +	if (sme_active() && (mask < sme_dma_mask()))
>> +		dev_warn_ratelimited(dev,
>> +				     "SME is active, device will require DMA bounce buffers\n");
>
> Bah, no need to break that line - just let it stick out. Ditto for the
> others.

Ok.

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
