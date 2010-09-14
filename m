Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 862946B004A
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 08:46:46 -0400 (EDT)
Date: Tue, 14 Sep 2010 14:45:55 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/4] writeback: integrated background work
Message-ID: <20100914124555.GB4874@quack.suse.cz>
References: <20100913123110.372291929@intel.com>
 <20100913130149.849935145@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="yEPQxsgoJgBvi8ip"
Content-Disposition: inline
In-Reply-To: <20100913130149.849935145@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


--yEPQxsgoJgBvi8ip
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon 13-09-10 20:31:11, Wu Fengguang wrote:
> Check background work whenever the flusher thread wakes up.  The page
> reclaim code may lower the soft dirty limit immediately before sending
> some work to the flusher thread.
> 
> This is also the prerequisite of next patch.
  I have a patch doing something functionally rather similar but it also
cleans up the code which isn't necessary after this patch. So could you
maybe consider using that one?
  BTW: What has happened with your patch which started writing back old
inodes?

								Honza
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c |   18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> --- linux-next.orig/fs/fs-writeback.c	2010-09-13 19:41:21.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2010-09-13 19:49:11.000000000 +0800
> @@ -716,6 +716,23 @@ get_next_work_item(struct backing_dev_in
>  	return work;
>  }
>  
> +static long wb_check_background_flush(struct bdi_writeback *wb)
> +{
> +	if (over_bground_thresh()) {
> +
> +		struct wb_writeback_work work = {
> +			.nr_pages	= LONG_MAX,
> +			.sync_mode	= WB_SYNC_NONE,
> +			.for_background	= 1,
> +			.range_cyclic	= 1,
> +		};
> +
> +		return wb_writeback(wb, &work);
> +	}
> +
> +	return 0;
> +}
> +
>  static long wb_check_old_data_flush(struct bdi_writeback *wb)
>  {
>  	unsigned long expired;
> @@ -787,6 +804,7 @@ long wb_do_writeback(struct bdi_writebac
>  	 * Check for periodic writeback, kupdated() style
>  	 */
>  	wrote += wb_check_old_data_flush(wb);
> +	wrote += wb_check_background_flush(wb);
>  	clear_bit(BDI_writeback_running, &wb->bdi->state);
>  
>  	return wrote;
> 
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--yEPQxsgoJgBvi8ip
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-mm-Check-whether-background-writeback-is-needed-afte.patch"


--yEPQxsgoJgBvi8ip--
