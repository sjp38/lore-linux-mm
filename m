Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1900B6B006E
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 06:17:34 -0500 (EST)
Date: Mon, 21 Nov 2011 11:17:26 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/5] mm: compaction: Determine if dirty pages can be
 migreated without blocking within ->migratepage
Message-ID: <20111121111726.GA19415@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
 <1321635524-8586-5-git-send-email-mgorman@suse.de>
 <20111118213530.GA6323@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111118213530.GA6323@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 18, 2011 at 10:35:30PM +0100, Andrea Arcangeli wrote:
> On Fri, Nov 18, 2011 at 04:58:43PM +0000, Mel Gorman wrote:
> > +	/* async case, we cannot block on lock_buffer so use trylock_buffer */
> > +	do {
> > +		get_bh(bh);
> > +		if (!trylock_buffer(bh)) {
> > +			/*
> > +			 * We failed to lock the buffer and cannot stall in
> > +			 * async migration. Release the taken locks
> > +			 */
> > +			struct buffer_head *failed_bh = bh;
> > +			bh = head;
> > +			do {
> > +				unlock_buffer(bh);
> > +				put_bh(bh);
> > +				bh = bh->b_this_page;
> > +			} while (bh != failed_bh);
> > +			return false;
> 
> here if blocksize is < PAGE_SIZE you're leaking one get_bh
> (memleak). If blocksize is PAGE_SIZE (common) you're unlocking a
> locked bh leading to fs corruption.

Well spotted, should be easily. Thanks.

> > +	if (!buffer_migrate_lock_buffers(head, sync)) {
> > +		/*
> > +		 * We have to revert the radix tree update. If this returns
> > +		 * non-zero, it either means that the page count changed
> > +		 * which "can't happen" or the slot changed from underneath
> > +		 * us in which case someone operated on a page that did not
> > +		 * have buffers fully migrated which is alarming so warn
> > +		 * that it happened.
> > +		 */
> > +		WARN_ON(migrate_page_move_mapping(mapping, page, newpage));
> 
> speculative pagecache lookups can actually increase the count, the
> freezing is released before returning from
> migrate_page_move_mapping. It's not alarming that pagecache lookup
> flips bit all over the place. The only way to stop them is the
> page_freeze_refs.
> 

You're right, speculative pagecache lookup complicates things. If the
backout case encounters a page with an elevated count, there is not
much it can do other than block until that reference has been dropped.
Even then, the backout case would be a bit of a mess.

One alternative option is for migrate_page_move_mapping to use lock
the buffers with trylock while the page is frozen and before the
slot is updated in the async case and bail if the buffers cannot be
locked. I am including an updated patch below.

> folks who wants low latency or no memory overhead should simply
> disable compaction.

That strikes me as being somewhat heavy handed. Compaction should be as
low latency as possible.

> In my tests these "lowlatency" changes, notably
> the change in vmscan that is already upstream breaks thp allocation
> reliability,

There might be some confusion on what commits were for. Commit
[e0887c19: vmscan: limit direct reclaim for higher order allocations]
was not about low latency but more about reclaim/compaction reclaiming
too much memory. IIRC, Rik's main problem was that there was too much
memory free on his machine when THP was enabled.

> the __GFP_NO_KSWAPD check too should be dropped I think,

Only if we can get rid of the major stalls. I haven't looked closely at
your series yet but I'll be searching for a replacment for patch 3 of
this series in it.

> it's good thing we dropped it because the sync migrate is needed or
> the above pages with bh to migrate would become "unmovable" despite
> they're allocated in "movable" pageblocks.
> 
> The workload to test is:
> 
> cp /dev/sda /dev/null &
> cp /dev/zero /media/someusb/zero &
> wait free memory to reach minimum level
> ./largepage (allocate some gigabyte of hugepages)
> grep thp /proc/vmstat
> 

Ok. It's not even close to what I was testing but I can move to this
test so we're looking at the same thing for allocation success rates.

> Anything that leads to a thp allocation failure rate of this workload
> of 50% should be banned and all compaction patches (including vmscan
> changes) should go through the above workload.
> 
> I got back to the previous state and there's <10% of failures even in
> the above workload (and close to 100% in normal load but it's harder
> to define normal load while the above is pretty easy to define).

Here is an updated patch that allows more dirty pages to be migrated by
async compation.

==== CUT HERE ====
mm: compaction: Determine if dirty pages can be migrated without blocking within ->migratepage

Asynchronous compaction is when allocating transparent hugepages to
avoid blocking for long periods of time. Due to reports of stalling,
synchronous compaction is never used but this impacts allocation
success rates. When deciding whether to migrate dirty pages, the
following check is made

	if (PageDirty(page) && !sync &&
		mapping->a_ops->migratepage != migrate_page)
			rc = -EBUSY;

This skips over all pages using buffer_migrate_page() even though
it is possible to migrate some of these pages without blocking. This
patch updates the ->migratepage callback with a "sync" parameter. It
is the resposibility of the callback to gracefully fail migration of
the page if it cannot be achieved without blocking.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 fs/btrfs/disk-io.c      |    2 +-
 fs/nfs/internal.h       |    2 +-
 fs/nfs/write.c          |    4 +-
 include/linux/fs.h      |    9 ++-
 include/linux/migrate.h |    2 +-
 mm/migrate.c            |  127 +++++++++++++++++++++++++++++++++--------------
 6 files changed, 101 insertions(+), 45 deletions(-)

diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 62afe5c..f841f00 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -872,7 +872,7 @@ static int btree_submit_bio_hook(struct inode *inode, int rw, struct bio *bio,
 
 #ifdef CONFIG_MIGRATION
 static int btree_migratepage(struct address_space *mapping,
-			struct page *newpage, struct page *page)
+			struct page *newpage, struct page *page, bool sync)
 {
 	/*
 	 * we can't safely write a btree page from here,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c1a1bd8..d0c460f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -328,7 +328,7 @@ void nfs_commit_release_pages(struct nfs_write_data *data);
 
 #ifdef CONFIG_MIGRATION
 extern int nfs_migrate_page(struct address_space *,
-		struct page *, struct page *);
+		struct page *, struct page *, bool);
 #else
 #define nfs_migrate_page NULL
 #endif
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1dda78d..33475df 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1711,7 +1711,7 @@ out_error:
 
 #ifdef CONFIG_MIGRATION
 int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
-		struct page *page)
+		struct page *page, bool sync)
 {
 	/*
 	 * If PagePrivate is set, then the page is currently associated with
@@ -1726,7 +1726,7 @@ int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
 
 	nfs_fscache_release_page(page, GFP_KERNEL);
 
-	return migrate_page(mapping, newpage, page);
+	return migrate_page(mapping, newpage, page, sync);
 }
 #endif
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 0c4df26..034cffb 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -609,9 +609,12 @@ struct address_space_operations {
 			loff_t offset, unsigned long nr_segs);
 	int (*get_xip_mem)(struct address_space *, pgoff_t, int,
 						void **, unsigned long *);
-	/* migrate the contents of a page to the specified target */
+	/*
+	 * migrate the contents of a page to the specified target. If sync
+	 * is false, it must not block.
+	 */
 	int (*migratepage) (struct address_space *,
-			struct page *, struct page *);
+			struct page *, struct page *, bool);
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
@@ -2577,7 +2580,7 @@ extern int generic_check_addressable(unsigned, u64);
 
 #ifdef CONFIG_MIGRATION
 extern int buffer_migrate_page(struct address_space *,
-				struct page *, struct page *);
+				struct page *, struct page *, bool);
 #else
 #define buffer_migrate_page NULL
 #endif
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e39aeec..14e6d2a 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -11,7 +11,7 @@ typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
 extern void putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
-			struct page *, struct page *);
+			struct page *, struct page *, bool);
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
 			bool sync);
