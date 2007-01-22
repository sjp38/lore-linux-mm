Date: Mon, 22 Jan 2007 12:31:10 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [PATCH 1/5] Add a map to to track dirty pages per node
Message-ID: <20070122013110.GN33919298@melbourne.sgi.com>
References: <20070120031007.17491.33355.sendpatchset@schroedinger.engr.sgi.com> <20070120031012.17491.72105.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070120031012.17491.72105.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Paul Menage <menage@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 19, 2007 at 07:10:12PM -0800, Christoph Lameter wrote:
> Index: linux-2.6.20-rc5/fs/fs-writeback.c
> ===================================================================
> --- linux-2.6.20-rc5.orig/fs/fs-writeback.c	2007-01-18 13:48:29.899625484 -0600
> +++ linux-2.6.20-rc5/fs/fs-writeback.c	2007-01-19 18:40:27.421969825 -0600
> @@ -22,6 +22,7 @@
>  #include <linux/blkdev.h>
>  #include <linux/backing-dev.h>
>  #include <linux/buffer_head.h>
> +#include <linux/cpuset.h>
>  #include "internal.h"
>  
>  /**
> @@ -349,6 +350,12 @@ sync_sb_inodes(struct super_block *sb, s
>  			continue;		/* blockdev has wrong queue */
>  		}
>  
> +		if (!cpuset_intersects_dirty_nodes(mapping, wbc->nodes)) {
> +			/* No pages on the nodes under writeback */
> +			list_move(&inode->i_list, &sb->s_dirty);
> +			continue;
> +		}

This breaks aging of dirty inodes, right? The s_dirty list a time
ordered list this will mean that the inode doesn't get written out
by a background sync for (potentially) another 30s. IOWs, we can
delay writeback of inodes on with data on other nodes by running
a single node out of memory. The normal background pdflush won't
help us either as it will see that there is an existing pdflush
working on the bdi and skip it....

> Index: linux-2.6.20-rc5/fs/inode.c
> ===================================================================
> --- linux-2.6.20-rc5.orig/fs/inode.c	2007-01-18 13:48:29.908415315 -0600
> +++ linux-2.6.20-rc5/fs/inode.c	2007-01-19 18:40:02.611062349 -0600
> @@ -22,6 +22,7 @@
>  #include <linux/bootmem.h>
>  #include <linux/inotify.h>
>  #include <linux/mount.h>
> +#include <linux/cpuset.h>
>  
>  /*
>   * This is needed for the following functions:
> @@ -148,6 +149,7 @@ static struct inode *alloc_inode(struct 
>  		mapping_set_gfp_mask(mapping, GFP_HIGHUSER);
>  		mapping->assoc_mapping = NULL;
>  		mapping->backing_dev_info = &default_backing_dev_info;
> +		cpuset_init_dirty_nodes(mapping);
>  
>  		/*
>  		 * If the block_device provides a backing_dev_info for client
> @@ -257,6 +259,7 @@ void clear_inode(struct inode *inode)
>  		bd_forget(inode);
>  	if (S_ISCHR(inode->i_mode) && inode->i_cdev)
>  		cd_forget(inode);
> +	cpuset_clear_dirty_nodes(inode->i_mapping);
>  	inode->i_state = I_CLEAR;
>  }

This is rather late to be clearing this, right? At the start of clear_inode()
we:

	BUG_ON(inode->i_data.nrpages);

Which tends to implicate that we should have already freed the dirty
map as there should be no pages (dirty or otherwise) attached to the
inode at this point. i.e. we should BUG here if we've still got
a dirty mask indicating dirty nodes on the inode because it should
be clear at this point.

> ===================================================================
> --- linux-2.6.20-rc5.orig/mm/page-writeback.c	2007-01-18 13:48:29.956271059 -0600
> +++ linux-2.6.20-rc5/mm/page-writeback.c	2007-01-19 19:45:08.755650133 -0600
> @@ -33,6 +33,7 @@
>  #include <linux/syscalls.h>
>  #include <linux/buffer_head.h>
>  #include <linux/pagevec.h>
> +#include <linux/cpuset.h>
>  
>  /*
>   * The maximum number of pages to writeout in a single bdflush/kupdate
> @@ -776,6 +777,7 @@ int __set_page_dirty_nobuffers(struct pa
>  			radix_tree_tag_set(&mapping->page_tree,
>  				page_index(page), PAGECACHE_TAG_DIRTY);
>  		}
> +		cpuset_update_dirty_nodes(mapping, page);

Shouldn't this be done in the same context of setting the
PAGECACHE_TAG_DIRTY? i.e. we set the node dirty at the same time
we set the page dirty tag.

>  		write_unlock_irq(&mapping->tree_lock);
>  		if (mapping->host) {
>  			/* !PageAnon && !swapper_space */
> @@ -940,10 +942,12 @@ int test_set_page_writeback(struct page 
>  			radix_tree_tag_set(&mapping->page_tree,
>  						page_index(page),
>  						PAGECACHE_TAG_WRITEBACK);
> -		if (!PageDirty(page))
> -			radix_tree_tag_clear(&mapping->page_tree,
> +		if (!PageDirty(page)) {
> +			if (radix_tree_tag_clear(&mapping->page_tree,
>  						page_index(page),
> -						PAGECACHE_TAG_DIRTY);
> +						PAGECACHE_TAG_DIRTY))
> +				cpuset_clear_dirty_nodes(mapping);
> +		}

Because you are clearing the dirty node state at the same time we clear
the PAGECACHE_TAG_DIRTY.

> +#if MAX_NUMNODES <= BITS_PER_LONG
> +#define cpuset_update_dirty_nodes(__mapping, __node) \
> +	if (!node_isset((__node, (__mapping)->dirty_nodes) \
> +		node_set((__node), (__mapping)->dirty_inodes)
> +
> +#define cpuset_clear_dirty_nodes(__mapping) \
> +		(__mapping)->dirty_nodes = NODE_MASK_NONE

Hmmm - the above is going to lose dirty state - you're calling
cpuset_clear_dirty_nodes() in the case that a page is now under
writeback. cpuset_clear_dirty_nodes() clears the _entire_ dirty node mask
but all you want to do above is remove the dirty state from the
node mask if that is the only page on the node that is dirty.

So we set the dirty node mask on a page by page basis, but we shoot
it down as soon as _any_ page transistions from dirty to writeback.
Hence if you've got dirty pages on other nodes (or other dirty pages
on this node) you have now lost track of them because cleaning a
single page clears all dirty node state on the inode. This seems
badly broken to me.

Because you are not tracking pages-per-node dirty state, the only way
you can really clear the dirty node state is when the inode is
completely clean. e.g. in __sync_single_inode where (inode->i_state
& I_DIRTY) == 0. Otherwise I can't see how this would work at all....

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
