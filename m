Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35BBBC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:05:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A00662087E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:05:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A00662087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 249748E0020; Thu,  1 Aug 2019 11:05:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FB468E0001; Thu,  1 Aug 2019 11:05:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C2A88E0020; Thu,  1 Aug 2019 11:05:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D89D68E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 11:05:04 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c207so61416007qkb.11
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 08:05:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=acH+Uu3i2HgZGub0/T4fGtKjcBxUsDGsYcTRbrCGqGg=;
        b=S0xVRSJEoJqB1dcYU9GkVgOK+T2/gHH8jGiJP5yx0ZZErUD5UcVV+dlD2idEuiQoW6
         2dNuvXFvpTbQILFCqLiwnAbVRLLR8BHvPnEU2ZAONanvnmlsIBeGlwCU9eGxBcFks4MG
         QrRIs7hb1xH4v/qr5gVfp28u4PI0KP++L/zzLnwf6YDNKo6IlZyo+QaB+ysJChy6Je9d
         nRH/mKv69Hv7Ffi1cOyIkZEWJHN6r7kWeXXRmH95jIHUPapLMY5rv8N3beZC31QDhXSC
         tLIMlKMGsY9qd2rHIcuIVb6R1DhTwVOitUx2n4jkrH+R2Plj1PqMC+116KOGok7GQdwi
         EpJA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/lwOAmlAIRxGdDMAye1C3y5cGCm2oXax2PyDuS7+MmWUCzDX6
	n+vUXyDJ+msY8i+Sn/GlhZZgqfXGT+Bjln3YdLNv5zEkA+g7zWBXiJ0XebgszLFJk52aKIPp1Ya
	NpT/n0mvyJ6Y5LgopHF8baqr8hl2oZEJO3KkK9LuJUWCrqnZM57dpdtD0s3n+LCxB/Q==
X-Received: by 2002:a05:620a:124f:: with SMTP id a15mr87278873qkl.173.1564671904569;
        Thu, 01 Aug 2019 08:05:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9WRAEEa1nmFFpOnpUAr2w5utyfWrK4TOHOB9WGuCipV/vV32xlP5o6veMZzi5EqX8MPuq
X-Received: by 2002:a05:620a:124f:: with SMTP id a15mr87278677qkl.173.1564671902673;
        Thu, 01 Aug 2019 08:05:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564671902; cv=none;
        d=google.com; s=arc-20160816;
        b=Cwd2EHKwQdV5g4IYCnXLjDjSgEMOkfnIw8zdF2W1Cn9Xf4X5NRXygvrmMUL6/A0q2Z
         MBGmO4AqQYT4C4g2gwzQ426Jo6n/4qFJe83DPsk1FXNr5ECizsbiB2hXCjql7UUCJHx3
         3KO4sSSIe5p00Vw4zeksX6ncpPN2eqzFLa+0AlSKUo1VgLgFq/xCr2zCr8tzvvpUX0s6
         D1Gx2GSJjxdvKwQkHXFNEmQgY5ZVs7Y6kLIrfhszNhoRnJxBbEX3e7bQZz24Ji4D1R8Y
         X/ptNmoFhTa1GBzHrYVD8s69dR8tZpWSXXWHWH/oWhxQkG0ED9V4YTzkijCF3ctGTbGK
         g2xQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=acH+Uu3i2HgZGub0/T4fGtKjcBxUsDGsYcTRbrCGqGg=;
        b=Z3FU+gJjI+BInWLft5tSHHsMEC3My1y8aHT28Bc/nDYIs2X5Jp9m8zHhfEJkcXQvKB
         okrBgnpZ59l+7SXlKKjSDl4s0sHQYx2Z3fN4TaAGVv/hYNqPzqfKO5ABW2ZLb7sAZxcK
         SAWGhz3guPpZ8bsMRG8qjsKjdM+iV4AQj2phjt/xPCMGtfbKQNd1aOzDebQA2n7+JFDw
         OnSRuWc6N2Oc4dA2o7OBwHDArL+gRs47lqOObP0jHMWWXjBBwa29F+u8UqOsNKsOSj4U
         fpTjAK0Czmnrp5EnEefnsGjrWitsEjQRRarCPG3X9tuGmL+Qfd0Kq+DYTtAIdIHulHSt
         mWfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w8si16737536qta.357.2019.08.01.08.05.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 08:05:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 96EB0C0AD2BB;
	Thu,  1 Aug 2019 15:05:01 +0000 (UTC)
