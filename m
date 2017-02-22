Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6BC6B038A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:49:02 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v63so9415304pgv.0
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 07:49:02 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0048.outbound.protection.outlook.com. [104.47.40.48])
        by mx.google.com with ESMTPS id g70si1573531pgc.92.2017.02.22.07.49.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 07:49:01 -0800 (PST)
Subject: Re: [RFC PATCH v4 09/28] x86: Add support for early
 encryption/decryption of memory
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154358.19244.6082.stgit@tlendack-t1.amdoffice.net>
 <20170220182256.qorlso5f4c72hl6o@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <7b8d7258-d5b5-6dbb-afe3-755f6a453d40@amd.com>
Date: Wed, 22 Feb 2017 09:48:52 -0600
MIME-Version: 1.0
In-Reply-To: <20170220182256.qorlso5f4c72hl6o@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/20/2017 12:22 PM, Borislav Petkov wrote:
> On Thu, Feb 16, 2017 at 09:43:58AM -0600, Tom Lendacky wrote:
>> Add support to be able to either encrypt or decrypt data in place during
>> the early stages of booting the kernel. This does not change the memory
>> encryption attribute - it is used for ensuring that data present in either
>> an encrypted or decrypted memory area is in the proper state (for example
>> the initrd will have been loaded by the boot loader and will not be
>> encrypted, but the memory that it resides in is marked as encrypted).
>>
>> The early_memmap support is enhanced to specify encrypted and decrypted
>> mappings with and without write-protection. The use of write-protection is
>> necessary when encrypting data "in place". The write-protect attribute is
>> considered cacheable for loads, but not stores. This implies that the
>> hardware will never give the core a dirty line with this memtype.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/mem_encrypt.h |   15 +++++++
>>  arch/x86/mm/mem_encrypt.c          |   79 ++++++++++++++++++++++++++++++++++++
>>  2 files changed, 94 insertions(+)
>
> ...
>
>> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
>> index d71df97..ac3565c 100644
>> --- a/arch/x86/mm/mem_encrypt.c
>> +++ b/arch/x86/mm/mem_encrypt.c
>> @@ -14,6 +14,9 @@
>>  #include <linux/init.h>
>>  #include <linux/mm.h>
>>
>> +#include <asm/tlbflush.h>
>> +#include <asm/fixmap.h>
>> +
>>  extern pmdval_t early_pmd_flags;
>>
>>  /*
>> @@ -24,6 +27,82 @@
>>  unsigned long sme_me_mask __section(.data) = 0;
>>  EXPORT_SYMBOL_GPL(sme_me_mask);
>>
>> +/* Buffer used for early in-place encryption by BSP, no locking needed */
>> +static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
>> +
>> +/*
>> + * This routine does not change the underlying encryption setting of the
>> + * page(s) that map this memory. It assumes that eventually the memory is
>> + * meant to be accessed as either encrypted or decrypted but the contents
>> + * are currently not in the desired stated.
>
> 				       state.

Will fix.

>
>> + *
>> + * This routine follows the steps outlined in the AMD64 Architecture
>> + * Programmer's Manual Volume 2, Section 7.10.8 Encrypt-in-Place.
>> + */
>> +static void __init __sme_early_enc_dec(resource_size_t paddr,
>> +				       unsigned long size, bool enc)
>> +{
>> +	void *src, *dst;
>> +	size_t len;
>> +
>> +	if (!sme_me_mask)
>> +		return;
>> +
>> +	local_flush_tlb();
>> +	wbinvd();
>> +
>> +	/*
>> +	 * There are limited number of early mapping slots, so map (at most)
>> +	 * one page at time.
>> +	 */
>> +	while (size) {
>> +		len = min_t(size_t, sizeof(sme_early_buffer), size);
>> +
>> +		/*
>> +		 * Create write protected mappings for the current format
>
> 			  write-protected

Ok.

>
>> +		 * of the memory.
>> +		 */
>> +		src = enc ? early_memremap_decrypted_wp(paddr, len) :
>> +			    early_memremap_encrypted_wp(paddr, len);
>> +
>> +		/*
>> +		 * Create mappings for the desired format of the memory.
>> +		 */
>
> That comment can go - you already say that in the previous one.

Ok.

>
>> +		dst = enc ? early_memremap_encrypted(paddr, len) :
>> +			    early_memremap_decrypted(paddr, len);
>
> Btw, looking at this again, it seems to me that if you write it this
> way:
>
>                 if (enc) {
>                         src = early_memremap_decrypted_wp(paddr, len);
>                         dst = early_memremap_encrypted(paddr, len);
>                 } else {
>                         src = early_memremap_encrypted_wp(paddr, len);
>                         dst = early_memremap_decrypted(paddr, len);
>                 }
>
> it might become even more readable. Anyway, just an idea - your decision
> which is better.

I go back and forth on that one, too.  Not sure what I'll do, I guess it
will depend on my mood :).

>
>> +
>> +		/*
>> +		 * If a mapping can't be obtained to perform the operation,
>> +		 * then eventual access of that area will in the desired
>
> s/will //

Yup.

Thanks,
Tom

>
>> +		 * mode will cause a crash.
>> +		 */
>> +		BUG_ON(!src || !dst);
>> +
>> +		/*
>> +		 * Use a temporary buffer, of cache-line multiple size, to
>> +		 * avoid data corruption as documented in the APM.
>> +		 */
>> +		memcpy(sme_early_buffer, src, len);
>> +		memcpy(dst, sme_early_buffer, len);
>> +
>> +		early_memunmap(dst, len);
>> +		early_memunmap(src, len);
>> +
>> +		paddr += len;
>> +		size -= len;
>> +	}
>> +}
>> +
>> +void __init sme_early_encrypt(resource_size_t paddr, unsigned long size)
>> +{
>> +	__sme_early_enc_dec(paddr, size, true);
>> +}
>> +
>> +void __init sme_early_decrypt(resource_size_t paddr, unsigned long size)
>> +{
>> +	__sme_early_enc_dec(paddr, size, false);
>> +}
>> +
>>  void __init sme_early_init(void)
>>  {
>>  	unsigned int i;
>>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
