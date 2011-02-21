Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC728D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 03:40:24 -0500 (EST)
Date: Mon, 21 Feb 2011 09:40:14 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v6 2/3] memcg: move memcg reclaimable page into tail of
 inactive list
Message-ID: <20110221084014.GC25382@cmpxchg.org>
References: <cover.1298212517.git.minchan.kim@gmail.com>
 <c76a1645aac12c3b8ffe2cc5738033f5a6da8d32.1298212517.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c76a1645aac12c3b8ffe2cc5738033f5a6da8d32.1298212517.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sun, Feb 20, 2011 at 11:43:37PM +0900, Minchan Kim wrote:
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -813,6 +813,33 @@ void mem_cgroup_del_lru(struct page *page)
>  	mem_cgroup_del_lru_list(page, page_lru(page));
>  }
>  
> +/*
> + * Writeback is about to end against a page which has been marked for immediate
> + * reclaim.  If it still appears to be reclaimable, move it to the tail of the
> + * inactive list.
> + */
> +void mem_cgroup_rotate_reclaimable_page(struct page *page)
> +{
> +	struct mem_cgroup_per_zone *mz;
> +	struct page_cgroup *pc;
> +	enum lru_list lru = page_lru(page);
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +
> +	pc = lookup_page_cgroup(page);
> +	/*
> +	 * Used bit is set without atomic ops but after smp_wmb().
> +	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
> +	 */
> +	smp_rmb();
> +	/* unused or root page is not rotated. */
> +	if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup))
> +		return;

The placement of this barrier is confused and has been fixed up in the
meantime in other places.  It has to be between PageCgroupUsed() and
accessing pc->mem_cgroup.  You can look at the other memcg lru
functions for reference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
