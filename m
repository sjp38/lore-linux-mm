Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 2B5266B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 09:07:40 -0500 (EST)
Date: Thu, 19 Jan 2012 15:07:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] [PATCH 5/7 v2] memcg: remove PCG_FILE_MAPPED
Message-ID: <20120119140737.GD13932@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
 <20120113174223.aaf5a80c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120113174223.aaf5a80c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Fri 13-01-12 17:42:23, KAMEZAWA Hiroyuki wrote:
> From a9b51d6204d7f8714173c46a306caf413ad25d4e Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 12 Jan 2012 18:40:26 +0900
> Subject: [PATCH 5/7] memcg: remove PCG_FILE_MAPPED
> 
> Because we can update page's status and memcg's statistics without
> race with move_account, this flag is unnecessary.

I would really appreciate a little bit more description ;)

8725d541 [memcg: fix race in file_mapped accounting] has added the
flag to resolve a race when a move_account happened between page's
mapcount has been updated and this has been accounted to memcg.
This, however, cannot happen anymore because mem_cgroup_update_page_stat
is always enclosed by mem_cgroup_begin_update_page_stat and
mem_cgroup_end_update_page_stat along with the mapcount update.

> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Other than that looks good and nice to see another one go away.
I will add my ack along with the patches which this depend on once they
settle down if you don't mind

Thanks

> ---
>  include/linux/page_cgroup.h |    6 ------
>  mm/memcontrol.c             |    6 +-----
>  2 files changed, 1 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 5dba799..0b9a48a 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -7,8 +7,6 @@ enum {
>  	PCG_CACHE, /* charged as cache */
>  	PCG_USED, /* this object is in use. */
>  	PCG_MIGRATION, /* under page migration */
> -	/* flags for mem_cgroup and file and I/O status */
> -	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
>  	__NR_PCG_FLAGS,
>  };
>  
> @@ -72,10 +70,6 @@ TESTPCGFLAG(Used, USED)
>  CLEARPCGFLAG(Used, USED)
>  SETPCGFLAG(Used, USED)
>  
> -SETPCGFLAG(FileMapped, FILE_MAPPED)
> -CLEARPCGFLAG(FileMapped, FILE_MAPPED)
> -TESTPCGFLAG(FileMapped, FILE_MAPPED)
> -
>  SETPCGFLAG(Migration, MIGRATION)
>  CLEARPCGFLAG(Migration, MIGRATION)
>  TESTPCGFLAG(Migration, MIGRATION)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 30ef810..a96800d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1952,10 +1952,6 @@ void mem_cgroup_update_page_stat(struct page *page,
>  
>  	switch (idx) {
>  	case MEMCG_NR_FILE_MAPPED:
> -		if (val > 0)
> -			SetPageCgroupFileMapped(pc);
> -		else if (!page_mapped(page))
> -			ClearPageCgroupFileMapped(pc);
>  		idx = MEM_CGROUP_STAT_FILE_MAPPED;
>  		break;
>  	default:
> @@ -2606,7 +2602,7 @@ static int mem_cgroup_move_account(struct page *page,
>  
>  	mem_cgroup_account_move_wlock(page, &flags);
>  
> -	if (PageCgroupFileMapped(pc)) {
> +	if (page_mapcount(page)) {
>  		/* Update mapped_file data for mem_cgroup */
>  		preempt_disable();
>  		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
