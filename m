Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64FCF6B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 11:43:53 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w185so2622162ita.5
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 08:43:53 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0068.outbound.protection.outlook.com. [104.47.32.68])
        by mx.google.com with ESMTPS id g96si2023336iod.228.2017.02.22.08.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 08:43:52 -0800 (PST)
Subject: Re: [RFC PATCH v4 07/28] x86: Provide general kernel support for
 memory encryption
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154332.19244.55451.stgit@tlendack-t1.amdoffice.net>
 <20170220183823.k7bsg77wbb4xyc2s@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <9b048215-0e78-dbf0-e82c-de3a1ee91ff3@amd.com>
Date: Wed, 22 Feb 2017 10:43:41 -0600
MIME-Version: 1.0
In-Reply-To: <20170220183823.k7bsg77wbb4xyc2s@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/20/2017 12:38 PM, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:43:32AM -0600, Tom Lendacky wrote:
>> Adding general kernel support for memory encryption includes:
>> - Modify and create some page table macros to include the Secure Memory
>>   Encryption (SME) memory encryption mask
>> - Modify and create some macros for calculating physical and virtual
>>   memory addresses
>> - Provide an SME initialization routine to update the protection map with
>>   the memory encryption mask so that it is used by default
>> - #undef CONFIG_AMD_MEM_ENCRYPT in the compressed boot path
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>
> ...
>
>> +#define __sme_pa(x)		(__pa((x)) | sme_me_mask)
>> +#define __sme_pa_nodebug(x)	(__pa_nodebug((x)) | sme_me_mask)
>> +
>>  #else	/* !CONFIG_AMD_MEM_ENCRYPT */
>>
>>  #ifndef sme_me_mask
>> @@ -35,6 +42,13 @@ static inline bool sme_active(void)
>>  }
>>  #endif
>>
>> +static inline void __init sme_early_init(void)
>> +{
>> +}
>> +
>> +#define __sme_pa		__pa
>> +#define __sme_pa_nodebug	__pa_nodebug
>
> One more thing - in the !CONFIG_AMD_MEM_ENCRYPT case, sme_me_mask is 0
> so you don't need to define __sme_pa* again.

Makes sense.  I'll move those macros outside the #ifdef (I'll do the
same for the new __sme_clr() and __sme_set() macros, too).

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
