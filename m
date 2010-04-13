Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC736B0217
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 02:46:00 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp03.in.ibm.com (8.14.3/8.13.1) with ESMTP id o3D6jmwG010087
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 12:15:48 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3D6jmUq3170384
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 12:15:48 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3D6jl1U017155
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 16:45:48 +1000
Date: Tue, 13 Apr 2010 12:15:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix underflow of mapped_file stat
Message-ID: <20100413064546.GG3994@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-04-13 13:42:07]:

> Hi.
> 
> When I was testing page migration, I found underflow problem of "mapped_file" field
> in memory.stat. This is a fix for the problem.
> 
> This patch is based on mmotm-2010-04-05-16-09, and IIUC it conflicts with Mel's
> compaction patches, so I send it as RFC for now. After next mmotm, which will
> include those patches, I'll update and resend this patch.
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> page_add_file_rmap(), which can be called from remove_migration_ptes(), is
> assumed to increment memcg's stat of mapped file. But on success of page
> migration, the newpage(mapped file) has not been charged yet, so the stat will
> not be incremented. This behavior leads to underflow of memcg's stat because
> when the newpage is unmapped afterwards, page_remove_rmap() decrements the stat.
> This problem doesn't happen on failure path of page migration, because the old
> page(mapped file) hasn't been uncharge at the point of remove_migration_ptes().
> This patch fixes this problem by calling commit_charge(mem_cgroup_end_migration)
> before remove_migration_ptes().
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/migrate.c |   19 ++++++++++++++-----
>  1 files changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 5938db5..915c35e 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -485,7 +485,8 @@ static int fallback_migrate_page(struct address_space *mapping,
>   *   < 0 - error code
>   *  == 0 - success
>   */
> -static int move_to_new_page(struct page *newpage, struct page *page)
> +static int move_to_new_page(struct page *newpage, struct page *page,
> +						struct mem_cgroup *mem)
>  {
>  	struct address_space *mapping;
>  	int rc;
> @@ -520,9 +521,16 @@ static int move_to_new_page(struct page *newpage, struct page *page)
>  	else
>  		rc = fallback_migrate_page(mapping, newpage, page);
> 
> -	if (!rc)
> +	if (!rc) {
> +		/*
> +		 * On success of page migration, the newpage has not been
> +		 * charged yet, so we must call end_migration() before
> +		 * remove_migration_ptes() to update stats of mapped file
> +		 * properly.
> +		 */
> +		mem_cgroup_end_migration(mem, page, newpage);
>  		remove_migration_ptes(page, newpage);
> -	else
> +	} else
>  		newpage->mapping = NULL;
> 
>  	unlock_page(newpage);
> @@ -633,7 +641,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> 
>  skip_unmap:
>  	if (!page_mapped(page))
> -		rc = move_to_new_page(newpage, page);
> +		rc = move_to_new_page(newpage, page, mem);

Why do we need to pass mem, won't try_get_mem_cgroup_from_page() help?
Is it cost versus space tradeoff.

> 
>  	if (rc)
>  		remove_migration_ptes(page, page);
> @@ -641,7 +649,8 @@ rcu_unlock:
>  	if (rcu_locked)
>  		rcu_read_unlock();
>  uncharge:
> -	if (!charge)
> +	if (rc)
> +		/* On success of page migration, we've alread called it */

Comment is not clear to me, but the code is :)

>  		mem_cgroup_end_migration(mem, page, newpage);
>  unlock:
>  	unlock_page(page);
> -- 
> 1.6.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
