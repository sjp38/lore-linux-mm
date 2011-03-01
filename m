Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 67D598D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 23:45:13 -0500 (EST)
Received: by pvg4 with SMTP id 4so1092619pvg.14
        for <linux-mm@kvack.org>; Mon, 28 Feb 2011 20:45:11 -0800 (PST)
Date: Tue, 1 Mar 2011 13:44:55 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v5 9/9] memcg: check memcg dirty limits in page
 writeback
Message-ID: <20110301044455.GB2107@barrios-desktop>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
 <1298669760-26344-10-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298669760-26344-10-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Fri, Feb 25, 2011 at 01:36:00PM -0800, Greg Thelen wrote:
> If the current process is in a non-root memcg, then
> balance_dirty_pages() will consider the memcg dirty limits as well as
> the system-wide limits.  This allows different cgroups to have distinct
> dirty limits which trigger direct and background writeback at different
> levels.
> 
> If called with a mem_cgroup, then throttle_vm_writeout() should query
> the given cgroup for its dirty memory usage limits.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
  
<snip>

>  /*
> @@ -477,12 +502,14 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
>   * data.  It looks at the number of dirty pages in the machine and will force
>   * the caller to perform writeback if the system is over `vm_dirty_ratio'.
>   * If we're over `background_thresh' then the writeback threads are woken to
> - * perform some writeout.
> + * perform some writeout.  The current task may have per-memcg dirty
> + * limits, which are also checked.
>   */
>  static void balance_dirty_pages(struct address_space *mapping,
>  				unsigned long write_chunk)
>  {
>  	struct dirty_info sys_info;
> +	struct dirty_info memcg_info;
>  	long bdi_nr_reclaimable;
>  	long bdi_nr_writeback;
>  	unsigned long bdi_thresh;
> @@ -500,18 +527,27 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		};
>  
>  		global_dirty_info(&sys_info);
> +		if (!memcg_dirty_info(NULL, &memcg_info))
> +			memcg_info = sys_info;


Sigh.

I don't like dobule check in case of no-memcg configuration or root memcgroup.
"Dobule check" means 1) sys_info check and 2) memcg_info check but it's same so
second check is redundant. 
In addition, we always need same logic between global and memcg.
It adds binary bloating.

>  
>  		/*
>  		 * Throttle it only when the background writeback cannot
>  		 * catch-up. This avoids (excessively) small writeouts
>  		 * when the bdi limits are ramping up.
>  		 */
> -		if (dirty_info_reclaimable(&sys_info) + sys_info.nr_writeback <=
> +		if ((dirty_info_reclaimable(&sys_info) +
> +		     sys_info.nr_writeback <=
>  				(sys_info.background_thresh +
> -				 sys_info.dirty_thresh) / 2)
> +				 sys_info.dirty_thresh) / 2) &&
> +		    (dirty_info_reclaimable(&memcg_info) +
> +		     memcg_info.nr_writeback <=
> +				(memcg_info.background_thresh +
> +				 memcg_info.dirty_thresh) / 2))
>  			break;
>  
> -		bdi_thresh = bdi_dirty_limit(bdi, sys_info.dirty_thresh);
> +		bdi_thresh = bdi_dirty_limit(bdi,
> +				min(sys_info.dirty_thresh,
> +				    memcg_info.dirty_thresh));
>  		bdi_thresh = task_dirty_limit(current, bdi_thresh);
>  
>  		/*
> @@ -541,7 +577,9 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		dirty_exceeded =
>  			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
>  			|| (dirty_info_reclaimable(&sys_info) +
> -			     sys_info.nr_writeback > sys_info.dirty_thresh);
> +			    sys_info.nr_writeback > sys_info.dirty_thresh)
> +			|| (dirty_info_reclaimable(&memcg_info) +
> +			    memcg_info.nr_writeback > memcg_info.dirty_thresh);
>  
>  		if (!dirty_exceeded)
>  			break;
> @@ -559,7 +597,9 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		 * up.
>  		 */
>  		trace_wbc_balance_dirty_start(&wbc, bdi);
> -		if (bdi_nr_reclaimable > bdi_thresh) {
> +		if ((bdi_nr_reclaimable > bdi_thresh) ||
> +		    (dirty_info_reclaimable(&memcg_info) >
> +		     memcg_info.dirty_thresh)) {

Why does memcg need this check?
I guess bdi_thresh is the f(x), x = dirty_thresh and dirty_thresh is already memcg's one.
So isn't it enough?
I don't know the logic well but as I look at the comment, at least you change the behavior.
Please write down why you need it and if you need it, please change comment, too.

"
 * Only move pages to writeback if this bdi is over its
 * threshold otherwise wait until the disk writes catch
 * up.
"

>  			writeback_inodes_wb(&bdi->wb, &wbc);
>  			pages_written += write_chunk - wbc.nr_to_write;
>  			trace_wbc_balance_dirty_written(&wbc, bdi);
> @@ -594,8 +634,10 @@ static void balance_dirty_pages(struct address_space *mapping,
>  	 * background_thresh, to keep the amount of dirty memory low.
>  	 */
>  	if ((laptop_mode && pages_written) ||
> -	    (!laptop_mode && (dirty_info_reclaimable(&sys_info) >
> -			      sys_info.background_thresh)))
> +	    (!laptop_mode && ((dirty_info_reclaimable(&sys_info) >
> +			       sys_info.background_thresh) ||
> +			      (dirty_info_reclaimable(&memcg_info) >
> +			       memcg_info.background_thresh))))
>  		bdi_start_background_writeback(bdi);
>  }
>  
> @@ -653,12 +695,20 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
>  }
>  EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
>  
> -void throttle_vm_writeout(gfp_t gfp_mask)
> +/*
> + * Throttle the current task if it is near dirty memory usage limits.
> + * If @mem_cgroup is NULL or the root_cgroup, then use global dirty memory
> + * information; otherwise use the per-memcg dirty limits.
> + */
> +void throttle_vm_writeout(gfp_t gfp_mask, struct mem_cgroup *mem_cgroup)
>  {
>  	struct dirty_info sys_info;
> +	struct dirty_info memcg_info;
>  
>          for ( ; ; ) {
>  		global_dirty_info(&sys_info);
> +		if (!memcg_dirty_info(mem_cgroup, &memcg_info))
> +			memcg_info = sys_info;
>  
>                  /*
>                   * Boost the allowable dirty threshold a bit for page
> @@ -666,9 +716,13 @@ void throttle_vm_writeout(gfp_t gfp_mask)
>                   */
>  		sys_info.dirty_thresh +=
>  			sys_info.dirty_thresh / 10;      /* wheeee... */
> +		memcg_info.dirty_thresh +=
> +			memcg_info.dirty_thresh / 10;    /* wheeee... */
>  
> -		if (sys_info.nr_unstable_nfs +
> -		    sys_info.nr_writeback <= sys_info.dirty_thresh)
> +		if ((sys_info.nr_unstable_nfs +
> +		     sys_info.nr_writeback <= sys_info.dirty_thresh) &&
> +		    (memcg_info.nr_unstable_nfs +
> +		     memcg_info.nr_writeback <= memcg_info.dirty_thresh))
>  			break;
>                  congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ba11e28..f723242 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1927,7 +1927,7 @@ restart:
>  					sc->nr_scanned - nr_scanned, sc))
>  		goto restart;
>  
> -	throttle_vm_writeout(sc->gfp_mask);
> +	throttle_vm_writeout(sc->gfp_mask, sc->mem_cgroup);
>  }
>  
>  /*
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
