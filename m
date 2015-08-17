Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9065B6B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 03:45:30 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so63257620wic.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 00:45:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id en7si25605754wjd.61.2015.08.17.00.45.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Aug 2015 00:45:28 -0700 (PDT)
Subject: Re: [RFC PATCH kernel vfio] mm: vfio: Move pages out of CMA before
 pinning
References: <1438762094-17747-1-git-send-email-aik@ozlabs.ru>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D1910C.7070006@suse.cz>
Date: Mon, 17 Aug 2015 09:45:16 +0200
MIME-Version: 1.0
In-Reply-To: <1438762094-17747-1-git-send-email-aik@ozlabs.ru>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>, linux-mm@kvack.org
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Gibson <david@gibson.dropbear.id.au>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Alexander Graf <agraf@suse.de>, Paolo Bonzini <pbonzini@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>

On 08/05/2015 10:08 AM, Alexey Kardashevskiy wrote:
> This is about VFIO aka PCI passthrough used from QEMU.
> KVM is irrelevant here.
>
> QEMU is a machine emulator. It allocates guest RAM from anonymous memory
> and these pages are movable which is ok. They may happen to be allocated
> from the contiguous memory allocation zone (CMA). Which is also ok as
> long they are movable.
>
> However if the guest starts using VFIO (which can be hotplugged into
> the guest), in most cases it involves DMA which requires guest RAM pages
> to be pinned and not move once their addresses are programmed to
> the hardware for DMA.
>
> So we end up in a situation when quite many pages in CMA are not movable
> anymore. And we get bunch of these:
>
> [77306.513966] alloc_contig_range: [1f3800, 1f78c4) PFNs busy
> [77306.514448] alloc_contig_range: [1f3800, 1f78c8) PFNs busy
> [77306.514927] alloc_contig_range: [1f3800, 1f78cc) PFNs busy

IIRC CMA was for mobile devices and their camera/codec drivers and you 
don't use QEMU on those? What do you need CMA for in your case?

> This is a very rough patch to start the conversation about how to move
> pages properly. mm/page_alloc.c does this and
> arch/powerpc/mm/mmu_context_iommu.c exploits it.

OK such conversation should probably start by mentioning the VM_PINNED 
effort by Peter Zijlstra: https://lkml.org/lkml/2014/5/26/345

It's more general approach to dealing with pinned pages, and moving them 
out of CMA area (and compacting them in general) prior pinning is one of 
the things that should be done within that framework.

Then there's the effort to enable migrating pages other than LRU during 
compaction (and thus CMA allocation): https://lwn.net/Articles/650864/
I don't know if that would be applicable in your use case, i.e. are the 
pins for DMA short-lived and can the isolation/migration code wait a bit 
for the transfer to finish so it can grab them, or something?

>
> Please do not comment on the style and code placement,
> this is just to give some context :)
>
> Obviously, this does not work well - it manages to migrate only few pages
> and crashes as it is missing locks/disabling interrupts and I probably
> should not just remove pages from LRU list (normally, I guess, only these
> can migrate) and a million of other things.
>
> The questions are:
>
> - what is the correct way of telling if the page is in CMA?
> is (get_pageblock_migratetype(page) == MIGRATE_CMA) good enough?

Should be.

> - how to tell MM to move page away? I am calling migrate_pages() with
> an get_new_page callback which allocates a page with GFP_USER but without
> GFP_MOVABLE which should allocate new page out of CMA which seems ok but
> there is a little convern that we might want to add MOVABLE back when
> VFIO device is unplugged from the guest.

Hmm, once the page is allocated, then the migratetype is not tracked 
anywhere (except in page_owner debug data). But the unmovable 
allocations might exhaust available unmovable pageblocks and lead to 
fragmentation. So "add MOVABLE back" would be too late. Instead we would 
need to tell the allocator somehow to give us movable page but outside 
of CMA. CMA's own __alloc_contig_migrate_range() avoids this problem by 
allocating movable pages, but the range has been already page-isolated 
and thus the allocator won't see the pages there. You obviously can't 
take this approach and isolate all CMA pageblocks like that. That smells 
like a new __GFP_FLAG, meh.

> - do I need to isolate pages by using isolate_migratepages_range,
> reclaim_clean_pages_from_list like __alloc_contig_migrate_range does?
> I dropped them for now and the patch uses only @migratepages from
> the compact_control struct.

You don't have to do reclaim_clean_pages_from_list(), but the isolation 
has to be careful, yeah.

> - are there any flags in madvise() to address this (could not
> locate any relevant)?

AFAIK there's no madvise(I_WILL_BE_PINNING_THIS_RANGE).

> - what else is missing? disabled interrupts? locks?

See what isolate_migratepages_block() does.

