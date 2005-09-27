Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8RM2gkc017552
	for <linux-mm@kvack.org>; Tue, 27 Sep 2005 18:02:42 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8RM4TO1519484
	for <linux-mm@kvack.org>; Tue, 27 Sep 2005 16:04:29 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8RM3pVv005069
	for <linux-mm@kvack.org>; Tue, 27 Sep 2005 16:03:52 -0600
Message-ID: <4339C1C6.8040202@austin.ibm.com>
Date: Tue, 27 Sep 2005 17:03:50 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 1/9] add defrag flags
References: <4338537E.8070603@austin.ibm.com>	<43385412.5080506@austin.ibm.com>	<21024267-29C3-4657-9C45-17D186EAD808@mac.com>	<1127780648.10315.12.camel@localhost>	<20050926224439.056eaf8d.pj@sgi.com>	<433991A0.7000803@austin.ibm.com>	<20050927123055.0ad9c2b4.pj@sgi.com>	<4339B2F6.1070806@austin.ibm.com> <20050927142355.232f6e95.pj@sgi.com>
In-Reply-To: <20050927142355.232f6e95.pj@sgi.com>
Content-Type: multipart/mixed;
 boundary="------------080203000001030806020802"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: haveblue@us.ibm.com, mrmacman_g4@mac.com, akpm@osdl.org, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kravetz@us.ibm.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080203000001030806020802
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

> Well, then, at least fix the comment, from the rather oddly phrased:
> 
> #define __GFP_USER	0x40000u /* User is a userspace user */
> 
> to something more accurate such as:
> 
> #define __GFP_USER	0x40000u /* User and other really easily reclaimed pages */

This was a cleverly designed trick to push me over the 80 column per line limit. 
   I've seen through your ruse and added:

#define __GFP_USER     0x40000u /* User & other really easily reclaimed pages */

> 
> And consider adding a comment to its use in fs/buffer.c, where marking
> a page obviously destined for kernel space __GFP_USER seems strange.
> I doubt I will be the last person to look at the line of code and
> scratch my head.

Done.  Patch with the two updated comments attached.

I think all hairs have been split and we can merge this one now.

--------------080203000001030806020802
Content-Type: text/plain;
 name="1_add_defrag_flags"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="1_add_defrag_flags"

