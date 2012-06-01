Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 0D4226B0069
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 12:55:49 -0400 (EDT)
Received: from euspt2 (mailout3.w1.samsung.com [210.118.77.13])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M4Y000HU722CXB0@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 01 Jun 2012 17:56:26 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4Y009D270Y3R@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 01 Jun 2012 17:55:46 +0100 (BST)
Date: Fri, 01 Jun 2012 18:54:25 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 1/3] proc: add /proc/kpageorder interface
Message-id: <201206011854.25795.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] proc: add /proc/kpageorder interface

This makes page order information available to the user-space.

Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 fs/proc/page.c              |   48 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h          |   11 ++++++++++
 kernel/events/internal.h    |    8 +++----
 kernel/events/ring_buffer.c |   10 ++++-----
 mm/internal.h               |   11 ----------
 5 files changed, 68 insertions(+), 20 deletions(-)

Index: b/fs/proc/page.c
===================================================================
--- a/fs/proc/page.c	2012-05-31 16:24:12.323109710 +0200
+++ b/fs/proc/page.c	2012-05-31 16:33:35.819109657 +0200
@@ -207,10 +207,58 @@ static const struct file_operations proc
 	.read = kpageflags_read,
 };
 
+static ssize_t kpageorder_read(struct file *file, char __user *buf,
+			     size_t count, loff_t *ppos)
+{
+	u64 __user *out = (u64 __user *)buf;
+	struct page *ppage;
+	unsigned long src = *ppos;
+	unsigned long pfn;
+	ssize_t ret = 0;
+	u64 porder;
+
+	pfn = src / KPMSIZE;
+	count = min_t(unsigned long, count,
+		      ((ARCH_PFN_OFFSET + max_pfn) * KPMSIZE) - src);
+	if (src & KPMMASK || count & KPMMASK)
+		return -EINVAL;
+
+	while (count > 0) {
+		if (pfn_valid(pfn))
+			ppage = pfn_to_page(pfn);
+		else
+			ppage = NULL;
+		if (!ppage || !PageBuddy(ppage))
+			porder = 0;
+		else
+			porder = page_order(ppage);
+
+		if (put_user(porder, out)) {
+			ret = -EFAULT;
+			break;
+		}
+
+		pfn++;
+		out++;
+		count -= KPMSIZE;
+	}
+
+	*ppos += (char __user *)out - buf;
+	if (!ret)
+		ret = (char __user *)out - buf;
+	return ret;
+}
+
+static const struct file_operations proc_kpageorder_operations = {
+	.llseek = mem_lseek,
+	.read = kpageorder_read,
+};
+
 static int __init proc_page_init(void)
 {
 	proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
 	proc_create("kpageflags", S_IRUSR, NULL, &proc_kpageflags_operations);
+	proc_create("kpageorder", S_IRUSR, NULL, &proc_kpageorder_operations);
 	return 0;
 }
 module_init(proc_page_init);
Index: b/include/linux/mm.h
===================================================================
--- a/include/linux/mm.h	2012-05-31 16:24:12.295109717 +0200
+++ b/include/linux/mm.h	2012-05-31 16:30:49.215109568 +0200
@@ -250,6 +250,17 @@ struct inode;
 #define set_page_private(page, v)	((page)->private = (v))
 
 /*
+ * function for dealing with page's order in buddy system.
+ * zone->lock is already acquired when we use these.
+ * So, we don't need atomic page->flags operations here.
+ */
+static inline unsigned long page_order(struct page *page)
+{
+	/* PageBuddy() must be checked by the caller */
+	return page_private(page);
+}
+
+/*
  * FIXME: take this include out, include page-flags.h in
  * files which need it (119 of them)
  */
