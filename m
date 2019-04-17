Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C57AC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 16:45:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1E3220835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 16:45:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1E3220835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A3516B0005; Wed, 17 Apr 2019 12:45:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32C136B0006; Wed, 17 Apr 2019 12:45:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F4AD6B0007; Wed, 17 Apr 2019 12:45:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4F1B6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:45:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id j3so13142084edb.14
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:45:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=4A37CxL0+aMP8ZM+AKb+6N2MExazGn4Z76kiNXe1kSg=;
        b=MyArRiGz0RJFvEr8mlW2M+IACCLT2OgjdqMX3ubKh8ilF5IAjt6j+4VTVXDP+mw3CP
         peIUvcwA+1/3nBVJCXuPpaRNIjGOmllLwFWahApTfywsvfutWMq5IjV1p6Djzq9bG9Qy
         L6AQeFGJtHQqjgHGZf6MyXqb5MawIM5kybiAgfVQBcTwqJLibjldc+UzCZi9AAL4LmWv
         xLjwOOBaildTO2bKGgi+aHqFVA4Pz6zpCfgafXYSGZ3k59Y4XeMFLIWLhMeX+B+MlfXm
         DXh+E/Z0JMzJ3mZ43PmIg6+D9nuqM1tu8RcbpGLy6sesCPabG8xG5Hi1PpB3J/vGJdmO
         cF3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVSTvTi6xIhq1p9XP4LAzwJZ0BBNJnoROhVgBo8giqdqVWDnZ1h
	x/pdLDFCYHQhgh1S1vzxctLoU0nPPvkTOUiF/6kkqf6PYnypcX7qGTXVdrFs7xN9I+Qp9l3nxd8
	pJNKll4JnAHZ/xqHlCqYBBKENV3DxVV8rBbiPKpLkFh+05vTVqix9oTsz5+nhqkr+tA==
X-Received: by 2002:a50:92cf:: with SMTP id l15mr946773eda.20.1555519545140;
        Wed, 17 Apr 2019 09:45:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysjx3KMnaGpGfwz7Qfk8486fxmK3yq8LT2MdpqF0/9PrqUe6ZkC1RT9w7HSXtU/U4LC/Kz
X-Received: by 2002:a50:92cf:: with SMTP id l15mr946710eda.20.1555519543698;
        Wed, 17 Apr 2019 09:45:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555519543; cv=none;
        d=google.com; s=arc-20160816;
        b=ZlO8QhhNInmwMpQSKCN3dRwkNWNT8Vkj+AI370h/NDjKxr1/37/62bwaUZ+HXloyrW
         4w+SZ9dYNYal6JfzooXTvLZ6/72lYkD5igzaK503ao1j2cPAfEZFbEl57j14YA9ynGf2
         NFrLknf+GHIXY09t7au10fMf782e06j68pH35wosiBdCsMzjxhASSJkvYjjLgpIOPhDd
         N/y7ViL+Y2/0Qz2mmIuudhG8EttdkbXAWaMYkx1WI4vX+lt3Avxj8/w4/ZEtBRHcXhBJ
         nAnZyYo4zwA7GGPClNKd1sX3qNIFA5t8xPS4WcLjQNPGBon6DkottFofUhR7mv0/d65b
         G4BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=4A37CxL0+aMP8ZM+AKb+6N2MExazGn4Z76kiNXe1kSg=;
        b=va2ILtEr2vPn0a1tgFLDwO9F6fx35YbnvC24/2I4qyey40uUHx/ewJ3F2tdFex7fmj
         7QAWiV/WoMEfugNZwgVHrOpewGClYUzWcEw5DEiF8KAGfcYDuzopWrkbU0CKIh32bDLJ
         kHtfjctScW5SUivk/dQ10kXH3varStAQsfcQsxWCon/8Yin1mAJLhNFTIvyzT4BnT+Ln
         DDM3uw7VsrRPxQzbOr2ZFI2ZA/Bnkjt9T6dPAYDeJ2yGXnTOYVBSC8T4QCx0ZmbP5qMZ
         hxw1V3CgYniSLwo3NBM1ydL/qUJ7xwSg9pfCwqILa0IIBbewgAT81qk3mTFRwl3lh0UH
         HGxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x14si5700913ejc.84.2019.04.17.09.45.43
        for <linux-mm@kvack.org>;
        Wed, 17 Apr 2019 09:45:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4C85FA78;
	Wed, 17 Apr 2019 09:45:42 -0700 (PDT)
