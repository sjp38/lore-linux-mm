Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 70A1A28093C
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 17:42:08 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b2so185903997pgc.6
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 14:42:08 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0074.outbound.protection.outlook.com. [104.47.41.74])
        by mx.google.com with ESMTPS id 102si10926926plb.131.2017.03.10.14.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 14:42:07 -0800 (PST)
From: Brijesh Singh <brijesh.singh@amd.com>
Subject: Re: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock
 when spliting large pages
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846771545.2349.9373586041426414252.stgit@brijesh-build-machine>
 <20170310110657.hophlog2juw5hpzz@pd.tnic>
Message-ID: <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
Date: Fri, 10 Mar 2017 16:41:56 -0600
MIME-Version: 1.0
In-Reply-To: <20170310110657.hophlog2juw5hpzz@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>, Paolo Bonzini <pbonzini@redhat.com>
Cc: brijesh.singh@amd.com, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, davem@davemloft.net

Hi Boris,

On 03/10/2017 05:06 AM, Borislav Petkov wrote:
> On Thu, Mar 02, 2017 at 10:15:15AM -0500, Brijesh Singh wrote:
>> If kernel_maps_pages_in_pgd is called early in boot process to change the
>
> kernel_map_pages_in_pgd()
>
>> memory attributes then it fails to allocate memory when spliting large
>> pages. The patch extends the cpa_data to provide the support to use
>> memblock_alloc when slab allocator is not available.
>>
>> The feature will be used in Secure Encrypted Virtualization (SEV) mode,
>> where we may need to change the memory region attributes in early boot
>> process.
>>
>> Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
>> ---
>>  arch/x86/mm/pageattr.c |   51 ++++++++++++++++++++++++++++++++++++++++--------
>>  1 file changed, 42 insertions(+), 9 deletions(-)
>>
>> diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
>> index 46cc89d..9e4ab3b 100644
>> --- a/arch/x86/mm/pageattr.c
>> +++ b/arch/x86/mm/pageattr.c
>> @@ -14,6 +14,7 @@
>>  #include <linux/gfp.h>
>>  #include <linux/pci.h>
>>  #include <linux/vmalloc.h>
>> +#include <linux/memblock.h>
>>
>>  #include <asm/e820/api.h>
>>  #include <asm/processor.h>
>> @@ -37,6 +38,7 @@ struct cpa_data {
>>  	int		flags;
>>  	unsigned long	pfn;
>>  	unsigned	force_split : 1;
>> +	unsigned	force_memblock :1;
>>  	int		curpage;
>>  	struct page	**pages;
>>  };
>> @@ -627,9 +629,8 @@ try_preserve_large_page(pte_t *kpte, unsigned long address,
>>
>>  static int
>>  __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
>> -		   struct page *base)
>> +		  pte_t *pbase, unsigned long new_pfn)
>>  {
>> -	pte_t *pbase = (pte_t *)page_address(base);
>>  	unsigned long ref_pfn, pfn, pfninc = 1;
>>  	unsigned int i, level;
>>  	pte_t *tmp;
>> @@ -646,7 +647,7 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
>>  		return 1;
>>  	}
>>
>> -	paravirt_alloc_pte(&init_mm, page_to_pfn(base));
>> +	paravirt_alloc_pte(&init_mm, new_pfn);
>>
>>  	switch (level) {
>>  	case PG_LEVEL_2M:
>> @@ -707,7 +708,8 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
>>  	 * pagetable protections, the actual ptes set above control the
>>  	 * primary protection behavior:
>>  	 */
>> -	__set_pmd_pte(kpte, address, mk_pte(base, __pgprot(_KERNPG_TABLE)));
>> +	__set_pmd_pte(kpte, address,
>> +		native_make_pte((new_pfn << PAGE_SHIFT) + _KERNPG_TABLE));
>>
>>  	/*
>>  	 * Intel Atom errata AAH41 workaround.
>> @@ -723,21 +725,50 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
>>  	return 0;
>>  }
>>
>> +static pte_t *try_alloc_pte(struct cpa_data *cpa, unsigned long *pfn)
>> +{
>> +	unsigned long phys;
>> +	struct page *base;
>> +
>> +	if (cpa->force_memblock) {
>> +		phys = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
>
> Maybe there's a reason this fires:
>
> WARNING: modpost: Found 2 section mismatch(es).
> To see full details build your kernel with:
> 'make CONFIG_DEBUG_SECTION_MISMATCH=y'
>
> WARNING: vmlinux.o(.text+0x48edc): Section mismatch in reference from the function __change_page_attr() to the function .init.text:memblock_alloc()
> The function __change_page_attr() references
> the function __init memblock_alloc().
> This is often because __change_page_attr lacks a __init
> annotation or the annotation of memblock_alloc is wrong.
>
> WARNING: vmlinux.o(.text+0x491d1): Section mismatch in reference from the function __change_page_attr() to the function .meminit.text:memblock_free()
> The function __change_page_attr() references
> the function __meminit memblock_free().
> This is often because __change_page_attr lacks a __meminit
> annotation or the annotation of memblock_free is wrong.
>

I can take a look at fixing those warning. In my initial attempt was to create
a new function to clear encryption bit but it ended up looking very similar to
__change_page_attr_set_clr() hence decided to extend the exiting function to
use memblock_alloc().


> Why do we need this whole early mapping? For the guest? I don't like
> that memblock thing at all.

Early in boot process, guest kernel allocates some structure (its either
statically allocated or dynamic allocated via memblock_alloc). And shares the physical
address of these structure with hypervisor. Since entire guest memory area is mapped
as encrypted hence those structure's are mapped as encrypted memory range. We need
a method to clear the encryption bit. Sometime these structure maybe part of 2M pages
and need to split into smaller pages.

>
> So I think the approach with the .data..percpu..hv_shared section is
> fine and we should consider SEV-ES
>
> http://support.amd.com/TechDocs/Protecting%20VM%20Register%20State%20with%20SEV-ES.pdf
>
> and do this right from the get-go so that when SEV-ES comes along, we
> should simply be ready and extend that mechanism to put the whole Guest
> Hypervisor Communication Block in there.
>

> But then the fact that you're mapping those decrypted in init_mm.pgd
> makes me think you don't need that early mapping thing at all. Those are
> the decrypted mappings of the hypervisor. And that you can do late.
>

In most cases, guest and hypervisor communication starts as soon as guest provides
the physical address to hypervisor. So we must map the pages as decrypted before
sharing the physical address to hypervisor.

> Now, what would be better, IMHO (and I have no idea about virtualization
> design so take with a grain of salt) is if the guest would allocate
> enough memory for the GHCB and mark it decrypted from the very
> beginning. It will be the communication vehicle with the hypervisor
> anyway.
>
> And we already do similar things in sme_map_bootdata() for the baremetal
> kernel to map boot_data, initrd, EFI, ... and so on things decrypted.
>

I will take a look at sme_map_bootdata but I believe the main difference is,
in case of SME those memory regions were allocated by bios or bootloader as
decrypted and sme_map_bootdata clears the encryptions bit.

In case of guest, memory maybe dynamically allocated at boot time and may not have same
attribute as early mapping.

> And we should extend that mechanism to map the GHCB in the guest too and
> then we can get rid of all that need for ->force_memblock which makes
> the crazy mess in pageattr.c even crazier. And it would be lovely if we
> can do it without it.
>
> But maybe Paolo might have an even better idea...
>

I am sure he will have better idea :)

-Brijesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
