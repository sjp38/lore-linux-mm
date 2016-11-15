Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2506B0282
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 09:33:16 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g187so1723907itc.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 06:33:16 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0062.outbound.protection.outlook.com. [104.47.38.62])
        by mx.google.com with ESMTPS id n34si15814960ioe.222.2016.11.15.06.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Nov 2016 06:33:15 -0800 (PST)
Subject: Re: [RFC PATCH v3 04/20] x86: Handle reduction in physical address
 size with SME
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003513.3280.12104.stgit@tlendack-t1.amdoffice.net>
 <20161115121035.GD24857@8bytes.org>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <f36306aa-cc28-ae2e-1a7e-a6b69c474daf@amd.com>
Date: Tue, 15 Nov 2016 08:32:50 -0600
MIME-Version: 1.0
In-Reply-To: <20161115121035.GD24857@8bytes.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/15/2016 6:10 AM, Joerg Roedel wrote:
> On Wed, Nov 09, 2016 at 06:35:13PM -0600, Tom Lendacky wrote:
>> +/*
>> + * AMD Secure Memory Encryption (SME) can reduce the size of the physical
>> + * address space if it is enabled, even if memory encryption is not active.
>> + * Adjust x86_phys_bits if SME is enabled.
>> + */
>> +static void phys_bits_adjust(struct cpuinfo_x86 *c)
>> +{
> 
> Better call this function amd_sme_phys_bits_adjust(). This name makes it
> clear at the call-site why it is there and what it does.

Will do.

> 
>> +	u32 eax, ebx, ecx, edx;
>> +	u64 msr;
>> +
>> +	if (c->x86_vendor != X86_VENDOR_AMD)
>> +		return;
>> +
>> +	if (c->extended_cpuid_level < 0x8000001f)
>> +		return;
>> +
>> +	/* Check for SME feature */
>> +	cpuid(0x8000001f, &eax, &ebx, &ecx, &edx);
>> +	if (!(eax & 0x01))
>> +		return;
> 
> Maybe add a comment here why you can't use cpu_has (yet).
> 

Ok, will do.

Thanks,
Tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
