Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 923806B0035
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 20:56:29 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id ma3so1190053pbc.33
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 17:56:29 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id pu3si14161316pbc.240.2014.01.12.17.56.27
        for <linux-mm@kvack.org>;
        Sun, 12 Jan 2014 17:56:28 -0800 (PST)
Date: Mon, 13 Jan 2014 10:57:00 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/7] improve robustness on handling migratetype
Message-ID: <20140113015659.GA28140@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140109092720.GM27046@suse.de>
 <20140110084854.GA22058@lge.com>
 <20140110094834.GV27046@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140110094834.GV27046@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 10, 2014 at 09:48:34AM +0000, Mel Gorman wrote:
> On Fri, Jan 10, 2014 at 05:48:55PM +0900, Joonsoo Kim wrote:
> > On Thu, Jan 09, 2014 at 09:27:20AM +0000, Mel Gorman wrote:
> > > On Thu, Jan 09, 2014 at 04:04:40PM +0900, Joonsoo Kim wrote:
> > > > Hello,
> > > > 
> > > > I found some weaknesses on handling migratetype during code review and
> > > > testing CMA.
> > > > 
> > > > First, we don't have any synchronization method on get/set pageblock
> > > > migratetype. When we change migratetype, we hold the zone lock. So
> > > > writer-writer race doesn't exist. But while someone changes migratetype,
> > > > others can get migratetype. This may introduce totally unintended value
> > > > as migratetype. Although I haven't heard of any problem report about
> > > > that, it is better to protect properly.
> > > > 
> > > 
> > > This is deliberate. The migratetypes for the majority of users are advisory
> > > and aimed for fragmentation avoidance. It was important that the cost of
> > > that be kept as low as possible and the general case is that migration types
> > > change very rarely. In many cases, the zone lock is held. In other cases,
> > > such as splitting free pages, the cost is simply not justified.
> > > 
> > > I doubt there is any amount of data you could add in support that would
> > > justify hammering the free fast paths (which call get_pageblock_type).
> > 
> > Hello, Mel.
> > 
> > There is a possibility that we can get unintended value such as 6 as migratetype
> > if reader-writer (get/set pageblock_migratetype) race happends. It can be
> > possible, because we read the value without any synchronization method. And
> > this migratetype, 6, has no place in buddy freelist, so array index overrun can
> > be possible and the system can break, although I haven't heard that it occurs.
> > 
> > I think that my solution is too expensive. However, I think that we need
> > solution. aren't we? Do you have any better idea?
> > 
> 
> It's not something I have ever heard or seen of occurring but
> if you've identified that it's a real possibility then split
> get_pageblock_migratetype into locked and unlocked versions. Ensure
> that calls to set_pageblock_migratetype is always under zone->lock and
> get_pageblock_migratetype is also under zone->lock which both should be
> true in the majority of cases. Use the unlocked version otherwise but
> instead of synchronoing, check if it's returning >= MIGRATE_TYPES and
> return MIGRATE_MOVABLE in the unlikely event of a race. This will avoid
> harming the fast paths for the majority of users and limit the damage if
> a MIGRATE_CMA region is accidentally treated as MIGRATe_MOVABLE

Okay.
I will re-investigate it and if I have indentified that it's a real possiblity,
I will re-make this patch according to your advice.

Thanks for comment!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
