Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E73E6B04AB
	for <linux-mm@kvack.org>; Sat, 19 Nov 2016 13:50:35 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id u15so312139845oie.6
        for <linux-mm@kvack.org>; Sat, 19 Nov 2016 10:50:35 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0082.outbound.protection.outlook.com. [104.47.34.82])
        by mx.google.com with ESMTPS id r54si5266506otc.242.2016.11.19.10.50.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 19 Nov 2016 10:50:34 -0800 (PST)
Subject: Re: [RFC PATCH v3 12/20] x86: Decrypt trampoline area if memory
 encryption is active
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003708.3280.29934.stgit@tlendack-t1.amdoffice.net>
 <20161117180913.ha5h4bfgrr5u6ccg@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <bb107821-3ddf-a3bd-e0c5-5a25daffb516@amd.com>
Date: Sat, 19 Nov 2016 12:50:24 -0600
MIME-Version: 1.0
In-Reply-To: <20161117180913.ha5h4bfgrr5u6ccg@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/17/2016 12:09 PM, Borislav Petkov wrote:
> On Wed, Nov 09, 2016 at 06:37:08PM -0600, Tom Lendacky wrote:
>> When Secure Memory Encryption is enabled, the trampoline area must not
>> be encrypted. A CPU running in real mode will not be able to decrypt
>> memory that has been encrypted because it will not be able to use addresses
>> with the memory encryption mask.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/realmode/init.c |    9 +++++++++
>>  1 file changed, 9 insertions(+)
>>
>> diff --git a/arch/x86/realmode/init.c b/arch/x86/realmode/init.c
>> index 5db706f1..44ed32a 100644
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
>> +	 * be in un-encrypted memory in order to bring up other processors
>> +	 * successfully.
>> +	 */
>> +	sme_early_mem_dec(__pa(base), size);
>> +	sme_set_mem_unenc(base, size);
> 
> We're still unsure about the non-encrypted state: dec vs unenc. Please
> unify those for ease of use, code reading, etc etc.
> 
> 	sme_early_decrypt(__pa(base), size);
> 	sme_mark_decrypted(base, size);
> 
> or similar looks much more readable and understandable to me.

Yeah, I'll go through and change everything so that the implication
or action is expressed better.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
