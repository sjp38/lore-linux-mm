Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 50698900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 19:55:08 -0400 (EDT)
Received: by gxk23 with SMTP id 23so648464gxk.14
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 16:55:06 -0700 (PDT)
Date: Thu, 14 Apr 2011 08:55:00 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: preemptless __per_cpu_counter_add
Message-ID: <20110413235500.GA12781@mtj.dyndns.org>
References: <alpine.DEB.2.00.1104130942500.16214@router.home>
 <alpine.DEB.2.00.1104131148070.20908@router.home>
 <20110413185618.GA3987@mtj.dyndns.org>
 <alpine.DEB.2.00.1104131521050.25812@router.home>
 <20110413215022.GI3987@mtj.dyndns.org>
 <alpine.DEB.2.00.1104131712070.29766@router.home>
 <alpine.DEB.2.00.1104131721590.30103@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104131721590.30103@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, eric.dumazet@gmail.com, shaohua.li@intel.com

Hello, Christoph.

On Wed, Apr 13, 2011 at 05:23:04PM -0500, Christoph Lameter wrote:
> 
> Suggested fixup. Return from slowpath and update percpu variable under
> spinlock.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---
>  lib/percpu_counter.c |    8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> Index: linux-2.6/lib/percpu_counter.c
> ===================================================================
> --- linux-2.6.orig/lib/percpu_counter.c	2011-04-13 17:20:41.000000000 -0500
> +++ linux-2.6/lib/percpu_counter.c	2011-04-13 17:21:33.000000000 -0500
> @@ -82,13 +82,9 @@ void __percpu_counter_add(struct percpu_
>  			spin_lock(&fbc->lock);
>  			count = __this_cpu_read(*fbc->counters);
>  			fbc->count += count + amount;
> +			__this_cpu_write(*fbc->counters, 0);
>  			spin_unlock(&fbc->lock);
> -			/*
> -			 * If cmpxchg fails then we need to subtract the amount that
> -			 * we found in the percpu value.
> -			 */
> -			amount = -count;
> -			new = 0;
> +			return;

Yeah, looks pretty good to me now.  Just a couple more things.

* Please fold this one into the original patch.

* While you're restructuring the functions, can you add unlikely to
  the slow path?

It now looks correct to me but just in case, Eric, do you mind
reviewing and acking it?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
