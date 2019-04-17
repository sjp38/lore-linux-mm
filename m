Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9A40C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:58:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5325520835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:58:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5325520835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5F5C6B0003; Wed, 17 Apr 2019 05:58:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D0F586B0006; Wed, 17 Apr 2019 05:58:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFD376B000D; Wed, 17 Apr 2019 05:58:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 669146B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:58:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m47so6464456edd.15
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 02:58:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=uWy26P5DqTYOoX9lK7nSwybw+K/oTh9Wgd2bDSt3rts=;
        b=GVNjahHAkz4f7qY5oZg8MznlCB1V74hD1n5UyX01um4zyxyMb5HC5yM6VpzdQoKCGk
         UT6z+ebLzStBWYtVMEdWvBsYJoeERtIrBGMV2Xhrkp9CA+Hd+3Ct44x6t1jcjNIJiz9d
         fHatu6rmcCg+zWUtQ1mIZYiPW1tdgMQps4MvrfCTll88IHuLJmCAsnVVRuIH67jDu6Yc
         HifMRuRT6rfTouk5+kKfNRQDMPTjutVZwGl5u/AfEWv6C8A5hG/IwRMB41JKwv3/Bfv6
         jsqiL/uO2L1ln6A90iSzhrX1uTky7JTRz1nTz+fPblvV5LIKjAPXmK8HHnbDtazFzCEG
         8oYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVw72pbhyctVE7ZD60TGFb4d61TOJS3Nqo49kt25G8OS4za6rRu
	gKZB8ZCDNSlIwrnxeHN23+5k1ZuR7gU575LWOvodPII697th04fQBjATdmkKV3QK7HXQKTbkKgn
	hNrvOiVR/pzV09lHUf9p3vgr2IJChYuU5o3K9Kc2AhvaFCAcEuhu2BPYuup1tq5lCTw==
X-Received: by 2002:a50:b6e4:: with SMTP id f33mr25597795ede.2.1555495107926;
        Wed, 17 Apr 2019 02:58:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNkieDszkRp0ShSItYkRui2Wd3a5U2tmb0aLUuEjKA4/uDHC4bXe8/O0koAQtHeSMuSQa9
X-Received: by 2002:a50:b6e4:: with SMTP id f33mr25597718ede.2.1555495106414;
        Wed, 17 Apr 2019 02:58:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555495106; cv=none;
        d=google.com; s=arc-20160816;
        b=hHK0jW75YFcp9rzywjitce2vsPWwrPlY1Yshuc/kPIKb6MdWCB/OPL09/8SYy4Zmv4
         OFzafhYpVdvx9YRiB0hJ7GV8BTmLEO8e5O2M7EOg8vy15km4rPGJzdJ//0DeEDqeQYma
         z6wwalyEbbZrlpqH9JN1vtYFohuQ7PYIjYHCKgY6vjPRMb9Lh5lvxWTmNwjSikMhz5V5
         GNbMQ1xX029REOYkWxqZ3a6z7xdmB7kn2+JKzNEPWz9mrOS5YvEiK6ujS3ilX+2gTJ5T
         XZBCe/RbIKAVziyveQ3xOL425fjlgXIpqEN8Of3lJdFZU1XQVuo9P0XOaUmdmyeyVsVD
         /Sgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=uWy26P5DqTYOoX9lK7nSwybw+K/oTh9Wgd2bDSt3rts=;
        b=MuZ4lMaS1vsfsLlh4GhV4PEvlQegQSGQAk3a+nvWPgRAXoiNyKJ8jgNETB6INaZro/
         jHuwajpbH8hoDdXEbmxF9tG/6EFTRH/r67LAA4qBi4ShLDEa2F3+hoZWeQ/u3hkAX1zs
         cdjt+3AgQ2k142OQm3HhyruPpUcutUYWW1GwVa1FQP0kx62z9tzINs1noPFqk7gvpTx1
         MFluyiavlEpJKHBI5vYB/HUHRu38tqwqYF+mTzpf22b+qyQXzBLFiz5lC0IzN8GmzU5Q
         HycVuCwOPvoIdZPo/Z9vKFGB/WtBok6SUGFKWfppBB26TRbU+H2PAzCQDh5SnOEvvpA9
         BVXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i20si10598484eds.34.2019.04.17.02.58.25
        for <linux-mm@kvack.org>;
        Wed, 17 Apr 2019 02:58:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 38404374;
	Wed, 17 Apr 2019 02:58:25 -0700 (PDT)