> Thanks!
>
>
> Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
> ---
>   arch/powerpc/mm/mmu_context_iommu.c | 40 +++++++++++++++++++++++++++++++------
>   mm/page_alloc.c                     | 36 +++++++++++++++++++++++++++++++++
>   2 files changed, 70 insertions(+), 6 deletions(-)
>
> diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
> index da6a216..bf6850e 100644
> --- a/arch/powerpc/mm/mmu_context_iommu.c
> +++ b/arch/powerpc/mm/mmu_context_iommu.c
> @@ -72,12 +72,15 @@ bool mm_iommu_preregistered(void)
>   }
>   EXPORT_SYMBOL_GPL(mm_iommu_preregistered);
>
> +extern int mm_iommu_move_page(unsigned long pfn);
> +
>   long mm_iommu_get(unsigned long ua, unsigned long entries,
>   		struct mm_iommu_table_group_mem_t **pmem)
>   {
>   	struct mm_iommu_table_group_mem_t *mem;
>   	long i, j, ret = 0, locked_entries = 0;
>   	struct page *page = NULL;
> +	unsigned long moved = 0, tried = 0;
>
>   	if (!current || !current->mm)
>   		return -ESRCH; /* process exited */
> @@ -122,15 +125,29 @@ long mm_iommu_get(unsigned long ua, unsigned long entries,
>   	}
>
>   	for (i = 0; i < entries; ++i) {
> +		unsigned long pfn;
> +
>   		if (1 != get_user_pages_fast(ua + (i << PAGE_SHIFT),
>   					1/* pages */, 1/* iswrite */, &page)) {
> -			for (j = 0; j < i; ++j)
> -				put_page(pfn_to_page(
> -						mem->hpas[j] >> PAGE_SHIFT));
> -			vfree(mem->hpas);
> -			kfree(mem);
>   			ret = -EFAULT;
> -			goto unlock_exit;
> +			goto put_exit;
> +		}
> +
> +		pfn = page_to_pfn(page);
> +		if (get_pageblock_migratetype(page) == MIGRATE_CMA)
> +		{
> +			unsigned long pfnold = pfn;
> +			put_page(page);
> +			page = NULL;
> +			mm_iommu_move_page(pfn);
> +			if (1 != get_user_pages_fast(ua + (i << PAGE_SHIFT),
> +						1/* pages */, 1/* iswrite */, &page)) {
> +				ret = -EFAULT;
> +				goto put_exit;
> +			}
> +			pfn = page_to_pfn(page);
> +			if (pfn != pfnold)
> +				++moved;
>   		}
>
>   		mem->hpas[i] = page_to_pfn(page) << PAGE_SHIFT;
> @@ -144,6 +161,17 @@ long mm_iommu_get(unsigned long ua, unsigned long entries,
>
>   	list_add_rcu(&mem->next, &current->mm->context.iommu_group_mem_list);
>
> +	printk("***K*** %s %u: tried %lu, moved %lu of %lu\n", __func__, __LINE__,
> +			tried, moved, entries);
> +
> +put_exit:
> +	if (ret) {
> +		for (j = 0; j < i; ++j)
> +			put_page(pfn_to_page(mem->hpas[j] >> PAGE_SHIFT));
> +		vfree(mem->hpas);
> +		kfree(mem);
> +	}
> +
>   unlock_exit:
>   	if (locked_entries && ret)
>   		mm_iommu_adjust_locked_vm(current->mm, locked_entries, false);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ef19f22..0639cce 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7008,3 +7008,39 @@ bool is_free_buddy_page(struct page *page)
>   	return order < MAX_ORDER;
>   }
>   #endif
> +
> +static struct page *mm_iommu_new_page(struct page *page, unsigned long private,
> +				int **reason)
> +{
> +	 /*
> +	  * Anything but not GFP_MOVABLE!
> +	  */
> +	return alloc_page(GFP_USER);
> +}
> +
> +static void mm_iommu_free_page(struct page *page, unsigned long private)
> +{
> +	free_page(page_to_pfn(page) << PAGE_SHIFT);
> +}
> +
> +int mm_iommu_move_page(unsigned long pfn)
> +{
> +	unsigned long ret, nr_reclaimed;
> +	struct compact_control cc = {
> +		.nr_migratepages = 0,
> +		.order = -1,
> +		.zone = page_zone(pfn_to_page(pfn)),
> +		.mode = MIGRATE_SYNC,
> +		.ignore_skip_hint = true,
> +	};
> +	struct page *page = pfn_to_page(pfn);
> +	INIT_LIST_HEAD(&cc.migratepages);
> +
> +	if (PageLRU(page)) {
> +		list_del(&page->lru);
> +	}
> +	ret = migrate_pages(&cc.migratepages, mm_iommu_new_page,
> +			mm_iommu_free_page, 0, cc.mode, MR_CMA);
> +
> +	return ret;
> +}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
