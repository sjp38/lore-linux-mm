Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 761FB6B005A
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 08:30:42 -0500 (EST)
Date: Thu, 19 Jan 2012 14:30:35 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: remove PCG_CACHE page_cgroup flag
Message-ID: <20120119133035.GO24386@cmpxchg.org>
References: <20120119181711.8d697a6b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120119181711.8d697a6b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Thu, Jan 19, 2012 at 06:17:11PM +0900, KAMEZAWA Hiroyuki wrote:
> @@ -4,7 +4,6 @@
>  enum {
>  	/* flags for mem_cgroup */
>  	PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
> -	PCG_CACHE, /* charged as cache */
>  	PCG_USED, /* this object is in use. */
>  	PCG_MIGRATION, /* under page migration */
>  	/* flags for mem_cgroup and file and I/O status */

Me gusta.

> @@ -606,11 +606,16 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
>  }
>  
>  static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
> -					 bool file, int nr_pages)
> +					 bool not_rss, int nr_pages)
>  {
>  	preempt_disable();
>  
> -	if (file)
> +	/*
> +	 * Here, RSS means 'mapped anon' and anon's SwapCache. Unlike LRU,
> +	 * Shmem is not included to Anon. It' counted as 'file cache'
> +	 * which tends to be shared between memcgs.
> +	 */
> +	if (not_rss)

Could you invert that boolean and call it "anon"?

> @@ -2343,6 +2348,8 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>  				       struct page_cgroup *pc,
>  				       enum charge_type ctype)
>  {
> +	bool not_rss;
> +
>  	lock_page_cgroup(pc);
>  	if (unlikely(PageCgroupUsed(pc))) {
>  		unlock_page_cgroup(pc);
> @@ -2362,21 +2369,15 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>  	 * See mem_cgroup_add_lru_list(), etc.
>   	 */
>  	smp_wmb();
> -	switch (ctype) {
> -	case MEM_CGROUP_CHARGE_TYPE_CACHE:
> -	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
> -		SetPageCgroupCache(pc);
> -		SetPageCgroupUsed(pc);
> -		break;
> -	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
> -		ClearPageCgroupCache(pc);
> -		SetPageCgroupUsed(pc);
> -		break;
> -	default:
> -		break;
> -	}
>  
> -	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), nr_pages);
> +	SetPageCgroupUsed(pc);
> +	if ((ctype == MEM_CGROUP_CHARGE_TYPE_CACHE) ||
> +	    (ctype == MEM_CGROUP_CHARGE_TYPE_SHMEM))
> +		not_rss = true;
> +	else
> +		not_rss = false;
> +
> +	mem_cgroup_charge_statistics(memcg, not_rss, nr_pages);

	mem_cgroup_charge_statistics(memcg,
				     ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED,
				     nr_pages);

and save even more lines, without sacrificing clarity! :)

> @@ -2908,9 +2915,15 @@ void mem_cgroup_uncharge_page(struct page *page)
>  
>  void mem_cgroup_uncharge_cache_page(struct page *page)
>  {
> +	int ctype;
> +
>  	VM_BUG_ON(page_mapped(page));
>  	VM_BUG_ON(page->mapping);
> -	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
> +	if (page_is_file_cache(page))
> +		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> +	else
> +		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> +	__mem_cgroup_uncharge_common(page, ctype);

Looks like an unrelated bugfix on one hand, but on the other hand we
do not differentiate cache from shmem anywhere, afaik, and you do not
introduce anything that does.  Could you just leave this out?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
