Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 53ECB6B0070
	for <linux-mm@kvack.org>; Mon, 31 Dec 2012 06:30:59 -0500 (EST)
Date: Mon, 31 Dec 2012 12:30:54 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] writeback: fix writeback cache thrashing
Message-ID: <20121231113054.GC7564@quack.suse.cz>
References: <1356847190-7986-1-git-send-email-linkinjeon@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1356847190-7986-1-git-send-email-linkinjeon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: fengguang.wu@intel.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, liwanp@linux.vnet.ibm.com, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Jan Kara <jack@suse.cz>, Dave Chinner <dchinner@redhat.com>

On Sun 30-12-12 14:59:50, Namjae Jeon wrote:
> From: Namjae Jeon <namjae.jeon@samsung.com>
> 
> Consider Process A: huge I/O on sda
>         doing heavy write operation - dirty memory becomes more
>         than dirty_background_ratio
>         on HDD - flusher thread flush-8:0
> 
> Consider Process B: small I/O on sdb
>         doing while [1]; read 1024K + rewrite 1024K + sleep 2sec
>         on Flash device - flusher thread flush-8:16
> 
> As Process A is a heavy dirtier, dirty memory becomes more
> than dirty_background_thresh. Due to this, below check becomes
> true(checking global_page_state in over_bground_thresh)
> for all bdi devices(even for very small dirtied bdi - sdb):
> 
> In this case, even small cached data on 'sdb' is forced to flush
> and writeback cache thrashing happens.
> 
> When we added debug prints inside above 'if' condition and ran
> above Process A(heavy dirtier on bdi with flush-8:0) and
> Process B(1024K frequent read/rewrite on bdi with flush-8:16)
> we got below prints:
> 
> [Test setup: ARM dual core CPU, 512 MB RAM]
> 
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  56064 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  56704 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 84720 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 94720 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   384 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   960 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =    64 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 92160 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   256 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   768 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =    64 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   256 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   320 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =     0 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 92032 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 91968 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   192 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =  1024 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =    64 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   192 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   576 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =     0 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 84352 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   192 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =   512 KB
> [over_bground_thresh]: wakeup flush-8:16 : BDI_RECLAIMABLE =     0 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 92608 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE = 92544 KB
> 
> As mentioned in above log, when global dirty memory > global background_thresh
> small cached data is also forced to flush by flush-8:16.
> 
> If removing global background_thresh checking code, we can reduce cache
> thrashing of frequently used small data.
  It's not completely clear to me:
  Why is this a problem? Wearing of the flash? Power consumption? I'd like
to understand this before changing the code...

> And It will be great if we can reserve a portion of writeback cache using
> min_ratio.
> 
> After applying patch:
> $ echo 5 > /sys/block/sdb/bdi/min_ratio
> $ cat /sys/block/sdb/bdi/min_ratio
> 5
> 
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  56064 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  56704 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  84160 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  96960 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  94080 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  93120 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  93120 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  91520 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  89600 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  93696 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  93696 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  72960 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  90624 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  90624 KB
> [over_bground_thresh]: wakeup flush-8:0 : BDI_RECLAIMABLE =  90688 KB
> 
> As mentioned in the above logs, once cache is reserved for Process B,
> and patch is applied there is less writeback cache thrashing on sdb
> by frequent forced writeback by flush-8:16 in over_bground_thresh.
> 
> After all, small cached data will be flushed by periodic writeback
> once every dirty_writeback_interval.
  OK, in principle something like this makes sence to me. But if there are
more BDIs which are roughly equally used, it could happen none of them are
over threshold due to percpu counter & rounding errors. So I'd rather
change the conditions to something like:
	reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
	bdi_bground_thresh = bdi_dirty_limit(bdi, background_thresh);

  	if (reclaimable > bdi_bground_thresh)
		return true;
	/*
	 * If global background limit is exceeded, kick the writeback on
	 * BDI if there's a reasonable amount of data to write (at least
	 * 1/2 of BDI's background dirty limit).
	 */
	if (global_page_state(NR_FILE_DIRTY) +
	    global_page_state(NR_UNSTABLE_NFS) > background_thresh &&
	    reclaimable * 2 > bdi_bground_thresh)
		return true;

								Honza

> Suggested-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>
> Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
> Cc: Fengguang Wu <fengguang.wu@intel.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/fs-writeback.c |    4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 310972b..070b773 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -756,10 +756,6 @@ static bool over_bground_thresh(struct backing_dev_info *bdi)
>  
>  	global_dirty_limits(&background_thresh, &dirty_thresh);
>  
> -	if (global_page_state(NR_FILE_DIRTY) +
> -	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
> -		return true;
> -
>  	if (bdi_stat(bdi, BDI_RECLAIMABLE) >
>  				bdi_dirty_limit(bdi, background_thresh))
>  		return true;
> -- 
> 1.7.9.5
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
