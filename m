Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A13FC4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:43:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FA392054F
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:43:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FA392054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAB426B027C; Tue, 11 Jun 2019 10:43:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B81986B027D; Tue, 11 Jun 2019 10:43:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4A6E6B027E; Tue, 11 Jun 2019 10:43:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 512386B027C
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:43:50 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y3so9612971edm.21
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:43:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=wM9btZqfVnHGhNijl4hK4FkzXZSucXkOKwvA2Z25zyY=;
        b=I+VJtIdOUMuxvy2ncyIhGeY/688X5u+0X0ULIr2pPOORRnyl+O+3PoahXN1y9+Tbsy
         Sqe/qN0j7geYGU2nzwl+gdJeZrF83+wdUdqhPj/XjKChzdGkhdr8omsEZSuM0ehM0kPn
         fu4aC9UUYTebfNZK6ooNY2FtMLf1/4ewch8aRMbNJnkpNVSRAaiYwK7cbZG8K/2OzGYz
         lM8cv92+u9uoIUrmrp4lOobK+XbkQsz/R9QmuFDmuV9g7mPOTVGUVosGZPUT9cFKKnEG
         Xt2S+TTM9gd5AQzY8naj8Q7L2CPlA61fzEgXSlCqG99H53hXHDfGvcX9N2lj6SvQt4IU
         WYiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVqMhd7y/qyhu/7sts0fFmXLqj+8+MQZittE4TsVVfxC09hEukL
	2iv4IiYr1Bi0c8Tm28ANzFdhV8ncAWsXtfm1yJ/IrJR3g0EDDJB6nHKo/WKwwPIxi1ij8lbzOBF
	RCGGUatjFiqGIHzyeLd+ixIQi/fkJf9ejxWpRI7WaYTyJtupLeva/9eK39NdakD8LUw==
X-Received: by 2002:a17:906:a2d2:: with SMTP id by18mr4474532ejb.245.1560264229828;
        Tue, 11 Jun 2019 07:43:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy50GBBGoFxhSHHgqgpAvFZGdEjib+KlPEXp9F7EaLi87ZB8kMFQW2MpR+2EFmceNTKdlyi
X-Received: by 2002:a17:906:a2d2:: with SMTP id by18mr4474417ejb.245.1560264228377;
        Tue, 11 Jun 2019 07:43:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560264228; cv=none;
        d=google.com; s=arc-20160816;
        b=urjXvepCXCx8Aqt3xrATu5cw715RX/eUjPtVauZyDctOIvH68qDZU/El4IYqhAkwbS
         nrWi0Xk5VMF+MZWIIyN7evG8YEMoZrAjN6YkHicn8lGz1zpupGYrPr6xQjsUswLbTcdw
         bGMLRVSvMPNOYktOCGRooqKq0NPnOz0O9KFQhd9mvVhAy0Tw86MRpS1nbLt8ELBxMKzi
         oRrgQLfk2LA7HCoMtsTQVyUdtELZB1UXb7vxlf1p8FDQ8XaZO2sPwbc4JdrGQ7wlDkzV
         op9zoOh91tsS5IA6vOAfb+3nv26p8ib82wtKJpVWLRi4jPkUfluwjQPY3k8sgvObINlF
         o7dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=wM9btZqfVnHGhNijl4hK4FkzXZSucXkOKwvA2Z25zyY=;
        b=Syv1H+Z/I3d7cpnPCrOJtY4dMpeSoPWT0ePlyw/UnE5kpK9fIUbscJmSWxPXnfFFct
         IoffE+UC9du18P8uWHIhtDN7Uakz+Jj+kqjBxIlife1bVF5e4zSfv1jUZHlZNEsvYHCk
         yExu35OgoVoA9yOJViO//dkAKw9cbvnRJtdHd9GpQSkcdv4rnt3csZ4/XBYLXetwVQnY
         30KVlYhkjRdyHF+jbZoEqo90Gdi5/Rt1zeJkTsedQrMYLwZiLyZ3xaEfPIm5g0as/Z1k
         g0boU0zxMXIhaWbmktvkrLv0xVtXD7ZX7KLvlvcpHAP41Ma7nnTv+3h5wrUZkbUnmCWr
         hyLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id f10si8728639ejq.375.2019.06.11.07.43.47
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 07:43:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E615A337;
	Tue, 11 Jun 2019 07:43:46 -0700 (PDT)
Received: from [10.162.43.135] (p8cg001049571a15.blr.arm.com [10.162.43.135])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 011D43F557;
	Tue, 11 Jun 2019 07:43:41 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH V5 3/3] arm64/mm: Enable memory hot remove
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 catalin.marinas@arm.com, will.deacon@arm.com, mhocko@suse.com,
 ira.weiny@intel.com, david@redhat.com, cai@lca.pw, logang@deltatee.com,
 james.morse@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, mgorman@techsingularity.net, osalvador@suse.de,
 ard.biesheuvel@arm.com
