Date: Fri, 10 Oct 2008 04:44:34 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] approach to pull writepage out of reclaim
Message-ID: <20081010024434.GB13779@wotan.suse.de>
References: <20081009144103.GE9941@wotan.suse.de> <48EE3A07.9060205@linux-foundation.org> <20081009194434.GB25780@parisc-linux.org> <48EE6D4C.7080901@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48EE6D4C.7080901@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Matthew Wilcox <matthew@wil.cx>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 09, 2008 at 03:45:00PM -0500, Christoph Lameter wrote:
> Matthew Wilcox wrote:
> > On Thu, Oct 09, 2008 at 12:06:15PM -0500, Christoph Lameter wrote:
> >> Nick Piggin wrote:
> >>
> >>> So. Firstly, what I'm looking at is doing swap writeout from pdflush. This
> >>> patch does that (working in concept, but pdflush and background writeout
> >>> from dirty inode list isn't really up to the task, might scrap it and do the
> >>> writeout from kswap). But writeout from radix-tree should actually be able to
> >>> give better swapout pattern than LRU writepage as well.
> >> Patch is missing from the message.
> > 
> > It's no longer acceptable to post descriptions of what you're about to
> > do?  You have to invest lots of time into creating a patch and testing that
> > it works before posting it (only to have it shot down because someone
> > disagrees with the design of your solution)?  Really?
> 
> The text says that a patch was included.... So I was expecting it....
> 
> But the problem you mention is real. Tried numerous times to get a conceptual
> discussion going without a patch. Usually that does not lead to anything.

I actually do have a patch I was going to send, but then with heavier
testing, I realised pdflush isn't working so well with it (only starts
up every 5 seconds, only does writeout after dirty limit is exceeded or
30s later -- swap pages want almost immediate writeout, and there also
has to be a coupling to prevent kswapd outrunning pdflush).

pdflush might be improved to handle it, but OTOH if we use something else,
then the bulk of the patch is just setting up the fs and inode etc.

So I decided not to send it, but I left thta sentence in ;) If you're
really interested:

---
Index: linux-2.6/mm/page_io.c
===================================================================
--- linux-2.6.orig/mm/page_io.c
+++ linux-2.6/mm/page_io.c
@@ -17,8 +17,110 @@
 #include <linux/bio.h>
 #include <linux/swapops.h>
 #include <linux/writeback.h>
+#include <linux/pagevec.h>
+#include <linux/backing-dev.h>
 #include <asm/pgtable.h>
 