Received: from [10.162.41.195] (p8cg001049571a15.blr.arm.com [10.162.41.195])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4F7253F557;
	Wed, 17 Apr 2019 09:45:36 -0700 (PDT)
Subject: Re: [PATCH V2 2/2] arm64/mm: Enable memory hot remove
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com, mhocko@suse.com, mgorman@techsingularity.net,
 james.morse@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 david@redhat.com, cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
 <20190415134841.GC13990@lakrids.cambridge.arm.com>
 <2faba38b-ab79-2dda-1b3c-ada5054d91fa@arm.com>
 <20190417142154.GA393@lakrids.cambridge.arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <bba0b71c-2d04-d589-e2bf-5de37806548f@arm.com>
Date: Wed, 17 Apr 2019 22:15:35 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190417142154.GA393@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/17/2019 07:51 PM, Mark Rutland wrote:
> On Wed, Apr 17, 2019 at 03:28:18PM +0530, Anshuman Khandual wrote:
>> On 04/15/2019 07:18 PM, Mark Rutland wrote:
>>> On Sun, Apr 14, 2019 at 11:29:13AM +0530, Anshuman Khandual wrote:
>>>> Memory removal from an arch perspective involves tearing down two different
>>>> kernel based mappings i.e vmemmap and linear while releasing related page
>>>> table pages allocated for the physical memory range to be removed.
>>>>
>>>> Define a common kernel page table tear down helper remove_pagetable() which
>>>> can be used to unmap given kernel virtual address range. In effect it can
>>>> tear down both vmemap or kernel linear mappings. This new helper is called
>>>> from both vmemamp_free() and ___remove_pgd_mapping() during memory removal.
>>>> The argument 'direct' here identifies kernel linear mappings.
>>>
>>> Can you please explain why we need to treat these differently? I thought
>>> the next paragraph was going to do that, but as per my comment there it
>>> doesn't seem to be relevant. :/
>>
>> For linear mapping there is no actual allocated page which is mapped. Its the
>> pfn derived from physical address (from __va(PA)-->PA translation) which is
>> there in the page table entry and need not be freed any where during tear down.
>>
>> But in case of vmemmap (struct page mapping for a given range) which is a real
>> virtual mapping (like vmalloc) real pages are allocated (buddy or memblock) and
>> are mapped in it's page table entries to effect the translation. These pages
>> need to be freed while tearing down the translation. But for both mappings
>> (linear and vmemmap) their page table pages need to be freed.
>>
>> This differentiation is needed while deciding if [pte|pmd|pud]_page() at any
>> given level needs to be freed or not. Will update the commit message with this
>> explanation if required.
> 
> Ok. I think you just need to say:
> 
>   When removing a vmemmap pagetable range, we must also free the pages
>   used to back this range of the vmemmap.

Sure will update the commit message with something similar.

> 
>>>> While here update arch_add_mempory() to handle __add_pages() failures by
>>>> just unmapping recently added kernel linear mapping. 
>>>
>>> Is this a latent bug?
>>
>> Did not get it. __add_pages() could fail because of __add_section() in which
>> case we should remove the linear mapping added previously in the first step.
>> Is there any concern here ?
> 
> That is the question.
> 
> If that were to fail _before_ this series were applied, does that permit
> anything bad to happen? e.g. is it permitted that when arch_add_memory()

