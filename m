From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070423064901.5458.9828.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 03/16] Variable Order Page Cache: Add order field in mapping
Date: Sun, 22 Apr 2007 23:49:01 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, David Chinner <dgc@sgi.com>, Badari Pulavarty <pbadari@gmail.com>, Adam Litke <aglitke@gmail.com>, Christoph Lameter <clameter@sgi.com>, Avi Kivity <avi@argo.co.il>, Mel Gorman <mel@skynet.ie>, Dave Hansen <hansendc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Variable Order Page Cache: Add order field in mapping

Add an "order" field in the address space structure that
specifies the page order of pages in an address space.

Set the field to zero by default so that filesystems not prepared to
deal with higher pages can be left as is.

Putting page order in the address space structure means that the order of the
pages in the page cache can be varied per file that a filesystem creates.
This means we can keep small 4k pages for small files. Larger files can
be configured by the file system to use a higher order.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/inode.c         |    1 +
 include/linux/fs.h |    1 +
 2 files changed, 2 insertions(+)

Index: linux-2.6.21-rc7/fs/inode.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/inode.c	2007-04-18 21:21:56.000000000 -0700
+++ linux-2.6.21-rc7/fs/inode.c	2007-04-18 21:26:31.000000000 -0700
@@ -145,6 +145,7 @@ static struct inode *alloc_inode(struct 
 		mapping->a_ops = &empty_aops;
  		mapping->host = inode;
 		mapping->flags = 0;
+		mapping->order = 0;
 		mapping_set_gfp_mask(mapping, GFP_HIGHUSER);
 		mapping->assoc_mapping = NULL;
 		mapping->backing_dev_info = &default_backing_dev_info;
Index: linux-2.6.21-rc7/include/linux/fs.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/fs.h	2007-04-18 21:21:56.000000000 -0700
+++ linux-2.6.21-rc7/include/linux/fs.h	2007-04-18 21:26:31.000000000 -0700
@@ -435,6 +435,7 @@ struct address_space {
 	struct inode		*host;		/* owner: inode, block_device */
 	struct radix_tree_root	page_tree;	/* radix tree of all pages */
 	rwlock_t		tree_lock;	/* and rwlock protecting it */
+	unsigned int		order;		/* Page order in this space */
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
