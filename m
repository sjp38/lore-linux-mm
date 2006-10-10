Date: Tue, 10 Oct 2006 09:21:29 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-ID: <20061010072129.GB14557@wotan.suse.de>
References: <20061009220127.c4721d2d.akpm@osdl.org> <20061010052248.GB24600@wotan.suse.de> <20061009222905.ddd270a6.akpm@osdl.org> <20061010054832.GC24600@wotan.suse.de> <20061009230832.7245814e.akpm@osdl.org> <20061010061958.GA25500@wotan.suse.de> <20061009232714.b52f678d.akpm@osdl.org> <20061010063900.GB25500@wotan.suse.de> <20061010065217.GC25500@wotan.suse.de> <20061010000652.bed6f901.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061010000652.bed6f901.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 10, 2006 at 12:06:52AM -0700, Andrew Morton wrote:
> On Tue, 10 Oct 2006 08:52:17 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > On Tue, Oct 10, 2006 at 08:39:00AM +0200, Nick Piggin wrote:
> > > As far as set_page_dirty races goes, I am having a bit of a look at that,
> > > but it would still require filesystems people to have a look.
> > 
> > I'm thinking something along the lines of this (untested) patch.
> 
> ho hum.
> 
> >  void block_invalidatepage(struct page *page, unsigned long offset)
> >  {
> > -	struct address_space *mapping;
> > +	struct address_space *mapping = page->mapping;
> >  	struct buffer_head *head, *bh, *next;
> > -	unsigned int curr_off = 0;
> > +	unsigned int curr_off;
> >  
> >  	BUG_ON(!PageLocked(page));
> > -	spin_lock(&mapping->private_lock);
> 
> block_invalidatepage() doesn't take ->private_lock.

Err, sorry, quilt leakage. This one should be better.
--

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -701,10 +701,11 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
  */
 int __set_page_dirty_buffers(struct page *page)
 {
+	int ret;
 	struct address_space * const mapping = page_mapping(page);
 
 	if (unlikely(!mapping))
-		return !TestSetPageDirty(page);
+		return 0;
 
 	spin_lock(&mapping->private_lock);
 	if (page_has_buffers(page)) {
@@ -712,26 +713,26 @@ int __set_page_dirty_buffers(struct page
 		struct buffer_head *bh = head;
 
 		do {
-			set_buffer_dirty(bh);
+			if (!buffer_invalid(bh))
+				set_buffer_dirty(bh);
 			bh = bh->b_this_page;
 		} while (bh != head);
 	}
 	spin_unlock(&mapping->private_lock);
 
-	if (!TestSetPageDirty(page)) {
-		write_lock_irq(&mapping->tree_lock);
-		if (page->mapping) {	/* Race with truncate? */
-			if (mapping_cap_account_dirty(mapping))
-				__inc_zone_page_state(page, NR_FILE_DIRTY);
-			radix_tree_tag_set(&mapping->page_tree,
-						page_index(page),
-						PAGECACHE_TAG_DIRTY);
-		}
-		write_unlock_irq(&mapping->tree_lock);
-		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
-		return 1;
+	ret = 0;
+	write_lock_irq(&mapping->tree_lock);
+	if (page->mapping) {	/* Race with truncate? */
+		if (mapping_cap_account_dirty(mapping))
+			__inc_zone_page_state(page, NR_FILE_DIRTY);
+		radix_tree_tag_set(&mapping->page_tree,
+					page_index(page), PAGECACHE_TAG_DIRTY);
+		ret = !TestSetPageDirty(page);
 	}
-	return 0;
+	write_unlock_irq(&mapping->tree_lock);
+	if (ret)
+		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+	return ret;
 }
 EXPORT_SYMBOL(__set_page_dirty_buffers);
 
@@ -1407,7 +1408,6 @@ EXPORT_SYMBOL(set_bh_page);
 static void discard_buffer(struct buffer_head * bh)
 {
 	lock_buffer(bh);
-	clear_buffer_dirty(bh);
 	bh->b_bdev = NULL;
 	clear_buffer_mapped(bh);
 	clear_buffer_req(bh);
@@ -1433,13 +1433,15 @@ static void discard_buffer(struct buffer
  */
 void block_invalidatepage(struct page *page, unsigned long offset)
 {
+ 	struct address_space *mapping = page->mapping;
 	struct buffer_head *head, *bh, *next;
-	unsigned int curr_off = 0;
+	unsigned int curr_off;
 
 	BUG_ON(!PageLocked(page));
 	if (!page_has_buffers(page))
 		goto out;
 
+	curr_off = 0;
 	head = page_buffers(page);
 	bh = head;
 	do {
@@ -1455,6 +1457,24 @@ void block_invalidatepage(struct page *p
 		bh = next;
 	} while (bh != head);
 
+	/* strip the dirty bits and protect against concurrent set_page_dirty */
+	spin_lock(&mapping->private_lock);
+	curr_off = 0;
+	head = page_buffers(page);
+	bh = head;
+	do {
+		unsigned int next_off = curr_off + bh->b_size;
+		next = bh->b_this_page;
+
+		if (offset <= curr_off) {
+			clear_buffer_dirty(bh);
+			set_buffer_invalid(bh);
+		}
+		curr_off = next_off;
+		bh = next;
+	} while (bh != head);
+	spin_unlock(&mapping->private_lock);
+
 	/*
 	 * We release buffers only if the entire page is being invalidated.
 	 * The get_block cached value has been unconditionally invalidated,
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h
+++ linux-2.6/include/linux/buffer_head.h
@@ -18,6 +18,7 @@
 
 enum bh_state_bits {
 	BH_Uptodate,	/* Contains valid data */
+	BH_Invalid,	/* Has been truncated/invalidated */
 	BH_Dirty,	/* Is dirty */
 	BH_Lock,	/* Is locked */
 	BH_Req,		/* Has been submitted for I/O */
@@ -109,6 +110,7 @@ static inline int test_clear_buffer_##na
  * do something in addition to setting a b_state bit.
  */
 BUFFER_FNS(Uptodate, uptodate)
+BUFFER_FNS(Invalid, invalid)
 BUFFER_FNS(Dirty, dirty)
 TAS_BUFFER_FNS(Dirty, dirty)
 BUFFER_FNS(Lock, locked)
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -757,30 +757,36 @@ EXPORT_SYMBOL(write_one_page);
  */
 int __set_page_dirty_nobuffers(struct page *page)
 {
-	if (!TestSetPageDirty(page)) {
-		struct address_space *mapping = page_mapping(page);
+	struct address_space *mapping;
+
+	if (PageDirty(page))
+		return 0;
+
+	mapping = page_mapping(page);
+	if (mapping) { /* Race with truncate? */
+		int ret;
 		struct address_space *mapping2;
 
-		if (mapping) {
-			write_lock_irq(&mapping->tree_lock);
-			mapping2 = page_mapping(page);
-			if (mapping2) { /* Race with truncate? */
-				BUG_ON(mapping2 != mapping);
-				if (mapping_cap_account_dirty(mapping))
-					__inc_zone_page_state(page,
-								NR_FILE_DIRTY);
-				radix_tree_tag_set(&mapping->page_tree,
+		ret = 0;
+		write_lock_irq(&mapping->tree_lock);
+		mapping2 = page_mapping(page);
+		if (mapping2 && !TestSetPageDirty(page)) {
+			BUG_ON(mapping2 != mapping);
+			if (mapping_cap_account_dirty(mapping))
+				__inc_zone_page_state(page, NR_FILE_DIRTY);
+			radix_tree_tag_set(&mapping->page_tree,
 					page_index(page), PAGECACHE_TAG_DIRTY);
-			}
-			write_unlock_irq(&mapping->tree_lock);
-			if (mapping->host) {
-				/* !PageAnon && !swapper_space */
-				__mark_inode_dirty(mapping->host,
-							I_DIRTY_PAGES);
-			}
+			ret = 1;
 		}
-		return 1;
+		write_unlock_irq(&mapping->tree_lock);
+		if (ret) {
+			/* !PageAnon && !swapper_space */
+			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+		}
+		return ret;
 	}
+
+	/* Don't bother dirtying truncated pages */
 	return 0;
 }
 EXPORT_SYMBOL(__set_page_dirty_nobuffers);
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -341,6 +341,14 @@ static pageout_t pageout(struct page *pa
 				return PAGE_CLEAN;
 			}
 		}
+		/*
+		 * Truncate/invalidate clears dirty, and it shouldn't get dirty
+		 * again (unless SetPageDirty is used instead of set_page_dirty,
+		 * so this will have some false positives)
+		 */
+		if (unlikely(PageDirty(page)))
+			printk("%s: dirty orphaned page\n", __FUNCTION__);
+
 		return PAGE_KEEP;
 	}
 	if (mapping->a_ops->writepage == NULL)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
