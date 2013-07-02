Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 5656F6B0031
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 15:38:06 -0400 (EDT)
Date: Tue, 2 Jul 2013 12:38:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: strictlimit feature -v2
Message-Id: <20130702123804.9f252487f86c12b0f4edee57@linux-foundation.org>
In-Reply-To: <20130702174316.15075.84993.stgit@maximpc.sw.ru>
References: <20130629174706.20175.78184.stgit@maximpc.sw.ru>
	<20130702174316.15075.84993.stgit@maximpc.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <MPatlasov@parallels.com>
Cc: miklos@szeredi.hu, riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

On Tue, 02 Jul 2013 21:44:47 +0400 Maxim Patlasov <MPatlasov@parallels.com> wrote:

> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> The feature prevents mistrusted filesystems to grow a large number of dirty
> pages before throttling. For such filesystems balance_dirty_pages always
> check bdi counters against bdi limits. I.e. even if global "nr_dirty" is under
> "freerun", it's not allowed to skip bdi checks. The only use case for now is
> fuse: it sets bdi max_ratio to 1% by default and system administrators are
> supposed to expect that this limit won't be exceeded.
> 
> The feature is on if address space is marked by AS_STRICTLIMIT flag.
> A filesystem may set the flag when it initializes a new inode.
> 
> Changed in v2 (thanks to Andrew Morton):
>  - added a few explanatory comments
>  - cleaned up the mess in backing_dev_info foo_stamp fields: now it's clearly
>    stated that bw_time_stamp is measured in jiffies; renamed other foo_stamp
>    fields to reflect that they are in units of number-of-pages.
> 

Better, thanks.

The writeback arithemtic makes my head spin - I'd really like Fengguang
to go over this, please.

A quick visit from the spelling police:

>
> ...
>
> @@ -41,8 +43,15 @@ typedef int (congested_fn)(void *, int);
>  enum bdi_stat_item {
>  	BDI_RECLAIMABLE,
>  	BDI_WRITEBACK,
> -	BDI_DIRTIED,
> -	BDI_WRITTEN,
> +
> +	/*
> +	 * The three counters below reflects number of events of specific type
> +	 * happened since bdi_init(). The type is defined in comments below:

"The three counters below reflect the number of events of specific
types since bdi_init()"

> +	 */
> +	BDI_DIRTIED,	  /* a page was dirtied */
> +	BDI_WRITTEN,	  /* writeout completed for a page */
> +	BDI_WRITTEN_BACK, /* a page went to writeback */
> +
>  	NR_BDI_STAT_ITEMS
>  };
>  
>
> ...
>
> @@ -680,28 +712,55 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
>  		return 0;
>  
>  	/*
> -	 * global setpoint
> +	 * The strictlimit feature is a tool preventing mistrusted filesystems
> +	 * to grow a large number of dirty pages before throttling. For such

"from growing"

> +	 * filesystems balance_dirty_pages always checks bdi counters against
> +	 * bdi limits. Even if global "nr_dirty" is under "freerun". This is
> +	 * especially important for fuse who sets bdi->max_ratio to 1% by

s/who/which/

> +	 * default. Without strictlimit feature, fuse writeback may consume
> +	 * arbitrary amount of RAM because it is accounted in
> +	 * NR_WRITEBACK_TEMP which is not involved in calculating "nr_dirty".
>
> ...
>
> @@ -994,6 +1054,26 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
>  	 * keep that period small to reduce time lags).
>  	 */
>  	step = 0;
> +
> +	/*
> +	 * For strictlimit case, balanced_dirty_ratelimit was calculated

balance_dirty_ratelimit?

> +	 * above based on bdi counters and limits (see bdi_position_ratio()).
> +	 * Hence, to calculate "step" properly, we have to use bdi_dirty as
> +	 * "dirty" and bdi_setpoint as "setpoint".
> +	 *
> +	 * We rampup dirty_ratelimit forcibly if bdi_dirty is low because
> +	 * it's possible that bdi_thresh is close to zero due to inactivity
> +	 * of backing device (see the implementation of bdi_dirty_limit()).
> +	 */
> +	if (unlikely(strictlimit)) {
> +		dirty = bdi_dirty;
> +		if (bdi_dirty < 8)
> +			setpoint = bdi_dirty + 1;
> +		else
>
> ...
>
> @@ -1057,18 +1140,32 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
>  	if (elapsed > HZ && time_before(bdi->bw_time_stamp, start_time))
>  		goto snapshot;
>  
> +	/*
> +	 * Skip periods when backing dev was idle due to abscence of pages

"absence"

> +	 * under writeback (when over_bground_thresh() returns false)
> +	 */
> +	if (test_bit(BDI_idle, &bdi->state) &&
> +	    bdi->writeback_nr_stamp == writeback)
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
