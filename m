Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 24FC58D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 11:47:43 -0500 (EST)
Received: by pzk33 with SMTP id 33so750574pzk.14
        for <linux-mm@kvack.org>; Sun, 27 Feb 2011 08:47:41 -0800 (PST)
Date: Mon, 28 Feb 2011 01:47:30 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v5 5/9] memcg: add dirty page accounting infrastructure
Message-ID: <20110227164730.GD3226@barrios-desktop>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
 <1298669760-26344-6-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298669760-26344-6-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Fri, Feb 25, 2011 at 01:35:56PM -0800, Greg Thelen wrote:
> Add memcg routines to track dirty, writeback, and unstable_NFS pages.
> These routines are not yet used by the kernel to count such pages.
> A later change adds kernel calls to these new routines.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
> Changelog since v1:
> - Renamed "nfs"/"total_nfs" to "nfs_unstable"/"total_nfs_unstable" in per cgroup
>   memory.stat to match /proc/meminfo.
> - Rename (for clarity):
>   - mem_cgroup_write_page_stat_item -> mem_cgroup_page_stat_item
>   - mem_cgroup_read_page_stat_item -> mem_cgroup_nr_pages_item
> - Remove redundant comments.
> - Made mem_cgroup_move_account_page_stat() inline.
> 
>  include/linux/memcontrol.h |    5 ++-
>  mm/memcontrol.c            |   87 ++++++++++++++++++++++++++++++++++++++++----
>  2 files changed, 83 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 3da48ae..e1f70a9 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -25,9 +25,12 @@ struct page_cgroup;
>  struct page;
>  struct mm_struct;
>  
> -/* Stats that can be updated by kernel. */
> +/* mem_cgroup page counts accessed by kernel. */

I confused by 'kernel', 'access'?
So, What's the page counts accessed by user?
I don't like such words.

Please, clarify the comment.
'Stats of page that can be tracking by memcg' or whatever.

