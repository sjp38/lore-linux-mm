Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA57D6B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 17:28:00 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id 1so3523514uas.23
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 14:28:00 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id a189si349078vkh.328.2018.02.08.14.27.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 14:27:59 -0800 (PST)
Subject: Re: [PATCH v2 1/1] mm: initialize pages on demand during boot
References: <20180208184555.5855-1-pasha.tatashin@oracle.com>
 <20180208184555.5855-2-pasha.tatashin@oracle.com>
 <20180208120334.0779ed0726bb527a9cad0336@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Message-ID: <92cb25ed-cd60-f3fa-dde5-72aa8b839808@oracle.com>
Date: Thu, 8 Feb 2018 17:27:34 -0500
MIME-Version: 1.0
In-Reply-To: <20180208120334.0779ed0726bb527a9cad0336@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, m.mizuma@jp.fujitsu.com, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Andrew,

Thank you for your comments. My replies below:

>> +
>> +/*
>> + * Protects some early interrupt threads, and also for a short period of time
>> + * from  smp_init() to page_alloc_init_late() when deferred pages are
>> + * initialized.
>> + */
>> +static __initdata DEFINE_SPINLOCK(deferred_zone_grow_lock);
> 
> Comment is a little confusing.  Locks don't protect "threads" - they
> protect data.  Can we be specific about which data is being protected?

I will update the comment, explaining that this lock protects 
first_deferred_pfn in all zones. The lock is discarded after boot, hence 
it is in __initdata.

> 
> Why is a new lock needed here?  Those data structures already have
> designated locks, don't they?

No, there is no lock for this particular purpose. Before this commit, 
first_deferred_pfn was only updated early in boot before the boot thread 
can be preempted. And, only once after all pages are initialized to mark 
that there are no deferred pages anymore. With this commit, the number 
of deferred pages can change later in boot, this is why we need this new 
lock, but for a relatively short period of boot time.

> 
> If the lock protects "early interrupt threads" then it's surprising to
> see it taken with spin_lock() and not spin_lock_irqsave()?

Yes, I will update the code to use spin_lock_irqsave(), thank you.

> 
>> +DEFINE_STATIC_KEY_TRUE(deferred_pages);
>> +
>> +/*
>> + * If this zone has deferred pages, try to grow it by initializing enough
>> + * deferred pages to satisfy the allocation specified by order, rounded up to
>> + * the nearest PAGES_PER_SECTION boundary.  So we're adding memory in increments
>> + * of SECTION_SIZE bytes by initializing struct pages in increments of
>> + * PAGES_PER_SECTION * sizeof(struct page) bytes.
>> + */
> 
> Please also document the return value.
> 
>> +static noinline bool __init
> 
> Why was noinline needed?

To save space after boot. We want the body of this function to be 
unloaded after the boot when __init pages are unmapped, and we do not 
want this function to be inlined into : _deferred_grow_zone() which is 
__ref function.

> 
>> +deferred_grow_zone(struct zone *zone, unsigned int order)
>> +{
>> +	int zid = zone_idx(zone);
>> +	int nid = zone->node;
>> +	pg_data_t *pgdat = NODE_DATA(nid);
>> +	unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
>> +	unsigned long nr_pages = 0;
>> +	unsigned long first_init_pfn, first_deferred_pfn, spfn, epfn, t;
>> +	phys_addr_t spa, epa;
>> +	u64 i;
>> +
>> +	/* Only the last zone may have deferred pages */
>> +	if (zone_end_pfn(zone) != pgdat_end_pfn(pgdat))
>> +		return false;
>> +
>> +	first_deferred_pfn = READ_ONCE(pgdat->first_deferred_pfn);
> 
> It would be nice to have a little comment explaining why READ_ONCE was
> needed.
> 
> Would it still be needed if this code was moved into the locked region?

No, we would need to use READ_ONCE() if we grabbed 
deferred_zone_grow_lock before this code. In fact I do not even think we 
strictly need READ_ONCE() here, as it is a single load anyway. But, 
because we are outside of the lock, and we want to quickly fetch the 
data with a single load, I think it makes sense to emphasize it using 
READ_ONCE() without expected compiler to simply do the write thing for us.

> 
>> +	first_init_pfn = max(zone->zone_start_pfn, first_deferred_pfn);
>> +
>> +	if (first_init_pfn >= pgdat_end_pfn(pgdat))
>> +		return false;
>> +
>> +	spin_lock(&deferred_zone_grow_lock);
>> +	/*
>> +	 * Bail if we raced with another thread that disabled on demand
>> +	 * initialization.
>> +	 */
>> +	if (!static_branch_unlikely(&deferred_pages)) {
>> +		spin_unlock(&deferred_zone_grow_lock);
>> +		return false;
>> +	}
>> +
>> +	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
>> +		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
>> +		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
>> +
>> +		while (spfn < epfn && nr_pages < nr_pages_needed) {
>> +			t = ALIGN(spfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
>> +			first_deferred_pfn = min(t, epfn);
>> +			nr_pages += deferred_init_pages(nid, zid, spfn,
>> +							first_deferred_pfn);
>> +			spfn = first_deferred_pfn;
>> +		}
>> +
>> +		if (nr_pages >= nr_pages_needed)
>> +			break;
>> +	}
>> +
>> +	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
>> +		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
>> +		epfn = min_t(unsigned long, first_deferred_pfn, PFN_DOWN(epa));
>> +		deferred_free_pages(nid, zid, spfn, epfn);
>> +
>> +		if (first_deferred_pfn == epfn)
>> +			break;
>> +	}
>> +	WRITE_ONCE(pgdat->first_deferred_pfn, first_deferred_pfn);
>> +	spin_unlock(&deferred_zone_grow_lock);
>> +
>> +	return nr_pages >= nr_pages_needed;
>> +}
>> +
>> +/*
>> + * deferred_grow_zone() is __init, but it is called from
>> + * get_page_from_freelist() during early boot until deferred_pages permanently
>> + * disables this call. This is why, we have refdata wrapper to avoid warning,
>> + * and ensure that the function body gets unloaded.
> 
> s/why,/why/
> s/ensure/to ensure/

OK, thank you.

> 
>> + */
>> +static bool __ref
>> +_deferred_grow_zone(struct zone *zone, unsigned int order)
>> +{
>> +	return deferred_grow_zone(zone, order);
>> +}
>> +
>>   #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
>>   
>>   void __init page_alloc_init_late(void)
>> @@ -1613,6 +1665,14 @@ void __init page_alloc_init_late(void)
>>   #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>>   	int nid;
>>   
>> +	/*
>> +	 * We are about to initialize the rest of deferred pages, permanently
>> +	 * disable on-demand struct page initialization.
>> +	 */
>> +	spin_lock(&deferred_zone_grow_lock);
>> +	static_branch_disable(&deferred_pages);
>> +	spin_unlock(&deferred_zone_grow_lock);
> 
> Ah, so the new lock is to protect the static branch machinery only?

This lock is needed when several threads are trying to allocate memory 
simultaneously, and there is no enough pages in the zone to do so, but 
there are still deferred pages available.

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
