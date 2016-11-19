Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E86726B04A9
	for <linux-mm@kvack.org>; Sat, 19 Nov 2016 13:48:37 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id v84so310779119oie.0
        for <linux-mm@kvack.org>; Sat, 19 Nov 2016 10:48:37 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0052.outbound.protection.outlook.com. [104.47.34.52])
        by mx.google.com with ESMTPS id m58si5265697otd.224.2016.11.19.10.48.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 19 Nov 2016 10:48:37 -0800 (PST)
Subject: Re: [RFC PATCH v3 11/20] x86: Add support for changing memory
 encryption attribute
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003655.3280.57333.stgit@tlendack-t1.amdoffice.net>
 <20161117173945.gnar3arpyeeh5xm2@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <6f1a16e4-5a84-20c0-4bd3-3be5ed933800@amd.com>
Date: Sat, 19 Nov 2016 12:48:27 -0600
MIME-Version: 1.0
In-Reply-To: <20161117173945.gnar3arpyeeh5xm2@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/17/2016 11:39 AM, Borislav Petkov wrote:
> On Wed, Nov 09, 2016 at 06:36:55PM -0600, Tom Lendacky wrote:
>> This patch adds support to be change the memory encryption attribute for
>> one or more memory pages.
> 
> "Add support for changing ..."

Yeah, I kind of messed up that description a bit!

> 
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  arch/x86/include/asm/cacheflush.h  |    3 +
>>  arch/x86/include/asm/mem_encrypt.h |   13 ++++++
>>  arch/x86/mm/mem_encrypt.c          |   43 +++++++++++++++++++++
>>  arch/x86/mm/pageattr.c             |   73 ++++++++++++++++++++++++++++++++++++
>>  4 files changed, 132 insertions(+)
> 
> ...
> 
>> diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
>> index 411210d..41cfdf9 100644
>> --- a/arch/x86/mm/mem_encrypt.c
>> +++ b/arch/x86/mm/mem_encrypt.c
>> @@ -18,6 +18,7 @@
>>  #include <asm/fixmap.h>
>>  #include <asm/setup.h>
>>  #include <asm/bootparam.h>
>> +#include <asm/cacheflush.h>
>>  
>>  extern pmdval_t early_pmd_flags;
>>  int __init __early_make_pgtable(unsigned long, pmdval_t);
>> @@ -33,6 +34,48 @@ EXPORT_SYMBOL_GPL(sme_me_mask);
>>  /* Buffer used for early in-place encryption by BSP, no locking needed */
>>  static char sme_early_buffer[PAGE_SIZE] __aligned(PAGE_SIZE);
>>  
>> +int sme_set_mem_enc(void *vaddr, unsigned long size)
>> +{
>> +	unsigned long addr, numpages;
>> +
>> +	if (!sme_me_mask)
>> +		return 0;
> 
> So those interfaces look duplicated to me: you have exported
> sme_set_mem_enc/sme_set_mem_unenc which take @size and then you have
> set_memory_enc/set_memory_dec which take numpages.
> 
> And then you're testing sme_me_mask in both.
> 
> What I'd prefer to have is only *two* set_memory_enc/set_memory_dec
> which take size in bytes and one workhorse __set_memory_enc_dec() which
> does it all. The user shouldn't have to care about numpages or size or
> whatever.
> 
> Ok?

Yup, makes sense. I'll redo this.

> 
>> +
>> +	addr = (unsigned long)vaddr & PAGE_MASK;
>> +	numpages = PAGE_ALIGN(size) >> PAGE_SHIFT;
>> +
>> +	/*
>> +	 * The set_memory_xxx functions take an integer for numpages, make
>> +	 * sure it doesn't exceed that.
>> +	 */
>> +	if (numpages > INT_MAX)
>> +		return -EINVAL;
>> +
>> +	return set_memory_enc(addr, numpages);
>> +}
>> +EXPORT_SYMBOL_GPL(sme_set_mem_enc);
>> +
>> +int sme_set_mem_unenc(void *vaddr, unsigned long size)
>> +{
>> +	unsigned long addr, numpages;
>> +
>> +	if (!sme_me_mask)
>> +		return 0;
>> +
>> +	addr = (unsigned long)vaddr & PAGE_MASK;
>> +	numpages = PAGE_ALIGN(size) >> PAGE_SHIFT;
>> +
>> +	/*
>> +	 * The set_memory_xxx functions take an integer for numpages, make
>> +	 * sure it doesn't exceed that.
>> +	 */
>> +	if (numpages > INT_MAX)
>> +		return -EINVAL;
>> +
>> +	return set_memory_dec(addr, numpages);
>> +}
>> +EXPORT_SYMBOL_GPL(sme_set_mem_unenc);
>> +
>>  /*
>>   * This routine does not change the underlying encryption setting of the
>>   * page(s) that map this memory. It assumes that eventually the memory is
>> diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
>> index b8e6bb5..babf3a6 100644
>> --- a/arch/x86/mm/pageattr.c
>> +++ b/arch/x86/mm/pageattr.c
>> @@ -1729,6 +1729,79 @@ int set_memory_4k(unsigned long addr, int numpages)
>>  					__pgprot(0), 1, 0, NULL);
>>  }
>>  
>> +static int __set_memory_enc_dec(struct cpa_data *cpa)
>> +{
>> +	unsigned long addr;
>> +	int numpages;
>> +	int ret;
>> +
>> +	/* People should not be passing in unaligned addresses */
>> +	if (WARN_ONCE(*cpa->vaddr & ~PAGE_MASK,
>> +		      "misaligned address: %#lx\n", *cpa->vaddr))
>> +		*cpa->vaddr &= PAGE_MASK;
>> +
>> +	addr = *cpa->vaddr;
>> +	numpages = cpa->numpages;
>> +
>> +	/* Must avoid aliasing mappings in the highmem code */
>> +	kmap_flush_unused();
>> +	vm_unmap_aliases();
>> +
>> +	ret = __change_page_attr_set_clr(cpa, 1);
>> +
>> +	/* Check whether we really changed something */
>> +	if (!(cpa->flags & CPA_FLUSHTLB))
>> +		goto out;
> 
> That label is used only once - just "return ret;" here.

