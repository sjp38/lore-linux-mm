Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id CCDBE6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 02:05:46 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id zv4so86236lbb.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 23:05:46 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c10si8280832wjt.45.2016.05.17.23.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 23:05:45 -0700 (PDT)
Date: Wed, 18 May 2016 02:03:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Use after free in workingset LRU handling
Message-ID: <20160518060348.GA31056@cmpxchg.org>
References: <20160512172722.GC30647@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160512172722.GC30647@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>

Hi Jan,

sorry for the delay, I was cut off from email while traveling.

On Thu, May 12, 2016 at 07:27:22PM +0200, Jan Kara wrote:
> Hello,
> 
> when testing recent DAX fixes, I was puzzled by shadow_lru_isolate()
> barfing on radix tree nodes attached to DAX mappings (as DAX mappings have
> no shadow entries and I took care to not insert radix tree nodes for such
> mappings into workingset_shadow_nodes LRU list. After some investigation, I
> think there is a use after free issue in the handling of radix tree nodes
> by workingset code. The following seems to be possible:
> 
> Radix tree node is created, is has two page pointers for indices 0 and 1.
> 
> Page pointer for index 0 gets replaced with a shadow entry, radix tree
> node gets inserted into workingset_shadow_nodes
> 
> Truncate happens removing page at index 1, __radix_tree_delete_node() in
> page_cache_tree_delete() frees the radix tree node (as it has only single
> entry at index 0 and thus we can shrink the tree) while it is still in LRU
> list!

Due to the way shadow entries are counted, the tree is not actually
shrunk if there is one shadow at index 0.

		/*
		 * The candidate node has more than one child, or its child
		 * is not at the leftmost slot, or it is a multiorder entry,
		 * we cannot shrink.
		 */
		if (to_free->count != 1)
			break;

vs:

static inline void workingset_node_shadows_inc(struct radix_tree_node *node)
{
	node->count += 1U << RADIX_TREE_COUNT_SHIFT;
}

So the use-after-free scenario isn't possible here.

Admittedly, it really isn't pretty. The mess is caused by the page
cache mucking around with structures that should be private to the
radix tree implementation, but I can't think of a good way to solve
this without increasing struct radix_tree_node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
