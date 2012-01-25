Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id B916F6B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 18:25:15 -0500 (EST)
Received: by pbaa12 with SMTP id a12so253782pba.14
        for <linux-mm@kvack.org>; Wed, 25 Jan 2012 15:25:15 -0800 (PST)
Date: Wed, 25 Jan 2012 15:25:00 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Patch] tmpfs: clean up shmem_find_get_pages_and_swap()
In-Reply-To: <1327420133-16551-1-git-send-email-xiyou.wangcong@gmail.com>
Message-ID: <alpine.LSU.2.00.1201251509480.2141@eggly.anvils>
References: <1327420133-16551-1-git-send-email-xiyou.wangcong@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 24 Jan 2012, Cong Wang wrote:

> This patch cleans up shmem_find_get_pages_and_swap() interface:
> 
> a) Pass struct pagevec* instead of ->pages
> b) Check if nr_pages is greater than PAGEVEC_SIZE inside the function
> c) Return the result via ->nr instead of using return value
> 
> Compiling test only.
> 
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

I don't see any cleanup: just a difference in taste, I suppose.

shmem_find_get_pages_and_swap() is modelled on find_get_pages():
I'd prefer to keep it that way unless there's good reason to diverge.

I do see a slight change in behaviour, where you've undone the range
limitation (coming from invalidate_inode_pages2_range() originally, but
now in several functions in mm/truncate.c).  I think you misunderstood

> -			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,

When doing a range, that's trying to stop the radix_tree gang lookup
looking further than could ever be necessary.  Not a big deal, it is
imperfect anyway - makes more sense when the range is 1 than larger;
but shouldn't be undone without justification.

Hugh

> 
> ---
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 269d049..c4e08e2 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -312,15 +312,19 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
>  /*
>   * Like find_get_pages, but collecting swap entries as well as pages.
>   */
> -static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
> +static void shmem_find_get_pages_and_swap(struct address_space *mapping,
>  					pgoff_t start, unsigned int nr_pages,
> -					struct page **pages, pgoff_t *indices)
> +					struct pagevec *pvec, pgoff_t *indices)
>  {
>  	unsigned int i;
>  	unsigned int ret;
>  	unsigned int nr_found;
> +	struct page **pages = pvec->pages;
>  
>  	rcu_read_lock();
> +
> +	if (nr_pages > PAGEVEC_SIZE)
> +		nr_pages = PAGEVEC_SIZE;
>  restart:
>  	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
>  				(void ***)pages, indices, start, nr_pages);
> @@ -357,7 +361,7 @@ export:
>  	if (unlikely(!ret && nr_found))
>  		goto restart;
>  	rcu_read_unlock();
> -	return ret;
> +	pvec->nr = ret;
>  }
>  
>  /*
> @@ -409,8 +413,8 @@ void shmem_unlock_mapping(struct address_space *mapping)
>  		 * Avoid pagevec_lookup(): find_get_pages() returns 0 as if it
>  		 * has finished, if it hits a row of PAGEVEC_SIZE swap entries.
>  		 */
> -		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
> -					PAGEVEC_SIZE, pvec.pages, indices);
> +		shmem_find_get_pages_and_swap(mapping, index,
> +					PAGEVEC_SIZE, &pvec, indices);
>  		if (!pvec.nr)
>  			break;
>  		index = indices[pvec.nr - 1] + 1;
> @@ -442,9 +446,8 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
>  	pagevec_init(&pvec, 0);
>  	index = start;
>  	while (index <= end) {
> -		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
> -			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
> -							pvec.pages, indices);
> +		shmem_find_get_pages_and_swap(mapping, index,
> +			end - index + 1, &pvec, indices);
>  		if (!pvec.nr)
>  			break;
>  		mem_cgroup_uncharge_start();
> @@ -490,9 +493,8 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
>  	index = start;
>  	for ( ; ; ) {
>  		cond_resched();
> -		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
> -			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
> -							pvec.pages, indices);
> +		shmem_find_get_pages_and_swap(mapping, index,
> +			end - index + 1, &pvec, indices);
>  		if (!pvec.nr) {
>  			if (index == start)
>  				break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
