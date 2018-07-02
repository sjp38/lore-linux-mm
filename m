Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 372CC6B026C
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 20:57:48 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id z25-v6so11180791otk.3
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 17:57:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u186-v6sor6099902oia.238.2018.07.01.17.57.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Jul 2018 17:57:45 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH v2 6/6] mm: page_mkclean, ttu: handle pinned pages
Date: Sun,  1 Jul 2018 17:56:54 -0700
Message-Id: <20180702005654.20369-7-jhubbard@nvidia.com>
In-Reply-To: <20180702005654.20369-1-jhubbard@nvidia.com>
References: <20180702005654.20369-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Update page_mkclean(), page_mkclean's callers, and try_to_unmap(), so that
there is a choice: in some cases, skipped dma-pinned pages. In other cases
(sync_mode ==  WB_SYNC_ALL), wait for those pages to become unpinned.

This fixes some problems that came up when using devices (NICs, GPUs, for
example) that set up direct access to a chunk of system (CPU) memory, so
that they can DMA to/from that memory. Problems [1] come up if that memory
is backed by persistence storage; for example, an ext4 file system. This
has caused several customers to experience kernel oops crashes, due to the
BUG_ON, below.

The bugs happen via:

-- get_user_pages() on some ext4-backed pages
-- device does DMA for a while to/from those pages

    -- Somewhere in here, some of the pages get disconnected from the
       file system, via try_to_unmap() and eventually drop_buffers()

-- device is all done, device driver calls set_page_dirty_locked, then
   put_page()

And then at some point, we see a this BUG():

    kernel BUG at /build/linux-fQ94TU/linux-4.4.0/fs/ext4/inode.c:1899!
    backtrace:
        ext4_writepage
        __writepage
        write_cache_pages
        ext4_writepages
        do_writepages
        __writeback_single_inode
        writeback_sb_inodes
        __writeback_inodes_wb
        wb_writeback
        wb_workfn
        process_one_work
        worker_thread
        kthread
        ret_from_fork

...which is due to the file system asserting that there are still buffer
heads attached:

        ({                                                      \
                BUG_ON(!PagePrivate(page));                     \
                ((struct buffer_head *)page_private(page));     \
        })

How to fix this:

If a page is pinned by any of the get_user_page("gup", here) variants, then
there is no need for that page to be on an LRU. So, this patch removes such
pages from their LRU, thus leaving the page->lru fields *mostly* available
for tracking gup pages. (The lowest bit of page->lru.next is used as
PageTail, and these flags have to be checked when we don't know if it
really is a tail page or not, so avoid that bit.)

After that, the page is reference-counted via page->dma_pinned_count, and
flagged via page->dma_pinned_flags. The PageDmaPinned flag is cleared when
the reference count hits zero, and the reference count is only used when
the flag is set, and we can only lock the page *most* of the time that we
look at the flag, so it's a little bit complicated, but it works.

All of the above provides a reliable PageDmaPinned flag, which will be used
in subsequent patches, to decide when to abort or wait for operations such
as:

    try_to_unmap()
    page_mkclean()

Thanks to Matthew Wilcox for suggesting re-using page->lru fields for a
new refcount and flag, and to Jan Kara for explaining the rest of the
design details (how to deal with page_mkclean() and try_to_unmap(),
especially). Also thanks to Dan Williams for design advice and DAX,
long-term pinning, and page flag thoughts.

References:

