Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7400A6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 03:13:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r12so23382747wme.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:13:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si8575653wjk.101.2016.05.18.00.13.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 00:13:17 -0700 (PDT)
Date: Wed, 18 May 2016 09:13:14 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Use after free in workingset LRU handling
Message-ID: <20160518071314.GA26315@quack2.suse.cz>
References: <20160512172722.GC30647@quack2.suse.cz>
 <20160518060348.GA31056@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160518060348.GA31056@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>

Hi Johannes!

On Wed 18-05-16 02:03:48, Johannes Weiner wrote:
> On Thu, May 12, 2016 at 07:27:22PM +0200, Jan Kara wrote:
> > Hello,
> > 
> > when testing recent DAX fixes, I was puzzled by shadow_lru_isolate()
> > barfing on radix tree nodes attached to DAX mappings (as DAX mappings have
> > no shadow entries and I took care to not insert radix tree nodes for such
> > mappings into workingset_shadow_nodes LRU list. After some investigation, I
> > think there is a use after free issue in the handling of radix tree nodes
> > by workingset code. The following seems to be possible:
> > 
> > Radix tree node is created, is has two page pointers for indices 0 and 1.
> > 
> > Page pointer for index 0 gets replaced with a shadow entry, radix tree
> > node gets inserted into workingset_shadow_nodes
> > 
> > Truncate happens removing page at index 1, __radix_tree_delete_node() in
> > page_cache_tree_delete() frees the radix tree node (as it has only single
> > entry at index 0 and thus we can shrink the tree) while it is still in LRU
> > list!
> 
> Due to the way shadow entries are counted, the tree is not actually
> shrunk if there is one shadow at index 0.
> 
> 		/*
> 		 * The candidate node has more than one child, or its child
> 		 * is not at the leftmost slot, or it is a multiorder entry,
> 		 * we cannot shrink.
> 		 */
> 		if (to_free->count != 1)
> 			break;
> 
> vs:
> 
> static inline void workingset_node_shadows_inc(struct radix_tree_node *node)
> {
> 	node->count += 1U << RADIX_TREE_COUNT_SHIFT;
> }
> 
> So the use-after-free scenario isn't possible here.

Ouch, you are right.

> Admittedly, it really isn't pretty. The mess is caused by the page
> cache mucking around with structures that should be private to the
> radix tree implementation, but I can't think of a good way to solve
> this without increasing struct radix_tree_node.

Yeah, it's a catch but I agree it should work as designed. Sorry for the
noise.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
