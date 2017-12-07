Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B4C3B6B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 19:13:50 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e69so3583691pgc.15
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 16:13:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h13si2855120plk.375.2017.12.06.16.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 16:13:48 -0800 (PST)
Date: Wed, 6 Dec 2017 16:13:45 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 00/73] XArray version 4
Message-ID: <20171207001345.GA8755@bombadil.infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206235829.GA28086@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206235829.GA28086@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 06, 2017 at 04:58:29PM -0700, Ross Zwisler wrote:
> Maybe I missed this from a previous version, but can you explain the
> motivation for replacing the radix tree with an xarray?  (I think this should
> probably still be part of the cover letter?)  Do we have a performance problem
> we need to solve?  A code complexity issue we need to solve?  Something else?

Sure!  Something else I screwed up in the v4 announcement ... I'll
need it again for v5, so here's a quick update of the v1 announcement's
justification:

I wrote the xarray to replace the radix tree with a better API based
on observing how programmers are currently using the radix tree, and
on how (and why) they aren't.  Conceptually, an xarray is an array of
ULONG_MAX pointers which is initially full of NULL pointers.

Improvements the xarray has over the radix tree:

 - The radix tree provides operations like other trees do; 'insert' and
   'delete'.  But what users really want is an automatically resizing
   array, and so it makes more sense to give users an API that is like
   an array -- 'load' and 'store'.
 - Locking is part of the API.  This simplifies a lot of users who
   formerly had to manage their own locking just for the radix tree.
   It also improves code generation as we can now tell RCU that we're
   holding a lock and it doesn't need to generate as much fencing code.
   The other advantage is that tree nodes can be moved (not yet
   implemented).
 - GFP flags are now parameters to calls which may need to allocate
   memory.  The radix tree forced users to decide what the allocation
   flags would be at creation time.  It's much clearer to specify them
   at allocation time.  I know the MM people disapprove of the radix
   tree using the top bits of the GFP flags for its own purpose, so
   they'll like this aspect.
 - Memory is not preloaded; we don't tie up dozens of pages on the
   off chance that the slab allocator fails.  Instead, we drop the lock,
   allocate a new node and retry the operation.
 - The xarray provides a conditional-replace operation.  The radix tree
   forces users to roll their own (and at least four have).
 - Iterators now take a 'max' parameter.  That simplifies many users and
   will reduce the amount of iteration done.
 - Iteration can proceed backwards.  We only have one user for this, but
   since it's called as part of the pagefault readahead algorithm, that
   seemed worth mentioning.
 - RCU-protected pointers are not exposed as part of the API.  There are
   some fun bugs where the page cache forgets to use rcu_dereference()
   in the current codebase.
 - Any function which wants it can now call the update_node() callback.
   There were a few places missing that I noticed as part of this rewrite.
 - Exceptional entries may now be BITS_PER_LONG-1 in size, rather than the
   BITS_PER_LONG-2 that they had in the radix tree.  That gives us the
   extra bit we need to put huge page swap entries in the page cache.

The API comes in two parts, normal and advanced.  The normal API takes
care of the locking and memory allocation for you.  You can get the
value of a pointer by calling xa_load() and set the value of a pointer by
calling xa_store().  You can conditionally update the value of a pointer
by calling xa_cmpxchg().  Each pointer which isn't NULL can be tagged
with up to 3 bits of extra information, accessed through xa_get_tag(),
xa_set_tag() and xa_clear_tag().  You can copy batches of pointers out
of the array by calling xa_get_entries() or xa_get_tagged().  You can
iterate over pointers in the array by calling xa_find(), xa_find_after()
or xa_for_each().

The advanced API allows users to build their own operations.  You have
to take care of your own locking and handle memory allocation failures.
Most of the advanced operations are based around the xa_state which
keeps state between sub-operations.  Read the xarray.h header file for
more information on the advanced API, and see the implementation of the
normal API for examples of how to use the advanced API.

Those familiar with the radix tree may notice certain similarities between
the implementation of the xarray and the radix tree.  That's entirely
intentional, but the implementation will certainly adapt in the future.
For example, one of the impediments I see to using xarrays instead of
kvmalloced arrays is memory consumption, so I have a couple of ideas to
reduce memory usage for smaller arrays.

I have reimplementated the IDR and the IDA based on the xarray.  They are
roughly the same complexity as they were when implemented on top of the
radix tree (although much less intertwined).

When converting code from the radix tree to the xarray, the biggest thing
to bear in mind is that 'store' overwrites anything which happens to be
in the xarray.  Just like the assignment operator.  The equivalent to
the insert operation is to replace NULL with the new value.

A quick reference guide to help when converting radix tree code.
Functions which start 'xas' are XA_ADVANCED functions.

INIT_RADIX_TREE				xa_init
radix_tree_empty			xa_empty
__radix_tree_create			xas_create
__radix_tree_insert			xas_store
radix_tree_insert(x)			xa_cmpxchg(NULL, x)
__radix_tree_lookup			xas_load
radix_tree_lookup			xa_load
radix_tree_lookup_slot			xas_load
__radix_tree_replace			xas_store
radix_tree_iter_replace			xas_store
radix_tree_replace_slot			xas_store
__radix_tree_delete_node		xas_store
radix_tree_delete_item			xa_cmpxhcg
radix_tree_delete			xa_erase
radix_tree_clear_tags			xas_init_tags
radix_tree_gang_lookup			xa_get_entries
radix_tree_gang_lookup_slot		xas_find (*1)
radix_tree_preload			(*3)
radix_tree_maybe_preload		(*3)
radix_tree_tag_set			xa_set_tag
radix_tree_tag_clear			xa_clear_tag
radix_tree_tag_get			xa_get_tag
radix_tree_iter_tag_set			xas_set_tag
radix_tree_gang_lookup_tag		xa_get_tagged
radix_tree_gang_lookup_tag_slot		xas_load (*2)
radix_tree_tagged			xa_tagged
radix_tree_preload_end			(*3)
radix_tree_split_preload		(*3)
radix_tree_split			xas_split (*4)
radix_tree_join				xas_store

(*1) All three users of radix_tree_gang_lookup_slot() are using it to
ensure that there are no entries in a given range.  
(*2) The one radix_tree_gang_lookup_tag_slot user should be using a
radix_tree_iter loop.  It can use an xas_for_each() loop, or even an
xa_for_each() loop.
(*3) I don't think we're going to need a preallocation API.  If we do
end up needing one, I have a plan that doesn't involve per-cpu
preallocation pools.
(*4) Not yet implemented

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
