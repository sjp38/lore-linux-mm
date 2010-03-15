Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BBE256B01EA
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 11:59:10 -0400 (EDT)
Date: Tue, 16 Mar 2010 02:58:59 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch] mm: lockdep page lock
Message-ID: <20100315155859.GE2869@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

This patch isn't totally complete. Needs some nesting annotations for
filesystems like ntfs, and some async lock release annotations for other
end-io handlers, also page migration code needs to set the page lock
class. But the core of it is working nicely and is a pretty small patch.

It is a bit different to one Peter posted a while back, with
differences. I don't care so much about bloating struct page with a few
more bytes. lockdep can't run on a production kernel so I think it's
preferable to be catching more complex errors than avoiding overhead. I
also set the page lock class at the time it is added to pagecache when
we have the mapping pinned to the page.

One issue I wonder about is if the lock class is changed while some
other page locker is waiting to get the lock but has already called
lock_acquire for the old class. Possibly it could be solved if lockdep
has different primitives to say the caller is contending for a lock
versus if it has been granted the lock?

Do you think it would be useful?
--

Page lock has very complex dependencies, so it would be really nice to add
lockdep support for it.

For example:
add_to_page_cache_locked(GFP_KERNEL) (called with page locked)
-> page reclaim performs a trylock_page
 -> page reclaim performs a writepage
  -> writepage performs a get_block
   -> get_block reads buffercache
    -> buffercache read requires grow_dev_page
     -> grow_dev_page locks buffercache page
 -> if writepage fails, page reclaim calls handle_write_error
  -> handle_write_error performs a lock_page

So before even considering any other locks or more complex nested
filesystems, we can hold at least 3 different page locks at once. Should
be safe because we have an fs->bdev page lock ordering, and because
add_to_page_cache* tend to be called on new (non-LRU) pages that can't
be locked elsewhere, however a notable exception is tmpfs which moves
live pages in and out of pagecache.

So lockdepify the page lock. Each filesystem type gets a unique key, to
handle inter-filesystem nesting (like regular filesystem -> buffercache,
or ecryptfs -> lower). Newly allocated pages get a default lock class,
and it is reassigned to their filesystem type when being added to page
cache.

---
 fs/buffer.c              |    5 ++++-
 fs/mpage.c               |    3 ++-
 include/linux/fs.h       |    2 ++
 include/linux/mm_types.h |    2 ++
 include/linux/pagemap.h  |   41 +++++++++++++++++++++++++++++++++++------
 kernel/lockdep.c         |    2 ++
 mm/filemap.c             |   30 ++++++++++++++++++++++++++++--
 mm/internal.h            |    3 +++
 mm/page_alloc.c          |    2 ++
 mm/page_io.c             |    3 ++-
 mm/truncate.c            |    3 +++
 mm/vmscan.c              |    3 +++
 12 files changed, 88 insertions(+), 11 deletions(-)

Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2010-03-16 02:27:57.000000000 +1100
+++ linux-2.6/include/linux/fs.h	2010-03-16 02:29:24.000000000 +1100
@@ -8,6 +8,7 @@
 
 #include <linux/limits.h>
 #include <linux/ioctl.h>
+#include <linux/lockdep.h>
 
 /*
  * It's silly to have NR_OPEN bigger than NR_FILE, but you can change
@@ -1749,6 +1750,7 @@ struct file_system_type {
 	struct lock_class_key i_mutex_key;
 	struct lock_class_key i_mutex_dir_key;
 	struct lock_class_key i_alloc_sem_key;
+	struct lock_class_key i_page_lock_key;
 };
 
 extern int get_sb_ns(struct file_system_type *fs_type, int flags, void *data,
Index: linux-2.6/mm/internal.h
===================================================================
--- linux-2.6.orig/mm/internal.h	2010-03-16 02:27:57.000000000 +1100
+++ linux-2.6/mm/internal.h	2010-03-16 02:29:24.000000000 +1100
@@ -13,6 +13,9 @@
 
 #include <linux/mm.h>
 
+struct lock_class_key *mapping_key(struct address_space *mapping);
+const char *mapping_key_name(struct address_space *mapping);
+
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c	2010-03-16 02:27:57.000000000 +1100
+++ linux-2.6/mm/truncate.c	2010-03-16 02:29:24.000000000 +1100
@@ -389,6 +389,9 @@ invalidate_complete_page2(struct address
 	__remove_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
+	mutex_release(&page->dep_map, 1, _THIS_IP_);
+	lockdep_init_map(&page->dep_map, mapping_key_name(NULL), mapping_key(NULL), 0);
+	mutex_acquire(&page->dep_map, 0, 1, _THIS_IP_);
 	page_cache_release(page);	/* pagecache ref */
 	return 1;
 failed:
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2010-03-16 02:27:57.000000000 +1100
+++ linux-2.6/mm/vmscan.c	2010-03-16 02:29:24.000000000 +1100
@@ -457,6 +457,9 @@ static int __remove_mapping(struct addre
 		__remove_from_page_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_uncharge_cache_page(page);
+		mutex_release(&page->dep_map, 1, _THIS_IP_);
+		lockdep_init_map(&page->dep_map, mapping_key_name(NULL), mapping_key(NULL), 0);
+		mutex_acquire(&page->dep_map, 0, 1, _THIS_IP_);
 	}
 
 	return 1;
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2010-03-16 02:27:57.000000000 +1100
+++ linux-2.6/include/linux/mm_types.h	2010-03-16 02:29:24.000000000 +1100
@@ -12,6 +12,7 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
+#include <linux/lockdep.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -100,6 +101,7 @@ struct page {
 	 */
 	void *shadow;
 #endif
