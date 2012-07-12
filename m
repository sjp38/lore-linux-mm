Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 9274F6B004D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:41:21 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/12] mm: Add support for direct_IO to highmem pages
Date: Thu, 12 Jul 2012 07:41:01 +0100
Message-Id: <1342075266-29593-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075266-29593-1-git-send-email-mgorman@suse.de>
References: <1342075266-29593-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

The patch "mm: Add support for a filesystem to activate swap files and
use direct_IO for writing swap pages" added support for using direct_IO
to write swap pages but it is insufficient for highmem pages.

To support highmem pages, this patch kmaps() the page before calling the
direct_IO() handler. As direct_IO deals with virtual addresses an
additional helper is necessary for get_kernel_pages() to lookup the
struct page for a kmap virtual address.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/linux/highmem.h |    7 +++++++
 mm/highmem.c            |   12 ++++++++++++
 mm/memory.c             |    3 +--
 mm/page_io.c            |    3 ++-
 4 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 774fa47..ef788b5 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -39,10 +39,17 @@ extern unsigned long totalhigh_pages;
 
 void kmap_flush_unused(void);
 
+struct page *kmap_to_page(void *addr);
+
 #else /* CONFIG_HIGHMEM */
 
 static inline unsigned int nr_free_highpages(void) { return 0; }
 
+static inline struct page *kmap_to_page(void *addr)
+{
+	return virt_to_page(addr);
+}
+
 #define totalhigh_pages 0UL
 
 #ifndef ARCH_HAS_KMAP
diff --git a/mm/highmem.c b/mm/highmem.c
index 57d82c6..d517cd1 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -94,6 +94,18 @@ static DECLARE_WAIT_QUEUE_HEAD(pkmap_map_wait);
 		do { spin_unlock(&kmap_lock); (void)(flags); } while (0)
 #endif
 
+struct page *kmap_to_page(void *vaddr)
+{
+	unsigned long addr = (unsigned long)vaddr;
+
+	if (addr >= PKMAP_ADDR(0) && addr <= PKMAP_ADDR(LAST_PKMAP)) {
+		int i = (addr - PKMAP_ADDR(0)) >> PAGE_SHIFT;
+		return pte_page(pkmap_page_table[i]);
+	}
+
+	return virt_to_page(addr);
+}
+
 static void flush_all_zero_pkmaps(void)
 {
 	int i;
diff --git a/mm/memory.c b/mm/memory.c
index 85705cd..ed1981f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1864,8 +1864,7 @@ int get_kernel_pages(const struct kvec *kiov, int nr_segs, int write,
 		if (WARN_ON(kiov[seg].iov_len != PAGE_SIZE))
 			return seg;
 
-		/* virt_to_page sanity checks the PFN */
-		pages[seg] = virt_to_page(kiov[seg].iov_base);
+		pages[seg] = kmap_to_page(kiov[seg].iov_base);
 		page_cache_get(pages[seg]);
 	}
 
diff --git a/mm/page_io.c b/mm/page_io.c
index 4a37962..78eee32 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -205,7 +205,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 		struct file *swap_file = sis->swap_file;
 		struct address_space *mapping = swap_file->f_mapping;
 		struct iovec iov = {
-			.iov_base = page_address(page),
+			.iov_base = kmap(page),
 			.iov_len  = PAGE_SIZE,
 		};
 
@@ -218,6 +218,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 		ret = mapping->a_ops->direct_IO(KERNEL_WRITE,
 						&kiocb, &iov,
 						kiocb.ki_pos, 1);
+		kunmap(page);
 		if (ret == PAGE_SIZE) {
 			count_vm_event(PSWPOUT);
 			ret = 0;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
