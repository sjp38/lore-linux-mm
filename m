Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 027DF8E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 07:56:03 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id t7so7054713edr.21
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 04:56:02 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id la26-v6si1561836ejb.33.2019.01.12.04.56.01
        for <linux-mm@kvack.org>;
        Sat, 12 Jan 2019 04:56:01 -0800 (PST)
Subject: Re: [PATCH] mm: Introduce GFP_PGTABLE
References: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
 <20190112121230.GQ6310@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <9dd9a8ef-8db8-891c-79a9-270ab033037c@arm.com>
Date: Sat, 12 Jan 2019 18:25:48 +0530
MIME-Version: 1.0
In-Reply-To: <20190112121230.GQ6310@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, mpe@ellerman.id.au, tglx@linutronix.de, mingo@redhat.com, dave.hansen@linux.intel.com, peterz@infradead.org, christoffer.dall@arm.com, marc.zyngier@arm.com, kirill@shutemov.name, rppt@linux.vnet.ibm.com, mhocko@suse.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, steve.capper@arm.com, james.morse@arm.com, robin.murphy@arm.com, aneesh.kumar@linux.ibm.com, vbabka@suse.cz, shakeelb@google.com, rientjes@google.com



On 01/12/2019 05:42 PM, Matthew Wilcox wrote:
> On Sat, Jan 12, 2019 at 03:56:38PM +0530, Anshuman Khandual wrote:
>> All architectures have been defining their own PGALLOC_GFP as (GFP_KERNEL |
>> __GFP_ZERO) and using it for allocating page table pages.
> 
> Except that's not true.
> 
>> +++ b/arch/x86/mm/pgtable.c
>> @@ -13,19 +13,17 @@ phys_addr_t physical_mask __ro_after_init = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
>>  EXPORT_SYMBOL(physical_mask);
>>  #endif
>>  
>> -#define PGALLOC_GFP (GFP_KERNEL_ACCOUNT | __GFP_ZERO)
>> -
>>  #ifdef CONFIG_HIGHPTE
> 
> ...
> 
>>  pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
>>  {
>> -	return (pte_t *)__get_free_page(PGALLOC_GFP & ~__GFP_ACCOUNT);
>> +	return (pte_t *)__get_free_page(GFP_PGTABLE & ~__GFP_ACCOUNT);
>>  }
> 
> I think x86 was the only odd one out here, but you'll need to try again ...

IIUC the user page table pages need __GFP_ACCOUNT not the kernel ones. Hence
in the above function it clears out __GFP_ACCOUNT for kernel page table page
allocations but where as by default it has got __GFP_ACCOUNT which would be
used for user page tables. Instead we can make X86 user allocations add
__GFP_ACCOUNT (like other archs) to generic GFP_PGTABLE when ever required.