Received: from [10.36.116.115] (ovpn-116-115.ams2.redhat.com [10.36.116.115])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 38C861001B02;
	Thu,  1 Aug 2019 15:04:59 +0000 (UTC)
Subject: Re: [PATCH v3 4/5] mm,memory_hotplug: Allocate memmap from the added
 memory range for sparse-vmemmap
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, pasha.tatashin@soleen.com, mhocko@suse.com,
 anshuman.khandual@arm.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190725160207.19579-1-osalvador@suse.de>
 <20190725160207.19579-5-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <6f2cf0c5-a319-370e-414a-fa341ebd650d@redhat.com>
Date: Thu, 1 Aug 2019 17:04:58 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190725160207.19579-5-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 01 Aug 2019 15:05:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.07.19 18:02, Oscar Salvador wrote:
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

FWIW, e.g., in my current virtio-mem prototype, I add a bunch of memory
blocks and wait until they have been onlined to add more memory blocks
(max 10 offline at a time). So I am not sure if this is actually a
problem that couldn't have been solved differently. Or I am missing
something :)

Anyhow, the enumeration a) b) a) is strange :)

> 
> This can be improved when CONFIG_SPARSEMEM_VMEMMAP is enabled.
> 
> Vmemap page tables can map arbitrary memory.
> That means that we can simply use the beginning of each memory section and
> map struct pages there.
> struct pages which back the allocated space then just need to be treated
> carefully.
> 
> Implementation wise we will reuse vmem_altmap infrastructure to override
> the default allocator used by __vmemap_populate. Once the memmap is
> allocated, we are going to need a way to mark altmap pfns used for the allocation.
> If MHP_MEMMAP_ON_MEMORY flag was passed, we will set up the layout of the
> altmap structure at the beginning of __add_pages(), and then we will call
> mhp_mark_vmemmap_pages() to do the proper marking.
> 
> mhp_mark_vmemmap_pages() marks the pages as vmemmap and sets some metadata:
> 
> Vmemmap's pages layout is as follows:
> 
>         * Layout:
>         * Head:
>         *      head->vmemmap_pages     : nr of vmemmap pages
>         *      head->vmemmap_sections  : nr of sections used by this altmap
>         * Tail:
>         *      tail->vmemmap_head      : head
>         * All:
>         *      page->type              : Vmemmap
> 

This description belongs into the introducing patch :)

> E.g:
> When hot-add 1GB on x86_64 :
> 
> head->vmemmap_pages = 4096
> head->vmemmap_sections = 8
> 
> We keep this information within the struct pages as we need them in certain
> stages like offline, online and hot-remove.
> 
> head->vmemmap_sections is a kind of refcount, because when using MHP_MEMMAP_ON_MEMORY,
> we need to know how much do we have to defer the call to vmemmap_free().

Why is it used as a refcount (see my comment to the previous patch,
storing the section count still makes sense)? As you validate that the
same granualrity is removed as was added, I would have guessed this does
not matter. But as we discussed, the whole ClearVmemmapPage() stuff
might not be needed at all (implying this patch can be simplified).

> The thing is that the first pages of the memory range are used to store the
> memmap mapping, so we cannot remove those first, otherwise we would blow up
> when accessing the other pages.

That is interesting: struct pages are initialized when onlining. That
makes me assume after offlining, the content is stale (especially when
never onlined). We should really fix any accesses to struct pages when
removing memory first. This smells like working around something that is
already broken.

