Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id ADA2E6B005A
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 10:40:48 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1258183pad.14
        for <linux-mm@kvack.org>; Thu, 15 Nov 2012 07:40:48 -0800 (PST)
Message-ID: <50A50CF8.9040207@gmail.com>
Date: Thu, 15 Nov 2012 23:40:40 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix a regression with HIGHMEM introduced by changeset
 7f1290f2f2a4d
References: <1352165517-9732-1-git-send-email-jiang.liu@huawei.com> <20121106124315.79deb2bc.akpm@linux-foundation.org> <50A3B013.4030207@gmail.com> <50A4B45D.5000905@cn.fujitsu.com>
In-Reply-To: <50A4B45D.5000905@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Jianguo Wu <wujianguo@huawei.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daniel Vetter <daniel.vetter@ffwll.ch>

On 11/15/2012 05:22 PM, Wen Congyang wrote:
> Hi, Liu Jiang
> 
> At 11/14/2012 10:52 PM, Jiang Liu Wrote:
>> On 11/07/2012 04:43 AM, Andrew Morton wrote:
>>> On Tue, 6 Nov 2012 09:31:57 +0800
>>> Jiang Liu <jiang.liu@huawei.com> wrote:
>>>
>>>> Changeset 7f1290f2f2 tries to fix a issue when calculating
>>>> zone->present_pages, but it causes a regression to 32bit systems with
>>>> HIGHMEM. With that changeset, function reset_zone_present_pages()
>>>> resets all zone->present_pages to zero, and fixup_zone_present_pages()
>>>> is called to recalculate zone->present_pages when boot allocator frees
>>>> core memory pages into buddy allocator. Because highmem pages are not
>>>> freed by bootmem allocator, all highmem zones' present_pages becomes
>>>> zero.
>>>>
>>>> Actually there's no need to recalculate present_pages for highmem zone
>>>> because bootmem allocator never allocates pages from them. So fix the
>>>> regression by skipping highmem in function reset_zone_present_pages()
>>>> and fixup_zone_present_pages().
>>>>
>>>> ...
>>>>
>>>> --- a/mm/page_alloc.c
>>>> +++ b/mm/page_alloc.c
>>>> @@ -6108,7 +6108,8 @@ void reset_zone_present_pages(void)
>>>>  	for_each_node_state(nid, N_HIGH_MEMORY) {
>>>>  		for (i = 0; i < MAX_NR_ZONES; i++) {
>>>>  			z = NODE_DATA(nid)->node_zones + i;
>>>> -			z->present_pages = 0;
>>>> +			if (!is_highmem(z))
>>>> +				z->present_pages = 0;
>>>>  		}
>>>>  	}
>>>>  }
>>>> @@ -6123,10 +6124,11 @@ void fixup_zone_present_pages(int nid, unsigned long start_pfn,
>>>>  
>>>>  	for (i = 0; i < MAX_NR_ZONES; i++) {
>>>>  		z = NODE_DATA(nid)->node_zones + i;
>>>> +		if (is_highmem(z))
>>>> +			continue;
>>>> +
>>>>  		zone_start_pfn = z->zone_start_pfn;
>>>>  		zone_end_pfn = zone_start_pfn + z->spanned_pages;
>>>> -
>>>> -		/* if the two regions intersect */
>>>>  		if (!(zone_start_pfn >= end_pfn	|| zone_end_pfn <= start_pfn))
>>>>  			z->present_pages += min(end_pfn, zone_end_pfn) -
>>>>  					    max(start_pfn, zone_start_pfn);
>>>
>>> This ...  isn't very nice.  It is embeds within
>>> reset_zone_present_pages() and fixup_zone_present_pages() knowledge
>>> about their caller's state.  Or, more specifically, it is emebedding
>>> knowledge about the overall state of the system when these functions
>>> are called.
>>>
>>> I mean, a function called "reset_zone_present_pages" should reset
>>> ->present_pages!
>>>
>>> The fact that fixup_zone_present_page() has multiple call sites makes
>>> this all even more risky.  And what are the interactions between this
>>> and memory hotplug?
>>>
>>> Can we find a cleaner fix?
>>>
>>> Please tell us more about what's happening here.  Is it the case that
>>> reset_zone_present_pages() is being called *after* highmem has been
>>> populated?  If so, then fixup_zone_present_pages() should work
>>> correctly for highmem?  Or is it the case that highmem hasn't yet been
>>> setup?  IOW, what is the sequence of operations here?
>>>
>>> Is the problem that we're *missing* a call to
>>> fixup_zone_present_pages(), perhaps?  If we call
>>> fixup_zone_present_pages() after highmem has been populated,
>>> fixup_zone_present_pages() should correctly fill in the highmem zone's
>>> ->present_pages?
>> Hi Andrew,
>> 	Sorry for the late response:(
>> 	I have done more investigations according to your suggestions. Currently
>> we have only called fixup_zone_present_pages() for memory freed by bootmem
>> allocator and missed HIGHMEM pages. We could also call fixup_zone_present_pages()
>> for HIGHMEM pages, but that will need to change arch specific code for x86, powerpc,
>> sparc, microblaze, arm, mips, um and tile etc. Seems a little overhead.
>> 	And sadly enough, I found the quick fix is still incomplete. The original
>> patch still have another issue that, reset_zone_present_pages() is only called
>> for IA64, so it will cause trouble for other arches which make use of "bootmem.c".
>> 	Then I feel a little guilty and tried to find a cleaner solution without
>> touching arch specific code. But things are more complex than my expectation and
>> I'm still working on that.
>> 	So how about totally reverting the changeset 7f1290f2f2a4d2c3f1b7ce8e87256e052ca23125
>> and I will post another version once I found a cleaner way?
> 
> I think fixup_zone_present_pages() are very useful for memory hotplug.
> 
> We calculate zone->present_pages in free_area_init_core(), but its value is wrong.
> So it is why we fix it in fixup_zone_present_pages().
> 
> What about this:
> 1. init zone->present_pages to the present pages in this zone(include bootmem)
> 2. don't reset zone->present_pages for HIGHMEM pages
> 
> We don't allocate bootmem from HIGHMEM. So its present pages is inited in step1
> and there is no need to fix it in step2.
Hi Congyang,

I feel that zone->present_pages has been abused. I guess it means "physical pages 
present in this zone" originally, but now sometimes zone->present_pages is used as
"pages in this zone managed by the buddy system". So I'm trying to add a new
field "managed_pages" into zone, which accounts for pages managed by buddy system.
That's why I thought the clean solution is a little complex:(

Why do we need "managed_pages"? With HIGHMEM enabled, there may be bigger difference
between "present_pages" and "managed_pages" on ZONE_NORMAL because it also hosts
page array for ZONE_HIGHMEM. That may cause disturbance to page allocator or scanner.

What's your thoughts?

Thanks
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
