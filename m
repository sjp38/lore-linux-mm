Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id DED036B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 08:34:31 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so7441971pab.22
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 05:34:31 -0700 (PDT)
Date: Mon, 14 Oct 2013 14:34:26 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2] writeback: fix negative bdi max pause
Message-ID: <20131014123426.GG19604@quack.suse.cz>
References: <525591AD.4060401@gmx.de>
 <5255A3E6.6020100@nod.at>
 <20131009214733.GB25608@quack.suse.cz>
 <5255D9A6.3010208@nod.at>
 <5256DA9A.5060904@gmx.de>
 <20131011011649.GA11191@localhost>
 <5257B9EB.7080503@gmx.de>
 <20131011085701.GA27382@localhost>
 <52580767.6090604@gmx.de>
 <20131012044517.GA32048@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20131012044517.GA32048@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>, Richard Weinberger <richard@nod.at>, Jan Kara <jack@suse.cz>, Geert Uytterhoeven <geert@linux-m68k.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, hannes@cmpxchg.org, darrick.wong@oracle.com, Michal Hocko <mhocko@suse.cz>

On Sat 12-10-13 12:45:17, Wu Fengguang wrote:
> Toralf runs trinity on UML/i386.
> After some time it hangs and the last message line is
> 
> 	BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child0:1521]
> 
> It's found that pages_dirtied becomes very large.
> More than 1000000000 pages in this case:
> 
> 	period = HZ * pages_dirtied / task_ratelimit;
> 	BUG_ON(pages_dirtied > 2000000000);
> 	BUG_ON(pages_dirtied > 1000000000);      <---------
> 
> UML debug printf shows that we got negative pause here:
> 
> 	ick: pause : -984
> 	ick: pages_dirtied : 0
> 	ick: task_ratelimit: 0
> 
> 	 pause:
> 	+       if (pause < 0)  {
> 	+               extern int printf(char *, ...);
> 	+               printf("ick : pause : %li\n", pause);
> 	+               printf("ick: pages_dirtied : %lu\n", pages_dirtied);
> 	+               printf("ick: task_ratelimit: %lu\n", task_ratelimit);
> 	+               BUG_ON(1);
> 	+       }
> 	        trace_balance_dirty_pages(bdi,
> 
> Since pause is bounded by [min_pause, max_pause] where min_pause is also
> bounded by max_pause. It's suspected and demonstrated that the max_pause
> calculation goes wrong:
> 
> 	ick: pause : -717
> 	ick: min_pause : -177
> 	ick: max_pause : -717
> 	ick: pages_dirtied : 14
> 	ick: task_ratelimit: 0
> 
> The problem lies in the two "long = unsigned long" assignments in
> bdi_max_pause() which might go negative if the highest bit is 1, and
> the min_t(long, ...) check failed to protect it falling under 0. Fix
> all of them by using "unsigned long" throughout the function.
> 
> Reported-by: Toralf Forster <toralf.foerster@gmx.de>
> Tested-by: Toralf Forster <toralf.foerster@gmx.de>
> Cc: <stable@vger.kernel.org>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Richard Weinberger <richard@nod.at>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
  The patch looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/page-writeback.c |   10 +++++-----
>  mm/readahead.c      |    2 +-
>  2 files changed, 6 insertions(+), 6 deletions(-)
> 
>  Changes since v1: Add CC list.
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 3f0c895..241a746 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1104,11 +1104,11 @@ static unsigned long dirty_poll_interval(unsigned long dirty,
>  	return 1;
>  }
>  
> -static long bdi_max_pause(struct backing_dev_info *bdi,
> -			  unsigned long bdi_dirty)
> +static unsigned long bdi_max_pause(struct backing_dev_info *bdi,
> +				   unsigned long bdi_dirty)
>  {
> -	long bw = bdi->avg_write_bandwidth;
> -	long t;
> +	unsigned long bw = bdi->avg_write_bandwidth;
> +	unsigned long t;
>  
>  	/*
>  	 * Limit pause time for small memory systems. If sleeping for too long
> @@ -1120,7 +1120,7 @@ static long bdi_max_pause(struct backing_dev_info *bdi,
>  	t = bdi_dirty / (1 + bw / roundup_pow_of_two(1 + HZ / 8));
>  	t++;
>  
> -	return min_t(long, t, MAX_PAUSE);
> +	return min_t(unsigned long, t, MAX_PAUSE);
>  }
>  
>  static long bdi_min_pause(struct backing_dev_info *bdi,
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
