Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BAF1C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:49:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAB4B215EA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:49:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAB4B215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B1346B0003; Tue, 25 Jun 2019 04:49:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33AC38E0003; Tue, 25 Jun 2019 04:49:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 167158E0002; Tue, 25 Jun 2019 04:49:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD9136B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 04:49:28 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id s22so7997382qtb.22
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 01:49:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=xm162ePhaxuQ5pGdl091/gE1/eYNl//uRsV36kGIOXY=;
        b=PZS5bRnDYM0lTYwTkVfxIvN/uR7Eu6m2jNDwdHotYYs6pFgrtsK/7EiaY5v7X+QM9R
         gP0UrA3PUbWYaJrqK4ZuhUuFgrzMWX/GjDbaan6FWrB+SB8YQjjovbKm0PTA108jZJoF
         wx16y2zM7vLfr9WuadMCjzr1Ygy1RZ0cCAgp3LPpH35lwRK3i7SN+aKXUBKGM+H+ZieN
         MBe/BX0pYem+fpv1UVV1MdaYITeUUoVI4lG696iQq+ny0zVH9W//owiDvsUzXRXADTcc
         CZigDwtUS6swwBnHw4iIQjWUIkp7c123d7ioDytdP3E52IVNpEBkzh5s5yzDuzdE0Z8F
         qiAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXTvOzSOalJ9pnOXNtqSNH/SMEnCe0HyvV6+9EPbLxu3tgqPSSE
	zzhSlou4TSSM1qqCy1avxrX12j0KV8c6cH1MMmvlscKX6ZPLIH6K5m7i+nNsB9p6zNxbYnZkgqq
	fuX3zdh7pAs5OSZv5wcn1+bBQcPs4BTA3fbssri9HNQP9LNjiIp06UZClmdbCBmf3GQ==
X-Received: by 2002:a0c:ae35:: with SMTP id y50mr24376102qvc.204.1561452568617;
        Tue, 25 Jun 2019 01:49:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWG960FKzYvOkd3MPl0flVeV228RKsYsaTy1Xtx5AFbYdvvsl43B/tvSeqiXhy4eT4Q2Op
X-Received: by 2002:a0c:ae35:: with SMTP id y50mr24376031qvc.204.1561452567137;
        Tue, 25 Jun 2019 01:49:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561452567; cv=none;
        d=google.com; s=arc-20160816;
        b=vhMvSkNok1xBcEVFFw5s7mmwabqh5VRj1TcEkLbFH3Y0H7yNPo/MrYlliwcd6e5wS8
         6sakTbXGZHY9kzv53qqxEJrUepd6OWrJ6puyxEs4G8CnurDwmYbhwS4YuUKGx9aTD0RA
         EIeJLmDU6gmM0XJ+829/WobLm81VgntBGcqfIQpkjqQimtjfC6NqvvkLeE+ot3eJKAFU
         2na09Fv/GqjgGrd6t7hK5koL3hzi/srmyVDjTJJpqE3L0HsXAuQziqrFlR391MBADr0p
         bzkF61kIBaj+/9yzC74UDL5ZtTM90juXo6q7KjNm/FPMz58SQGfrrydfBJx3bv/dBU13
         oLhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=xm162ePhaxuQ5pGdl091/gE1/eYNl//uRsV36kGIOXY=;
        b=oHkVFIeGFPrKaiQdQKyjC9YK9opXbt7xClsA010oaffiUeSBour4a8H1AwZovxhiin
         vmLOdgYW79ux1hTZxrsOAyH7p/JY/xhNqW8H89TDYKcEmKAXp0CXxwyAB+sf4JXZ41TZ
         h0jgCMOfavlctkk95YLXaO/pSQuIFA2HDuC2V0ZwiFRHrZivVw8TdRZOahsrYJp/iP6i
         PrI4UYoD9uoeYhddAd16pCYrq06P+XngOPv+ourzmRWElOZ2Czr3qvbvToTPVlSRmd1t
         P3MK+xvWGIAe9KsLp0ioLxhGqpF4JTRg19GHD9sR6HBZu1edmENgAbzAWZMbls/2IXKa
         VKgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y47si9462570qve.70.2019.06.25.01.49.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 01:49:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0244530833B2;
	Tue, 25 Jun 2019 08:49:20 +0000 (UTC)
