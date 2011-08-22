Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7308B6B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 19:26:54 -0400 (EDT)
Date: Tue, 23 Aug 2011 09:26:50 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/2] vmscan: use atomic-long for shrinker batching
Message-ID: <20110822232650.GU3162@dastard>
References: <20110822101721.19462.63082.stgit@zurg>
 <20110822101727.19462.55289.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110822101727.19462.55289.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, Aug 22, 2011 at 02:17:27PM +0300, Konstantin Khlebnikov wrote:
> Use atomic-long operations instead of looping around cmpxchg().
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> ---
>  include/linux/shrinker.h |    2 +-
>  mm/vmscan.c              |   17 +++++++----------
>  2 files changed, 8 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index 790651b..ac6b8ee 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -34,7 +34,7 @@ struct shrinker {
>  
>  	/* These are for internal use */
>  	struct list_head list;
> -	long nr;	/* objs pending delete */
> +	atomic_long_t nr_in_batch; /* objs pending delete */

It's not really the number in a batch - we use the "batch" term to
refer to the value we set sc->nr_to_scan for each shrinker scan call.
This is more the overflow of unscanned objects - objects pending
delete, as the comment says. So renaming it "nr_pending" might be
better.

As it is, this is a good change - I'll fold it into the series I
already have.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
