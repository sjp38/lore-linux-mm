Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 54B476B004D
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 23:22:02 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1716D3EE0B5
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 12:22:00 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EF37745DE4E
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 12:21:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CCEA345DE4D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 12:21:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BB1391DB803C
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 12:21:59 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 659771DB802C
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 12:21:59 +0900 (JST)
Message-ID: <5008CE38.2020300@jp.fujitsu.com>
Date: Fri, 20 Jul 2012 12:19:20 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Cgroup: Fix memory accounting scalability in shrink_page_list
References: <1342740866.13492.50.camel@schen9-DESK>
In-Reply-To: <1342740866.13492.50.camel@schen9-DESK>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "andi.kleen" <andi.kleen@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

(2012/07/20 8:34), Tim Chen wrote:
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
>       40.67%           usemem  [kernel.kallsyms]                   [k] _raw_spin_lock
>                        |
>                        --- _raw_spin_lock
>                           |
>                           |--92.61%-- res_counter_uncharge
>                           |          |
>                           |          |--100.00%-- __mem_cgroup_uncharge_common
>                           |          |          |
>                           |          |          |--100.00%-- mem_cgroup_uncharge_cache_page
>                           |          |          |          __remove_mapping
>                           |          |          |          shrink_page_list
>                           |          |          |          shrink_inactive_list
>                           |          |          |          shrink_mem_cgroup_zone
>                           |          |          |          shrink_zone
>                           |          |          |          do_try_to_free_pages
>                           |          |          |          try_to_free_pages
>                           |          |          |          __alloc_pages_nodemask
>                           |          |          |          alloc_pages_current
>
>

Thank you very much !!

When I added batching, I didn't touch page-reclaim path because it delays
res_counter_uncharge() and make more threads run into page reclaim.
But, from above score, bactching seems required.

And because of current design of per-zone-per-memcg-LRU, batching
works very very well....all lru pages shrink_page_list() scans are on
the same memcg.

BTW, it's better to show 'how much improved' in patch description..


> ---
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 33dc256..aac5672 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -779,6 +779,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>
>   	cond_resched();
>
> +	mem_cgroup_uncharge_start();
>   	while (!list_empty(page_list)) {
>   		enum page_references references;
>   		struct address_space *mapping;
> @@ -1026,6 +1027,7 @@ keep_lumpy:
>
>   	list_splice(&ret_pages, page_list);
>   	count_vm_events(PGACTIVATE, pgactivate);
> +	mem_cgroup_uncharge_end();

I guess placing mem_cgroup_uncharge_end() just after the loop may be better looking.

Anyway,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

But please show 'how much improved' in patch description.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