Received: from [10.36.117.83] (ovpn-117-83.ams2.redhat.com [10.36.117.83])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7598A5C234;
	Tue, 25 Jun 2019 08:49:16 +0000 (UTC)
Subject: Re: [PATCH v2 4/5] mm,memory_hotplug: allocate memmap from the added
 memory range for sparse-vmemmap
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@soleen.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com, vbabka@suse.cz,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-5-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <80f8afcf-0934-33e5-5dc4-a0d19ec2b910@redhat.com>
Date: Tue, 25 Jun 2019 10:49:10 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190625075227.15193-5-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Tue, 25 Jun 2019 08:49:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.06.19 09:52, Oscar Salvador wrote:
> Physical memory hotadd has to allocate a memmap (struct page array) for
> the newly added memory section. Currently, alloc_pages_node() is used
> for those allocations.
> 
> This has some disadvantages:
>  a) an existing memory is consumed for that purpose
>     (~2MB per 128MB memory section on x86_64)
>  b) if the whole node is movable then we have off-node struct pages
>     which has performance drawbacks.
> 
> a) has turned out to be a problem for memory hotplug based ballooning
>    because the userspace might not react in time to online memory while
>    the memory consumed during physical hotadd consumes enough memory to
>    push system to OOM. 31bc3858ea3e ("memory-hotplug: add automatic onlining
>    policy for the newly added memory") has been added to workaround that
>    problem.
> 
> I have also seen hot-add operations failing on powerpc due to the fact
> that we try to use order-8 pages. If the base page size is 64KB, this
> gives us 16MB, and if we run out of those, we simply fail.
> One could arge that we can fall back to basepages as we do in x86_64, but
> we can do better when CONFIG_SPARSEMEM_VMEMMAP is enabled.
> 
> Vmemap page tables can map arbitrary memory.
> That means that we can simply use the beginning of each memory section and
> map struct pages there.
> struct pages which back the allocated space then just need to be treated
> carefully.
> 
> Implementation wise we reuse vmem_altmap infrastructure to override
> the default allocator used by __vmemap_populate. Once the memmap is
> allocated we need a way to mark altmap pfns used for the allocation.
> If MHP_MEMMAP_{DEVICE,MEMBLOCK} flag was passed, we set up the layout of the
> altmap structure at the beginning of __add_pages(), and then we call
> mark_vmemmap_pages().
> 
> Depending on which flag is passed (MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK),
> mark_vmemmap_pages() gets called at a different stage.
> With MHP_MEMMAP_MEMBLOCK, we call it once we have populated the sections
> fitting in a single memblock, while with MHP_MEMMAP_DEVICE we wait until all
> sections have been populated.

So, only MHP_MEMMAP_DEVICE will be used. Would it make sense to only
implement one for now (after we decide which one to use), to make things
simpler?

Or do you have a real user in mind for the other?

> 
> mark_vmemmap_pages() marks the pages as vmemmap and sets some metadata:
> 
> The current layout of the Vmemmap pages are:
> 
> 	[Head->refcount] : Nr sections used by this altmap
> 	[Head->private]  : Nr of vmemmap pages
> 	[Tail->freelist] : Pointer to the head page
> 
> This is done to easy the computation we need in some places.
> E.g:
> 
> Example 1)
> We hot-add 1GB on x86_64 (memory block 128MB) using
> MHP_MEMMAP_DEVICE:
> 
> head->_refcount = 8 sections
> head->private = 4096 vmemmap pages
> tail's->freelist = head
> 
> Example 2)
> We hot-add 1GB on x86_64 using MHP_MEMMAP_MEMBLOCK:
> 
> [at the beginning of each memblock]
> head->_refcount = 1 section
> head->private = 512 vmemmap pages
> tail's->freelist = head
> 
> We have the refcount because when using MHP_MEMMAP_DEVICE, we need to know
> how much do we have to defer the call to vmemmap_free().
> The thing is that the first pages of the hot-added range are used to create
> the memmap mapping, so we cannot remove those first, otherwise we would blow up
> when accessing the other pages.
> 
> What we do is that since when we hot-remove a memory-range, sections are being
> removed sequentially, we wait until we hit the last section, and then we free
> the hole range to vmemmap_free backwards.
> We know that it is the last section because in every pass we
> decrease head->_refcount, and when it reaches 0, we got our last section.
> 
> We also have to be careful about those pages during online and offline
> operations. They are simply skipped, so online will keep them
> reserved and so unusable for any other purpose and offline ignores them
> so they do not block the offline operation.
> 
> In offline operation we only have to check for one particularity.
> Depending on how large was the hot-added range, and using MHP_MEMMAP_DEVICE,
> can be that one or more than one memory block is filled with only vmemmap pages.
> We just need to check for this case and skip 1) isolating 2) migrating,
> because those pages do not need to be migrated anywhere, they are self-hosted.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  arch/arm64/mm/mmu.c            |   5 +-
>  arch/powerpc/mm/init_64.c      |   7 +++
>  arch/s390/mm/init.c            |   6 ++
>  arch/x86/mm/init_64.c          |  10 +++
>  drivers/acpi/acpi_memhotplug.c |   2 +-
>  drivers/base/memory.c          |   2 +-
>  include/linux/memory_hotplug.h |   6 ++
>  include/linux/memremap.h       |   2 +-
>  mm/compaction.c                |   7 +++
>  mm/memory_hotplug.c            | 138 +++++++++++++++++++++++++++++++++++------
>  mm/page_alloc.c                |  22 ++++++-
>  mm/page_isolation.c            |  14 ++++-
>  mm/sparse.c                    |  93 +++++++++++++++++++++++++++
>  13 files changed, 289 insertions(+), 25 deletions(-)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index 93ed0df4df79..d4b5661fa6b6 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -765,7 +765,10 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
>  		if (pmd_none(READ_ONCE(*pmdp))) {
>  			void *p = NULL;
>  
> -			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
> +			if (altmap)
> +				p = altmap_alloc_block_buf(PMD_SIZE, altmap);
> +			else
> +				p = vmemmap_alloc_block_buf(PMD_SIZE, node);
>  			if (!p)
>  				return -ENOMEM;
>  
> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> index a4e17a979e45..ff9d2c245321 100644
> --- a/arch/powerpc/mm/init_64.c
> +++ b/arch/powerpc/mm/init_64.c
> @@ -289,6 +289,13 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
>  
>  		if (base_pfn >= alt_start && base_pfn < alt_end) {
>  			vmem_altmap_free(altmap, nr_pages);
> +		} else if (PageVmemmap(page)) {
> +			/*
> +			 * runtime vmemmap pages are residing inside the memory
> +			 * section so they do not have to be freed anywhere.
> +			 */
> +			while (PageVmemmap(page))
> +				__ClearPageVmemmap(page++);
>  		} else if (PageReserved(page)) {
>  			/* allocated from bootmem */
>  			if (page_size < PAGE_SIZE) {
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index ffb81fe95c77..c045411552a3 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -226,6 +226,12 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  	unsigned long size_pages = PFN_DOWN(size);
>  	int rc;
>  
> +	/*
> +	 * Physical memory is added only later during the memory online so we
> +	 * cannot use the added range at this stage unfortunately.
> +	 */
> +	restrictions->flags &= ~restrictions->flags;
> +
>  	if (WARN_ON_ONCE(restrictions->altmap))
>  		return -EINVAL;
>  
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 688fb0687e55..00d17b666337 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -874,6 +874,16 @@ static void __meminit free_pagetable(struct page *page, int order)
>  	unsigned long magic;
>  	unsigned int nr_pages = 1 << order;
>  
> +	/*
> +	 * Runtime vmemmap pages are residing inside the memory section so
> +	 * they do not have to be freed anywhere.
> +	 */
> +	if (PageVmemmap(page)) {
> +		while (nr_pages--)
> +			__ClearPageVmemmap(page++);
> +		return;
> +	}
> +
>  	/* bootmem page has reserved flag */
>  	if (PageReserved(page)) {
>  		__ClearPageReserved(page);
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index 860f84e82dd0..3257edb98d90 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -218,7 +218,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>  		if (node < 0)
>  			node = memory_add_physaddr_to_nid(info->start_addr);
>  
> -		result = __add_memory(node, info->start_addr, info->length, 0);
> +		result = __add_memory(node, info->start_addr, info->length, MHP_MEMMAP_DEVICE);
>  
>  		/*
>  		 * If the memory block has been used by the kernel, add_memory()
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index ad9834b8b7f7..e0ac9a3b66f8 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -32,7 +32,7 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
>  
>  #define to_memory_block(dev) container_of(dev, struct memory_block, dev)
>  
> -static int sections_per_block;
> +int sections_per_block;
>  
>  static inline int base_memory_block_id(int section_nr)
>  {
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 6fdbce9d04f9..e28e226c9a20 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -375,4 +375,10 @@ extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_
>  		int online_type);
>  extern struct zone *zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
>  		unsigned long nr_pages);
> +
> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> +extern void mark_vmemmap_pages(struct vmem_altmap *self);
> +#else
> +static inline void mark_vmemmap_pages(struct vmem_altmap *self) {}
> +#endif
>  #endif /* __LINUX_MEMORY_HOTPLUG_H */
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 1732dea030b2..6de37e168f57 100644
> --- a/include/linux/memremap.h
> +++ b/include/linux/memremap.h
> @@ -16,7 +16,7 @@ struct device;
>   * @alloc: track pages consumed, private to vmemmap_populate()
>   */
>  struct vmem_altmap {
> -	const unsigned long base_pfn;
> +	unsigned long base_pfn;
>  	const unsigned long reserve;
>  	unsigned long free;
>  	unsigned long align;
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 9e1b9acb116b..40697f74b8b4 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -855,6 +855,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  		nr_scanned++;
>  
>  		page = pfn_to_page(low_pfn);
> +		/*
> +		 * Vmemmap pages do not need to be isolated.
> +		 */
> +		if (PageVmemmap(page)) {
> +			low_pfn += get_nr_vmemmap_pages(page) - 1;
> +			continue;
> +		}
>  
>  		/*
>  		 * Check if the pageblock has already been marked skipped.
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index e4e3baa6eaa7..b5106cb75795 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -42,6 +42,8 @@
>  #include "internal.h"
>  #include "shuffle.h"
>  
> +extern int sections_per_block;
> +
>  /*
>   * online_page_callback contains pointer to current page onlining function.
>   * Initially it is generic_online_page(). If it is required it could be
> @@ -279,6 +281,24 @@ static int check_pfn_span(unsigned long pfn, unsigned long nr_pages,
>  	return 0;
>  }
>  
> +static void mhp_reset_altmap(unsigned long next_pfn,
> +			     struct vmem_altmap *altmap)
> +{
> +	altmap->base_pfn = next_pfn;
> +	altmap->alloc = 0;
> +}
> +
> +static void mhp_init_altmap(unsigned long pfn, unsigned long nr_pages,
> +			    unsigned long mhp_flags,
> +			    struct vmem_altmap *altmap)
> +{
> +	if (mhp_flags & MHP_MEMMAP_DEVICE)
> +		altmap->free = nr_pages;
> +	else
> +		altmap->free = PAGES_PER_SECTION * sections_per_block;
> +	altmap->base_pfn = pfn;
> +}
> +
>  /*
>   * Reasonably generic function for adding memory.  It is
>   * expected that archs that support memory hotplug will
> @@ -290,8 +310,17 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
>  {
>  	unsigned long i;
>  	int start_sec, end_sec, err;
> -	struct vmem_altmap *altmap = restrictions->altmap;
> +	struct vmem_altmap *altmap;
> +	struct vmem_altmap __memblk_altmap = {};
> +	unsigned long mhp_flags = restrictions->flags;
> +	unsigned long sections_added;
> +
> +	if (mhp_flags & MHP_VMEMMAP_FLAGS) {
> +		mhp_init_altmap(pfn, nr_pages, mhp_flags, &__memblk_altmap);
> +		restrictions->altmap = &__memblk_altmap;
> +	}
>  
> +	altmap = restrictions->altmap;
>  	if (altmap) {
>  		/*
>  		 * Validate altmap is within bounds of the total request
> @@ -308,9 +337,10 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
>  	if (err)
>  		return err;
>  
> +	sections_added = 1;
>  	start_sec = pfn_to_section_nr(pfn);
>  	end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
> -	for (i = start_sec; i <= end_sec; i++) {
> +	for (i = start_sec; i <= end_sec; i++, sections_added++) {
>  		unsigned long pfns;
>  
>  		pfns = min(nr_pages, PAGES_PER_SECTION
> @@ -320,9 +350,19 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
>  			break;
>  		pfn += pfns;
>  		nr_pages -= pfns;
> +
> +		if (mhp_flags & MHP_MEMMAP_MEMBLOCK &&
> +		    !(sections_added % sections_per_block)) {
> +			mark_vmemmap_pages(altmap);
> +			mhp_reset_altmap(pfn, altmap);
> +		}
>  		cond_resched();
>  	}
>  	vmemmap_populate_print_last();
> +
> +	if (mhp_flags & MHP_MEMMAP_DEVICE)
> +		mark_vmemmap_pages(altmap);
> +
>  	return err;
>  }
>  
> @@ -642,6 +682,14 @@ static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
>  	while (start < end) {
>  		order = min(MAX_ORDER - 1,
>  			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
> +		/*
> +		 * Check if the pfn is aligned to its order.
> +		 * If not, we decrement the order until it is,
> +		 * otherwise __free_one_page will bug us.
> +		 */
> +		while (start & ((1 << order) - 1))
> +			order--;
> +
>  		(*online_page_callback)(pfn_to_page(start), order);
>  
>  		onlined_pages += (1UL << order);
> @@ -654,13 +702,30 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>  			void *arg)
>  {
>  	unsigned long onlined_pages = *(unsigned long *)arg;
> +	unsigned long pfn = start_pfn;
> +	unsigned long nr_vmemmap_pages = 0;
>  
> -	if (PageReserved(pfn_to_page(start_pfn)))
> -		onlined_pages += online_pages_blocks(start_pfn, nr_pages);
> +	if (PageVmemmap(pfn_to_page(pfn))) {
> +		/*
> +		 * Do not send vmemmap pages to the page allocator.
> +		 */
> +		nr_vmemmap_pages = get_nr_vmemmap_pages(pfn_to_page(start_pfn));
> +		nr_vmemmap_pages = min(nr_vmemmap_pages, nr_pages);
> +		pfn += nr_vmemmap_pages;
> +		if (nr_vmemmap_pages == nr_pages)
> +			/*
> +			 * If the entire range contains only vmemmap pages,
> +			 * there are no pages left for the page allocator.
> +			 */
> +			goto skip_online;
> +	}
>  
> +	if (PageReserved(pfn_to_page(pfn)))
> +		onlined_pages += online_pages_blocks(pfn, nr_pages - nr_vmemmap_pages);
> +skip_online:
>  	online_mem_sections(start_pfn, start_pfn + nr_pages);
>  
> -	*(unsigned long *)arg = onlined_pages;
> +	*(unsigned long *)arg = onlined_pages + nr_vmemmap_pages;
>  	return 0;
>  }
>  
> @@ -1051,6 +1116,23 @@ static int online_memory_block(struct memory_block *mem, void *arg)
>  	return device_online(&mem->dev);
>  }
>  
> +static bool mhp_check_correct_flags(unsigned long flags)
> +{
> +	if (flags & MHP_VMEMMAP_FLAGS) {
> +		if (!IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP)) {
> +			WARN(1, "Vmemmap capability can only be used on"
> +				"CONFIG_SPARSEMEM_VMEMMAP. Ignoring flags.\n");
> +			return false;
> +		}
> +		if ((flags & MHP_VMEMMAP_FLAGS) == MHP_VMEMMAP_FLAGS) {
> +			WARN(1, "Both MHP_MEMMAP_DEVICE and MHP_MEMMAP_MEMBLOCK"
> +				"were passed. Ignoring flags.\n");
> +			return false;
> +		}
> +	}
> +	return true;
> +}
> +
>  /*
>   * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
>   * and online/offline operations (triggered e.g. by sysfs).
> @@ -1086,6 +1168,9 @@ int __ref add_memory_resource(int nid, struct resource *res, unsigned long flags
>  		goto error;
>  	new_node = ret;
>  
> +	if (mhp_check_correct_flags(flags))
> +		restrictions.flags = flags;
> +
>  	/* call arch's memory hotadd */
>  	ret = arch_add_memory(nid, start, size, &restrictions);
>  	if (ret < 0)
> @@ -1518,12 +1603,14 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  {
>  	unsigned long pfn, nr_pages;
>  	unsigned long offlined_pages = 0;
> +	unsigned long nr_vmemmap_pages = 0;
>  	int ret, node, nr_isolate_pageblock;
>  	unsigned long flags;
>  	unsigned long valid_start, valid_end;
>  	struct zone *zone;
>  	struct memory_notify arg;
>  	char *reason;
> +	bool skip = false;
>  
>  	mem_hotplug_begin();
>  
> @@ -1540,15 +1627,24 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	node = zone_to_nid(zone);
>  	nr_pages = end_pfn - start_pfn;
>  
> -	/* set above range as isolated */
> -	ret = start_isolate_page_range(start_pfn, end_pfn,
> -				       MIGRATE_MOVABLE,
> -				       SKIP_HWPOISON | REPORT_FAILURE);
> -	if (ret < 0) {
> -		reason = "failure to isolate range";
> -		goto failed_removal;
> +	if (PageVmemmap(pfn_to_page(start_pfn))) {
> +		nr_vmemmap_pages = get_nr_vmemmap_pages(pfn_to_page(start_pfn));
> +		nr_vmemmap_pages = min(nr_vmemmap_pages, nr_pages);
> +		if (nr_vmemmap_pages == nr_pages)
> +			skip = true;
> +	}
> +
> +	if (!skip) {
> +		/* set above range as isolated */
> +		ret = start_isolate_page_range(start_pfn, end_pfn,
> +					       MIGRATE_MOVABLE,
> +					       SKIP_HWPOISON | REPORT_FAILURE);
> +		if (ret < 0) {
> +			reason = "failure to isolate range";
> +			goto failed_removal;
> +		}
> +		nr_isolate_pageblock = ret;
>  	}
> -	nr_isolate_pageblock = ret;
>  
>  	arg.start_pfn = start_pfn;
>  	arg.nr_pages = nr_pages;
> @@ -1561,6 +1657,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  		goto failed_removal_isolated;
>  	}
>  
> +	if (skip)
> +		goto skip_migration;
> +
>  	do {
>  		for (pfn = start_pfn; pfn;) {
>  			if (signal_pending(current)) {
> @@ -1601,7 +1700,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	   We cannot do rollback at this point. */
>  	walk_system_ram_range(start_pfn, end_pfn - start_pfn,
>  			      &offlined_pages, offline_isolated_pages_cb);
> -	pr_info("Offlined Pages %ld\n", offlined_pages);
> +
> +skip_migration:
> +	pr_info("Offlined Pages %ld\n", offlined_pages + nr_vmemmap_pages);
>  	/*
>  	 * Onlining will reset pagetype flags and makes migrate type
>  	 * MOVABLE, so just need to decrease the number of isolated
> @@ -1612,11 +1713,12 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  
>  	/* removal success */
> -	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
> -	zone->present_pages -= offlined_pages;
> +	if (offlined_pages)
> +		adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
> +	zone->present_pages -= offlined_pages + nr_vmemmap_pages;
>  
>  	pgdat_resize_lock(zone->zone_pgdat, &flags);
> -	zone->zone_pgdat->node_present_pages -= offlined_pages;
> +	zone->zone_pgdat->node_present_pages -= offlined_pages + nr_vmemmap_pages;
>  	pgdat_resize_unlock(zone->zone_pgdat, &flags);
>  
>  	init_per_zone_wmark_min();
> @@ -1645,7 +1747,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	memory_notify(MEM_CANCEL_OFFLINE, &arg);
>  failed_removal:
>  	pr_debug("memory offlining [mem %#010llx-%#010llx] failed due to %s\n",
> -		 (unsigned long long) start_pfn << PAGE_SHIFT,
> +		 (unsigned long long) (start_pfn - nr_vmemmap_pages) << PAGE_SHIFT,
>  		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1,
>  		 reason);
>  	/* pushback to free area */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5b3266d63521..7a73a06c5730 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1282,9 +1282,14 @@ static void free_one_page(struct zone *zone,
>  static void __meminit __init_single_page(struct page *page, unsigned long pfn,
>  				unsigned long zone, int nid)
>  {
> -	mm_zero_struct_page(page);
> +	if (!__PageVmemmap(page)) {
> +		/*
> +		 * Vmemmap pages need to preserve their state.
> +		 */
> +		mm_zero_struct_page(page);
> +		init_page_count(page);
> +	}
>  	set_page_links(page, zone, nid, pfn);
> -	init_page_count(page);
>  	page_mapcount_reset(page);
>  	page_cpupid_reset_last(page);
>  	page_kasan_tag_reset(page);
> @@ -8143,6 +8148,14 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  
>  		page = pfn_to_page(check);
>  
> +		/*
> +		 * Vmemmap pages are not needed to be moved around.
> +		 */
> +		if (PageVmemmap(page)) {
> +			iter += get_nr_vmemmap_pages(page) - 1;
> +			continue;
> +		}
> +
>  		if (PageReserved(page))
>  			goto unmovable;
>  
> @@ -8510,6 +8523,11 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  			continue;
>  		}
>  		page = pfn_to_page(pfn);
> +
> +		if (PageVmemmap(page)) {
> +			pfn += get_nr_vmemmap_pages(page);
> +			continue;
> +		}
>  		/*
>  		 * The HWPoisoned page may be not in buddy system, and
>  		 * page_count() is not 0.
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index e3638a5bafff..128c47a27925 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -146,7 +146,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  static inline struct page *
>  __first_valid_page(unsigned long pfn, unsigned long nr_pages)
>  {
> -	int i;
> +	unsigned long i;
>  
>  	for (i = 0; i < nr_pages; i++) {
>  		struct page *page;
> @@ -154,6 +154,10 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
>  		page = pfn_to_online_page(pfn + i);
>  		if (!page)
>  			continue;
> +		if (PageVmemmap(page)) {
> +			i += get_nr_vmemmap_pages(page) - 1;
> +			continue;
> +		}
>  		return page;
>  	}
>  	return NULL;
> @@ -268,6 +272,14 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>  			continue;
>  		}
>  		page = pfn_to_page(pfn);
> +		/*
> +		 * Vmemmap pages are not isolated. Skip them.
> +		 */
> +		if (PageVmemmap(page)) {
> +			pfn += get_nr_vmemmap_pages(page);
> +			continue;
> +		}
> +
>  		if (PageBuddy(page))
>  			/*
>  			 * If the page is on a free list, it has to be on
> diff --git a/mm/sparse.c b/mm/sparse.c
> index b77ca21a27a4..04b395fb4463 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -635,6 +635,94 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
>  #endif
>  
>  #ifdef CONFIG_SPARSEMEM_VMEMMAP
> +void mark_vmemmap_pages(struct vmem_altmap *self)
> +{
> +	unsigned long pfn = self->base_pfn + self->reserve;
> +	unsigned long nr_pages = self->alloc;
> +	unsigned long nr_sects = self->free / PAGES_PER_SECTION;
> +	unsigned long i;
> +	struct page *head;
> +
> +	if (!nr_pages)
> +		return;
> +
> +	pr_debug("%s: marking %px - %px as Vmemmap (%ld pages)\n",
> +						__func__,
> +						pfn_to_page(pfn),
> +						pfn_to_page(pfn + nr_pages - 1),
> +						nr_pages);
> +
> +	/*
> +	 * All allocations for the memory hotplug are the same sized so align
> +	 * should be 0.
> +	 */
> +	WARN_ON(self->align);
> +
> +	/*
> +	 * Layout of vmemmap pages:
> +	 * [Head->refcount] : Nr sections used by this altmap
> +	 * [Head->private]  : Nr of vmemmap pages
> +	 * [Tail->freelist] : Pointer to the head page
> +	 */
> +
> +	/*
> +	 * Head, first vmemmap page
> +	 */
> +	head = pfn_to_page(pfn);
> +	for (i = 0; i < nr_pages; i++, pfn++) {
> +		struct page *page = pfn_to_page(pfn);
> +
> +		mm_zero_struct_page(page);
> +		__SetPageVmemmap(page);
> +		page->freelist = head;
> +		init_page_count(page);
> +	}
> +	set_page_count(head, (int)nr_sects);
> +	set_page_private(head, nr_pages);
> +}
> +/*
> + * If the range we are trying to remove was hot-added with vmemmap pages
> + * using MHP_MEMMAP_DEVICE, we need to keep track of it to know how much
> + * do we have do defer the free up.
> + * Since sections are removed sequentally in __remove_pages()->
> + * __remove_section(), we just wait until we hit the last section.
> + * Once that happens, we can trigger free_deferred_vmemmap_range to actually
> + * free the whole memory-range.
> + */
> +static struct page *head_vmemmap_page = NULL;;
> +static bool freeing_vmemmap_range = false;
> +
> +static inline bool vmemmap_dec_and_test(void)
> +{
> +	return page_ref_dec_and_test(head_vmemmap_page);
> +}
> +
> +static void free_deferred_vmemmap_range(unsigned long start,
> +                                       unsigned long end)
> +{
> +	unsigned long nr_pages = end - start;
> +	unsigned long first_section = (unsigned long)head_vmemmap_page;
> +
> +	while (start >= first_section) {
> +		vmemmap_free(start, end, NULL);
> +		end = start;
> +		start -= nr_pages;
> +	}
> +	head_vmemmap_page = NULL;
> +	freeing_vmemmap_range = false;
> +}
> +
> +static void deferred_vmemmap_free(unsigned long start, unsigned long end)
> +{
> +	if (!freeing_vmemmap_range) {
> +		freeing_vmemmap_range = true;
> +		head_vmemmap_page = (struct page *)start;
> +	}
> +
> +	if (vmemmap_dec_and_test())
> +		free_deferred_vmemmap_range(start, end);
> +}
> +
>  static struct page *populate_section_memmap(unsigned long pfn,
>  		unsigned long nr_pages, int nid, struct vmem_altmap *altmap)
>  {
> @@ -647,6 +735,11 @@ static void depopulate_section_memmap(unsigned long pfn, unsigned long nr_pages,
>  	unsigned long start = (unsigned long) pfn_to_page(pfn);
>  	unsigned long end = start + nr_pages * sizeof(struct page);
>  
> +	if (PageVmemmap((struct page *)start) || freeing_vmemmap_range) {
> +		deferred_vmemmap_free(start, end);
> +		return;
> +	}
> +
>  	vmemmap_free(start, end, altmap);
>  }
>  static void free_map_bootmem(struct page *memmap)
> 


-- 

Thanks,

David / dhildenb

