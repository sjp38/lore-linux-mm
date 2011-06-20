Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 587F56B0012
	for <linux-mm@kvack.org>; Sun, 19 Jun 2011 20:47:02 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 36E093EE0BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:46:57 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F115C45DE5B
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:46:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CE5DB45DE56
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:46:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BCCCE1DB8056
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:46:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 802371DB804A
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 09:46:56 +0900 (JST)
Message-ID: <4DFE987E.1070900@jp.fujitsu.com>
Date: Mon, 20 Jun 2011 09:46:54 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/12] vmscan: shrinker->nr updates race and go wrong
References: <1306998067-27659-1-git-send-email-david@fromorbit.com> <1306998067-27659-3-git-send-email-david@fromorbit.com>
In-Reply-To: <1306998067-27659-3-git-send-email-david@fromorbit.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 48e3fbd..dce2767 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -251,17 +251,29 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  		unsigned long total_scan;
>  		unsigned long max_pass;
>  		int shrink_ret = 0;
> +		long nr;
> +		long new_nr;
>  
> +		/*
> +		 * copy the current shrinker scan count into a local variable
> +		 * and zero it so that other concurrent shrinker invocations
> +		 * don't also do this scanning work.
> +		 */
> +		do {
> +			nr = shrinker->nr;
> +		} while (cmpxchg(&shrinker->nr, nr, 0) != nr);
> +
> +		total_scan = nr;
>  		max_pass = do_shrinker_shrink(shrinker, shrink, 0);
>  		delta = (4 * nr_pages_scanned) / shrinker->seeks;
>  		delta *= max_pass;
>  		do_div(delta, lru_pages + 1);
> -		shrinker->nr += delta;
> -		if (shrinker->nr < 0) {
> +		total_scan += delta;
> +		if (total_scan < 0) {
>  			printk(KERN_ERR "shrink_slab: %pF negative objects to "
>  			       "delete nr=%ld\n",
> -			       shrinker->shrink, shrinker->nr);
> -			shrinker->nr = max_pass;
> +			       shrinker->shrink, total_scan);
> +			total_scan = max_pass;
>  		}
>  
>  		/*
> @@ -269,13 +281,11 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  		 * never try to free more than twice the estimate number of
>  		 * freeable entries.
>  		 */
> -		if (shrinker->nr > max_pass * 2)
> -			shrinker->nr = max_pass * 2;
> +		if (total_scan > max_pass * 2)
> +			total_scan = max_pass * 2;
>  
> -		total_scan = shrinker->nr;
> -		shrinker->nr = 0;
>  
> -		trace_mm_shrink_slab_start(shrinker, shrink, nr_pages_scanned,
> +		trace_mm_shrink_slab_start(shrinker, shrink, nr, nr_pages_scanned,
>  					lru_pages, max_pass, delta, total_scan);
>  
>  		while (total_scan >= SHRINK_BATCH) {
> @@ -295,8 +305,19 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  			cond_resched();
>  		}
>  
> -		shrinker->nr += total_scan;
> -		trace_mm_shrink_slab_end(shrinker, shrink_ret, total_scan);
> +		/*
> +		 * move the unused scan count back into the shrinker in a
> +		 * manner that handles concurrent updates. If we exhausted the
> +		 * scan, there is no need to do an update.
> +		 */
> +		do {
> +			nr = shrinker->nr;
> +			new_nr = total_scan + nr;
> +			if (total_scan <= 0)
> +				break;
> +		} while (cmpxchg(&shrinker->nr, nr, new_nr) != nr);
> +
> +		trace_mm_shrink_slab_end(shrinker, shrink_ret, nr, new_nr);
>  	}
>  	up_read(&shrinker_rwsem);
>  out:

Looks great fix. Please remove tracepoint change from this patch and send it
to -stable. iow, I expect I'll ack your next spin.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
