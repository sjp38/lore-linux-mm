Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1AA76B025E
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 11:17:20 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id u125so320230449ybg.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 08:17:20 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0052.outbound.protection.outlook.com. [104.47.33.52])
        by mx.google.com with ESMTPS id n81si6392045qka.92.2016.09.12.08.15.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 08:15:09 -0700 (PDT)
Subject: Re: [RFC PATCH v2 11/20] mm: Access BOOT related data in the clear
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223738.29880.6909.stgit@tlendack-t1.amdoffice.net>
 <20160909163814.sgsi2jlxlshskt5c@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <6431e761-a4c8-c9bb-1352-6d66672200fd@amd.com>
Date: Mon, 12 Sep 2016 10:14:59 -0500
MIME-Version: 1.0
In-Reply-To: <20160909163814.sgsi2jlxlshskt5c@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/09/2016 11:38 AM, Borislav Petkov wrote:
> On Mon, Aug 22, 2016 at 05:37:38PM -0500, Tom Lendacky wrote:
>> BOOT data (such as EFI related data) is not encyrpted when the system is
>> booted and needs to be accessed as non-encrypted.  Add support to the
>> early_memremap API to identify the type of data being accessed so that
>> the proper encryption attribute can be applied.  Currently, two types
>> of data are defined, KERNEL_DATA and BOOT_DATA.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
> 
> ...
> 
>> diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
>> index 031db21..e3bdc5a 100644
>> --- a/arch/x86/mm/ioremap.c
>> +++ b/arch/x86/mm/ioremap.c
>> @@ -419,6 +419,25 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr)
>>  	iounmap((void __iomem *)((unsigned long)addr & PAGE_MASK));
>>  }
>>  
>> +/*
>> + * Architecure override of __weak function to adjust the protection attributes
>> + * used when remapping memory.
>> + */
>> +pgprot_t __init early_memremap_pgprot_adjust(resource_size_t phys_addr,
>> +					     unsigned long size,
>> +					     enum memremap_owner owner,
>> +					     pgprot_t prot)
>> +{
>> +	/*
>> +	 * If memory encryption is enabled and BOOT_DATA is being mapped
>> +	 * then remove the encryption bit.
>> +	 */
>> +	if (_PAGE_ENC && (owner == BOOT_DATA))
>> +		prot = __pgprot(pgprot_val(prot) & ~_PAGE_ENC);
>> +
>> +	return prot;
>> +}
>> +
> 
> Hmm, so AFAICT, only arch/x86/xen needs KERNEL_DATA and everything else
> is BOOT_DATA.
> 
> So instead of touching so many files and changing early_memremap(),
> why can't you remove _PAGE_ENC by default on x86 and define a specific
> early_memremap() for arch/x86/xen/ which you call there?
> 
> That would make this patch soo much smaller and the change simpler.

Yes it would.  I'll take a look into that.

> 
> ...
> 
>> diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
>> index 5a2631a..f9286c6 100644
>> --- a/drivers/firmware/efi/efi.c
>> +++ b/drivers/firmware/efi/efi.c
>> @@ -386,7 +386,7 @@ int __init efi_mem_desc_lookup(u64 phys_addr, efi_memory_desc_t *out_md)
>>  		 * So just always get our own virtual map on the CPU.
>>  		 *
>>  		 */
>> -		md = early_memremap(p, sizeof (*md));
>> +		md = early_memremap(p, sizeof (*md), BOOT_DATA);
> 
> WARNING: space prohibited between function name and open parenthesis '('
> #432: FILE: drivers/firmware/efi/efi.c:389:
> +               md = early_memremap(p, sizeof (*md), BOOT_DATA);
> 
> Please integrate checkpatch.pl into your workflow so that you can catch
> small style nits like this. And don't take its output too seriously... :-)

I did run checkpatch against everything, but was always under the
assumption that I shouldn't change existing warnings/errors like this.
If it's considered ok since I'm touching that line of code then I'll
take care of those situations.

Thanks,
Tom

> 
>>  		if (!md) {
>>  			pr_err_once("early_memremap(%pa, %zu) failed.\n",
>>  				    &p, sizeof (*md));
>> @@ -501,7 +501,8 @@ int __init efi_config_parse_tables(void *config_tables, int count, int sz,
>>  	if (efi.properties_table != EFI_INVALID_TABLE_ADDR) {
>>  		efi_properties_table_t *tbl;
>>  
>> -		tbl = early_memremap(efi.properties_table, sizeof(*tbl));
>> +		tbl = early_memremap(efi.properties_table, sizeof(*tbl),
>> +				     BOOT_DATA);
>>  		if (tbl == NULL) {
>>  			pr_err("Could not map Properties table!\n");
>>  			return -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
