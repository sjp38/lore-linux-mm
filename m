Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6B36B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 11:07:16 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 76so80036633itj.0
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 08:07:16 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0070.outbound.protection.outlook.com. [104.47.38.70])
        by mx.google.com with ESMTPS id i93si941121ioo.45.2017.03.27.08.07.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 27 Mar 2017 08:07:15 -0700 (PDT)
Subject: Re: [RFC PATCH v2 15/32] x86: Add support for changing memory
 encryption attribute in early boot
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846772794.2349.1396854638510933455.stgit@brijesh-build-machine>
 <20170324171257.lgvqcdqec3nla5nb@pd.tnic>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <f8c57c98-4d42-4bfe-f05f-37c607a81a42@amd.com>
Date: Mon, 27 Mar 2017 10:07:00 -0500
MIME-Version: 1.0
In-Reply-To: <20170324171257.lgvqcdqec3nla5nb@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: brijesh.singh@amd.com, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

Hi Boris,

On 03/24/2017 12:12 PM, Borislav Petkov wrote:
>>  }
>>
>> +static inline int __init early_set_memory_decrypted(void *addr,
>> +						    unsigned long size)
>> +{
>> +	return 1;
> 	^^^^^^^^
>
> return 1 when !CONFIG_AMD_MEM_ENCRYPT ?
>
> The non-early variants return 0.
>

I will fix it and use the same return value.

>> +}
>> +
>> +static inline int __init early_set_memory_encrypted(void *addr,
>> +						    unsigned long size)
>> +{
>> +	return 1;
>> +}
>> +
>>  #define __sme_pa		__pa

>> +	unsigned long pfn, npages;
>> +	unsigned long addr = (unsigned long)vaddr & PAGE_MASK;
>> +
>> +	/* We are going to change the physical page attribute from C=1 to C=0.
>> +	 * Flush the caches to ensure that all the data with C=1 is flushed to
>> +	 * memory. Any caching of the vaddr after function returns will
>> +	 * use C=0.
>> +	 */
>
> Kernel comments style is:
>
> 	/*
> 	 * A sentence ending with a full-stop.
> 	 * Another sentence. ...
> 	 * More sentences. ...
> 	 */
>

I will update to use kernel comment style.


>> +	clflush_cache_range(vaddr, size);
>> +
>> +	npages = PAGE_ALIGN(size) >> PAGE_SHIFT;
>> +	pfn = slow_virt_to_phys((void *)addr) >> PAGE_SHIFT;
>> +
>> +	return kernel_map_pages_in_pgd(init_mm.pgd, pfn, addr, npages,
>> +					flags & ~sme_me_mask);
>> +
>> +}
>> +
>> +int __init early_set_memory_decrypted(void *vaddr, unsigned long size)
>> +{
>> +	unsigned long flags = get_pte_flags((unsigned long)vaddr);
>
> So this does lookup_address()...
>
>> +	return early_set_memory_enc_dec(vaddr, size, flags & ~sme_me_mask);
>
> ... and this does it too in slow_virt_to_phys(). So you do it twice per
> vaddr.
>
> So why don't you define a __slow_virt_to_phys() helper - notice
> the "__" - which returns flags in its second parameter and which
> slow_virt_to_phys() calls with a NULL second parameter in the other
> cases?
>

I will look into creating a helper function. thanks

-Brijesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