diff --git a/mm/migrate.c b/mm/migrate.c
index 578e291..f93bfad 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -220,6 +220,54 @@ out:
 	pte_unmap_unlock(ptep, ptl);
 }
 
+#ifdef CONFIG_BLOCK
+/* Returns true if all buffers are successfully locked */
+static bool buffer_migrate_lock_buffers(struct buffer_head *head, bool sync)
+{
+	struct buffer_head *bh = head;
+
+	/* Simple case, sync compaction */
+	if (sync) {
+		do {
+			get_bh(bh);
+			lock_buffer(bh);
+			bh = bh->b_this_page;
+
+		} while (bh != head);
+
+		return true;
+	}
+
+	/* async case, we cannot block on lock_buffer so use trylock_buffer */
+	do {
+		get_bh(bh);
+		if (!trylock_buffer(bh)) {
+			/*
+			 * We failed to lock the buffer and cannot stall in
+			 * async migration. Release the taken locks
+			 */
+			struct buffer_head *failed_bh = bh;
+			put_bh(failed_bh);
+			bh = head;
+			while (bh != failed_bh) {
+				unlock_buffer(bh);
+				put_bh(bh);
+				bh = bh->b_this_page;
+			}
+			return false;
+		}
+
+		bh = bh->b_this_page;
+	} while (bh != head);
+	return true;
+}
+#else
+static inline bool buffer_migrate_lock_buffers(struct buffer_head *head, bool sync)
+{
+	return true;
+}
+#endif /* CONFIG_BLOCK */
+
 /*
  * Replace the page in the mapping.
  *
@@ -229,7 +277,8 @@ out:
  * 3 for pages with a mapping and PagePrivate/PagePrivate2 set.
  */
 static int migrate_page_move_mapping(struct address_space *mapping,
-		struct page *newpage, struct page *page)
+		struct page *newpage, struct page *page,
+		struct buffer_head *head, bool sync)
 {
 	int expected_count;
 	void **pslot;
@@ -259,6 +308,19 @@ static int migrate_page_move_mapping(struct address_space *mapping,
 	}
 
 	/*
+	 * In the async migration case of moving a page with buffers, lock the
+	 * buffers using trylock before the mapping is moved. If the mapping
+	 * was moved, we later failed to lock the buffers and could not move
+	 * the mapping back due to an elevated page count, we would have to
+	 * block waiting on other references to be dropped.
+	 */
+	if (!sync && head && !buffer_migrate_lock_buffers(head, sync)) {
+		page_unfreeze_refs(page, expected_count);
+		spin_unlock_irq(&mapping->tree_lock);
+		return -EAGAIN;
+	}
+	
+	/*
 	 * Now we know that no one else is looking at the page.
 	 */
 	get_page(newpage);	/* add cache reference */
@@ -415,13 +477,13 @@ EXPORT_SYMBOL(fail_migrate_page);
  * Pages are locked upon entry and exit.
  */
 int migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page)
