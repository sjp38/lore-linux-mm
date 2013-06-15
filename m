Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 0C05D6B0033
	for <linux-mm@kvack.org>; Sat, 15 Jun 2013 03:09:38 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id 10so1227154pdi.39
        for <linux-mm@kvack.org>; Sat, 15 Jun 2013 00:09:38 -0700 (PDT)
Date: Sat, 15 Jun 2013 16:09:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: vmscan: remove redundant querying to shrinker
Message-ID: <20130615070930.GC7470@gmail.com>
References: <1371204471-13518-1-git-send-email-heesub.shin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371204471-13518-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, riel@redhat.com, kyungmin.park@samsung.com, d.j.shin@samsung.com, sunae.seo@samsung.com

Hello,

Andrew want to merge this so I try to review.

On Fri, Jun 14, 2013 at 07:07:51PM +0900, Heesub Shin wrote:
> shrink_slab() queries each slab cache to get the number of
> elements in it. In most cases such queries are cheap but,
> on some caches. For example, Android low-memory-killer,
> which is operates as a slab shrinker, does relatively
> long calculation once invoked and it is quite expensive.

long calculation?
I am looking at lowmem_shrink in v3.9 and I couldn't find
anything  which would make slow in case of slab query.
It does have rather unnecessary code with calulating
global vmstat but I think it's not culprit for your slowness.

Could you say how does it makes slow with some number?
If it's true, we have to fix LMK.
We already have been said following as.

 * Note that 'shrink' will be passed nr_to_scan == 0 when the VM is
 * querying the cache size, so a fastpath for that case is appropriate.

> 
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

It might be a good optimization but one of the problem I can see
is cond_resched. If the process is scheduled out and other task
consume more object from the slab, shrink_ret would be obsolete
so that shrink_ret would be greater than nr_before in next iteration.
In such case, we can lose the number of slab objects.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
