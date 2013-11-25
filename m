Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id EF5846B0035
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 18:18:22 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so6752756pbc.40
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:18:22 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id fb6si18242534pab.8.2013.11.25.15.18.20
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 15:18:21 -0800 (PST)
Date: Tue, 26 Nov 2013 10:17:16 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 6/9] mm + fs: store shadow entries in page cache
Message-ID: <20131125231716.GJ8803@dastard>
References: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
 <1385336308-27121-7-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1385336308-27121-7-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Nov 24, 2013 at 06:38:25PM -0500, Johannes Weiner wrote:
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
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
....
> @@ -545,10 +546,25 @@ static void evict(struct inode *inode)
>  	 */
>  	inode_wait_for_writeback(inode);
>  
> +	/*
> +	 * Page reclaim can not do iput() and thus can race with the
> +	 * inode teardown.  Tell it when the address space is exiting,
> +	 * so that it does not install eviction information after the
> +	 * final truncate has begun.
> +	 *
> +	 * As truncation uses a lockless tree lookup, acquire the
> +	 * spinlock to make sure any ongoing tree modification that
> +	 * does not see AS_EXITING is completed before starting the
> +	 * final truncate.
> +	 */
> +	spin_lock_irq(&inode->i_data.tree_lock);
> +	mapping_set_exiting(&inode->i_data);
> +	spin_unlock_irq(&inode->i_data.tree_lock);
> +
>  	if (op->evict_inode) {
>  		op->evict_inode(inode);
>  	} else {
> -		if (inode->i_data.nrpages)
> +		if (inode->i_data.nrpages || inode->i_data.nrshadows)
>  			truncate_inode_pages(&inode->i_data, 0);
>  		clear_inode(inode);
>  	}

Ok, so what I see here is that we need a wrapper function that
handles setting the AS_EXITING flag and doing the "final"
truncate_inode_pages() call, and the locking for the AS_EXITING flag
moved into mapping_set_exiting()

That is, because this AS_EXITING flag and it's locking constraints
are directly related to the upcoming truncate_inode_pages() call,
I'd prefer to see a helper that captures that relationship used
in all the filesystem code. e.g:

void truncate_inode_pages_final(struct address_space *mapping)
{
	spin_lock_irq(&mapping->tree_lock);
	mapping_set_exiting(mapping);
	spin_unlock_irq(&mapping->tree_lock);
	if (inode->i_data.nrpages || inode->i_data.nrshadows)
		truncate_inode_pages_range(mapping, 0, (loff_t)-1);
}

And document it in Documentation/filesystems/porting as a mandatory
function to be called from ->evict_inode() implementations before
calling clear_inode().  You can then replace all the direct calls to
truncate_inode_pages() in the evict_inode() path with a call to
truncate_inode_pages_final().

As it is, I'd really like to see that unconditional irq disable go
away from this code - disabling and enabling interrupts for every
single inode we reclaim is going to add significant overhead to this
hot code path. And given that:

> +static inline void mapping_set_exiting(struct address_space *mapping)
> +{
> +	set_bit(AS_EXITING, &mapping->flags);
> +}
> +
> +static inline int mapping_exiting(struct address_space *mapping)
> +{
> +	return test_bit(AS_EXITING, &mapping->flags);
> +}

these atomic bit ops, why do we need to take the tree_lock and
disable irqs in evict() to set this bit if there's nothing to
truncate on the inode? i.e. something like this:

void truncate_inode_pages_final(struct address_space *mapping)
{
	mapping_set_exiting(mapping);
	if (inode->i_data.nrpages || inode->i_data.nrshadows) {
		/*
		 * spinlock barrier to ensure all modifications are
		 * complete before we do the final truncate
		 */
		spin_lock_irq(&mapping->tree_lock);
		spin_unlock_irq(&mapping->tree_lock);
		truncate_inode_pages_range(mapping, 0, (loff_t)-1);
}

and thereby avoiding the mapping lock altogether for inodes that do
not require it to be taken?

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