References: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
 <1559121387-674-4-git-send-email-anshuman.khandual@arm.com>
 <20190530151227.GD56046@lakrids.cambridge.arm.com>
Message-ID: <e339a58f-4426-1a37-3ab9-112f5d4cc643@arm.com>
Date: Tue, 11 Jun 2019 20:13:59 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190530151227.GD56046@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/30/2019 08:42 PM, Mark Rutland wrote:
> Hi Anshuman,

Hello Mark,

> 
>>From reviwing the below, I can see some major issues that need to be
> addressed, which I've commented on below.
> 
> Andrew, please do not pick up this patch.

I was reworking this patch series and investigating the vmalloc/vmemmap
conflict issues. Hence could not respond earlier.

> 
> On Wed, May 29, 2019 at 02:46:27PM +0530, Anshuman Khandual wrote:
>> The arch code for hot-remove must tear down portions of the linear map and
>> vmemmap corresponding to memory being removed. In both cases the page
>> tables mapping these regions must be freed, and when sparse vmemmap is in
>> use the memory backing the vmemmap must also be freed.
>>
>> This patch adds a new remove_pagetable() helper which can be used to tear
>> down either region, and calls it from vmemmap_free() and
>> ___remove_pgd_mapping(). The sparse_vmap argument determines whether the
>> backing memory will be freed.
>>
>> While freeing intermediate level page table pages bail out if any of it's
> 
> Nit: s/it's/its/

Done.

> 
>> entries are still valid. This can happen for partially filled kernel page
>> table either from a previously attempted failed memory hot add or while
>> removing an address range which does not span the entire page table page
>> range.
>>
>> The vmemmap region may share levels of table with the vmalloc region. Take
>> the kernel ptl so that we can safely free potentially-shared tables.
> 
> AFAICT, this is not sufficient; please see below for details.

Sure.

> 
>> While here update arch_add_memory() to handle __add_pages() failures by
>> just unmapping recently added kernel linear mapping. Now enable memory hot
>> remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.
>>
>> This implementation is overall inspired from kernel page table tear down
>> procedure on X86 architecture.
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> Acked-by: David Hildenbrand <david@redhat.com>
> 
> Looking at this some more, I don't think this is quite right, and tI
> think that structure of the free_*() and remove_*() functions makes this
> unnecessarily hard to follow. We should aim for this to be obviously
> correct.

Okay.

> 
> The x86 code is the best template to follow here. As mentioned

Did you mean *not the best* instead.

> previously, I'm fairly certain it's not entirely correct (e.g. due to
> missing TLB maintenance), and we've already diverged a fair amount in
> fixing up obvious issues, so we shouldn't aim to mirror it.

Okay.

> 
> I think that the structure of unmap_region() is closer to what we want
> here -- do one pass to unmap leaf entries (and freeing the associated
> memory if unmapping the vmemmap), then do a second pass cleaning up any
> empty tables.

Done.

> 
> In general I'm concerned that we don't strictly follow a
> clear->tlbi->free sequence, and free pages before tearing down their
> corresponding mapping. It doesn't feel great to leave a cacheable alias
> around, even transiently. Further, as commented below, the
> remove_p?d_table() functions leave stale leaf entries in the TLBs when
> removing section entries.

Fixed these.

> 
>> ---
>>  arch/arm64/Kconfig  |   3 +
>>  arch/arm64/mm/mmu.c | 211 +++++++++++++++++++++++++++++++++++++++++++++++++++-
>>  2 files changed, 212 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index 697ea05..7f917fe 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -268,6 +268,9 @@ config HAVE_GENERIC_GUP
>>  config ARCH_ENABLE_MEMORY_HOTPLUG
>>  	def_bool y
>>  
>> +config ARCH_ENABLE_MEMORY_HOTREMOVE
>> +	def_bool y
>> +
>>  config SMP
>>  	def_bool y
>>  
>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>> index a1bfc44..4803624 100644
>> --- a/arch/arm64/mm/mmu.c
>> +++ b/arch/arm64/mm/mmu.c
>> @@ -733,6 +733,187 @@ int kern_addr_valid(unsigned long addr)
>>  
>>  	return pfn_valid(pte_pfn(pte));
>>  }
>> +
>> +#ifdef CONFIG_MEMORY_HOTPLUG
>> +static void free_hotplug_page_range(struct page *page, ssize_t size)
> 
> The size argument should never be negative, so size_t would be best.

Done.

