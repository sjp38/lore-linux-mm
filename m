Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 0E3BC6B13F3
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 17:56:51 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/11] mm: Add get_kernel_page[s] for pinning of kernel addresses for I/O
Date: Mon,  6 Feb 2012 22:56:36 +0000
Message-Id: <1328569001-17599-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1328569001-17599-1-git-send-email-mgorman@suse.de>
References: <1328569001-17599-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

This patch adds two new APIs get_kernel_pages() and get_kernel_page()
that may be used to pin a vector of kernel addresses for IO. The initial
user is expected to be NFS for allowing pages to be written to swap
using aops->direct_IO(). Strictly speaking, swap-over-NFS only needs
to pin one page for IO but it makes sense to express the API in terms
of a vector and add a helper for pinning single pages.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/blk_types.h |    2 +
 include/linux/fs.h        |    2 +
 include/linux/mm.h        |    4 +++
 mm/memory.c               |   53 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index 4053cbd..1e62642 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -150,6 +150,7 @@ enum rq_flag_bits {
 	__REQ_FLUSH_SEQ,	/* request for flush sequence */
 	__REQ_IO_STAT,		/* account I/O stat */
 	__REQ_MIXED_MERGE,	/* merge of different types, fail separately */
+	__REQ_KERNEL, 		/* direct IO to kernel pages */
 	__REQ_NR_BITS,		/* stops here */
 };
 
@@ -191,5 +192,6 @@ enum rq_flag_bits {
 #define REQ_IO_STAT		(1 << __REQ_IO_STAT)
 #define REQ_MIXED_MERGE		(1 << __REQ_MIXED_MERGE)
 #define REQ_SECURE		(1 << __REQ_SECURE)
+#define REQ_KERNEL		(1 << __REQ_KERNEL)
 
 #endif /* __LINUX_BLK_TYPES_H */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 5031625..4888f18 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -161,6 +161,8 @@ struct inodes_stat_t {
 #define READ			0
 #define WRITE			RW_MASK
 #define READA			RWA_MASK
+#define KERNEL_READ		(READ|REQ_KERNEL)
+#define KERNEL_WRITE		(WRITE|REQ_KERNEL)
 
 #define READ_SYNC		(READ | REQ_SYNC)
 #define WRITE_SYNC		(WRITE | REQ_SYNC | REQ_NOIDLE)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ac90729..250fe61 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1022,6 +1022,10 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
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
index fa2f04e..ff60ade 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1825,6 +1825,59 @@ next_page:
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
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
