Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 613806B0033
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 16:59:17 -0400 (EDT)
Date: Tue, 20 Aug 2013 13:59:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 5/9] mm + fs: store shadow entries in page cache
Message-Id: <20130820135915.80e05e1554597666a8e6ef88@linux-foundation.org>
In-Reply-To: <1376767883-4411-6-git-send-email-hannes@cmpxchg.org>
References: <1376767883-4411-1-git-send-email-hannes@cmpxchg.org>
	<1376767883-4411-6-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, 17 Aug 2013 15:31:19 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Reclaim will be leaving shadow entries in the page cache radix tree
> upon evicting the real page.  As those pages are found from the LRU,
> an iput() can lead to the inode being freed concurrently.  At this
> point, reclaim must no longer install shadow pages because the inode
> freeing code needs to ensure the page tree is really empty.
> 
> Add an address_space flag, AS_EXITING, that the inode freeing code
> sets under the tree lock before doing the final truncate.  Reclaim
> will check for this flag before installing shadow pages.
> 
> ...
>
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -503,6 +503,7 @@ void clear_inode(struct inode *inode)
>  	 */
>  	spin_lock_irq(&inode->i_data.tree_lock);
>  	BUG_ON(inode->i_data.nrpages);
> +	BUG_ON(inode->i_data.nrshadows);
>  	spin_unlock_irq(&inode->i_data.tree_lock);
>  	BUG_ON(!list_empty(&inode->i_data.private_list));
>  	BUG_ON(!(inode->i_state & I_FREEING));
> @@ -545,10 +546,14 @@ static void evict(struct inode *inode)
>  	 */
>  	inode_wait_for_writeback(inode);
>  
> +	spin_lock_irq(&inode->i_data.tree_lock);
> +	mapping_set_exiting(&inode->i_data);
> +	spin_unlock_irq(&inode->i_data.tree_lock);

mapping_set_exiting() is atomic and the locking here probably doesn't do
anythng useful.


>  	if (op->evict_inode) {
>  		op->evict_inode(inode);
>  	} else {
> -		if (inode->i_data.nrpages)
> +		if (inode->i_data.nrpages || inode->i_data.nrshadows)
>  			truncate_inode_pages(&inode->i_data, 0);
>  		clear_inode(inode);
>  	}
> 
> ...
>
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -416,6 +416,7 @@ struct address_space {
>  	struct mutex		i_mmap_mutex;	/* protect tree, count, list */
>  	/* Protected by tree_lock together with the radix tree */
>  	unsigned long		nrpages;	/* number of total pages */
> +	unsigned long		nrshadows;	/* number of shadow entries */
>  	pgoff_t			writeback_index;/* writeback starts here */
>  	const struct address_space_operations *a_ops;	/* methods */
>  	unsigned long		flags;		/* error bits/gfp mask */

This grows the size of the in-core inode.  There can be tremendous
numbers of those so this was a significantly costly change.

And this whole patchset contains no data which permits us to agree that
this cost was worthwhile.

> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index b6854b7..db3a78b 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -25,6 +25,7 @@ enum mapping_flags {
>  	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
>  	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
>  	AS_BALLOON_MAP  = __GFP_BITS_SHIFT + 4, /* balloon page special map */
> +	AS_EXITING	= __GFP_BITS_SHIFT + 5, /* inode is being evicted */

This is far too little documentation.  I suggest adding the complete
rationale at the mapping_set_exiting() definition site.  Or perhaps at
the mapping_set_exiting callsite in evict().

>  };
>  
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
