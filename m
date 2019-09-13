Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 775E7C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 05:58:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0872E20CC7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 05:58:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0872E20CC7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D12D6B0005; Fri, 13 Sep 2019 01:58:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6595C6B0006; Fri, 13 Sep 2019 01:58:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 548376B0007; Fri, 13 Sep 2019 01:58:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0157.hostedemail.com [216.40.44.157])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA6A6B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 01:58:01 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C5117181AC9AE
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 05:58:00 +0000 (UTC)
X-FDA: 75928841520.29.rate62_28b32342e110c
X-HE-Tag: rate62_28b32342e110c
X-Filterd-Recvd-Size: 10141
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 05:57:59 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 48CCF337;
	Thu, 12 Sep 2019 22:57:58 -0700 (PDT)
Received: from [10.162.41.125] (p8cg001049571a15.blr.arm.com [10.162.41.125])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C08F33F67D;
	Thu, 12 Sep 2019 23:00:20 -0700 (PDT)
Subject: Re: [PATCH V7 3/3] arm64/mm: Enable memory hot remove
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 will@kernel.org, mark.rutland@arm.com, mhocko@suse.com, ira.weiny@intel.com,
 david@redhat.com, cai@lca.pw, logang@deltatee.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com,
 mgorman@techsingularity.net, osalvador@suse.de, ard.biesheuvel@arm.com,
 steve.capper@arm.com, broonie@kernel.org, valentin.schneider@arm.com,
 Robin.Murphy@arm.com, steven.price@arm.com, suzuki.poulose@arm.com
References: <1567503958-25831-1-git-send-email-anshuman.khandual@arm.com>
 <1567503958-25831-4-git-send-email-anshuman.khandual@arm.com>
 <20190912201517.GB1068@C02TF0J2HF1T.local>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <ce127798-3863-0f28-de04-84b177418310@arm.com>
Date: Fri, 13 Sep 2019 11:28:01 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190912201517.GB1068@C02TF0J2HF1T.local>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/13/2019 01:45 AM, Catalin Marinas wrote:
> Hi Anshuman,
> 
> Thanks for the details on the need for removing the page tables and
> vmemmap backing. Some comments on the code below.
> 
> On Tue, Sep 03, 2019 at 03:15:58PM +0530, Anshuman Khandual wrote:
>> --- a/arch/arm64/mm/mmu.c
>> +++ b/arch/arm64/mm/mmu.c
>> @@ -60,6 +60,14 @@ static pud_t bm_pud[PTRS_PER_PUD] __page_aligned_bss __maybe_unused;
>>  
>>  static DEFINE_SPINLOCK(swapper_pgdir_lock);
>>  
>> +/*
>> + * This represents if vmalloc and vmemmap address range overlap with
>> + * each other on an intermediate level kernel page table entry which
>> + * in turn helps in deciding whether empty kernel page table pages
>> + * if any can be freed during memory hotplug operation.
>> + */
>> +static bool vmalloc_vmemmap_overlap;
> 
> I'd say just move the static find_vmalloc_vmemmap_overlap() function
> here, the compiler should be sufficiently smart enough to figure out
> that it's just a build-time constant.

Sure, will do.

> 
>> @@ -770,6 +1022,28 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>>  void vmemmap_free(unsigned long start, unsigned long end,
>>  		struct vmem_altmap *altmap)
>>  {
>> +#ifdef CONFIG_MEMORY_HOTPLUG
>> +	/*
>> +	 * FIXME: We should have called remove_pagetable(start, end, true).
>> +	 * vmemmap and vmalloc virtual range might share intermediate kernel
>> +	 * page table entries. Removing vmemmap range page table pages here
>> +	 * can potentially conflict with a concurrent vmalloc() allocation.
>> +	 *
>> +	 * This is primarily because vmalloc() does not take init_mm ptl for
>> +	 * the entire page table walk and it's modification. Instead it just
>> +	 * takes the lock while allocating and installing page table pages
>> +	 * via [p4d|pud|pmd|pte]_alloc(). A concurrently vanishing page table
>> +	 * entry via memory hot remove can cause vmalloc() kernel page table
>> +	 * walk pointers to be invalid on the fly which can cause corruption
>> +	 * or worst, a crash.
>> +	 *
>> +	 * So free_empty_tables() gets called where vmalloc and vmemmap range
>> +	 * do not overlap at any intermediate level kernel page table entry.
>> +	 */
>> +	unmap_hotplug_range(start, end, true);
>> +	if (!vmalloc_vmemmap_overlap)
>> +		free_empty_tables(start, end);
>> +#endif
>>  }
> 
> So, I see the risk with overlapping and I guess for some kernel
> configurations (PAGE_SIZE == 64K) we may not be able to avoid it. If we

Did not see 64K config options to have overlap, do you suspect they might ?
After the 52 bit KVA series has been merged, following configurations have
the vmalloc-vmemmap range overlap problem.

