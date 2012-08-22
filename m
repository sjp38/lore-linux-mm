Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id DEBEF6B006C
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 04:31:05 -0400 (EDT)
Message-ID: <50349891.7020809@huawei.com>
Date: Wed, 22 Aug 2012 16:30:09 +0800
From: Jiang Liu <jiang.liu@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: fix a drain pcp bug when offline pages
References: <50337B15.2090701@gmail.com> <20120822033441.GB24667@bbox> <503490F9.2050805@gmail.com> <20120822081410.GA5369@bbox>
In-Reply-To: <20120822081410.GA5369@bbox>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: qiuxishi <qiuxishi@gmail.com>, akpm@linux-foundation.org, lliubbo@gmail.com, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi@huawei.com, wujianguo@huawei.com, bessel.wang@huawei.com, guohanjun@huawei.com, chenkeping@huawei.com, yinghai@kernel.org, wency@cn.fujitsu.com

On 2012-8-22 16:14, Minchan Kim wrote:
> On Wed, Aug 22, 2012 at 03:57:45PM +0800, qiuxishi wrote:
>> On 2012-8-22 11:34, Minchan Kim wrote:
>>> Hello Xishi,
>>>
>>> On Tue, Aug 21, 2012 at 08:12:05PM +0800, qiuxishi wrote:
>>>> From: Xishi Qiu <qiuxishi@huawei.com>
>>>>
>>>> When offline a section, we move all the free pages and pcp into MIGRATE_ISOLATE list first.
>>>> start_isolate_page_range()
>>>> 	set_migratetype_isolate()
>>>> 		drain_all_pages(),
>>>>
>>>> Here is a problem, it is not sure that pcp will be moved into MIGRATE_ISOLATE list. They may
>>>> be moved into MIGRATE_MOVABLE list because page_private() maybe 2. So when finish migrating
>>>> pages, the free pages from pcp may be allocated again, and faild in check_pages_isolated().
>>>> drain_all_pages()
>>>> 	drain_local_pages()
>>>> 		drain_pages()
>>>> 			free_pcppages_bulk()
>>>> 				__free_one_page(page, zone, 0, page_private(page));
>>>>
>>>> If we add move_freepages_block() after drain_all_pages(), it can not sure that all the pcp
>>>> will be moved into MIGRATE_ISOLATE list when the system works on high load. The free pages
>>>> which from pcp may immediately be allocated again.
>>>>
>>>> I think the similar bug described in http://marc.info/?t=134250882300003&r=1&w=2
>>>
>>> Yes. I reported the problem a few month ago but it's not real bug in practice
>>> but found by my eyes during looking the code so I wanted to confirm the problem.
>>>
>>> Do you find that problem in real practice? or just code review?
>>>
>>
>> I use /sys/devices/system/memory/soft_offline_page to offline a lot of pages when the
>> system works on high load, then I find some unknown zero refcount pages, such as
>> get_any_page: 0x650422: unknown zero refcount page type 19400c00000000
>> get_any_page: 0x650867: unknown zero refcount page type 19400c00000000
>>
>> soft_offline_page()
>> 	get_any_page()
>> 		set_migratetype_isolate()
>> 			drain_all_pages()
>>
>> I think after drain_all_pages(), pcp are moved into MIGRATE_MOVABLE list which managed by
>> buddy allocator, but they are allocated and becaome pcp again as the system works on high
>> load. There will be no this problem by applying this patch.
>>
>>> Anyway, I don't like your approach which I already considered because it hurts hotpath
>>> while the race is really unlikely. Get_pageblock_migratetype is never trivial.
>>> We should avoid the overhead in hotpath and move into memory-hotplug itself.
>>> Do you see my patch in https://patchwork.kernel.org/patch/1225081/ ?
>>
>> Yes, you are right, I will try to find another way to fix this problem.
>> How about doing this work in set_migratetype_isolate(), find the pcp and change the value
>> of private to get_pageblock_migratetype(page)?
>>
> 
> Allocator doesn't have any lock when he allocates the page from pcp.
> How could you prevent race between allocator and memory-hotplug
> routine(ie, set_migratetype_isolate) without hurting hotpath?
Hi Minchan,
	I have thought about using a jump label in the hot path, which won't cause big
performance drop, but it seems a little dirty. What's your thoughts?

	migrate_type = page_private(page);
	if (static_key_false(&memory_hotplug_inprogress))
		migrate_type = get_pageblock_migratetype(page);
	__free_one_page(page, zone, 0, migrate_type);

	Regards!
	Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