+	struct lockdep_map dep_map;
 };
 
 /*
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h	2010-03-16 02:27:57.000000000 +1100
+++ linux-2.6/include/linux/pagemap.h	2010-03-16 02:29:24.000000000 +1100
@@ -292,21 +292,31 @@ static inline pgoff_t linear_page_index(
 extern void __lock_page(struct page *page);
 extern int __lock_page_killable(struct page *page);
 extern void __lock_page_nosync(struct page *page);
-extern void unlock_page(struct page *page);
+extern void __unlock_page(struct page *page);
 
 static inline void __set_page_locked(struct page *page)
 {
+	mutex_acquire(&page->dep_map, 0, 1, _THIS_IP_);
 	__set_bit(PG_locked, &page->flags);
 }
 
 static inline void __clear_page_locked(struct page *page)
 {
+	mutex_release(&page->dep_map, 1, _THIS_IP_);
 	__clear_bit(PG_locked, &page->flags);
 }
 
+static inline int __trylock_page(struct page *page)
+{
+	return likely(!test_and_set_bit_lock(PG_locked, &page->flags));
+}
+
 static inline int trylock_page(struct page *page)
 {
-	return (likely(!test_and_set_bit_lock(PG_locked, &page->flags)));
+	int ret = __trylock_page(page);
+	if (likely(ret))
+		mutex_acquire(&page->dep_map, 0, 1, _THIS_IP_);
+	return likely(ret);
 }
 
 /*
@@ -315,7 +325,8 @@ static inline int trylock_page(struct pa
 static inline void lock_page(struct page *page)
 {
 	might_sleep();
-	if (!trylock_page(page))
+	mutex_acquire(&page->dep_map, 0, 0, _THIS_IP_);
+	if (!__trylock_page(page))
 		__lock_page(page);
 }
 
@@ -327,7 +338,8 @@ static inline void lock_page(struct page
 static inline int lock_page_killable(struct page *page)
 {
 	might_sleep();
-	if (!trylock_page(page))
+	mutex_acquire(&page->dep_map, 0, 0, _THIS_IP_);
+	if (!__trylock_page(page))
 		return __lock_page_killable(page);
 	return 0;
 }
@@ -339,10 +351,27 @@ static inline int lock_page_killable(str
 static inline void lock_page_nosync(struct page *page)
 {
 	might_sleep();
-	if (!trylock_page(page))
+	mutex_acquire(&page->dep_map, 0, 0, _THIS_IP_);
+	if (!__trylock_page(page))
 		__lock_page_nosync(page);
 }
-	
+
+static inline void unlock_page(struct page *page)
+{
+	mutex_release(&page->dep_map, 1, _THIS_IP_);
+	__unlock_page(page);
+}
+
+static inline void unlock_page_async(struct page *page)
+{
+	__unlock_page(page);
+}
+
+static inline void set_page_async_unlock(struct page *page)
+{
+	mutex_release(&page->dep_map, 1, _THIS_IP_);
+}
+
 /*
  * This is exported only for wait_on_page_locked/wait_on_page_writeback.
  * Never use this directly!
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2010-03-16 02:27:57.000000000 +1100
+++ linux-2.6/mm/filemap.c	2010-03-16 02:29:24.000000000 +1100
@@ -110,6 +110,21 @@
  *    ->i_mmap_lock
  */
 