- 4K  page size with 48 bit VA space
- 16K page size with 48 bit VA space

> can, that's great, otherwise could we rewrite the above functions to
> handle floor and ceiling similar to free_pgd_range()? (I wonder how this
> function works if you called it on init_mm and kernel address range). By

Hmm, never tried that. Are you wondering if this can be used directly ?
There are two distinct elements which make it very specific to user page
tables, mmu_gather based TLB tracking and mm->pgtable_bytes accounting
with mm_dec_nr_pxx().

> having the vmemmap start/end information it avoids freeing partially
> filled page table pages.

Did you mean page table pages which can partially overlap with vmalloc ?

The problem (race) is not because of the inability to deal with partially
filled table. We can handle that correctly as explained below [1]. The
problem is with inadequate kernel page table locking during vmalloc()
which might be accessing intermediate kernel page table pointers which is
being freed with free_empty_tables() concurrently. Hence we cannot free
any page table page which can ever have entries from vmalloc() range.

Though not completely sure, whether I really understood the suggestion above
with respect to the floor-ceiling mechanism as in free_pgd_range(). Are you
suggesting that we should only attempt to free up those vmemmap range page
table pages which *definitely* could never overlap with vmalloc by working
on a modified (i.e cut down with floor-ceiling while avoiding vmalloc range
at each level) vmemmap range instead ? This can be one restrictive version of
the function free_empty_tables() called in case there is an overlap. So we
will maintain two versions for free_empty_tables(). Please correct me if any
the above assumptions or understanding is wrong.

But yes, with this we should be able to free up some possible empty page
table pages which were being left out in the current proposal when overlap
happens.

[1] Skipping partially filled page tables

All free_pXX_table() functions take care in avoiding freeing partially filled
page table pages whether they represent or ever represented linear or vmemmap
or vmalloc mapping in init_mm. They go over each individual entry in a given
page table making sure that each of them checks as pXX_none() before freeing
the entire page table page.

Though walking is restricted by the address range in question.

free_empty_tables(start, end)
	free_empty_pud_table(pgdp, addr, next);
		free_empty_pmd_table(pudp, addr, next);
			free_empty_pte_table(pmdp, addr, next);

Page table pages being examined here on the way while freeing might contain
entries which once represented address beyond vmemmap range in removal. But
thats a good thing IMHO. It can accommodate vmemmap tear down from a previous
hot remove for an adjacent range which might not have been freed last time.

pudp = pud_offset(pgdp, 0UL);
pmdp = pmd_offset(pudp, 0UL);
ptep = pte_offset_kernel(pmdp, 0UL);

pxx_none() makes sure that in such cases freeing of the page table page is
skipped. But yes, even though it is more thorough, it might attempt to free
page table pages which might contains entries not belonging to the range
being removed.

> 
> Another question: could we do the page table and the actual vmemmap
> pages freeing in a single pass (sorry if this has been discussed
> before)?

We could and some initial versions (till V5) of the series had that in fact.
Initially Mark Rutland had suggested to do this in two passes. Some extracts
from the previous discussion.

https://lkml.org/lkml/2019/5/30/1159

-----------------------
Looking at this some more, I don't think this is quite right, and tI
think that structure of the free_*() and remove_*() functions makes this
unnecessarily hard to follow. We should aim for this to be obviously
correct.

The x86 code is the best template to follow here. As mentioned
previously, I'm fairly certain it's not entirely correct (e.g. due to
missing TLB maintenance), and we've already diverged a fair amount in
fixing up obvious issues, so we shouldn't aim to mirror it.

I think that the structure of unmap_region() is closer to what we want
here -- do one pass to unmap leaf entries (and freeing the associated
memory if unmapping the vmemmap), then do a second pass cleaning up any
empty tables.
----------------------

Apart from the fact that two passes over the page table is cleaner and gives
us more granular and modular infrastructure to use for later purposes, it is
also a necessity in dealing with vmalloc-vmemmap overlap. free_empty_tables()
which is the second pass, can be skipped cleanly when overlap is detected.

> 
>> @@ -1048,10 +1322,18 @@ int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
>>  }
>>  
>>  #ifdef CONFIG_MEMORY_HOTPLUG
>> +static void __remove_pgd_mapping(pgd_t *pgdir, unsigned long start, u64 size)
>> +{
>> +	unsigned long end = start + size;
>> +
>> +	WARN_ON(pgdir != init_mm.pgd);
>> +	remove_pagetable(start, end, false);
>> +}
> 
> I think the point I've made previously still stands: you only call
> remove_pagetable() with sparse_vmap == false in this patch. Just remove
> the extra argument and call unmap_hotplug_range() with sparse_vmap ==
> false directly in remove_pagetable().

Sure, will do. The original function signature was left unchanged in the hope
that at a later point in time it can be called with "sparse_vmap == true" as
mentioned by the comment in vmemmap_free(). Will change the comment as well.

