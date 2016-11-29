Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 685576B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:48:27 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f188so445520066pgc.1
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:48:27 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0079.outbound.protection.outlook.com. [104.47.34.79])
        by mx.google.com with ESMTPS id n17si41504773pgj.73.2016.11.29.10.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 10:48:26 -0800 (PST)
Subject: Re: [RFC PATCH v3 20/20] x86: Add support to make use of Secure
 Memory Encryption
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003838.3280.23327.stgit@tlendack-t1.amdoffice.net>
 <20161126204703.wlcd6cw7dxzvpxyc@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <4cffdd71-dcc6-35e9-2654-e39067a525a8@amd.com>
Date: Tue, 29 Nov 2016 12:48:17 -0600
MIME-Version: 1.0
In-Reply-To: <20161126204703.wlcd6cw7dxzvpxyc@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/26/2016 2:47 PM, Borislav Petkov wrote:
> On Wed, Nov 09, 2016 at 06:38:38PM -0600, Tom Lendacky wrote:
>> This patch adds the support to check if SME has been enabled and if the
>> mem_encrypt=on command line option is set. If both of these conditions
>> are true, then the encryption mask is set and the kernel is encrypted
>> "in place."
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/kernel/head_64.S          |    1 +
>>  arch/x86/kernel/mem_encrypt_init.c |   60 +++++++++++++++++++++++++++++++++++-
>>  arch/x86/mm/mem_encrypt.c          |    2 +
>>  3 files changed, 62 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
>> index e8a7272..c225433 100644
>> --- a/arch/x86/kernel/head_64.S
>> +++ b/arch/x86/kernel/head_64.S
>> @@ -100,6 +100,7 @@ startup_64:
>>  	 * to include it in the page table fixups.
>>  	 */
>>  	push	%rsi
>> +	movq	%rsi, %rdi
>>  	call	sme_enable
>>  	pop	%rsi
>>  	movq	%rax, %r12
>> diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
>> index 7bdd159..c94ceb8 100644
>> --- a/arch/x86/kernel/mem_encrypt_init.c
>> +++ b/arch/x86/kernel/mem_encrypt_init.c
>> @@ -16,9 +16,14 @@
>>  #include <linux/mm.h>
>>  
>>  #include <asm/sections.h>
>> +#include <asm/processor-flags.h>
>> +#include <asm/msr.h>
>> +#include <asm/cmdline.h>
>>  
>>  #ifdef CONFIG_AMD_MEM_ENCRYPT
>>  
>> +static char sme_cmdline_arg[] __initdata = "mem_encrypt=on";
> 
> One more thing: just like we're adding an =on switch, we'd need an =off
> switch in case something's wrong with the SME code. IOW, if a user
> supplies "mem_encrypt=off", we do not encrypt.

Well, we can document "off", but if the exact string "mem_encrypt=on"
isn't specified on the command line then the encryption won't occur.
The cmdline_find_option_bool() function looks for the exact string and
isn't interpreting the value on the right side of the equal sign. So
omitting mem_encrypt=on or using mem_encrypt=off is the same.

Thanks,
Tom

> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
