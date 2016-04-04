Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 886C26B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 01:12:22 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id c20so27408896pfc.1
        for <linux-mm@kvack.org>; Sun, 03 Apr 2016 22:12:22 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l27si24044200pfi.125.2016.04.03.22.12.20
        for <linux-mm@kvack.org>;
        Sun, 03 Apr 2016 22:12:21 -0700 (PDT)
Date: Mon, 4 Apr 2016 14:12:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 02/16] mm/compaction: support non-lru movable page
 migration
Message-ID: <20160404051225.GA6838@bbox>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-3-git-send-email-minchan@kernel.org>
 <56FEE82A.30602@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56FEE82A.30602@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, dri-devel@lists.freedesktop.org, Gioh Kim <gurugio@hanmail.net>

On Fri, Apr 01, 2016 at 11:29:14PM +0200, Vlastimil Babka wrote:
> Might have been better as a separate migration patch and then a
> compaction patch. It's prefixed mm/compaction, but most changed are
> in mm/migrate.c

Indeed. The title is rather misleading but not sure it's a good idea
to separate compaction and migration part.
I will just resend to change the tile from "mm/compaction" to
"mm/migration".

> 
> On 03/30/2016 09:12 AM, Minchan Kim wrote:
> >We have allowed migration for only LRU pages until now and it was
> >enough to make high-order pages. But recently, embedded system(e.g.,
> >webOS, android) uses lots of non-movable pages(e.g., zram, GPU memory)
> >so we have seen several reports about troubles of small high-order
> >allocation. For fixing the problem, there were several efforts
> >(e,g,. enhance compaction algorithm, SLUB fallback to 0-order page,
> >reserved memory, vmalloc and so on) but if there are lots of
> >non-movable pages in system, their solutions are void in the long run.
> >
> >So, this patch is to support facility to change non-movable pages
> >with movable. For the feature, this patch introduces functions related
> >to migration to address_space_operations as well as some page flags.
> >
> >Basically, this patch supports two page-flags and two functions related
> >to page migration. The flag and page->mapping stability are protected
> >by PG_lock.
> >
> >	PG_movable
> >	PG_isolated
> >
> >	bool (*isolate_page) (struct page *, isolate_mode_t);
> >	void (*putback_page) (struct page *);
> >
> >Duty of subsystem want to make their pages as migratable are
> >as follows:
> >
> >1. It should register address_space to page->mapping then mark
> >the page as PG_movable via __SetPageMovable.
> >
> >2. It should mark the page as PG_isolated via SetPageIsolated
> >if isolation is sucessful and return true.
> 
> Ah another thing to document (especially in the comments/Doc) is
> that the subsystem must not expect anything to survive in page.lru
> (or fields that union it) after having isolated successfully.

Indeed. I surprised I didn't miss because I wrote it down somewhere
but might miss it during rebase.
I will fix it.

> 
> >3. If migration is successful, it should clear PG_isolated and
> >PG_movable of the page for free preparation then release the
> >reference of the page to free.
> >
> >4. If migration fails, putback function of subsystem should
> >clear PG_isolated via ClearPageIsolated.
> >
> >5. If a subsystem want to release isolated page, it should
> >clear PG_isolated but not PG_movable. Instead, VM will do it.
> 
> Under lock? Or just with ClearPageIsolated?

Both:
ClearPageIsolated undert PG_lock.

Yes, it's better to change ClearPageIsolated to __ClearPageIsolated.

