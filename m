Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4316B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 08:42:30 -0400 (EDT)
Date: Tue, 7 Jun 2011 08:42:13 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 8/8] mm: make per-memcg lru lists exclusive
Message-ID: <20110607124213.GB18571@infradead.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306909519-7286-9-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 01, 2011 at 08:25:19AM +0200, Johannes Weiner wrote:
> All lru list walkers have been converted to operate on per-memcg
> lists, the global per-zone lists are no longer required.
> 
> This patch makes the per-memcg lists exclusive and removes the global
> lists from memcg-enabled kernels.
> 
> The per-memcg lists now string up page descriptors directly, which
> unifies/simplifies the list isolation code of page reclaim as well as
> it saves a full double-linked list head for each page in the system.
> 
> At the core of this change is the introduction of the lruvec
> structure, an array of all lru list heads.  It exists for each zone
> globally, and for each zone per memcg.  All lru list operations are
> now done in generic code against lruvecs, with the memcg lru list
> primitives only doing accounting and returning the proper lruvec for
> the currently scanned memcg on isolation, or for the respective page
> on putback.

Wouldn't it be simpler if we always have a stub mem_cgroup_per_zone
structure even for non-memcg kernels, and always operate on a
single instance per node of those for non-memcg kernels?  In effect the
lruvec almost is something like that, just adding another layer of
abstraction.

>  static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> index 8f7d247..43d5d9f 100644
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -25,23 +25,27 @@ static inline void
>  __add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l,
>  		       struct list_head *head)
>  {
> +	/* NOTE: Caller must ensure @head is on the right lruvec! */
> +	mem_cgroup_lru_add_list(zone, page, l);
>  	list_add(&page->lru, head);
>
>  	__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pages(page));
> -	mem_cgroup_add_lru_list(page, l);
>  }

This already has been a borderline-useful function before, but with the
new changes it's not a useful helper.  Either add the code surrounding
it includeing the PageLRU check and the normal add_page_to_lru_list
into a new page_update_lru_pos or similar helper, or just opencode these
bits in the only caller with a comment documenting why we are doing it.

I would tend towards the opencoding variant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
