Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 17BAB6B016A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 02:57:01 -0400 (EDT)
Message-ID: <4E534F33.5070609@openvz.org>
Date: Tue, 23 Aug 2011 10:56:51 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] vmscan: use atomic-long for shrinker batching
References: <20110822101721.19462.63082.stgit@zurg> <20110822101727.19462.55289.stgit@zurg>
In-Reply-To: <20110822101727.19462.55289.stgit@zurg>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Chinner <david@fromorbit.com>

Konstantin Khlebnikov wrote:
>   		delta = (4 * nr_pages_scanned) / shrinker->seeks;
> @@ -329,12 +327,11 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>   		 * manner that handles concurrent updates. If we exhausted the
>   		 * scan, there is no need to do an update.
>   		 */
> -		do {
> -			nr = shrinker->nr;
> -			new_nr = total_scan + nr;
> -			if (total_scan<= 0)
> -				break;
> -		} while (cmpxchg(&shrinker->nr, nr, new_nr) != nr);
> +		if (total_scan>  0)
> +			new_nr = atomic_long_add_return(total_scan,
> +					&shrinker->nr_in_batch);
> +		else
> +			new_nr = atomic_long_read(&shrinker->nr_in_batch);
>
>   		trace_mm_shrink_slab_end(shrinker, shrink_ret, nr, new_nr);

BTW, new_nr required only for tracing, maybe this will be better/faster,
because atomic accuracy there isn't required at all.

	if (total_scan > 0)
		atomic_long_add(total_scan, &shrinker->nr_in_batch);

	new_nr = atomic_long_read(&shrinker->nr_in_batch);
	trace_mm_shrink_slab_end(shrinker, shrink_ret, nr, new_nr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
