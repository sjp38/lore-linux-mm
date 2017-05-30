Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 33D226B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 10:39:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h76so98198062pfh.15
        for <linux-mm@kvack.org>; Tue, 30 May 2017 07:39:06 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0077.outbound.protection.outlook.com. [104.47.40.77])
        by mx.google.com with ESMTPS id u22si45968185plk.91.2017.05.30.07.39.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 May 2017 07:39:05 -0700 (PDT)
Subject: Re: [PATCH v5 32/32] x86/mm: Add support to make use of Secure Memory
 Encryption
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212223.10190.85121.stgit@tlendack-t1.amdoffice.net>
 <20170519112703.voajtn4t7uy6nwa3@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <7c522f65-c5c8-9362-e1eb-d0765e3ea6c9@amd.com>
Date: Tue, 30 May 2017 09:38:36 -0500
MIME-Version: 1.0
In-Reply-To: <20170519112703.voajtn4t7uy6nwa3@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/19/2017 6:27 AM, Borislav Petkov wrote:
> On Tue, Apr 18, 2017 at 04:22:23PM -0500, Tom Lendacky wrote:
>> Add support to check if SME has been enabled and if memory encryption
>> should be activated (checking of command line option based on the
>> configuration of the default state).  If memory encryption is to be
>> activated, then the encryption mask is set and the kernel is encrypted
>> "in place."
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   arch/x86/kernel/head_64.S |    1 +
>>   arch/x86/mm/mem_encrypt.c |   83 +++++++++++++++++++++++++++++++++++++++++++--
>>   2 files changed, 80 insertions(+), 4 deletions(-)
> 
> ...
> 
>> +unsigned long __init sme_enable(struct boot_params *bp)
>>   {
>> +	const char *cmdline_ptr, *cmdline_arg, *cmdline_on, *cmdline_off;
>> +	unsigned int eax, ebx, ecx, edx;
>> +	unsigned long me_mask;
>> +	bool active_by_default;
>> +	char buffer[16];
>> +	u64 msr;
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
> 
> <---- newline here.
> 
>> +	me_mask = 1UL << (ebx & 0x3f);
>> +
>> +	/* Check if SME is enabled */
>> +	msr = __rdmsr(MSR_K8_SYSCFG);
>> +	if (!(msr & MSR_K8_SYSCFG_MEM_ENCRYPT))
>> +		goto out;
>> +
>> +	/*
>> +	 * Fixups have not been applied to phys_base yet, so we must obtain
>> +	 * the address to the SME command line option data in the following
>> +	 * way.
>> +	 */
>> +	asm ("lea sme_cmdline_arg(%%rip), %0"
>> +	     : "=r" (cmdline_arg)
>> +	     : "p" (sme_cmdline_arg));
>> +	asm ("lea sme_cmdline_on(%%rip), %0"
>> +	     : "=r" (cmdline_on)
>> +	     : "p" (sme_cmdline_on));
>> +	asm ("lea sme_cmdline_off(%%rip), %0"
>> +	     : "=r" (cmdline_off)
>> +	     : "p" (sme_cmdline_off));
>> +
>> +	if (IS_ENABLED(CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT))
>> +		active_by_default = true;
>> +	else
>> +		active_by_default = false;
>> +
>> +	cmdline_ptr = (const char *)((u64)bp->hdr.cmd_line_ptr |
>> +				     ((u64)bp->ext_cmd_line_ptr << 32));
>> +
>> +	cmdline_find_option(cmdline_ptr, cmdline_arg, buffer, sizeof(buffer));
>> +
>> +	if (strncmp(buffer, cmdline_on, sizeof(buffer)) == 0)
>> +		sme_me_mask = me_mask;
> 
> Why doesn't simply
> 
> 	if (!strncmp(buffer, "on", 2))
> 		...
> 
> work?

In this case we're running identity mapped and the "on" constant ends up
as kernel address (0xffffffff81...) which results in a segfault.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
