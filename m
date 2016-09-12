Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2BF6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 11:43:42 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 192so132125326itm.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 08:43:42 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0084.outbound.protection.outlook.com. [104.47.38.84])
        by mx.google.com with ESMTPS id u201si10600195oie.216.2016.09.12.08.43.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 08:43:41 -0700 (PDT)
Subject: Re: [RFC PATCH v2 13/20] x86: Decrypt trampoline area if memory
 encryption is active
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223757.29880.24107.stgit@tlendack-t1.amdoffice.net>
 <20160909173442.wypsprnzb5ax6xqb@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <15219992-dfca-aaa4-4a98-593ed85e1e8f@amd.com>
Date: Mon, 12 Sep 2016 10:43:32 -0500
MIME-Version: 1.0
In-Reply-To: <20160909173442.wypsprnzb5ax6xqb@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/09/2016 12:34 PM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:37:57PM -0500, Tom Lendacky wrote:
>> When Secure Memory Encryption is enabled, the trampoline area must not
>> be encrypted. A cpu running in real mode will not be able to decrypt
> 
> s/cpu/CPU/... always :-)

Ok.

> 
>> memory that has been encrypted because it will not be able to use addresses
>> with the memory encryption mask.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/realmode/init.c |    9 +++++++++
>>  1 file changed, 9 insertions(+)
>>
>> diff --git a/arch/x86/realmode/init.c b/arch/x86/realmode/init.c
>> index 5db706f1..f74925f 100644
>> --- a/arch/x86/realmode/init.c
>> +++ b/arch/x86/realmode/init.c
>> @@ -6,6 +6,7 @@
>>  #include <asm/pgtable.h>
>>  #include <asm/realmode.h>
>>  #include <asm/tlbflush.h>
>> +#include <asm/mem_encrypt.h>
>>  
>>  struct real_mode_header *real_mode_header;
>>  u32 *trampoline_cr4_features;
>> @@ -130,6 +131,14 @@ static void __init set_real_mode_permissions(void)
>>  	unsigned long text_start =
>>  		(unsigned long) __va(real_mode_header->text_start);
>>  
>> +	/*
>> +	 * If memory encryption is active, the trampoline area will need to
>> +	 * be in non-encrypted memory in order to bring up other processors
> 
> Let's stick with either "unencrypted" - I'd prefer that one - or
> "non-encrypted" nomenclature so that there's no distraction. I see both
> versions in the patchset.

Yup, I'll audit the code and make everything consistent.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
