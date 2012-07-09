Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 147FF6B005C
	for <linux-mm@kvack.org>; Sun,  8 Jul 2012 22:44:41 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 795843EE0C8
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:44:39 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5698945DE4E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:44:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 33CF245DE4D
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:44:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 20F461DB8041
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:44:39 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C81F71DB8037
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 11:44:38 +0900 (JST)
Message-ID: <4FFA4504.4040408@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 11:42:12 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 04/11] mm: memcg: push down PageSwapCache check into uncharge
 entry functions
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org> <1341449103-1986-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-5-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2012/07/05 9:44), Johannes Weiner wrote:
> Not all uncharge paths need to check if the page is swapcache, some of
> them can know for sure.
> 
> Push down the check into all callsites of uncharge_common() so that
> the patch that removes some of them is more obvious.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---

some nitpick.

>   mm/memcontrol.c |   18 ++++++++++++------
>   1 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4ea19c6..a3bf414 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2920,8 +2920,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
>   	if (mem_cgroup_disabled())
>   		return NULL;
>   
> -	if (PageSwapCache(page))
> -		return NULL;
> +	VM_BUG_ON(PageSwapCache(page));
>   
>   	if (PageTransHuge(page)) {
>   		nr_pages <<= compound_order(page);
> @@ -3018,6 +3017,8 @@ void mem_cgroup_uncharge_page(struct page *page)
>   	if (page_mapped(page))
>   		return;
>   	VM_BUG_ON(page->mapping && !PageAnon(page));
> +	if (PageSwapCache(page))
> +		return;
>   	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_ANON, false);
>   }
>   
> @@ -3025,6 +3026,8 @@ void mem_cgroup_uncharge_cache_page(struct page *page)
>   {
>   	VM_BUG_ON(page_mapped(page));
>   	VM_BUG_ON(page->mapping);
> +	if (PageSwapCache(page))
> +		return;
>   	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE, false);
>   }
>   
> @@ -3089,6 +3092,8 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>   	if (!swapout) /* this was a swap cache but the swap is unused ! */
>   		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
>   
> +	if (PageSwapCache(page))
> +		return;
>   	memcg = __mem_cgroup_uncharge_common(page, ctype, false);
>   
>   	/*
> @@ -3278,10 +3283,11 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
>   		unused = oldpage;
>   	}
>   	anon = PageAnon(used);
> -	__mem_cgroup_uncharge_common(unused,
> -		anon ? MEM_CGROUP_CHARGE_TYPE_ANON
> -		     : MEM_CGROUP_CHARGE_TYPE_CACHE,
> -		true);
> +	if (!PageSwapCache(page))
> +		__mem_cgroup_uncharge_common(unused,
> +					     anon ? MEM_CGROUP_CHARGE_TYPE_ANON
> +					     : MEM_CGROUP_CHARGE_TYPE_CACHE,
> +					     true);

!PageSwapCache(unused) ?

But I think unused page's PG_swapcache is always dropped. So, the check is
not necessary.

Thanks,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
