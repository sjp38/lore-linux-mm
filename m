Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 366686B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 00:07:46 -0500 (EST)
Date: Wed, 21 Dec 2011 16:07:40 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] radix_tree: take radix_tree_path off stack
Message-ID: <20111221050740.GD23662@dastard>
References: <alpine.LSU.2.00.1112182234310.1503@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1112182234310.1503@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Dec 18, 2011 at 10:41:39PM -0800, Hugh Dickins wrote:
> Down, down in the deepest depths of GFP_NOIO page reclaim, we have
> shrink_page_list() calling __remove_mapping() calling __delete_from_
> swap_cache() or __delete_from_page_cache().
> 
> You would not expect those to need much stack, but in fact they call
> radix_tree_delete(): which declares a 192-byte radix_tree_path array
> on its stack (to record the node,offsets it visits when descending,
> in case it needs to ascend to update them).  And if any tag is still
> set [1], that calls radix_tree_tag_clear(), which declares a further
> such 192-byte radix_tree_path array on the stack.  (At least we have
> interrupts disabled here, so won't then be pushing registers too.)
> 
> That was probably a good choice when most users were 32-bit (array
> of half the size), and adding fields to radix_tree_node would have
> bloated it unnecessarily.  But nowadays many are 64-bit, and each
> radix_tree_node contains a struct rcu_head, which is only used when
> freeing; whereas the radix_tree_path info is only used for updating
> the tree (deleting, clearing tags or setting tags if tagged) when a
> lock must be held, of no interest when accessing the tree locklessly.
> 
> So add a parent pointer to the radix_tree_node, in union with the
> rcu_head, and remove all uses of the radix_tree_path.  There would
> be space in that union to save the offset when descending as before
> (we can argue that a lock must already be held to exclude other users),
> but recalculating it when ascending is both easy (a constant shift and
> a constant mask) and uncommon, so it seems better just to do that.

Seems sane - any modification of the tree contents or tag has to be
done under a lock, so we can maintain parent pointers safely. And we
don't reda them under RCU conditions, so we don't need any special
handling there, either.

> Two little optimizations: no need to decrement height when descending,
> adjusting shift is enough;

*nod*

> and once radix_tree_tag_if_tagged() has set
> tag on a node and its ancestors, it need not ascend from that node again.

I'm not sure I really follow this. I think I know what you mean, but
I can't quite get it straight and the comment in the code doesn't
help me get it straight. Can you describe it a bit more - I think
I'm just being dense at the moment....

> perf on the radix tree test harness reports radix_tree_insert() as 2%
> slower (now having to set parent), but radix_tree_delete() 24% faster.
> Surely that's an exaggeration from rtth's artificially low map shift 3,
> but forcing it back to 6 still rates radix_tree_delete() 8% faster.

Nice.

> [1] Can a pagecache tag (dirty, writeback or towrite) actually still be
> set at the time of radix_tree_delete()?  Perhaps not if the filesystem
> is well-behaved.  But although I've not tracked any stack overflow down
> to this cause, I have observed a curious case in which a dirty tag is
> set and left set on tmpfs: page migration's migrate_page_copy() happens
> to use __set_page_dirty_nobuffers() to set PageDirty on the newpage,
> and that sets PAGECACHE_TAG_DIRTY as a side-effect - harmless to a
> filesystem which doesn't use tags, except for this stack depth issue.

Not sure about the page cache, but other users of the radix tree
definitely do delete objects with tags still set. For example, when
XFS is reclaiming inodes it will delete the inode from it's internal
radix trees with the reclaim tag still set on the index. This
happens for every single inode that is reclaimed, so it's anything
but seldom and should really be considered a common operation....

Couple more comments below.

> @@ -274,18 +273,23 @@ static int radix_tree_extend(struct radi
>  		if (!(node = radix_tree_node_alloc(root)))
>  			return -ENOMEM;
>  
> -		/* Increase the height.  */
> -		node->slots[0] = indirect_to_ptr(root->rnode);
> -
>  		/* Propagate the aggregated tag info into the new root */
>  		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
>  			if (root_tag_get(root, tag))
>  				tag_set(node, tag, 0);
>  		}
>  
> +		/* Increase the height.  */
>  		newheight = root->height+1;

While touching this code, fixing the adjacent whitespace damage
would be good.

>  		node->height = newheight;
>  		node->count = 1;
> +		node->parent = NULL;
> +		slot = root->rnode;
> +		if (newheight > 1) {
> +			slot = indirect_to_ptr(slot);
> +			slot->parent = node;
> +		}
> +		node->slots[0] = slot;

This would be much more obvious in function if it separated the two
different cases completely:

		if (newheight > 1) {
			slot = indirect_to_ptr(root->rnode);
			slot->parent = node;
		} else {
			slot = root->rnode;
			node->parent = NULL;
		}
		node->slots[0] = slot;

> @@ -701,15 +691,21 @@ unsigned long radix_tree_range_tag_if_ta
>  		tag_set(slot, settag, offset);
>  
>  		/* walk back up the path tagging interior nodes */
> -		pathp = &path[0];
> -		while (pathp->node) {
> +		upindex = index;
> +		while (node) {
> +			upindex >>= RADIX_TREE_MAP_SHIFT;
> +			offset = upindex & RADIX_TREE_MAP_MASK;
> +
>  			/* stop if we find a node with the tag already set */
> -			if (tag_get(pathp->node, settag, pathp->offset))
> +			if (tag_get(node, settag, offset))
>  				break;
> -			tag_set(pathp->node, settag, pathp->offset);
> -			pathp++;
> +			tag_set(node, settag, offset);
> +			node = node->parent;
>  		}
>  
> +		/* optimization: no need to walk up from this node again */
> +		node = NULL;

As per my query above: why? That's the question the comment needs to
answer....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
