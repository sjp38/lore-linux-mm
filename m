Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B67E38D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 18:17:42 -0500 (EST)
Date: Wed, 2 Mar 2011 18:17:27 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v5 9/9] memcg: check memcg dirty limits in page writeback
Message-ID: <20110302231727.GG2547@redhat.com>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
 <1298669760-26344-10-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298669760-26344-10-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>

On Fri, Feb 25, 2011 at 01:36:00PM -0800, Greg Thelen wrote:

[..]
> @@ -500,18 +527,27 @@ static void balance_dirty_pages(struct address_space *mapping,
>  		};
>  
>  		global_dirty_info(&sys_info);
> +		if (!memcg_dirty_info(NULL, &memcg_info))
> +			memcg_info = sys_info;
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

Greg, so currently we seem to have per_bdi/per_task dirty limits and
now with this patch it will sort of become per_cgroup/per_bdi/per_task
dirty limits? I think that kind of makes sense to me.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
