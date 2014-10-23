Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB9A6B0072
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 11:03:24 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id p9so999289lbv.19
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 08:03:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si3048865lax.37.2014.10.23.08.03.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 08:03:22 -0700 (PDT)
Date: Thu, 23 Oct 2014 17:03:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm: memcontrol: fix missed end-writeback page
 accounting
Message-ID: <20141023150321.GJ23011@dhcp22.suse.cz>
References: <1414002568-21042-1-git-send-email-hannes@cmpxchg.org>
 <1414002568-21042-3-git-send-email-hannes@cmpxchg.org>
 <20141022133936.44f2d2931948ce13477b5e64@linux-foundation.org>
 <20141023135729.GB24269@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141023135729.GB24269@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 23-10-14 09:57:29, Johannes Weiner wrote:
[...]
> From b518d88254b01be8c6c0c4a496d9f311f0c71b4a Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Thu, 23 Oct 2014 09:29:06 -0400
> Subject: [patch] mm: rmap: split out page_remove_file_rmap()
> 
> page_remove_rmap() has too many branches on PageAnon() and is hard to
> follow.  Move the file part into a separate function.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/rmap.c | 78 +++++++++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 46 insertions(+), 32 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index f574046f77d4..19886fb2f13a 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1054,6 +1054,36 @@ void page_add_file_rmap(struct page *page)
>  	mem_cgroup_end_page_stat(memcg, locked, flags);
>  }
>  
> +static void page_remove_file_rmap(struct page *page)
> +{
> +	struct mem_cgroup *memcg;
> +	unsigned long flags;
> +	bool locked;
> +
> +	memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
> +
> +	/* page still mapped by someone else? */
> +	if (!atomic_add_negative(-1, &page->_mapcount))
> +		goto out;
> +
> +	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
> +	if (unlikely(PageHuge(page)))
> +		goto out;
> +
> +	/*
> +	 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
> +	 * these counters are not modified in interrupt context, and
> +	 * pte lock(a spinlock) is held, which implies preemption disabled.
> +	 */
> +	__dec_zone_page_state(page, NR_FILE_MAPPED);
> +	mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
> +
> +	if (unlikely(PageMlocked(page)))
> +		clear_page_mlock(page);
> +out:
> +	mem_cgroup_end_page_stat(memcg, locked, flags);
> +}
> +
>  /**
>   * page_remove_rmap - take down pte mapping from a page
>   * @page: page to remove mapping from
> @@ -1062,46 +1092,33 @@ void page_add_file_rmap(struct page *page)
>   */
>  void page_remove_rmap(struct page *page)
>  {
> -	struct mem_cgroup *uninitialized_var(memcg);
> -	bool anon = PageAnon(page);
> -	unsigned long flags;
> -	bool locked;
> -
> -	/*
> -	 * The anon case has no mem_cgroup page_stat to update; but may
> -	 * uncharge_page() below, where the lock ordering can deadlock if
> -	 * we hold the lock against page_stat move: so avoid it on anon.
> -	 */
> -	if (!anon)
> -		memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
> +	if (!PageAnon(page)) {
> +		page_remove_file_rmap(page);
> +		return;
> +	}
>  
>  	/* page still mapped by someone else? */
>  	if (!atomic_add_negative(-1, &page->_mapcount))
> -		goto out;
> +		return;
> +
> +	/* Hugepages are not counted in NR_ANON_PAGES for now. */
> +	if (unlikely(PageHuge(page)))
> +		return;
>  
>  	/*
> -	 * Hugepages are not counted in NR_ANON_PAGES nor NR_FILE_MAPPED
> -	 * and not charged by memcg for now.
> -	 *
>  	 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
>  	 * these counters are not modified in interrupt context, and
> -	 * these counters are not modified in interrupt context, and
>  	 * pte lock(a spinlock) is held, which implies preemption disabled.
>  	 */
> -	if (unlikely(PageHuge(page)))
> -		goto out;
> -	if (anon) {
> -		if (PageTransHuge(page))
> -			__dec_zone_page_state(page,
> -					      NR_ANON_TRANSPARENT_HUGEPAGES);
> -		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
> -				-hpage_nr_pages(page));
> -	} else {
> -		__dec_zone_page_state(page, NR_FILE_MAPPED);
> -		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
> -	}
> +	if (PageTransHuge(page))
> +		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
> +
> +	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
> +			      -hpage_nr_pages(page));
> +
>  	if (unlikely(PageMlocked(page)))
>  		clear_page_mlock(page);
> +
>  	/*
>  	 * It would be tidy to reset the PageAnon mapping here,
>  	 * but that might overwrite a racing page_add_anon_rmap
> @@ -1111,9 +1128,6 @@ void page_remove_rmap(struct page *page)
>  	 * Leaving it set also helps swapoff to reinstate ptes
>  	 * faster for those pages still in swapcache.
>  	 */
> -out:
> -	if (!anon)
> -		mem_cgroup_end_page_stat(memcg, locked, flags);
>  }
>  
>  /*
> -- 
> 2.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
