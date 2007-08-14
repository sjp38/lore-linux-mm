Message-Id: <20070814153502.239881998@sgi.com>
References: <20070814153021.446917377@sgi.com>
Date: Tue, 14 Aug 2007 08:30:27 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 6/9] Disable irqs on taking the private_lock
Content-Disposition: inline; filename=vmscan_private_lock_irqsave
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

It is necessary to take the private_lock in the reclaim path to
be able to unmap pages. For atomic reclaim we must consistently
disable interrupts.

There is still a FIXME in sync_mapping_buffers(). The private_lock
is passed there as a parameter and the function does not do
the requres disabling of irqs and saving of flags.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/buffer.c |   50 ++++++++++++++++++++++++++++++++------------------
 1 file changed, 32 insertions(+), 18 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2007-08-13 22:43:03.000000000 -0700
+++ linux-2.6/fs/buffer.c	2007-08-14 07:39:22.000000000 -0700
@@ -256,13 +256,14 @@ __find_get_block_slow(struct block_devic
 	struct buffer_head *head;
 	struct page *page;
 	int all_mapped = 1;
+	unsigned long flags;
 
 	index = block >> (PAGE_CACHE_SHIFT - bd_inode->i_blkbits);
 	page = find_get_page(bd_mapping, index);
 	if (!page)
 		goto out;
 
-	spin_lock(&bd_mapping->private_lock);
+	spin_lock_irqsave(&bd_mapping->private_lock, flags);
 	if (!page_has_buffers(page))
 		goto out_unlock;
 	head = page_buffers(page);
@@ -293,7 +294,7 @@ __find_get_block_slow(struct block_devic
 		printk("device blocksize: %d\n", 1 << bd_inode->i_blkbits);
 	}
 out_unlock:
-	spin_unlock(&bd_mapping->private_lock);
+	spin_unlock_irqrestore(&bd_mapping->private_lock, flags);
 	page_cache_release(page);
 out:
 	return ret;
@@ -632,6 +633,11 @@ int sync_mapping_buffers(struct address_
 	if (buffer_mapping == NULL || list_empty(&mapping->private_list))
 		return 0;
 
+	/*
+	 * FIXME: Ugly situation for ATOMIC reclaim. The private_lock
+	 * requires spin_lock_irqsave but we only do a spin_lock in
+	 * fsync_buffers_list!
+	 */
 	return fsync_buffers_list(&buffer_mapping->private_lock,
 					&mapping->private_list);
 }
@@ -658,6 +664,7 @@ void mark_buffer_dirty_inode(struct buff
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct address_space *buffer_mapping = bh->b_page->mapping;
+	unsigned long flags;
 
 	mark_buffer_dirty(bh);
 	if (!mapping->assoc_mapping) {
@@ -666,11 +673,11 @@ void mark_buffer_dirty_inode(struct buff
 		BUG_ON(mapping->assoc_mapping != buffer_mapping);
 	}
 	if (list_empty(&bh->b_assoc_buffers)) {
-		spin_lock(&buffer_mapping->private_lock);
+		spin_lock_irqsave(&buffer_mapping->private_lock, flags);
 		list_move_tail(&bh->b_assoc_buffers,
 				&mapping->private_list);
 		bh->b_assoc_map = mapping;
-		spin_unlock(&buffer_mapping->private_lock);
+		spin_unlock_irqrestore(&buffer_mapping->private_lock, flags);
 	}
 }
 EXPORT_SYMBOL(mark_buffer_dirty_inode);
@@ -736,11 +743,12 @@ static int __set_page_dirty(struct page 
 int __set_page_dirty_buffers(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
+	unsigned long flags;
 
 	if (unlikely(!mapping))
 		return !TestSetPageDirty(page);
 
-	spin_lock(&mapping->private_lock);
+	spin_lock_irqsave(&mapping->private_lock, flags);
 	if (page_has_buffers(page)) {
 		struct buffer_head *head = page_buffers(page);
 		struct buffer_head *bh = head;
@@ -750,7 +758,7 @@ int __set_page_dirty_buffers(struct page
 			bh = bh->b_this_page;
 		} while (bh != head);
 	}
-	spin_unlock(&mapping->private_lock);
+	spin_unlock_irqrestore(&mapping->private_lock, flags);
 
 	return __set_page_dirty(page, mapping, 1);
 }
@@ -840,11 +848,12 @@ void invalidate_inode_buffers(struct ino
 		struct address_space *mapping = &inode->i_data;
 		struct list_head *list = &mapping->private_list;
 		struct address_space *buffer_mapping = mapping->assoc_mapping;
+		unsigned long flags;
 
-		spin_lock(&buffer_mapping->private_lock);
+		spin_lock_irqsave(&buffer_mapping->private_lock, flags);
 		while (!list_empty(list))
 			__remove_assoc_queue(BH_ENTRY(list->next));
-		spin_unlock(&buffer_mapping->private_lock);
+		spin_unlock_irqrestore(&buffer_mapping->private_lock, flags);
 	}
 }
 
@@ -862,8 +871,9 @@ int remove_inode_buffers(struct inode *i
 		struct address_space *mapping = &inode->i_data;
 		struct list_head *list = &mapping->private_list;
 		struct address_space *buffer_mapping = mapping->assoc_mapping;
+		unsigned long flags;
 
-		spin_lock(&buffer_mapping->private_lock);
+		spin_lock_irqsave(&buffer_mapping->private_lock, flags);
 		while (!list_empty(list)) {
 			struct buffer_head *bh = BH_ENTRY(list->next);
 			if (buffer_dirty(bh)) {
@@ -872,7 +882,7 @@ int remove_inode_buffers(struct inode *i
 			}
 			__remove_assoc_queue(bh);
 		}
-		spin_unlock(&buffer_mapping->private_lock);
+		spin_unlock_irqrestore(&buffer_mapping->private_lock, flags);
 	}
 	return ret;
 }
@@ -999,6 +1009,7 @@ grow_dev_page(struct block_device *bdev,
 	struct inode *inode = bdev->bd_inode;
 	struct page *page;
 	struct buffer_head *bh;
+	unsigned long flags;
 
 	page = find_or_create_page(inode->i_mapping, index,
 		(mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS)|__GFP_MOVABLE);
@@ -1029,10 +1040,10 @@ grow_dev_page(struct block_device *bdev,
 	 * lock to be atomic wrt __find_get_block(), which does not
 	 * run under the page lock.
 	 */
-	spin_lock(&inode->i_mapping->private_lock);
+	spin_lock_irqsave(&inode->i_mapping->private_lock, flags);
 	link_dev_buffers(page, bh);
 	init_page_buffers(page, bdev, block, size);
-	spin_unlock(&inode->i_mapping->private_lock);
+	spin_unlock_irqrestore(&inode->i_mapping->private_lock, flags);
 	return page;
 
 failed:
@@ -1182,11 +1193,12 @@ void __bforget(struct buffer_head *bh)
 	clear_buffer_dirty(bh);
 	if (!list_empty(&bh->b_assoc_buffers)) {
 		struct address_space *buffer_mapping = bh->b_page->mapping;
+		unsigned long flags;
 
-		spin_lock(&buffer_mapping->private_lock);
+		spin_lock_irqsave(&buffer_mapping->private_lock, flags);
 		list_del_init(&bh->b_assoc_buffers);
 		bh->b_assoc_map = NULL;
-		spin_unlock(&buffer_mapping->private_lock);
+		spin_unlock_irqrestore(&buffer_mapping->private_lock, flags);
 	}
 	__brelse(bh);
 }
@@ -1513,6 +1525,7 @@ void create_empty_buffers(struct page *p
 			unsigned long blocksize, unsigned long b_state)
 {
 	struct buffer_head *bh, *head, *tail;
+	unsigned long flags;
 
 	head = alloc_page_buffers(page, blocksize, 1);
 	bh = head;
@@ -1523,7 +1536,7 @@ void create_empty_buffers(struct page *p
 	} while (bh);
 	tail->b_this_page = head;
 
-	spin_lock(&page->mapping->private_lock);
+	spin_lock_irqsave(&page->mapping->private_lock, flags);
 	if (PageUptodate(page) || PageDirty(page)) {
 		bh = head;
 		do {
@@ -1535,7 +1548,7 @@ void create_empty_buffers(struct page *p
 		} while (bh != head);
 	}
 	attach_page_buffers(page, head);
-	spin_unlock(&page->mapping->private_lock);
+	spin_unlock_irqrestore(&page->mapping->private_lock, flags);
 }
 EXPORT_SYMBOL(create_empty_buffers);
 
@@ -2844,6 +2857,7 @@ int try_to_free_buffers(struct page *pag
 	struct address_space * const mapping = page->mapping;
 	struct buffer_head *buffers_to_free = NULL;
 	int ret = 0;
+	unsigned long flags;
 
 	BUG_ON(!PageLocked(page));
 	if (PageWriteback(page))
@@ -2854,7 +2868,7 @@ int try_to_free_buffers(struct page *pag
 		goto out;
 	}
 
-	spin_lock(&mapping->private_lock);
+	spin_lock_irqsave(&mapping->private_lock, flags);
 	ret = drop_buffers(page, &buffers_to_free);
 
 	/*
@@ -2873,7 +2887,7 @@ int try_to_free_buffers(struct page *pag
 	 */
 	if (ret)
 		cancel_dirty_page(page, PAGE_CACHE_SIZE);
-	spin_unlock(&mapping->private_lock);
+	spin_unlock_irqrestore(&mapping->private_lock, flags);
 out:
 	if (buffers_to_free) {
 		struct buffer_head *bh = buffers_to_free;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
