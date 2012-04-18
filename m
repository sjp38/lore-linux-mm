Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id C4D466B0101
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 19:33:32 -0400 (EDT)
Date: Wed, 18 Apr 2012 16:33:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2] memcg: add mlock statistic in memory.stat
Message-Id: <20120418163330.ca1518c7.akpm@linux-foundation.org>
In-Reply-To: <1334773315-32215-1-git-send-email-yinghan@google.com>
References: <1334773315-32215-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Wed, 18 Apr 2012 11:21:55 -0700
Ying Han <yinghan@google.com> wrote:

> We have the nr_mlock stat both in meminfo as well as vmstat system wide, this
> patch adds the mlock field into per-memcg memory stat. The stat itself enhances
> the metrics exported by memcg since the unevictable lru includes more than
> mlock()'d page like SHM_LOCK'd.
> 
> Why we need to count mlock'd pages while they are unevictable and we can not
> do much on them anyway?
> 
> This is true. The mlock stat I am proposing is more helpful for system admin
> and kernel developer to understand the system workload. The same information
> should be helpful to add into OOM log as well. Many times in the past that we
> need to read the mlock stat from the per-container meminfo for different
> reason. Afterall, we do have the ability to read the mlock from meminfo and
> this patch fills the info in memcg.
> 
>
> ...
>
>  static inline int is_mlocked_vma(struct vm_area_struct *vma, struct page *page)
>  {
> +	bool locked;
> +	unsigned long flags;
> +
>  	VM_BUG_ON(PageLRU(page));
>  
>  	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
>  		return 0;
>  
> +	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
>  	if (!TestSetPageMlocked(page)) {
>  		inc_zone_page_state(page, NR_MLOCK);
> +		mem_cgroup_inc_page_stat(page, MEMCG_NR_MLOCK);
>  		count_vm_event(UNEVICTABLE_PGMLOCKED);
>  	}
> +	mem_cgroup_end_update_page_stat(page, &locked, &flags);
> +
>  	return 1;
>  }

Unrelated to this patch: is_mlocked_vma() is misnamed.  A function with
that name should be a bool-returning test which has no side-effects.

>
> ...
>
>  static void __free_pages_ok(struct page *page, unsigned int order)
>  {
>  	unsigned long flags;
> -	int wasMlocked = __TestClearPageMlocked(page);
> +	bool locked;
>  
>  	if (!free_pages_prepare(page, order))
>  		return;
>  
>  	local_irq_save(flags);
> -	if (unlikely(wasMlocked))
> +	mem_cgroup_begin_update_page_stat(page, &locked, &flags);

hm, what's going on here.  The page now has a zero refcount and is to
be returned to the buddy.  But mem_cgroup_begin_update_page_stat()
assumes that the page still belongs to a memcg.  I'd have thought that
any page_cgroup backreferences would have been torn down by now?

> +	if (unlikely(__TestClearPageMlocked(page)))
>  		free_page_mlock(page);

And if the page _is_ still accessible via cgroup lookup, the use of the
nonatomic RMW is dangerous.

>  	__count_vm_events(PGFREE, 1 << order);
>  	free_one_page(page_zone(page), page, order,
>  					get_pageblock_migratetype(page));
> +	mem_cgroup_end_update_page_stat(page, &locked, &flags);
>  	local_irq_restore(flags);
>  }
>  
> @@ -1250,7 +1256,7 @@ void free_hot_cold_page(struct page *page, int cold)

The same comments apply in free_hot_cold_page().

>  	struct per_cpu_pages *pcp;
>  	unsigned long flags;
>  	int migratetype;
> -	int wasMlocked = __TestClearPageMlocked(page);
> +	bool locked;
>  
>  	if (!free_pages_prepare(page, 0))
>  		return;
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
