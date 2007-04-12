Subject: [PATCH 2/2] mm: optimize kill_bdev()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Type: text/plain; charset=utf-8
Date: Thu, 12 Apr 2007 17:21:22 +0200
Message-Id: <1176391282.4114.10.camel@taijtu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Zhao Forrest <forrest.zhao@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Remove duplicate work in kill_bdev().

It currently invalidates and then truncates the bdev's mapping.
invalidate_mapping_pages() will opportunistically remove pages from the
mapping. And truncate_inode_pages() will forcefully remove all pages.

The only thing truncate doesn't do is flush the bh lrus. So do that explicitly.
This avoids (very unlikely) but possible invalid lookup results if the
same bdev is quickyl re-issued.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/block_dev.c              |    2 +-
 fs/buffer.c                 |    3 +--
 include/linux/buffer_head.h |    1 +
 3 files changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6/fs/block_dev.c
===================================================================
--- linux-2.6.orig/fs/block_dev.c	2007-04-12 16:01:13.000000000 +0200
+++ linux-2.6/fs/block_dev.c	2007-04-12 16:20:14.000000000 +0200
@@ -61,7 +61,7 @@ static sector_t max_block(struct block_d
 /* Kill _all_ buffers, dirty or not.. */
 static void kill_bdev(struct block_device *bdev)
 {
-	invalidate_bdev(bdev);
+	invalidate_bh_lrus();
 	truncate_inode_pages(bdev->bd_inode->i_mapping, 0);
 }	
 
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2007-04-12 15:26:37.000000000 +0200
+++ linux-2.6/fs/buffer.c	2007-04-12 16:19:50.000000000 +0200
@@ -43,7 +43,6 @@
 #include <linux/bit_spinlock.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
-static void invalidate_bh_lrus(void);
 
 #define BH_ENTRY(list) list_entry((list), struct buffer_head, b_assoc_buffers)
 
@@ -1412,7 +1411,7 @@ static void invalidate_bh_lru(void *arg)
 	put_cpu_var(bh_lrus);
 }
 	
-static void invalidate_bh_lrus(void)
+void invalidate_bh_lrus(void)
 {
 	on_each_cpu(invalidate_bh_lru, NULL, 1, 1);
 }
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h	2007-04-12 15:25:39.000000000 +0200
+++ linux-2.6/include/linux/buffer_head.h	2007-04-12 16:05:43.000000000 +0200
@@ -182,6 +182,7 @@ void __brelse(struct buffer_head *);
 void __bforget(struct buffer_head *);
 void __breadahead(struct block_device *, sector_t block, unsigned int size);
 struct buffer_head *__bread(struct block_device *, sector_t block, unsigned size);
+void invalidate_bh_lrus(void);
 struct buffer_head *alloc_buffer_head(gfp_t gfp_flags);
 void free_buffer_head(struct buffer_head * bh);
 void FASTCALL(unlock_buffer(struct buffer_head *bh));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
