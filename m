Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5666B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 14:45:27 -0400 (EDT)
Received: by mail-bk0-f47.google.com with SMTP id w10so107781bkz.34
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 11:45:26 -0700 (PDT)
Received: from faui40.informatik.uni-erlangen.de (faui40.informatik.uni-erlangen.de. [2001:638:a000:4134::ffff:40])
        by mx.google.com with ESMTPS id oh7si1509828bkb.213.2014.03.13.11.45.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 11:45:25 -0700 (PDT)
From: Matthias Wirth <matthias.wirth@gmail.com>
Subject: [PATCHv2] mm: implement POSIX_FADV_NOREUSE
Date: Thu, 13 Mar 2014 19:43:41 +0100
Message-Id: <1394736229-30684-1-git-send-email-matthias.wirth@gmail.com>
In-Reply-To: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
References: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Wirth <matthias.wirth@gmail.com>
Cc: Lukas Senger <lukas@fridolin.com>, i4passt@lists.cs.fau.de, Dave Hansen <dave.hansen@linux.intel.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Backups, logrotation and indexers don't need files they read to remain
in the page cache. Their pages can be reclaimed early and should not
displace useful pages. POSIX specifices the POSIX_FADV_NOREUSE flag for
these use cases but it's currently a noop.

Pages coming from files with FMODE_NOREUSE that are to be added to the
page cache via add_to_page_cache_lru get their page struct pointer saved
in a per_cpu variable which gets checked further along the way in
__lru_cache_add. If the variable is set they get added to the new
lru_add_tail_pvec which as a whole later gets added to the tail of the
LRU list. Therefore these pages are the first to be reclaimed.

It might happen that a page is brought in via readahead for a file that
has NOREUSE set and is then requested by another process. This can lead
to the page being dropped from the page cache earlier even though the
competing process still needs it. The impact of this however, is small
as the likelihood of the page getting dropped is reduced because it
probably moves to the active list when the page is accessed by the
second process.

Signed-off-by: Matthias Wirth <matthias.wirth@gmail.com>
Signed-off-by: Lukas Senger <lukas@fridolin.com>
---
 include/linux/fs.h        |  3 +++
 include/linux/mm_inline.h |  9 ++++++++
 include/linux/pagevec.h   |  1 +
 mm/fadvise.c              |  4 ++++
 mm/filemap.c              |  7 +++++++
 mm/readahead.c            | 14 ++++++++++++-
 mm/swap.c                 | 52 ++++++++++++++++++++++++++++++++++++++++++-----
 7 files changed, 84 insertions(+), 6 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 42b70bc..68ccf93 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -126,6 +126,9 @@ typedef void (dio_iodone_t)(struct kiocb *iocb, loff_t offset,
 /* File needs atomic accesses to f_pos */
 #define FMODE_ATOMIC_POS	((__force fmode_t)0x8000)
 
+/* Expect one read only (effect on page cache behavior) */
+#define FMODE_NOREUSE		((__force fmode_t)0x10000)
+
 /* File was opened by fanotify and shouldn't generate fanotify events */
 #define FMODE_NONOTIFY		((__force fmode_t)0x1000000)
 
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index cf55945..11347f7 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -31,6 +31,15 @@ static __always_inline void add_page_to_lru_list(struct page *page,
 	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
 }
 
+static __always_inline void add_page_to_lru_list_tail(struct page *page,
+				struct lruvec *lruvec, enum lru_list lru)
+{
+	int nr_pages = hpage_nr_pages(page);
+	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
+	list_add_tail(&page->lru, &lruvec->lists[lru]);
+	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
+}
+
 static __always_inline void del_page_from_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 3c6b8b1..d1d3223 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -22,6 +22,7 @@ struct pagevec {
 
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec);
+void __pagevec_lru_add_tail(struct pagevec *pvec);
 unsigned __pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 			  pgoff_t start, unsigned nr_pages, pgoff_t *indices);
 void pagevec_remove_exceptionals(struct pagevec *pvec);
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 3bcfd81..387d10a 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -80,6 +80,7 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 		f.file->f_ra.ra_pages = bdi->ra_pages;
 		spin_lock(&f.file->f_lock);
 		f.file->f_mode &= ~FMODE_RANDOM;
+		f.file->f_mode &= ~FMODE_NOREUSE;
 		spin_unlock(&f.file->f_lock);
 		break;
 	case POSIX_FADV_RANDOM:
@@ -111,6 +112,9 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 					   nrpages);
 		break;
 	case POSIX_FADV_NOREUSE:
+		spin_lock(&f.file->f_lock);
+		f.file->f_mode |= FMODE_NOREUSE;
+		spin_unlock(&f.file->f_lock);
 		break;
 	case POSIX_FADV_DONTNEED:
 		if (!bdi_write_congested(mapping->backing_dev_info))
diff --git a/mm/filemap.c b/mm/filemap.c
index 97474c1..54d1aaa 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -39,6 +39,8 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/filemap.h>
 
+DECLARE_PER_CPU(struct page*, noreuse_page);
+
 /*
  * FIXME: remove all knowledge of the buffer layer from the core VM
  */
@@ -1630,6 +1632,11 @@ no_cached_page:
 			desc->error = -ENOMEM;
 			goto out;
 		}
