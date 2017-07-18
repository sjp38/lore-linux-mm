Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B48886B0279
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 09:57:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v62so20593789pfd.10
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 06:57:13 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0068.outbound.protection.outlook.com. [104.47.36.68])
        by mx.google.com with ESMTPS id a73si1814968pfg.415.2017.07.18.06.57.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Jul 2017 06:57:12 -0700 (PDT)
Subject: Re: [PATCH v10 37/38] compiler-gcc.h: Introduce __nostackp function
 attribute
References: <cover.1500319216.git.thomas.lendacky@amd.com>
 <0576fd5c74440ad0250f16ac6609ecf587812456.1500319216.git.thomas.lendacky@amd.com>
 <20170718093631.pnamvdrkmzcjz64j@gmail.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <b9b7d092-cb15-bc2e-6675-a36a78a5db6f@amd.com>
Date: Tue, 18 Jul 2017 08:56:56 -0500
MIME-Version: 1.0
In-Reply-To: <20170718093631.pnamvdrkmzcjz64j@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, kasan-dev@googlegroups.com, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Young <dyoung@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, "Michael S. Tsirkin" <mst@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>

On 7/18/2017 4:36 AM, Ingo Molnar wrote:
> 
> * Tom Lendacky <thomas.lendacky@amd.com> wrote:
> 
>> Create a new function attribute, __nostackp, that can used to turn off
>> stack protection on a per function basis.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   include/linux/compiler-gcc.h | 2 ++
>>   include/linux/compiler.h     | 4 ++++
>>   2 files changed, 6 insertions(+)
>>
>> diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
>> index cd4bbe8..682063b 100644
>> --- a/include/linux/compiler-gcc.h
>> +++ b/include/linux/compiler-gcc.h
>> @@ -166,6 +166,8 @@
>>   
>>   #if GCC_VERSION >= 40100
>>   # define __compiletime_object_size(obj) __builtin_object_size(obj, 0)
>> +
>> +#define __nostackp	__attribute__((__optimize__("no-stack-protector")))
>>   #endif
>>   
>>   #if GCC_VERSION >= 40300
>> diff --git a/include/linux/compiler.h b/include/linux/compiler.h
>> index 219f82f..63cbca1 100644
>> --- a/include/linux/compiler.h
>> +++ b/include/linux/compiler.h
>> @@ -470,6 +470,10 @@ static __always_inline void __write_once_size(volatile void *p, void *res, int s
>>   #define __visible
>>   #endif
>>   
>> +#ifndef __nostackp
>> +#define __nostackp
>> +#endif
> 
> So I changed this from the hard to read and ambiguous "__nostackp" abbreviation
> (does it mean 'no stack pointer?') to "__nostackprotector", plus added this detail
> to the changelog:
> 
> | ( This is needed by the SME in-place kernel memory encryption feature,
> |   which activates encryption in its sme_enable() function and thus changes the
> |   visible value of the stack protection cookie on function return. )
> 
> Agreed?

Hi Ingo,

I debugged this to needing "__nostackprotector" because sme_enable()
is called very early in the boot process before everything is properly
setup to fully support stack protection when KASLR is enabled. Without
this attribute the call to sme_enable() would fail even if encryption
was disabled with the "mem_encrypt=off" command line option.

If KASLR wasn't enabled, then everything worked fine without the
"__nostackprotector" attribute, encryption enabled or not.

The stack protection support is activated because of the 16-byte
character buffer in the sme_enable() routine.  I think we'll find that
if a character buffer greater than 8 bytes is added to, for example,
__startup_64, then this attribute will need to be added to that routine.

Thanks,
Tom

> 
> Thanks,
> 
> 	Ingo
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