>  enum mem_cgroup_page_stat_item {
>  	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
> +	MEMCG_NR_FILE_DIRTY, /* # of dirty pages in page cache */
> +	MEMCG_NR_FILE_WRITEBACK, /* # of pages under writeback */
> +	MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
>  };
>  
>  extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1c2704a..38f786b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -92,8 +92,11 @@ enum mem_cgroup_stat_index {
>  	 */
>  	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
>  	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
> -	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> +	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
> +	MEM_CGROUP_STAT_FILE_DIRTY,	/* # of dirty pages in page cache */
> +	MEM_CGROUP_STAT_FILE_WRITEBACK,		/* # of pages under writeback */
> +	MEM_CGROUP_STAT_FILE_UNSTABLE_NFS,	/* # of NFS unstable pages */
>  	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
>  	MEM_CGROUP_ON_MOVE,	/* someone is moving account between groups */
>  	MEM_CGROUP_STAT_NSTATS,
> @@ -1622,6 +1625,44 @@ void mem_cgroup_update_page_stat(struct page *page,
>  			ClearPageCgroupFileMapped(pc);
>  		idx = MEM_CGROUP_STAT_FILE_MAPPED;
>  		break;
> +
> +	case MEMCG_NR_FILE_DIRTY:
> +		/* Use Test{Set,Clear} to only un/charge the memcg once. */
> +		if (val > 0) {
> +			if (TestSetPageCgroupFileDirty(pc))
> +				val = 0;
> +		} else {
> +			if (!TestClearPageCgroupFileDirty(pc))
> +				val = 0;
> +		}
> +		idx = MEM_CGROUP_STAT_FILE_DIRTY;
> +		break;
> +
> +	case MEMCG_NR_FILE_WRITEBACK:
> +		/*
> +		 * This counter is adjusted while holding the mapping's
> +		 * tree_lock.  Therefore there is no race between settings and
> +		 * clearing of this flag.
> +		 */
> +		if (val > 0)
> +			SetPageCgroupFileWriteback(pc);
> +		else
> +			ClearPageCgroupFileWriteback(pc);
> +		idx = MEM_CGROUP_STAT_FILE_WRITEBACK;
> +		break;
> +
> +	case MEMCG_NR_FILE_UNSTABLE_NFS:
> +		/* Use Test{Set,Clear} to only un/charge the memcg once. */
> +		if (val > 0) {
> +			if (TestSetPageCgroupFileUnstableNFS(pc))
> +				val = 0;
> +		} else {
> +			if (!TestClearPageCgroupFileUnstableNFS(pc))
> +				val = 0;
> +		}
> +		idx = MEM_CGROUP_STAT_FILE_UNSTABLE_NFS;
> +		break;

This part can be simplified by some macro work.
But it's another issue.

> +
>  	default:
>  		BUG();
>  	}
> @@ -2181,6 +2222,17 @@ void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
>  }
>  #endif
>  
> +static inline
> +void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
> +				       struct mem_cgroup *to,
> +				       enum mem_cgroup_stat_index idx)
> +{
> +	preempt_disable();
> +	__this_cpu_dec(from->stat->count[idx]);
> +	__this_cpu_inc(to->stat->count[idx]);
> +	preempt_enable();
> +}
> +
>  /**
>   * mem_cgroup_move_account - move account of the page
>   * @page: the page
> @@ -2229,13 +2281,18 @@ static int mem_cgroup_move_account(struct page *page,
>  
>  	move_lock_page_cgroup(pc, &flags);
>  
> -	if (PageCgroupFileMapped(pc)) {
> -		/* Update mapped_file data for mem_cgroup */
> -		preempt_disable();
> -		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> -		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
> -		preempt_enable();
> -	}
> +	if (PageCgroupFileMapped(pc))
> +		mem_cgroup_move_account_page_stat(from, to,
> +					MEM_CGROUP_STAT_FILE_MAPPED);
> +	if (PageCgroupFileDirty(pc))
> +		mem_cgroup_move_account_page_stat(from, to,
> +					MEM_CGROUP_STAT_FILE_DIRTY);
> +	if (PageCgroupFileWriteback(pc))
> +		mem_cgroup_move_account_page_stat(from, to,
> +					MEM_CGROUP_STAT_FILE_WRITEBACK);
> +	if (PageCgroupFileUnstableNFS(pc))
> +		mem_cgroup_move_account_page_stat(from, to,
> +					MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
>  	mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -nr_pages);
>  	if (uncharge)
>  		/* This is not "cancel", but cancel_charge does all we need. */
> @@ -3681,6 +3738,9 @@ enum {
>  	MCS_PGPGIN,
>  	MCS_PGPGOUT,
>  	MCS_SWAP,
> +	MCS_FILE_DIRTY,
> +	MCS_WRITEBACK,
> +	MCS_UNSTABLE_NFS,
>  	MCS_INACTIVE_ANON,
>  	MCS_ACTIVE_ANON,
>  	MCS_INACTIVE_FILE,
> @@ -3703,6 +3763,9 @@ struct {
>  	{"pgpgin", "total_pgpgin"},
>  	{"pgpgout", "total_pgpgout"},
>  	{"swap", "total_swap"},
> +	{"dirty", "total_dirty"},
> +	{"writeback", "total_writeback"},
> +	{"nfs_unstable", "total_nfs_unstable"},
>  	{"inactive_anon", "total_inactive_anon"},
>  	{"active_anon", "total_active_anon"},
>  	{"inactive_file", "total_inactive_file"},
> @@ -3732,6 +3795,14 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
>  		s->stat[MCS_SWAP] += val * PAGE_SIZE;
>  	}
>  
> +	/* dirty stat */
> +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_DIRTY);
> +	s->stat[MCS_FILE_DIRTY] += val * PAGE_SIZE;
> +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_WRITEBACK);
> +	s->stat[MCS_WRITEBACK] += val * PAGE_SIZE;
> +	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_UNSTABLE_NFS);
> +	s->stat[MCS_UNSTABLE_NFS] += val * PAGE_SIZE;
> +
>  	/* per zone stat */
>  	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
>  	s->stat[MCS_INACTIVE_ANON] += val * PAGE_SIZE;
> -- 
> 1.7.3.1
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