Before this patch ? Yeah if __add_pages() fail then there are no memory
sections created for range (which means it can never be onlined) but they
have got linear mapping which is not good.
 > fails, the relevant memory can be physically removed?

Yeah you can remove it but there are linear mapping entries in init_mm
which when attempted will cause load/store instruction abort even after
a successful MMU translation and should raise an exception on the CPU
doing it.

> 
> If so, that could result in a number of problems, and would be a latent
> bug...

IIUC your question on the possibility of a latent bug. Yes if we just leave
the linear mapping intact which does not have valid memory block sections,
struct pages vmemmap etc it can cause unexpected behavior.

> 
> [...]
> 
>>>> +#ifdef CONFIG_MEMORY_HOTPLUG
>>>> +static void free_pagetable(struct page *page, int order)
>>>
>>> On arm64, all of the stage-1 page tables other than the PGD are always
>>> PAGE_SIZE. We shouldn't need to pass an order around in order to free
>>> page tables.
>>>
>>> It looks like this function is misnamed, and is used to free vmemmap
>>> backing pages in addition to page tables used to map them. It would be
>>> nicer to come up with a better naming scheme.
>>
>> free_pagetable() is being used both for freeing page table pages as well
>> mapped entries at various level (for vmemmap). As you rightly mentioned
>> page table pages are invariably PAGE_SIZE (other than pgd) but theses
>> mapped pages size can vary at various level. free_pagetable() is a very
>> generic helper which can accommodate pages allocated from buddy as well
>> as memblock. But I agree that the naming is misleading.
>>
>> Will something like this will be better ?
>>
>> void free_pagetable_mapped_page(struct page *page, int order)
>> {
>> 	.......................
>> 	.......................
>> }
>>
>> void free_pagetable_page(struct page *page)
>> {
>> 	free_pagetable_mapped_page(page, 0);
>> }
>>
>> - Call free_pgtable_page() while freeing pagetable pages
>> - Call free_pgtable_mapped_page() while freeing mapped pages
> 
> I think the "pgtable" naming isn't necessary. These functions are passed
> the relevant page, and free that page (or a range starting at that
> page).

Though just freeing pages, these helpers free pages belonging to kernel page
table (init_mm) which either contains entries or memory which is mapped in
those entries. Appending 'pgtable' to their name seems appropriate and also
help in preventing others from using it as a generic wrapper to free pages.
But also I guess it is just a matter of code choice.

> 
> I think it would be better to have something like:
> 
> static void free_hotplug_page_range(struct page *page, unsigned long size)
> {
> 	int order = get_order(size);
> 	int nr_pages = 1 << order;
> 
> 	...
> }
> 
> static void free_hotplug_page(struct page *page)
> {
> 	free_hotplug_page_range(page, PAGE_SIZE);
> }
> 
> ... which avoids having to place get_order() in all the callers, and
> makes things a bit easier to read.

Dont have a strong opinion on this but I guess its just code preference.

> 
>>>
>>>> +{
>>>> +	unsigned long magic;
>>>> +	unsigned int nr_pages = 1 << order;
>>>> +
>>>> +	if (PageReserved(page)) {
>>>> +		__ClearPageReserved(page);
>>>> +
>>>> +		magic = (unsigned long)page->freelist;
>>>> +		if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
>>>
>>> Not a new problem, but it's unfortunate that the core code reuses the
>>> page::freelist field for this, given it also uses page::private for the
>>> section number. Using fields from different parts of the union doesn't
>>> seem robust.> 
>>> It would seem nicer to have a private2 field in the struct for anonymous
>>> pages.
>>
>> Okay. But I guess its not something for us to investigate in this context.
>>
>>>
>>>> +			while (nr_pages--)
>>>> +				put_page_bootmem(page++);
>>>> +		} else {
>>>> +			while (nr_pages--)
>>>> +				free_reserved_page(page++);
>>>> +		}
>>>> +	} else {
>>>> +		free_pages((unsigned long)page_address(page), order);
>>>> +	}
>>>> +}
> 
> Looking at this again, I'm surprised that we'd ever free bootmem pages.
> I'd expect that we'd only remove memory that was added as part of a
> hotplug, and that shouldn't have come from bootmem.
> 
> Will we ever really try to free bootmem pages like this?
> 
> [...]
> 

