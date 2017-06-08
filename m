Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF0146B02C3
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 10:26:51 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id f100so11848191iod.14
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 07:26:51 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0067.outbound.protection.outlook.com. [104.47.41.67])
        by mx.google.com with ESMTPS id k78si5849889ita.112.2017.06.08.07.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 07:26:50 -0700 (PDT)
Subject: Re: [PATCH v6 26/34] iommu/amd: Allow the AMD IOMMU to work with
 memory encryption
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191745.28645.81756.stgit@tlendack-t1.amdoffice.net>
 <CAOcCaLZ5QNx+CdnLn4eHtYOJOezJAsmq2whf8mggOdeMQDWOhw@mail.gmail.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <9ca73103-f202-b5b0-b449-79a4b8a8fd72@amd.com>
Date: Thu, 8 Jun 2017 09:26:38 -0500
MIME-Version: 1.0
In-Reply-To: <CAOcCaLZ5QNx+CdnLn4eHtYOJOezJAsmq2whf8mggOdeMQDWOhw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Sarnie <commendsarnex@gmail.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 6/7/2017 9:38 PM, Nick Sarnie wrote:
> On Wed, Jun 7, 2017 at 3:17 PM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
>> The IOMMU is programmed with physical addresses for the various tables
>> and buffers that are used to communicate between the device and the
>> driver. When the driver allocates this memory it is encrypted. In order
>> for the IOMMU to access the memory as encrypted the encryption mask needs
>> to be included in these physical addresses during configuration.
>>
>> The PTE entries created by the IOMMU should also include the encryption
>> mask so that when the device behind the IOMMU performs a DMA, the DMA
>> will be performed to encrypted memory.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   arch/x86/include/asm/mem_encrypt.h |    7 +++++++
>>   arch/x86/mm/mem_encrypt.c          |   30 ++++++++++++++++++++++++++++++
>>   drivers/iommu/amd_iommu.c          |   36 +++++++++++++++++++-----------------
>>   drivers/iommu/amd_iommu_init.c     |   18 ++++++++++++------
>>   drivers/iommu/amd_iommu_proto.h    |   10 ++++++++++
>>   drivers/iommu/amd_iommu_types.h    |    2 +-
>>   include/asm-generic/mem_encrypt.h  |    5 +++++
>>   7 files changed, 84 insertions(+), 24 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
>> index c7a2525..d86e544 100644
>> --- a/arch/x86/include/asm/mem_encrypt.h
>> +++ b/arch/x86/include/asm/mem_encrypt.h
>> @@ -31,6 +31,8 @@ void __init sme_early_decrypt(resource_size_t paddr,
>>
>>   void __init sme_early_init(void);
>>
>> +bool sme_iommu_supported(void);
>> +
>>   /* Architecture __weak replacement functions */
>>   void __init mem_encrypt_init(void);
>>
>> @@ -62,6 +64,11 @@ static inline void __init sme_early_init(void)
>>   {
>>   }
>>
>> +static inline bool sme_iommu_supported(void)
>> +{
>> +       return true;
>> +}
>> +
>>   #endif /* CONFIG_AMD_MEM_ENCRYPT */
>>
>>   static inline bool sme_active(void)
>> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
>> index 5d7c51d..018b58a 100644
>> --- a/arch/x86/mm/mem_encrypt.c
>> +++ b/arch/x86/mm/mem_encrypt.c
>> @@ -197,6 +197,36 @@ void __init sme_early_init(void)
>>                  protection_map[i] = pgprot_encrypted(protection_map[i]);
>>   }
>>
>> +bool sme_iommu_supported(void)
>> +{
>> +       struct cpuinfo_x86 *c = &boot_cpu_data;
>> +
>> +       if (!sme_me_mask || (c->x86 != 0x17))
>> +               return true;
>> +
>> +       /* For Fam17h, a specific level of support is required */
>> +       switch (c->microcode & 0xf000) {
>> +       case 0x0000:
>> +               return false;
>> +       case 0x1000:
>> +               switch (c->microcode & 0x0f00) {
>> +               case 0x0000:
>> +                       return false;
>> +               case 0x0100:
>> +                       if ((c->microcode & 0xff) < 0x26)
>> +                               return false;
>> +                       break;
>> +               case 0x0200:
>> +                       if ((c->microcode & 0xff) < 0x05)
>> +                               return false;
>> +                       break;
>> +               }
>> +               break;
>> +       }
>> +
>> +       return true;
>> +}
>> +
>>   /* Architecture __weak replacement functions */
>>   void __init mem_encrypt_init(void)
>>   {
> 

...

> 
> Hi Tom,
> 
> This sounds like a cool feature. I'm trying to test it on my Ryzen
> system, but c->microcode & 0xf000 is evaluating as 0, so IOMMU is not
> being enabled on my system. I'm using the latest microcode for AGESA
> 1.0.0.6, 0x08001126. Is this work reliant on a future microcode
> update, or is there some other issue?

This is my mistake. I moved the check and didn't re-test. At this point
the c->microcode field hasn't been filled in so I'll need to read
MSR_AMD64_PATCH_LEVEL directly in the sme_iommu_supported() function.

Thanks,
Tom

> 
> Thanks,
> Sarnex
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