Index: b/kernel/events/internal.h
===================================================================
--- a/kernel/events/internal.h	2012-05-31 16:24:12.307109719 +0200
+++ b/kernel/events/internal.h	2012-05-31 16:30:49.215109568 +0200
@@ -58,14 +58,14 @@ perf_mmap_to_page(struct ring_buffer *rb
  * Required for architectures that have d-cache aliasing issues.
  */
 
-static inline int page_order(struct ring_buffer *rb)
+static inline int rb_page_order(struct ring_buffer *rb)
 {
 	return rb->page_order;
 }
 
 #else
 
-static inline int page_order(struct ring_buffer *rb)
+static inline int rb_page_order(struct ring_buffer *rb)
 {
 	return 0;
 }
@@ -73,7 +73,7 @@ static inline int page_order(struct ring
 
 static inline unsigned long perf_data_size(struct ring_buffer *rb)
 {
-	return rb->nr_pages << (PAGE_SHIFT + page_order(rb));
+	return rb->nr_pages << (PAGE_SHIFT + rb_page_order(rb));
 }
 
 static inline void
@@ -95,7 +95,7 @@ __output_copy(struct perf_output_handle 
 			handle->page++;
 			handle->page &= rb->nr_pages - 1;
 			handle->addr = rb->data_pages[handle->page];
-			handle->size = PAGE_SIZE << page_order(rb);
+			handle->size = PAGE_SIZE << rb_page_order(rb);
 		}
 	} while (len);
 }
Index: b/kernel/events/ring_buffer.c
===================================================================
--- a/kernel/events/ring_buffer.c	2012-05-31 16:24:12.315109715 +0200
+++ b/kernel/events/ring_buffer.c	2012-05-31 16:30:49.215109568 +0200
@@ -154,12 +154,12 @@ int perf_output_begin(struct perf_output
 	if (head - local_read(&rb->wakeup) > rb->watermark)
 		local_add(rb->watermark, &rb->wakeup);
 
-	handle->page = offset >> (PAGE_SHIFT + page_order(rb));
+	handle->page = offset >> (PAGE_SHIFT + rb_page_order(rb));
 	handle->page &= rb->nr_pages - 1;
-	handle->size = offset & ((PAGE_SIZE << page_order(rb)) - 1);
+	handle->size = offset & ((PAGE_SIZE << rb_page_order(rb)) - 1);
 	handle->addr = rb->data_pages[handle->page];
 	handle->addr += handle->size;
-	handle->size = (PAGE_SIZE << page_order(rb)) - handle->size;
+	handle->size = (PAGE_SIZE << rb_page_order(rb)) - handle->size;
 
 	if (have_lost) {
 		lost_event.header.type = PERF_RECORD_LOST;
@@ -310,7 +310,7 @@ void rb_free(struct ring_buffer *rb)
 struct page *
 perf_mmap_to_page(struct ring_buffer *rb, unsigned long pgoff)
 {
-	if (pgoff > (1UL << page_order(rb)))
+	if (pgoff > (1UL << rb_page_order(rb)))
 		return NULL;
 
 	return vmalloc_to_page((void *)rb->user_page + pgoff * PAGE_SIZE);
@@ -330,7 +330,7 @@ static void rb_free_work(struct work_str
 	int i, nr;
 
 	rb = container_of(work, struct ring_buffer, work);
-	nr = 1 << page_order(rb);
+	nr = 1 << rb_page_order(rb);
 
 	base = rb->user_page;
 	for (i = 0; i < nr + 1; i++)
Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h	2012-05-31 16:24:12.299109722 +0200
+++ b/mm/internal.h	2012-05-31 16:30:49.215109568 +0200
@@ -141,17 +141,6 @@ isolate_migratepages_range(struct zone *
 
 #endif
 
-/*
- * function for dealing with page's order in buddy system.
- * zone->lock is already acquired when we use these.
- * So, we don't need atomic page->flags operations here.
- */
-static inline unsigned long page_order(struct page *page)
-{
-	/* PageBuddy() must be checked by the caller */
-	return page_private(page);
-}
-
 /* mm/util.c */
 void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev, struct rb_node *rb_parent);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
