Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8D38E6B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 16:37:01 -0400 (EDT)
Date: Wed, 20 Mar 2013 13:36:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/4 v3]swap: change block allocation algorithm for SSD
Message-Id: <20130320133659.7ba5465e6e4063b2651be266@linux-foundation.org>
In-Reply-To: <20130221021710.GA32580@kernel.org>
References: <20130221021710.GA32580@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org

On Thu, 21 Feb 2013 10:17:10 +0800 Shaohua Li <shli@kernel.org> wrote:

> I'm using a fast SSD to do swap. scan_swap_map() sometimes uses up to 20~30%
> CPU time (when cluster is hard to find, the CPU time can be up to 80%), which
> becomes a bottleneck.  scan_swap_map() scans a byte array to search a 256 page
> cluster, which is very slow.
> 
> Here I introduced a simple algorithm to search cluster. Since we only care
> about 256 pages cluster, we can just use a counter to track if a cluster is
> free. Every 256 pages use one int to store the counter. If the counter of a
> cluster is 0, the cluster is free. All free clusters will be added to a list,
> so searching cluster is very efficient. With this, scap_swap_map() overhead
> disappears.
> 
> Since searching cluster with a list is easy, we can easily implement a per-cpu
> cluster algorithm to do block allocation, which can make swapout more
> efficient. This is in my TODO list.
> 
> This might help low end SD card swap too. Because if the cluster is aligned, SD
> firmware can do flash erase more efficiently.
> 
> We only enable the algorithm for SSD. Hard disk swap isn't fast enough and has
> downside with the algorithm which might introduce regression (see below).
> 
> The patch slightly changes which cluster is choosen. It always adds free
> cluster to list tail. This can help wear leveling for low end SSD too. And if
> no cluster found, the scan_swap_map() will do search from the end of last
> cluster. So if no cluster found, the scan_swap_map() will do search from the
> end of last free cluster, which is random. For SSD, this isn't a problem at
> all.
> 
> Another downside is the cluster must be aligned to 256 pages, which will reduce
> the chance to find a cluster. I would expect this isn't a big problem for SSD
> because of the non-seek penality. (And this is the reason I only enable the
> algorithm for SSD).
> 
> ...
>
> --- linux.orig/mm/swapfile.c	2013-02-18 15:06:06.000000000 +0800
> +++ linux/mm/swapfile.c	2013-02-18 15:21:09.285317914 +0800
> ...
>
> +#define CLUSTER_FLAG_FREE (1 << 0)
> +#define CLUSTER_FLAG_NEXT_NULL (1 << 1)
> +#define CLUSTER_NULL (CLUSTER_FLAG_NEXT_NULL << 24)

Some code comments describing the above wouldn't hurt.

> +#define cluster_flag(info) ((info) >> 24)
> +#define cluster_set_flag(info, flag) \
> +	do { info = ((info) & 0xffffff) | ((flag) << 24); } while (0)
> +#define cluster_count(info) ((info) & 0xffffff)
> +#define cluster_set_count(info, c) \
> +	do { info = (cluster_flag(info) << 24) | (c); } while (0)
> +#define cluster_next(info) ((info) & 0xffffff)
> +#define cluster_set_next(info, n) \
> +	do { info = (cluster_flag(info) << 24) | (n); } while (0)
> +#define cluster_is_free(info) (cluster_flag(info) & CLUSTER_FLAG_FREE)

All the above can and should be implemented in C, please.  Doing so will

a) improve readability.

b) increase the likelihood of them being documented (why does this happen?)

c) provide additional typesafety and

d) fix potential bugs when the "function" is passed an expression
   with side-effects.  Three instances of this problem were added here.

> 
> ...
>
>  static int setup_swap_map_and_extents(struct swap_info_struct *p,
>  					union swap_header *swap_header,
>  					unsigned char *swap_map,
> +					unsigned int *cluster_info,
>  					unsigned long maxpages,
>  					sector_t *span)
>  {
>  	int i;
>  	unsigned int nr_good_pages;
>  	int nr_extents;
> +	unsigned long nr_clusters = DIV_ROUND_UP(maxpages, SWAPFILE_CLUSTER);

Rounding up seems wrong.  Will nr_clusters be off-by-one if maxpages is
not a multiple of SWAPFILE_CLUSTER?

> +	unsigned long idx = p->cluster_next / SWAPFILE_CLUSTER;
>  
>  	nr_good_pages = maxpages - 1;	/* omit header page */
>  
> +	p->free_cluster_head = CLUSTER_NULL;
> +	p->free_cluster_tail = CLUSTER_NULL;
> +
>  	for (i = 0; i < swap_header->info.nr_badpages; i++) {
>  		unsigned int page_nr = swap_header->info.badpages[i];
>  		if (page_nr == 0 || page_nr > swap_header->info.last_page)
> @@ -1982,11 +2097,25 @@ static int setup_swap_map_and_extents(st
>  		if (page_nr < maxpages) {
>  			swap_map[page_nr] = SWAP_MAP_BAD;
>  			nr_good_pages--;
> +			/*
> +			 * Not mark the cluster free yet, no list

s/Not/Don't/

> +			 * operation involved
> +			 */
> +			inc_cluster_info_page(p, cluster_info, page_nr);
>  		}
>  	}
>  
> +	/* Not mark the cluster free yet, no list operation involved */

s/Not/Won't/

> +	for (i = maxpages; i < round_up(maxpages, SWAPFILE_CLUSTER); i++)
> +		inc_cluster_info_page(p, cluster_info, i);
> +
>  	if (nr_good_pages) {
>  		swap_map[0] = SWAP_MAP_BAD;
> +		/*
> +		 * Not mark the cluster free yet, no list
> +		 * operation involved
> +		 */
> +		inc_cluster_info_page(p, cluster_info, 0);
>  		p->max = maxpages;
>  		p->pages = nr_good_pages;
>  		nr_extents = setup_swap_extents(p, span);
> 
> ...
>
> @@ -2089,13 +2240,24 @@ SYSCALL_DEFINE2(swapon, const char __use
>  		error = -ENOMEM;
>  		goto bad_swap;
>  	}
> +	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
> +		p->flags |= SWP_SOLIDSTATE;
> +		p->cluster_next = 1 + (random32() % p->highest_bit);

The random32() usage was unchangelogged and uncommented.  A comment
would be better, please.  Explain the concept, not the code.

Also, random32 was removed.  Use prandom_u32().

> +		cluster_info = vzalloc(DIV_ROUND_UP(maxpages,
> +			SWAPFILE_CLUSTER) * sizeof(*cluster_info));
> +		if (!cluster_info) {
> +			error = -ENOMEM;
> +			goto bad_swap;
> +		}
> +	}
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
