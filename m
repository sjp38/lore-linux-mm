Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id F3AA56B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:53:30 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id r10so1734824pdi.6
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 14:53:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tr4si5058158pab.5.2014.01.15.14.53.29
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 14:53:29 -0800 (PST)
Date: Wed, 15 Jan 2014 14:53:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] mm: vmscan: shrink all slab objects if tight on
 memory
Message-Id: <20140115145327.6aae2e13a9a8bba619923ac9@linux-foundation.org>
In-Reply-To: <52D6AF5F.2040102@parallels.com>
References: <7d37542211678a637dc6b4d995fd6f1e89100538.1389443272.git.vdavydov@parallels.com>
	<20140113150502.4505f661589a4a2d30e6f11d@linux-foundation.org>
	<52D4E5F2.5080205@parallels.com>
	<20140114141453.374bd18e5290876177140085@linux-foundation.org>
	<52D64B27.30604@parallels.com>
	<20140115012541.ad302526.akpm@linux-foundation.org>
	<52D6AF5F.2040102@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

On Wed, 15 Jan 2014 19:55:11 +0400 Vladimir Davydov <vdavydov@parallels.com> wrote:

> >
> > We could avoid the "scan 32 then scan just 1" issue with something like
> >
> > 	if (total_scan > batch_size)
> > 		total_scan %= batch_size;
> >
> > before the loop.  But I expect the effects of that will be unmeasurable
> > - on average the number of objects which are scanned in the final pass
> > of the loop will be batch_size/2, yes?  That's still a decent amount.
> 
> Let me try to summarize. We want to scan batch_size objects in one pass,
> not more (to keep latency low) and not less (to avoid cpu cache
> pollution due to too frequent calls); if the calculated value of
> nr_to_scan is less than the batch_size we should accumulate it in
> nr_deferred instead of calling ->scan() and add nr_deferred to
> nr_to_scan on the next pass, i.e. in pseudo-code:
> 
>     /* calculate current nr_to_scan */
>     max_pass = shrinker->count();
>     delta = max_pass * nr_user_pages_scanned / nr_user_pages;
> 
>     /* add nr_deferred */
>     total_scan = delta + nr_deferred;
> 
>     while (total_scan >= batch_size) {
>         shrinker->scan(batch_size);
>         total_scan -= batch_size;
>     }
> 
>     /* save the remainder to nr_deferred  */
>     nr_deferred = total_scan;
> 
> That would work, but if max_pass is < batch_size, it would not scan the
> objects immediately even if prio is high (we want to scan all objects).

Yes, that's a problem.

> For example, dropping caches would not work on the first attempt - the
> user would have to call it batch_size / max_pass times.

And we do want drop_caches to work immediately.

> This could be
> fixed by making the code proceed to ->scan() not only if total_scan is
> >= batch_size, but also if max_pass is < batch_size and total_scan is >=
> max_pass, i.e.
> 
>     while (total_scan >= batch_size ||
>             (max_pass < batch_size && total_scan >= max_pass)) ...
> 
> which is equivalent to
> 
>     while (total_scan >= batch_size ||
>                 total_scan >= max_pass) ...
> 
> The latter is the loop condition from the current patch, i.e. this patch
> would make the trick if shrink_slab() followed the pseudo-code above. In
> real life, it does not actually - we have to bias total_scan before the
> while loop in order to avoid dropping fs meta caches on light memory
> pressure due to a large number being built in nr_deferred:
> 
>     if (delta < max_pass / 4)
>         total_scan = min(total_scan, max_pass / 2);

Oh, is that what's it's for.  Where did you discover this gem?

>     while (total_scan >= batch_size) ...
> 
> With this biasing, it is impossible to achieve the ideal behavior I've
> described above, because we will never accumulate max_pass objects in
> nr_deferred if memory pressure is low. So, if applied to the real code,
> this patch takes on a slightly different sense, which I tried to reflect
> in the comment to the code: it will call ->scan() with nr_to_scan <
> batch_size only if:
> 
> 1) max_pass < batch_size && total_scan >= max_pass
> 
> and
> 
> 2) we're tight on memory, i.e. the current delta is high (otherwise
> total_scan will be biased as max_pass / 2 and condition 1 won't be
> satisfied).

(is max_pass misnamed?)

> >From our discussion it seems condition 2 is not necessary at all, but it
> follows directly from the biasing rule. So I propose to tweak the
> biasing a bit so that total_scan won't be lowered < batch_size:
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eea668d..78ddd5e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -267,7 +267,7 @@ shrink_slab_node(struct shrink_control *shrinkctl,
> struct shrinker *shrinker,
>       * a large delta change is calculated directly.
>       */
>      if (delta < max_pass / 4)
> -        total_scan = min(total_scan, max_pass / 2);
> +        total_scan = min(total_scan, max(max_pass / 2, batch_size));
>  
>      /*
>       * Avoid risking looping forever due to too large nr value:
> @@ -281,7 +281,7 @@ shrink_slab_node(struct shrink_control *shrinkctl,
> struct shrinker *shrinker,
>                  nr_pages_scanned, lru_pages,
>                  max_pass, delta, total_scan);
>  
> -    while (total_scan >= batch_size) {
> +    while (total_scan >= batch_size || total_scan >= max_pass) {
>          unsigned long ret;
>  
>          shrinkctl->nr_to_scan = batch_size;
> 
> The first hunk guarantees that total_scan will always accumulate at
> least batch_size objects no matter how small max_pass is. That means
> that when max_pass is < batch_size we will eventually get >= max_pass
> objects to scan and shrink the slab to 0 as we need. What do you think
> about that?

I'm a bit lost :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