[1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

CC: Matthew Wilcox <willy@infradead.org>
CC: Jan Kara <jack@suse.cz>
CC: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/video/fbdev/core/fb_defio.c |  3 +-
 include/linux/rmap.h                |  4 +-
 mm/memory-failure.c                 |  3 +-
 mm/page-writeback.c                 |  3 +-
 mm/rmap.c                           | 71 ++++++++++++++++++++++++++---
 mm/truncate.c                       |  3 +-
 6 files changed, 75 insertions(+), 12 deletions(-)

diff --git a/drivers/video/fbdev/core/fb_defio.c b/drivers/video/fbdev/core/fb_defio.c
index 82c20c6047b0..f5aca45adb75 100644
--- a/drivers/video/fbdev/core/fb_defio.c
+++ b/drivers/video/fbdev/core/fb_defio.c
@@ -181,12 +181,13 @@ static void fb_deferred_io_work(struct work_struct *work)
 	struct list_head *node, *next;
 	struct page *cur;
 	struct fb_deferred_io *fbdefio = info->fbdefio;
+	bool skip_pinned_pages = false;
 
 	/* here we mkclean the pages, then do all deferred IO */
 	mutex_lock(&fbdefio->lock);
 	list_for_each_entry(cur, &fbdefio->pagelist, lru) {
 		lock_page(cur);
-		page_mkclean(cur);
+		page_mkclean(cur, skip_pinned_pages);
 		unlock_page(cur);
 	}
 
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 988d176472df..f68a473a48fb 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -233,7 +233,7 @@ unsigned long page_address_in_vma(struct page *, struct vm_area_struct *);
  *
  * returns the number of cleaned PTEs.
  */
-int page_mkclean(struct page *);
+int page_mkclean(struct page *page, bool skip_pinned_pages);
 
 /*
  * called in munlock()/munmap() path to check for other vmas holding
@@ -291,7 +291,7 @@ static inline int page_referenced(struct page *page, int is_locked,
 
 #define try_to_unmap(page, refs) false
 
-static inline int page_mkclean(struct page *page)
+static inline int page_mkclean(struct page *page, bool skip_pinned_pages)
 {
 	return 0;
 }
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 9d142b9b86dc..c4bc8d216746 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -931,6 +931,7 @@ static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	int kill = 1, forcekill;
 	struct page *hpage = *hpagep;
 	bool mlocked = PageMlocked(hpage);
+	bool skip_pinned_pages = false;
 
 	/*
 	 * Here we are interested only in user-mapped pages, so skip any
@@ -968,7 +969,7 @@ static bool hwpoison_user_mappings(struct page *p, unsigned long pfn,
 	mapping = page_mapping(hpage);
 	if (!(flags & MF_MUST_KILL) && !PageDirty(hpage) && mapping &&
 	    mapping_cap_writeback_dirty(mapping)) {
-		if (page_mkclean(hpage)) {
+		if (page_mkclean(hpage, skip_pinned_pages)) {
 			SetPageDirty(hpage);
 		} else {
 			kill = 0;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index e526b3cbf900..19f4972ba5c6 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2660,6 +2660,7 @@ int clear_page_dirty_for_io(struct page *page, int sync_mode)
 		struct inode *inode = mapping->host;
 		struct bdi_writeback *wb;
 		struct wb_lock_cookie cookie = {};
+		bool skip_pinned_pages = (sync_mode != WB_SYNC_ALL);
 
 		/*
 		 * Yes, Virginia, this is indeed insane.
@@ -2686,7 +2687,7 @@ int clear_page_dirty_for_io(struct page *page, int sync_mode)
 		 * as a serialization point for all the different
 		 * threads doing their things.
 		 */
-		if (page_mkclean(page))
+		if (page_mkclean(page, skip_pinned_pages))
 			set_page_dirty(page);
 		/*
 		 * We carefully synchronise fault handlers against
diff --git a/mm/rmap.c b/mm/rmap.c
index 6db729dc4c50..c137c43eb2ad 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -879,6 +879,26 @@ int page_referenced(struct page *page,
 	return pra.referenced;
 }
 
+/* Must be called with pinned_dma_lock held. */
+static void wait_for_dma_pinned_to_clear(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+
+	while (PageDmaPinnedFlags(page)) {
+		spin_unlock(zone_gup_lock(zone));
+
+		schedule();
+
+		spin_lock(zone_gup_lock(zone));
+	}
+}
+
+struct page_mkclean_info {
+	int cleaned;
+	int skipped;
+	bool skip_pinned_pages;
+};
+
 static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			    unsigned long address, void *arg)
 {
@@ -889,7 +909,24 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		.flags = PVMW_SYNC,
 	};
 	unsigned long start = address, end;
