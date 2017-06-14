Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BEAC76B0292
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 15:49:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b74so8253447pfj.5
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 12:49:12 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0045.outbound.protection.outlook.com. [104.47.38.45])
        by mx.google.com with ESMTPS id d4si601561pgc.141.2017.06.14.12.49.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Jun 2017 12:49:11 -0700 (PDT)
Subject: Re: [PATCH v6 25/34] swiotlb: Add warnings for use of bounce buffers
 with SME
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191732.28645.42876.stgit@tlendack-t1.amdoffice.net>
 <20170614165052.fyn5t4gkq5leczcc@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <33d1debc-c684-cba1-7d95-493678f086d0@amd.com>
Date: Wed, 14 Jun 2017 14:49:02 -0500
MIME-Version: 1.0
In-Reply-To: <20170614165052.fyn5t4gkq5leczcc@pd.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 6/14/2017 11:50 AM, Borislav Petkov wrote:
> On Wed, Jun 07, 2017 at 02:17:32PM -0500, Tom Lendacky wrote:
>> Add warnings to let the user know when bounce buffers are being used for
>> DMA when SME is active.  Since the bounce buffers are not in encrypted
>> memory, these notifications are to allow the user to determine some
>> appropriate action - if necessary.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   arch/x86/include/asm/mem_encrypt.h |    8 ++++++++
>>   include/asm-generic/mem_encrypt.h  |    5 +++++
>>   include/linux/dma-mapping.h        |    9 +++++++++
>>   lib/swiotlb.c                      |    3 +++
>>   4 files changed, 25 insertions(+)
>>
>> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
>> index f1215a4..c7a2525 100644
>> --- a/arch/x86/include/asm/mem_encrypt.h
>> +++ b/arch/x86/include/asm/mem_encrypt.h
>> @@ -69,6 +69,14 @@ static inline bool sme_active(void)
>>   	return !!sme_me_mask;
>>   }
>>   
>> +static inline u64 sme_dma_mask(void)
>> +{
>> +	if (!sme_me_mask)
>> +		return 0ULL;
>> +
>> +	return ((u64)sme_me_mask << 1) - 1;
>> +}
>> +
>>   /*
>>    * The __sme_pa() and __sme_pa_nodebug() macros are meant for use when
>>    * writing to or comparing values from the cr3 register.  Having the
>> diff --git a/include/asm-generic/mem_encrypt.h b/include/asm-generic/mem_encrypt.h
>> index b55c3f9..fb02ff0 100644
>> --- a/include/asm-generic/mem_encrypt.h
>> +++ b/include/asm-generic/mem_encrypt.h
>> @@ -22,6 +22,11 @@ static inline bool sme_active(void)
>>   	return false;
>>   }
>>   
>> +static inline u64 sme_dma_mask(void)
>> +{
>> +	return 0ULL;
>> +}
>> +
>>   /*
>>    * The __sme_set() and __sme_clr() macros are useful for adding or removing
>>    * the encryption mask from a value (e.g. when dealing with pagetable
>> diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
>> index 4f3eece..e2c5fda 100644
>> --- a/include/linux/dma-mapping.h
>> +++ b/include/linux/dma-mapping.h
>> @@ -10,6 +10,7 @@
>>   #include <linux/scatterlist.h>
>>   #include <linux/kmemcheck.h>
>>   #include <linux/bug.h>
>> +#include <linux/mem_encrypt.h>
>>   
>>   /**
>>    * List of possible attributes associated with a DMA mapping. The semantics
>> @@ -577,6 +578,10 @@ static inline int dma_set_mask(struct device *dev, u64 mask)
>>   
>>   	if (!dev->dma_mask || !dma_supported(dev, mask))
>>   		return -EIO;
>> +
>> +	if (sme_active() && (mask < sme_dma_mask()))
>> +		dev_warn(dev, "SME is active, device will require DMA bounce buffers\n");
> 
> Something looks strange here:
> 
> you're checking sme_active() before calling sme_dma_mask() and yet in
> it, you're checking !sme_me_mask again. What gives?
> 

I guess I don't need the sme_active() check since the second part of the
if statement can only ever be true if SME is active (since mask is
unsigned).

Thanks,
Tom

> Why not move the sme_active() check into sme_dma_mask() and thus
> simplify callers?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
