Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 17B446B01EE
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 10:44:47 -0400 (EDT)
Subject: Re: [RFC PATCH] mm: let the bdi_writeout fraction respond more
 quickly
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <1276523894.1980.85.camel@castor.rsk>
References: <1276523894.1980.85.camel@castor.rsk>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 14 Jun 2010 15:44:41 +0100
Message-ID: <1276526681.1980.89.camel@castor.rsk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <axboe@kernel.dk>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-14 at 14:58 +0100, Richard Kennedy wrote:
> Hi all,
> The fraction of vm cache allowed to each BDI as calculated by
> get_dirty_limits (mm/page-writeback.c) respond very slowly to changes in
> workload.
> 
> Running a simple test that alternately writes 1Gb to sda then sdb,
> twice, shows the bdi_threshold taking approximately 15 seconds to reach
> a steady state value. This prevents a application from using all of the
> available cache and forces it to write to the physical disk earlier than
> strictly necessary.  
> As you can see from the attached graph, bdi_thresh_before.png, our
> current control system responds to this kind of workload very slowly.
> 
> The below patch speeds up the recalculation and lets it reach a steady
> state value in a couple of seconds. see bdi_thresh_after.png.
> 
> I get better throughput with this patch applied and have been running
> some variation of this on and off for some months without any obvious
> problems.
> 
> (These tests were all run on 2.6.35-rc3,
> where dm-2 is a sata drive lvm/ext4 and sdb is ide ext4.
> I've got lots more results and graphs but won't bore you all with
> them ;) )
> 
> I see this as a considerable improvement but I have found the magic
> number of -4 empirically so it may just be tuned to my system. I'm not
> sure how to decide on a value that is suitable for everyone. 
> 
> Does anyone have any suggestions or thoughts?
> 
> Unfortunately I don't have any other hardware to try this on, so I would
> be very interest to hear if anyone tries this on their favourite
> workload.
> 
> regards
> Richard
>  
> patch against 2.6.35-rc3
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 2fdda90..315dd04 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -144,7 +144,7 @@ static int calc_period_shift(void)
>  	else
>  		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
>  				100;
> -	return 2 + ilog2(dirty_total - 1);
> +	return ilog2(dirty_total - 1) - 4;
>  }
>  
>  /*
> 
Fixed Jens email address. I can send you the graphs privately if you
haven't already got them.

regards
Richard


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
