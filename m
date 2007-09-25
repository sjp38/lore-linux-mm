Message-Id: <20070925233006.824405511@sgi.com>
References: <20070925232543.036615409@sgi.com>
Date: Tue, 25 Sep 2007 16:25:49 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 06/14] is_vmalloc_addr(): Check if an address is within the vmalloc boundaries
Content-Disposition: inline; filename=vcompound_is_vmalloc_addr
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Checking if an address is a vmalloc address is done in a couple of places.
Define a common version in mm.h and replace the other checks.

Again the include structures suck. The definition of VMALLOC_START and VMALLOC_END
is not available in vmalloc.h since highmem.c cannot be included there.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 drivers/net/cxgb3/cxgb3_offload.c |    4 +---
 fs/ntfs/malloc.h                  |    3 +--
 fs/proc/kcore.c                   |    2 +-
 fs/xfs/linux-2.6/kmem.c           |    3 +--
 fs/xfs/linux-2.6/xfs_buf.c        |    3 +--
 include/linux/mm.h                |    8 ++++++++
 mm/sparse.c                       |   10 +---------
 7 files changed, 14 insertions(+), 19 deletions(-)

Index: linux-2.6.23-rc8-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/linux/mm.h	2007-09-25 15:16:53.000000000 -0700
+++ linux-2.6.23-rc8-mm1/include/linux/mm.h	2007-09-25 15:19:26.000000000 -0700
@@ -235,6 +235,14 @@ static inline int get_page_unless_zero(s
 struct page *vmalloc_to_page(const void *addr);
 unsigned long vmalloc_to_pfn(const void *addr);
 
+/* Determine if an address is within the vmalloc range */
+static inline int is_vmalloc_addr(const void *x)
+{
+	unsigned long addr = (unsigned long)x;
+
+	return addr >= VMALLOC_START && addr < VMALLOC_END;
+}
+
 static inline struct page *compound_head(struct page *page)
 {
 	if (unlikely(PageTail(page)))
Index: linux-2.6.23-rc8-mm1/mm/sparse.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/mm/sparse.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/mm/sparse.c	2007-09-25 15:19:26.000000000 -0700
@@ -362,17 +362,9 @@ static inline struct page *kmalloc_secti
 	return __kmalloc_section_memmap(nr_pages);
 }
 
-static int vaddr_in_vmalloc_area(void *addr)
-{
-	if (addr >= (void *)VMALLOC_START &&
-	    addr < (void *)VMALLOC_END)
-		return 1;
-	return 0;
-}
-
 static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
 {
-	if (vaddr_in_vmalloc_area(memmap))
+	if (is_vmalloc_addr(memmap))
 		vfree(memmap);
 	else
 		free_pages((unsigned long)memmap,
Index: linux-2.6.23-rc8-mm1/drivers/net/cxgb3/cxgb3_offload.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/drivers/net/cxgb3/cxgb3_offload.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/drivers/net/cxgb3/cxgb3_offload.c	2007-09-25 15:19:26.000000000 -0700
@@ -1060,9 +1060,7 @@ void *cxgb_alloc_mem(unsigned long size)
  */
 void cxgb_free_mem(void *addr)
 {
-	unsigned long p = (unsigned long)addr;
-
-	if (p >= VMALLOC_START && p < VMALLOC_END)
+	if (is_vmalloc_addr(addr))
 		vfree(addr);
 	else
 		kfree(addr);
Index: linux-2.6.23-rc8-mm1/fs/ntfs/malloc.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/ntfs/malloc.h	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/ntfs/malloc.h	2007-09-25 15:19:26.000000000 -0700
@@ -85,8 +85,7 @@ static inline void *ntfs_malloc_nofs_nof
 
 static inline void ntfs_free(void *addr)
 {
-	if (likely(((unsigned long)addr < VMALLOC_START) ||
-			((unsigned long)addr >= VMALLOC_END ))) {
+	if (!is_vmalloc_addr(addr)) {
 		kfree(addr);
 		/* free_page((unsigned long)addr); */
 		return;
Index: linux-2.6.23-rc8-mm1/fs/proc/kcore.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/proc/kcore.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/proc/kcore.c	2007-09-25 15:19:26.000000000 -0700
@@ -325,7 +325,7 @@ read_kcore(struct file *file, char __use
 		if (m == NULL) {
 			if (clear_user(buffer, tsz))
 				return -EFAULT;
-		} else if ((start >= VMALLOC_START) && (start < VMALLOC_END)) {
+		} else if (is_vmalloc_addr((void *)start)) {
 			char * elf_buf;
 			struct vm_struct *m;
 			unsigned long curstart = start;
Index: linux-2.6.23-rc8-mm1/fs/xfs/linux-2.6/kmem.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/xfs/linux-2.6/kmem.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/xfs/linux-2.6/kmem.c	2007-09-25 15:19:26.000000000 -0700
@@ -92,8 +92,7 @@ kmem_zalloc_greedy(size_t *size, size_t 
 void
 kmem_free(void *ptr, size_t size)
 {
-	if (((unsigned long)ptr < VMALLOC_START) ||
-	    ((unsigned long)ptr >= VMALLOC_END)) {
+	if (!is_vmalloc_addr(ptr)) {
 		kfree(ptr);
 	} else {
 		vfree(ptr);
Index: linux-2.6.23-rc8-mm1/fs/xfs/linux-2.6/xfs_buf.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/xfs/linux-2.6/xfs_buf.c	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/xfs/linux-2.6/xfs_buf.c	2007-09-25 15:19:26.000000000 -0700
@@ -696,8 +696,7 @@ static inline struct page *
 mem_to_page(
 	void			*addr)
 {
-	if (((unsigned long)addr < VMALLOC_START) ||
-	    ((unsigned long)addr >= VMALLOC_END)) {
+	if ((!is_vmalloc_addr(addr))) {
 		return virt_to_page(addr);
 	} else {
 		return vmalloc_to_page(addr);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
