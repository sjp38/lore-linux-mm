Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 2E0A56B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 02:27:45 -0400 (EDT)
Date: Fri, 20 Jul 2012 08:27:20 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] Cgroup: Fix memory accounting scalability in
 shrink_page_list
Message-ID: <20120720062720.GD1505@cmpxchg.org>
References: <1342740866.13492.50.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342740866.13492.50.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "andi.kleen" <andi.kleen@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu, Jul 19, 2012 at 04:34:26PM -0700, Tim Chen wrote:
> Hi,
> 
> I noticed in a multi-process parallel files reading benchmark I ran on a
> 8 socket machine,  throughput slowed down by a factor of 8 when I ran
> the benchmark within a cgroup container.  I traced the problem to the
> following code path (see below) when we are trying to reclaim memory
> from file cache.  The res_counter_uncharge function is called on every
> page that's reclaimed and created heavy lock contention.  The patch
> below allows the reclaimed pages to be uncharged from the resource
> counter in batch and recovered the regression. 
> 
> Tim
> 
>      40.67%           usemem  [kernel.kallsyms]                   [k] _raw_spin_lock
>                       |
>                       --- _raw_spin_lock
>                          |
>                          |--92.61%-- res_counter_uncharge
>                          |          |
>                          |          |--100.00%-- __mem_cgroup_uncharge_common
>                          |          |          |
>                          |          |          |--100.00%-- mem_cgroup_uncharge_cache_page
>                          |          |          |          __remove_mapping
>                          |          |          |          shrink_page_list
>                          |          |          |          shrink_inactive_list
>                          |          |          |          shrink_mem_cgroup_zone
>                          |          |          |          shrink_zone
>                          |          |          |          do_try_to_free_pages
>                          |          |          |          try_to_free_pages
>                          |          |          |          __alloc_pages_nodemask
>                          |          |          |          alloc_pages_current
> 
> 
> ---
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Good one.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