Yup, will do.

> 
>> +	/*
>> +	 * On success we use CLFLUSH, when the CPU supports it to
>> +	 * avoid the WBINVD.
>> +	 */
>> +	if (!ret && static_cpu_has(X86_FEATURE_CLFLUSH))
>> +		cpa_flush_range(addr, numpages, 1);
>> +	else
>> +		cpa_flush_all(1);
>> +
>> +out:
>> +	return ret;
>> +}
>> +
>> +int set_memory_enc(unsigned long addr, int numpages)
>> +{
>> +	struct cpa_data cpa;
>> +
>> +	if (!sme_me_mask)
>> +		return 0;
>> +
>> +	memset(&cpa, 0, sizeof(cpa));
>> +	cpa.vaddr = &addr;
>> +	cpa.numpages = numpages;
>> +	cpa.mask_set = __pgprot(_PAGE_ENC);
>> +	cpa.mask_clr = __pgprot(0);
>> +	cpa.pgd = init_mm.pgd;
> 
> You could move that...
> 
>> +
>> +	return __set_memory_enc_dec(&cpa);
>> +}
>> +EXPORT_SYMBOL(set_memory_enc);
>> +
>> +int set_memory_dec(unsigned long addr, int numpages)
>> +{
>> +	struct cpa_data cpa;
>> +
>> +	if (!sme_me_mask)
>> +		return 0;
>> +
>> +	memset(&cpa, 0, sizeof(cpa));
>> +	cpa.vaddr = &addr;
>> +	cpa.numpages = numpages;
>> +	cpa.mask_set = __pgprot(0);
>> +	cpa.mask_clr = __pgprot(_PAGE_ENC);
>> +	cpa.pgd = init_mm.pgd;
> 
> ... and that into __set_memory_enc_dec() too and pass in a "bool dec" or
> "bool enc" or so which presets mask_set and mask_clr properly.
> 
> See above. I think two functions exported to other in-kernel users are
> more than enough.

Should I move this functionality into the sme_set_mem_* functions or
remove the sme_set_mem_* functions and use the set_memory_* functions
directly.  The latter means calculating the number of pages, but makes
it clear that this works on a page level while the former keeps
everything the mem_encrypt.c file (and I can change that to take in a
page count so that it is clear about the page boundary usage).

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
