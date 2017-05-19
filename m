Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 96EFC2806EE
	for <linux-mm@kvack.org>; Fri, 19 May 2017 15:53:12 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o85so31089142qkh.15
        for <linux-mm@kvack.org>; Fri, 19 May 2017 12:53:12 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0043.outbound.protection.outlook.com. [104.47.33.43])
        by mx.google.com with ESMTPS id c187si9374591qkg.107.2017.05.19.12.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 May 2017 12:53:11 -0700 (PDT)
Subject: Re: [PATCH v5 19/32] x86/mm: Add support to access persistent memory
 in the clear
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211941.10190.19751.stgit@tlendack-t1.amdoffice.net>
 <20170516140449.zmp3sm4krro55bbi@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <adce040c-66ba-55ad-4431-780b9c8d1d72@amd.com>
Date: Fri, 19 May 2017 14:52:58 -0500
MIME-Version: 1.0
In-Reply-To: <20170516140449.zmp3sm4krro55bbi@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/16/2017 9:04 AM, Borislav Petkov wrote:
> On Tue, Apr 18, 2017 at 04:19:42PM -0500, Tom Lendacky wrote:
>> Persistent memory is expected to persist across reboots. The encryption
>> key used by SME will change across reboots which will result in corrupted
>> persistent memory.  Persistent memory is handed out by block devices
>> through memory remapping functions, so be sure not to map this memory as
>> encrypted.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/mm/ioremap.c |   31 ++++++++++++++++++++++++++++++-
>>  1 file changed, 30 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
>> index bce0604..55317ba 100644
>> --- a/arch/x86/mm/ioremap.c
>> +++ b/arch/x86/mm/ioremap.c
>> @@ -425,17 +425,46 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
>>   * Examine the physical address to determine if it is an area of memory
>>   * that should be mapped decrypted.  If the memory is not part of the
>>   * kernel usable area it was accessed and created decrypted, so these
>> - * areas should be mapped decrypted.
>> + * areas should be mapped decrypted. And since the encryption key can
>> + * change across reboots, persistent memory should also be mapped
>> + * decrypted.
>>   */
>>  static bool memremap_should_map_decrypted(resource_size_t phys_addr,
>>  					  unsigned long size)
>>  {
>> +	int is_pmem;
>> +
>> +	/*
>> +	 * Check if the address is part of a persistent memory region.
>> +	 * This check covers areas added by E820, EFI and ACPI.
>> +	 */
>> +	is_pmem = region_intersects(phys_addr, size, IORESOURCE_MEM,
>> +				    IORES_DESC_PERSISTENT_MEMORY);
>> +	if (is_pmem != REGION_DISJOINT)
>> +		return true;
>> +
>> +	/*
>> +	 * Check if the non-volatile attribute is set for an EFI
>> +	 * reserved area.
>> +	 */
>> +	if (efi_enabled(EFI_BOOT)) {
>> +		switch (efi_mem_type(phys_addr)) {
>> +		case EFI_RESERVED_TYPE:
>> +			if (efi_mem_attributes(phys_addr) & EFI_MEMORY_NV)
>> +				return true;
>> +			break;
>> +		default:
>> +			break;
>> +		}
>> +	}
>> +
>>  	/* Check if the address is outside kernel usable area */
>>  	switch (e820__get_entry_type(phys_addr, phys_addr + size - 1)) {
>>  	case E820_TYPE_RESERVED:
>>  	case E820_TYPE_ACPI:
>>  	case E820_TYPE_NVS:
>>  	case E820_TYPE_UNUSABLE:
>> +	case E820_TYPE_PRAM:
>
> Can't you simply add:
>
> 	case E820_TYPE_PMEM:
>
> here too and thus get rid of the region_intersects() thing above?
>
> Because, for example, e820_type_to_iores_desc() maps E820_TYPE_PMEM to
> IORES_DESC_PERSISTENT_MEMORY so those should be equivalent...

I'll have to double-check this, but I believe that when persistent
memory is identified through the NFIT table it adds it as a resource
but doesn't add it as an e820 entry so I can't rely on the type being
returned as E820_TYPE_PMEM by e820__get_entry_type().

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
