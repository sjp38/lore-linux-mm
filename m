Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 7E4D46B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 10:16:17 -0500 (EST)
Date: Thu, 24 Jan 2013 16:16:03 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] Negative (setpoint-dirty) in bdi_position_ratio()
Message-ID: <20130124151603.GD21818@quack.suse.cz>
References: <201301200002.r0K02Atl031280@como.maths.usyd.edu.au>
 <20130124145707.GB12745@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130124145707.GB12745@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: paul.szabo@sydney.edu.au, linux-mm@kvack.org, 695182@bugs.debian.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

On Thu 24-01-13 22:57:07, Wu Fengguang wrote:
> Hi Paul,
> 
> > (This patch does not solve the PAE OOM issue.)
> 
> You may try the below debug patch. The only way the writeback patches
> should trigger OOM, I think, is for the number of dirty/writeback
> pages going out of control.
> 
> Or more simple, you may show us the OOM dmesg which will contain the
> number of dirty pages. Or run this in a continuous loop during your
> tests, and see how the dirty numbers change before OOM:
  I think he found the culprit of the problem being min_free_kbytes was not
properly reflected in the dirty throttling. But the patch has been already
picked up by Andrew so I didn't forward it to you. Paul please correct me
if I'm wrong.

								Honza

> 
> while :
> do
>         grep -E '(Dirty|Writeback)' /proc/meminfo
>         sleep 1
> done
> 
> Thanks,
> Fengguang
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 50f0824..cf1165a 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1147,6 +1147,16 @@ pause:
>  		if (task_ratelimit)
>  			break;
>  
> +		if (nr_dirty > dirty_thresh + dirty_thresh / 2) {
> +			if (printk_ratelimit())
> +				printk(KERN_WARNING "nr_dirty=%lu dirty_thresh=%lu task_ratelimit=%lu dirty_ratelimit=%lu pos_ratio=%lu\n",
> +				       nr_dirty,
> +				       dirty_thresh,
> +				       task_ratelimit,
> +				       dirty_ratelimit,
> +				       pos_ratio);
> +		}
> +
>  		/*
>  		 * In the case of an unresponding NFS server and the NFS dirty
>  		 * pages exceeds dirty_thresh, give the other good bdi's a pipe
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
