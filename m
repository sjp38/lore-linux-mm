Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6BHaHeL216420
	for <linux-mm@kvack.org>; Mon, 11 Jul 2005 13:36:17 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j6BHaHio394696
	for <linux-mm@kvack.org>; Mon, 11 Jul 2005 11:36:17 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6BHaGoi013053
	for <linux-mm@kvack.org>; Mon, 11 Jul 2005 11:36:16 -0600
Message-ID: <42D2AE0F.8020809@austin.ibm.com>
Date: Mon, 11 Jul 2005 12:36:15 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Fwd: [PATCH 2/4] cpusets new __GFP_HARDWALL flag]
References: <1121101013.15095.19.camel@localhost>
In-Reply-To: <1121101013.15095.19.camel@localhost>
Content-Type: multipart/mixed;
 boundary="------------040303020509030602090006"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040303020509030602090006
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Dave Hansen brought this to my attention.  I've attached the bit of the 
memory fragmentation avoidance you conflict with (I'm working with Mel 
on his patches).  I think we share similar goals, and I wouldn't mind 
changing __GFP_USERRCLM to __GFP_USERALLOC or some neutral name we could 
share.  Anything to increase the chances of fragmentation avoidance 
getting merged is good in my book.

-Joel


>>GFP_USER allocations, and distinguish them from GFP_KERNEL allocations.
>>
>>Allocations (such as GFP_USER) marked GFP_HARDWALL are constrainted to
>>the current tasks cpuset.  Other allocations (such as GFP_KERNEL) can
>>steal from the possibly larger nearest mem_exclusive cpuset ancestor,
>>if memory is tight on every node in the current cpuset.
>>
>>This patch collides with Mel Gorman's patch to reduce fragmentation
>>in the standard buddy allocator, which adds two GFP flags.  At first
>>glance, it seems that his added __GFP_USERRCLM flag could be used in
>>place of the following __GFP_HARDWALL, as they both seem to be set
>>the same way - for GFP_USER and GFP_HIGHUSER.  Perhaps we should call
>>this flag __GFP_USER, rather than some name dependent on its use(s).
> 
> 
> Does this make sense to integrate into your patches?
> 
> Index: linux-2.6-mem_exclusive/include/linux/gfp.h
> ===================================================================
> --- linux-2.6-mem_exclusive.orig/include/linux/gfp.h	2005-07-02 17:42:02.000000000 -0700
> +++ linux-2.6-mem_exclusive/include/linux/gfp.h	2005-07-02 17:43:00.000000000 -0700
> @@ -40,6 +40,7 @@ struct vm_area_struct;
>  #define __GFP_ZERO	0x8000u	/* Return zeroed page on success */
>  #define __GFP_NOMEMALLOC 0x10000u /* Don't use emergency reserves */
>  #define __GFP_NORECLAIM  0x20000u /* No zone reclaim during page_cache_alloc */
> +#define __GFP_HARDWALL   0x40000u /* Enforce hardwall cpuset memory allocs */
>  
>  #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
>  #define __GFP_BITS_MASK ((1 << __GFP_BITS_SHIFT) - 1)
> @@ -48,14 +49,15 @@ struct vm_area_struct;
>  #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
>  			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
>  			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
> -			__GFP_NOMEMALLOC|__GFP_NORECLAIM)
> +			__GFP_NOMEMALLOC|__GFP_NORECLAIM|__GFP_HARDWALL)
>  
>  #define GFP_ATOMIC	(__GFP_HIGH)
>  #define GFP_NOIO	(__GFP_WAIT)
>  #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
>  #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
> -#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS)
> -#define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HIGHMEM)
> +#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
> +#define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL | \
> +			 __GFP_HIGHMEM)
>  
>  /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
>     platforms, used as appropriate on others */


--------------040303020509030602090006
Content-Type: text/plain;
 name="patch-defrag-flags"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-defrag-flags"