There are page table pages and page table mapped pages for each mapping.

VMEMMAP Mapping:

1) vmemmap_populate (ARM64_4K_PAGES)

a) Vmemmap backing pages:
	- vmemmap_alloc_block_buf(PMD_SIZE, node)
		- sparse_buffer_alloc(size)
			- memblock_alloc_try_nid_raw()	(NA as sparse_buffer is gone [1])

		- OR

		-  vmemmap_alloc_block(size, node)
			- alloc_pages_node()		-> When slab available (runtime)
			- __earlyonly_bootmem_alloc 	-> When slab not available (NA)

b) Vmemmap pgtable pages:

vmemmap_pgd_populate()
vmemmap_pud_populate()
	 vmemmap_alloc_block_zero()
		vmemmap_alloc_block()
			alloc_pages_node()		-> When slab available (runtime)
			__earlyonly_bootmem_alloc()	-> When slab not available (NA)

2) vmemmap_populate (AR64_64K_PAGES || ARM64_16K_PAGES)

a) Vmemmap backing pages:
	vmemmap_pte_populate()
		vmemmap_alloc_block_buf(PAGE_SIZE, node)
		- sparse_buffer_alloc(size)
			- memblock_alloc_try_nid_raw()	(NA as sparse_buffer is gone [1])

		- OR

		-  vmemmap_alloc_block(size, node)
			- alloc_pages_node()		-> When slab available (runtime)
			- __earlyonly_bootmem_alloc 	-> When slab not available (NA)


b) Vmemmap pgtable pages:

vmemmap_pgd_populate()
vmemmap_pud_populate()
vmemmap_pmd_populate()
	 vmemmap_alloc_block_zero()
		vmemmap_alloc_block()
			alloc_pages_node()		-> When slab available (runtime)
			__earlyonly_bootmem_alloc()	-> When slab not available (NA)
			
LINEAR Mapping:

a) There are no backing pages here

b) Linear pgtable pages:

	Gets allocated through __pgd_pgtable_alloc() --> __get_free_page() which is buddy.

You might be right that we never allocate from memblock during memory hotplug but I
would still suggest keeping PageRserved() check to deal with 'accidental/unexpected'
memblock pages. If we are really sure that this is never going to happen then at least
lets do an WARN_ON() if this functions ever gets one non-buddy page.

I did give this a try (just calling free_pages) on couple of configs and did not see
any problem/crash or bad_page() errors. Will do more investigation and tests tomorrow.

