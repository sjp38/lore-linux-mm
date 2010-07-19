Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DF6F0600800
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 11:31:21 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v5 06/12] Add get_user_pages() variant that fails if major fault is required.
Date: Mon, 19 Jul 2010 18:30:56 +0300
Message-Id: <1279553462-7036-7-git-send-email-gleb@redhat.com>
In-Reply-To: <1279553462-7036-1-git-send-email-gleb@redhat.com>
References: <1279553462-7036-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

This patch add get_user_pages() variant that only succeeds if getting
a reference to a page doesn't require major fault.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 fs/ncpfs/mmap.c    |    2 ++
 include/linux/mm.h |    5 +++++
 mm/filemap.c       |    3 +++
 mm/memory.c        |   31 ++++++++++++++++++++++++++++---
 mm/shmem.c         |    8 +++++++-
 5 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/fs/ncpfs/mmap.c b/fs/ncpfs/mmap.c
index 56f5b3a..b9c4f36 100644
--- a/fs/ncpfs/mmap.c
+++ b/fs/ncpfs/mmap.c
@@ -39,6 +39,8 @@ static int ncp_file_mmap_fault(struct vm_area_struct *area,
 	int bufsize;
 	int pos; /* XXX: loff_t ? */
 
+	if (vmf->flags & FAULT_FLAG_MINOR)
+		return VM_FAULT_MAJOR | VM_FAULT_ERROR;
 	/*
 	 * ncpfs has nothing against high pages as long
 	 * as recvmsg and memset works on it
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4238a9c..2bfc85a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -140,6 +140,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
 #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
 #define FAULT_FLAG_MKWRITE	0x04	/* Fault was mkwrite of existing pte */
+#define FAULT_FLAG_MINOR	0x08	/* Do only minor fault */
 
 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
@@ -843,6 +844,9 @@ extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			unsigned long start, int nr_pages, int write, int force,
 			struct page **pages, struct vm_area_struct **vmas);
+int get_user_pages_noio(struct task_struct *tsk, struct mm_struct *mm,
+			unsigned long start, int nr_pages, int write, int force,
+			struct page **pages, struct vm_area_struct **vmas);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
 struct page *get_dump_page(unsigned long addr);
@@ -1373,6 +1377,7 @@ struct page *follow_page(struct vm_area_struct *, unsigned long address,
 #define FOLL_GET	0x04	/* do get_page on page */
 #define FOLL_DUMP	0x08	/* give error on hole if it would be zero */
 #define FOLL_FORCE	0x10	/* get_user_pages read/write w/o permission */
+#define FOLL_MINOR	0x20	/* do only minor page faults */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
diff --git a/mm/filemap.c b/mm/filemap.c
index 20e5642..1186338 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1548,6 +1548,9 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 			goto no_cached_page;
 		}
 	} else {
+		if (vmf->flags & FAULT_FLAG_MINOR)
+			return VM_FAULT_MAJOR | VM_FAULT_ERROR;
+
 		/* No page in the page cache at all */
 		do_sync_mmap_readahead(vma, ra, file, offset);
 		count_vm_event(PGMAJFAULT);
diff --git a/mm/memory.c b/mm/memory.c
index 119b7cc..7dfaba2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1433,10 +1433,13 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			cond_resched();
 			while (!(page = follow_page(vma, start, foll_flags))) {
 				int ret;
+				unsigned int fault_fl =
+					((foll_flags & FOLL_WRITE) ?
+					FAULT_FLAG_WRITE : 0) |
+					((foll_flags & FOLL_MINOR) ?
+					FAULT_FLAG_MINOR : 0);
 
-				ret = handle_mm_fault(mm, vma, start,
-					(foll_flags & FOLL_WRITE) ?
-					FAULT_FLAG_WRITE : 0);
+				ret = handle_mm_fault(mm, vma, start, fault_fl);
 
 				if (ret & VM_FAULT_ERROR) {
 					if (ret & VM_FAULT_OOM)
@@ -1444,6 +1447,8 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 					if (ret &
 					    (VM_FAULT_HWPOISON|VM_FAULT_SIGBUS))
 						return i ? i : -EFAULT;
+					else if (ret & VM_FAULT_MAJOR)
+						return i ? i : -EFAULT;
 					BUG();
 				}
 				if (ret & VM_FAULT_MAJOR)
@@ -1554,6 +1559,23 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 }
 EXPORT_SYMBOL(get_user_pages);
 
+int get_user_pages_noio(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, int nr_pages, int write, int force,
+		struct page **pages, struct vm_area_struct **vmas)
+{
+	int flags = FOLL_TOUCH | FOLL_MINOR;
+
+	if (pages)
+		flags |= FOLL_GET;
+	if (write)
+		flags |= FOLL_WRITE;
+	if (force)
+		flags |= FOLL_FORCE;
+
+	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas);
+}
+EXPORT_SYMBOL(get_user_pages_noio);
+
 /**
  * get_dump_page() - pin user page in memory while writing it to core dump
  * @addr: user address
@@ -2640,6 +2662,9 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
 	page = lookup_swap_cache(entry);
 	if (!page) {
+		if (flags & FAULT_FLAG_MINOR)
+			return VM_FAULT_MAJOR | VM_FAULT_ERROR;
+
 		grab_swap_token(mm); /* Contend for token _before_ read-in */
 		page = swapin_readahead(entry,
 					GFP_HIGHUSER_MOVABLE, vma, address);
diff --git a/mm/shmem.c b/mm/shmem.c
index f65f840..acc8958 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1227,6 +1227,7 @@ static int shmem_getpage(struct inode *inode, unsigned long idx,
 	swp_entry_t swap;
 	gfp_t gfp;
 	int error;
+	int flags = type ? *type : 0;
 
 	if (idx >= SHMEM_MAX_INDEX)
 		return -EFBIG;
@@ -1275,6 +1276,11 @@ repeat:
 		swappage = lookup_swap_cache(swap);
 		if (!swappage) {
 			shmem_swp_unmap(entry);
+			if (flags & FAULT_FLAG_MINOR) {
+				spin_unlock(&info->lock);
+				*type = VM_FAULT_MAJOR | VM_FAULT_ERROR;
+				goto failed;
+			}
 			/* here we actually do the io */
 			if (type && !(*type & VM_FAULT_MAJOR)) {
 				__count_vm_event(PGMAJFAULT);
@@ -1483,7 +1489,7 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
 	int error;
-	int ret;
+	int ret = (int)vmf->flags;
 
 	if (((loff_t)vmf->pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
 		return VM_FAULT_SIGBUS;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
