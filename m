Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 686DB6B0142
	for <linux-mm@kvack.org>; Sat, 18 Feb 2012 08:39:12 -0500 (EST)
Date: Sat, 18 Feb 2012 14:39:04 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/6] memcg: remove PCG_FILE_MAPPED
Message-ID: <20120218133904.GA1678@cmpxchg.org>
References: <20120217182426.86aebfde.kamezawa.hiroyu@jp.fujitsu.com>
 <20120217182818.f3e7fe28.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120217182818.f3e7fe28.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>

On Fri, Feb 17, 2012 at 06:28:18PM +0900, KAMEZAWA Hiroyuki wrote:
> >From a19a8eae9c2a3dabb25a50c7a1b2e3a183935260 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 2 Feb 2012 15:02:18 +0900
> Subject: [PATCH 5/6] memcg: remove PCG_FILE_MAPPED
> 
> with new lock scheme for updating memcg's page stat, we don't need
> a flag PCG_FILE_MAPPED which was duplicated information of page_mapped().
> 
> Acked-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/page_cgroup.h |    6 ------
>  mm/memcontrol.c             |    6 +-----
>  2 files changed, 1 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 7a3af74..a88cdba 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -6,8 +6,6 @@ enum {
>  	PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
>  	PCG_USED, /* this object is in use. */
>  	PCG_MIGRATION, /* under page migration */
> -	/* flags for mem_cgroup and file and I/O status */
> -	PCG_FILE_MAPPED, /* page is accounted as "mapped" */
>  	__NR_PCG_FLAGS,
>  };
>  
> @@ -66,10 +64,6 @@ TESTPCGFLAG(Used, USED)
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
> index 86bdde0..e19cffb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1935,10 +1935,6 @@ void mem_cgroup_update_page_stat(struct page *page,
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
> @@ -2559,7 +2555,7 @@ static int mem_cgroup_move_account(struct page *page,
>  
>  	move_lock_mem_cgroup(from, &flags);
>  
> -	if (PageCgroupFileMapped(pc)) {
> +	if (page_mapped(page)) {

As opposed to update_page_stat(), this runs against all types of
pages, so I think it should be

	if (!PageAnon(page) && page_mapped(page))

instead.

>  		/* Update mapped_file data for mem_cgroup */
>  		preempt_disable();
>  		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
