Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8DB2E900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 18:04:47 -0400 (EDT)
Date: Thu, 14 Apr 2011 00:04:44 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 4/4] writeback: reduce per-bdi dirty threshold ramp up
 time
Message-ID: <20110413220444.GF4648@quack.suse.cz>
References: <20110413085937.981293444@intel.com>
 <20110413090415.763161169@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110413090415.763161169@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Richard Kennedy <richard@rsk.demon.co.uk>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

On Wed 13-04-11 16:59:41, Wu Fengguang wrote:
> Reduce the dampening for the control system, yielding faster
> convergence. The change is a bit conservative, as smaller values may
> lead to noticeable bdi threshold fluctuates in low memory JBOD setup.
> 
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Richard Kennedy <richard@rsk.demon.co.uk>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
  Well, I have nothing against this change as such but what I don't like is
that it just changes magical +2 for similarly magical +0. It's clear that
this will lead to more rapid updates of proportions of bdi's share of
writeback and thread's share of dirtying but why +0? Why not +1 or -1? So
I'd prefer to get some understanding of why do we need to update the
proportion period and why 4-times faster is just the right amount of faster
:) If I remember right you had some numbers for this, didn't you?

								Honza
> ---
>  mm/page-writeback.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-next.orig/mm/page-writeback.c	2011-03-02 14:52:19.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2011-03-02 15:00:17.000000000 +0800
> @@ -145,7 +145,7 @@ static int calc_period_shift(void)
>  	else
>  		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
>  				100;
> -	return 2 + ilog2(dirty_total - 1);
> +	return ilog2(dirty_total - 1);
>  }
>  
>  /*
> 
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
