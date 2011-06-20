Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E94196B0012
	for <linux-mm@kvack.org>; Sun, 19 Jun 2011 20:51:20 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 86FF73EE0CF
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:51:09 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BA0345DE8F
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:51:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 52EA645DE67
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:51:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 431E51DB803E
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:51:09 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0227C1DB8037
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:51:09 +0900 (JST)
Message-ID: <4DFE997C.2060805@jp.fujitsu.com>
Date: Mon, 20 Jun 2011 09:51:08 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/12] vmscan: reduce wind up shrinker->nr when shrinker
 can't do work
References: <1306998067-27659-1-git-send-email-david@fromorbit.com> <1306998067-27659-4-git-send-email-david@fromorbit.com>
In-Reply-To: <1306998067-27659-4-git-send-email-david@fromorbit.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

(2011/06/02 16:00), Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> When a shrinker returns -1 to shrink_slab() to indicate it cannot do
> any work given the current memory reclaim requirements, it adds the
> entire total_scan count to shrinker->nr. The idea ehind this is that
> whenteh shrinker is next called and can do work, it will do the work
> of the previously aborted shrinker call as well.
> 
> However, if a filesystem is doing lots of allocation with GFP_NOFS
> set, then we get many, many more aborts from the shrinkers than we
> do successful calls. The result is that shrinker->nr winds up to
> it's maximum permissible value (twice the current cache size) and
> then when the next shrinker call that can do work is issued, it
> has enough scan count built up to free the entire cache twice over.
> 
> This manifests itself in the cache going from full to empty in a
> matter of seconds, even when only a small part of the cache is
> needed to be emptied to free sufficient memory.
> 
> Under metadata intensive workloads on ext4 and XFS, I'm seeing the
> VFS caches increase memory consumption up to 75% of memory (no page
> cache pressure) over a period of 30-60s, and then the shrinker
> empties them down to zero in the space of 2-3s. This cycle repeats
> over and over again, with the shrinker completely trashing the N?node
> and dentry caches every minute or so the workload continues.
> 
> This behaviour was made obvious by the shrink_slab tracepoints added
> earlier in the series, and made worse by the patch that corrected
> the concurrent accounting of shrinker->nr.
> 
> To avoid this problem, stop repeated small increments of the total
> scan value from winding shrinker->nr up to a value that can cause
> the entire cache to be freed. We still need to allow it to wind up,
> so use the delta as the "large scan" threshold check - if the delta
> is more than a quarter of the entire cache size, then it is a large
> scan and allowed to cause lots of windup because we are clearly
> needing to free lots of memory.
> 
> If it isn't a large scan then limit the total scan to half the size
> of the cache so that windup never increases to consume the whole
> cache. Reducing the total scan limit further does not allow enough
> wind-up to maintain the current levels of performance, whilst a
> higher threshold does not prevent the windup from freeing the entire
> cache under sustained workloads.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  mm/vmscan.c |   14 ++++++++++++++
>  1 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index dce2767..3688f47 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -277,6 +277,20 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  		}
>  
>  		/*
> +		 * Avoid excessive windup on fielsystem shrinkers due to large
> +		 * numbers of GFP_NOFS allocations causing the shrinkers to
> +		 * return -1 all the time. This results in a large nr being
> +		 * built up so when a shrink that can do some work comes along
> +		 * it empties the entire cache due to nr >>> max_pass.  This is
> +		 * bad for sustaining a working set in memory.
> +		 *
> +		 * Hence only allow nr to go large when a large delta is
> +		 * calculated.
> +		 */
> +		if (delta < max_pass / 4)
> +			total_scan = min(total_scan, max_pass / 2);
> +
> +		/*
>  		 * Avoid risking looping forever due to too large nr value:
>  		 * never try to free more than twice the estimate number of
>  		 * freeable entries.

I guess "max_pass/4" and "min(total_scan, max_pass / 2)" are your heuristic value. right?
If so, please write your benchmark name and its result into the description. I mean,
currently some mm folks plan to enhance shrinker. So, sharing benchmark may help to avoid
an accidental regression.

I mean, your code itself looks pretty good to me.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
