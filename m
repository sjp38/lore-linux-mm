Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 98A3E6B0039
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 13:43:07 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id m19so972608wiv.10
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 10:43:07 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id dr3si7476140wib.64.2014.01.22.10.43.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 10:43:06 -0800 (PST)
Date: Wed, 22 Jan 2014 13:42:17 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20140122184217.GD4407@cmpxchg.org>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-10-git-send-email-hannes@cmpxchg.org>
 <20140113073947.GR1992@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140113073947.GR1992@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jan 13, 2014 at 04:39:47PM +0900, Minchan Kim wrote:
> On Fri, Jan 10, 2014 at 01:10:43PM -0500, Johannes Weiner wrote:
> > Previously, page cache radix tree nodes were freed after reclaim
> > emptied out their page pointers.  But now reclaim stores shadow
> > entries in their place, which are only reclaimed when the inodes
> > themselves are reclaimed.  This is problematic for bigger files that
> > are still in use after they have a significant amount of their cache
> > reclaimed, without any of those pages actually refaulting.  The shadow
> > entries will just sit there and waste memory.  In the worst case, the
> > shadow entries will accumulate until the machine runs out of memory.
> > 
> > To get this under control, the VM will track radix tree nodes
> > exclusively containing shadow entries on a per-NUMA node list.
> > Per-NUMA rather than global because we expect the radix tree nodes
> > themselves to be allocated node-locally and we want to reduce
> > cross-node references of otherwise independent cache workloads.  A
> > simple shrinker will then reclaim these nodes on memory pressure.
> > 
> > A few things need to be stored in the radix tree node to implement the
> > shadow node LRU and allow tree deletions coming from the list:
> > 
> > 1. There is no index available that would describe the reverse path
> >    from the node up to the tree root, which is needed to perform a
> >    deletion.  To solve this, encode in each node its offset inside the
> >    parent.  This can be stored in the unused upper bits of the same
> >    member that stores the node's height at no extra space cost.
> > 
> > 2. The number of shadow entries needs to be counted in addition to the
> >    regular entries, to quickly detect when the node is ready to go to
> >    the shadow node LRU list.  The current entry count is an unsigned
> >    int but the maximum number of entries is 64, so a shadow counter
> >    can easily be stored in the unused upper bits.
> > 
> > 3. Tree modification needs tree lock and tree root, which are located
> >    in the address space, so store an address_space backpointer in the
> >    node.  The parent pointer of the node is in a union with the 2-word
> >    rcu_head, so the backpointer comes at no extra cost as well.
> > 
> > 4. The node needs to be linked to an LRU list, which requires a list
> >    head inside the node.  This does increase the size of the node, but
> >    it does not change the number of objects that fit into a slab page.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  include/linux/list_lru.h   |   2 +
> >  include/linux/mmzone.h     |   1 +
> >  include/linux/radix-tree.h |  32 +++++++++---
> >  include/linux/swap.h       |   1 +
> >  lib/radix-tree.c           |  36 ++++++++------
> >  mm/filemap.c               |  77 +++++++++++++++++++++++------
> >  mm/list_lru.c              |   8 +++
> >  mm/truncate.c              |  20 +++++++-
> >  mm/vmstat.c                |   1 +
> >  mm/workingset.c            | 121 +++++++++++++++++++++++++++++++++++++++++++++
> >  10 files changed, 259 insertions(+), 40 deletions(-)
> > 
> > diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> > index 3ce541753c88..b02fc233eadd 100644
> > --- a/include/linux/list_lru.h
> > +++ b/include/linux/list_lru.h
> > @@ -13,6 +13,8 @@
> >  /* list_lru_walk_cb has to always return one of those */
> >  enum lru_status {
> >  	LRU_REMOVED,		/* item removed from list */
> > +	LRU_REMOVED_RETRY,	/* item removed, but lock has been
> > +				   dropped and reacquired */
> >  	LRU_ROTATE,		/* item referenced, give another pass */
> >  	LRU_SKIP,		/* item cannot be locked, skip */
> >  	LRU_RETRY,		/* item not freeable. May drop the lock
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 118ba9f51e86..8cac5a7ef7a7 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -144,6 +144,7 @@ enum zone_stat_item {
> >  #endif
> >  	WORKINGSET_REFAULT,
> >  	WORKINGSET_ACTIVATE,
> > +	WORKINGSET_NODERECLAIM,
> >  	NR_ANON_TRANSPARENT_HUGEPAGES,
> >  	NR_FREE_CMA_PAGES,
> >  	NR_VM_ZONE_STAT_ITEMS };
> > diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> > index 13636c40bc42..33170dbd9db4 100644
> > --- a/include/linux/radix-tree.h
> > +++ b/include/linux/radix-tree.h
> > @@ -72,21 +72,37 @@ static inline int radix_tree_is_indirect_ptr(void *ptr)
> >  #define RADIX_TREE_TAG_LONGS	\
> >  	((RADIX_TREE_MAP_SIZE + BITS_PER_LONG - 1) / BITS_PER_LONG)
> >  
> > +#define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
> > +#define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
> > +					  RADIX_TREE_MAP_SHIFT))
> > +
> > +/* Height component in node->path */
> > +#define RADIX_TREE_HEIGHT_SHIFT	(RADIX_TREE_MAX_PATH + 1)
> > +#define RADIX_TREE_HEIGHT_MASK	((1UL << RADIX_TREE_HEIGHT_SHIFT) - 1)
> > +
> > +/* Internally used bits of node->count */
> > +#define RADIX_TREE_COUNT_SHIFT	(RADIX_TREE_MAP_SHIFT + 1)
> > +#define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)
> > +
> >  struct radix_tree_node {
> > -	unsigned int	height;		/* Height from the bottom */
> > +	unsigned int	path;	/* Offset in parent & height from the bottom */
> >  	unsigned int	count;
> >  	union {
> > -		struct radix_tree_node *parent;	/* Used when ascending tree */
> > -		struct rcu_head	rcu_head;	/* Used when freeing node */
> > +		struct {
> > +			/* Used when ascending tree */
> > +			struct radix_tree_node *parent;
> > +			/* For tree user */
> > +			void *private_data;
> > +		};
> > +		/* Used when freeing node */
> > +		struct rcu_head	rcu_head;
> >  	};
> > +	/* For tree user */
> > +	struct list_head private_list;
> >  	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
> >  	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
> >  };
> >  
> > -#define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
> > -#define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
> > -					  RADIX_TREE_MAP_SHIFT))
> > -
> >  /* root tags are stored in gfp_mask, shifted by __GFP_BITS_SHIFT */
> >  struct radix_tree_root {
> >  	unsigned int		height;
> > @@ -251,7 +267,7 @@ void *__radix_tree_lookup(struct radix_tree_root *root, unsigned long index,
> >  			  struct radix_tree_node **nodep, void ***slotp);
> >  void *radix_tree_lookup(struct radix_tree_root *, unsigned long);
> >  void **radix_tree_lookup_slot(struct radix_tree_root *, unsigned long);
> > -bool __radix_tree_delete_node(struct radix_tree_root *root, unsigned long index,
> > +bool __radix_tree_delete_node(struct radix_tree_root *root,
> >  			      struct radix_tree_node *node);
> >  void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
> >  void *radix_tree_delete(struct radix_tree_root *, unsigned long);
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index b83cf61403ed..102e37bc82d5 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -264,6 +264,7 @@ struct swap_list_t {
> >  void *workingset_eviction(struct address_space *mapping, struct page *page);
> >  bool workingset_refault(void *shadow);
> >  void workingset_activation(struct page *page);
> > +extern struct list_lru workingset_shadow_nodes;
> >  
> >  /* linux/mm/page_alloc.c */
> >  extern unsigned long totalram_pages;
> > diff --git a/lib/radix-tree.c b/lib/radix-tree.c
> > index e601c56a43d0..0a0895371447 100644
> > --- a/lib/radix-tree.c
> > +++ b/lib/radix-tree.c
> > @@ -342,7 +342,8 @@ static int radix_tree_extend(struct radix_tree_root *root, unsigned long index)
> >  
> >  		/* Increase the height.  */
> >  		newheight = root->height+1;
> > -		node->height = newheight;
> > +		BUG_ON(newheight & ~RADIX_TREE_HEIGHT_MASK);
> > +		node->path = newheight;
> 
> Nitpick:
> It would be better to add some accessor for path and offset for
> readability and future enhance?

Nodes are instantiated in one central place, I can't see the value in
obscuring a straight-forward bitop with a radix_tree_node_set_offset()
call.

And height = node->path & RADIX_TREE_HEIGHT_MASK should be fairly
descriptive, I think.

> > @@ -123,9 +129,39 @@ static void page_cache_tree_delete(struct address_space *mapping,
> >  		 * same time and miss a shadow entry.
> >  		 */
> >  		smp_wmb();
> > -	} else
> > -		radix_tree_delete(&mapping->page_tree, page->index);
> > +	}
> >  	mapping->nrpages--;
> > +
> > +	if (!node) {
> > +		/* Clear direct pointer tags in root node */
> > +		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
> > +		radix_tree_replace_slot(slot, shadow);
> > +		return;
> > +	}
> > +
> > +	/* Clear tree tags for the removed page */
> > +	index = page->index;
> > +	offset = index & RADIX_TREE_MAP_MASK;
> > +	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
> > +		if (test_bit(offset, node->tags[tag]))
> > +			radix_tree_tag_clear(&mapping->page_tree, index, tag);
> > +	}
> > +
> > +	/* Delete page, swap shadow entry */
> > +	radix_tree_replace_slot(slot, shadow);
> > +	node->count--;
> > +	if (shadow)
> > +		node->count += 1U << RADIX_TREE_COUNT_SHIFT;
> 
> Nitpick2:
> It should be a function of workingset.c rather than exposing
> RADIX_TREE_COUNT_SHIFT?
> 
> IMO, It would be better to provide some accessor functions here, too.

The shadow maintenance and node lifetime management are pretty
interwoven to share branches and reduce instructions as these are
common paths.  I don't see how this could result in cleaner code while
keeping these advantages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