Received: from [10.162.41.195] (p8cg001049571a15.blr.arm.com [10.162.41.195])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C11583F68F;
	Wed, 17 Apr 2019 02:58:19 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
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
Message-ID: <2faba38b-ab79-2dda-1b3c-ada5054d91fa@arm.com>
Date: Wed, 17 Apr 2019 15:28:18 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190415134841.GC13990@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/15/2019 07:18 PM, Mark Rutland wrote:
> Hi Anshuman,
> 
> On Sun, Apr 14, 2019 at 11:29:13AM +0530, Anshuman Khandual wrote:
>> Memory removal from an arch perspective involves tearing down two different
>> kernel based mappings i.e vmemmap and linear while releasing related page
>> table pages allocated for the physical memory range to be removed.
>>
>> Define a common kernel page table tear down helper remove_pagetable() which
>> can be used to unmap given kernel virtual address range. In effect it can
>> tear down both vmemap or kernel linear mappings. This new helper is called
>> from both vmemamp_free() and ___remove_pgd_mapping() during memory removal.
>> The argument 'direct' here identifies kernel linear mappings.
> 
> Can you please explain why we need to treat these differently? I thought
> the next paragraph was going to do that, but as per my comment there it
> doesn't seem to be relevant. :/

For linear mapping there is no actual allocated page which is mapped. Its the
pfn derived from physical address (from __va(PA)-->PA translation) which is
there in the page table entry and need not be freed any where during tear down.

But in case of vmemmap (struct page mapping for a given range) which is a real
virtual mapping (like vmalloc) real pages are allocated (buddy or memblock) and
are mapped in it's page table entries to effect the translation. These pages
need to be freed while tearing down the translation. But for both mappings
(linear and vmemmap) their page table pages need to be freed.

This differentiation is needed while deciding if [pte|pmd|pud]_page() at any
given level needs to be freed or not. Will update the commit message with this
explanation if required.

> 
>> Vmemmap mappings page table pages are allocated through sparse mem helper
>> functions like vmemmap_alloc_block() which does not cycle the pages through
>> pgtable_page_ctor() constructs. Hence while removing it skips corresponding
>> destructor construct pgtable_page_dtor().
> 
> I thought the ctor/dtor dance wasn't necessary for any init_mm tables,
> so why do we need to mention it here specifically for the vmemmap
> tables?

Yeah not necessary any more. Will drop it.

> 
>> While here update arch_add_mempory() to handle __add_pages() failures by
>> just unmapping recently added kernel linear mapping. 
> 
> Is this a latent bug?

Did not get it. __add_pages() could fail because of __add_section() in which
case we should remove the linear mapping added previously in the first step.
Is there any concern here ?

> 
>> Now enable memory hot remove on arm64 platforms by default with
>> ARCH_ENABLE_MEMORY_HOTREMOVE.
>>
>> This implementation is overall inspired from kernel page table tear down
>> procedure on X86 architecture.
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>>  arch/arm64/Kconfig               |   3 +
>>  arch/arm64/include/asm/pgtable.h |   2 +
>>  arch/arm64/mm/mmu.c              | 221 ++++++++++++++++++++++++++++++++++++++-
>>  3 files changed, 224 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index c383625..a870eb2 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -267,6 +267,9 @@ config HAVE_GENERIC_GUP
>>  config ARCH_ENABLE_MEMORY_HOTPLUG
>>  	def_bool y
>>  
>> +config ARCH_ENABLE_MEMORY_HOTREMOVE
>> +	def_bool y
>> +
>>  config SMP
>>  	def_bool y
>>  
>> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
>> index de70c1e..1ee22ff 100644
>> --- a/arch/arm64/include/asm/pgtable.h
>> +++ b/arch/arm64/include/asm/pgtable.h
>> @@ -555,6 +555,7 @@ static inline phys_addr_t pud_page_paddr(pud_t pud)
>>  
>>  #else
>>  
>> +#define pmd_index(addr) 0
>>  #define pud_page_paddr(pud)	({ BUILD_BUG(); 0; })
>>  
>>  /* Match pmd_offset folding in <asm/generic/pgtable-nopmd.h> */
>> @@ -612,6 +613,7 @@ static inline phys_addr_t pgd_page_paddr(pgd_t pgd)
>>  
>>  #else
>>  
>> +#define pud_index(adrr)	0
>>  #define pgd_page_paddr(pgd)	({ BUILD_BUG(); 0;})
>>  
>>  /* Match pud_offset folding in <asm/generic/pgtable-nopud.h> */
>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>> index ef82312..a4750fe 100644
>> --- a/arch/arm64/mm/mmu.c
>> +++ b/arch/arm64/mm/mmu.c
>> @@ -733,6 +733,194 @@ int kern_addr_valid(unsigned long addr)
>>  
>>  	return pfn_valid(pte_pfn(pte));
>>  }
>> +
>> +#ifdef CONFIG_MEMORY_HOTPLUG
>> +static void free_pagetable(struct page *page, int order)
> 
> On arm64, all of the stage-1 page tables other than the PGD are always
> PAGE_SIZE. We shouldn't need to pass an order around in order to free
> page tables.
> 
> It looks like this function is misnamed, and is used to free vmemmap
> backing pages in addition to page tables used to map them. It would be
> nicer to come up with a better naming scheme.