> 
>> +{
>> +	WARN_ON(PageReserved(page));
>> +	free_pages((unsigned long)page_address(page), get_order(size));
>> +}
>> +
>> +static void free_hotplug_pgtable_page(struct page *page)
>> +{
>> +	free_hotplug_page_range(page, PAGE_SIZE);
>> +}
>> +
>> +static void free_pte_table(pte_t *ptep, pmd_t *pmdp, unsigned long addr)
>> +{
>> +	struct page *page;
>> +	int i;
>> +
>> +	for (i = 0; i < PTRS_PER_PTE; i++) {
>> +		if (!pte_none(ptep[i]))
>> +			return;
>> +	}
>> +
>> +	page = pmd_page(READ_ONCE(*pmdp));
>> +	pmd_clear(pmdp);
>> +	__flush_tlb_kernel_pgtable(addr);
>> +	free_hotplug_pgtable_page(page);
>> +}
>> +
>> +static void free_pmd_table(pmd_t *pmdp, pud_t *pudp, unsigned long addr)
>> +{
>> +	struct page *page;
>> +	int i;
>> +
>> +	if (CONFIG_PGTABLE_LEVELS <= 2)
>> +		return;
>> +
>> +	for (i = 0; i < PTRS_PER_PMD; i++) {
>> +		if (!pmd_none(pmdp[i]))
>> +			return;
>> +	}
>> +
>> +	page = pud_page(READ_ONCE(*pudp));
>> +	pud_clear(pudp);
>> +	__flush_tlb_kernel_pgtable(addr);
>> +	free_hotplug_pgtable_page(page);
>> +}
>> +
>> +static void free_pud_table(pud_t *pudp, pgd_t *pgdp, unsigned long addr)
>> +{
>> +	struct page *page;
>> +	int i;
>> +
>> +	if (CONFIG_PGTABLE_LEVELS <= 3)
>> +		return;
>> +
>> +	for (i = 0; i < PTRS_PER_PUD; i++) {
>> +		if (!pud_none(pudp[i]))
>> +			return;
>> +	}
>> +
>> +	page = pgd_page(READ_ONCE(*pgdp));
>> +	pgd_clear(pgdp);
>> +	__flush_tlb_kernel_pgtable(addr);
>> +	free_hotplug_pgtable_page(page);
>> +}
>> +
>> +static void
>> +remove_pte_table(pmd_t *pmdp, unsigned long addr,
> 
> Please put this on a single line.
> 
> All the existing functions in this file (and the ones you add above)
> have the return type on the same line as the name, and since this
> portion of the prototype doesn't encroach 80 columns there's no reason
> to flow it.

Fixed.

> 
>> +			unsigned long end, bool sparse_vmap)
>> +{
>> +	struct page *page;
>> +	pte_t *ptep, pte;
>> +	unsigned long start = addr;
>> +
>> +	for (; addr < end; addr += PAGE_SIZE) {
>> +		ptep = pte_offset_kernel(pmdp, addr);
>> +		pte = READ_ONCE(*ptep);
>> +
>> +		if (pte_none(pte))
>> +			continue;
>> +
>> +		WARN_ON(!pte_present(pte));
>> +		if (sparse_vmap) {
>> +			page = pte_page(pte);
>> +			free_hotplug_page_range(page, PAGE_SIZE);
>> +		}
>> +		pte_clear(&init_mm, addr, ptep);
>> +	}
>> +	flush_tlb_kernel_range(start, end);
>> +}
> 
> For consistency we should use a do { ... } while (..., addr != end) loop
> to iterate over the page tables. All the other code in our mmu.c does
> that, and diverging from that doesn't save use anything here but does
> make review and maintenance harder.

Done.

