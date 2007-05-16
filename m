Date: Wed, 16 May 2007 11:33:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/8] Review-based updates to grouping pages by mobility
Message-Id: <20070516113314.65f442a2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007 16:03:11 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:

> Hi Christoph,
> 
> The following patches address points brought up by your review of the
> grouping pages by mobility patches. There are quite a number of patches here.
> 
May I have a question ?
Not about this patch but about 2.6.21-mm2.

In free_hot_cold_page()

==
static void fastcall free_hot_cold_page(struct page *page, int cold)
{
        struct zone *zone = page_zone(page);
        struct per_cpu_pages *pcp;
        unsigned long flags;
<snip>
	set_page_private(page, get_pageblock_migratetype(page));
        pcp->count++;
        if (pcp->count >= pcp->high) {
                free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
                pcp->count -= pcp->batch;
        }

==

get_pageblock_migratetype(page) is called without zone->lock.

Is this safe ? or should we add seqlock(or something) to access
migrate type bitmap ?

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
