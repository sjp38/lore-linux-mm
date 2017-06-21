Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E88796B03FE
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:55:12 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k93so3822537ioi.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 06:55:12 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0075.outbound.protection.outlook.com. [104.47.41.75])
        by mx.google.com with ESMTPS id i186si1404979ioi.150.2017.06.21.06.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Jun 2017 06:55:11 -0700 (PDT)
Subject: Re: [PATCH v7 07/36] x86/mm: Don't use phys_to_virt in ioremap() if
 SME is active
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net>
 <20170616185104.18967.7867.stgit@tlendack-t1.amdoffice.net>
 <alpine.DEB.2.20.1706210934540.2328@nanos>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <859437c0-d190-240e-6aa5-5edb0b63aa9e@amd.com>
Date: Wed, 21 Jun 2017 08:54:57 -0500
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706210934540.2328@nanos>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, xen-devel@lists.xen.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Paolo Bonzini <pbonzini@redhat.com>

On 6/21/2017 2:37 AM, Thomas Gleixner wrote:
> On Fri, 16 Jun 2017, Tom Lendacky wrote:
>> Currently there is a check if the address being mapped is in the ISA
>> range (is_ISA_range()), and if it is then phys_to_virt() is used to
>> perform the mapping.  When SME is active, however, this will result
>> in the mapping having the encryption bit set when it is expected that
>> an ioremap() should not have the encryption bit set. So only use the
>> phys_to_virt() function if SME is not active
>>
>> Reviewed-by: Borislav Petkov <bp@suse.de>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>   arch/x86/mm/ioremap.c |    7 +++++--
>>   1 file changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
>> index 4c1b5fd..a382ba9 100644
>> --- a/arch/x86/mm/ioremap.c
>> +++ b/arch/x86/mm/ioremap.c
>> @@ -13,6 +13,7 @@
>>   #include <linux/slab.h>
>>   #include <linux/vmalloc.h>
>>   #include <linux/mmiotrace.h>
>> +#include <linux/mem_encrypt.h>
>>   
>>   #include <asm/set_memory.h>
>>   #include <asm/e820/api.h>
>> @@ -106,9 +107,11 @@ static void __iomem *__ioremap_caller(resource_size_t phys_addr,
>>   	}
>>   
>>   	/*
>> -	 * Don't remap the low PCI/ISA area, it's always mapped..
>> +	 * Don't remap the low PCI/ISA area, it's always mapped.
>> +	 *   But if SME is active, skip this so that the encryption bit
>> +	 *   doesn't get set.
>>   	 */
>> -	if (is_ISA_range(phys_addr, last_addr))
>> +	if (is_ISA_range(phys_addr, last_addr) && !sme_active())
>>   		return (__force void __iomem *)phys_to_virt(phys_addr);
> 
> More thoughts about that.
> 
> Making this conditional on !sme_active() is not the best idea. I'd rather
> remove that whole thing and make it unconditional so the code pathes get
> always exercised and any subtle wreckage is detected on a broader base and
> not only on that hard to access and debug SME capable machine owned by Joe
> User.

Ok, that sounds good.  I'll remove the check and usage of phys_to_virt()
and update the changelog with additional detail about that.

Thanks,
Tom

> 
> Thanks,
> 
> 	tglx
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
