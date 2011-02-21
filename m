Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 011E38D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 08:11:07 -0500 (EST)
Date: Mon, 21 Feb 2011 14:10:58 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 2/2] memcg: remove charge variable in unmap_and_move
Message-ID: <20110221131058.GG25382@cmpxchg.org>
References: <cover.1298214672.git.minchan.kim@gmail.com>
 <c48df61c1186492699f18c4c6b401dcbc0db2b7f.1298214672.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c48df61c1186492699f18c4c6b401dcbc0db2b7f.1298214672.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Mon, Feb 21, 2011 at 12:17:18AM +0900, Minchan Kim wrote:
> memcg charge/uncharge could be handled by mem_cgroup_[prepare/end]
> migration itself so charge local variable in unmap_and_move lost the role
> since we introduced 01b1ae63c2.
> 
> In addition, the variable name is not good like below.
> 
> int unmap_and_move()
> {
> 	charge = mem_cgroup_prepare_migration(xxx);
> 	..
> 		BUG_ON(charge); <-- BUG if it is charged?
> 		..
> uncharge:
> 		if (!charge)    <-- why do we have to uncharge !charge?
> 			mem_group_end_migration(xxx);
> 	..
> }
> 
> So let's remove unnecessary and confusing variable.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Suggested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/memcontrol.c |    1 +
>  mm/migrate.c    |    9 +++------
>  2 files changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8a97571..3c91d5c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2873,6 +2873,7 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
>  /*
>   * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
>   * page belongs to.
> + * Note: Should not return -EAGAIN. unmap_and_move depens on it.
>   */
>  int mem_cgroup_prepare_migration(struct page *page,
>  	struct page *newpage, struct mem_cgroup **ptr, gfp_t gfp_mask)
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 2abc9c9..37055d0 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -622,7 +622,6 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  	int *result = NULL;
>  	struct page *newpage = get_new_page(page, private, &result);
>  	int remap_swapcache = 1;
> -	int charge = 0;
>  	struct mem_cgroup *mem;
>  	struct anon_vma *anon_vma = NULL;
>  
> @@ -637,7 +636,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  		if (unlikely(split_huge_page(page)))
>  			goto move_newpage;
>  
> -	/* prepare cgroup just returns 0 or -ENOMEM */
> +	/* mem_cgroup_prepage_migration never returns -EAGAIN */
>  	rc = -EAGAIN;

I really don't like this.  Why should we depend on that?

>  	if (!trylock_page(page)) {
> @@ -678,8 +677,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  	}
>  
>  	/* charge against new page */
> -	charge = mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL);
> -	if (charge == -ENOMEM) {
> +	if (mem_cgroup_prepare_migration(page, newpage, &mem, GFP_KERNEL)) {
>  		rc = -ENOMEM;
>  		goto unlock;

Couldn't we make unmap_and_move completely oblivious of the specific
value and just do

	rc = mem_cgroup_prepare_migration()
	if (rc)
		goto unlock;

at this point?  I think mem_cgroup_prepare_migration should be rather
free to signal pretty much any error and it is up to migrate_pages()
to handle them correctly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
