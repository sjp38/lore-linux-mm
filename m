Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 06FD76B049F
	for <linux-mm@kvack.org>; Sat, 19 Nov 2016 13:13:18 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id 128so306163837oih.1
        for <linux-mm@kvack.org>; Sat, 19 Nov 2016 10:13:18 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0046.outbound.protection.outlook.com. [104.47.38.46])
        by mx.google.com with ESMTPS id k2si5243812ote.122.2016.11.19.10.13.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 19 Nov 2016 10:13:17 -0800 (PST)
Subject: Re: [RFC PATCH v3 09/20] x86: Insure that boot memory areas are
 mapped properly
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003620.3280.20613.stgit@tlendack-t1.amdoffice.net>
 <20161117122015.kxnwjtgyzitxio2p@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <d6e8539a-0e4d-8d16-ffe1-e88595cb7ab3@amd.com>
Date: Sat, 19 Nov 2016 12:12:27 -0600
MIME-Version: 1.0
In-Reply-To: <20161117122015.kxnwjtgyzitxio2p@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/17/2016 6:20 AM, Borislav Petkov wrote:
> On Wed, Nov 09, 2016 at 06:36:20PM -0600, Tom Lendacky wrote:
>> The boot data and command line data are present in memory in an
>> un-encrypted state and are copied early in the boot process.  The early
>> page fault support will map these areas as encrypted, so before attempting
>> to copy them, add unencrypted mappings so the data is accessed properly
>> when copied.
>>
>> For the initrd, encrypt this data in place. Since the future mapping of the
>> initrd area will be mapped as encrypted the data will be accessed properly.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/mem_encrypt.h |   13 ++++++++
>>  arch/x86/kernel/head64.c           |   21 ++++++++++++--
>>  arch/x86/kernel/setup.c            |    9 ++++++
>>  arch/x86/mm/mem_encrypt.c          |   56 ++++++++++++++++++++++++++++++++++++
>>  4 files changed, 96 insertions(+), 3 deletions(-)
> 
> ...
> 
>> @@ -122,6 +131,12 @@ static void __init copy_bootdata(char *real_mode_data)
>>  	char * command_line;
>>  	unsigned long cmd_line_ptr;
>>  
>> +	/*
>> +	 * If SME is active, this will create un-encrypted mappings of the
>> +	 * boot data in advance of the copy operations
> 						      ^
> 						      |
> 					    Fullstop--+
> 
>> +	 */
>> +	sme_map_bootdata(real_mode_data);
>> +
>>  	memcpy(&boot_params, real_mode_data, sizeof boot_params);
>>  	sanitize_boot_params(&boot_params);
>>  	cmd_line_ptr = get_cmd_line_ptr();
> 
> ...
> 
>> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
>> index 06235b4..411210d 100644
>> --- a/arch/x86/mm/mem_encrypt.c
>> +++ b/arch/x86/mm/mem_encrypt.c
>> @@ -16,8 +16,11 @@
>>  
>>  #include <asm/tlbflush.h>
>>  #include <asm/fixmap.h>
>> +#include <asm/setup.h>
>> +#include <asm/bootparam.h>
>>  
>>  extern pmdval_t early_pmd_flags;
>> +int __init __early_make_pgtable(unsigned long, pmdval_t);
>>  
>>  /*
>>   * Since sme_me_mask is set early in the boot process it must reside in
>> @@ -126,6 +129,59 @@ void __init sme_early_mem_dec(resource_size_t paddr, unsigned long size)
>>  	}
>>  }
>>  
>> +static void __init *sme_bootdata_mapping(void *vaddr, unsigned long size)
> 
> So this could be called __sme_map_bootdata(). "sme_bootdata_mapping"
> doesn't tell me what the function does as there's no verb in the name.
> 

Ok, makes sense.

>> +{
>> +	unsigned long paddr = (unsigned long)vaddr - __PAGE_OFFSET;
>> +	pmdval_t pmd_flags, pmd;
>> +	void *ret = vaddr;
> 
> That *ret --->
> 
>> +
>> +	/* Use early_pmd_flags but remove the encryption mask */
>> +	pmd_flags = early_pmd_flags & ~sme_me_mask;
>> +
>> +	do {
>> +		pmd = (paddr & PMD_MASK) + pmd_flags;
>> +		__early_make_pgtable((unsigned long)vaddr, pmd);
>> +
>> +		vaddr += PMD_SIZE;
>> +		paddr += PMD_SIZE;
>> +		size = (size < PMD_SIZE) ? 0 : size - PMD_SIZE;
> 
> 			size <= PMD_SIZE
> 
> 				looks more obvious to me...

Ok, will do.

> 
>> +	} while (size);
>> +
>> +	return ret;
> 
> ---> is simply passing vaddr out. So the function can be just as well be
> void and you can do below:
> 
> 	__sme_map_bootdata(real_mode_data, sizeof(boot_params));
> 
> 	boot_data = (struct boot_params *)real_mode_data;
> 
> 	...

Ok, that simplifies the function too.

> 
>> +void __init sme_map_bootdata(char *real_mode_data)
>> +{
>> +	struct boot_params *boot_data;
>> +	unsigned long cmdline_paddr;
>> +
>> +	if (!sme_me_mask)
>> +		return;
>> +
>> +	/*
>> +	 * The bootdata will not be encrypted, so it needs to be mapped
>> +	 * as unencrypted data so it can be copied properly.
>> +	 */
>> +	boot_data = sme_bootdata_mapping(real_mode_data, sizeof(boot_params));
>> +
>> +	/*
>> +	 * Determine the command line address only after having established
>> +	 * the unencrypted mapping.
>> +	 */
>> +	cmdline_paddr = boot_data->hdr.cmd_line_ptr |
>> +			((u64)boot_data->ext_cmd_line_ptr << 32);
> 
> <---- newline here.
> 
>> +	if (cmdline_paddr)
>> +		sme_bootdata_mapping(__va(cmdline_paddr), COMMAND_LINE_SIZE);
>> +}
>> +
>> +void __init sme_encrypt_ramdisk(resource_size_t paddr, unsigned long size)
>> +{
>> +	if (!sme_me_mask)
>> +		return;
>> +
>> +	sme_early_mem_enc(paddr, size);
>> +}
> 
> So this one could simply be called sme_encrypt_area() and be used for
> other things. There's nothing special about encrypting a ramdisk, by the
> looks of it.

The sme_early_mem_enc() function is already exposed so I'll use that. I
originally had it that way but tried to hide any logic associated with
it by just calling this function.  Any changes in logic in the future
would be handled within the SME function.  But that can be done in the
future if needed.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
