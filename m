Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F01C8E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 08:49:33 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id y74so1486880wmc.0
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 05:49:33 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id d14si49591016wrg.151.2019.01.12.05.49.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Jan 2019 05:49:31 -0800 (PST)
Subject: Re: [PATCH] mm: Introduce GFP_PGTABLE
References: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
 <20190112121230.GQ6310@bombadil.infradead.org>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <ddd59fdc-3d8f-4015-e851-e7f099193a1b@c-s.fr>
Date: Sat, 12 Jan 2019 14:49:29 +0100
MIME-Version: 1.0
In-Reply-To: <20190112121230.GQ6310@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Anshuman Khandual <anshuman.khandual@arm.com>
Cc: mark.rutland@arm.com, mhocko@suse.com, linux-sh@vger.kernel.org, peterz@infradead.org, catalin.marinas@arm.com, dave.hansen@linux.intel.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvmarm@lists.cs.columbia.edu, linux@armlinux.org.uk, mingo@redhat.com, vbabka@suse.cz, rientjes@google.com, marc.zyngier@arm.com, rppt@linux.vnet.ibm.com, shakeelb@google.com, kirill@shutemov.name, tglx@linutronix.de, linux-arm-kernel@lists.infradead.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, steve.capper@arm.com, christoffer.dall@arm.com, james.morse@arm.com, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org



Le 12/01/2019 à 13:12, Matthew Wilcox a écrit :
> On Sat, Jan 12, 2019 at 03:56:38PM +0530, Anshuman Khandual wrote:
>> All architectures have been defining their own PGALLOC_GFP as (GFP_KERNEL |
>> __GFP_ZERO) and using it for allocating page table pages.
> 
> Except that's not true.
> 
>> +++ b/arch/x86/mm/pgtable.c
>> @@ -13,19 +13,17 @@ phys_addr_t physical_mask __ro_after_init = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;
>>   EXPORT_SYMBOL(physical_mask);
>>   #endif
>>   
>> -#define PGALLOC_GFP (GFP_KERNEL_ACCOUNT | __GFP_ZERO)
>> -
>>   #ifdef CONFIG_HIGHPTE
> 
> ...
> 
>>   pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
>>   {
>> -	return (pte_t *)__get_free_page(PGALLOC_GFP & ~__GFP_ACCOUNT);
>> +	return (pte_t *)__get_free_page(GFP_PGTABLE & ~__GFP_ACCOUNT);
>>   }

As far as I can see,

#define GFP_KERNEL_ACCOUNT (GFP_KERNEL | __GFP_ACCOUNT)

So what's the difference between:

(GFP_KERNEL_ACCOUNT | __GFP_ZERO) & ~__GFP_ACCOUNT

and

(GFP_KERNEL | __GFP_ZERO) & ~__GFP_ACCOUNT

Christophe

> 
> I think x86 was the only odd one out here, but you'll need to try again ...
> 
