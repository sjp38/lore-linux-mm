Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B87EC9000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 09:17:55 -0400 (EDT)
Received: by ewy22 with SMTP id 22so1380955ewy.9
        for <linux-mm@kvack.org>; Wed, 21 Sep 2011 06:17:53 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 2/8] mm: alloc_contig_freed_pages() added
References: <1313764064-9747-1-git-send-email-m.szyprowski@samsung.com>
 <1313764064-9747-3-git-send-email-m.szyprowski@samsung.com>
 <1315505152.3114.9.camel@nimitz>
Date: Wed, 21 Sep 2011 15:17:50 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v15tv0183l0zgt@mnazarewicz-glaptop>
In-Reply-To: <1315505152.3114.9.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd
 Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan
 Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Thu, 08 Sep 2011 20:05:52 +0200, Dave Hansen <dave@linux.vnet.ibm.com>  
wrote:

> On Fri, 2011-08-19 at 16:27 +0200, Marek Szyprowski wrote:
>> +unsigned long alloc_contig_freed_pages(unsigned long start, unsigned  
>> long end,
>> +				       gfp_t flag)
>> +{
>> +	unsigned long pfn = start, count;
>> +	struct page *page;
>> +	struct zone *zone;
>> +	int order;
>> +
>> +	VM_BUG_ON(!pfn_valid(start));
>> +	zone = page_zone(pfn_to_page(start));
>
> This implies that start->end are entirely contained in a single zone.
> What enforces that?

In case of CMA, the __cma_activate_area() function from 6/8 has the check:

  151                         VM_BUG_ON(!pfn_valid(pfn));
  152                         VM_BUG_ON(page_zone(pfn_to_page(pfn)) !=  
zone);

This guarantees that CMA will never try to call alloc_contig_freed_pages()
on a region that spans multiple regions.

> If some higher layer enforces that, I think we probably need at least
> a VM_BUG_ON() in here and a comment about who enforces it.

Agreed.

>> +	spin_lock_irq(&zone->lock);
>> +
>> +	page = pfn_to_page(pfn);
>> +	for (;;) {
>> +		VM_BUG_ON(page_count(page) || !PageBuddy(page));
>> +		list_del(&page->lru);
>> +		order = page_order(page);
>> +		zone->free_area[order].nr_free--;
>> +		rmv_page_order(page);
>> +		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
>> +		pfn  += 1 << order;
>> +		if (pfn >= end)
>> +			break;
>> +		VM_BUG_ON(!pfn_valid(pfn));
>> +		page += 1 << order;
>> +	}

> This 'struct page *'++ stuff is OK, but only for small, aligned areas.
> For at least some of the sparsemem modes (non-VMEMMAP), you could walk
> off of the end of the section_mem_map[] when you cross a MAX_ORDER
> boundary.  I'd feel a little bit more comfortable if pfn_to_page() was
> being done each time, or only occasionally when you cross a section
> boundary.

I'm fine with that.  I've used pointer arithmetic for performance reasons
but if that may potentially lead to bugs then obviously pfn_to_page()  
should
be used.

-- 
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
