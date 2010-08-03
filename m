Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B48206008E4
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 23:58:46 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7341OcS018309
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 22:01:24 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o73437t1043864
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 22:03:09 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o73437hC030116
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 22:03:07 -0600
Date: Tue, 3 Aug 2010 09:33:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mm 4/5] memcg generic file stat accounting interface.
Message-ID: <20100803040304.GG3863@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100802191715.63ce81ed.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100802191715.63ce81ed.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-02 19:17:15]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Preparing for adding new status arounf file caches.(dirty, writeback,etc..)
> Using a unified macro and more generic names.
> All counters will have the same rule for updating.
> 
> Changelog:
>  - clean up and moved mem_cgroup_stat_index to header file.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h  |   23 ++++++++++++++++++++++
>  include/linux/page_cgroup.h |   12 +++++------
>  mm/memcontrol.c             |   46 ++++++++++++++++++--------------------------
>  3 files changed, 48 insertions(+), 33 deletions(-)
> 
> Index: mmotm-0727/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-0727.orig/include/linux/memcontrol.h
> +++ mmotm-0727/include/linux/memcontrol.h
> @@ -25,6 +25,29 @@ struct page_cgroup;
>  struct page;
>  struct mm_struct;
> 
> +/*
> + * Per-cpu Statistics for memory cgroup.
> + */
> +enum mem_cgroup_stat_index {
> +	/*
> +	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> +	 */
> +	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
> +	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> +	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> +	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> +	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> +	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> +	MEM_CGROUP_ON_MOVE,   /* A check for locking move account/status */
> +	/* About file-stat please see memcontrol.h */

Isn't this memcontrol.h?

> +	MEM_CGROUP_FSTAT_BASE,
> +	MEM_CGROUP_FSTAT_FILE_MAPPED = MEM_CGROUP_FSTAT_BASE,
> +	MEM_CGROUP_FSTAT_END,
> +	MEM_CGROUP_STAT_NSTATS = MEM_CGROUP_FSTAT_END,
> +};
> +
> +#define MEMCG_FSTAT_IDX(idx)	((idx) - MEM_CGROUP_FSTAT_BASE)
> +
>  extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>  					struct list_head *dst,
>  					unsigned long *scanned, int order,
> Index: mmotm-0727/mm/memcontrol.c
> ===================================================================
> --- mmotm-0727.orig/mm/memcontrol.c
> +++ mmotm-0727/mm/memcontrol.c
> @@ -74,24 +74,6 @@ static int really_do_swap_account __init
>  #define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */
>  #define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
> 
> -/*
> - * Statistics for memory cgroup.
> - */
> -enum mem_cgroup_stat_index {
> -	/*
> -	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
> -	 */
> -	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
> -	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> -	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> -	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
> -	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
> -	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> -	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> -	MEM_CGROUP_ON_MOVE,   /* A check for locking move account/status */
> -
> -	MEM_CGROUP_STAT_NSTATS,
> -};
> 
>  struct mem_cgroup_stat_cpu {
>  	s64 count[MEM_CGROUP_STAT_NSTATS];
> @@ -1512,7 +1494,8 @@ bool mem_cgroup_handle_oom(struct mem_cg
>   * Currently used to update mapped file statistics, but the routine can be
>   * generalized to update other statistics as well.
>   */
> -void mem_cgroup_update_file_mapped(struct page *page, int val)
> +static void
> +mem_cgroup_update_file_stat(struct page *page, unsigned int idx, int val)
>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc;
> @@ -1536,11 +1519,11 @@ void mem_cgroup_update_file_mapped(struc
>  	if (unlikely(!PageCgroupUsed(pc)))
>  		goto done;
>  	if (val > 0) {
> -		this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> -		SetPageCgroupFileMapped(pc);
> +		this_cpu_inc(mem->stat->count[idx]);
> +		set_bit(fflag_idx(MEMCG_FSTAT_IDX(idx)), &pc->flags);

Do we use the bit in pc->flags, otherwise is there an advantage of
creating a separate index for the other stats the block I/O needs?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
