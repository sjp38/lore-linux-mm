Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 717566B0069
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 18:52:10 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id gg9so25519238pac.6
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 15:52:10 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id c63si2567266pga.244.2016.10.11.15.52.08
        for <linux-mm@kvack.org>;
        Tue, 11 Oct 2016 15:52:09 -0700 (PDT)
Date: Wed, 12 Oct 2016 09:52:06 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2] z3fold: add shrinker
Message-ID: <20161011225206.GJ23194@dastard>
References: <20161012001827.53ae55723e67d1dee2a2f839@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161012001827.53ae55723e67d1dee2a2f839@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 12, 2016 at 12:18:27AM +0200, Vitaly Wool wrote:
> 
> Here comes the correct shrinker patch for z3fold. This shrinker
> implementation does not free up any pages directly but it allows
> for a denser placement of compressed objects which results in
> less actual pages consumed and higher compression ratio therefore.
> 
> This patch has been checked with the latest Linus's tree.
> 
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  mm/z3fold.c | 151 ++++++++++++++++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 127 insertions(+), 24 deletions(-)
> 
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 8f9e89c..4841972 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -30,6 +30,7 @@
>  #include <linux/slab.h>
>  #include <linux/spinlock.h>
>  #include <linux/zpool.h>
> +#include <linux/shrinker.h>
>  
>  /*****************
>   * Structures
> @@ -69,8 +70,11 @@ struct z3fold_ops {
>   * @lru:	list tracking the z3fold pages in LRU order by most recently
>   *		added buddy.
>   * @pages_nr:	number of z3fold pages in the pool.
> + * @unbuddied_nr:	number of unbuddied z3fold pages in the pool.
>   * @ops:	pointer to a structure of user defined operations specified at
>   *		pool creation time.
> + * @shrinker:	shrinker structure to optimize page layout in background
> + * @no_shrinker:	flag showing if we run with shrinker or not

Ugh.

>  
> +/* Has to be called with lock held */
> +static int z3fold_compact_page(struct z3fold_header *zhdr, bool sync)
> +{
> +	struct page *page = virt_to_page(zhdr);
> +	void *beg = zhdr;
> +

[snip using memmove() to shift chunks around]

> +static unsigned long z3fold_shrink_scan(struct shrinker *shrink,
> +				struct shrink_control *sc)
> +{
> +	struct z3fold_pool *pool = container_of(shrink, struct z3fold_pool,
> +						shrinker);
> +	struct z3fold_header *zhdr;
> +	int i, nr_to_scan = sc->nr_to_scan;
> +
> +	spin_lock(&pool->lock);

Do not do this. Shrinkers should not run entirely under a spin lock
like this - it causes scheduling latency problems and when the
shrinker is run concurrently on different CPUs it will simply burn
CPU doing no useful work. Especially, in this case, as each call to
z3fold_compact_page() may be copying a significant amount of data
around and so there is potentially a /lot/ of work being done on
each call to the shrinker.

If you need compaction exclusion for the shrinker invocation, then
please use a sleeping lock to protect the compaction work.

>  *****************/
> @@ -234,6 +335,13 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
>  		INIT_LIST_HEAD(&pool->unbuddied[i]);
>  	INIT_LIST_HEAD(&pool->buddied);
>  	INIT_LIST_HEAD(&pool->lru);
> +	pool->shrinker.count_objects = z3fold_shrink_count;
> +	pool->shrinker.scan_objects = z3fold_shrink_scan;
> +	pool->shrinker.seeks = DEFAULT_SEEKS;
> +	if (register_shrinker(&pool->shrinker)) {
> +		pr_warn("z3fold: could not register shrinker\n");
> +		pool->no_shrinker = true;
> +	}

Just fail creation of the pool. If you can't register a shrinker,
then much bigger problems are about to happen to your system, and
running a new memory consumer that /can't be shrunk/ is not going to
help anyone.

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
