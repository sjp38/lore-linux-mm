Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 718556B004F
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 21:48:07 -0400 (EDT)
Date: Wed, 23 Sep 2009 09:48:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Message-ID: <20090923014802.GA11491@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Subject: Re: [RESEND] [PATCH] readahead:add blk_run_backing_dev
Reply-To: 
In-Reply-To: <20090922135838.33ebe36b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ronald Moesbergen <intercommit@gmail.com>, Vladislav Bolkhovitin <vst@vlnb.net>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 23, 2009 at 04:58:38AM +0800, Andrew Morton wrote:
> On Fri, 29 May 2009 14:35:55 +0900
> Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp> wrote:
> 
> > I added blk_run_backing_dev on page_cache_async_readahead
> > so readahead I/O is unpluged to improve throughput on 
> > especially RAID environment. 
> 
> I still haven't sent this upstream.  It's unclear to me that we've
> decided that it merits merging?

Yes, if I remember it right, the performance gain is later confirmed
by Ronald's independent testing on his RAID. (Ronald CC-ed)

Thanks,
Fengguang

> 
> 
> From: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
> 
> I added blk_run_backing_dev on page_cache_async_readahead so readahead I/O
> is unpluged to improve throughput on especially RAID environment.
> 
> The normal case is, if page N become uptodate at time T(N), then T(N) <=
> T(N+1) holds.  With RAID (and NFS to some degree), there is no strict
> ordering, the data arrival time depends on runtime status of individual
> disks, which breaks that formula.  So in do_generic_file_read(), just
> after submitting the async readahead IO request, the current page may well
> be uptodate, so the page won't be locked, and the block device won't be
> implicitly unplugged:
> 
>                if (PageReadahead(page))
>                         page_cache_async_readahead()
>                 if (!PageUptodate(page))
>                                 goto page_not_up_to_date;
>                 //...
> page_not_up_to_date:
>                 lock_page_killable(page);
> 
> Therefore explicit unplugging can help.
> 
> Following is the test result with dd.
> 
> #dd if=testdir/testfile of=/dev/null bs=16384
> 
> -2.6.30-rc6
> 1048576+0 records in
> 1048576+0 records out
> 17179869184 bytes (17 GB) copied, 224.182 seconds, 76.6 MB/s
> 
> -2.6.30-rc6-patched
> 1048576+0 records in
> 1048576+0 records out
> 17179869184 bytes (17 GB) copied, 206.465 seconds, 83.2 MB/s
> 
> (7Disks RAID-0 Array)
> 
> -2.6.30-rc6
> 1054976+0 records in
> 1054976+0 records out
> 17284726784 bytes (17 GB) copied, 212.233 seconds, 81.4 MB/s
> 
> -2.6.30-rc6-patched
> 1054976+0 records out
> 17284726784 bytes (17 GB) copied, 198.878 seconds, 86.9 MB/s
> 
> (7Disks RAID-5 Array)
> 
> The patch was found to improve performance with the SCST scsi target
> driver.  See
> http://sourceforge.net/mailarchive/forum.php?thread_name=a0272b440906030714g67eabc5k8f847fb1e538cc62%40mail.gmail.com&forum_name=scst-devel
> 
> [akpm@linux-foundation.org: unbust comment layout]
> [akpm@linux-foundation.org: "fix" CONFIG_BLOCK=n]
> Signed-off-by: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Jens Axboe <jens.axboe@oracle.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Tested-by: Ronald <intercommit@gmail.com>
> Cc: Bart Van Assche <bart.vanassche@gmail.com>
> Cc: Vladislav Bolkhovitin <vst@vlnb.net>
> Cc: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/readahead.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff -puN mm/readahead.c~readahead-add-blk_run_backing_dev mm/readahead.c
> --- a/mm/readahead.c~readahead-add-blk_run_backing_dev
> +++ a/mm/readahead.c
> @@ -547,5 +547,17 @@ page_cache_async_readahead(struct addres
>  
>  	/* do read-ahead */
>  	ondemand_readahead(mapping, ra, filp, true, offset, req_size);
> +
> +#ifdef CONFIG_BLOCK
> +	/*
> +	 * Normally the current page is !uptodate and lock_page() will be
> +	 * immediately called to implicitly unplug the device. However this
> +	 * is not always true for RAID conifgurations, where data arrives
> +	 * not strictly in their submission order. In this case we need to
> +	 * explicitly kick off the IO.
> +	 */
> +	if (PageUptodate(page))
> +		blk_run_backing_dev(mapping->backing_dev_info, NULL);
> +#endif
>  }
>  EXPORT_SYMBOL_GPL(page_cache_async_readahead);
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
