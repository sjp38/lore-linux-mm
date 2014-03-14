Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id CBE8B6B005C
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 11:54:14 -0400 (EDT)
Received: by mail-bk0-f45.google.com with SMTP id na10so206860bkb.18
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 08:54:14 -0700 (PDT)
Received: from faui40.informatik.uni-erlangen.de (faui40.informatik.uni-erlangen.de. [2001:638:a000:4134::ffff:40])
        by mx.google.com with ESMTPS id qj10si2732131bkb.56.2014.03.14.08.54.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 08:54:13 -0700 (PDT)
From: Matthias Wirth <matthias.wirth@gmail.com>
Subject: [PATCHv3] mm: implement POSIX_FADV_NOREUSE
Date: Fri, 14 Mar 2014 16:52:38 +0100
Message-Id: <1394812370-13454-1-git-send-email-matthias.wirth@gmail.com>
In-Reply-To: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
References: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Wirth <matthias.wirth@gmail.com>
Cc: Lukas Senger <lukas@fridolin.com>, i4passt@lists.cs.fau.de, Dave Hansen <dave.hansen@linux.intel.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Bob Liu <bob.liu@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rafael Aquini <aquini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Backups, logrotation and indexers don't need files they read to remain
in the page cache. Their pages can be reclaimed early and should not
displace useful pages. POSIX specifices the POSIX_FADV_NOREUSE flag for
these use cases but it's currently a noop.

Using DONTNEED is not a good solution: It means the application will
throw out its pages even if they are used by other processes. If the
application wants to be more polite it needs a way to find out whether
thats the case. One way is to use mincore to get a snapshot of pages
before mmaping the file and then keeping pages that were already cached
before we accessed them. This of course ignores all accesses by other
processes occuring while we use the file and doesn't work with read.

The idea of the patch is to add pages from files with FMODE_NOREUSE at
the tail of the lru list. Therefore these pages are the first to be
reclaimed. We added add_to_page_cache_lru_tail and corresponding
functions, complementing add_to_page_cache_lru.

Our implementation on the other hand is alot easier to implement for
userspace as you only need to call posix_fadvise once after each open.
We currently ignore ranges and apply it to the complete file, which
should cover most usecases. Range functionality can be added with a
list/tree of ranges in the filp.

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
 include/linux/pagemap.h   |  2 ++
 include/linux/pagevec.h   |  1 +
 include/linux/swap.h      |  8 ++++++++
 mm/fadvise.c              |  4 ++++
 mm/filemap.c              | 27 ++++++++++++++++++++++--
 mm/readahead.c            | 20 ++++++++++++++----
 mm/swap.c                 | 52 +++++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 120 insertions(+), 6 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 4f59e18..0c1b031 100644
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
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 532cedc..0191357 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -575,6 +575,8 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
+int add_to_page_cache_lru_tail(struct page *page, struct address_space *mapping,
+				pgoff_t index, gfp_t gfp_mask);
 extern void delete_from_page_cache(struct page *page);
 extern void __delete_from_page_cache(struct page *page, void *shadow);
 int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
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
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3507115..c6bb26f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -309,7 +309,9 @@ extern unsigned long nr_free_pagecache_pages(void);
 
 /* linux/mm/swap.c */
 extern void __lru_cache_add(struct page *);
+extern void __lru_cache_add_tail(struct page *);
 extern void lru_cache_add(struct page *);
+extern void lru_cache_add_tail(struct page *);
 extern void lru_add_page_tail(struct page *page, struct page *page_tail,
 			 struct lruvec *lruvec, struct list_head *head);
 extern void activate_page(struct page *);
@@ -339,6 +341,12 @@ static inline void lru_cache_add_file(struct page *page)
 	__lru_cache_add(page);
 }
 
