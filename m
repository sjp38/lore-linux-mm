Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6C25A6B004F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 02:54:28 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L6tHPl012783
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Apr 2009 15:55:17 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CB3345DD7B
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:55:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 307DA45DD76
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:55:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0030C1DB8043
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:55:17 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C9151DB803B
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 15:55:16 +0900 (JST)
Date: Tue, 21 Apr 2009 15:53:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: free unused swapcache at the end of page
 migration
Message-Id: <20090421155345.9530d24e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090421142931.2c02811a.nishimura@mxp.nes.nec.co.jp>
References: <20090421142641.aa4efa2f.nishimura@mxp.nes.nec.co.jp>
	<20090421142931.2c02811a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009 14:29:31 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Reading the comments, mem_cgroup_end_migration assumes that "newpage" is under lock_page.
> 
> And at the end of mem_cgroup_end_migration, mem_cgroup_uncharge_page cannot
> uncharge the "target" if it's SwapCache even if the owner process has already
> called zap_pte_range -> free_swap_and_cache.
> try_to_free_swap does all necessary checks(it checks page_swapcount).
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Nishimura-san, I'd like to handle this issue by my own handle-stale-swapcache patch.
(I'll post it today.)

So, could you wait this patch for a while ?

Thanks,
-Kame

> ---
>  mm/memcontrol.c |    7 +++++--
>  mm/migrate.c    |    9 +++++++--
>  2 files changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 619b0c1..f41433c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1611,10 +1611,13 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  	 * There is a case for !page_mapped(). At the start of
>  	 * migration, oldpage was mapped. But now, it's zapped.
>  	 * But we know *target* page is not freed/reused under us.
> -	 * mem_cgroup_uncharge_page() does all necessary checks.
> +	 * mem_cgroup_uncharge_page() cannot free SwapCache, so we call
> +	 * try_to_free_swap(), which does all necessary checks.
>  	 */
> -	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
> +	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED && !page_mapped(target)) {
>  		mem_cgroup_uncharge_page(target);
> +		try_to_free_swap(target);
> +	}
>  }
>  
>  /*
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 068655d..364edf7 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -580,7 +580,7 @@ static int move_to_new_page(struct page *newpage, struct page *page)
>  	} else
>  		newpage->mapping = NULL;
>  
> -	unlock_page(newpage);
> +	/* keep lock on newpage because mem_cgroup_end_migration assumes it */
>  
>  	return rc;
>  }
> @@ -595,6 +595,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  	int rc = 0;
>  	int *result = NULL;
>  	struct page *newpage = get_new_page(page, private, &result);
> +	int newpage_locked = 0;
>  	int rcu_locked = 0;
>  	int charge = 0;
>  	struct mem_cgroup *mem;
> @@ -671,8 +672,10 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  	/* Establish migration ptes or remove ptes */
>  	try_to_unmap(page, 1);
>  
> -	if (!page_mapped(page))
> +	if (!page_mapped(page)) {
>  		rc = move_to_new_page(newpage, page);
> +		newpage_locked = 1;
> +	}
>  
>  	if (rc)
>  		remove_migration_ptes(page, page);
> @@ -683,6 +686,8 @@ uncharge:
>  	if (!charge)
>  		mem_cgroup_end_migration(mem, page, newpage);
>  unlock:
> +	if (newpage_locked)
> +		unlock_page(newpage);
>  	unlock_page(page);
>  
>  	if (rc != -EAGAIN) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
