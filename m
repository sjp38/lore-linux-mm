Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 2FF466B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 22:18:21 -0500 (EST)
Date: Sat, 5 Jan 2013 11:18:17 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: fix writeback cache thrashing
Message-ID: <20130105031817.GA8650@localhost>
References: <1356847190-7986-1-git-send-email-linkinjeon@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1356847190-7986-1-git-send-email-linkinjeon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, liwanp@linux.vnet.ibm.com, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Jan Kara <jack@suse.cz>, Dave Chinner <dchinner@redhat.com>, Simon Jeons <simon.jeons@gmail.com>

Hi Namjae,

On Sun, Dec 30, 2012 at 02:59:50PM +0900, Namjae Jeon wrote:
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

Yeah, that IO pattern is not good. Perhaps it's 6 small IOs in /one/
second?  However that's not quite in line with "sleep 2sec" in your
workload description. Note that I assume flush-8:0 works on a hard
disk, so each flush-8:0 line indicates roughly 1 second interval
elapsed. It would be much more clear if the printk timestamps are
turned on (CONFIG_PRINTK_TIME=y).

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
> And It will be great if we can reserve a portion of writeback cache using
> min_ratio.
 
> After applying patch:
> $ echo 5 > /sys/block/sdb/bdi/min_ratio
> $ cat /sys/block/sdb/bdi/min_ratio
> 5

The below log looks all perfect. However the min_ratio setup is a
problem. If possible, I'd like the final patch being able to work
reasonably well with min_ratio=0 (the system default), too.

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
 
> As mentioned in the above logs, once cache is reserved for Process B,
> and patch is applied there is less writeback cache thrashing on sdb
> by frequent forced writeback by flush-8:16 in over_bground_thresh.
> 
> After all, small cached data will be flushed by periodic writeback
> once every dirty_writeback_interval.
> 
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

That global test should be kept in some form (see Jan's proposal).
Because the below per-bdi test can be inaccurate in various ways:

- bdi_stat() may have errors up to bdi_stat_error()

- bdi_dirty_limit() may be arbitrarily shifted by min_ratio etc.

- bdi_dirty_limit() may be totally wrong due to the estimation in
  bdi_writeout_fraction() is in its initial value 0, or is still
  trying to catch up with sudden workload changes.

>  	if (bdi_stat(bdi, BDI_RECLAIMABLE) >
>  				bdi_dirty_limit(bdi, background_thresh))
>  		return true;

I suspect even removing the global test as in your patch, the above
bdi test will still mostly return true for your described workload,
due to bdi_dirty_limit() returning a value close to 0, because the
writeout fraction of sdb is close to 0.

You cleverly avoided this in your test by raising min_ratio to 5.
However I'd suggest to test with min_ratio=0 and try solutions that
can work well in such default configuration.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
