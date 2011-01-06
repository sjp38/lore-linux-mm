Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 68BD46B0087
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 00:42:10 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p065apOe011058
	for <linux-mm@kvack.org>; Thu, 6 Jan 2011 16:36:51 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p065g5M52142286
	for <linux-mm@kvack.org>; Thu, 6 Jan 2011 16:42:06 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p065g5sY015629
	for <linux-mm@kvack.org>; Thu, 6 Jan 2011 16:42:05 +1100
Date: Thu, 6 Jan 2011 11:12:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH v3] memcg: fix memory migration of shmem
 swapcache
Message-ID: <20110106054200.GG3722@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110105130020.e2a854e4.nishimura@mxp.nes.nec.co.jp>
 <20110105115840.GD4654@cmpxchg.org>
 <20110106100923.24b1dd12.nishimura@mxp.nes.nec.co.jp>
 <AANLkTi=rp=WZa7PP4V6anU0SQ3BM-RJQwiDu1fJuoDig@mail.gmail.com>
 <20110106123415.895d6dfc.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110106123415.895d6dfc.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2011-01-06 12:34:15]:

> > > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > > index 159a076..cc5a8fd 100644
> > > --- a/include/linux/memcontrol.h
> > > +++ b/include/linux/memcontrol.h
> > > @@ -93,7 +93,7 @@ extern int
> > >  mem_cgroup_prepare_migration(struct page *page,
> > >        struct page *newpage, struct mem_cgroup **ptr);
> > >  extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
> > > -       struct page *oldpage, struct page *newpage);
> > > +       struct page *oldpage, struct page *newpage, bool success);
> > 
> > The term "success" implies present or future tense.
> > The event this variable cares about in the past so "succeed" might be
> > a more appropriate term.
> > Sorry to be picky about the English but there is an important
> > distinction here since we don't have any comment about the variable.
> > 
> > Am I being too fussy?
> Not at all. Your comments are very helpful to make the code more readable :)
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> In current implimentation, mem_cgroup_end_migration() decides whether the page
> migration has succeeded or not by checking "oldpage->mapping".
> 
> But if we are tring to migrate a shmem swapcache, the page->mapping of it is
> NULL from the begining, so the check would be invalid.
> As a result, mem_cgroup_end_migration() assumes the migration has succeeded
> even if it's not, so "newpage" would be freed while it's not uncharged.
> 
> This patch fixes it by passing mem_cgroup_end_migration() the result of the
> page migration.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> v2->v3
>   - s/success/succeed
> 
> v1->v2
>   - pass mem_cgroup_end_migration() "bool" instead of "int".
> 
>  include/linux/memcontrol.h |    5 ++---
>  mm/memcontrol.c            |    5 ++---
>  mm/migrate.c               |    2 +-
>  3 files changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 159a076..9f52b57 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -93,7 +93,7 @@ extern int
>  mem_cgroup_prepare_migration(struct page *page,
>  	struct page *newpage, struct mem_cgroup **ptr);
>  extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
> -	struct page *oldpage, struct page *newpage);
> +	struct page *oldpage, struct page *newpage, bool succeed);

Sorry for nit-picking but succeed is not as good as succeeded,
successful, successful_migration or migration_ok

> 
>  /*
>   * For memory reclaim.
> @@ -231,8 +231,7 @@ mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
>  }
> 
>  static inline void mem_cgroup_end_migration(struct mem_cgroup *mem,
> -					struct page *oldpage,
> -					struct page *newpage)
> +		struct page *oldpage, struct page *newpage, bool succeed)
>  {
>  }
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 61678be..71a39bc 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2856,7 +2856,7 @@ int mem_cgroup_prepare_migration(struct page *page,
> 
>  /* remove redundant charge if migration failed*/
>  void mem_cgroup_end_migration(struct mem_cgroup *mem,
> -	struct page *oldpage, struct page *newpage)
> +	struct page *oldpage, struct page *newpage, bool succeed)
>  {
>  	struct page *used, *unused;
>  	struct page_cgroup *pc;
> @@ -2865,8 +2865,7 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  		return;
>  	/* blocks rmdir() */
>  	cgroup_exclude_rmdir(&mem->css);
> -	/* at migration success, oldpage->mapping is NULL. */
> -	if (oldpage->mapping) {
> +	if (!succeed) {
>  		used = oldpage;
>  		unused = newpage;
>  	} else {
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 6ae8a66..be66b23 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -756,7 +756,7 @@ rcu_unlock:
>  		rcu_read_unlock();
>  uncharge:
>  	if (!charge)
> -		mem_cgroup_end_migration(mem, page, newpage);
> +		mem_cgroup_end_migration(mem, page, newpage, rc == 0);
>  unlock:
>  	unlock_page(page);
> 
> -- 
> 1.7.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
