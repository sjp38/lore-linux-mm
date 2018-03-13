Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D57606B0006
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 23:33:50 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o19so7537680pgn.12
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 20:33:50 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n10si6003700pge.342.2018.03.12.20.33.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 20:33:49 -0700 (PDT)
Date: Tue, 13 Mar 2018 11:34:53 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v4 2/3] mm/free_pcppages_bulk: do not hold lock when
 picking pages to free
Message-ID: <20180313033453.GB13782@intel.com>
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-3-aaron.lu@intel.com>
 <9cad642d-9fe5-b2c3-456c-279065c32337@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9cad642d-9fe5-b2c3-456c-279065c32337@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On Mon, Mar 12, 2018 at 03:22:53PM +0100, Vlastimil Babka wrote:
> On 03/01/2018 07:28 AM, Aaron Lu wrote:
> > When freeing a batch of pages from Per-CPU-Pages(PCP) back to buddy,
> > the zone->lock is held and then pages are chosen from PCP's migratetype
> > list. While there is actually no need to do this 'choose part' under
> > lock since it's PCP pages, the only CPU that can touch them is us and
> > irq is also disabled.
> > 
> > Moving this part outside could reduce lock held time and improve
> > performance. Test with will-it-scale/page_fault1 full load:
> > 
> > kernel      Broadwell(2S)  Skylake(2S)   Broadwell(4S)  Skylake(4S)
> > v4.16-rc2+  9034215        7971818       13667135       15677465
> > this patch  9536374 +5.6%  8314710 +4.3% 14070408 +3.0% 16675866 +6.4%
> > 
> > What the test does is: starts $nr_cpu processes and each will repeatedly
> > do the following for 5 minutes:
> > 1 mmap 128M anonymouse space;
> > 2 write access to that space;
> > 3 munmap.
> > The score is the aggregated iteration.
> > 
> > https://github.com/antonblanchard/will-it-scale/blob/master/tests/page_fault1.c
> > 
> > Acked-by: Mel Gorman <mgorman@techsingularity.net>
> > Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> > ---
> >  mm/page_alloc.c | 39 +++++++++++++++++++++++----------------
> >  1 file changed, 23 insertions(+), 16 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index faa33eac1635..dafdcdec9c1f 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1116,12 +1116,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  	int migratetype = 0;
> >  	int batch_free = 0;
> >  	bool isolated_pageblocks;
> > -
> > -	spin_lock(&zone->lock);
> > -	isolated_pageblocks = has_isolate_pageblock(zone);
> > +	struct page *page, *tmp;
> > +	LIST_HEAD(head);
> >  
> >  	while (count) {
> > -		struct page *page;
> >  		struct list_head *list;
> >  
> >  		/*
> > @@ -1143,27 +1141,36 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  			batch_free = count;
> >  
> >  		do {
> > -			int mt;	/* migratetype of the to-be-freed page */
> > -
> >  			page = list_last_entry(list, struct page, lru);
> > -			/* must delete as __free_one_page list manipulates */
> > +			/* must delete to avoid corrupting pcp list */
> >  			list_del(&page->lru);
> 
> Well, since bulkfree_pcp_prepare() doesn't care about page->lru, you
> could maybe use list_move_tail() instead of list_del() +
> list_add_tail()? That avoids temporarily writing poison values.

Good point, except bulkfree_pcp_prepare() could return error and then
the page will need to be removed from the to-be-freed list, like this:

		do {
			page = list_last_entry(list, struct page, lru);
			list_move_tail(&page->lru, &head);
			pcp->count--;

			if (bulkfree_pcp_prepare(page))
				list_del(&page->lru);
		} while (--count && --batch_free && !list_empty(list));

Considering bulkfree_pcp_prepare() returning error is the rare case,
this list_del() should rarely happen. At the same time, this part is
outside of zone->lock and can hardly impact performance...so I'm not
sure.
 
> Hm actually, you are reversing the list in the process, because page is
> obtained by list_last_entry and you use list_add_tail. That could have
> unintended performance consequences?

True the order is changed when these to-be-freed pages are in this
temporary list, but then they are iterated and freed one by one from
head to tail so the order they landed in free_list is the same as
before the patch(also the same as they are in pcp list).

> 
> Also maybe list_cut_position() could be faster than shuffling pages one
> by one? I guess not really, because batch_free will be generally low?

We will need to know where to cut if list_cut_position() is to be used
and to find that out, the list will need to be iterated first. I guess
that's too much trouble.

Since this part of code is per-cpu(outside of zone->lock) and these
pages are in pcp(meaning their cachelines are not likely in remote),
I didn't worry too much about not being able to list_cut_position() but
iterate. On allocation side though, when manipulating the global
free_list under zone->lock, this is a big problem since pages there are
freed from different CPUs and the cache could be cold for the allocating
CPU. That is why I'm proposing clusted allocation sometime ago as an RFC
patch where list_cut_position() is so good that it could eliminate the
cacheline miss issue since we do not need to iterate cold pages one by
one.

I wish there is a data structure that has the flexibility of list while
at the same time we can locate the Nth element in the list without the
need to iterate. That's what I'm looking for when developing clustered
allocation for order 0 pages. In the end, I had to use another place to
record where the Nth element is. I hope to send out v2 of that RFC
series soon but I'm still collecting data for it. I would appreciate if
people could take a look then :-)

