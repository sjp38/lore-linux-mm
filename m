Date: Wed, 25 Apr 2007 12:05:54 +0100
Subject: Re: [RFC 03/16] Variable Order Page Cache: Add order field in mapping
Message-ID: <20070425110554.GC19942@skynet.ie>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com> <20070423064901.5458.9828.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070423064901.5458.9828.sendpatchset@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, David Chinner <dgc@sgi.com>, Badari Pulavarty <pbadari@gmail.com>, Adam Litke <aglitke@gmail.com>, Avi Kivity <avi@argo.co.il>, Dave Hansen <hansendc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On (22/04/07 23:49), Christoph Lameter didst pronounce:
> Variable Order Page Cache: Add order field in mapping
> 
> Add an "order" field in the address space structure that
> specifies the page order of pages in an address space.
> 
> Set the field to zero by default so that filesystems not prepared to
> deal with higher pages can be left as is.
> 
> Putting page order in the address space structure means that the order of the
> pages in the page cache can be varied per file that a filesystem creates.
> This means we can keep small 4k pages for small files. Larger files can
> be configured by the file system to use a higher order.


It may be desirable later to record when a filesystem does that so that bugs
related to compound-page-in-page-cache stand out a bit more.

> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  fs/inode.c         |    1 +
>  include/linux/fs.h |    1 +
>  2 files changed, 2 insertions(+)
> 
> Index: linux-2.6.21-rc7/fs/inode.c
> ===================================================================
> --- linux-2.6.21-rc7.orig/fs/inode.c	2007-04-18 21:21:56.000000000 -0700
> +++ linux-2.6.21-rc7/fs/inode.c	2007-04-18 21:26:31.000000000 -0700
> @@ -145,6 +145,7 @@ static struct inode *alloc_inode(struct 
>  		mapping->a_ops = &empty_aops;
>   		mapping->host = inode;
>  		mapping->flags = 0;
> +		mapping->order = 0;
>  		mapping_set_gfp_mask(mapping, GFP_HIGHUSER);

Just as a heads-up, grouping pages by mobility changes the
mapping_set_gfp_mask() flag so you may run into merge conflicts there. It
might make life easier if you set the order earlier so that it merges with
fuzz instead of going blamo. It's functionally identical.

>  		mapping->assoc_mapping = NULL;
>  		mapping->backing_dev_info = &default_backing_dev_info;
> Index: linux-2.6.21-rc7/include/linux/fs.h
> ===================================================================
> --- linux-2.6.21-rc7.orig/include/linux/fs.h	2007-04-18 21:21:56.000000000 -0700
> +++ linux-2.6.21-rc7/include/linux/fs.h	2007-04-18 21:26:31.000000000 -0700
> @@ -435,6 +435,7 @@ struct address_space {
>  	struct inode		*host;		/* owner: inode, block_device */
>  	struct radix_tree_root	page_tree;	/* radix tree of all pages */
>  	rwlock_t		tree_lock;	/* and rwlock protecting it */
> +	unsigned int		order;		/* Page order in this space */
>  	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
>  	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
>  	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