+static int swap_writepages(struct address_space *mapping, struct writeback_control *wbc)
+{
+	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	int ret = 0;
+	int done = 0;
+	struct pagevec pvec;
+	int nr_pages;
+	pgoff_t writeback_index;
+	pgoff_t index;
+	pgoff_t end;		/* Inclusive */
+	int cycled;
+
+	if (!wbc->nonblocking)
+		return -EBUSY; /* don't force balance_dirty_pages here */
+	BUG_ON(wbc->sync_mode != WB_SYNC_NONE);
+	BUG_ON(!wbc->range_cyclic);
+	BUG_ON(wbc->range_cont);
+
+	if (bdi_write_congested(bdi)) {
+		wbc->encountered_congestion = 1;
+		return 0;
+	}
+
+	pagevec_init(&pvec, 0);
+	writeback_index = mapping->writeback_index; /* prev offset */
+	index = writeback_index;
+	if (index == 0)
+		cycled = 1;
+	else
+		cycled = 0;
+	end = -1;
+
+retry:
+	while (!done && (index <= end)) {
+		int i;
+
+		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
+			      PAGECACHE_TAG_DIRTY,
+			      min(end - index, (pgoff_t)PAGEVEC_SIZE-1) + 1);
+		if (nr_pages == 0)
+			break;
+
+		for (i = 0; i < nr_pages; i++) {
+			struct page *page = pvec.pages[i];
+			pgoff_t pidx;
+
+			lock_page(page);
+			if (!PageSwapCache(page)) {
+continue_unlock:
+				unlock_page(page);
+				continue;
+			}
+			pidx = page_private(page);
+			if (pidx > end) {
+				done = 1;
+				break;
+			}
+
+			if (!PageDirty(page) || PageWriteback(page))
+				goto continue_unlock;
+			if (remove_exclusive_swap_page(page))
+				goto continue_unlock;
+
+			BUG_ON(PageWriteback(page));
+			if (!clear_page_dirty_for_io(page))
+				goto continue_unlock;
+
+			ret = swap_writepage(page, wbc);
+			if (unlikely(ret)) {
+				done = 1;
+				break;
+			}
+			wbc->nr_to_write--;
+			if (wbc->nr_to_write <= 0)
+				done = 1;
+			if (bdi_write_congested(bdi)) {
+				wbc->encountered_congestion = 1;
+				done = 1;
+			}
+		}
+		pagevec_release(&pvec);
+		cond_resched();
+	}
+	if (!cycled) {
+		/*
+		 * range_cyclic:
+		 * We hit the last page and there is more work to be done: wrap
+		 * back to the start of the file
+		 */
+		cycled = 1;
+		index = 0;
+		end = writeback_index - 1;
+		goto retry;
+	}
+	if (wbc->range_cyclic)
+		mapping->writeback_index = index;
+
+	return ret;
+}
+
 static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
 				struct page *page, bio_end_io_t end_io)
 {
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -253,7 +253,7 @@ static inline int page_mapping_inuse(str
 
 static inline int is_page_cache_freeable(struct page *page)
 {
-	return page_count(page) - !!PagePrivate(page) == 2;
+	return page_count(page) - !!page->mapping - !!PagePrivate(page) == 1;
 }
 
 static int may_write_to_queue(struct backing_dev_info *bdi)
@@ -496,6 +496,9 @@ static unsigned long shrink_page_list(st
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
+		if (unlikely(!is_page_cache_freeable(page)))
+			goto keep;
+
 		if (!trylock_page(page))
 			goto keep;
 
@@ -546,11 +549,27 @@ static unsigned long shrink_page_list(st
 
 		mapping = page_mapping(page);
 
+		if (unlikely(!mapping)) {
+			BUG_ON(page_mapped(page));
+			/*
+			 * Some data journaling orphaned pages can have
+			 * page->mapping == NULL while being dirty with clean
+			 * buffers.
+			 */
+			if (PagePrivate(page)) {
+				if (try_to_free_buffers(page)) {
+					ClearPageDirty(page);
+					printk("vmscan: orphaned page\n");
+				}
+			}
+			goto keep_locked;
+		}
+
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page_mapped(page) && mapping) {
+		if (page_mapped(page)) {
 			switch (try_to_unmap(page, 0)) {
 			case SWAP_FAIL:
 				goto activate_locked;
@@ -562,8 +581,12 @@ static unsigned long shrink_page_list(st
 		}
 
 		if (PageDirty(page)) {
-			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
-				goto keep_locked;
+			if (!sync_writeback) {
+				unlock_page(page);
+				if (PageAnon(page))
+					balance_dirty_pages_ratelimited(mapping);
+				goto keep;
+			}
 			if (!may_enter_fs)
 				goto keep_locked;
 			if (!sc->may_writepage)
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -55,6 +55,10 @@ extern unsigned long mmap_min_addr;
 
 extern struct kmem_cache *vm_area_cachep;
 
+#include <linux/fs.h>
+extern struct inode *swap_inode;
+#define swapper_space (swap_inode->i_data)
+
 /*
  * This struct defines the per-mm list of VMAs for uClinux. If CONFIG_MMU is
  * disabled, then there's a single shared list of VMAs maintained by the
@@ -627,7 +631,6 @@ void page_address_init(void);
  */
 #define PAGE_MAPPING_ANON	1
 
-extern struct address_space swapper_space;
 static inline struct address_space *page_mapping(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h
+++ linux-2.6/include/linux/swap.h
@@ -11,6 +11,7 @@
 #include <asm/atomic.h>
 #include <asm/page.h>
 
+#define SWAPFS_MAGIC	0x5111A9F5
 struct notifier_block;
 
 struct bio;
@@ -220,7 +221,6 @@ extern int swap_writepage(struct page *p
 extern void end_swap_bio_read(struct bio *bio, int err);
 
 /* linux/mm/swap_state.c */
-extern struct address_space swapper_space;
 #define total_swapcache_pages  swapper_space.nrpages
 extern void show_swap_cache_info(void);
 extern int add_to_swap(struct page *, gfp_t);
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -8,6 +8,8 @@
  */
 #include <linux/module.h>
 #include <linux/mm.h>
+#include <linux/fs.h>
+#include <linux/mount.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
@@ -20,6 +22,8 @@
 
 #include <asm/pgtable.h>
 
+static int swap_set_page_dirty(struct page *page);
+
 /*
  * swapper_space is a fiction, retained to simplify the path through
  * vmscan's shrink_page_list, to make sync_page look nicer, and to allow
@@ -27,24 +31,74 @@
  */
 static const struct address_space_operations swap_aops = {
 	.writepage	= swap_writepage,
+//	.writepages	= swap_writepages,
 	.sync_page	= block_sync_page,
-	.set_page_dirty	= __set_page_dirty_nobuffers,
+	.set_page_dirty	= swap_set_page_dirty,
 	.migratepage	= migrate_page,
 };
 
 static struct backing_dev_info swap_backing_dev_info = {
-	.capabilities	= BDI_CAP_NO_ACCT_AND_WRITEBACK,
 	.unplug_io_fn	= swap_unplug_io_fn,
 };
 
-struct address_space swapper_space = {
-	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
-	.tree_lock	= __SPIN_LOCK_UNLOCKED(swapper_space.tree_lock),
-	.a_ops		= &swap_aops,
-	.i_mmap_nonlinear = LIST_HEAD_INIT(swapper_space.i_mmap_nonlinear),
-	.backing_dev_info = &swap_backing_dev_info,
+static int swapfs_get_sb(struct file_system_type *fs_type,
+			int flags, const char *dev_name, void *data,
+			struct vfsmount *mnt)
+{
+	return get_sb_pseudo(fs_type, "swap:", NULL, SWAPFS_MAGIC, mnt);
+}
+
+static struct file_system_type swap_fs_type = {
+	.name		= "swapfs",
+	.get_sb		= swapfs_get_sb,
+	.kill_sb	= kill_anon_super,
 };
 
+static struct vfsmount *swap_mnt __read_mostly;
+struct inode *swap_inode __read_mostly;
+
+static int swap_set_page_dirty(struct page *page)
+{
+	int ret;
+	ret = __set_page_dirty_nobuffers(page);
+	mark_inode_dirty(swap_inode);
+	return ret;
+}
+
+static int __init init_swap_fs(void)
+{
+	int err;
+
+	err = register_filesystem(&swap_fs_type);
+	if (err)
+		goto out;
+
+	swap_mnt = kern_mount(&swap_fs_type);
+	if (IS_ERR(swap_mnt)) {
+		err = PTR_ERR(swap_mnt);
+		goto out_register;
+	}
+
+	swap_inode = new_inode(swap_mnt->mnt_sb);
+	if (!swap_inode) {
+		err = -ENOMEM;
+		goto out_mount;
+	}
+
+	swap_inode->i_mapping->a_ops = &swap_aops;
+	swap_inode->i_mapping->backing_dev_info = &swap_backing_dev_info;
+
+	return 0;
+
+out_mount:
+	mntput(swap_mnt);
+out_register:
+	unregister_filesystem(&swap_fs_type);
+out:
+	return err;
+}
+fs_initcall(init_swap_fs);
+
 #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
 
 static struct {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