Index: 2.6.13-joel2/fs/buffer.c
===================================================================
--- 2.6.13-joel2.orig/fs/buffer.c	2005-09-13 14:54:13.%N -0500
+++ 2.6.13-joel2/fs/buffer.c	2005-09-27 16:52:05.%N -0500
@@ -1119,7 +1119,12 @@ grow_dev_page(struct block_device *bdev,
 	struct page *page;
 	struct buffer_head *bh;
 
-	page = find_or_create_page(inode->i_mapping, index, GFP_NOFS);
+	/*
+	 * Mark as __GFP_USER because from a fragmentation avoidance and
+	 * reclimation point of view this memory behaves like user memory.
+	 */
+	page = find_or_create_page(inode->i_mapping, index,
+				   GFP_NOFS | __GFP_USER);
 	if (!page)
 		return NULL;
 
@@ -3044,7 +3049,8 @@ static void recalc_bh_state(void)
 	
 struct buffer_head *alloc_buffer_head(unsigned int __nocast gfp_flags)
 {
-	struct buffer_head *ret = kmem_cache_alloc(bh_cachep, gfp_flags);
+	struct buffer_head *ret = kmem_cache_alloc(bh_cachep,
+						   gfp_flags|__GFP_KERNRCLM);
 	if (ret) {
 		preempt_disable();
 		__get_cpu_var(bh_accounting).nr++;
Index: 2.6.13-joel2/fs/dcache.c
===================================================================
--- 2.6.13-joel2.orig/fs/dcache.c	2005-09-13 14:54:14.%N -0500
+++ 2.6.13-joel2/fs/dcache.c	2005-09-13 15:02:01.%N -0500
@@ -721,7 +721,7 @@ struct dentry *d_alloc(struct dentry * p
 	struct dentry *dentry;
 	char *dname;
 
-	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL); 
+	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL|__GFP_KERNRCLM);
 	if (!dentry)
 		return NULL;
 
Index: 2.6.13-joel2/fs/ext2/super.c
===================================================================
--- 2.6.13-joel2.orig/fs/ext2/super.c	2005-09-13 14:54:14.%N -0500
+++ 2.6.13-joel2/fs/ext2/super.c	2005-09-13 15:02:01.%N -0500
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
Index: 2.6.13-joel2/fs/ext3/super.c
===================================================================
--- 2.6.13-joel2.orig/fs/ext3/super.c	2005-09-13 14:54:14.%N -0500
+++ 2.6.13-joel2/fs/ext3/super.c	2005-09-13 15:02:01.%N -0500
@@ -440,7 +440,7 @@ static struct inode *ext3_alloc_inode(st
 {
 	struct ext3_inode_info *ei;
 
-	ei = kmem_cache_alloc(ext3_inode_cachep, SLAB_NOFS);
+	ei = kmem_cache_alloc(ext3_inode_cachep, SLAB_NOFS|__GFP_KERNRCLM);
 	if (!ei)
 		return NULL;
 #ifdef CONFIG_EXT3_FS_POSIX_ACL
Index: 2.6.13-joel2/fs/ntfs/inode.c
===================================================================
--- 2.6.13-joel2.orig/fs/ntfs/inode.c	2005-09-13 14:54:14.%N -0500
+++ 2.6.13-joel2/fs/ntfs/inode.c	2005-09-13 15:05:53.%N -0500
@@ -317,7 +317,7 @@ struct inode *ntfs_alloc_big_inode(struc
 	ntfs_inode *ni;
 
 	ntfs_debug("Entering.");
-	ni = kmem_cache_alloc(ntfs_big_inode_cache, SLAB_NOFS);
+	ni = kmem_cache_alloc(ntfs_big_inode_cache, SLAB_NOFS|__GFP_KERNRCLM);
 	if (likely(ni != NULL)) {
 		ni->state = 0;
 		return VFS_I(ni);
@@ -342,7 +342,7 @@ static inline ntfs_inode *ntfs_alloc_ext
 	ntfs_inode *ni;
 
 	ntfs_debug("Entering.");
-	ni = kmem_cache_alloc(ntfs_inode_cache, SLAB_NOFS);
+	ni = kmem_cache_alloc(ntfs_inode_cache, SLAB_NOFS|__GFP_KERNRCLM);
 	if (likely(ni != NULL)) {
 		ni->state = 0;
 		return ni;
Index: 2.6.13-joel2/include/linux/gfp.h
===================================================================
--- 2.6.13-joel2.orig/include/linux/gfp.h	2005-09-13 14:54:17.%N -0500
+++ 2.6.13-joel2/include/linux/gfp.h	2005-09-27 16:40:55.%N -0500
@@ -41,6 +41,16 @@ struct vm_area_struct;
 #define __GFP_NOMEMALLOC 0x10000u /* Don't use emergency reserves */
 #define __GFP_NORECLAIM  0x20000u /* No realy zone reclaim during allocation */
 
+/* Allocation type modifiers, these are required to be adjacent
+ * __GPF_USER: Allocation for user page or a buffer page
+ * __GFP_KERNRCLM: Short-lived or reclaimable kernel allocation
+ * Both bits off: Kernel non-reclaimable or very hard to reclaim
+ * RCLM_SHIFT (defined elsewhere) depends on the location of these bits
+ */
+#define __GFP_USER	0x40000u /* User & other really easily reclaimed pages */
+#define __GFP_KERNRCLM	0x80000u /* Kernel page that is easily reclaimable */
+#define __GFP_RCLM_BITS (__GFP_USER|__GFP_KERNRCLM)
+
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((1 << __GFP_BITS_SHIFT) - 1)
 
@@ -48,14 +58,15 @@ struct vm_area_struct;
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
-			__GFP_NOMEMALLOC|__GFP_NORECLAIM)
+			__GFP_NOMEMALLOC|__GFP_KERNRCLM|__GFP_USER)
 
 #define GFP_ATOMIC	(__GFP_HIGH)
 #define GFP_NOIO	(__GFP_WAIT)
 #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
-#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS)
-#define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HIGHMEM)
+#define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_USER)
+#define GFP_HIGHUSER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HIGHMEM | \
+			 __GFP_USER)
 
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */

--------------080203000001030806020802--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
