Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3126B025E
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:01:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x23so449042774pgx.6
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:01:08 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0058.outbound.protection.outlook.com. [104.47.40.58])
        by mx.google.com with ESMTPS id 60si32299490ple.301.2016.11.29.10.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 10:01:07 -0800 (PST)
Subject: Re: [RFC PATCH v3 15/20] x86: Check for memory encryption on the APs
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003740.3280.57300.stgit@tlendack-t1.amdoffice.net>
 <20161122192526.vg63jjhwsbjwex7i@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <b3b5cc5d-dc1d-187d-d738-ba55798327d2@amd.com>
Date: Tue, 29 Nov 2016 12:00:56 -0600
MIME-Version: 1.0
In-Reply-To: <20161122192526.vg63jjhwsbjwex7i@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/22/2016 1:25 PM, Borislav Petkov wrote:
> On Wed, Nov 09, 2016 at 06:37:40PM -0600, Tom Lendacky wrote:
>> Add support to check if memory encryption is active in the kernel and that
>> it has been enabled on the AP. If memory encryption is active in the kernel
>> but has not been enabled on the AP then do not allow the AP to continue
>> start up.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/realmode.h      |   12 ++++++++++++
>>  arch/x86/realmode/init.c             |    4 ++++
>>  arch/x86/realmode/rm/trampoline_64.S |   19 +++++++++++++++++++
>>  3 files changed, 35 insertions(+)
>>
>> diff --git a/arch/x86/include/asm/realmode.h b/arch/x86/include/asm/realmode.h
>> index 230e190..850dbe0 100644
>> --- a/arch/x86/include/asm/realmode.h
>> +++ b/arch/x86/include/asm/realmode.h
>> @@ -1,6 +1,15 @@
>>  #ifndef _ARCH_X86_REALMODE_H
>>  #define _ARCH_X86_REALMODE_H
>>  
>> +/*
>> + * Flag bit definitions for use with the flags field of the trampoline header
>> + * when configured for X86_64
> 
> Let's use kernel nomenclature: "... of the trampoline header in the
> CONFIG_X86_64 variant."

Ok.

> 
>> + */
>> +#define TH_FLAGS_SME_ENABLE_BIT		0
>> +#define TH_FLAGS_SME_ENABLE		BIT_ULL(TH_FLAGS_SME_ENABLE_BIT)
> 
> BIT() is the proper one for u32 flags variable.

Yup, not sure why I used BIT_ULL...  will fix.

> 
>> +
>> +#ifndef __ASSEMBLY__
>> +
>>  #include <linux/types.h>
>>  #include <asm/io.h>
>>  
>> @@ -38,6 +47,7 @@ struct trampoline_header {
>>  	u64 start;
>>  	u64 efer;
>>  	u32 cr4;
>> +	u32 flags;
>>  #endif
>>  };
>>  
>> @@ -69,4 +79,6 @@ static inline size_t real_mode_size_needed(void)
>>  void set_real_mode_mem(phys_addr_t mem, size_t size);
>>  void reserve_real_mode(void);
>>  
>> +#endif /* __ASSEMBLY__ */
>> +
>>  #endif /* _ARCH_X86_REALMODE_H */
>> diff --git a/arch/x86/realmode/init.c b/arch/x86/realmode/init.c
>> index 44ed32a..a8e7ebe 100644
>> --- a/arch/x86/realmode/init.c
>> +++ b/arch/x86/realmode/init.c
>> @@ -101,6 +101,10 @@ static void __init setup_real_mode(void)
>>  	trampoline_cr4_features = &trampoline_header->cr4;
>>  	*trampoline_cr4_features = mmu_cr4_features;
>>  
>> +	trampoline_header->flags = 0;
>> +	if (sme_me_mask)
>> +		trampoline_header->flags |= TH_FLAGS_SME_ENABLE;
>> +
>>  	trampoline_pgd = (u64 *) __va(real_mode_header->trampoline_pgd);
>>  	trampoline_pgd[0] = trampoline_pgd_entry.pgd;
>>  	trampoline_pgd[511] = init_level4_pgt[511].pgd;
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
> Can this ever happen?
> 
> I mean, we set TH_FLAGS_SME_ENABLE when sme_me_mask is set and this
> would have happened only if the BSP has MSR_K8_SYSCFG[23] set.
> 
> How is it possible that that bit won't be set on some of the APs but set
> on the BSP?
> 
> I'd assume the BIOS is doing a consistent setting everywhere...
> 

It can happen if BIOS doesn't do something right.  So this is just a
safety thing.  I thought I had changed this to set the bit if it
wasn't set, which is safe to do.  I'm not sure what happened to that
change (based on your previous comment actually!)...  I'll add that
back so that the AP is useful.

Thanks,
Tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
