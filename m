Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2484C2806EA
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 13:29:35 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id k77so15985416oih.11
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:29:35 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0046.outbound.protection.outlook.com. [104.47.34.46])
        by mx.google.com with ESMTPS id y8si3723820oie.271.2017.04.20.10.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 10:29:34 -0700 (PDT)
Subject: Re: [PATCH v5 05/32] x86/CPU/AMD: Handle SME reduction in physical
 address size
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211711.10190.30861.stgit@tlendack-t1.amdoffice.net>
 <20170420165922.j2inlwbchrs6senw@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <aaa52e93-5875-6033-e72f-8fc3de43ca3a@amd.com>
Date: Thu, 20 Apr 2017 12:29:20 -0500
MIME-Version: 1.0
In-Reply-To: <20170420165922.j2inlwbchrs6senw@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 4/20/2017 11:59 AM, Borislav Petkov wrote:
> On Tue, Apr 18, 2017 at 04:17:11PM -0500, Tom Lendacky wrote:
>> When System Memory Encryption (SME) is enabled, the physical address
>> space is reduced. Adjust the x86_phys_bits value to reflect this
>> reduction.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/kernel/cpu/amd.c |   14 +++++++++++---
>>  1 file changed, 11 insertions(+), 3 deletions(-)
>
> ...
>
>> @@ -622,8 +624,14 @@ static void early_init_amd(struct cpuinfo_x86 *c)
>>
>>  			/* Check if SME is enabled */
>>  			rdmsrl(MSR_K8_SYSCFG, msr);
>> -			if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
>> +			if (msr & MSR_K8_SYSCFG_MEM_ENCRYPT) {
>> +				unsigned int ebx;
>> +
>> +				ebx = cpuid_ebx(0x8000001f);
>> +				c->x86_phys_bits -= (ebx >> 6) & 0x3f;
>> +			} else {
>>  				clear_cpu_cap(c, X86_FEATURE_SME);
>> +			}
>
> Lemme do some simplifying to save an indent level, get rid of local var
> ebx and kill some { }-brackets for a bit better readability:
>
>         if (c->extended_cpuid_level >= 0x8000001f) {
>                 u64 msr;
>
>                 if (!cpu_has(c, X86_FEATURE_SME))
>                         return;
>
>                 /* Check if SME is enabled */
>                 rdmsrl(MSR_K8_SYSCFG, msr);
>                 if (msr & MSR_K8_SYSCFG_MEM_ENCRYPT)
>                         c->x86_phys_bits -= (cpuid_ebx(0x8000001f) >> 6) & 0x3f;
>                 else
>                         clear_cpu_cap(c, X86_FEATURE_SME);
>         }
>

Hmmm... and actually if cpu_has(X86_FEATURE_SME) is true then it's a
given that extended_cpuid_level >= 0x8000001f.  So this can be
simplified to just:

	if (cpu_has(c, X86_FEATURE_SME)) {
		... the rest of your suggestion (minus cpu_has()) ...
	}

Thanks,
Tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
