Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB1186B42E6
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 12:22:57 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id h11so3417886pfj.13
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 09:22:57 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id s8si864349plq.345.2018.11.26.09.22.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 26 Nov 2018 09:22:56 -0800 (PST)
Date: Mon, 26 Nov 2018 09:22:55 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: prototype: rid swapoff of quadratic complexity
Message-ID: <20181126172255.GK3065@bombadil.infradead.org>
References: <20181126165521.19777-1-vpillai@digitalocean.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126165521.19777-1-vpillai@digitalocean.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineeth Remanan Pillai <vpillai@digitalocean.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>

On Mon, Nov 26, 2018 at 04:55:21PM +0000, Vineeth Remanan Pillai wrote:
> +	do {
> +		XA_STATE(xas, &mapping->i_pages, start);
> +		int i;
> +		int entries = 0;
> +		struct page *page;
> +		pgoff_t indices[PAGEVEC_SIZE];
> +		unsigned long end = start + PAGEVEC_SIZE;
>  
> +		rcu_read_lock();
> +		xas_for_each(&xas, page, end) {

I think this is a mistake.  You should probably specify ULONG_MAX for the
end.  Otherwise if there are no swap entries in the first 60kB of the file,
you'll just exit.  That does mean you'll need to check 'entries' for
hitting PAGEVEC_SIZE.

> +			if (xas_retry(&xas, page))
> +				continue;
>  
> +			if (!xa_is_value(page))
> +				continue;
>  
> +			indices[entries++] = xas.xa_index;
> +
> +			if (need_resched()) {
> +				xas_pause(&xas);
> +				cond_resched_rcu();
> +			}
>  		}
> +		rcu_read_unlock();
> +
> +		if (entries == 0)
> +			break;
> +
> +		for (i = 0; i < entries; i++) {
> +			int err = 0;
> +
> +			err = shmem_getpage(inode, indices[i],
> +					    &page, SGP_CACHE);
> +			if (err == 0) {
> +				unlock_page(page);
> +				put_page(page);
> +			}
> +			if (err == -ENOMEM)
> +				goto out;
> +			else
> +				error = err;
> +		}
> +		start = xas.xa_index;
> +	} while (true);
> +
> +out:
>  	return error;
>  }

This seems terribly complicated.  You run through i_pages, record the
indices of the swap entries, then go back and look them up again by
calling shmem_getpage() which calls the incredibly complex 300 line
shmem_getpage_gfp().

Can we refactor shmem_getpage_gfp() to skip some of the checks which
aren't necessary when called from this path, and turn this into a nice
simple xas_for_each() loop which works one entry at a time?

>  /*
> - * Search through swapped inodes to find and replace swap by page.
> + * Read all the shared memory data that resides in the swap
> + * device 'type' back into memory, so the swap device can be
> + * unused.
>   */
> -int shmem_unuse(swp_entry_t swap, struct page *page)
> +int shmem_unuse(unsigned int type)
>  {
> -	struct list_head *this, *next;
>  	struct shmem_inode_info *info;
> -	struct mem_cgroup *memcg;
> +	struct inode *inode;
> +	struct inode *prev_inode = NULL;
> +	struct list_head *p;
> +	struct list_head *next;
>  	int error = 0;
>  
> -	/*
> -	 * There's a faint possibility that swap page was replaced before
> -	 * caller locked it: caller will come back later with the right page.
> -	 */
> -	if (unlikely(!PageSwapCache(page) || page_private(page) != swap.val))
> -		goto out;
> +	if (list_empty(&shmem_swaplist))
> +		return 0;
> +
> +	mutex_lock(&shmem_swaplist_mutex);
> +	p = &shmem_swaplist;
>  
>  	/*
> -	 * Charge page using GFP_KERNEL while we can wait, before taking
> -	 * the shmem_swaplist_mutex which might hold up shmem_writepage().
> -	 * Charged back to the user (not to caller) when swap account is used.
> +	 * The extra refcount on the inode is necessary to safely dereference
> +	 * p->next after re-acquiring the lock. New shmem inodes with swap
> +	 * get added to the end of the list and we will scan them all.
>  	 */
> -	error = mem_cgroup_try_charge_delay(page, current->mm, GFP_KERNEL,
> -					    &memcg, false);
> -	if (error)
> -		goto out;
> -	/* No memory allocation: swap entry occupies the slot for the page */
> -	error = -EAGAIN;
> +	list_for_each_safe(p, next, &shmem_swaplist) {
> +		info = list_entry(p, struct shmem_inode_info, swaplist);

This could use list_for_each_entry_safe(), right?