> 
> >Cc: Vlastimil Babka <vbabka@suse.cz>
> >Cc: Mel Gorman <mgorman@suse.de>
> >Cc: Hugh Dickins <hughd@google.com>
> >Cc: dri-devel@lists.freedesktop.org
> >Cc: virtualization@lists.linux-foundation.org
> >Signed-off-by: Gioh Kim <gurugio@hanmail.net>
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> >---
> >  Documentation/filesystems/Locking      |   4 +
> >  Documentation/filesystems/vfs.txt      |   5 +
> >  fs/proc/page.c                         |   3 +
> >  include/linux/fs.h                     |   2 +
> >  include/linux/migrate.h                |   2 +
> >  include/linux/page-flags.h             |  31 ++++++
> >  include/uapi/linux/kernel-page-flags.h |   1 +
> >  mm/compaction.c                        |  14 ++-
> >  mm/migrate.c                           | 174 +++++++++++++++++++++++++++++----
> >  9 files changed, 217 insertions(+), 19 deletions(-)
> >
> >diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
> >index 619af9bfdcb3..0bb79560abb3 100644
> >--- a/Documentation/filesystems/Locking
> >+++ b/Documentation/filesystems/Locking
> >@@ -195,7 +195,9 @@ unlocks and drops the reference.
> >  	int (*releasepage) (struct page *, int);
> >  	void (*freepage)(struct page *);
> >  	int (*direct_IO)(struct kiocb *, struct iov_iter *iter, loff_t offset);
> >+	bool (*isolate_page) (struct page *, isolate_mode_t);
> >  	int (*migratepage)(struct address_space *, struct page *, struct page *);
> >+	void (*putback_page) (struct page *);
> >  	int (*launder_page)(struct page *);
> >  	int (*is_partially_uptodate)(struct page *, unsigned long, unsigned long);
> >  	int (*error_remove_page)(struct address_space *, struct page *);
> >@@ -219,7 +221,9 @@ invalidatepage:		yes
> >  releasepage:		yes
> >  freepage:		yes
> >  direct_IO:
> >+isolate_page:		yes
> >  migratepage:		yes (both)
> >+putback_page:		yes
> >  launder_page:		yes
> >  is_partially_uptodate:	yes
> >  error_remove_page:	yes
> >diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> >index b02a7d598258..4c1b6c3b4bc8 100644
> >--- a/Documentation/filesystems/vfs.txt
> >+++ b/Documentation/filesystems/vfs.txt
> >@@ -592,9 +592,14 @@ struct address_space_operations {
> >  	int (*releasepage) (struct page *, int);
> >  	void (*freepage)(struct page *);
> >  	ssize_t (*direct_IO)(struct kiocb *, struct iov_iter *iter, loff_t offset);
> >+	/* isolate a page for migration */
> >+	bool (*isolate_page) (struct page *, isolate_mode_t);
> >  	/* migrate the contents of a page to the specified target */
> >  	int (*migratepage) (struct page *, struct page *);
> >+	/* put the page back to right list */
> 
> ... "after a failed migration" ?

Better.

> 
> >+	void (*putback_page) (struct page *);
> >  	int (*launder_page) (struct page *);
> >+
> >  	int (*is_partially_uptodate) (struct page *, unsigned long,
> >  					unsigned long);
> >  	void (*is_dirty_writeback) (struct page *, bool *, bool *);
> >diff --git a/fs/proc/page.c b/fs/proc/page.c
> >index 3ecd445e830d..ce3d08a4ad8d 100644
> >--- a/fs/proc/page.c
> >+++ b/fs/proc/page.c
> >@@ -157,6 +157,9 @@ u64 stable_page_flags(struct page *page)
> >  	if (page_is_idle(page))
> >  		u |= 1 << KPF_IDLE;
> >
> >+	if (PageMovable(page))
> >+		u |= 1 << KPF_MOVABLE;
> >+
> >  	u |= kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
> >
> >  	u |= kpf_copy_bit(k, KPF_SLAB,		PG_slab);
> >diff --git a/include/linux/fs.h b/include/linux/fs.h
> >index da9e67d937e5..36f2d610e7a8 100644
> >--- a/include/linux/fs.h
> >+++ b/include/linux/fs.h
> >@@ -401,6 +401,8 @@ struct address_space_operations {
> >  	 */
> >  	int (*migratepage) (struct address_space *,
> >  			struct page *, struct page *, enum migrate_mode);
> >+	bool (*isolate_page)(struct page *, isolate_mode_t);
> >+	void (*putback_page)(struct page *);
> >  	int (*launder_page) (struct page *);
> >  	int (*is_partially_uptodate) (struct page *, unsigned long,
> >  					unsigned long);
> >diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> >index 9b50325e4ddf..404fbfefeb33 100644
> >--- a/include/linux/migrate.h
> >+++ b/include/linux/migrate.h
> >@@ -37,6 +37,8 @@ extern int migrate_page(struct address_space *,
> >  			struct page *, struct page *, enum migrate_mode);
> >  extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
> >  		unsigned long private, enum migrate_mode mode, int reason);
> >+extern bool isolate_movable_page(struct page *page, isolate_mode_t mode);
> >+extern void putback_movable_page(struct page *page);
> >
> >  extern int migrate_prep(void);
> >  extern int migrate_prep_local(void);
> >diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> >index f4ed4f1b0c77..77ebf8fdbc6e 100644
> >--- a/include/linux/page-flags.h
> >+++ b/include/linux/page-flags.h
> >@@ -129,6 +129,10 @@ enum pageflags {
> >
> >  	/* Compound pages. Stored in first tail page's flags */
> >  	PG_double_map = PG_private_2,
> >+
> >+	/* non-lru movable pages */
> >+	PG_movable = PG_reclaim,
> >+	PG_isolated = PG_owner_priv_1,
> 
> Documentation should probably state that these fields alias and
> subsystem supporting the movable pages shouldn't use them elsewhere.

Yeb.

> 
> Also I'm a bit uncomfortable how isolate_movable_page() blindly expects that
> page->mapping->a_ops->isolate_page exists for PageMovable() pages.
> What if it's a false positive on a PG_reclaim page? Can we rely on
> PG_reclaim always (and without races) implying PageLRU() so that we
> don't even attempt isolate_movable_page()?

For now, we shouldn't have such a false positive because PageMovable
checks page->_mapcount == PAGE_MOVABLE_MAPCOUNT_VALUE as well as PG_movable
under PG_lock.

But I read your question about user-mapped drvier pages so we cannot
use _mapcount anymore so I will find another thing. A option is this.

static inline int PageMovable(struct page *page)
{
        int ret = 0;
        struct address_space *mapping;
        struct address_space_operations *a_op;

        if (!test_bit(PG_movable, &(page->flags))
                goto out;

        mapping = page->mapping;
        if (!mapping)
                goto out;

        a_op = mapping->a_op;
        if (!aop)
                goto out;
        if (a_op->isolate_page)
                ret = 1;
out:
        return ret;

}

It works under PG_lock but with this, we need trylock_page to peek
whether it's movable non-lru or not for scanning pfn.
For avoiding that, we need another function to peek which just checks
PG_movable bit instead of all things.


/*
 * If @page_locked is false, we cannot guarantee page->mapping's stability
 * so just the function checks with PG_movable which could be false positive
 * so caller should check it again under PG_lock to check a_ops->isolate_page.
 */
static inline int PageMovable(struct page *page, bool page_locked)
{
        int ret = 0;
        struct address_space *mapping;
        struct address_space_operations *a_op;

        if (!test_bit(PG_movable, &(page->flags))
                goto out;

        if (!page_locked) {
                ret = 1;
                goto out;
        }

        mapping = page->mapping;
        if (!mapping)
                goto out;

        a_op = mapping->a_op;
        if (!aop)
                goto out;
        if (a_op->isolate_page)
                ret = 1;
out:
        return ret;
}

> 
> >  };
> >
> >  #ifndef __GENERATING_BOUNDS_H
> >@@ -614,6 +618,33 @@ static inline void __ClearPageBalloon(struct page *page)
> >  	atomic_set(&page->_mapcount, -1);
> >  }
> >
> >+#define PAGE_MOVABLE_MAPCOUNT_VALUE (-255)
> 
> IIRC this was what Gioh's previous attempts used instead of
> PG_movable? Is it still needed? Doesn't it prevent a driver

It needs to avoid false positive as I said.

> providing movable *and* mapped pages?

Absolutely true. I will rethink about it.

> If it's to distinguish the PG_reclaim alias that I mention above, it
> seems like an overkill to me. Why would be need both special
> mapcount value and a flag? Checking that
> page->mapping->a_ops->isolate_page exists before calling it should
> be enough to resolve the ambiguity?

As I mentioned, using a_ops->isolate_page needs to be done under PG_lock.
And the idea I suggested above will work, I guess.
I will try it.

> 
> >+
> >+static inline int PageMovable(struct page *page)
> >+{
> >+	return ((test_bit(PG_movable, &(page)->flags) &&
> >+		atomic_read(&page->_mapcount) == PAGE_MOVABLE_MAPCOUNT_VALUE)
> >+		|| PageBalloon(page));
> >+}
> >+
> >+/* Caller should hold a PG_lock */
> >+static inline void __SetPageMovable(struct page *page,
> >+				struct address_space *mapping)
> >+{
> >+	page->mapping = mapping;
> >+	__set_bit(PG_movable, &page->flags);
> >+	atomic_set(&page->_mapcount, PAGE_MOVABLE_MAPCOUNT_VALUE);
> >+}
> >+
> >+static inline void __ClearPageMovable(struct page *page)
> >+{
> >+	atomic_set(&page->_mapcount, -1);
> >+	__clear_bit(PG_movable, &(page)->flags);
> >+	page->mapping = NULL;
> >+}
> >+
> >+PAGEFLAG(Isolated, isolated, PF_ANY);
> >+
> >  /*
> >   * If network-based swap is enabled, sl*b must keep track of whether pages
> >   * were allocated from pfmemalloc reserves.
> >diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
> >index 5da5f8751ce7..a184fd2434fa 100644
> >--- a/include/uapi/linux/kernel-page-flags.h
> >+++ b/include/uapi/linux/kernel-page-flags.h
> >@@ -34,6 +34,7 @@
> >  #define KPF_BALLOON		23
> >  #define KPF_ZERO_PAGE		24
> >  #define KPF_IDLE		25
> >+#define KPF_MOVABLE		26
> >
> >
> >  #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
> >diff --git a/mm/compaction.c b/mm/compaction.c
> >index ccf97b02b85f..7557aedddaee 100644
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -703,7 +703,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> >
> >  		/*
> >  		 * Check may be lockless but that's ok as we recheck later.
> >-		 * It's possible to migrate LRU pages and balloon pages
> >+		 * It's possible to migrate LRU and movable kernel pages.
> >  		 * Skip any other type of page
> >  		 */
> >  		is_lru = PageLRU(page);
> >@@ -714,6 +714,18 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> >  					goto isolate_success;
> >  				}
> >  			}
> >+
> >+			if (unlikely(PageMovable(page)) &&
> >+					!PageIsolated(page)) {
> >+				if (locked) {
> >+					spin_unlock_irqrestore(&zone->lru_lock,
> >+									flags);
> >+					locked = false;
> >+				}
> >+
> >+				if (isolate_movable_page(page, isolate_mode))
> >+					goto isolate_success;
> >+			}
> >  		}
> >
> >  		/*
> >diff --git a/mm/migrate.c b/mm/migrate.c
> >index 53529c805752..b56bf2b3fe8c 100644
> >--- a/mm/migrate.c
> >+++ b/mm/migrate.c
> >@@ -73,6 +73,85 @@ int migrate_prep_local(void)
> >  	return 0;
> >  }
> >
> >+bool isolate_movable_page(struct page *page, isolate_mode_t mode)
> >+{
> >+	bool ret = false;
> 
> Maintaining "ret" seems useless here. All the "goto out*" statements
> are executed only when ret is false, and ret == true is returned by
> a different return.

Yeb. Will change.

> 
> >+
> >+	/*
> >+	 * Avoid burning cycles with pages that are yet under __free_pages(),
> >+	 * or just got freed under us.
> >+	 *
> >+	 * In case we 'win' a race for a movable page being freed under us and
> >+	 * raise its refcount preventing __free_pages() from doing its job
> >+	 * the put_page() at the end of this block will take care of
> >+	 * release this page, thus avoiding a nasty leakage.
> >+	 */
> >+	if (unlikely(!get_page_unless_zero(page)))
> >+		goto out;
> >+
> >+	/*
> >+	 * Check PG_movable before holding a PG_lock because page's owner
> >+	 * assumes anybody doesn't touch PG_lock of newly allocated page.
> >+	 */
> >+	if (unlikely(!PageMovable(page)))
> >+		goto out_putpage;
> >+	/*
> >+	 * As movable pages are not isolated from LRU lists, concurrent
> >+	 * compaction threads can race against page migration functions
> >+	 * as well as race against the releasing a page.
> >+	 *
> >+	 * In order to avoid having an already isolated movable page
> >+	 * being (wrongly) re-isolated while it is under migration,
> >+	 * or to avoid attempting to isolate pages being released,
> >+	 * lets be sure we have the page lock
> >+	 * before proceeding with the movable page isolation steps.
> >+	 */
> >+	if (unlikely(!trylock_page(page)))
> >+		goto out_putpage;
> >+
> >+	if (!PageMovable(page) || PageIsolated(page))
> >+		goto out_no_isolated;
> >+
> >+	ret = page->mapping->a_ops->isolate_page(page, mode);
> >+	if (!ret)
> >+		goto out_no_isolated;
> >+
> >+	WARN_ON_ONCE(!PageIsolated(page));
> >+	unlock_page(page);
> >+	return ret;
> >+
> >+out_no_isolated:
> >+	unlock_page(page);
> >+out_putpage:
> >+	put_page(page);
> >+out:
> >+	return ret;
> >+}
> >+
> >+/* It should be called on page which is PG_movable */
> >+void putback_movable_page(struct page *page)
> >+{
> >+	/*
> >+	 * 'lock_page()' stabilizes the page and prevents races against
> >+	 * concurrent isolation threads attempting to re-isolate it.
> >+	 */
> >+	VM_BUG_ON_PAGE(!PageMovable(page), page);
> >+
> >+	lock_page(page);
> >+	if (PageIsolated(page)) {
> >+		struct address_space *mapping;
> >+
> >+		mapping = page_mapping(page);
> >+		mapping->a_ops->putback_page(page);
> >+		WARN_ON_ONCE(PageIsolated(page));
> >+	} else {
> >+		__ClearPageMovable(page);
> >+	}
> >+	unlock_page(page);
> >+	/* drop the extra ref count taken for movable page isolation */
> >+	put_page(page);
> >+}
> >+
> >  /*
> >   * Put previously isolated pages back onto the appropriate lists
> >   * from where they were once taken off for compaction/migration.
> >@@ -94,10 +173,18 @@ void putback_movable_pages(struct list_head *l)
> >  		list_del(&page->lru);
> >  		dec_zone_page_state(page, NR_ISOLATED_ANON +
> >  				page_is_file_cache(page));
> >-		if (unlikely(isolated_balloon_page(page)))
> >+		if (unlikely(isolated_balloon_page(page))) {
> >  			balloon_page_putback(page);
> >-		else
> >+		} else if (unlikely(PageMovable(page))) {
> >+			if (PageIsolated(page)) {
> >+				putback_movable_page(page);
> >+			} else {
> >+				__ClearPageMovable(page);
> 
> We don't do lock_page() here, so what prevents parallel compaction
> isolating the same page?

Need PG_lock.

> 
> >+				put_page(page);
> >+			}
> >+		} else {
> >  			putback_lru_page(page);
> >+		}
> >  	}
> >  }
> >
> >@@ -592,7 +679,7 @@ void migrate_page_copy(struct page *newpage, struct page *page)
> >   ***********************************************************/
> >
> >  /*
> >- * Common logic to directly migrate a single page suitable for
> >+ * Common logic to directly migrate a single LRU page suitable for
> >   * pages that do not use PagePrivate/PagePrivate2.
> >   *
> >   * Pages are locked upon entry and exit.
> >@@ -755,24 +842,54 @@ static int move_to_new_page(struct page *newpage, struct page *page,
> >  				enum migrate_mode mode)
> >  {
> >  	struct address_space *mapping;
> >-	int rc;
> >+	int rc = -EAGAIN;
> >+	bool lru_movable = true;
> >
> >  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> >  	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
> >
> >  	mapping = page_mapping(page);
> >-	if (!mapping)
> >-		rc = migrate_page(mapping, newpage, page, mode);
> >-	else if (mapping->a_ops->migratepage)
> >-		/*
> >-		 * Most pages have a mapping and most filesystems provide a
> >-		 * migratepage callback. Anonymous pages are part of swap
> >-		 * space which also has its own migratepage callback. This
> >-		 * is the most common path for page migration.
> >-		 */
> >-		rc = mapping->a_ops->migratepage(mapping, newpage, page, mode);
> >-	else
> >-		rc = fallback_migrate_page(mapping, newpage, page, mode);
> >+	/*
> >+	 * In case of non-lru page, it could be released after
> >+	 * isolation step. In that case, we shouldn't try
> >+	 * fallback migration which was designed for LRU pages.
> >+	 *
> >+	 * The rule for such case is that subsystem should clear
> >+	 * PG_isolated but remains PG_movable so VM should catch
> >+	 * it and clear PG_movable for it.
> >+	 */
> >+	if (unlikely(PageMovable(page))) {
> 
> Can false positive from PG_reclaim occur here?

PageMovable has _mapcount == PAGE_MOVALBE_MAPCOUNT_VALUE check.

> 
> >+		lru_movable = false;
> >+		VM_BUG_ON_PAGE(!mapping, page);
> >+		if (!PageIsolated(page)) {
> >+			rc = MIGRATEPAGE_SUCCESS;
> >+			__ClearPageMovable(page);
> >+			goto out;
> >+		}
> >+	}
> >+
> >+	if (likely(lru_movable)) {
> >+		if (!mapping)
> >+			rc = migrate_page(mapping, newpage, page, mode);
> >+		else if (mapping->a_ops->migratepage)
> >+			/*
> >+			 * Most pages have a mapping and most filesystems
> >+			 * provide a migratepage callback. Anonymous pages
> >+			 * are part of swap space which also has its own
> >+			 * migratepage callback. This is the most common path
> >+			 * for page migration.
> >+			 */
> >+			rc = mapping->a_ops->migratepage(mapping, newpage,
> >+							page, mode);
> >+		else
> >+			rc = fallback_migrate_page(mapping, newpage,
> >+							page, mode);
> >+	} else {
> >+		rc = mapping->a_ops->migratepage(mapping, newpage,
> >+						page, mode);
> >+		WARN_ON_ONCE(rc == MIGRATEPAGE_SUCCESS &&
> >+			PageIsolated(page));
> >+	}
> >
> >  	/*
> >  	 * When successful, old pagecache page->mapping must be cleared before
> >@@ -782,6 +899,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
> >  		if (!PageAnon(page))
> >  			page->mapping = NULL;
> >  	}
> >+out:
> >  	return rc;
> >  }
> >
> >@@ -960,6 +1078,8 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
> >  			put_new_page(newpage, private);
> >  		else
> >  			put_page(newpage);
> >+		if (PageMovable(page))
> >+			__ClearPageMovable(page);
> >  		goto out;
> >  	}
> >
> >@@ -1000,8 +1120,26 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
> >  				num_poisoned_pages_inc();
> >  		}
> >  	} else {
> >-		if (rc != -EAGAIN)
> >-			putback_lru_page(page);
> >+		if (rc != -EAGAIN) {
> >+			/*
> >+			 * subsystem couldn't remove PG_movable since page is
> >+			 * isolated so PageMovable check is not racy in here.
> >+			 * But PageIsolated check can be racy but it's okay
> >+			 * because putback_movable_page checks it under PG_lock
> >+			 * again.
> >+			 */
> >+			if (unlikely(PageMovable(page))) {
> >+				if (PageIsolated(page))
> >+					putback_movable_page(page);
> >+				else {
> >+					__ClearPageMovable(page);
> 
> Again, we don't do lock_page() here, so what prevents parallel
> compaction isolating the same page?

It seems to need PG_lock in there, too.
Thanks for catching it up.

> 
> Sorry for so many questions, hope they all have good answers and
> this series is a success :) Thanks for picking it up.

No problem at all. Many question means the code or/and doc is not
clear and still need be improved.

Thanks for detail review, Vlastimil!
I will resend new versions after vacation in this week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
