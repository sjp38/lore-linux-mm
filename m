Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE3F6B02B4
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 11:53:03 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id o66so98721158ita.5
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 08:53:03 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0057.outbound.protection.outlook.com. [104.47.32.57])
        by mx.google.com with ESMTPS id r63si14521915itc.134.2017.06.20.08.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 20 Jun 2017 08:53:02 -0700 (PDT)
Subject: Re: [PATCH v7 08/36] x86/mm: Add support to enable SME in early boot
 processing
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185115.18967.79622.stgit@tlendack-t1.amdoffice.net>
 <20170620073845.nteivabsgcdy7gv4@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <49c62e8c-c4ae-6d05-e2a4-aa1fc6e2d717@amd.com>
Date: Tue, 20 Jun 2017 10:52:48 -0500
MIME-Version: 1.0
In-Reply-To: <20170620073845.nteivabsgcdy7gv4@pd.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On 6/20/2017 2:38 AM, Borislav Petkov wrote:
> On Fri, Jun 16, 2017 at 01:51:15PM -0500, Tom Lendacky wrote:
>> Add support to the early boot code to use Secure Memory Encryption (SME).
>> Since the kernel has been loaded into memory in a decrypted state, encrypt
>> the kernel in place and update the early pagetables with the memory
>> encryption mask so that new pagetable entries will use memory encryption.
>>
>> The routines to set the encryption mask and perform the encryption are
>> stub routines for now with functionality to be added in a later patch.
>>
>> Because of the need to have the routines available to head_64.S, the
>> mem_encrypt.c is always built and #ifdefs in mem_encrypt.c will provide
>> functionality or stub routines depending on CONFIG_AMD_MEM_ENCRYPT.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   arch/x86/include/asm/mem_encrypt.h |    8 +++++++
>>   arch/x86/kernel/head64.c           |   33 +++++++++++++++++++++---------
>>   arch/x86/kernel/head_64.S          |   39 ++++++++++++++++++++++++++++++++++--
>>   arch/x86/mm/Makefile               |    4 +---
>>   arch/x86/mm/mem_encrypt.c          |   24 ++++++++++++++++++++++
>>   5 files changed, 93 insertions(+), 15 deletions(-)
> 
> ...
> 
>> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
>> index b99d469..9a78277 100644
>> --- a/arch/x86/mm/mem_encrypt.c
>> +++ b/arch/x86/mm/mem_encrypt.c
>> @@ -11,6 +11,9 @@
>>    */
>>   
>>   #include <linux/linkage.h>
>> +#include <linux/init.h>
>> +
>> +#ifdef CONFIG_AMD_MEM_ENCRYPT
>>   
>>   /*
>>    * Since SME related variables are set early in the boot process they must
>> @@ -19,3 +22,24 @@
>>    */
>>   unsigned long sme_me_mask __section(.data) = 0;
>>   EXPORT_SYMBOL_GPL(sme_me_mask);
>> +
>> +void __init sme_encrypt_kernel(void)
>> +{
>> +}
> 
> Just the minor:
> 
> void __init sme_encrypt_kernel(void) { }
> 
> in case you have to respin.

I have to re-spin for the kbuild test error.  But given that this
function will be filled in later it's probably not worth doing the
space savings here.

Thanks,
Tom

> 
> Reviewed-by: Borislav Petkov <bp@suse.de>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
