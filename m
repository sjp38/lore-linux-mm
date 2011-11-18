Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C97696B0069
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 19:30:18 -0500 (EST)
Date: Thu, 17 Nov 2011 16:30:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] mm: abort inode pruning if it has active pages
Message-Id: <20111117163016.d98ef860.akpm@linux-foundation.org>
In-Reply-To: <20111116134747.8958.11569.stgit@zurg>
References: <20111116134747.8958.11569.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 16 Nov 2011 17:47:47 +0300
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Inode cache pruning can throw out some usefull data from page cache.
> This patch aborts inode invalidation and keep inode alive if it still has
> active pages.
> 

hm, I suppose so.

I also suppose there are various risks related to failing to reclaim
inodes due to ongoing userspace activity and then running out of lowmem
pages.

> It improves interaction between inode cache and page cache.

Well, this is the key part of the patch and it is the thing which we
are most interested in.  But you didn't tell us anything about it!

So please, provide us with much more detailed information on the
observed benefits.

> 
> diff --git a/fs/inode.c b/fs/inode.c
> index 1f6c48d..8d55a63 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -663,8 +663,8 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
>  			spin_unlock(&inode->i_lock);
>  			spin_unlock(&sb->s_inode_lru_lock);
>  			if (remove_inode_buffers(inode))
> -				reap += invalidate_mapping_pages(&inode->i_data,
> -								0, -1);
> +				reap += invalidate_inode_inactive_pages(
> +						&inode->i_data, 0, -1);
>  			iput(inode);
>  			spin_lock(&sb->s_inode_lru_lock);
>  
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 0c4df26..05875d7 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2211,6 +2211,8 @@ extern int invalidate_partition(struct gendisk *, int);
>  #endif
>  unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  					pgoff_t start, pgoff_t end);
> +unsigned long invalidate_inode_inactive_pages(struct address_space *mapping,
> +					pgoff_t start, pgoff_t end);
>  
>  static inline void invalidate_remote_inode(struct inode *inode)
>  {
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 632b15e..ac739bc 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -379,6 +379,52 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
>  EXPORT_SYMBOL(invalidate_mapping_pages);
>  
>  /*
> + * This is like invalidate_mapping_pages(),
> + * except it aborts invalidation at the first active page.
> + */
> +unsigned long invalidate_inode_inactive_pages(struct address_space *mapping,
> +					    pgoff_t start, pgoff_t end)
> +{
> +	struct pagevec pvec;
> +	pgoff_t index = start;
> +	unsigned long ret;
> +	unsigned long count = 0;
> +	int i;
> +
> +	pagevec_init(&pvec, 0);
> +	while (index <= end && pagevec_lookup(&pvec, mapping, index,
> +			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
> +
> +		mem_cgroup_uncharge_start();
> +		for (i = 0; i < pagevec_count(&pvec); i++) {
> +			struct page *page = pvec.pages[i];
> +
> +			if (PageActive(page)) {
> +				index = end;
> +				break;
> +			}
> +
> +			/* We rely upon deletion not changing page->index */
> +			index = page->index;
> +			if (index > end)
> +				break;
> +
> +			if (!trylock_page(page))
> +				continue;
> +			WARN_ON(page->index != index);
> +			ret = invalidate_inode_page(page);
> +			unlock_page(page);
> +			count += ret;
> +		}
> +		pagevec_release(&pvec);
> +		mem_cgroup_uncharge_end();
> +		cond_resched();
> +		index++;
> +	}
> +	return count;
> +}

We shouldn't just copy-n-paste invalidate_mapping_pages() like this. 
Can't we share the function by passing in a pointer to a callback
function (invalidate_inode_page or a new
invalidate_inode_page_unless_it_is_active).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
