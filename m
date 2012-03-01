Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 509196B0083
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 04:19:44 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CD5DE3EE0C0
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 18:19:42 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id ADFB445DE5C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 18:19:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C39845DE58
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 18:19:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A7A1E08003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 18:19:42 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CDAEC1DB8053
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 18:19:41 +0900 (JST)
Date: Thu, 1 Mar 2012 18:18:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 next] memcg: fix deadlock by avoiding stat lock when
 anon
Message-Id: <20120301181813.edd2357d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1202291843120.14002@eggly.anvils>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
	<alpine.LSU.2.00.1202282125240.4875@eggly.anvils>
	<20120229193517.GD1673@cmpxchg.org>
	<alpine.LSU.2.00.1202291648340.11821@eggly.anvils>
	<alpine.LSU.2.00.1202291843120.14002@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 29 Feb 2012 18:44:59 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Fix deadlock in "memcg: use new logic for page stat accounting".
> 
> page_remove_rmap() first calls mem_cgroup_begin_update_page_stat(),
> which may take move_lock_mem_cgroup(), unlocked at the end of
> page_remove_rmap() by mem_cgroup_end_update_page_stat().
> 
> The PageAnon case never needs to mem_cgroup_dec_page_stat(page,
> MEMCG_NR_FILE_MAPPED); but it often needs to mem_cgroup_uncharge_page(),
> which does lock_page_cgroup(), while holding that move_lock_mem_cgroup().
> Whereas mem_cgroup_move_account() calls move_lock_mem_cgroup() while
> holding lock_page_cgroup().
> 
> Since mem_cgroup_begin and end are unnecessary here for PageAnon,
> simply avoid the deadlock and wasted calls in that case.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thank you and I'm sorry.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
> v2: added comment in the code so it's not thought just an optimization.
> 
>  mm/rmap.c |   17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> --- 3.3-rc5-next/mm/rmap.c	2012-02-26 23:51:46.506050210 -0800
> +++ linux/mm/rmap.c	2012-02-29 17:55:42.868665736 -0800
> @@ -1166,10 +1166,18 @@ void page_add_file_rmap(struct page *pag
>   */
>  void page_remove_rmap(struct page *page)
>  {
> +	bool anon = PageAnon(page);
>  	bool locked;
>  	unsigned long flags;
>  
> -	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
> +	/*
> +	 * The anon case has no mem_cgroup page_stat to update; but may
> +	 * uncharge_page() below, where the lock ordering can deadlock if
> +	 * we hold the lock against page_stat move: so avoid it on anon.
> +	 */
> +	if (!anon)
> +		mem_cgroup_begin_update_page_stat(page, &locked, &flags);
> +
>  	/* page still mapped by someone else? */
>  	if (!atomic_add_negative(-1, &page->_mapcount))
>  		goto out;
> @@ -1181,7 +1189,7 @@ void page_remove_rmap(struct page *page)
>  	 * not if it's in swapcache - there might be another pte slot
>  	 * containing the swap entry, but page not yet written to swap.
>  	 */
> -	if ((!PageAnon(page) || PageSwapCache(page)) &&
> +	if ((!anon || PageSwapCache(page)) &&
>  	    page_test_and_clear_dirty(page_to_pfn(page), 1))
>  		set_page_dirty(page);
>  	/*
> @@ -1190,7 +1198,7 @@ void page_remove_rmap(struct page *page)
>  	 */
>  	if (unlikely(PageHuge(page)))
>  		goto out;
> -	if (PageAnon(page)) {
> +	if (anon) {
>  		mem_cgroup_uncharge_page(page);
>  		if (!PageTransHuge(page))
>  			__dec_zone_page_state(page, NR_ANON_PAGES);
> @@ -1211,7 +1219,8 @@ void page_remove_rmap(struct page *page)
>  	 * faster for those pages still in swapcache.
>  	 */
>  out:
> -	mem_cgroup_end_update_page_stat(page, &locked, &flags);
> +	if (!anon)
> +		mem_cgroup_end_update_page_stat(page, &locked, &flags);
>  }
>  
>  /*
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
