Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 073A56B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 18:29:03 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id x66so29712668pfb.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 15:29:02 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0058.outbound.protection.outlook.com. [104.47.38.58])
        by mx.google.com with ESMTPS id q5si3002440pfk.67.2017.02.28.15.29.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 Feb 2017 15:29:02 -0800 (PST)
Subject: Re: [RFC PATCH v4 21/28] x86: Check for memory encryption on the APs
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154647.19244.18733.stgit@tlendack-t1.amdoffice.net>
 <20170227181701.2lynk4rm77yk4msf@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <5f461d57-9232-1cb3-d4d9-9b8a39d00b12@amd.com>
Date: Tue, 28 Feb 2017 17:28:48 -0600
MIME-Version: 1.0
In-Reply-To: <20170227181701.2lynk4rm77yk4msf@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/27/2017 12:17 PM, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:46:47AM -0600, Tom Lendacky wrote:
>> Add support to check if memory encryption is active in the kernel and that
>> it has been enabled on the AP. If memory encryption is active in the kernel
>> but has not been enabled on the AP, then set the SYS_CFG MSR bit to enable
>> memory encryption on that AP and allow the AP to continue start up.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/realmode.h      |   12 ++++++++++++
>>  arch/x86/realmode/init.c             |    4 ++++
>>  arch/x86/realmode/rm/trampoline_64.S |   17 +++++++++++++++++
>>  3 files changed, 33 insertions(+)
>>
>> diff --git a/arch/x86/include/asm/realmode.h b/arch/x86/include/asm/realmode.h
>> index 230e190..4f7ef53 100644
>> --- a/arch/x86/include/asm/realmode.h
>> +++ b/arch/x86/include/asm/realmode.h
>> @@ -1,6 +1,15 @@
>>  #ifndef _ARCH_X86_REALMODE_H
>>  #define _ARCH_X86_REALMODE_H
>>
>> +/*
>> + * Flag bit definitions for use with the flags field of the trampoline header
>> + * int the CONFIG_X86_64 variant.
>
> s/int/in/

Fixed.

>
>> + */
>> +#define TH_FLAGS_SME_ACTIVE_BIT		0
>> +#define TH_FLAGS_SME_ACTIVE		BIT(TH_FLAGS_SME_ACTIVE_BIT)
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
>> index 21d7506..5010089 100644
>> --- a/arch/x86/realmode/init.c
>> +++ b/arch/x86/realmode/init.c
>> @@ -102,6 +102,10 @@ static void __init setup_real_mode(void)
>>  	trampoline_cr4_features = &trampoline_header->cr4;
>>  	*trampoline_cr4_features = mmu_cr4_features;
>>
>> +	trampoline_header->flags = 0;
>> +	if (sme_active())
>> +		trampoline_header->flags |= TH_FLAGS_SME_ACTIVE;
>> +
>>  	trampoline_pgd = (u64 *) __va(real_mode_header->trampoline_pgd);
>>  	trampoline_pgd[0] = trampoline_pgd_entry.pgd;
>>  	trampoline_pgd[511] = init_level4_pgt[511].pgd;
>> diff --git a/arch/x86/realmode/rm/trampoline_64.S b/arch/x86/realmode/rm/trampoline_64.S
>> index dac7b20..a88c3d1 100644
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
>> @@ -92,6 +93,21 @@ ENTRY(startup_32)
>>  	movl	%edx, %fs
>>  	movl	%edx, %gs
>>
>> +	/* Check for memory encryption support */
>
> Let's add some blurb here about this being a safety net in case BIOS
> f*cks up. Which wouldn't be that far-fetched... :-)

That's a good idea, I'll expand on that.  I probably won't be that
direct in my comment though :)

Thanks,
Tom

>
>> +	bt	$TH_FLAGS_SME_ACTIVE_BIT, pa_tr_flags
>> +	jnc	.Ldone
>> +	movl	$MSR_K8_SYSCFG, %ecx
>> +	rdmsr
>> +	bts	$MSR_K8_SYSCFG_MEM_ENCRYPT_BIT, %eax
>> +	jc	.Ldone
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
