Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 92EEC6B00B7
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 17:34:04 -0400 (EDT)
Date: Mon, 7 Sep 2009 22:33:16 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 3/8] mm: add get_dump_page
In-Reply-To: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
Message-ID: <Pine.LNX.4.64.0909072231120.15430@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Howells <dhowells@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation for the next patch, add a simple get_dump_page(addr)
interface for the CONFIG_ELF_CORE dumpers to use, instead of calling
get_user_pages() directly.  They're not interested in errors: they
just want to use holes as much as possible, to save space and make
sure that the data is aligned where the headers said it would be.

Oh, and don't use that horrid DUMP_SEEK(off) macro!

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 fs/binfmt_elf.c       |   42 +++++++++---------------------
 fs/binfmt_elf_fdpic.c |   56 +++++++++++++---------------------------
 include/linux/mm.h    |    1 
 mm/memory.c           |   33 ++++++++++++++++++++++-
 4 files changed, 65 insertions(+), 67 deletions(-)

--- mm2/fs/binfmt_elf.c	2009-09-05 14:40:15.000000000 +0100
+++ mm3/fs/binfmt_elf.c	2009-09-07 13:16:32.000000000 +0100
@@ -1280,9 +1280,6 @@ static int writenote(struct memelfnote *
 #define DUMP_WRITE(addr, nr)	\
 	if ((size += (nr)) > limit || !dump_write(file, (addr), (nr))) \
 		goto end_coredump;
-#define DUMP_SEEK(off)	\
-	if (!dump_seek(file, (off))) \
-		goto end_coredump;
 
 static void fill_elf_header(struct elfhdr *elf, int segs,
 			    u16 machine, u32 flags, u8 osabi)
@@ -2024,7 +2021,8 @@ static int elf_core_dump(long signr, str
 		goto end_coredump;
 
 	/* Align to page */
-	DUMP_SEEK(dataoff - foffset);
+	if (!dump_seek(file, dataoff - foffset))
+		goto end_coredump;
 
 	for (vma = first_vma(current, gate_vma); vma != NULL;
 			vma = next_vma(vma, gate_vma)) {
@@ -2035,33 +2033,19 @@ static int elf_core_dump(long signr, str
 
 		for (addr = vma->vm_start; addr < end; addr += PAGE_SIZE) {
 			struct page *page;
-			struct vm_area_struct *tmp_vma;
+			int stop;
 
-			if (get_user_pages(current, current->mm, addr, 1, 0, 1,
-						&page, &tmp_vma) <= 0) {
-				DUMP_SEEK(PAGE_SIZE);
-			} else {
-				if (page == ZERO_PAGE(0)) {
-					if (!dump_seek(file, PAGE_SIZE)) {
-						page_cache_release(page);
-						goto end_coredump;
-					}
-				} else {
-					void *kaddr;
-					flush_cache_page(tmp_vma, addr,
-							 page_to_pfn(page));
-					kaddr = kmap(page);
-					if ((size += PAGE_SIZE) > limit ||
-					    !dump_write(file, kaddr,
-					    PAGE_SIZE)) {
-						kunmap(page);
-						page_cache_release(page);
-						goto end_coredump;
-					}
-					kunmap(page);
-				}
+			page = get_dump_page(addr);
+			if (page) {
+				void *kaddr = kmap(page);
+				stop = ((size += PAGE_SIZE) > limit) ||
+					!dump_write(file, kaddr, PAGE_SIZE);
+				kunmap(page);
 				page_cache_release(page);
-			}
+			} else
+				stop = !dump_seek(file, PAGE_SIZE);
+			if (stop)
+				goto end_coredump;
 		}
 	}
 
--- mm2/fs/binfmt_elf_fdpic.c	2009-09-05 14:40:15.000000000 +0100
+++ mm3/fs/binfmt_elf_fdpic.c	2009-09-07 13:16:32.000000000 +0100
@@ -1328,9 +1328,6 @@ static int writenote(struct memelfnote *
 #define DUMP_WRITE(addr, nr)	\
 	if ((size += (nr)) > limit || !dump_write(file, (addr), (nr))) \
 		goto end_coredump;
-#define DUMP_SEEK(off)	\
-	if (!dump_seek(file, (off))) \
-		goto end_coredump;
 
 static inline void fill_elf_fdpic_header(struct elfhdr *elf, int segs)
 {
@@ -1521,6 +1518,7 @@ static int elf_fdpic_dump_segments(struc
 			   unsigned long *limit, unsigned long mm_flags)
 {
 	struct vm_area_struct *vma;
+	int err = 0;
 
 	for (vma = current->mm->mmap; vma; vma = vma->vm_next) {
 		unsigned long addr;
@@ -1528,43 +1526,26 @@ static int elf_fdpic_dump_segments(struc
 		if (!maydump(vma, mm_flags))
 			continue;
 
-		for (addr = vma->vm_start;
-		     addr < vma->vm_end;
-		     addr += PAGE_SIZE
-		     ) {
-			struct vm_area_struct *vma;
-			struct page *page;
-
-			if (get_user_pages(current, current->mm, addr, 1, 0, 1,
-					   &page, &vma) <= 0) {
-				DUMP_SEEK(file->f_pos + PAGE_SIZE);
-			}
-			else if (page == ZERO_PAGE(0)) {
-				page_cache_release(page);
-				DUMP_SEEK(file->f_pos + PAGE_SIZE);
-			}
-			else {
-				void *kaddr;
-
-				flush_cache_page(vma, addr, page_to_pfn(page));
-				kaddr = kmap(page);
-				if ((*size += PAGE_SIZE) > *limit ||
-				    !dump_write(file, kaddr, PAGE_SIZE)
-				    ) {
-					kunmap(page);
-					page_cache_release(page);
-					return -EIO;
-				}
+		for (addr = vma->vm_start; addr < vma->vm_end;
+							addr += PAGE_SIZE) {
+			struct page *page = get_dump_page(addr);
+			if (page) {
+				void *kaddr = kmap(page);
+				*size += PAGE_SIZE;
+				if (*size > *limit)
+					err = -EFBIG;
+				else if (!dump_write(file, kaddr, PAGE_SIZE))
+					err = -EIO;
 				kunmap(page);
 				page_cache_release(page);
-			}
+			} else if (!dump_seek(file, file->f_pos + PAGE_SIZE))
+				err = -EFBIG;
+			if (err)
+				goto out;
 		}
 	}
-
-	return 0;
-
-end_coredump:
-	return -EFBIG;
+out:
+	return err;
 }
 #endif
 
@@ -1805,7 +1786,8 @@ static int elf_fdpic_core_dump(long sign
 				goto end_coredump;
 	}
 
-	DUMP_SEEK(dataoff);
+	if (!dump_seek(file, dataoff))
+		goto end_coredump;
 
 	if (elf_fdpic_dump_segments(file, &size, &limit, mm_flags) < 0)
 		goto end_coredump;
--- mm2/include/linux/mm.h	2009-09-05 14:40:16.000000000 +0100
+++ mm3/include/linux/mm.h	2009-09-07 13:16:32.000000000 +0100
@@ -832,6 +832,7 @@ int get_user_pages(struct task_struct *t
 			struct page **pages, struct vm_area_struct **vmas);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
+struct page *get_dump_page(unsigned long addr);
 
 extern int try_to_release_page(struct page * page, gfp_t gfp_mask);
 extern void do_invalidatepage(struct page *page, unsigned long offset);
--- mm2/mm/memory.c	2009-09-07 13:16:22.000000000 +0100
+++ mm3/mm/memory.c	2009-09-07 13:16:32.000000000 +0100
@@ -1424,9 +1424,40 @@ int get_user_pages(struct task_struct *t
 
 	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas);
 }
-
 EXPORT_SYMBOL(get_user_pages);
 
+/**
+ * get_dump_page() - pin user page in memory while writing it to core dump
+ * @addr: user address
+ *
+ * Returns struct page pointer of user page pinned for dump,
+ * to be freed afterwards by page_cache_release() or put_page().
+ *
+ * Returns NULL on any kind of failure - a hole must then be inserted into
+ * the corefile, to preserve alignment with its headers; and also returns
+ * NULL wherever the ZERO_PAGE, or an anonymous pte_none, has been found -
+ * allowing a hole to be left in the corefile to save diskspace.
+ *
+ * Called without mmap_sem, but after all other threads have been killed.
+ */
+#ifdef CONFIG_ELF_CORE
+struct page *get_dump_page(unsigned long addr)
+{
+	struct vm_area_struct *vma;
+	struct page *page;
+
+	if (__get_user_pages(current, current->mm, addr, 1,
+				GUP_FLAGS_FORCE, &page, &vma) < 1)
+		return NULL;
+	if (page == ZERO_PAGE(0)) {
+		page_cache_release(page);
+		return NULL;
+	}
+	flush_cache_page(vma, addr, page_to_pfn(page));
+	return page;
+}
+#endif /* CONFIG_ELF_CORE */
+
 pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
 			spinlock_t **ptl)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