+		if (filp->f_mode & FMODE_NOREUSE) {
+			get_cpu_var(noreuse_page) = page;
+			put_cpu_var(noreuse_page);
+		}
+
 		error = add_to_page_cache_lru(page, mapping,
 						index, GFP_KERNEL);
 		if (error) {
diff --git a/mm/readahead.c b/mm/readahead.c
index 29c5e1a..61fd79e 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -20,6 +20,8 @@
 #include <linux/syscalls.h>
 #include <linux/file.h>
 
+DECLARE_PER_CPU(struct page*, noreuse_page);
+
 /*
  * Initialise a struct file's readahead state.  Assumes that the caller has
  * memset *ra to zero.
@@ -117,7 +119,13 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 
 	blk_start_plug(&plug);
 
-	if (mapping->a_ops->readpages) {
+	/*
+	 * If the file was marked NOREUSE we need to save a page in
+	 * noreuse_page before calling add_to_page_cache_lru on it so that it's
+	 * added to the tail of the LRU further along the way. This is not
+	 * possible in mpage_readpages as there is no filp there.
+	 */
+	if (mapping->a_ops->readpages && !(filp->f_mode & FMODE_NOREUSE)) {
 		ret = mapping->a_ops->readpages(filp, mapping, pages, nr_pages);
 		/* Clean up the remaining pages */
 		put_pages_list(pages);
@@ -127,6 +135,10 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 	for (page_idx = 0; page_idx < nr_pages; page_idx++) {
 		struct page *page = list_to_page(pages);
 		list_del(&page->lru);
+		if (filp->f_mode & FMODE_NOREUSE) {
+			get_cpu_var(noreuse_page) = page;
+			put_cpu_var(noreuse_page);
+		}
 		if (!add_to_page_cache_lru(page, mapping,
 					page->index, GFP_KERNEL)) {
 			mapping->a_ops->readpage(filp, page);
diff --git a/mm/swap.c b/mm/swap.c
index f4d5f59..8cef7ac 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -41,8 +41,10 @@
 int page_cluster;
 
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
+static DEFINE_PER_CPU(struct pagevec, lru_add_tail_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
+DEFINE_PER_CPU(struct page*, noreuse_page);
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -587,16 +589,32 @@ EXPORT_SYMBOL(mark_page_accessed);
  * to add the page to the [in]active [file|anon] list is deferred until the
  * pagevec is drained. This gives a chance for the caller of __lru_cache_add()
  * have the page added to the active list using mark_page_accessed().
+ *
+ * If the the page was marked noreuse by posix_fadvise it is added to the tail
+ * of the LRU via the lru_add_tail_pvec.
  */
 void __lru_cache_add(struct page *page)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
+	struct pagevec *pvec;
+	struct page *noreuse = get_cpu_var(noreuse_page);
 
 	page_cache_get(page);
-	if (!pagevec_space(pvec))
-		__pagevec_lru_add(pvec);
-	pagevec_add(pvec, page);
-	put_cpu_var(lru_add_pvec);
+
+	if (noreuse == page) {
+		pvec = &get_cpu_var(lru_add_tail_pvec);
+		if (!pagevec_space(pvec))
+			__pagevec_lru_add_tail(pvec);
+		pagevec_add(pvec, page);
+		put_cpu_var(lru_add_tail_pvec);
+	} else {
+		pvec = &get_cpu_var(lru_add_pvec);
+		if (!pagevec_space(pvec))
+			__pagevec_lru_add(pvec);
+		pagevec_add(pvec, page);
+		put_cpu_var(lru_add_pvec);
+	}
+	noreuse = NULL;
+	put_cpu_var(noreuse_page);
 }
 EXPORT_SYMBOL(__lru_cache_add);
 
@@ -939,6 +957,21 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 	trace_mm_lru_insertion(page, page_to_pfn(page), lru, trace_pagemap_flags(page));
 }
 
+static void __pagevec_lru_add_tail_fn(struct page *page, struct lruvec *lruvec,
+				 void *arg)
+{
+	int file = page_is_file_cache(page);
+	int active = PageActive(page);
+	enum lru_list lru = page_lru(page);
+
+	VM_BUG_ON_PAGE(PageLRU(page), page);
+
+	SetPageLRU(page);
+	add_page_to_lru_list_tail(page, lruvec, lru);
+	update_page_reclaim_stat(lruvec, file, active);
+	trace_mm_lru_insertion(page, page_to_pfn(page), lru, trace_pagemap_flags(page));
+}
+
 /*
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
@@ -949,6 +982,15 @@ void __pagevec_lru_add(struct pagevec *pvec)
 }
 EXPORT_SYMBOL(__pagevec_lru_add);
 
+/*
+ * Same as __pagevec_lru_add, but pages are added to the tail of the LRU.
+ */
+void __pagevec_lru_add_tail(struct pagevec *pvec)
+{
+	pagevec_lru_move_fn(pvec, __pagevec_lru_add_tail_fn, NULL);
+}
+EXPORT_SYMBOL(__pagevec_lru_add_tail);
+
 /**
  * __pagevec_lookup - gang pagecache lookup
  * @pvec:	Where the resulting entries are placed
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
