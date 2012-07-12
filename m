Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 029506B0095
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:41:19 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/12] mm: Add get_kernel_page[s] for pinning of kernel addresses for I/O
Date: Thu, 12 Jul 2012 07:41:00 +0100
Message-Id: <1342075266-29593-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075266-29593-1-git-send-email-mgorman@suse.de>
References: <1342075266-29593-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

This patch adds two new APIs get_kernel_pages() and get_kernel_page()
that may be used to pin a vector of kernel addresses for IO. The initial
user is expected to be NFS for allowing pages to be written to swap
using aops->direct_IO(). Strictly speaking, swap-over-NFS only needs
to pin one page for IO but it makes sense to express the API in terms
of a vector and add a helper for pinning single pages.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/blk_types.h |    2 ++
 include/linux/fs.h        |    2 ++
 include/linux/mm.h        |    4 ++++
 mm/memory.c               |   53 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 61 insertions(+)

diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index 0edb65d..7b7ac9c 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -160,6 +160,7 @@ enum rq_flag_bits {
 	__REQ_FLUSH_SEQ,	/* request for flush sequence */
 	__REQ_IO_STAT,		/* account I/O stat */
 	__REQ_MIXED_MERGE,	/* merge of different types, fail separately */
+	__REQ_KERNEL, 		/* direct IO to kernel pages */
 	__REQ_NR_BITS,		/* stops here */
 };
 
@@ -201,5 +202,6 @@ enum rq_flag_bits {
 #define REQ_IO_STAT		(1 << __REQ_IO_STAT)
 #define REQ_MIXED_MERGE		(1 << __REQ_MIXED_MERGE)
 #define REQ_SECURE		(1 << __REQ_SECURE)
+#define REQ_KERNEL		(1 << __REQ_KERNEL)
 
 #endif /* __LINUX_BLK_TYPES_H */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6d269ba..019f5b8 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -165,6 +165,8 @@ struct inodes_stat_t {
 #define READ			0
 #define WRITE			RW_MASK
 #define READA			RWA_MASK
+#define KERNEL_READ		(READ|REQ_KERNEL)
+#define KERNEL_WRITE		(WRITE|REQ_KERNEL)
 
 #define READ_SYNC		(READ | REQ_SYNC)
 #define WRITE_SYNC		(WRITE | REQ_SYNC | REQ_NOIDLE)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b3d4cd9..bbb3167 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1019,6 +1019,10 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			struct page **pages, struct vm_area_struct **vmas);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
+struct kvec;
+int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
+			struct page **pages);
+int get_kernel_page(unsigned long start, int write, struct page **pages);
 struct page *get_dump_page(unsigned long addr);
 
 extern int try_to_release_page(struct page * page, gfp_t gfp_mask);
diff --git a/mm/memory.c b/mm/memory.c
index 8e298f5..85705cd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1843,6 +1843,59 @@ next_page:
 EXPORT_SYMBOL(__get_user_pages);
 
 /*
+ * get_kernel_pages() - pin kernel pages in memory
+ * @kiov:	An array of struct kvec structures
+ * @nr_segs:	number of segments to pin
+ * @write:	pinning for read/write, currently ignored
+ * @pages:	array that receives pointers to the pages pinned.
+ *		Should be at least nr_segs long.
+ *
+ * Returns number of pages pinned. This may be fewer than the number
+ * requested. If nr_pages is 0 or negative, returns 0. If no pages
+ * were pinned, returns -errno. Each page returned must be released
+ * with a put_page() call when it is finished with.
+ */
+int get_kernel_pages(const struct kvec *kiov, int nr_segs, int write,
+		struct page **pages)
+{
+	int seg;
+
+	for (seg = 0; seg < nr_segs; seg++) {
+		if (WARN_ON(kiov[seg].iov_len != PAGE_SIZE))
+			return seg;
+
+		/* virt_to_page sanity checks the PFN */
+		pages[seg] = virt_to_page(kiov[seg].iov_base);
+		page_cache_get(pages[seg]);
+	}
+
+	return seg;
+}
+EXPORT_SYMBOL_GPL(get_kernel_pages);
+
+/*
+ * get_kernel_page() - pin a kernel page in memory
+ * @start:	starting kernel address
+ * @write:	pinning for read/write, currently ignored
+ * @pages:	array that receives pointer to the page pinned.
+ *		Must be at least nr_segs long.
+ *
+ * Returns 1 if page is pinned. If the page was not pinned, returns
+ * -errno. The page returned must be released with a put_page() call
+ * when it is finished with.
+ */
+int get_kernel_page(unsigned long start, int write, struct page **pages)
+{
+	const struct kvec kiov = {
+		.iov_base = (void *)start,
+		.iov_len = PAGE_SIZE
+	};
+
+	return get_kernel_pages(&kiov, 1, write, pages);
+}
+EXPORT_SYMBOL_GPL(get_kernel_page);
+
+/*
  * fixup_user_fault() - manually resolve a user page fault
  * @tsk:	the task_struct to use for page fault accounting, or
  *		NULL if faults are not to be recorded.
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
