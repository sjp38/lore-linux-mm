Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 7CBA96B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 01:53:27 -0500 (EST)
Received: by iacb35 with SMTP id b35so12555103iac.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 22:53:26 -0800 (PST)
Date: Tue, 20 Dec 2011 22:53:17 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] radix_tree: take radix_tree_path off stack
In-Reply-To: <20111221050740.GD23662@dastard>
Message-ID: <alpine.LSU.2.00.1112202218490.4026@eggly.anvils>
References: <alpine.LSU.2.00.1112182234310.1503@eggly.anvils> <20111221050740.GD23662@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 21 Dec 2011, Dave Chinner wrote:
> On Sun, Dec 18, 2011 at 10:41:39PM -0800, Hugh Dickins wrote:
> 
> > and once radix_tree_tag_if_tagged() has set
> > tag on a node and its ancestors, it need not ascend from that node again.
> 
> I'm not sure I really follow this. I think I know what you mean, but
> I can't quite get it straight and the comment in the code doesn't
> help me get it straight. Can you describe it a bit more - I think
> I'm just being dense at the moment....

Below...

> 
> Not sure about the page cache, but other users of the radix tree
> definitely do delete objects with tags still set. For example, when
> XFS is reclaiming inodes it will delete the inode from it's internal
> radix trees with the reclaim tag still set on the index. This
> happens for every single inode that is reclaimed, so it's anything
> but seldom and should really be considered a common operation....

Thanks for that info: it was the pagecache case's deep stack that
was worrying me, and I'm only dimly aware of its other uses.

> 
> Couple more comments below.
> 
> > @@ -274,18 +273,23 @@ static int radix_tree_extend(struct radi
> >  		if (!(node = radix_tree_node_alloc(root)))
> >  			return -ENOMEM;
> >  
> > -		/* Increase the height.  */
> > -		node->slots[0] = indirect_to_ptr(root->rnode);
> > -
> >  		/* Propagate the aggregated tag info into the new root */
> >  		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
> >  			if (root_tag_get(root, tag))
> >  				tag_set(node, tag, 0);
> >  		}
> >  
> > +		/* Increase the height.  */
> >  		newheight = root->height+1;
> 
> While touching this code, fixing the adjacent whitespace damage
> would be good.

I didn't notice any: do you mean "root->height+1" instead of
"root->height + 1"?  I don't care much, and checkpatch didn't complain.

> 
> >  		node->height = newheight;
> >  		node->count = 1;
> > +		node->parent = NULL;
> > +		slot = root->rnode;
> > +		if (newheight > 1) {
> > +			slot = indirect_to_ptr(slot);
> > +			slot->parent = node;
> > +		}
> > +		node->slots[0] = slot;
> 
> This would be much more obvious in function if it separated the two
> different cases completely:
> 
> 		if (newheight > 1) {
> 			slot = indirect_to_ptr(root->rnode);
> 			slot->parent = node;
> 		} else {
> 			slot = root->rnode;
> 			node->parent = NULL;
> 		}
> 		node->slots[0] = slot;

We do need to set node->parent NULL in all cases (and cannot clear
it when freeing).  I chose the "slot = blah(slot)" style to follow the
"newptr = blah(newptr)" over in radix_tree_shrink(), thought it helped
to keep those blocks alike.

> 
> > @@ -701,15 +691,21 @@ unsigned long radix_tree_range_tag_if_ta
> >  		tag_set(slot, settag, offset);
> >  
> >  		/* walk back up the path tagging interior nodes */
> > -		pathp = &path[0];
> > -		while (pathp->node) {
> > +		upindex = index;
> > +		while (node) {
> > +			upindex >>= RADIX_TREE_MAP_SHIFT;
> > +			offset = upindex & RADIX_TREE_MAP_MASK;
> > +
> >  			/* stop if we find a node with the tag already set */
> > -			if (tag_get(pathp->node, settag, pathp->offset))
> > +			if (tag_get(node, settag, offset))
> >  				break;
> > -			tag_set(pathp->node, settag, pathp->offset);
> > -			pathp++;
> > +			tag_set(node, settag, offset);
> > +			node = node->parent;
> >  		}
> >  
> > +		/* optimization: no need to walk up from this node again */
> > +		node = NULL;
> 
> As per my query above: why? That's the question the comment needs to
> answer....

At the top of the hunk, we can see the tag_set(slot, settag, offset)
where it sets the tag in the leafnode "slot"; then it loops up to parent
"node" of slot, to parent of parent, etc, setting tag in those, but
breaking as soon as it finds the tag already set - it can be sure that
the tag must already be set on all nodes above.

If afterwards it comes to set tag at another offset (most likely the
very next) in this same leafnode, we know that it has already set tag
on the parent, the parent's parent etc., so need not bother to tag_get
from the level above to discover that.  And since we happen to have a
variable "node" which stops the loop when it's NULL, let's set it to
NULL now to stop the loop immediately in future.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
