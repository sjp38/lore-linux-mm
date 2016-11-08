Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D3EA46B0069
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 14:30:22 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r68so88248681wmd.0
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 11:30:22 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hv9si18409219wjb.232.2016.11.08.11.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 11:30:21 -0800 (PST)
Date: Tue, 8 Nov 2016 14:30:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/6] mm: workingset: switch shadow entry tracking to
 radix tree exceptional counting
Message-ID: <20161108193011.GA15802@cmpxchg.org>
References: <20161107190741.3619-1-hannes@cmpxchg.org>
 <20161107190741.3619-6-hannes@cmpxchg.org>
 <20161108102716.GL32353@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161108102716.GL32353@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Nov 08, 2016 at 11:27:16AM +0100, Jan Kara wrote:
> On Mon 07-11-16 14:07:40, Johannes Weiner wrote:
> > Currently, we track the shadow entries in the page cache in the upper
> > bits of the radix_tree_node->count, behind the back of the radix tree
> > implementation. Because the radix tree code has no awareness of them,
> > we rely on random subtleties throughout the implementation (such as
> > the node->count != 1 check in the shrinking code which is meant to
> > exclude multi-entry nodes, but also happens to skip nodes with only
> > one shadow entry since it's accounted in the upper bits). This is
> > error prone and has, in fact, caused the bug fixed in d3798ae8c6f3
> > ("mm: filemap: don't plant shadow entries without radix tree node").
> > 
> > To remove these subtleties, this patch moves shadow entry tracking
> > from the upper bits of node->count to the existing counter for
> > exceptional entries. node->count goes back to being a simple counter
> > of valid entries in the tree node and can be shrunk to a single byte.
> 
> ...
> 
> > diff --git a/mm/truncate.c b/mm/truncate.c
> > index 6ae44571d4c7..d3ce5f261f47 100644
> > --- a/mm/truncate.c
> > +++ b/mm/truncate.c
> > @@ -53,7 +53,6 @@ static void clear_exceptional_entry(struct address_space *mapping,
> >  	mapping->nrexceptional--;
> >  	if (!node)
> >  		goto unlock;
> > -	workingset_node_shadows_dec(node);
> >  	/*
> >  	 * Don't track node without shadow entries.
> >  	 *
> > @@ -61,8 +60,7 @@ static void clear_exceptional_entry(struct address_space *mapping,
> >  	 * The list_empty() test is safe as node->private_list is
> >  	 * protected by mapping->tree_lock.
> >  	 */
> > -	if (!workingset_node_shadows(node) &&
> > -	    !list_empty(&node->private_list))
> > +	if (!node->exceptional && !list_empty(&node->private_list))
> >  		list_lru_del(&workingset_shadow_nodes,
> >  				&node->private_list);
> >  	__radix_tree_delete_node(&mapping->page_tree, node);
> 
> Is this really correct now? The radix tree implementation can move a single
> exceptional entry at index 0 from a node into a direct pointer and free
> the node while it is still in the LRU list. Or am I missing something?

You're right. I missed that scenario.

> To fix this I'd prefer to just have a callback from radix tree code when it
> is freeing a node, rather that trying to second-guess its implementation in
> the page-cache code...
> 
> Otherwise the patch looks good to me and I really like the simplification!

That's a good idea. I'll do away with __radix_tree_delete_node()
altogether and move not just the slot accounting but also the tree
shrinking and the maintenance callback into __radix_tree_replace().

The page cache can then simply do

__radix_tree_replace(&mapping->page_tree, node, slot, new,
                     workingset_node_update, mapping)

And workingset_node_update() gets called on every node that changes,
where it can track and untrack it depending on count & exceptional.

I'll give it some testing before posting it, but currently it's

 include/linux/radix-tree.h |   4 +-
 include/linux/swap.h       |   1 -
 lib/radix-tree.c           | 212 ++++++++++++++++++++-----------------------
 mm/filemap.c               |  48 +---------
 mm/truncate.c              |  16 +---
 mm/workingset.c            |  31 +++++--
 6 files changed, 134 insertions(+), 178 deletions(-)

on top of the simplifications of this patch 5/6.

Thanks for your input, Jan!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
