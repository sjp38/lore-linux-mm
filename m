Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D91406B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 15:03:39 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id k38so3126712wre.23
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 12:03:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 4si501130wrj.71.2018.02.08.12.03.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 12:03:38 -0800 (PST)
Date: Thu, 8 Feb 2018 12:03:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/1] mm: initialize pages on demand during boot
Message-Id: <20180208120334.0779ed0726bb527a9cad0336@linux-foundation.org>
In-Reply-To: <20180208184555.5855-2-pasha.tatashin@oracle.com>
References: <20180208184555.5855-1-pasha.tatashin@oracle.com>
	<20180208184555.5855-2-pasha.tatashin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, m.mizuma@jp.fujitsu.com, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu,  8 Feb 2018 13:45:55 -0500 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> Deferred page initialization allows the boot cpu to initialize a small
> subset of the system's pages early in boot, with other cpus doing the rest
> later on.
> 
> It is, however, problematic to know how many pages the kernel needs during
> boot.  Different modules and kernel parameters may change the requirement,
> so the boot cpu either initializes too many pages or runs out of memory.
> 
> To fix that, initialize early pages on demand.  This ensures the kernel
> does the minimum amount of work to initialize pages during boot and leaves
> the rest to be divided in the multithreaded initialization path
> (deferred_init_memmap).
> 
> The on-demand code is permanently disabled using static branching once
> deferred pages are initialized.  After the static branch is changed to
> false, the overhead is up-to two branch-always instructions if the zone
> watermark check fails or if rmqueue fails.
>
> ...
>
> @@ -1604,6 +1566,96 @@ static int __init deferred_init_memmap(void *data)
>  	pgdat_init_report_one_done();
>  	return 0;
>  }
> +
> +/*
> + * Protects some early interrupt threads, and also for a short period of time
> + * from  smp_init() to page_alloc_init_late() when deferred pages are
> + * initialized.
> + */
> +static __initdata DEFINE_SPINLOCK(deferred_zone_grow_lock);

Comment is a little confusing.  Locks don't protect "threads" - they
protect data.  Can we be specific about which data is being protected?

Why is a new lock needed here?  Those data structures already have
designated locks, don't they?

If the lock protects "early interrupt threads" then it's surprising to
see it taken with spin_lock() and not spin_lock_irqsave()?

> +DEFINE_STATIC_KEY_TRUE(deferred_pages);
> +
> +/*
> + * If this zone has deferred pages, try to grow it by initializing enough
> + * deferred pages to satisfy the allocation specified by order, rounded up to
> + * the nearest PAGES_PER_SECTION boundary.  So we're adding memory in increments
> + * of SECTION_SIZE bytes by initializing struct pages in increments of
> + * PAGES_PER_SECTION * sizeof(struct page) bytes.
> + */

Please also document the return value.

> +static noinline bool __init

Why was noinline needed?

> +deferred_grow_zone(struct zone *zone, unsigned int order)
> +{
> +	int zid = zone_idx(zone);
> +	int nid = zone->node;
> +	pg_data_t *pgdat = NODE_DATA(nid);
> +	unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
> +	unsigned long nr_pages = 0;
> +	unsigned long first_init_pfn, first_deferred_pfn, spfn, epfn, t;
> +	phys_addr_t spa, epa;
> +	u64 i;
> +
> +	/* Only the last zone may have deferred pages */
> +	if (zone_end_pfn(zone) != pgdat_end_pfn(pgdat))
> +		return false;
> +
> +	first_deferred_pfn = READ_ONCE(pgdat->first_deferred_pfn);

It would be nice to have a little comment explaining why READ_ONCE was
needed.

Would it still be needed if this code was moved into the locked region?

> +	first_init_pfn = max(zone->zone_start_pfn, first_deferred_pfn);
> +
> +	if (first_init_pfn >= pgdat_end_pfn(pgdat))
> +		return false;
> +
> +	spin_lock(&deferred_zone_grow_lock);
> +	/*
> +	 * Bail if we raced with another thread that disabled on demand
> +	 * initialization.
> +	 */
> +	if (!static_branch_unlikely(&deferred_pages)) {
> +		spin_unlock(&deferred_zone_grow_lock);
> +		return false;
> +	}
> +
> +	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
> +		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
> +		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
> +
> +		while (spfn < epfn && nr_pages < nr_pages_needed) {
> +			t = ALIGN(spfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
> +			first_deferred_pfn = min(t, epfn);
> +			nr_pages += deferred_init_pages(nid, zid, spfn,
> +							first_deferred_pfn);
> +			spfn = first_deferred_pfn;
> +		}
> +
> +		if (nr_pages >= nr_pages_needed)
> +			break;
> +	}
> +
> +	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
> +		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
> +		epfn = min_t(unsigned long, first_deferred_pfn, PFN_DOWN(epa));
> +		deferred_free_pages(nid, zid, spfn, epfn);
> +
> +		if (first_deferred_pfn == epfn)
> +			break;
> +	}
> +	WRITE_ONCE(pgdat->first_deferred_pfn, first_deferred_pfn);
> +	spin_unlock(&deferred_zone_grow_lock);
> +
> +	return nr_pages >= nr_pages_needed;
> +}
> +
> +/*
> + * deferred_grow_zone() is __init, but it is called from
> + * get_page_from_freelist() during early boot until deferred_pages permanently
> + * disables this call. This is why, we have refdata wrapper to avoid warning,
> + * and ensure that the function body gets unloaded.

s/why,/why/
s/ensure/to ensure/

> + */
> +static bool __ref
> +_deferred_grow_zone(struct zone *zone, unsigned int order)
> +{
> +	return deferred_grow_zone(zone, order);
> +}
> +
>  #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
>  
>  void __init page_alloc_init_late(void)
> @@ -1613,6 +1665,14 @@ void __init page_alloc_init_late(void)
>  #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>  	int nid;
>  
> +	/*
> +	 * We are about to initialize the rest of deferred pages, permanently
> +	 * disable on-demand struct page initialization.
> +	 */
> +	spin_lock(&deferred_zone_grow_lock);
> +	static_branch_disable(&deferred_pages);
> +	spin_unlock(&deferred_zone_grow_lock);

Ah, so the new lock is to protect the static branch machinery only?

>  	/* There will be num_node_state(N_MEMORY) threads */
>  	atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
>  	for_each_node_state(nid, N_MEMORY) {
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