-	int *cleaned = arg;
+	struct page_mkclean_info *mki = (struct page_mkclean_info *)arg;
+	bool is_dma_pinned;
+	struct zone *zone = page_zone(page);
+
+	/* Serialize with get_user_pages: */
+	spin_lock(zone_gup_lock(zone));
+	is_dma_pinned = PageDmaPinned(page);
+
+	if (is_dma_pinned) {
+		if (mki->skip_pinned_pages) {
+			spin_unlock(zone_gup_lock(zone));
+			mki->skipped++;
+			return false;
+		}
+	}
+
+	/* Unlock while doing mmu notifier callbacks */
+	spin_unlock(zone_gup_lock(zone));
 
 	/*
 	 * We have to assume the worse case ie pmd for invalidation. Note that
@@ -898,6 +935,10 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
 	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
 
+	spin_lock(zone_gup_lock(zone));
+
+	wait_for_dma_pinned_to_clear(page);
+
 	while (page_vma_mapped_walk(&pvmw)) {
 		unsigned long cstart;
 		int ret = 0;
@@ -945,9 +986,11 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		 * See Documentation/vm/mmu_notifier.rst
 		 */
 		if (ret)
-			(*cleaned)++;
+			(mki->cleaned)++;
 	}
 
+	spin_unlock(zone_gup_lock(zone));
+
 	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
 
 	return true;
@@ -961,12 +1004,17 @@ static bool invalid_mkclean_vma(struct vm_area_struct *vma, void *arg)
 	return true;
 }
 
-int page_mkclean(struct page *page)
+int page_mkclean(struct page *page, bool skip_pinned_pages)
 {
-	int cleaned = 0;
+	struct page_mkclean_info mki = {
+		.cleaned = 0,
+		.skipped = 0,
+		.skip_pinned_pages = skip_pinned_pages
+	};
+
 	struct address_space *mapping;
 	struct rmap_walk_control rwc = {
-		.arg = (void *)&cleaned,
+		.arg = (void *)&mki,
 		.rmap_one = page_mkclean_one,
 		.invalid_vma = invalid_mkclean_vma,
 	};
@@ -982,7 +1030,7 @@ int page_mkclean(struct page *page)
 
 	rmap_walk(page, &rwc);
 
-	return cleaned;
+	return mki.cleaned && !mki.skipped;
 }
 EXPORT_SYMBOL_GPL(page_mkclean);
 
@@ -1346,6 +1394,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	bool ret = true;
 	unsigned long start = address, end;
 	enum ttu_flags flags = (enum ttu_flags)arg;
+	struct zone *zone = page_zone(page);
 
 	/* munlock has nothing to gain from examining un-locked vmas */
 	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
@@ -1360,6 +1409,16 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				flags & TTU_SPLIT_FREEZE, page);
 	}
 
+	/* Serialize with get_user_pages: */
+	spin_lock(zone_gup_lock(zone));
+
+	if (PageDmaPinned(page)) {
+		spin_unlock(zone_gup_lock(zone));
+		return false;
+	}
+
+	spin_unlock(zone_gup_lock(zone));
+
 	/*
 	 * We have to assume the worse case ie pmd for invalidation. Note that
 	 * the page can not be free in this function as call of try_to_unmap()
diff --git a/mm/truncate.c b/mm/truncate.c
index 1d2fb2dca96f..61e73d0d8777 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -852,6 +852,7 @@ void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
 	loff_t rounded_from;
 	struct page *page;
 	pgoff_t index;
+	bool skip_pinned_pages = false;
 
 	WARN_ON(to > inode->i_size);
 
@@ -871,7 +872,7 @@ void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
 	 * See clear_page_dirty_for_io() for details why set_page_dirty()
 	 * is needed.
 	 */
-	if (page_mkclean(page))
+	if (page_mkclean(page, skip_pinned_pages))
 		set_page_dirty(page);
 	unlock_page(page);
 	put_page(page);
-- 
2.18.0