+static struct lock_class_key page_lock_key;
+struct lock_class_key *mapping_key(struct address_space *mapping)
+{
+	if (!mapping)
+		return &page_lock_key;
+	return &mapping->host->i_sb->s_type->i_page_lock_key;
+}
+
+const char *mapping_key_name(struct address_space *mapping)
+{
+	if (!mapping)
+		return "page_lock";
+	return mapping->host->i_sb->s_type->name;
+}
+
 /*
  * Remove a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
@@ -150,6 +165,10 @@ void remove_from_page_cache(struct page
 	__remove_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
+
+	mutex_release(&page->dep_map, 1, _THIS_IP_);
+	lockdep_init_map(&page->dep_map, mapping_key_name(NULL), mapping_key(NULL), 0);
+	mutex_acquire(&page->dep_map, 0, 1, _THIS_IP_);
 }
 
 static int sync_page(void *word)
@@ -419,6 +438,13 @@ int add_to_page_cache_locked(struct page
 			if (PageSwapBacked(page))
 				__inc_zone_page_state(page, NR_SHMEM);
 			spin_unlock_irq(&mapping->tree_lock);
+
+			mutex_release(&page->dep_map, 1, _THIS_IP_);
+			lockdep_init_map(&page->dep_map, mapping_key_name(mapping), mapping_key(mapping), 0);
+			if (!(gfp_mask & __GFP_WAIT)) /* hack for shmem */
+				mutex_acquire(&page->dep_map, 0, 1, _THIS_IP_);
+			else
+				mutex_acquire(&page->dep_map, 0, 0, _THIS_IP_);
 		} else {
 			page->mapping = NULL;
 			spin_unlock_irq(&mapping->tree_lock);
@@ -538,14 +564,14 @@ EXPORT_SYMBOL_GPL(add_page_wait_queue);
  * The mb is necessary to enforce ordering between the clear_bit and the read
  * of the waitqueue (to avoid SMP races with a parallel wait_on_page_locked()).
  */
-void unlock_page(struct page *page)
+void __unlock_page(struct page *page)
 {
 	VM_BUG_ON(!PageLocked(page));
 	clear_bit_unlock(PG_locked, &page->flags);
 	smp_mb__after_clear_bit();
 	wake_up_page(page, PG_locked);
 }
-EXPORT_SYMBOL(unlock_page);
+EXPORT_SYMBOL(__unlock_page);
 
 /**
  * end_page_writeback - end writeback against a page
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2010-03-16 02:27:57.000000000 +1100
+++ linux-2.6/mm/page_alloc.c	2010-03-16 02:29:24.000000000 +1100
@@ -728,6 +728,8 @@ static int prep_new_page(struct page *pa
 	if (order && (gfp_flags & __GFP_COMP))
 		prep_compound_page(page, order);
 
+	lockdep_init_map(&page->dep_map, mapping_key_name(NULL), mapping_key(NULL), 0);
+
 	return 0;
 }
 
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2010-03-16 02:27:57.000000000 +1100
+++ linux-2.6/fs/buffer.c	2010-03-16 02:29:24.000000000 +1100
@@ -353,7 +353,7 @@ static void end_buffer_async_read(struct
 	 */
 	if (page_uptodate && !PageError(page))
 		SetPageUptodate(page);
-	unlock_page(page);
+	unlock_page_async(page);
 	return;
 
 still_busy:
@@ -2214,6 +2214,9 @@ int block_read_full_page(struct page *pa
 		mark_buffer_async_read(bh);
 	}
 
+	/* page will be unlocked asynchronously by end-io handler */
+	set_page_async_unlock(page);
+
 	/*
 	 * Stage 3: start the IO.  Check for uptodateness
 	 * inside the buffer lock in case another process reading
Index: linux-2.6/fs/mpage.c
===================================================================
--- linux-2.6.orig/fs/mpage.c	2010-03-16 02:27:57.000000000 +1100
+++ linux-2.6/fs/mpage.c	2010-03-16 02:29:24.000000000 +1100
@@ -56,7 +56,7 @@ static void mpage_end_io_read(struct bio
 			ClearPageUptodate(page);
 			SetPageError(page);
 		}
-		unlock_page(page);
+		unlock_page_async(page);
 	} while (bvec >= bio->bi_io_vec);
 	bio_put(bio);
 }
@@ -301,6 +301,7 @@ alloc_new:
 	}
 
 	length = first_hole << blkbits;
+	set_page_async_unlock(page);
 	if (bio_add_page(bio, page, length, 0) < length) {
 		bio = mpage_bio_submit(READ, bio);
 		goto alloc_new;
Index: linux-2.6/mm/page_io.c
===================================================================
--- linux-2.6.orig/mm/page_io.c	2010-03-16 02:27:57.000000000 +1100
+++ linux-2.6/mm/page_io.c	2010-03-16 02:29:24.000000000 +1100
@@ -80,7 +80,7 @@ void end_swap_bio_read(struct bio *bio,
 	} else {
 		SetPageUptodate(page);
 	}
-	unlock_page(page);
+	unlock_page_async(page);
 	bio_put(bio);
 }
 
@@ -128,6 +128,7 @@ int swap_readpage(struct page *page)
 		goto out;
 	}
 	count_vm_event(PSWPIN);
+	set_page_async_unlock(page);
 	submit_bio(READ, bio);
 out:
 	return ret;
Index: linux-2.6/kernel/lockdep.c
===================================================================
--- linux-2.6.orig/kernel/lockdep.c	2010-03-16 02:27:57.000000000 +1100
+++ linux-2.6/kernel/lockdep.c	2010-03-16 02:29:24.000000000 +1100
@@ -2701,11 +2701,13 @@ void lockdep_init_map(struct lockdep_map
 	/*
 	 * Sanity check, the lock-class key must be persistent:
 	 */
+#if 0
 	if (!static_obj(key)) {
 		printk("BUG: key %p not in .data!\n", key);
 		DEBUG_LOCKS_WARN_ON(1);
 		return;
 	}
+#endif
 	lock->key = key;
 
 	if (unlikely(!debug_locks))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
