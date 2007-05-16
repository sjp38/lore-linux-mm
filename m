Date: Wed, 16 May 2007 09:58:16 +0100 (IST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/8] Review-based updates to grouping pages by mobility
In-Reply-To: <20070516113314.65f442a2.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705160951490.7139@skynet.skynet.ie>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
 <20070516113314.65f442a2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2007, KAMEZAWA Hiroyuki wrote:

> On Tue, 15 May 2007 16:03:11 +0100 (IST)
> Mel Gorman <mel@csn.ul.ie> wrote:
>
>> Hi Christoph,
>>
>> The following patches address points brought up by your review of the
>> grouping pages by mobility patches. There are quite a number of patches here.
>>
> May I have a question ?
> Not about this patch but about 2.6.21-mm2.
>
> In free_hot_cold_page()
>
> ==
> static void fastcall free_hot_cold_page(struct page *page, int cold)
> {
>        struct zone *zone = page_zone(page);
>        struct per_cpu_pages *pcp;
>        unsigned long flags;
> <snip>
> 	set_page_private(page, get_pageblock_migratetype(page));
>        pcp->count++;
>        if (pcp->count >= pcp->high) {
>                free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
>                pcp->count -= pcp->batch;
>        }
>
> ==
>
> get_pageblock_migratetype(page) is called without zone->lock.
>

Indeed, this is the per-cpu allocator so acquiring a lock defeats the 
point.

> Is this safe ? or should we add seqlock(or something) to access
> migrate type bitmap ?
>

It's safe.

At worst, the pcp free calls get_pageblock_migratetype() and gets the 
wrong migrate type. For that to happen, it means that an allocator under 
lock has "stolen" the block already contains pages of a mixed type. As the 
block is already mixed, the situation has not gotten any worse.

If the pcp page gets a migrate type > MIGRATE_TYPE, it will remain on the 
pcp lists until a batch free occurs in which case it will call 
get_pageblock_migratetype() again under the zone->lock this time, get the 
right type and be freed.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
