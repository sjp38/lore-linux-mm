Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 270CD6B009C
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 05:50:54 -0400 (EDT)
Date: Fri, 3 Sep 2010 11:50:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] Make is_mem_section_removable more conformable
 with offlining code
Message-ID: <20100903095049.GG10686@tiehlicka.suse.cz>
References: <20100902092454.GA17971@tiehlicka.suse.cz>
 <AANLkTi=cLzRGPCc3gCubtU7Ggws7yyAK5c7tp4iocv6u@mail.gmail.com>
 <20100902131855.GC10265@tiehlicka.suse.cz>
 <AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
 <20100902143939.GD10265@tiehlicka.suse.cz>
 <20100902150554.GE10265@tiehlicka.suse.cz>
 <20100903121003.e2b8993a.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903121452.2d22b3aa.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903082558.GC10686@tiehlicka.suse.cz>
 <20100903181327.7dad3f84.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100903181327.7dad3f84.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri 03-09-10 18:13:27, KAMEZAWA Hiroyuki wrote:
> On Fri, 3 Sep 2010 10:25:58 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Fri 03-09-10 12:14:52, KAMEZAWA Hiroyuki wrote:
> > [...]
[...]
> > Cannot ZONE_MOVABLE contain different MIGRATE_types?
> > 
> never.

Then I am terribly missing something. Zone contains free lists for
different MIGRATE_TYPES, doesn't it? Pages allocated from those free
lists keep the migration type of the list, right?

ZONE_MOVABLE just says whether it makes sense to move pages in that zone
at all, right?

> 
> > > +
> > > +	pfn = page_to_pfn(page);
> > > +	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
> > > +		unsigned long check = pfn + iter;
> > > +
> > > +		if (!pfn_valid_within(check)) {
> > > +			iter++;
> > > +			continue;
> > > +		}
> > > +		page = pfn_to_page(check);
> > > +		if (!page_count(page)) {
> > > +			if (PageBuddy(page))
> > 
> > Why do you check page_count as well? PageBuddy has alwyas count==0,
> > right?
> > 
> 
> But PageBuddy() flag is considered to be valid only when page_count()==0.
> This is for safe handling.

OK. I don't see that documented anywhere but it makes sense. Anyway
there are some places which don't do this test (e.g.
isolate_freepages_block, suitable_migration_target, etc.).

> 
> 
> > > +				iter += (1 << page_order(page)) - 1;
> > > +			continue;
> > > +		}
> > > +		if (!PageLRU(page))
> > > +			found++;
> > > +		/*
> > > +		 * If the page is not RAM, page_count()should be 0.
> > > +		 * we don't need more check. This is an _used_ not-movable page.
> > > +		 *
> > > +		 * The problematic thing here is PG_reserved pages. But if
> > > +		 * a PG_reserved page is _used_ (at boot), page_count > 1.
> > > +		 * But...is there PG_reserved && page_count(page)==0 page ?
> > 
> > Can we have PG_reserved && PG_lru? 
> 
> I think never.
> 
> > I also quite don't understand the comment. 
> 
> There an issue that "remove an memory section which includes memory hole".
> Then,
> 
>    a page used by bootmem .... PG_reserved.
>    a page of memory hole  .... PG_reserved.
> 
> We need to call page_is_ram() or some for handling this mess.

OK, I see.

> 
> 
> > At this place we are sure that the page is valid and neither
> > free nor LRU.
> > 
[...]
> > > +bool is_pageblock_removable(struct page *page)
> > > +{
> > > +	struct zone *zone = page_zone(page);
> > > +	unsigned long flags;
> > > +	int num;
> > > +
> > > +	spin_lock_irqsave(&zone->lock, flags);
> > > +	num = __count_unmovable_pages(zone, page);
> > > +	spin_unlock_irqrestore(&zone->lock, flags);
> > 
> > Isn't this a problem? The function is triggered from userspace by sysfs
> > (0444 file) and holds the lock for pageblock_nr_pages. So someone can
> > simply read the file and block the zone->lock preventing/delaying
> > allocations for the rest of the system.
> > 
> But we need to take this. Maybe no panic you'll see even if no-lock.

Yes, I think that this can only lead to a false possitive in sysfs
interface. Isolating code holds the lock.

Thanks
-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
