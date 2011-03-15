Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 562408D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 18:54:29 -0400 (EDT)
Date: Tue, 15 Mar 2011 18:54:09 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v6 9/9] memcg: make background writeback memcg aware
Message-ID: <20110315225409.GD5740@redhat.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
 <1299869011-26152-10-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299869011-26152-10-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>

On Fri, Mar 11, 2011 at 10:43:31AM -0800, Greg Thelen wrote:
> Add an memcg parameter to bdi_start_background_writeback().  If a memcg
> is specified then the resulting background writeback call to
> wb_writeback() will run until the memcg dirty memory usage drops below
> the memcg background limit.  This is used when balancing memcg dirty
> memory with mem_cgroup_balance_dirty_pages().
> 
> If the memcg parameter is not specified, then background writeback runs
> globally system dirty memory usage falls below the system background
> limit.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---

[..]
> -static inline bool over_bground_thresh(void)
> +static inline bool over_bground_thresh(struct mem_cgroup *mem_cgroup)
>  {
>  	unsigned long background_thresh, dirty_thresh;
>  
> +	if (mem_cgroup) {
> +		struct dirty_info info;
> +
> +		if (!mem_cgroup_hierarchical_dirty_info(
> +			    determine_dirtyable_memory(), false,
> +			    mem_cgroup, &info))
> +			return false;
> +
> +		return info.nr_file_dirty +
> +			info.nr_unstable_nfs > info.background_thresh;
> +	}
> +
>  	global_dirty_limits(&background_thresh, &dirty_thresh);
>  
>  	return (global_page_state(NR_FILE_DIRTY) +
> @@ -683,7 +694,8 @@ static long wb_writeback(struct bdi_writeback *wb,
>  		 * For background writeout, stop when we are below the
>  		 * background dirty threshold
>  		 */
> -		if (work->for_background && !over_bground_thresh())
> +		if (work->for_background &&
> +		    !over_bground_thresh(work->mem_cgroup))
>  			break;
>  
>  		wbc.more_io = 0;
> @@ -761,23 +773,6 @@ static unsigned long get_nr_dirty_pages(void)
>  		get_nr_dirty_inodes();
>  }
>  
> -static long wb_check_background_flush(struct bdi_writeback *wb)
> -{
> -	if (over_bground_thresh()) {
> -
> -		struct wb_writeback_work work = {
> -			.nr_pages	= LONG_MAX,
> -			.sync_mode	= WB_SYNC_NONE,
> -			.for_background	= 1,
> -			.range_cyclic	= 1,
> -		};
> -
> -		return wb_writeback(wb, &work);
> -	}
> -
> -	return 0;
> -}
> -
>  static long wb_check_old_data_flush(struct bdi_writeback *wb)
>  {
>  	unsigned long expired;
> @@ -839,15 +834,17 @@ long wb_do_writeback(struct bdi_writeback *wb, int force_wait)
>  		 */
>  		if (work->done)
>  			complete(work->done);
> -		else
> +		else {
> +			if (work->mem_cgroup)
> +				mem_cgroup_bg_writeback_done(work->mem_cgroup);
>  			kfree(work);
> +		}
>  	}
>  
>  	/*
>  	 * Check for periodic writeback, kupdated() style
>  	 */
>  	wrote += wb_check_old_data_flush(wb);
> -	wrote += wb_check_background_flush(wb);

Hi Greg,

So in the past we will leave the background work unfinished and try
to finish queued work first.

I see following line in wb_writeback().

                /*
                 * Background writeout and kupdate-style writeback may
                 * run forever. Stop them if there is other work to do
                 * so that e.g. sync can proceed. They'll be restarted
                 * after the other works are all done.
                 */
                if ((work->for_background || work->for_kupdate) &&
                    !list_empty(&wb->bdi->work_list))
                        break;

Now you seem to have converted background writeout also as queued 
work item. So it sounds wb_writebac() will finish that background
work early and never take it up and finish other queued items. So
we might finish queued items still flusher thread might exit
without bringing down the background ratio of either root or memcg
depending on the ->mem_cgroup pointer.

May be requeuing the background work at the end of list might help.

Thanks
Vivek 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