[1] Though sparse_buffer gets allocated from memblock it does not stay till runtime.
Early memory uses chunks from it but rest gets released back. Runtime hotplug ideally
should not have got vmemmap backing memory from memblock. 

 
>>> I take it that some higher-level serialization prevents concurrent
>>> modification to this table. Where does that happen?
>>
>> mem_hotplug_begin()
>> mem_hotplug_end()
>>
>> which operates on DEFINE_STATIC_PERCPU_RWSEM(mem_hotplug_lock)
>>
>> - arch_remove_memory() called from (__remove_memory || devm_memremap_pages_release)
>> - vmemmap_free() called from __remove_pages called from (arch_remove_memory || devm_memremap_pages_release)
>>
>> Both __remove_memory() and devm_memremap_pages_release() are protected with
>> pair of these.
>>
>> mem_hotplug_begin()
>> mem_hotplug_end()
>>
>> vmemmap tear down happens before linear mapping and in sequence.
>>
>>>
>>>> +
>>>> +	free_pagetable(pmd_page(*pmd), 0);
>>>
>>> Here we free the pte level of table...
>>>
>>>> +	spin_lock(&init_mm.page_table_lock);
>>>> +	pmd_clear(pmd);
>>>
>>> ... but only here do we disconnect it from the PMD level of table, and
>>> we don't do any TLB maintenance just yet. The page could be poisoned
>>> and/or reallocated before we invalidate the TLB, which is not safe. In
>>> all cases, we must follow the sequence:
>>>
>>> 1) clear the pointer to a table
>>> 2) invalidate any corresponding TLB entries
>>> 3) free the table page
>>>
>>> ... or we risk a number of issues resulting from erroneous programming
>>> of the TLBs. See pmd_free_pte_page() for an example of how to do this
>>> correctly.
>>
>> Okay will send 'addr' into these functions and do somehting like this
>> at all levels as in case for pmd_free_pte_page().
>>
>>         page = pud_page(*pudp);
>>         pud_clear(pudp);
>>         __flush_tlb_kernel_pgtable(addr);
>>         free_pgtable_page(page);
> 
> That looks correct to me!
> 
>>> I'd have thought similar applied to x86, so that implementation looks
>>> suspicious to me too...
>>>
>>>> +	spin_unlock(&init_mm.page_table_lock);
>>>
>>> What precisely is the page_table_lock intended to protect?
>>
>> Concurrent modification to kernel page table (init_mm) while clearing entries.
> 
> Concurrent modification by what code?
> 
> If something else can *modify* the portion of the table that we're
> manipulating, then I don't see how we can safely walk the table up to
> this point without holding the lock, nor how we can safely add memory.
> 
> Even if this is to protect something else which *reads* the tables,
> other code in arm64 which modifies the kernel page tables doesn't take
> the lock.
> 
> Usually, if you can do a lockless walk you have to verify that things
> didn't change once you've taken the lock, but we don't follow that
> pattern here.
> 
> As things stand it's not clear to me whether this is necessary or
> sufficient.

Hence lets take more conservative approach and wrap the entire process of
remove_pagetable() under init_mm.page_table_lock which looks safe unless
in the worst case when free_pages() gets stuck for some reason in which
case we have bigger memory problem to deal with than a soft lock up.

> 
>>> It seems odd to me that we're happy to walk the tables without the lock,
>>> but only grab the lock when performing a modification. That implies we
>>> either have some higher-level mutual exclusion, or we're not holding the
>>> lock in all cases we need to be.
>>
>> On arm64
>>
>> - linear mapping is half kernel virtual range (unlikely to share PGD with any other)
>> - vmemmap and vmalloc might or might not be aligned properly to avoid PGD/PUD/PMD overlap
>> - This kernel virtual space layout is not fixed and can change in future
>>
>> Hence just to be on safer side lets take init_mm.page_table_lock for the entire tear
>> down process in remove_pagetable(). put_page_bootmem/free_reserved_page/free_pages should
>> not block for longer period unlike allocation paths. Hence it should be safe with overall
>> spin lock on init_mm.page_table_lock unless if there are some other concerns.
> 
> Given the other issues with the x86 hot-remove code, it's not clear to
> me whether that locking is correct or necessary. I think that before we
> make any claim as to whether that's safe we should figure out how the
> lock is actually used today.

Did not get you. What is the exact concern with the proposed lock which covers
end to end remove_pagetable() and guarantees that kernel pagetable init_mm wont
be modified cuncurrently. Thats what the definition of mm->page_table_lock says.
Is not that enough ?

struct mm_struct {
................
................
................
spinlock_t page_table_lock; /* Protects page tables and some
                             * counters
                             */
...............
...............
}

The worst would be hot-remove is bit slower which should be an acceptable
proposition IMHO but again I am open to ideas on this.

> 
> I do not think we should mindlessly copy that.

The overall protection for remove_pagetable() with init_mm.page_table_lock is a
deviation from what x86 is doing right now.