free_pagetable() is being used both for freeing page table pages as well
mapped entries at various level (for vmemmap). As you rightly mentioned
page table pages are invariably PAGE_SIZE (other than pgd) but theses
mapped pages size can vary at various level. free_pagetable() is a very
generic helper which can accommodate pages allocated from buddy as well
as memblock. But I agree that the naming is misleading.

Will something like this will be better ?

void free_pagetable_mapped_page(struct page *page, int order)
{
	.......................
	.......................
}

void free_pagetable_page(struct page *page)
{
	free_pagetable_mapped_page(page, 0);
}

- Call free_pgtable_page() while freeing pagetable pages
- Call free_pgtable_mapped_page() while freeing mapped pages

> 
>> +{
>> +	unsigned long magic;
>> +	unsigned int nr_pages = 1 << order;
>> +
>> +	if (PageReserved(page)) {
>> +		__ClearPageReserved(page);
>> +
>> +		magic = (unsigned long)page->freelist;
>> +		if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
> 
> Not a new problem, but it's unfortunate that the core code reuses the
> page::freelist field for this, given it also uses page::private for the
> section number. Using fields from different parts of the union doesn't
> seem robust.> 
> It would seem nicer to have a private2 field in the struct for anonymous
> pages.

Okay. But I guess its not something for us to investigate in this context.

> 
>> +			while (nr_pages--)
>> +				put_page_bootmem(page++);
>> +		} else {
>> +			while (nr_pages--)
>> +				free_reserved_page(page++);
>> +		}
>> +	} else {
>> +		free_pages((unsigned long)page_address(page), order);
>> +	}
>> +}
>> +
>> +#if (CONFIG_PGTABLE_LEVELS > 2)
>> +static void free_pte_table(pte_t *pte_start, pmd_t *pmd)
> 
> As a general note, for arm64 please append a 'p' for pointers to
> entries, i.e. these should be ptep and pmdp.

Sure will fix across the entire patch.

> 
>> +{
>> +	pte_t *pte;
>> +	int i;
>> +
>> +	for (i = 0; i < PTRS_PER_PTE; i++) {
>> +		pte = pte_start + i;
>> +		if (!pte_none(*pte))
>> +			return;
>> +	}
> 
> You could get rid of the pte temporary, rename pte_start to ptep, and
> simplify this to:
> 
> 	for (i = 0; i < PTRS_PER_PTE; i++)
> 		if (!pte_none(ptep[i]))
> 			return;
> 
> Similar applies at the other levels.

Sure will do.

> 
> I take it that some higher-level serialization prevents concurrent
> modification to this table. Where does that happen?

mem_hotplug_begin()
mem_hotplug_end()

which operates on DEFINE_STATIC_PERCPU_RWSEM(mem_hotplug_lock)

- arch_remove_memory() called from (__remove_memory || devm_memremap_pages_release)
- vmemmap_free() called from __remove_pages called from (arch_remove_memory || devm_memremap_pages_release)

Both __remove_memory() and devm_memremap_pages_release() are protected with
pair of these.

mem_hotplug_begin()
mem_hotplug_end()

vmemmap tear down happens before linear mapping and in sequence.

> 
>> +
>> +	free_pagetable(pmd_page(*pmd), 0);
> 
> Here we free the pte level of table...
> 
>> +	spin_lock(&init_mm.page_table_lock);
>> +	pmd_clear(pmd);
> 
> ... but only here do we disconnect it from the PMD level of table, and
> we don't do any TLB maintenance just yet. The page could be poisoned
> and/or reallocated before we invalidate the TLB, which is not safe. In
> all cases, we must follow the sequence:
> 
> 1) clear the pointer to a table
> 2) invalidate any corresponding TLB entries
> 3) free the table page
> 
> ... or we risk a number of issues resulting from erroneous programming
> of the TLBs. See pmd_free_pte_page() for an example of how to do this
> correctly.

Okay will send 'addr' into these functions and do somehting like this
at all levels as in case for pmd_free_pte_page().

        page = pud_page(*pudp);
        pud_clear(pudp);
        __flush_tlb_kernel_pgtable(addr);
        free_pgtable_page(page);


> 
> I'd have thought similar applied to x86, so that implementation looks
> suspicious to me too...
> 
>> +	spin_unlock(&init_mm.page_table_lock);
> 
> What precisely is the page_table_lock intended to protect?

Concurrent modification to kernel page table (init_mm) while clearing entries.

> 
> It seems odd to me that we're happy to walk the tables without the lock,
> but only grab the lock when performing a modification. That implies we
> either have some higher-level mutual exclusion, or we're not holding the
> lock in all cases we need to be.

