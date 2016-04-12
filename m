Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id C497E6B025E
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:25:35 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id td3so14510058pab.2
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 07:25:35 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id cg4si10550251pad.22.2016.04.12.07.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 07:25:34 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id k3so1507797pav.3
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 07:25:34 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Date: Tue, 12 Apr 2016 23:25:22 +0900
Subject: Re: [PATCH v3 02/16] mm/compaction: support non-lru movable page
 migration
Message-ID: <20160412142522.GA3265@blaptop>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-3-git-send-email-minchan@kernel.org>
 <570CAB12.2090408@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <570CAB12.2090408@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chulmin Kim <cmlaika.kim@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Chulmin,

On Tue, Apr 12, 2016 at 05:00:18PM +0900, Chulmin Kim wrote:
> On 2016e?? 03i?? 30i? 1/4  16:12, Minchan Kim wrote:
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
> >
> >3. If migration is successful, it should clear PG_isolated and
> >PG_movable of the page for free preparation then release the
> >reference of the page to free.
> >
> >4. If migration fails, putback function of subsystem should
> >clear PG_isolated via ClearPageIsolated.
> >
> >5. If a subsystem want to release isolated page, it should
> >clear PG_isolated but not PG_movable. Instead, VM will do it.
> >
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
> >  };
> >
> >  #ifndef __GENERATING_BOUNDS_H
> >@@ -614,6 +618,33 @@ static inline void __ClearPageBalloon(struct page *page)
> >  	atomic_set(&page->_mapcount, -1);
> >  }
> >
> >+#define PAGE_MOVABLE_MAPCOUNT_VALUE (-255)
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
> 
> 
> Hello Minchan.
> 
> We captured a problem case.
> We suspect that
> a zs subpage(T) in the below condition can be isolated twice,
> which seems wrong.
> 
>  migrate_ctx_A         migrate_ctx_B            C (proc being killed)
> -------------       ----------------        -----------------
>  lock_page(T)
>  isolate(T)
>  unlock_page(T)
> 
>                                               zs_free() (making zspage
> ZS_EMPTY)
>                                                   free_zspage()
>                                                      lock_page(T)
>                                                      reset_page(T)
>                                                         (Keeps T
> "PageMovable" and Clears "PageIsolated")
>                                                      unlock_page(T)
> 
> 
>                        lock_page(T)
>                        isolate(T)
> 
> 
> In our case,
> during the second isolation (migrateB),
> there was null pointer dereference
> ((Without DEBUG_VM) T's first page was set to NULL)
> 
> 
> Not sure this is the case you and Vlastimil discussed.
> (I think it is a bit different)

That's exactly a bug we discussed.
I will fix it in next revision.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
