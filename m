Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 11FDB6B01EF
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 04:17:15 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3D8HDeT013265
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Apr 2010 17:17:13 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6228645DE4F
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:17:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 37C4D45DE4D
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:17:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 19A43E08008
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:17:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B9EDDE08004
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:17:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] mm: add context argument to shrinker callback
In-Reply-To: <1271118255-21070-2-git-send-email-david@fromorbit.com>
References: <1271118255-21070-1-git-send-email-david@fromorbit.com> <1271118255-21070-2-git-send-email-david@fromorbit.com>
Message-Id: <20100413170653.D10A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 13 Apr 2010 17:17:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index e70f21b..7d48942 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -982,11 +982,11 @@ static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
>  /*
>   * A callback you can register to apply pressure to ageable caches.
>   *
> - * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
> - * look through the least-recently-used 'nr_to_scan' entries and
> - * attempt to free them up.  It should return the number of objects
> - * which remain in the cache.  If it returns -1, it means it cannot do
> - * any scanning at this time (eg. there is a risk of deadlock).
> + * 'shrink' is passed a context 'ctx', a count 'nr_to_scan' and a 'gfpmask'.
> + * It should look through the least-recently-used 'nr_to_scan' entries and
> + * attempt to free them up.  It should return the number of objects which
> + * remain in the cache.  If it returns -1, it means it cannot do any scanning
> + * at this time (eg. there is a risk of deadlock).
>   *
>   * The 'gfpmask' refers to the allocation we are currently trying to
>   * fulfil.
> @@ -995,7 +995,8 @@ static inline void sync_mm_rss(struct task_struct *task, struct mm_struct *mm)
>   * querying the cache size, so a fastpath for that case is appropriate.
>   */
>  struct shrinker {
> -	int (*shrink)(int nr_to_scan, gfp_t gfp_mask);
> +	int (*shrink)(void *ctx, int nr_to_scan, gfp_t gfp_mask);
> +	void *ctx;	/* user callback context */
>  	int seeks;	/* seeks to recreate an obj */
>  
>  	/* These are for internal use */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5321ac4..40f27d2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -215,8 +215,9 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
>  	list_for_each_entry(shrinker, &shrinker_list, list) {
>  		unsigned long long delta;
>  		unsigned long total_scan;
> -		unsigned long max_pass = (*shrinker->shrink)(0, gfp_mask);
> +		unsigned long max_pass;
>  
> +		max_pass = (*shrinker->shrink)(shrinker->ctx, 0, gfp_mask);
>  		delta = (4 * scanned) / shrinker->seeks;
>  		delta *= max_pass;
>  		do_div(delta, lru_pages + 1);
> @@ -244,8 +245,10 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
>  			int shrink_ret;
>  			int nr_before;
>  
> -			nr_before = (*shrinker->shrink)(0, gfp_mask);
> -			shrink_ret = (*shrinker->shrink)(this_scan, gfp_mask);
> +			nr_before = (*shrinker->shrink)(shrinker->ctx,
> +							0, gfp_mask);
> +			shrink_ret = (*shrinker->shrink)(shrinker->ctx,
> +							this_scan, gfp_mask);
>  			if (shrink_ret == -1)
>  				break;
>  			if (shrink_ret < nr_before)

Looks good about this mm part.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


off-topic: shrink_slab() was introduced for page/[id]-cache scan balancing
at first. now it still have hardcorded shrinker->nr calculation for slab
although now lots another subsystem using it. shrinker->seeks seems no
intuitive knob. probably we should try generalization it in future. but
it is another story. I think this patch provide good first step.

                delta = (4 * scanned) / shrinker->seeks;
                delta *= max_pass;
                do_div(delta, lru_pages + 1);
                shrinker->nr += delta;


Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