On arm64

- linear mapping is half kernel virtual range (unlikely to share PGD with any other)
- vmemmap and vmalloc might or might not be aligned properly to avoid PGD/PUD/PMD overlap
- This kernel virtual space layout is not fixed and can change in future

Hence just to be on safer side lets take init_mm.page_table_lock for the entire tear
down process in remove_pagetable(). put_page_bootmem/free_reserved_page/free_pages should
not block for longer period unlike allocation paths. Hence it should be safe with overall
spin lock on init_mm.page_table_lock unless if there are some other concerns.

> 
>> +}
>> +#else
>> +static void free_pte_table(pte_t *pte_start, pmd_t *pmd)
>> +{
>> +}
>> +#endif
> 
> I'm surprised that we never need to free a pte table for 2 level paging.
> Is that definitely the case?

Will fix it.

> 
>> +
>> +#if (CONFIG_PGTABLE_LEVELS > 3)
>> +static void free_pmd_table(pmd_t *pmd_start, pud_t *pud)
>> +{
>> +	pmd_t *pmd;
>> +	int i;
>> +
>> +	for (i = 0; i < PTRS_PER_PMD; i++) {
>> +		pmd = pmd_start + i;
>> +		if (!pmd_none(*pmd))
>> +			return;
>> +	}
>> +
>> +	free_pagetable(pud_page(*pud), 0);
>> +	spin_lock(&init_mm.page_table_lock);
>> +	pud_clear(pud);
>> +	spin_unlock(&init_mm.page_table_lock);
>> +}
>> +
>> +static void free_pud_table(pud_t *pud_start, pgd_t *pgd)
>> +{
>> +	pud_t *pud;
>> +	int i;
>> +
>> +	for (i = 0; i < PTRS_PER_PUD; i++) {
>> +		pud = pud_start + i;
>> +		if (!pud_none(*pud))
>> +			return;
>> +	}
>> +
>> +	free_pagetable(pgd_page(*pgd), 0);
>> +	spin_lock(&init_mm.page_table_lock);
>> +	pgd_clear(pgd);
>> +	spin_unlock(&init_mm.page_table_lock);
>> +}
>> +#else
>> +static void free_pmd_table(pmd_t *pmd_start, pud_t *pud)
>> +{
>> +}
>> +
>> +static void free_pud_table(pud_t *pud_start, pgd_t *pgd)
>> +{
>> +}
>> +#endif
> 
> It seems very odd to me that we suddenly need both of these, rather than
> requiring one before the other. Naively, I'd have expected that we'd
> need:
> 
> - free_pte_table for CONFIG_PGTABLE_LEVELS > 1 (i.e. always)
> - free_pmd_table for CONFIG_PGTABLE_LEVELS > 2
> - free_pud_table for CONFIG_PGTABLE_LEVELS > 3
> 
> ... matching the cases where the levels "really" exist. What am I
> missing that ties the pmd and pud levels together?

Might have got somehting wrong here. Will fix it.

> 
>> +static void
>> +remove_pte_table(pte_t *pte_start, unsigned long addr,
>> +			unsigned long end, bool direct)
>> +{
>> +	pte_t *pte;
>> +
>> +	pte = pte_start + pte_index(addr);
>> +	for (; addr < end; addr += PAGE_SIZE, pte++) {
>> +		if (!pte_present(*pte))
>> +			continue;
>> +
>> +		if (!direct)
>> +			free_pagetable(pte_page(*pte), 0);
> 
> This is really confusing. Here we're freeing a page of memory backing
> the vmemmap, which it _not_ a page table.

Right. The new naming scheme proposed before should do take care.

> 
> At the least, can we please rename "direct" to something like
> "free_backing", inverting its polarity?

Will use 'sparse_vmap' instead and invert the polarity.

> 
>> +		spin_lock(&init_mm.page_table_lock);
>> +		pte_clear(&init_mm, addr, pte);
>> +		spin_unlock(&init_mm.page_table_lock);
>> +	}
>> +}
> 
> Rather than explicitly using pte_index(), the usual style for arm64 is
> to pass the pmdp in and use pte_offset_kernel() to find the relevant
> ptep, e.g.
> 
> static void remove pte_table(pmd_t *pmdp, unsigned long addr,
> 			     unsigned long end, bool direct)
> {
> 	pte_t *ptep = pte_offset_kernel(pmdp, addr);
> 
> 	do {
> 		if (!pte_present(*ptep)
> 			continue;
> 
> 		...
> 
> 	} while (ptep++, addr += PAGE_SIZE, addr != end);

Will probably stick with 'next = [pgd|pud|pmd_addr]_end(addr, end)' which
is used for iteration as well as for next level function.

> }
> 
> ... with similar applying at all levels.

Sure will change and this will probably get rid of additional [pmd|pud]_index()
definitions added here.