batch_free's value depends on what the system is doing. When user
application is making use of memory, the common case is, only
migratetype of MIGRATE_MOVABLE has pages to free and then batch_free
will be 1 in the first round and (pcp->batch-1) in the 2nd round.

Here is some data I collected recently on how often only MIGRATE_MOVABLE
list has pages to free in free_pcppages_bulk():

On my desktop, after boot:

free_pcppages_bulk:     6268
single_mt_movable:      2566 (41%)

free_pcppages_bulk means the number of time this function gets called.     
single_mt_movable means number of times when only MIGRATE_MOVABLE list
has pages to free.
                                       
After kbuild with a distro kconfig:

free_pcppages_bulk:     9100508
single_mt_movable:      8435483 (92.75%)

If we change the initial value of migratetype in free_pcppages_bulk()
from 0(MIGRATE_UNMOVABLE) to 1(MIGRATE_MOVABLE), then batch_free will be
pcp->batch in the 1st round and we can save something but the saving is
negligible when running a workload so I didn't send a patch for it yet.

> >  			pcp->count--;
> >  
> > -			mt = get_pcppage_migratetype(page);
> > -			/* MIGRATE_ISOLATE page should not go to pcplists */
> > -			VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
> > -			/* Pageblock could have been isolated meanwhile */
> > -			if (unlikely(isolated_pageblocks))
> > -				mt = get_pageblock_migratetype(page);
> > -
> >  			if (bulkfree_pcp_prepare(page))
> >  				continue;
> >  
> > -			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
> > -			trace_mm_page_pcpu_drain(page, 0, mt);
> > +			list_add_tail(&page->lru, &head);
> >  		} while (--count && --batch_free && !list_empty(list));
> >  	}
> > +
> > +	spin_lock(&zone->lock);
> > +	isolated_pageblocks = has_isolate_pageblock(zone);
> > +
> > +	/*
> > +	 * Use safe version since after __free_one_page(),
> > +	 * page->lru.next will not point to original list.
> > +	 */
> > +	list_for_each_entry_safe(page, tmp, &head, lru) {
> > +		int mt = get_pcppage_migratetype(page);
> > +		/* MIGRATE_ISOLATE page should not go to pcplists */
> > +		VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
> > +		/* Pageblock could have been isolated meanwhile */
> > +		if (unlikely(isolated_pageblocks))
> > +			mt = get_pageblock_migratetype(page);
> > +
> > +		__free_one_page(page, page_to_pfn(page), zone, 0, mt);
> > +		trace_mm_page_pcpu_drain(page, 0, mt);
> > +	}
> >  	spin_unlock(&zone->lock);
> >  }
> >  
> > 
> 
