Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 8C9506B00B1
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 22:57:38 -0400 (EDT)
Date: Thu, 6 Sep 2012 11:59:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/3] memory-hotplug: bug fix race between isolation and
 allocation
Message-ID: <20120906025912.GE31615@bbox>
References: <50480BFB.8050501@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50480BFB.8050501@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qiuxishi <qiuxishi@gmail.com>
Cc: mgorman@suse.de, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, qiuxishi@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Xishi,

On Thu, Sep 06, 2012 at 10:35:39AM +0800, qiuxishi wrote:
> On 2012/9/5 17:40, Mel Gorman wrote:
> 
> > On Wed, Sep 05, 2012 at 04:26:02PM +0900, Minchan Kim wrote:
> >> Like below, memory-hotplug makes race between page-isolation
> >> and page-allocation so it can hit BUG_ON in __offline_isolated_pages.
> >>
> >> 	CPU A					CPU B
> >>
> >> start_isolate_page_range
> >> set_migratetype_isolate
> >> spin_lock_irqsave(zone->lock)
> >>
> >> 				free_hot_cold_page(Page A)
> >> 				/* without zone->lock */
> >> 				migratetype = get_pageblock_migratetype(Page A);
> >> 				/*
> >> 				 * Page could be moved into MIGRATE_MOVABLE
> >> 				 * of per_cpu_pages
> >> 				 */
> >> 				list_add_tail(&page->lru, &pcp->lists[migratetype]);
> >>
> >> set_pageblock_isolate
> >> move_freepages_block
> >> drain_all_pages
> 
> I think here is the problem you want to fix, it is not sure that pcp will be moved
> into MIGRATE_ISOLATE list. They may be moved into MIGRATE_MOVABLE list because
> page_private() maybe 2, it uses page_private() not get_pageblock_migratetype()
> 
> So when finish migrating pages, the free pages from pcp may be allocated again, and
> failed in check_pages_isolated().
> 
> drain_all_pages()
> 	drain_local_pages()
> 		drain_pages()
> 			free_pcppages_bulk()
> 				__free_one_page(page, zone, 0, page_private(page))
> 
> I reported this problem too. http://marc.info/?l=linux-mm&m=134555113706068&w=2
> How about this change:
> 	free_pcppages_bulk()
> 		__free_one_page(page, zone, 0, get_pageblock_migratetype(page))

I already explained why it was not good solution.
Again, here it goes from my previous reply.

"
Anyway, I don't like your approach which I already considered because it hurts hotpath
while the race is really unlikely. Get_pageblock_migratetype is never trivial.
We should avoid the overhead in hotpath and move into memory-hotplug itself.
Do you see my patch in https://patchwork.kernel.org/patch/1225081/ ?
"

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
