Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 98D2F6B0253
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 12:15:42 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so77422549pgc.1
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 09:15:42 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0078.outbound.protection.outlook.com. [104.47.38.78])
        by mx.google.com with ESMTPS id h125si23029148pfb.24.2016.11.14.09.15.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 14 Nov 2016 09:15:41 -0800 (PST)
Subject: Re: [RFC PATCH v3 01/20] x86: Documentation for AMD Secure Memory
 Encryption (SME)
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003439.3280.82634.stgit@tlendack-t1.amdoffice.net>
 <20161110105114.oiwcgpb436dxrdpb@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <0a4fd80a-c3ec-5cb3-6996-bb1562c1bf58@amd.com>
Date: Mon, 14 Nov 2016 11:15:23 -0600
MIME-Version: 1.0
In-Reply-To: <20161110105114.oiwcgpb436dxrdpb@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/10/2016 4:51 AM, Borislav Petkov wrote:
> On Wed, Nov 09, 2016 at 06:34:39PM -0600, Tom Lendacky wrote:
>> This patch adds a Documenation entry to decribe the AMD Secure Memory
>> Encryption (SME) feature.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  Documentation/kernel-parameters.txt         |    5 +++
>>  Documentation/x86/amd-memory-encryption.txt |   40 +++++++++++++++++++++++++++
>>  2 files changed, 45 insertions(+)
>>  create mode 100644 Documentation/x86/amd-memory-encryption.txt
>>
>> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
>> index 030e9e9..4c730b0 100644
>> --- a/Documentation/kernel-parameters.txt
>> +++ b/Documentation/kernel-parameters.txt
>> @@ -2282,6 +2282,11 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>>  			memory contents and reserves bad memory
>>  			regions that are detected.
>>  
>> +	mem_encrypt=	[X86-64] Enable AMD Secure Memory Encryption (SME)
>> +			Memory encryption is disabled by default, using this
>> +			switch, memory encryption can be enabled.
> 
> I'd say here:
> 
> 			"Force-enable memory encryption if it is disabled in the
> 			BIOS."

Good suggestion, that will make this clearer.

> 
>> +			on: enable memory encryption
>> +
>>  	meye.*=		[HW] Set MotionEye Camera parameters
>>  			See Documentation/video4linux/meye.txt.
>>  
>> diff --git a/Documentation/x86/amd-memory-encryption.txt b/Documentation/x86/amd-memory-encryption.txt
>> new file mode 100644
>> index 0000000..788d871
>> --- /dev/null
>> +++ b/Documentation/x86/amd-memory-encryption.txt
>> @@ -0,0 +1,40 @@
>> +Secure Memory Encryption (SME) is a feature found on AMD processors.
>> +
>> +SME provides the ability to mark individual pages of memory as encrypted using
>> +the standard x86 page tables.  A page that is marked encrypted will be
>> +automatically decrypted when read from DRAM and encrypted when written to
>> +DRAM.  SME can therefore be used to protect the contents of DRAM from physical
>> +attacks on the system.
>> +
>> +A page is encrypted when a page table entry has the encryption bit set (see
>> +below how to determine the position of the bit).  The encryption bit can be
>> +specified in the cr3 register, allowing the PGD table to be encrypted. Each
>> +successive level of page tables can also be encrypted.
>> +
>> +Support for SME can be determined through the CPUID instruction. The CPUID
>> +function 0x8000001f reports information related to SME:
>> +
>> +	0x8000001f[eax]:
>> +		Bit[0] indicates support for SME
>> +	0x8000001f[ebx]:
>> +		Bit[5:0]  pagetable bit number used to enable memory encryption
>> +		Bit[11:6] reduction in physical address space, in bits, when
>> +			  memory encryption is enabled (this only affects system
>> +			  physical addresses, not guest physical addresses)
>> +
>> +If support for SME is present, MSR 0xc00100010 (SYS_CFG) can be used to
>> +determine if SME is enabled and/or to enable memory encryption:
>> +
>> +	0xc0010010:
>> +		Bit[23]   0 = memory encryption features are disabled
>> +			  1 = memory encryption features are enabled
>> +
>> +Linux relies on BIOS to set this bit if BIOS has determined that the reduction
>> +in the physical address space as a result of enabling memory encryption (see
>> +CPUID information above) will not conflict with the address space resource
>> +requirements for the system.  If this bit is not set upon Linux startup then
>> +Linux itself will not set it and memory encryption will not be possible.
>> +
>> +SME support is configurable through the AMD_MEM_ENCRYPT config option.
>> +Additionally, the mem_encrypt=on command line parameter is required to activate
>> +memory encryption.
> 
> So how am I to understand this? We won't have TSME or we will but it
> will be off by default and users will have to enable it in the BIOS or
> will have to boot with mem_encrypt=on...?
> 
> Can you please expand on all the possible options there would be
> available to users?

Yup, I'll try to expand on the documentation to include all the
possibilities for this.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
