Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id A90AC6B0397
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 11:05:06 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id a12so8527605ota.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 08:05:06 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0043.outbound.protection.outlook.com. [104.47.38.43])
        by mx.google.com with ESMTPS id x31si246419otd.238.2017.03.07.08.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 08:05:05 -0800 (PST)
Subject: Re: [RFC PATCH v4 28/28] x86: Add support to make use of Secure
 Memory Encryption
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154825.19244.32545.stgit@tlendack-t1.amdoffice.net>
 <20170301184055.gl3iic3gir6zzb23@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <7e6c308f-3caf-5531-3cb2-9b6986f4288e@amd.com>
Date: Tue, 7 Mar 2017 10:05:00 -0600
MIME-Version: 1.0
In-Reply-To: <20170301184055.gl3iic3gir6zzb23@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 3/1/2017 12:40 PM, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:48:25AM -0600, Tom Lendacky wrote:
>> This patch adds the support to check if SME has been enabled and if
>> memory encryption should be activated (checking of command line option
>> based on the configuration of the default state).  If memory encryption
>> is to be activated, then the encryption mask is set and the kernel is
>> encrypted "in place."
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/kernel/head_64.S          |    1 +
>>  arch/x86/kernel/mem_encrypt_init.c |   71 +++++++++++++++++++++++++++++++++++-
>>  arch/x86/mm/mem_encrypt.c          |    2 +
>>  3 files changed, 73 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
>> index edd2f14..e6820e7 100644
>> --- a/arch/x86/kernel/head_64.S
>> +++ b/arch/x86/kernel/head_64.S
>> @@ -97,6 +97,7 @@ startup_64:
>>  	 * Save the returned mask in %r12 for later use.
>>  	 */
>>  	push	%rsi
>> +	movq	%rsi, %rdi
>>  	call	sme_enable
>>  	pop	%rsi
>>  	movq	%rax, %r12
>> diff --git a/arch/x86/kernel/mem_encrypt_init.c b/arch/x86/kernel/mem_encrypt_init.c
>> index 07cbb90..35c5e3d 100644
>> --- a/arch/x86/kernel/mem_encrypt_init.c
>> +++ b/arch/x86/kernel/mem_encrypt_init.c
>> @@ -19,6 +19,12 @@
>>  #include <linux/mm.h>
>>
>>  #include <asm/sections.h>
>> +#include <asm/processor-flags.h>
>> +#include <asm/msr.h>
>> +#include <asm/cmdline.h>
>> +
>> +static char sme_cmdline_arg_on[] __initdata = "mem_encrypt=on";
>> +static char sme_cmdline_arg_off[] __initdata = "mem_encrypt=off";
>>
>>  extern void sme_encrypt_execute(unsigned long, unsigned long, unsigned long,
>>  				void *, pgd_t *);
>> @@ -217,8 +223,71 @@ unsigned long __init sme_get_me_mask(void)
>>  	return sme_me_mask;
>>  }
>>
>> -unsigned long __init sme_enable(void)
>> +unsigned long __init sme_enable(void *boot_data)
>
> unsigned long __init sme_enable(struct boot_params *bp)
>
> works too.

Ok, will do.

>
> And then you need to correct the function signature in the
> !CONFIG_AMD_MEM_ENCRYPT case, at the end of this file, too:
>
> unsigned long __init sme_enable(struct boot_params *bp)		{ return 0; }

Yup, missed that.  I'll make it match.

>
>>  {
>> +	struct boot_params *bp = boot_data;
>> +	unsigned int eax, ebx, ecx, edx;
>> +	unsigned long cmdline_ptr;
>> +	bool enable_if_found;
>> +	void *cmdline_arg;
>> +	u64 msr;
>> +
>> +	/* Check for an AMD processor */
>> +	eax = 0;
>> +	ecx = 0;
>> +	native_cpuid(&eax, &ebx, &ecx, &edx);
>> +	if ((ebx != 0x68747541) || (edx != 0x69746e65) || (ecx != 0x444d4163))
>> +		goto out;
>> +
>> +	/* Check for the SME support leaf */
>> +	eax = 0x80000000;
>> +	ecx = 0;
>> +	native_cpuid(&eax, &ebx, &ecx, &edx);
>> +	if (eax < 0x8000001f)
>> +		goto out;
>> +
>> +	/*
>> +	 * Check for the SME feature:
>> +	 *   CPUID Fn8000_001F[EAX] - Bit 0
>> +	 *     Secure Memory Encryption support
>> +	 *   CPUID Fn8000_001F[EBX] - Bits 5:0
>> +	 *     Pagetable bit position used to indicate encryption
>> +	 */
>> +	eax = 0x8000001f;
>> +	ecx = 0;
>> +	native_cpuid(&eax, &ebx, &ecx, &edx);
>> +	if (!(eax & 1))
>> +		goto out;
>> +
>> +	/* Check if SME is enabled */
>> +	msr = native_read_msr(MSR_K8_SYSCFG);
>
> This native_read_msr() wankery is adding this check:
>
> 	if (msr_tracepoint_active(__tracepoint_read_msr))
>
> and here it is clearly too early for tracepoints. Please use __rdmsr()
> which is purely doing the MSR operation. (... and exception handling for

Ah, good catch.  I'll switch to __rdmsr().

> when the RDMSR itself raises an exception but we're very early here too
> so the MSR better be there, otherwise we'll blow up).

Yes, it will be there if SME support is indicated in the CPUID result.

>
>> +	if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
>> +		goto out;
>> +
>> +	/*
>> +	 * Fixups have not been to applied phys_base yet, so we must obtain
>
> 		...    not been applied to phys_base yet ...

Yup.

>
>> +	 * the address to the SME command line option in the following way.
>> +	 */
>> +	if (IS_ENABLED(CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT)) {
>> +		asm ("lea sme_cmdline_arg_off(%%rip), %0"
>> +		     : "=r" (cmdline_arg)
>> +		     : "p" (sme_cmdline_arg_off));
>> +		enable_if_found = false;
>> +	} else {
>> +		asm ("lea sme_cmdline_arg_on(%%rip), %0"
>> +		     : "=r" (cmdline_arg)
>> +		     : "p" (sme_cmdline_arg_on));
>> +		enable_if_found = true;
>> +	}
>> +
>> +	cmdline_ptr = bp->hdr.cmd_line_ptr | ((u64)bp->ext_cmd_line_ptr << 32);
>> +
>> +	if (cmdline_find_option_bool((char *)cmdline_ptr, cmdline_arg))
>> +		sme_me_mask = enable_if_found ? 1UL << (ebx & 0x3f) : 0;
>> +	else
>> +		sme_me_mask = enable_if_found ? 0 : 1UL << (ebx & 0x3f);
>
> I have a better idea: you can copy __cmdline_find_option() +
> cmdline_find_option() to arch/x86/lib/cmdline.c in a pre-patch. Then,
> pass in a buffer and check for "on" and "off". This way you don't
> have to misuse the _bool() variant for something which is actually
> "option=argument".

I can do that.  Because phys_base hasn't been updated yet, I'll have to
create "on" and "off" constants and get their address in a similar way
to the command line option so that I can do the strncmp properly.

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
