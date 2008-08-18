Date: Mon, 18 Aug 2008 07:44:09 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: xip fix fault vs sparse page invalidate race
Message-ID: <20080818054409.GB3011@wotan.suse.de>
References: <20080818053821.GA3011@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080818053821.GA3011@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, cotte@de.ibm.com, borntraeger@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

XIP has a race between sparse pages being inserted into page tables, and
sparse pages being zapped when its time to put a non-sparse page in.

What can happen is that a process can be left with a dangling sparse page
in a MAP_SHARED mapping, while the rest of the world sees the non-sparse
version. Ie. data corruption. 

Guard these operations with a seqlock, making fault-in-sparse-pages
the slowpath, and try-to-unmap-sparse-pages the fastpath.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---

Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c	2008-08-18 13:43:53.000000000 +1000
+++ linux-2.6/mm/filemap_xip.c	2008-08-18 15:02:29.000000000 +1000
@@ -15,6 +15,8 @@
 #include <linux/rmap.h>
 #include <linux/mmu_notifier.h>
 #include <linux/sched.h>
+#include <linux/seqlock.h>
+#include <linux/mutex.h>
 #include <asm/tlbflush.h>
 #include <asm/io.h>
 
@@ -22,22 +24,18 @@
  * We do use our own empty page to avoid interference with other users
  * of ZERO_PAGE(), such as /dev/zero
  */
+static DEFINE_MUTEX(xip_sparse_mutex);
+static seqcount_t xip_sparse_seq = SEQCNT_ZERO;
 static struct page *__xip_sparse_page;
 
+/* called under xip_sparse_mutex */
 static struct page *xip_sparse_page(void)
 {
 	if (!__xip_sparse_page) {
 		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_ZERO);
 
-		if (page) {
-			static DEFINE_SPINLOCK(xip_alloc_lock);
-			spin_lock(&xip_alloc_lock);
-			if (!__xip_sparse_page)
-				__xip_sparse_page = page;
-			else
-				__free_page(page);
-			spin_unlock(&xip_alloc_lock);
-		}
+		if (page)
+			__xip_sparse_page = page;
 	}
 	return __xip_sparse_page;
 }
@@ -174,11 +172,16 @@ __xip_unmap (struct address_space * mapp
 	pte_t pteval;
 	spinlock_t *ptl;
 	struct page *page;
+	unsigned count;
+	int locked = 0;
+
+	count = read_seqcount_begin(&xip_sparse_seq);
 
 	page = __xip_sparse_page;
 	if (!page)
 		return;
 
+retry:
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		mm = vma->vm_mm;
@@ -198,6 +201,14 @@ __xip_unmap (struct address_space * mapp
 		}
 	}
 	spin_unlock(&mapping->i_mmap_lock);
+
+	if (locked) {
+		mutex_unlock(&xip_sparse_mutex);
+	} else if (read_seqcount_retry(&xip_sparse_seq, count)) {
+		mutex_lock(&xip_sparse_mutex);
+		locked = 1;
+		goto retry;
+	}
 }
 
 /*
@@ -218,7 +229,7 @@ static int xip_file_fault(struct vm_area
 	int error;
 
 	/* XXX: are VM_FAULT_ codes OK? */
-
+again:
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	if (vmf->pgoff >= size)
 		return VM_FAULT_SIGBUS;
@@ -245,6 +256,7 @@ static int xip_file_fault(struct vm_area
 		__xip_unmap(mapping, vmf->pgoff);
 
 found:
+		printk("%s insert %lx@%lx\n", current->comm, (unsigned long)vmf->virtual_address, xip_pfn);
 		err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
 							xip_pfn);
 		if (err == -ENOMEM)
@@ -252,14 +264,34 @@ found:
 		BUG_ON(err);
 		return VM_FAULT_NOPAGE;
 	} else {
+		int err, ret = VM_FAULT_OOM;
+
+		mutex_lock(&xip_sparse_mutex);
+		write_seqcount_begin(&xip_sparse_seq);
+		error = mapping->a_ops->get_xip_mem(mapping, vmf->pgoff, 0,
+							&xip_mem, &xip_pfn);
+		if (unlikely(!error)) {
+			write_seqcount_end(&xip_sparse_seq);
+			mutex_unlock(&xip_sparse_mutex);
+			goto again;
+		}
+		if (error != -ENODATA)
+			goto out;
 		/* not shared and writable, use xip_sparse_page() */
 		page = xip_sparse_page();
 		if (!page)
-			return VM_FAULT_OOM;
+			goto out;
+		err = vm_insert_page(vma, (unsigned long)vmf->virtual_address,
+							page);
+		if (err == -ENOMEM)
+			goto out;
 
-		page_cache_get(page);
-		vmf->page = page;
-		return 0;
+		ret = VM_FAULT_NOPAGE;
+out:
+		write_seqcount_end(&xip_sparse_seq);
+		mutex_unlock(&xip_sparse_mutex);
+
+		return ret;
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
