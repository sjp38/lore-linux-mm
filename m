Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id ACD4D6B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 10:31:04 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w193so38111090oiw.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 07:31:04 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0046.outbound.protection.outlook.com. [104.47.42.46])
        by mx.google.com with ESMTPS id 186si14728076oig.259.2016.09.07.07.31.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 07:31:03 -0700 (PDT)
Subject: Re: [RFC PATCH v2 07/20] x86: Provide general kernel support for
 memory encryption
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223646.29880.28794.stgit@tlendack-t1.amdoffice.net>
 <20160906093113.GA18319@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <f4125cae-63af-f8c7-086f-e297ce480a07@amd.com>
Date: Wed, 7 Sep 2016 09:30:54 -0500
MIME-Version: 1.0
In-Reply-To: <20160906093113.GA18319@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/06/2016 04:31 AM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:36:46PM -0500, Tom Lendacky wrote:
>> Adding general kernel support for memory encryption includes:
>> - Modify and create some page table macros to include the Secure Memory
>>   Encryption (SME) memory encryption mask
>> - Update kernel boot support to call an SME routine that checks for and
>>   sets the SME capability (the SME routine will grow later and for now
>>   is just a stub routine)
>> - Update kernel boot support to call an SME routine that encrypts the
>>   kernel (the SME routine will grow later and for now is just a stub
>>   routine)
>> - Provide an SME initialization routine to update the protection map with
>>   the memory encryption mask so that it is used by default
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> 
> ...
> 
>> diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
>> index 54a2372..88c7bae 100644
>> --- a/arch/x86/kernel/head64.c
>> +++ b/arch/x86/kernel/head64.c
>> @@ -28,6 +28,7 @@
>>  #include <asm/bootparam_utils.h>
>>  #include <asm/microcode.h>
>>  #include <asm/kasan.h>
>> +#include <asm/mem_encrypt.h>
>>  
>>  /*
>>   * Manage page tables very early on.
>> @@ -42,7 +43,7 @@ static void __init reset_early_page_tables(void)
>>  {
>>  	memset(early_level4_pgt, 0, sizeof(pgd_t)*(PTRS_PER_PGD-1));
>>  	next_early_pgt = 0;
>> -	write_cr3(__pa_nodebug(early_level4_pgt));
>> +	write_cr3(__sme_pa_nodebug(early_level4_pgt));
>>  }
>>  
>>  /* Create a new PMD entry */
>> @@ -54,7 +55,7 @@ int __init early_make_pgtable(unsigned long address)
>>  	pmdval_t pmd, *pmd_p;
>>  
>>  	/* Invalid address or early pgt is done ?  */
>> -	if (physaddr >= MAXMEM || read_cr3() != __pa_nodebug(early_level4_pgt))
>> +	if (physaddr >= MAXMEM || read_cr3() != __sme_pa_nodebug(early_level4_pgt))
>>  		return -1;
>>  
>>  again:
>> @@ -157,6 +158,11 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
>>  
>>  	clear_page(init_level4_pgt);
>>  
>> +	/* Update the early_pmd_flags with the memory encryption mask */
>> +	early_pmd_flags |= _PAGE_ENC;
>> +
>> +	sme_early_init();
>> +
> 
> So maybe this comes later but you're setting _PAGE_ENC unconditionally
> *before* sme_early_init().
> 
> I think you should set it in sme_early_init() and iff SME is enabled.

_PAGE_ENC is #defined as sme_me_mask and sme_me_mask has already been
set (or not set) at this point - so it will be the mask if SME is
active or 0 if SME is not active.  sme_early_init() is merely
propagating the mask to other structures.  Since early_pmd_flags is
mainly used in this file (one line in head_64.S is the other place) I
felt it best to modify it here.  But it can always be moved if you feel
that is best.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
