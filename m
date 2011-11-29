Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0058E6B004D
	for <linux-mm@kvack.org>; Tue, 29 Nov 2011 08:26:15 -0500 (EST)
Message-Id: <20111129131456.535182080@intel.com>
Date: Tue, 29 Nov 2011 21:09:05 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 5/9] readahead: tag metadata call sites
References: <20111129130900.628549879@intel.com>
Content-Disposition: inline; filename=readahead-for-metadata
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

We may be doing more metadata readahead in future.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/ext3/dir.c      |    1 +
 fs/ext4/dir.c      |    1 +
 include/linux/fs.h |    1 +
 mm/readahead.c     |    1 +
 4 files changed, 4 insertions(+)

--- linux-next.orig/fs/ext3/dir.c	2011-11-29 09:48:49.000000000 +0800
+++ linux-next/fs/ext3/dir.c	2011-11-29 10:13:13.000000000 +0800
@@ -136,6 +136,7 @@ static int ext3_readdir(struct file * fi
 			pgoff_t index = map_bh.b_blocknr >>
 					(PAGE_CACHE_SHIFT - inode->i_blkbits);
 			if (!ra_has_index(&filp->f_ra, index))
+				filp->f_ra.for_metadata = 1;
 				page_cache_sync_readahead(
 					sb->s_bdev->bd_inode->i_mapping,
 					&filp->f_ra, filp,
--- linux-next.orig/fs/ext4/dir.c	2011-11-29 09:48:49.000000000 +0800
+++ linux-next/fs/ext4/dir.c	2011-11-29 10:13:13.000000000 +0800
@@ -153,6 +153,7 @@ static int ext4_readdir(struct file *fil
 			pgoff_t index = map.m_pblk >>
 					(PAGE_CACHE_SHIFT - inode->i_blkbits);
 			if (!ra_has_index(&filp->f_ra, index))
+				filp->f_ra.for_metadata = 1;
 				page_cache_sync_readahead(
 					sb->s_bdev->bd_inode->i_mapping,
 					&filp->f_ra, filp,
--- linux-next.orig/include/linux/fs.h	2011-11-29 10:13:08.000000000 +0800
+++ linux-next/include/linux/fs.h	2011-11-29 10:13:13.000000000 +0800
@@ -948,6 +948,7 @@ struct file_ra_state {
 	u16 mmap_miss;			/* Cache miss stat for mmap accesses */
 	u8 pattern;			/* one of RA_PATTERN_* */
 	unsigned int for_mmap:1;	/* readahead for mmap accesses */
+	unsigned int for_metadata:1;	/* readahead for meta data */
 
 	loff_t prev_pos;		/* Cache last read() position */
 };
--- linux-next.orig/mm/readahead.c	2011-11-29 10:13:08.000000000 +0800
+++ linux-next/mm/readahead.c	2011-11-29 10:13:13.000000000 +0800
@@ -268,6 +268,7 @@ unsigned long ra_submit(struct file_ra_s
 					ra->start, ra->size, ra->async_size);
 
 	ra->for_mmap = 0;
+	ra->for_metadata = 0;
 	return actual;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