Index: 2.6.13-rc1-mhp1/fs/buffer.c
===================================================================
--- 2.6.13-rc1-mhp1.orig/fs/buffer.c	2005-06-29 15:11:40.%N -0500
+++ 2.6.13-rc1-mhp1/fs/buffer.c	2005-07-06 12:30:55.%N -0500
@@ -1110,7 +1110,8 @@ grow_dev_page(struct block_device *bdev,
 	struct page *page;
 	struct buffer_head *bh;
 
-	page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
+	page = find_or_create_page(inode->i_mapping, index,
+				   GFP_NOFS | __GFP_USERRCLM);
 	if (!page)
 		return NULL;
 
@@ -3079,7 +3080,8 @@ static void recalc_bh_state(void)
 	
 struct buffer_head *alloc_buffer_head(unsigned int __nocast gfp_flags)
 {
-	struct buffer_head *ret = kmem_cache_alloc(bh_cachep, gfp_flags);
+	struct buffer_head *ret = kmem_cache_alloc(bh_cachep,
+						   gfp_flags|__GFP_KERNRCLM);
 	if (ret) {
 		preempt_disable();
 		__get_cpu_var(bh_accounting).nr++;
Index: 2.6.13-rc1-mhp1/fs/dcache.c
===================================================================
--- 2.6.13-rc1-mhp1.orig/fs/dcache.c	2005-06-29 15:11:18.%N -0500
+++ 2.6.13-rc1-mhp1/fs/dcache.c	2005-07-06 12:32:00.%N -0500
@@ -719,7 +719,7 @@ struct dentry *d_alloc(struct dentry * p
 	struct dentry *dentry;
 	char *dname;
 
-	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL); 
+	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL|__GFP_KERNRCLM);
 	if (!dentry)
 		return NULL;
 
Index: 2.6.13-rc1-mhp1/fs/ext2/super.c
===================================================================
--- 2.6.13-rc1-mhp1.orig/fs/ext2/super.c	2005-06-29 15:11:18.%N -0500
+++ 2.6.13-rc1-mhp1/fs/ext2/super.c	2005-07-06 12:34:16.%N -0500
@@ -138,7 +138,8 @@ static kmem_cache_t * ext2_inode_cachep;
 static struct inode *ext2_alloc_inode(struct super_block *sb)
 {
 	struct ext2_inode_info *ei;
-	ei = (struct ext2_inode_info *)kmem_cache_alloc(ext2_inode_cachep, SLAB_KERNEL);
+	ei = (struct ext2_inode_info *)kmem_cache_alloc(ext2_inode_cachep,
+						SLAB_KERNEL|__GFP_KERNRCLM);
 	if (!ei)
 		return NULL;
 #ifdef CONFIG_EXT2_FS_POSIX_ACL
Index: 2.6.13-rc1-mhp1/fs/ext3/super.c
===================================================================
--- 2.6.13-rc1-mhp1.orig/fs/ext3/super.c	2005-06-29 15:11:18.%N -0500
+++ 2.6.13-rc1-mhp1/fs/ext3/super.c	2005-06-29 16:02:25.%N -0500
@@ -440,7 +440,7 @@ static struct inode *ext3_alloc_inode(st
 {
 	struct ext3_inode_info *ei;
 
-	ei = kmem_cache_alloc(ext3_inode_cachep, SLAB_NOFS);
+	ei = kmem_cache_alloc(ext3_inode_cachep, SLAB_NOFS|__GFP_KERNRCLM);
 	if (!ei)
 		return NULL;
 #ifdef CONFIG_EXT3_FS_POSIX_ACL
Index: 2.6.13-rc1-mhp1/fs/ntfs/inode.c
===================================================================
--- 2.6.13-rc1-mhp1.orig/fs/ntfs/inode.c	2005-06-29 15:11:18.%N -0500
+++ 2.6.13-rc1-mhp1/fs/ntfs/inode.c	2005-07-06 13:10:49.%N -0500
@@ -317,8 +317,8 @@ struct inode *ntfs_alloc_big_inode(struc
 	ntfs_inode *ni;
 
 	ntfs_debug("Entering.");
-	ni = (ntfs_inode *)kmem_cache_alloc(ntfs_big_inode_cache,
-			SLAB_NOFS);
+	ni = (ntfs_inode *)kmem_cache_alloc(ntfs_big_inode_cache,
+					    SLAB_NOFS|__GFP_KERNRCLM);
 	if (likely(ni != NULL)) {
 		ni->state = 0;
 		return VFS_I(ni);
@@ -343,7 +343,8 @@ static inline ntfs_inode *ntfs_alloc_ext
 	ntfs_inode *ni;
 
 	ntfs_debug("Entering.");
-	ni = (ntfs_inode *)kmem_cache_alloc(ntfs_inode_cache, SLAB_NOFS);
+	ni = (ntfs_inode *)kmem_cache_alloc(ntfs_inode_cache,
+					    SLAB_NOFS|__GFP_KERNRCLM);
 	if (likely(ni != NULL)) {
 		ni->state = 0;
 		return ni;
Index: 2.6.13-rc1-mhp1/include/linux/gfp.h
===================================================================
--- 2.6.13-rc1-mhp1.orig/include/linux/gfp.h	2005-06-29 15:11:35.%N -0500
+++ 2.6.13-rc1-mhp1/include/linux/gfp.h	2005-07-06 12:39:56.%N -0500
@@ -40,22 +40,26 @@ struct vm_area_struct;
 #define __GFP_ZERO	0x8000u	/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC 0x10000u /* Don't use emergency reserves */
 #define __GFP_NORECLAIM  0x20000u /* No realy zone reclaim during allocation */
+#define __GFP_KERNRCLM 0x40000u /* Kernel page that is easily reclaimable */
+#define __GFP_USERRCLM 0x80000u /* User is a userspace user */
 
-#define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 22	/* Room for 22 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((1 << __GFP_BITS_SHIFT) - 1)
 
 /* if you forget to add the bitmask here kernel will crash, period */
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
-			__GFP_NOMEMALLOC|__GFP_NORECLAIM)
+			__GFP_NOMEMALLOC|__GFP_NORECLAIM| \
+			__GFP_USERRCLM|__GFP_KERNRCLM)
 
 #define GFP_ATOMIC	(__GFP_HIGH)
 #define GFP_NOIO	(__GFP_WAIT)
 #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
-#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS)
-#define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HIGHMEM)
+#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_USERRCLM)
+#define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HIGHMEM | \
+			 __GFP_USERRCLM)
 
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */

--------------040303020509030602090006--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
