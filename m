Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 7486A6B0033
	for <linux-mm@kvack.org>; Sun, 16 Jun 2013 20:08:32 -0400 (EDT)
Date: Mon, 17 Jun 2013 10:08:27 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: vmscan: remove redundant querying to shrinker
Message-ID: <20130617000827.GI29338@dastard>
References: <1371204471-13518-1-git-send-email-heesub.shin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371204471-13518-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, riel@redhat.com, kyungmin.park@samsung.com, d.j.shin@samsung.com, sunae.seo@samsung.com

On Fri, Jun 14, 2013 at 07:07:51PM +0900, Heesub Shin wrote:
> shrink_slab() queries each slab cache to get the number of
> elements in it. In most cases such queries are cheap but,
> on some caches. For example, Android low-memory-killer,
> which is operates as a slab shrinker, does relatively
> long calculation once invoked and it is quite expensive.

As has already been pointed out, the low memory killer is a badly
broken piece of code. I can't run a normal machine with it enabled
because it randomly kills processes whenever memory pressure is
generated. What it does is simply broken and hence arguing that it
has too much overhead is not a convincing argument for changing core
shrinker infrastructure.

> This patch removes redundant queries to shrinker function
> in the loop of shrink batch.
> 
> Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
> ---
>  mm/vmscan.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index fa6a853..11b6695 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -282,9 +282,8 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  					max_pass, delta, total_scan);
>  
>  		while (total_scan >= batch_size) {
> -			int nr_before;
> +			int nr_before = max_pass;
>  
> -			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
>  			shrink_ret = do_shrinker_shrink(shrinker, shrink,
>  							batch_size);
>  			if (shrink_ret == -1)
> @@ -293,6 +292,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>  				ret += nr_before - shrink_ret;
>  			count_vm_events(SLABS_SCANNED, batch_size);
>  			total_scan -= batch_size;
> +			max_pass = shrink_ret;
>  
>  			cond_resched();
>  		}

Shrinkers run concurrently on different CPUs, and so the state of
the cache being shrunk can change significantly when cond_resched()
actually yields the CPU.  Hence we need to recalculate the current
state of the cache before we shrink again to get an accurate idea of
how much work the current loop has done. If we get this badly wrong,
the caller of shrink_slab() will get an incorrect idea of how much
work was actually done by the shrinkers....

This problem is fixed in mmtom by the change of shrinker API that
results shrinker->scan_objects() returning the number of objects
freed directly, and hence it isn't necessary to have a
shrinker->count_objects() call in the scan loop anymore. i.e. the
reworked scan loop ends up like:

	while (total_scan >= batch_size) {
		unsigned long ret;
		shrinkctl->nr_to_scan = batch_size;
		ret = shrinker->scan_objects(shrinker, shrinkctl);

		if (ret == SHRINK_STOP)
			break;
		freed += ret;

		count_vm_events(SLABS_SCANNED, batch_size);
		total_scan -= batch_size;
	}

So we've already solved the problem you are concerned about....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
