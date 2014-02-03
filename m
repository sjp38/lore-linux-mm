Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3CD6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 02:45:10 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so6526781pde.21
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 23:45:10 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ek3si19520102pbd.115.2014.02.02.23.45.08
        for <linux-mm@kvack.org>;
        Sun, 02 Feb 2014 23:45:09 -0800 (PST)
Date: Mon, 3 Feb 2014 16:45:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/7] improve robustness on handling migratetype
Message-ID: <20140203074507.GB2360@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140109092720.GM27046@suse.de>
 <20140110084854.GA22058@lge.com>
 <52E931D9.8050002@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52E931D9.8050002@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 29, 2014 at 05:52:41PM +0100, Vlastimil Babka wrote:
> On 01/10/2014 09:48 AM, Joonsoo Kim wrote:
> >On Thu, Jan 09, 2014 at 09:27:20AM +0000, Mel Gorman wrote:
> >>On Thu, Jan 09, 2014 at 04:04:40PM +0900, Joonsoo Kim wrote:
> >>>Hello,
> >>>
> >>>I found some weaknesses on handling migratetype during code review and
> >>>testing CMA.
> >>>
> >>>First, we don't have any synchronization method on get/set pageblock
> >>>migratetype. When we change migratetype, we hold the zone lock. So
> >>>writer-writer race doesn't exist. But while someone changes migratetype,
> >>>others can get migratetype. This may introduce totally unintended value
> >>>as migratetype. Although I haven't heard of any problem report about
> >>>that, it is better to protect properly.
> >>>
> >>
> >>This is deliberate. The migratetypes for the majority of users are advisory
> >>and aimed for fragmentation avoidance. It was important that the cost of
> >>that be kept as low as possible and the general case is that migration types
> >>change very rarely. In many cases, the zone lock is held. In other cases,
> >>such as splitting free pages, the cost is simply not justified.
> >>
> >>I doubt there is any amount of data you could add in support that would
> >>justify hammering the free fast paths (which call get_pageblock_type).
> >
> >Hello, Mel.
> >
> >There is a possibility that we can get unintended value such as 6 as migratetype
> >if reader-writer (get/set pageblock_migratetype) race happends. It can be
> >possible, because we read the value without any synchronization method. And
> >this migratetype, 6, has no place in buddy freelist, so array index overrun can
> >be possible and the system can break, although I haven't heard that it occurs.
> 
> Hello,
> 
> it seems this can indeed happen. I'm working on memory compaction
> improvements and in a prototype patch, I'm basically adding calls of
> start_isolate_page_range() undo_isolate_page_range() some functions
> under compact_zone(). With this I've seen occurrences of NULL
> pointers in move_freepages(), free_one_page() in places where
> free_list[migratetype] is manipulated by e.g. list_move(). That lead
> me to question the value of migratetype and I found this thread.
> Adding some debugging in get_pageblock_migratetype() and voila, I
> get a value of 6 being read.
> 
> So is it just my patch adding a dangerous situation, or does it exist in
> mainline as well? By looking at free_one_page(), it uses zone->lock, but
> get_pageblock_migratetype() is called by its callers
> (free_hot_cold_page() or __free_pages_ok()) outside of the lock.
> This determined migratetype is then used under free_one_page() to
> access a free_list.
> 
> It seems that this could race with set_pageblock_migratetype()
> called from try_to_steal_freepages() (despite the latter being
> properly locked). There are also other callers but those seem to be
> either limited to initialization and isolation, which should be rare
> (?).
> However, try_to_steal_freepages can occur repeatedly.
> So I assume that the race happens but never manifests as a fatal
> error as long as MIGRATE_UNMOVABLE, MIGRATE_RECLAIMABLE and
> MIGRATE_MOVABLE
> values are used. Only MIGRATE_CMA and MIGRATE_ISOLATE have values
> with bit 4 enabled and can thus result in invalid values due to
> non-atomic access.
> 
> Does that make sense to you and should we thus proceed with patching
> this race?
> 

Hello,

This race is possible without your prototype patch, however, on very low
probability. Some codes related to memory failure use set_migratetype_isolate()
which could result in this race.

Although it may be very rare case and not critical, it is better to fix
this race. I prefer that we don't depend on luck. :)

Mel's suggestion looks good to me. Do you have another idea?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