> 
> So, instead of actually removing the section (with vmemmap_free), we wait
> until we remove the last one, and then we call vmemmap_free() for all
> batched sections.
> 
> We also have to be careful about those pages during online and offline
> operations. They are simply skipped, so online will keep them
> reserved and so unusable for any other purpose and offline ignores them
> so they do not block the offline operation.

As discussed, maybe storing an offset in the memory block can avoid
having to look at struct pages when onlining/offlining - simply skip
that part.

> 
> In offline operation we only have to check for one particularity.
> Depending on the way the hot-added range was added, it might be that,
> that one or more of memory blocks from the beginning are filled with
> only vmemmap pages.
> We just need to check for this case and skip 1) isolating 2) migrating,
> because those pages do not need to be migrated anywhere, as they are
> self-hosted.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  arch/powerpc/mm/init_64.c      |   7 +++
>  arch/s390/mm/init.c            |   6 ++
>  arch/x86/mm/init_64.c          |  10 +++
>  drivers/acpi/acpi_memhotplug.c |   3 +-
>  include/linux/memory_hotplug.h |   6 ++
>  include/linux/memremap.h       |   2 +-
>  mm/compaction.c                |   7 +++
>  mm/memory_hotplug.c            | 136 ++++++++++++++++++++++++++++++++++++++---
>  mm/page_alloc.c                |  26 +++++++-
>  mm/page_isolation.c            |  14 ++++-
>  mm/sparse.c                    | 107 ++++++++++++++++++++++++++++++++
>  11 files changed, 309 insertions(+), 15 deletions(-)
> 
> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
> index a44f6281ca3a..f19aa006ca6d 100644
> --- a/arch/powerpc/mm/init_64.c
> +++ b/arch/powerpc/mm/init_64.c
> @@ -292,6 +292,13 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
>  
>  		if (base_pfn >= alt_start && base_pfn < alt_end) {
>  			vmem_altmap_free(altmap, nr_pages);
> +		} else if (PageVmemmap(page)) {
> +			/*
> +			 * runtime vmemmap pages are residing inside the memory
> +			 * section so they do not have to be freed anywhere.
> +			 */
> +			while (PageVmemmap(page))
> +				ClearPageVmemmap(page++);
>  		} else if (PageReserved(page)) {
>  			/* allocated from bootmem */
>  			if (page_size < PAGE_SIZE) {
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index 20340a03ad90..adb04f3977eb 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -278,6 +278,12 @@ int arch_add_memory(int nid, u64 start, u64 size,
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
> index a6b5c653727b..f9f720a28b3e 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -876,6 +876,16 @@ static void __meminit free_pagetable(struct page *page, int order)
>  	unsigned long magic;
>  	unsigned int nr_pages = 1 << order;
>  
> +	/*
> +	 * Runtime vmemmap pages are residing inside the memory section so
> +	 * they do not have to be freed anywhere.
> +	 */
> +	if (PageVmemmap(page)) {
> +		while (nr_pages--)
> +			ClearPageVmemmap(page++);
> +		return;
> +	}
> +
>  	/* bootmem page has reserved flag */
>  	if (PageReserved(page)) {
>  		__ClearPageReserved(page);
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index d91b3584d4b2..e0148dde5313 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -207,7 +207,8 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>  		if (node < 0)
>  			node = memory_add_physaddr_to_nid(info->start_addr);
>  
> -		result = __add_memory(node, info->start_addr, info->length, 0);
> +		result = __add_memory(node, info->start_addr, info->length,
> +				      MHP_MEMMAP_ON_MEMORY);
>  
>  		/*
>  		 * If the memory block has been used by the kernel, add_memory()
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 6b20008d9297..e1e8abf22a80 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -377,4 +377,10 @@ extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_
>  		int online_type);
>  extern struct zone *zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
>  		unsigned long nr_pages);
> +
> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> +extern void mhp_mark_vmemmap_pages(struct vmem_altmap *self);
> +#else
> +static inline void mhp_mark_vmemmap_pages(struct vmem_altmap *self) {}
> +#endif
>  #endif /* __LINUX_MEMORY_HOTPLUG_H */
> diff --git a/include/linux/memremap.h b/include/linux/memremap.h
> index 2cfc3c289d01..0a7355b8c1cf 100644
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
> index ac4ead029b4a..2faf769375c4 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -857,6 +857,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
>  		nr_scanned++;
>  
>  		page = pfn_to_page(low_pfn);
> +		/*
> +		 * Vmemmap pages do not need to be isolated.
> +		 */
> +		if (PageVmemmap(page)) {
> +			low_pfn += vmemmap_nr_pages(page) - 1;
> +			continue;
> +		}

What if somebody uses this e.g. via alloc_pages_contig()? Are we sure
only the actual memory offlining path will skip these? (maybe looking at
the pageblock migratetype might be necessary).

This makes me think that we should not even try to offline/online these
pages right from online_pages()/offline_pages() but instead skip the
vmemmap part there completely.

>  
>  		/*
>  		 * Check if the pageblock has already been marked skipped.
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c2338703ce80..09d41339cd11 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -278,6 +278,13 @@ static int check_pfn_span(unsigned long pfn, unsigned long nr_pages,
>  	return 0;
>  }
>  
> +static void mhp_init_altmap(unsigned long pfn, unsigned long nr_pages,
> +			    struct vmem_altmap *altmap)
> +{
> +	altmap->free = nr_pages;
> +	altmap->base_pfn = pfn;
> +}
> +
>  /*
>   * Reasonably generic function for adding memory.  It is
>   * expected that archs that support memory hotplug will
> @@ -289,8 +296,18 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
>  {
>  	int err;
>  	unsigned long nr, start_sec, end_sec;
> -	struct vmem_altmap *altmap = restrictions->altmap;
> +	struct vmem_altmap *altmap;
> +	struct vmem_altmap mhp_altmap = {};
> +	unsigned long mhp_flags = restrictions->flags;
> +	bool vmemmap_section = false;
> +
> +	if (mhp_flags) {
> +		mhp_init_altmap(pfn, nr_pages, &mhp_altmap);
> +		restrictions->altmap = &mhp_altmap;
> +		vmemmap_section = true;
> +	}
>  
> +	altmap = restrictions->altmap;
>  	if (altmap) {
>  		/*
>  		 * Validate altmap is within bounds of the total request
> @@ -314,7 +331,7 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
>  
>  		pfns = min(nr_pages, PAGES_PER_SECTION
>  				- (pfn & ~PAGE_SECTION_MASK));
> -		err = sparse_add_section(nid, pfn, pfns, altmap, 0);
> +		err = sparse_add_section(nid, pfn, pfns, altmap, vmemmap_section);
>  		if (err)
>  			break;
>  		pfn += pfns;
> @@ -322,6 +339,10 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
>  		cond_resched();
>  	}
>  	vmemmap_populate_print_last();
> +
> +	if (mhp_flags)
> +		mhp_mark_vmemmap_pages(altmap);
> +
>  	return err;
>  }
>  
> @@ -640,6 +661,14 @@ static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
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
> @@ -648,17 +677,51 @@ static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
>  	return onlined_pages;
>  }
>  
> +static bool vmemmap_skip_block(unsigned long pfn, unsigned long nr_pages,
> +		       unsigned long *nr_vmemmap_pages)
> +{
> +	bool skip = false;
> +	unsigned long vmemmap_pages = 0;
> +
> +	/*
> +	 * This function gets called from {online,offline}_pages.
> +	 * It has two goals:
> +	 *
> +	 * 1) Account number of vmemmap pages within the range
> +	 * 2) Check if the whole range contains only vmemmap_pages.
> +	 */
> +
> +	if (PageVmemmap(pfn_to_page(pfn))) {
> +		struct page *page = pfn_to_page(pfn);
> +
> +		vmemmap_pages = min(vmemmap_nr_pages(page), nr_pages);
> +		if (vmemmap_pages == nr_pages)
> +			skip = true;
> +	}
> +
> +	*nr_vmemmap_pages = vmemmap_pages;
> +	return skip;
> +}
> +
>  static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>  			void *arg)
>  {
>  	unsigned long onlined_pages = *(unsigned long *)arg;
> -
> -	if (PageReserved(pfn_to_page(start_pfn)))
> -		onlined_pages += online_pages_blocks(start_pfn, nr_pages);
> -
> +	unsigned long pfn = start_pfn;
> +	unsigned long nr_vmemmap_pages = 0;
> +	bool skip;
> +
> +	skip = vmemmap_skip_block(pfn, nr_pages, &nr_vmemmap_pages);
> +	if (skip)
> +		goto skip_online_pages;
> +
> +	pfn += nr_vmemmap_pages;
> +	if (PageReserved(pfn_to_page(pfn)))
> +		onlined_pages += online_pages_blocks(pfn, nr_pages - nr_vmemmap_pages);
> +skip_online_pages:
>  	online_mem_sections(start_pfn, start_pfn + nr_pages);
>  
> -	*(unsigned long *)arg = onlined_pages;
> +	*(unsigned long *)arg = onlined_pages + nr_vmemmap_pages;
>  	return 0;
>  }
>  
> @@ -1040,6 +1103,19 @@ static int online_memory_block(struct memory_block *mem, void *arg)
>  	return device_online(&mem->dev);
>  }
>  
> +static unsigned long mhp_check_flags(unsigned long flags)
> +{
> +	if (!flags)
> +		return 0;
> +
> +	if (flags != MHP_MEMMAP_ON_MEMORY) {
> +		WARN(1, "Wrong flags value (%lx). Ignoring flags.\n", flags);
> +		return 0;
> +	}
> +
> +	return flags;
> +}
> +
>  /*
>   * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
>   * and online/offline operations (triggered e.g. by sysfs).
> @@ -1075,6 +1151,8 @@ int __ref add_memory_resource(int nid, struct resource *res, unsigned long flags
>  		goto error;
>  	new_node = ret;
>  
> +	restrictions.flags = mhp_check_flags(flags);
> +
>  	/* call arch's memory hotadd */
>  	ret = arch_add_memory(nid, start, size, &restrictions);
>  	if (ret < 0)
> @@ -1502,12 +1580,14 @@ static int __ref __offline_pages(unsigned long start_pfn,
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
> @@ -1524,8 +1604,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	node = zone_to_nid(zone);
>  	nr_pages = end_pfn - start_pfn;
>  
> +	skip = vmemmap_skip_block(start_pfn, nr_pages, &nr_vmemmap_pages);
> +
>  	/* set above range as isolated */
> -	ret = start_isolate_page_range(start_pfn, end_pfn,
> +	ret = start_isolate_page_range(start_pfn + nr_vmemmap_pages, end_pfn,
>  				       MIGRATE_MOVABLE,
>  				       SKIP_HWPOISON | REPORT_FAILURE);
>  	if (ret < 0) {
> @@ -1545,6 +1627,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  		goto failed_removal_isolated;
>  	}
>  
> +	if (skip)
> +		goto skip_migration;
> +
>  	do {
>  		for (pfn = start_pfn; pfn;) {
>  			if (signal_pending(current)) {
> @@ -1581,6 +1666,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  					    NULL, check_pages_isolated_cb);
>  	} while (ret);
>  
> +skip_migration:
>  	/* Ok, all of our target is isolated.
>  	   We cannot do rollback at this point. */
>  	walk_system_ram_range(start_pfn, end_pfn - start_pfn,
> @@ -1596,7 +1682,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  
>  	/* removal success */
> -	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
> +	if (offlined_pages)
> +		adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
> +	offlined_pages += nr_vmemmap_pages;
>  	zone->present_pages -= offlined_pages;
>  
>  	pgdat_resize_lock(zone->zone_pgdat, &flags);
> @@ -1739,11 +1827,41 @@ static void __release_memory_resource(resource_size_t start,
>  	}
>  }
>  
> +static int check_hotplug_granularity(u64 start, u64 size)
> +{
> +	unsigned long pfn = PHYS_PFN(start);
> +
> +	/*
> +	 * Sanity check in case the range used MHP_MEMMAP_ON_MEMORY.
> +	 */
> +	if (vmemmap_section(__pfn_to_section(pfn))) {
> +		struct page *page = pfn_to_page(pfn);
> +		unsigned long nr_pages = size >> PAGE_SHIFT;
> +		unsigned long sections;
> +
> +		/*
> +		 * The start of the memory range is not correct.
> +		 */
> +		if (!PageVmemmap(page) || (vmemmap_head(page) != page))
> +			return -EINVAL;
> +
> +		sections = vmemmap_nr_sections(page);
> +		if (sections * PAGES_PER_SECTION != nr_pages)
> +			/*
> +			 * Check that granularity is the same.
> +			 */
> +			return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
>  static int __ref try_remove_memory(int nid, u64 start, u64 size)
>  {
>  	int rc = 0;
>  
>  	BUG_ON(check_hotplug_memory_range(start, size));
> +	BUG_ON(check_hotplug_granularity(start, size));
>  
>  	mem_hotplug_begin();
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d3bb601c461b..7c7d7130b627 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1340,14 +1340,21 @@ static void free_one_page(struct zone *zone,
>  static void __meminit __init_single_page(struct page *page, unsigned long pfn,
>  				unsigned long zone, int nid)
>  {
> +	if (PageVmemmap(page))
> +		/*
> +		 * Vmemmap pages need to preserve their state.
> +		 */
> +		goto preserve_state;
> +
>  	mm_zero_struct_page(page);
> -	set_page_links(page, zone, nid, pfn);
> -	init_page_count(page);
>  	page_mapcount_reset(page);
> +	INIT_LIST_HEAD(&page->lru);
> +preserve_state:
> +	init_page_count(page);
> +	set_page_links(page, zone, nid, pfn);
>  	page_cpupid_reset_last(page);
>  	page_kasan_tag_reset(page);
>  
> -	INIT_LIST_HEAD(&page->lru);
>  #ifdef WANT_PAGE_VIRTUAL
>  	/* The shift won't overflow because ZONE_NORMAL is below 4G. */
>  	if (!is_highmem_idx(zone))
> @@ -8184,6 +8191,14 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  
>  		page = pfn_to_page(check);
>  
> +		/*
> +		 * Vmemmap pages are not needed to be moved around.
> +		 */
> +		if (PageVmemmap(page)) {
> +			iter += vmemmap_nr_pages(page) - 1;
> +			continue;
> +		}

Same applies, maybe we can skip such stuff right from the caller. Not
sure :(

> +
>  		if (PageReserved(page))
>  			goto unmovable;
>  
> @@ -8551,6 +8566,11 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>  			continue;
>  		}
>  		page = pfn_to_page(pfn);
> +
> +		if (PageVmemmap(page)) {
> +			pfn += vmemmap_nr_pages(page);
> +			continue;
> +		}
>  		/*
>  		 * The HWPoisoned page may be not in buddy system, and
>  		 * page_count() is not 0.
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 89c19c0feadb..ee26ea41c9eb 100644
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
> +			i += vmemmap_nr_pages(page) - 1;
> +			continue;
> +		}
>  		return page;
>  	}
>  	return NULL;
> @@ -267,6 +271,14 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>  			continue;
>  		}
>  		page = pfn_to_page(pfn);
> +		/*
> +		 * Vmemmap pages are not isolated. Skip them.
> +		 */
> +		if (PageVmemmap(page)) {
> +			pfn += vmemmap_nr_pages(page);
> +			continue;
> +		}
> +
>  		if (PageBuddy(page))
>  			/*
>  			 * If the page is on a free list, it has to be on
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 09cac39e39d9..2cc2e5af1986 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -645,18 +645,125 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
>  #endif
>  
>  #ifdef CONFIG_SPARSEMEM_VMEMMAP
> +static void vmemmap_init_page(struct page *page, struct page *head)
> +{
> +	page_mapcount_reset(page);
> +	SetPageVmemmap(page);
> +	page->vmemmap_head = (unsigned long)head;
> +}
> +
> +static void vmemmap_init_head(struct page *page, unsigned long nr_sections,
> +			      unsigned long nr_pages)
> +{
> +	page->vmemmap_sections = nr_sections;
> +	page->vmemmap_pages = nr_pages;
> +}
> +
> +void mhp_mark_vmemmap_pages(struct vmem_altmap *self)
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
> +	/*
> +	 * All allocations for the memory hotplug are the same sized so align
> +	 * should be 0.
> +	 */
> +	WARN_ON(self->align);
> +
> +	memset(pfn_to_page(pfn), 0, sizeof(struct page) * nr_pages);
> +
> +	/*
> +	 * Mark pages as Vmemmap pages
> +	 * Layout:
> +	 * Head:
> +	 * 	head->vmemmap_pages	: nr of vmemmap pages
> +	 *	head->mhp_flags    	: MHP_flags
> +	 *	head->vmemmap_sections	: nr of sections used by this altmap
> +	 * Tail:
> +	 *	tail->vmemmap_head	: head
> +	 * All:
> +	 *	page->type		: Vmemmap
> +	 */

I think this documentation is better kept at the place where the fields
actually reside.

> +	head = pfn_to_page(pfn);
> +	for (i = 0; i < nr_pages; i++) {
> +		struct page *page = head + i;
> +
> +		vmemmap_init_page(page, head);
> +	}
> +	vmemmap_init_head(head, nr_sects, nr_pages);
> +}
> +
> +/*
> + * If the range we are trying to remove was hot-added with vmemmap pages
> + * using MHP_MEMMAP_*, we need to keep track of it to know how much
> + * do we have do defer the free up.
> + * Since sections are removed sequentally in __remove_pages()->
> + * __remove_section(), we just wait until we hit the last section.
> + * Once that happens, we can trigger free_deferred_vmemmap_range to actually
> + * free the whole memory-range.
> + */
> +static struct page *__vmemmap_head = NULL;
> +
>  static struct page *populate_section_memmap(unsigned long pfn,
>  		unsigned long nr_pages, int nid, struct vmem_altmap *altmap)
>  {
>  	return __populate_section_memmap(pfn, nr_pages, nid, altmap);
>  }
>  
> +static void vmemmap_free_deferred_range(unsigned long start,
> +					unsigned long end)
> +{
> +	unsigned long nr_pages = end - start;
> +	unsigned long first_section;
> +
> +	first_section = (unsigned long)__vmemmap_head;
> +	while (start >= first_section) {
> +		vmemmap_free(start, end, NULL);
> +		end = start;
> +		start -= nr_pages;
> +	}
> +	__vmemmap_head = NULL;
> +}
> +
> +static inline bool vmemmap_dec_and_test(void)
> +{
> +	__vmemmap_head->vmemmap_sections--;
> +	return !__vmemmap_head->vmemmap_sections;
> +}
> +
> +static void vmemmap_defer_free(unsigned long start, unsigned long end)
> +{
> +	if (vmemmap_dec_and_test())
> +		vmemmap_free_deferred_range(start, end);
> +}
> +
> +static inline bool should_defer_freeing(unsigned long start)
> +{
> +	if (PageVmemmap((struct page *)start) || __vmemmap_head) {
> +		if (!__vmemmap_head)
> +			__vmemmap_head = (struct page *)start;
> +		return true;
> +	}
> +	return false;
> +}
> +
>  static void depopulate_section_memmap(unsigned long pfn, unsigned long nr_pages,
>  		struct vmem_altmap *altmap)
>  {
>  	unsigned long start = (unsigned long) pfn_to_page(pfn);
>  	unsigned long end = start + nr_pages * sizeof(struct page);
>  
> +	if (should_defer_freeing(start)) {
> +		vmemmap_defer_free(start, end);
> +		return;
> +	}
> +
>  	vmemmap_free(start, end, altmap);
>  }
>  static void free_map_bootmem(struct page *memmap)
> 

Complicated stuff :)

-- 

Thanks,

David / dhildenb

