Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1E36B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 16:07:28 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j66so103344987oib.2
        for <linux-mm@kvack.org>; Tue, 30 May 2017 13:07:28 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0085.outbound.protection.outlook.com. [104.47.42.85])
        by mx.google.com with ESMTPS id s62si5897427oih.129.2017.05.30.13.07.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 May 2017 13:07:27 -0700 (PDT)
Subject: Re: [PATCH v5 26/32] x86, drm, fbdev: Do not specify encrypted memory
 for video mappings
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212056.10190.25468.stgit@tlendack-t1.amdoffice.net>
 <20170516173541.q2rbh5dhkluzsjae@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <766ddfd1-d1fe-213f-1720-5e10356398f0@amd.com>
Date: Tue, 30 May 2017 15:07:05 -0500
MIME-Version: 1.0
In-Reply-To: <20170516173541.q2rbh5dhkluzsjae@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/16/2017 12:35 PM, Borislav Petkov wrote:
> On Tue, Apr 18, 2017 at 04:20:56PM -0500, Tom Lendacky wrote:
>> Since video memory needs to be accessed decrypted, be sure that the
>> memory encryption mask is not set for the video ranges.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   arch/x86/include/asm/vga.h       |   13 +++++++++++++
>>   arch/x86/mm/pageattr.c           |    2 ++
>>   drivers/gpu/drm/drm_gem.c        |    2 ++
>>   drivers/gpu/drm/drm_vm.c         |    4 ++++
>>   drivers/gpu/drm/ttm/ttm_bo_vm.c  |    7 +++++--
>>   drivers/gpu/drm/udl/udl_fb.c     |    4 ++++
>>   drivers/video/fbdev/core/fbmem.c |   12 ++++++++++++
>>   7 files changed, 42 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/vga.h b/arch/x86/include/asm/vga.h
>> index c4b9dc2..5c7567a 100644
>> --- a/arch/x86/include/asm/vga.h
>> +++ b/arch/x86/include/asm/vga.h
>> @@ -7,12 +7,25 @@
>>   #ifndef _ASM_X86_VGA_H
>>   #define _ASM_X86_VGA_H
>>   
>> +#include <asm/cacheflush.h>
>> +
>>   /*
>>    *	On the PC, we can just recalculate addresses and then
>>    *	access the videoram directly without any black magic.
>> + *	To support memory encryption however, we need to access
>> + *	the videoram as decrypted memory.
>>    */
>>   
>> +#ifdef CONFIG_AMD_MEM_ENCRYPT
>> +#define VGA_MAP_MEM(x, s)					\
>> +({								\
>> +	unsigned long start = (unsigned long)phys_to_virt(x);	\
>> +	set_memory_decrypted(start, (s) >> PAGE_SHIFT);		\
>> +	start;							\
>> +})
>> +#else
>>   #define VGA_MAP_MEM(x, s) (unsigned long)phys_to_virt(x)
>> +#endif
> 
> Can we push the check in and save us the ifdeffery?
> 
> #define VGA_MAP_MEM(x, s)                                       \
> ({                                                              \
>          unsigned long start = (unsigned long)phys_to_virt(x);   \
>                                                                  \
>          if (IS_ENABLED(CONFIG_AMD_MEM_ENCRYPT))                 \
>                  set_memory_decrypted(start, (s) >> PAGE_SHIFT); \
>                                                                  \
>          start;                                                  \
> })
> 
> It does build here. :)
> 

That works for me and it's a lot cleaner.  I'll make the change.

Thanks,
Tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
