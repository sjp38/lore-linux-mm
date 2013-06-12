Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 3EF2E6B0036
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 18:21:24 -0400 (EDT)
Date: Wed, 12 Jun 2013 15:21:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/4 v4]swap: change block allocation algorithm for SSD
Message-Id: <20130612152122.1f18457bbf6fc096b70eea94@linux-foundation.org>
In-Reply-To: <20130326053706.GA19646@kernel.org>
References: <20130326053706.GA19646@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com

On Tue, 26 Mar 2013 13:37:06 +0800 Shaohua Li <shli@kernel.org> wrote:

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
> +/*
> + * cluster info is a unsigned int, the highest 8 bits stores flags, the low 24
> + * bits stores next cluster if the cluster is free or cluster counter otherwise
> + */
> +#define CLUSTER_FLAG_FREE (1 << 0) /* This cluster is free */
> +#define CLUSTER_FLAG_NEXT_NULL (1 << 1) /* This cluster has no next cluster */
> +#define CLUSTER_NULL (CLUSTER_FLAG_NEXT_NULL << 24)
> +static inline unsigned int cluster_flag(unsigned int info)
> +{
> +	return info >> 24;
> +}
> +
> +static inline void cluster_set_flag(unsigned int *info, unsigned int flag)
> +{
> +	*info = ((*info) & 0xffffff) | (flag << 24);
> +}
> +
> +static inline unsigned int cluster_count(unsigned int info)
> +{
> +	return info & 0xffffff;
> +}
> +
> +static inline void cluster_set_count(unsigned int *info, unsigned int c)
> +{
> +	*info = (cluster_flag(*info) << 24) | c;
> +}
> +
> +static inline unsigned int cluster_next(unsigned int info)
> +{
> +	return info & 0xffffff;
> +}
> +
> +static inline void cluster_set_next(unsigned int *info, unsigned int n)
> +{
> +	*info = (cluster_flag(*info) << 24) | n;
> +}
> +
> +static inline bool cluster_is_free(unsigned int info)
> +{
> +	return cluster_flag(info) & CLUSTER_FLAG_FREE;
> +}

This is all a bit gruesome and might generate inefficient code.

It may look a bit better if we were to do

#define CLUSTER_FLAG_FREE (1 << 24) /* This cluster is free */
#define CLUSTER_FLAG_NEXT_NULL (2 << 24)

However I suspect it would work out very nicely if the code were to use
C bitfields?

> +static inline void inc_cluster_info_page(struct swap_info_struct *p,
> +	unsigned int *cluster_info, unsigned long page_nr)
> +{
> +	unsigned long idx = page_nr / SWAPFILE_CLUSTER;
> +
> +	if (!cluster_info)
> +		return;
> +	if (cluster_is_free(cluster_info[idx])) {
> +		VM_BUG_ON(p->free_cluster_head != idx);
> +		p->free_cluster_head = cluster_next(cluster_info[idx]);
> +		if (p->free_cluster_tail == idx) {
> +			p->free_cluster_tail = CLUSTER_NULL;
> +			p->free_cluster_head = CLUSTER_NULL;
> +		}
> +		cluster_set_flag(&cluster_info[idx], 0);
> +		cluster_set_count(&cluster_info[idx], 0);
> +	}
> +
> +	VM_BUG_ON(cluster_count(cluster_info[idx]) >= SWAPFILE_CLUSTER);
> +	cluster_set_count(&cluster_info[idx],
> +		cluster_count(cluster_info[idx]) + 1);
> +}
> +
> +static inline void dec_cluster_info_page(struct swap_info_struct *p,
> +	unsigned int *cluster_info, unsigned long page_nr)
> +{
> +	unsigned long idx = page_nr / SWAPFILE_CLUSTER;
> +
> +	if (!cluster_info)
> +		return;
> +
> +	VM_BUG_ON(cluster_count(cluster_info[idx]) == 0);
> +	cluster_set_count(&cluster_info[idx],
> +		cluster_count(cluster_info[idx]) - 1);
> +
> +	if (cluster_count(cluster_info[idx]) == 0) {
> +		cluster_set_flag(&cluster_info[idx], CLUSTER_FLAG_FREE);
> +		if (p->free_cluster_head == CLUSTER_NULL) {
> +			p->free_cluster_head = idx;
> +			p->free_cluster_tail = idx;
> +		} else {
> +			cluster_set_next(&cluster_info[p->free_cluster_tail],
> +				idx);
> +			p->free_cluster_tail = idx;
> +		}
> +	}
> +}

I'd remove the 'inline' keywords here - the compiler will work it out
for us.

> +/*
> + * It's possible scan_swap_map() uses a free cluster in the middle of free
> + * cluster list. Avoiding such abuse to avoid list corruption.
> + */
> +static inline bool scan_swap_map_recheck_cluster(struct swap_info_struct *si,
> +	unsigned long offset)
> +{
> +	offset /= SWAPFILE_CLUSTER;
> +	return si->free_cluster_head != CLUSTER_NULL &&
> +		offset != si->free_cluster_head &&
> +		cluster_is_free(si->cluster_info[offset]);
> +}
> +
>  static unsigned long scan_swap_map(struct swap_info_struct *si,
>  				   unsigned char usage)
>  {
>
> ...
>
> @@ -2102,13 +2277,28 @@ SYSCALL_DEFINE2(swapon, const char __use
>  		error = -ENOMEM;
>  		goto bad_swap;
>  	}
> +	if (p->bdev && blk_queue_nonrot(bdev_get_queue(p->bdev))) {
> +		p->flags |= SWP_SOLIDSTATE;
> +		/*
> +		 * select a random position to start with to help wear leveling
> +		 * SSD
> +		 */
> +		p->cluster_next = 1 + (prandom_u32() % p->highest_bit);
> +
> +		cluster_info = vzalloc(DIV_ROUND_UP(maxpages,
> +			SWAPFILE_CLUSTER) * sizeof(*cluster_info));

Why vmalloc()?  How large can this allocation be?

> +		if (!cluster_info) {
> +			error = -ENOMEM;
> +			goto bad_swap;
> +		}
> +	}
>  
>  	error = swap_cgroup_swapon(p->type, maxpages);
>  	if (error)
>  		goto bad_swap;
>  
>  	nr_extents = setup_swap_map_and_extents(p, swap_header, swap_map,
> -		maxpages, &span);
> +		cluster_info, maxpages, &span);
>  	if (unlikely(nr_extents < 0)) {
>  		error = nr_extents;
>  		goto bad_swap;
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
