Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 566766B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 10:56:58 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id ro8so6176256pbb.18
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 07:56:57 -0800 (PST)
Message-ID: <5137673F.4030801@gmail.com>
Date: Wed, 06 Mar 2013 23:56:47 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v1 22/33] mm/SPARC: use common help functions to free
 reserved pages
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com> <1362495317-32682-23-git-send-email-jiang.liu@huawei.com> <20130305195845.GB12225@merkur.ravnborg.org>
In-Reply-To: <20130305195845.GB12225@merkur.ravnborg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>

Hi Sam,
	Thanks for review!

On 03/06/2013 03:58 AM, Sam Ravnborg wrote:
> On Tue, Mar 05, 2013 at 10:55:05PM +0800, Jiang Liu wrote:
>> Use common help functions to free reserved pages.
> 
> I like how this simplify things!
> 
> Please consider how you can also cover the HIGHMEM case,
> so map_high_region(...) is simplified too (in init_32.c).
> 
>>
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Sam Ravnborg <sam@ravnborg.org>
>> ---
>>  arch/sparc/kernel/leon_smp.c |   15 +++------------
>>  arch/sparc/mm/init_32.c      |   40 ++++++----------------------------------
>>  arch/sparc/mm/init_64.c      |   25 ++++---------------------
>>  3 files changed, 13 insertions(+), 67 deletions(-)
>>
>> diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
>> index 48e0c03..2a7b6eb 100644
>> --- a/arch/sparc/mm/init_32.c
>> +++ b/arch/sparc/mm/init_32.c
>> @@ -374,45 +374,17 @@ void __init mem_init(void)
>>  
>>  void free_initmem (void)
>>  {
>> -	unsigned long addr;
>> -	unsigned long freed;
>> -
>> -	addr = (unsigned long)(&__init_begin);
>> -	freed = (unsigned long)(&__init_end) - addr;
>> -	for (; addr < (unsigned long)(&__init_end); addr += PAGE_SIZE) {
>> -		struct page *p;
>> -
>> -		memset((void *)addr, POISON_FREE_INITMEM, PAGE_SIZE);
>> -		p = virt_to_page(addr);
>> -
>> -		ClearPageReserved(p);
>> -		init_page_count(p);
>> -		__free_page(p);
>> -		totalram_pages++;
>> -		num_physpages++;
>> -	}
>> -	printk(KERN_INFO "Freeing unused kernel memory: %ldk freed\n",
>> -		freed >> 10);
>> +	num_physpages += free_reserved_area((unsigned long)(&__init_begin),
>> +					    (unsigned long)(&__init_end),
>> +					    POISON_FREE_INITMEM,
>> +					    "unused kernel");
> If you change free_initmem_default(...) to return number of pages freed this
> could have been used here.
Good suggestion, will make that change.

> 
>>  }
>>  
>>  #ifdef CONFIG_BLK_DEV_INITRD
>>  void free_initrd_mem(unsigned long start, unsigned long end)
>>  {
>> -	if (start < end)
>> -		printk(KERN_INFO "Freeing initrd memory: %ldk freed\n",
>> -			(end - start) >> 10);
>> -	for (; start < end; start += PAGE_SIZE) {
>> -		struct page *p;
>> -
>> -		memset((void *)start, POISON_FREE_INITMEM, PAGE_SIZE);
>> -		p = virt_to_page(start);
>> -
>> -		ClearPageReserved(p);
>> -		init_page_count(p);
>> -		__free_page(p);
>> -		totalram_pages++;
>> -		num_physpages++;
>> -	}
>> +	num_physpages += free_reserved_area(start, end, POISON_FREE_INITMEM,
>> +					    "initrd");
>>  }
>>  #endif
>>  
>> diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
>> index 1588d33..03bfd10 100644
>> --- a/arch/sparc/mm/init_64.c
>> +++ b/arch/sparc/mm/init_64.c
>> @@ -2060,8 +2060,7 @@ void __init mem_init(void)
>>  	/* We subtract one to account for the mem_map_zero page
>>  	 * allocated below.
>>  	 */
>> -	totalram_pages -= 1;
>> -	num_physpages = totalram_pages;
>> +	num_physpages = totalram_pages - 1;
>>  
>>  	/*
>>  	 * Set up the zero page, mark it reserved, so that page count
>> @@ -2072,7 +2071,7 @@ void __init mem_init(void)
>>  		prom_printf("paging_init: Cannot alloc zero page.\n");
>>  		prom_halt();
>>  	}
>> -	SetPageReserved(mem_map_zero);
>> +	mark_page_reserved(mem_map_zero);
>>  
>>  	codepages = (((unsigned long) _etext) - ((unsigned long) _start));
>>  	codepages = PAGE_ALIGN(codepages) >> PAGE_SHIFT;
>> @@ -2112,7 +2111,6 @@ void free_initmem(void)
>>  	initend = (unsigned long)(__init_end) & PAGE_MASK;
>>  	for (; addr < initend; addr += PAGE_SIZE) {
>>  		unsigned long page;
>> -		struct page *p;
>>  
>>  		page = (addr +
>>  			((unsigned long) __va(kern_base)) -
>> @@ -2120,13 +2118,8 @@ void free_initmem(void)
>>  		memset((void *)addr, POISON_FREE_INITMEM, PAGE_SIZE);
>>  
>>  		if (do_free) {
>> -			p = virt_to_page(page);
>> -
>> -			ClearPageReserved(p);
>> -			init_page_count(p);
>> -			__free_page(p);
>> +			free_reserved_page(virt_to_page(page));
>>  			num_physpages++;
>> -			totalram_pages++;
>>  		}
>>  	}
>>  }
>> @@ -2134,17 +2127,7 @@ void free_initmem(void)
>>  #ifdef CONFIG_BLK_DEV_INITRD
>>  void free_initrd_mem(unsigned long start, unsigned long end)
>>  {
>> -	if (start < end)
>> -		printk ("Freeing initrd memory: %ldk freed\n", (end - start) >> 10);
>> -	for (; start < end; start += PAGE_SIZE) {
>> -		struct page *p = virt_to_page(start);
>> -
>> -		ClearPageReserved(p);
>> -		init_page_count(p);
>> -		__free_page(p);
>> -		num_physpages++;
>> -		totalram_pages++;
>> -	}
>> +	num_physpages += free_reserved_area(start, end, 0, "initrd");
> 
> Please add poison POISON_FREE_INITMEM here. I know this was not done before.
Sure, will make it.

> 
> 	Sam
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