> 
>> +
>> +static void
>> +remove_pmd_table(pud_t *pudp, unsigned long addr,
> 
> Same line please.
> 
>> +			unsigned long end, bool sparse_vmap)
>> +{
>> +	unsigned long next;
>> +	struct page *page;
>> +	pte_t *ptep_base;
>> +	pmd_t *pmdp, pmd;
>> +
>> +	for (; addr < end; addr = next) {
>> +		next = pmd_addr_end(addr, end);
>> +		pmdp = pmd_offset(pudp, addr);
>> +		pmd = READ_ONCE(*pmdp);
>> +
>> +		if (pmd_none(pmd))
>> +			continue;
>> +
>> +		WARN_ON(!pmd_present(pmd));
>> +		if (pmd_sect(pmd)) {
>> +			if (sparse_vmap) {
>> +				page = pmd_page(pmd);
>> +				free_hotplug_page_range(page, PMD_SIZE);
>> +			}
>> +			pmd_clear(pmdp);
> 
> As mentioned above, this has no corresponding TLB maintenance, and I'm
> concerned that we free the page before clearing the entry. If the page
> gets re-allocated elsewhere, whoever received the page may not be
> expecting a cacheable alias to exist other than the linear map.

Fixed.

> 
>> +			continue;
>> +		}
>> +		ptep_base = pte_offset_kernel(pmdp, 0UL);
>> +		remove_pte_table(pmdp, addr, next, sparse_vmap);
>> +		free_pte_table(ptep_base, pmdp, addr);
>> +	}
>> +}
>> +
>> +static void
>> +remove_pud_table(pgd_t *pgdp, unsigned long addr,
> 
> Same line please

Fixed.

> 
>> +			unsigned long end, bool sparse_vmap)
>> +{
>> +	unsigned long next;
>> +	struct page *page;
>> +	pmd_t *pmdp_base;
>> +	pud_t *pudp, pud;
>> +
>> +	for (; addr < end; addr = next) {
>> +		next = pud_addr_end(addr, end);
>> +		pudp = pud_offset(pgdp, addr);
>> +		pud = READ_ONCE(*pudp);
>> +
>> +		if (pud_none(pud))
>> +			continue;
>> +
>> +		WARN_ON(!pud_present(pud));
>> +		if (pud_sect(pud)) {
>> +			if (sparse_vmap) {
>> +				page = pud_page(pud);
>> +				free_hotplug_page_range(page, PUD_SIZE);
>> +			}
>> +			pud_clear(pudp);
> 
> Same issue as in remove_pmd_table().

Fixed.


> 
>> +			continue;
>> +		}
>> +		pmdp_base = pmd_offset(pudp, 0UL);
>> +		remove_pmd_table(pudp, addr, next, sparse_vmap);
>> +		free_pmd_table(pmdp_base, pudp, addr);
>> +	}
>> +}
>> +
>> +static void
>> +remove_pagetable(unsigned long start, unsigned long end, bool sparse_vmap)
> 
> Same line please (with the sparse_vmap argument flowed on to the next
> line as that will encroach 80 characters).

Done.

> 
>> +{
>> +	unsigned long addr, next;
>> +	pud_t *pudp_base;
>> +	pgd_t *pgdp, pgd;
>> +
>> +	spin_lock(&init_mm.page_table_lock);
> 
> Please add a comment above this to explain why we need to take the
> init_mm ptl. Per the cover letter, this should be something like:
> 
> 	/*
> 	 * We may share tables with the vmalloc region, so we must take
> 	 * the init_mm ptl so that we can safely free any
> 	 * potentially-shared tables that we have emptied.
> 	 */

This might not be required any more (see below comments)

> 
> The vmalloc code doesn't hold the init_mm ptl when walking a table; it

Right.

> only takes the init_mm ptl when populating a none entry in
> __p??_alloc(), to avoid a race where two threads need to populate the
> entry.

Right.

> 
> So AFAICT, taking the init_mm ptl here is not sufficient to make this
> safe.

I understand that there can be potential conflicts here if vmalloc and
vmemap mappings share kernel intermediate level page table pages.

For example.

- vmalloc takes an intermediate page table page pointer during walk
  (without init_mm lock) and proceeds further to create leaf level
  entries

- memory hot-remove walks the page table, (clear-->--invalidate-->free)
  leaf level entries and then removes (clear-->--invalidate-->free) an
  intermediate level page table pages (already emptied) while holding
  init_mm lock

- vmalloc now holds an invalid page table entry pointer derived from a
  freed page (potentially being used else where) and proceeds to create
  an entry on it !

The primary cause which creates this problematic situation is

- vmalloc does not take init_mm.page_table_lock for it's entire duration.
  Kernel page table walk, page table page insert, creation of leaf level
  entries etc. This should have prevented memory hot-remove from deleting
  intermediate page table pages while vmalloc was at it.

So how to solve this problem ?

Broadly there are three options (unless I have missed some more)

Option 1:

Take init_mm ptl for the entire duration of vmalloc() but it will then
have significant impact on it's performance. vmalloc() works on mutually
exclusive ranges which can proceed concurrently for their allocation
except the page table pages which are currently protected. Multiple
threads doing vmalloc() dont need init_mm ptl for it's entire duration.
Hence doing so can affect performance.

Option 2:

Take mem_hotplug_lock in read mode through [get|put]_online_mems() for
the entire duration of vmalloc(). It protects vmalloc() from concurrent
memory hot remove operation but does not add significant overhead to
other concurrent vmalloc() threads.

Option 3:

Dont not free page table pages for vmemmap mappings after unmapping the
hotplug range. The only downside is that some page table pages might
remain empty and unused till the next hot add operation for the same
memory range, which should be fine.

IMHO

- Option 1 does not seem to be viable for it's performance impact
- Option 2 seems to solve the problem in the right way unless we dont
           want to further the usage of mem_hotplug_lock in core MM

- Option 3 seems like an easy and quick solution on the platform side
           which avoids the problem for now

Please let me know your thoughts.

- Anshuman

