Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 2E9666B005D
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 10:01:53 -0500 (EST)
Message-ID: <50BF61E0.1060307@codeaurora.org>
Date: Wed, 05 Dec 2012 07:01:52 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Debugging: Keep track of page owners
References: <20121205011242.09C8667F@kernel.stglabs.ibm.com>
In-Reply-To: <20121205011242.09C8667F@kernel.stglabs.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@osdl.org, linux-mm@kvack.org

Hi,

This looks really useful. I'd like to see it usable on ARM. A couple of 
quick comments:

On 12/4/2012 5:12 PM, Dave Hansen wrote:
> From: mel@skynet.ie (Mel Gorman)

<snip>
>
> +#ifdef CONFIG_PAGE_OWNER
> +static inline int valid_stack_ptr(struct thread_info *tinfo, void *p)
> +{
> +	return	p > (void *)tinfo &&
> +		p < (void *)tinfo + THREAD_SIZE - 3;
> +}
> +
> +static inline void __stack_trace(struct page *page, unsigned long *stack,
> +			unsigned long bp)
> +{
> +	int i = 0;
> +	unsigned long addr;
> +	struct thread_info *tinfo = (struct thread_info *)
> +		((unsigned long)stack & (~(THREAD_SIZE - 1)));
> +
> +	memset(page->trace, 0, sizeof(long) * 8);
> +
> +#ifdef CONFIG_FRAME_POINTER
> +	if (bp) {
> +		while (valid_stack_ptr(tinfo, (void *)bp)) {
> +			addr = *(unsigned long *)(bp + sizeof(long));
> +			page->trace[i] = addr;
> +			if (++i >= 8)
> +				break;
> +			bp = *(unsigned long *)bp;
> +		}
> +		return;
> +	}
> +#endif /* CONFIG_FRAME_POINTER */
> +	while (valid_stack_ptr(tinfo, stack)) {
> +		addr = *stack++;
> +		if (__kernel_text_address(addr)) {
> +			page->trace[i] = addr;
> +			if (++i >= 8)
> +				break;
> +		}
> +	}
> +}
> +
> +static void set_page_owner(struct page *page, unsigned int order,
> +			unsigned int gfp_mask)
> +{
> +	unsigned long address;
> +	unsigned long bp = 0;
> +#ifdef CONFIG_X86_64
> +	asm ("movq %%rbp, %0" : "=r" (bp) : );
> +#endif
> +#ifdef CONFIG_X86_32
> +	asm ("movl %%ebp, %0" : "=r" (bp) : );
> +#endif
> +	page->order = (int) order;
> +	page->gfp_mask = gfp_mask;
> +	__stack_trace(page, &address, bp);
> +}
> +#endif /* CONFIG_PAGE_OWNER */
> +
> +
>   /* The really slow allocator path where we enter direct reclaim */
>   static inline struct page *
>   __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
> @@ -2285,6 +2345,10 @@ retry:
>   		goto retry;
>   	}
>
> +#ifdef CONFIG_PAGE_OWNER
> +	if (page)
> +		set_page_owner(page, order, gfp_mask);
> +#endif
>   	return page;
>   }
>
> @@ -2593,6 +2657,10 @@ nopage:
>   	warn_alloc_failed(gfp_mask, order, NULL);
>   	return page;
>   got_pg:
> +#ifdef CONFIG_PAGE_OWNER
> +	if (page)
> +		set_page_owner(page, order, gfp_mask);
> +#endif
>   	if (kmemcheck_enabled)
>   		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
>
> @@ -2665,6 +2733,11 @@ out:
>   	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
>   		goto retry_cpuset;
>
> +#ifdef CONFIG_PAGE_OWNER
> +	if (page)
> +		set_page_owner(page, order, gfp_mask);
> +#endif
> +
>   	return page;
>   }
>   EXPORT_SYMBOL(__alloc_pages_nodemask);
> @@ -3869,6 +3942,9 @@ void __meminit memmap_init_zone(unsigned
>   		if (!is_highmem_idx(zone))
>   			set_page_address(page, __va(pfn << PAGE_SHIFT));
>   #endif
> +#ifdef CONFIG_PAGE_OWNER
> +		page->order = -1;
> +#endif
>   	}
>   }
>

Any reason you are using custom stack saving code instead of using the 
save_stack_trace API? (include/linux/stacktrace.h) . This is implemented 
on all architectures and takes care of special considerations for 
architectures such as ARM.

<snip>
> diff -puN mm/vmstat.c~pageowner mm/vmstat.c
> --- linux-2.6.git/mm/vmstat.c~pageowner	2012-12-04 20:06:36.803943465 -0500
> +++ linux-2.6.git-dave/mm/vmstat.c	2012-12-04 20:06:36.815943566 -0500
> @@ -19,6 +19,7 @@
>   #include <linux/math64.h>
>   #include <linux/writeback.h>
>   #include <linux/compaction.h>
> +#include "internal.h"
>
>   #ifdef CONFIG_VM_EVENT_COUNTERS
>   DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
> @@ -921,6 +922,97 @@ static int pagetypeinfo_showblockcount(s
>   	return 0;
>   }
>
> +#ifdef CONFIG_PAGE_OWNER
> +static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
> +							pg_data_t *pgdat,
> +							struct zone *zone)
> +{
> +	int mtype, pagetype;
> +	unsigned long pfn;
> +	unsigned long start_pfn = zone->zone_start_pfn;
> +	unsigned long end_pfn = start_pfn + zone->spanned_pages;
> +	unsigned long count[MIGRATE_TYPES] = { 0, };
> +
> +	/* Align PFNs to pageblock_nr_pages boundary */
> +	pfn = start_pfn & ~(pageblock_nr_pages-1);
> +
> +	/*
> +	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
> +	 * a zone boundary, it will be double counted between zones. This does
> +	 * not matter as the mixed block count will still be correct
> +	 */
> +	for (; pfn < end_pfn; pfn += pageblock_nr_pages) {
> +		struct page *page;
> +		unsigned long offset = 0;
> +
> +		/* Do not read before the zone start, use a valid page */
> +		if (pfn < start_pfn)
> +			offset = start_pfn - pfn;
> +
> +		if (!pfn_valid(pfn + offset))
> +			continue;
> +
> +		page = pfn_to_page(pfn + offset);
> +		mtype = get_pageblock_migratetype(page);
> +
> +		/* Check the block for bad migrate types */
> +		for (; offset < pageblock_nr_pages; offset++) {
> +			/* Do not past the end of the zone */
> +			if (pfn + offset >= end_pfn)
> +				break;
> +
> +			if (!pfn_valid_within(pfn + offset))
> +				continue;
> +
> +			page = pfn_to_page(pfn + offset);
> +
> +			/* Skip free pages */
> +			if (PageBuddy(page)) {
> +				offset += (1UL << page_order(page)) - 1UL;
> +				continue;
> +			}
> +			if (page->order < 0)
> +				continue;
> +
> +			pagetype = allocflags_to_migratetype(page->gfp_mask);
> +			if (pagetype != mtype) {
> +				count[mtype]++;
> +				break;
> +			}
> +
MIGRATE_CMA pages (with CONFIG_CMA) will always have pagetype != mtype 
so CMA pages will always show up here even though they are considered 
movable pages. That's probably not what you want here.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
