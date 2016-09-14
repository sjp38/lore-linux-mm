Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9C7B6B0253
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 09:50:39 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu12so28297327pac.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 06:50:39 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0064.outbound.protection.outlook.com. [104.47.40.64])
        by mx.google.com with ESMTPS id 201si12624322pfw.92.2016.09.14.06.50.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 06:50:39 -0700 (PDT)
Subject: Re: [RFC PATCH v2 16/20] x86: Check for memory encryption on the APs
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223829.29880.10341.stgit@tlendack-t1.amdoffice.net>
 <20160912121739.rwuumwpwo5megmd7@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <06a97eaa-d54f-9f7e-d207-4ff3e576169f@amd.com>
Date: Wed, 14 Sep 2016 08:50:25 -0500
MIME-Version: 1.0
In-Reply-To: <20160912121739.rwuumwpwo5megmd7@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/12/2016 07:17 AM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:38:29PM -0500, Tom Lendacky wrote:
>> Add support to check if memory encryption is active in the kernel and that
>> it has been enabled on the AP. If memory encryption is active in the kernel
>> but has not been enabled on the AP then do not allow the AP to continue
>> start up.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/msr-index.h     |    2 ++
>>  arch/x86/include/asm/realmode.h      |   12 ++++++++++++
>>  arch/x86/realmode/init.c             |    4 ++++
>>  arch/x86/realmode/rm/trampoline_64.S |   19 +++++++++++++++++++
>>  4 files changed, 37 insertions(+)
> 
> ...
> 
>> diff --git a/arch/x86/realmode/rm/trampoline_64.S b/arch/x86/realmode/rm/trampoline_64.S
>> index dac7b20..94e29f4 100644
>> --- a/arch/x86/realmode/rm/trampoline_64.S
>> +++ b/arch/x86/realmode/rm/trampoline_64.S
>> @@ -30,6 +30,7 @@
>>  #include <asm/msr.h>
>>  #include <asm/segment.h>
>>  #include <asm/processor-flags.h>
>> +#include <asm/realmode.h>
>>  #include "realmode.h"
>>  
>>  	.text
>> @@ -92,6 +93,23 @@ ENTRY(startup_32)
>>  	movl	%edx, %fs
>>  	movl	%edx, %gs
>>  
>> +	/* Check for memory encryption support */
>> +	bt	$TH_FLAGS_SME_ENABLE_BIT, pa_tr_flags
>> +	jnc	.Ldone
>> +	movl	$MSR_K8_SYSCFG, %ecx
>> +	rdmsr
>> +	bt	$MSR_K8_SYSCFG_MEM_ENCRYPT_BIT, %eax
>> +	jc	.Ldone
>> +
>> +	/*
>> +	 * Memory encryption is enabled but the MSR has not been set on this
>> +	 * CPU so we can't continue
> 
> Hmm, let me try to parse this correctly: BSP has SME enabled but the
> BIOS might not've set this on the AP? Really? Is that even possible?

Anything is possible, although it's highly unlikely.

> 
> Because if SME is enabled, that means that MSR_K8_SYSCFG[23] on the BSP
> is set, right?

Correct.

> 
> Also, I want to rule out here simple BIOS idiocy: if the only problem
> with the bit not being set in the AP is because some BIOS monkey forgot
> to do so, then we should try to set it ourselves and not die for no real
> reason.

Yes, we can do that.  I was debating on which way to go with this. Most
likely this would never happen, but if it did...  I can change this to
set the MSR bit and continue.

Thanks,
Tom

> 
> Or is there another issue?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
