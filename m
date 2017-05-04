Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF10831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 10:39:29 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id z125so18275142itc.12
        for <linux-mm@kvack.org>; Thu, 04 May 2017 07:39:29 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0081.outbound.protection.outlook.com. [104.47.36.81])
        by mx.google.com with ESMTPS id m43si1234067iti.86.2017.05.04.07.39.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 04 May 2017 07:39:28 -0700 (PDT)
Subject: Re: [PATCH v5 12/32] x86/mm: Insure that boot memory areas are mapped
 properly
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211822.10190.67435.stgit@tlendack-t1.amdoffice.net>
 <20170504101609.vazu4tuc3gqapaqk@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <2384de89-4c55-a181-148e-128943f18d5f@amd.com>
Date: Thu, 4 May 2017 09:39:20 -0500
MIME-Version: 1.0
In-Reply-To: <20170504101609.vazu4tuc3gqapaqk@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/4/2017 5:16 AM, Borislav Petkov wrote:
> On Tue, Apr 18, 2017 at 04:18:22PM -0500, Tom Lendacky wrote:
>> The boot data and command line data are present in memory in a decrypted
>> state and are copied early in the boot process.  The early page fault
>> support will map these areas as encrypted, so before attempting to copy
>> them, add decrypted mappings so the data is accessed properly when copied.
>>
>> For the initrd, encrypt this data in place. Since the future mapping of the
>> initrd area will be mapped as encrypted the data will be accessed properly.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/mem_encrypt.h |   11 +++++
>>  arch/x86/include/asm/pgtable.h     |    3 +
>>  arch/x86/kernel/head64.c           |   30 ++++++++++++--
>>  arch/x86/kernel/setup.c            |   10 +++++
>>  arch/x86/mm/mem_encrypt.c          |   77 ++++++++++++++++++++++++++++++++++++
>>  5 files changed, 127 insertions(+), 4 deletions(-)
>
> ...
>
>> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
>> index 603a166..a95800b 100644
>> --- a/arch/x86/kernel/setup.c
>> +++ b/arch/x86/kernel/setup.c
>> @@ -115,6 +115,7 @@
>>  #include <asm/microcode.h>
>>  #include <asm/mmu_context.h>
>>  #include <asm/kaslr.h>
>> +#include <asm/mem_encrypt.h>
>>
>>  /*
>>   * max_low_pfn_mapped: highest direct mapped pfn under 4GB
>> @@ -374,6 +375,15 @@ static void __init reserve_initrd(void)
>>  	    !ramdisk_image || !ramdisk_size)
>>  		return;		/* No initrd provided by bootloader */
>>
>> +	/*
>> +	 * If SME is active, this memory will be marked encrypted by the
>> +	 * kernel when it is accessed (including relocation). However, the
>> +	 * ramdisk image was loaded decrypted by the bootloader, so make
>> +	 * sure that it is encrypted before accessing it.
>> +	 */
>> +	if (sme_active())
>
> That test is not needed here because __sme_early_enc_dec() already tests
> sme_me_mask. There you should change that test to sme_active() instead.

Yeah, I was probably thinking slightly ahead to SEV where the initrd
will already be encrypted and so we only want to do this for SME.
That change can come in the SEV support patches, though.

Thanks,
Tom

>
>> +		sme_early_encrypt(ramdisk_image, ramdisk_end - ramdisk_image);
>> +
>>  	initrd_start = 0;
>>
>>  	mapped_size = memblock_mem_size(max_pfn_mapped);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
