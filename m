Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED826B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 17:03:43 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id r1so4655652pgq.7
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 14:03:43 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k6si4522822pgo.818.2018.03.02.14.03.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 02 Mar 2018 14:03:42 -0800 (PST)
Date: Fri, 2 Mar 2018 14:03:40 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] Handle mapcount overflows
Message-ID: <20180302220340.GC671@bombadil.infradead.org>
References: <20180208021112.GB14918@bombadil.infradead.org>
 <20180302212637.GB671@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180302212637.GB671@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Mar 02, 2018 at 01:26:37PM -0800, Matthew Wilcox wrote:
> Here's my third effort to handle page->_mapcount overflows.

If you like this approach, but wonder if it works, here's a little forkbomb
of a program and a patch to add instrumentation.

In my dmesg, I never see the max mapcount getting above 65539.  I see a mix
of unlucky, it him! and it me! messages.

#define _GNU_SOURCE

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

int dummy;

int main(int argc, char **argv)
{
	int fd = open(argv[1], O_RDWR);
	int i;

	if (fd < 0) {
		perror(argv[1]);
		return 1;
	}

	// Spawn 511 children
	for (i = 0; i < 9; i++)
		fork();

	for (i = 0; i < 5000; i++)
		dummy = *(int *)mmap(NULL, 4096, PROT_READ, MAP_SHARED, fd, 0);
}


diff --git a/mm/mmap.c b/mm/mmap.c
index 575766ec02f8..2b6187156db0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1325,7 +1325,7 @@ static inline int mlock_future_check(struct mm_struct *mm,
  * Experimentally determined.  gnome-shell currently uses fewer than
  * 3000 mappings, so should have zero effect on desktop users.
  */
-#define mm_track_threshold	5000
+#define mm_track_threshold	50
 static DEFINE_SPINLOCK(heavy_users_lock);
 static DEFINE_IDR(heavy_users);
 
@@ -1377,9 +1377,11 @@ static void kill_abuser(struct mm_struct *mm)
 			break;
 
 	if (down_write_trylock(&mm->mmap_sem)) {
+		printk_ratelimited("it him!\n");
 		kill_mm(tsk);
 		up_write(&mm->mmap_sem);
 	} else {
+		printk_ratelimited("unlucky!\n");
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, tsk, true);
 	}
 }
@@ -1396,8 +1398,10 @@ void mm_mapcount_overflow(struct page *page)
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff + 1) {
 		if (vma->vm_mm == entry)
 			count++;
-		if (count > 1000)
+		if (count > 1000) {
+			printk_ratelimited("it me!\n");
 			kill_mm(current);
+		}
 	}
 
 	rcu_read_lock();
@@ -1408,7 +1412,7 @@ void mm_mapcount_overflow(struct page *page)
 				pgoff, pgoff + 1) {
 			if (vma->vm_mm == entry)
 				count++;
-			if (count > 1000) {
+			if (count > 10) {
 				kill_abuser(entry);
 				goto out;
 			}
diff --git a/mm/rmap.c b/mm/rmap.c
index d88acf5c98e9..3f0509f6f011 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1190,6 +1190,7 @@ void page_add_file_rmap(struct page *page, bool compound)
 		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 		__inc_node_page_state(page, NR_SHMEM_PMDMAPPED);
 	} else {
+		static int max = 0;
 		int v;
 		if (PageTransCompound(page) && page_mapping(page)) {
 			VM_WARN_ON_ONCE(!PageLocked(page));
@@ -1199,12 +1200,14 @@ void page_add_file_rmap(struct page *page, bool compound)
 				clear_page_mlock(compound_head(page));
 		}
 		v = atomic_inc_return(&page->_mapcount);
-		if (likely(v > 0))
-			goto out;
-		if (unlikely(v < 0)) {
+		if (unlikely(v > 65535)) {
+			if (max < v) max = v;
+			printk_ratelimited("overflow %d max %d\n", v, max);
 			mm_mapcount_overflow(page);
 			goto out;
 		}
+		if (likely(v > 0))
+			goto out;
 	}
 	__mod_lruvec_page_state(page, NR_FILE_MAPPED, nr);
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