+static inline void lru_cache_add_tail_file(struct page *page)
+{
+	ClearPageActive(page);
+	__lru_cache_add_tail(page);
+}
+
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
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
index 97474c1..49b488a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -642,6 +642,23 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 }
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
+/*
+ * Pages added to the tail are less important and should not be activated even
+ * if they were recently accessed. Therefore we behave different from
+ * add_to_page_cache_lru.
+ */
+int add_to_page_cache_lru_tail(struct page *page, struct address_space *mapping,
+				pgoff_t offset, gfp_t gfp_mask)
+{
+	int ret;
+
+	ret = add_to_page_cache(page, mapping, offset, gfp_mask);
+	if (ret == 0)
+		lru_cache_add_tail_file(page);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(add_to_page_cache_lru_tail);
+
 #ifdef CONFIG_NUMA
 struct page *__page_cache_alloc(gfp_t gfp)
 {
@@ -1630,8 +1647,14 @@ no_cached_page:
 			desc->error = -ENOMEM;
 			goto out;
 		}
-		error = add_to_page_cache_lru(page, mapping,
-						index, GFP_KERNEL);
+
+		if (unlikely(filp->f_mode & FMODE_NOREUSE)) {
+			error = add_to_page_cache_lru_tail(page, mapping,
+							index, GFP_KERNEL);
+		} else {
+			error = add_to_page_cache_lru(page, mapping,
+							index, GFP_KERNEL);
+		}
 		if (error) {
 			page_cache_release(page);
 			if (error == -EEXIST)
diff --git a/mm/readahead.c b/mm/readahead.c
index 29c5e1a..749df01 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -117,7 +117,13 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 
 	blk_start_plug(&plug);
 
-	if (mapping->a_ops->readpages) {
+	/*
+	 * If the file was marked POSIX_FADV_NOREUSE we call need to call
+	 * add_to_page_cache_lru_tail on it so that it's added to the tail of
+	 * the LRU further along the way. This is not possible in
+	 * mpage_readpages as there is no filp there.
+	 */
+	if (mapping->a_ops->readpages && !(filp->f_mode & FMODE_NOREUSE)) {
 		ret = mapping->a_ops->readpages(filp, mapping, pages, nr_pages);
 		/* Clean up the remaining pages */
 		put_pages_list(pages);
@@ -127,10 +133,16 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 	for (page_idx = 0; page_idx < nr_pages; page_idx++) {
 		struct page *page = list_to_page(pages);
 		list_del(&page->lru);
-		if (!add_to_page_cache_lru(page, mapping,
-					page->index, GFP_KERNEL)) {
-			mapping->a_ops->readpage(filp, page);
+
+		if (unlikely(filp->f_mode & FMODE_NOREUSE)) {
+			ret = add_to_page_cache_lru_tail(page, mapping,
+					page->index, GFP_KERNEL);
+		} else {
+			ret = add_to_page_cache_lru(page, mapping,
+					page->index, GFP_KERNEL);
 		}
+		if (!ret)
+			mapping->a_ops->readpage(filp, page);
 		page_cache_release(page);
 	}
 	ret = 0;
diff --git a/mm/swap.c b/mm/swap.c
index f4d5f59..ebf2d2c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -41,6 +41,7 @@
 int page_cluster;
 
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
+static DEFINE_PER_CPU(struct pagevec, lru_add_tail_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
@@ -600,6 +601,22 @@ void __lru_cache_add(struct page *page)
 }
 EXPORT_SYMBOL(__lru_cache_add);
 
+/*
+ * Same as __lru_cache_add but add to tail.
+ */
+
+void __lru_cache_add_tail(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_tail_pvec);
+
+	page_cache_get(page);
+	if (!pagevec_space(pvec))
+		__pagevec_lru_add_tail(pvec);
+	pagevec_add(pvec, page);
+	put_cpu_var(lru_add_tail_pvec);
+}
+EXPORT_SYMBOL(__lru_cache_add_tail);
+
 /**
  * lru_cache_add - add a page to a page list
  * @page: the page to be added to the LRU.
@@ -612,6 +629,17 @@ void lru_cache_add(struct page *page)
 }
 
 /**
+ * lru_cache_add_tail - add a page to a page list at the tail
+ * @page: the page to be added to the tail of the LRU.
+ */
+void lru_cache_add_tail(struct page *page)
+{
+	VM_BUG_ON_PAGE(PageActive(page) && PageUnevictable(page), page);
+	VM_BUG_ON_PAGE(PageLRU(page), page);
+	__lru_cache_add_tail(page);
+}
+
+/**
  * add_page_to_unevictable_list - add a page to the unevictable list
  * @page:  the page to be added to the unevictable list
  *
@@ -939,6 +967,21 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
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
@@ -949,6 +992,15 @@ void __pagevec_lru_add(struct pagevec *pvec)
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
