Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9634D8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:47:22 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id 51so2931190wrb.15
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:47:22 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id q8si59679033wrf.2.2019.01.16.05.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 05:47:21 -0800 (PST)
Subject: Re: [PATCH V2] mm: Introduce GFP_PGTABLE
References: <1547619692-7946-1-git-send-email-anshuman.khandual@arm.com>
 <20190116065703.GE24149@dhcp22.suse.cz>
 <20190116123018.GF6310@bombadil.infradead.org>
 <07d6a264-dccd-78ab-e8a9-2410bbef7b97@arm.com>
 <20190116131827.GH6310@bombadil.infradead.org>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <521d8511-4c87-49c6-de03-67a71d5bacca@c-s.fr>
Date: Wed, 16 Jan 2019 14:47:16 +0100
MIME-Version: 1.0
In-Reply-To: <20190116131827.GH6310@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Anshuman Khandual <anshuman.khandual@arm.com>
Cc: mark.rutland@arm.com, linux-sh@vger.kernel.org, peterz@infradead.org, catalin.marinas@arm.com, dave.hansen@linux.intel.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, kvmarm@lists.cs.columbia.edu, linux@armlinux.org.uk, mingo@redhat.com, vbabka@suse.cz, rientjes@google.com, palmer@sifive.com, greentime@andestech.com, marc.zyngier@arm.com, rppt@linux.vnet.ibm.com, shakeelb@google.com, kirill@shutemov.name, tglx@linutronix.de, Michal Hocko <mhocko@kernel.org>, linux-arm-kernel@lists.infradead.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, steve.capper@arm.com, christoffer.dall@arm.com, james.morse@arm.com, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org



Le 16/01/2019 à 14:18, Matthew Wilcox a écrit :
> On Wed, Jan 16, 2019 at 06:42:22PM +0530, Anshuman Khandual wrote:
>> On 01/16/2019 06:00 PM, Matthew Wilcox wrote:
>>> On Wed, Jan 16, 2019 at 07:57:03AM +0100, Michal Hocko wrote:
>>>> On Wed 16-01-19 11:51:32, Anshuman Khandual wrote:
>>>>> All architectures have been defining their own PGALLOC_GFP as (GFP_KERNEL |
>>>>> __GFP_ZERO) and using it for allocating page table pages. This causes some
>>>>> code duplication which can be easily avoided. GFP_KERNEL allocated and
>>>>> cleared out pages (__GFP_ZERO) are required for page tables on any given
>>>>> architecture. This creates a new generic GFP flag flag which can be used
>>>>> for any page table page allocation. Does not cause any functional change.
>>>>>
>>>>> GFP_PGTABLE is being added into include/asm-generic/pgtable.h which is the
>>>>> generic page tabe header just to prevent it's potential misuse as a general
>>>>> allocation flag if included in include/linux/gfp.h.
>>>>
>>>> I haven't reviewed the patch yet but I am wondering whether this is
>>>> really worth it without going all the way down to unify the common code
>>>> and remove much more code duplication. Or is this not possible for some
>>>> reason?
>>>
>>> Exactly what I suggested doing in response to v1.
>>>
>>> Also, the approach taken here is crazy.  x86 has a feature that no other
>>> architecture has bothered to implement yet -- accounting page tables
>>> to the process.  Yet instead of spreading that goodness to all other
>>> architectures, Anshuman has gone to more effort to avoid doing that.
>>
>> The basic objective for this patch is to create a common minimum allocation
>> flag that can be used by architectures but that still allows archs to add
>> on additional constraints if they see fit. This patch does not intend to
>> change functionality for any arch.
> 
> I disagree with your objective.  Making more code common is a great idea,
> but this patch is too unambitious.  We should be heading towards one or
> two page table allocation functions instead of having every architecture do
> its own thing.
> 
> So start there.  Move the x86 function into common code and convert one
> other architecture to use it too.

Are we talking about pte_alloc_one_kernel() and pte_alloc_one() ?

I'm not sure x86 function is the best common one, as it seems to 
allocate a multiple of PAGE_SIZE only.

Some arches like powerpc use pagetables which are smaller than a page, 
for instance powerpc 8xx uses 4k pagetables even with 16k pages, which 
means a single page can be used by 4 pagetables.

Therefore, I would suggest to start with powerpc functions.

Christophe
