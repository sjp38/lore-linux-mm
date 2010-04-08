Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D609600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 12:46:54 -0400 (EDT)
Date: Thu, 8 Apr 2010 18:46:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 56 of 67] Memory compaction core
Message-ID: <20100408164630.GL5749@random.random>
References: <patchbomb.1270691443@v2.random>
 <a86f1d01d86dffb4ab53.1270691499@v2.random>
 <20100408161814.GC28964@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100408161814.GC28964@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

Hi Johannes,

On Thu, Apr 08, 2010 at 06:18:14PM +0200, Johannes Weiner wrote:
> Andrea,
> 
> > +		/* Get the page and skip if free */
> > +		page = pfn_to_page(low_pfn);
> > +		if (PageBuddy(page)) {
> 
> Should this be
> 
> 		if (PageBuddy(page) || PageTransHuge(page)) {
> 
> > +			low_pfn += (1 << page_order(page)) - 1;
> > +			continue;
> > +		}
> 
> instead?

That was the original code (without PageTransHuge) and what you will
find in -mm. But calling page_order crashes because there's only the
lru_lock here (not the zone->lock), so PageBuddy will go away from
under us and it won't be set when page_order is called.

It's a minor optimization so the fix is what I implemented with:

     if (PageBuddy(page))
     	continue;

I also noticed this loop misses the check for PageTransCompound. Your
PageTransHuge check above would make it crash if it touches a tail
page. this scans all pfn so if a order 10 allocation exists in the
system, that could trip on it. PageTransCompound is the right check
and it'll fix Avi's issue.

I'm undecided if it's safe to have PageTransCompound checked before or
after __isolate_lru_page.

Now split_huge_page_refcount clears PG_head/tail gauranteed under
zone->lru_lock so there's zero risk of PageTransCompound to go away
from under us there. In fact we can also check the
compound_order(page) there, safely. It can't go away from under us
(unlike the page_order when PageBuddy is set).

But khugepaged might create hugepages from under us at that
point. While if we run it after __isolate_lru_page we keep khugepaged
away too, because khugepaged has to isolate the pages to collapse
them, and secondly because khugepaged will never touch a page with
pinned page_count.

> 
> > +
> > +		/* Try isolate the page */
> > +		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)
> > +			continue;
> > +
> > +		/* Successfully isolated */
> > +		del_page_from_lru_list(zone, page, page_lru(page));
> > +		list_add(&page->lru, migratelist);
> > +		mem_cgroup_del_lru(page);
> > +		cc->nr_migratepages++;
> > +
> > +		/* Avoid isolating too much */
> > +		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
> > +			break;
> > +	}
> > +
> > +	acct_isolated(zone, cc);
> > +
> > +	spin_unlock_irq(&zone->lru_lock);
> > +	cc->migrate_pfn = low_pfn;
> > +
> > +	return cc->nr_migratepages;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