+		struct page *newpage, struct page *page, bool sync)
 {
 	int rc;
 
 	BUG_ON(PageWriteback(page));	/* Writeback must be complete */
 
-	rc = migrate_page_move_mapping(mapping, newpage, page);
+	rc = migrate_page_move_mapping(mapping, newpage, page, NULL, sync);
 
 	if (rc)
 		return rc;
@@ -438,28 +500,27 @@ EXPORT_SYMBOL(migrate_page);
  * exist.
  */
 int buffer_migrate_page(struct address_space *mapping,
-		struct page *newpage, struct page *page)
+		struct page *newpage, struct page *page, bool sync)
 {
 	struct buffer_head *bh, *head;
 	int rc;
 
 	if (!page_has_buffers(page))
-		return migrate_page(mapping, newpage, page);
+		return migrate_page(mapping, newpage, page, sync);
 
 	head = page_buffers(page);
 
-	rc = migrate_page_move_mapping(mapping, newpage, page);
+	rc = migrate_page_move_mapping(mapping, newpage, page, head, sync);
 
 	if (rc)
 		return rc;
 
-	bh = head;
-	do {
-		get_bh(bh);
-		lock_buffer(bh);
-		bh = bh->b_this_page;
-
-	} while (bh != head);
+	/* In the async case, migrate_page_move_mapping locked the buffers
+	 * with an IRQ-safe spinlock held. In the sync case, the buffers
+	 * need to be locked now
+	 */
+	if (sync)
+		BUG_ON(!buffer_migrate_lock_buffers(head, sync));
 
 	ClearPagePrivate(page);
 	set_page_private(newpage, page_private(page));
@@ -536,10 +597,13 @@ static int writeout(struct address_space *mapping, struct page *page)
  * Default handling if a filesystem does not provide a migration function.
  */
 static int fallback_migrate_page(struct address_space *mapping,
-	struct page *newpage, struct page *page)
+	struct page *newpage, struct page *page, bool sync)
 {
-	if (PageDirty(page))
+	if (PageDirty(page)) {
+		if (!sync)
+			return -EBUSY;
 		return writeout(mapping, page);
+	}
 
 	/*
 	 * Buffers may be managed in a filesystem specific way.
@@ -549,7 +613,7 @@ static int fallback_migrate_page(struct address_space *mapping,
 	    !try_to_release_page(page, GFP_KERNEL))
 		return -EAGAIN;
 
-	return migrate_page(mapping, newpage, page);
+	return migrate_page(mapping, newpage, page, sync);
 }
 
 /*
@@ -585,29 +649,18 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 
 	mapping = page_mapping(page);
 	if (!mapping)
-		rc = migrate_page(mapping, newpage, page);
-	else {
+		rc = migrate_page(mapping, newpage, page, sync);
+	else if (mapping->a_ops->migratepage)
 		/*
-		 * Do not writeback pages if !sync and migratepage is
-		 * not pointing to migrate_page() which is nonblocking
-		 * (swapcache/tmpfs uses migratepage = migrate_page).
+		 * Most pages have a mapping and most filesystems provide a
+		 * migratepage callback. Anonymous pages are part of swap
+		 * space which also has its own migratepage callback. This
+		 * is the most common path for page migration.
 		 */
-		if (PageDirty(page) && !sync &&
-		    mapping->a_ops->migratepage != migrate_page)
-			rc = -EBUSY;
-		else if (mapping->a_ops->migratepage)
-			/*
-			 * Most pages have a mapping and most filesystems
-			 * should provide a migration function. Anonymous
-			 * pages are part of swap space which also has its
-			 * own migration function. This is the most common
-			 * path for page migration.
-			 */
-			rc = mapping->a_ops->migratepage(mapping,
-							newpage, page);
-		else
-			rc = fallback_migrate_page(mapping, newpage, page);
-	}
+		rc = mapping->a_ops->migratepage(mapping,
+						newpage, page, sync);
+	else
+		rc = fallback_migrate_page(mapping, newpage, page, sync);
 
 	if (rc) {
 		newpage->mapping = NULL;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
