Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id CC4016B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 00:25:43 -0400 (EDT)
Date: Fri, 20 Jul 2012 13:25:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] Cgroup: Fix memory accounting scalability in
 shrink_page_list
Message-ID: <20120720042545.GA24267@bbox>
References: <1342740866.13492.50.camel@schen9-DESK>
 <5008CE38.2020300@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5008CE38.2020300@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "andi.kleen" <andi.kleen@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Fri, Jul 20, 2012 at 12:19:20PM +0900, Kamezawa Hiroyuki wrote:
> (2012/07/20 8:34), Tim Chen wrote:
> >Hi,
> >
> >I noticed in a multi-process parallel files reading benchmark I ran on a
> >8 socket machine,  throughput slowed down by a factor of 8 when I ran
> >the benchmark within a cgroup container.  I traced the problem to the
> >following code path (see below) when we are trying to reclaim memory
> >from file cache.  The res_counter_uncharge function is called on every
> >page that's reclaimed and created heavy lock contention.  The patch
> >below allows the reclaimed pages to be uncharged from the resource
> >counter in batch and recovered the regression.
> >
> >Tim
> >
> >      40.67%           usemem  [kernel.kallsyms]                   [k] _raw_spin_lock
> >                       |
> >                       --- _raw_spin_lock
> >                          |
> >                          |--92.61%-- res_counter_uncharge
> >                          |          |
> >                          |          |--100.00%-- __mem_cgroup_uncharge_common
> >                          |          |          |
> >                          |          |          |--100.00%-- mem_cgroup_uncharge_cache_page
> >                          |          |          |          __remove_mapping
> >                          |          |          |          shrink_page_list
> >                          |          |          |          shrink_inactive_list
> >                          |          |          |          shrink_mem_cgroup_zone
> >                          |          |          |          shrink_zone
> >                          |          |          |          do_try_to_free_pages
> >                          |          |          |          try_to_free_pages
> >                          |          |          |          __alloc_pages_nodemask
> >                          |          |          |          alloc_pages_current
> >
> >
> 
> Thank you very much !!
> 
> When I added batching, I didn't touch page-reclaim path because it delays
> res_counter_uncharge() and make more threads run into page reclaim.

Isn't it really problem? It's same as global reclaim.
In the short term, you might be right but batch free might prevent
entering more into reclaim path in the long term because we get lots
of free pages than nenessary one. And we can reduce lock overhead.
If it is proved as real problem, maybe we need global reclaim, too.

> But, from above score, bactching seems required.
> 
> And because of current design of per-zone-per-memcg-LRU, batching
> works very very well....all lru pages shrink_page_list() scans are on
> the same memcg.

Yes. It's more effective point!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
