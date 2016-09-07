Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2C66B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 10:07:24 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so35898479pad.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 07:07:24 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0069.outbound.protection.outlook.com. [104.47.41.69])
        by mx.google.com with ESMTPS id e73si41479103pfj.239.2016.09.07.07.07.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 07:07:23 -0700 (PDT)
Subject: Re: [RFC PATCH v2 05/20] x86: Add the Secure Memory Encryption cpu
 feature
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223622.29880.17779.stgit@tlendack-t1.amdoffice.net>
 <20160902140913.GA23808@nazgul.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <e3356344-6542-10d1-21e8-97e6fec30371@amd.com>
Date: Wed, 7 Sep 2016 09:07:11 -0500
MIME-Version: 1.0
In-Reply-To: <20160902140913.GA23808@nazgul.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/02/2016 09:09 AM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:36:22PM -0500, Tom Lendacky wrote:
>> Update the cpu features to include identifying and reporting on the
>> Secure Memory Encryption feature.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/cpufeature.h        |    7 +++++--
>>  arch/x86/include/asm/cpufeatures.h       |    5 ++++-
>>  arch/x86/include/asm/disabled-features.h |    3 ++-
>>  arch/x86/include/asm/required-features.h |    3 ++-
>>  arch/x86/kernel/cpu/scattered.c          |    1 +
>>  5 files changed, 14 insertions(+), 5 deletions(-)
> 
> ...
> 
>> diff --git a/arch/x86/kernel/cpu/scattered.c b/arch/x86/kernel/cpu/scattered.c
>> index 8cb57df..d86d9a5 100644
>> --- a/arch/x86/kernel/cpu/scattered.c
>> +++ b/arch/x86/kernel/cpu/scattered.c
>> @@ -37,6 +37,7 @@ void init_scattered_cpuid_features(struct cpuinfo_x86 *c)
>>  		{ X86_FEATURE_HW_PSTATE,	CR_EDX, 7, 0x80000007, 0 },
>>  		{ X86_FEATURE_CPB,		CR_EDX, 9, 0x80000007, 0 },
>>  		{ X86_FEATURE_PROC_FEEDBACK,	CR_EDX,11, 0x80000007, 0 },
>> +		{ X86_FEATURE_SME,		CR_EAX, 0, 0x8000001f, 0 },
> 
> If this is in scattered CPUID features, it doesn't need any of the
> (snipped) changes above - you solely need to reuse one of the free
> defines, i.e., something like this:

Ok, that's much easier. I'll do that.

Thanks,
Tom

> 
> ---
> --- a/arch/x86/include/asm/cpufeatures.h	2016-09-02 15:49:08.853374323 +0200
> +++ b/arch/x86/include/asm/cpufeatures.h	2016-09-02 15:52:34.477365610 +0200
> @@ -100,7 +100,7 @@
>  #define X86_FEATURE_XTOPOLOGY	( 3*32+22) /* cpu topology enum extensions */
>  #define X86_FEATURE_TSC_RELIABLE ( 3*32+23) /* TSC is known to be reliable */
>  #define X86_FEATURE_NONSTOP_TSC	( 3*32+24) /* TSC does not stop in C states */
> -/* free, was #define X86_FEATURE_CLFLUSH_MONITOR ( 3*32+25) * "" clflush reqd with monitor */
> +#define X86_FEATURE_SME		( 3*32+25) /* Secure Memory Encryption */
>  #define X86_FEATURE_EXTD_APICID	( 3*32+26) /* has extended APICID (8 bits) */
>  #define X86_FEATURE_AMD_DCM     ( 3*32+27) /* multi-node processor */
>  #define X86_FEATURE_APERFMPERF	( 3*32+28) /* APERFMPERF */
> --- a/arch/x86/kernel/cpu/scattered.c	2016-09-02 15:48:52.753375005 +0200
> +++ b/arch/x86/kernel/cpu/scattered.c	2016-09-02 15:51:32.437368239 +0200
> @@ -37,6 +37,7 @@ void init_scattered_cpuid_features(struc
>  		{ X86_FEATURE_HW_PSTATE,	CR_EDX, 7, 0x80000007, 0 },
>  		{ X86_FEATURE_CPB,		CR_EDX, 9, 0x80000007, 0 },
>  		{ X86_FEATURE_PROC_FEEDBACK,	CR_EDX,11, 0x80000007, 0 },
> +		{ X86_FEATURE_SME,		CR_EAX, 0, 0x8000001f, 0 },
>  		{ 0, 0, 0, 0, 0 }
>  	};
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
