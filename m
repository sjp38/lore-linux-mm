Date: Wed, 14 Jul 2004 23:06:54 +0900 (JST)
Message-Id: <20040714.230654.58831017.taka@valinux.co.jp>
Subject: [PATCH] memory hotremoval for linux-2.6.7 [16/16]
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20040714.224138.95803956.taka@valinux.co.jp>
References: <20040714.224138.95803956.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- linux-2.6.7.ORG/fs/direct-io.c	Thu Jun 17 15:17:13 2032
+++ linux-2.6.7/fs/direct-io.c	Thu Jun 17 15:28:44 2032
@@ -27,6 +27,7 @@
 #include <linux/slab.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
+#include <linux/hugetlb.h>
 #include <linux/bio.h>
 #include <linux/wait.h>
 #include <linux/err.h>
@@ -110,7 +111,11 @@ struct dio {
 	 * Page queue.  These variables belong to dio_refill_pages() and
 	 * dio_get_page().
 	 */
+#ifndef CONFIG_HUGETLB_PAGE
 	struct page *pages[DIO_PAGES];	/* page buffer */
+#else
+	struct page *pages[HPAGE_SIZE/PAGE_SIZE];	/* page buffer */
+#endif
 	unsigned head;			/* next page to process */
 	unsigned tail;			/* last valid page + 1 */
 	int page_errors;		/* errno from get_user_pages() */
@@ -143,9 +148,20 @@ static int dio_refill_pages(struct dio *
 {
 	int ret;
 	int nr_pages;
+	struct vm_area_struct * vma;
 
-	nr_pages = min(dio->total_pages - dio->curr_page, DIO_PAGES);
 	down_read(&current->mm->mmap_sem);
+#ifdef CONFIG_HUGETLB_PAGE
+	vma = find_vma(current->mm, dio->curr_user_address);
+	if (vma && is_vm_hugetlb_page(vma)) {
+		unsigned long n = dio->curr_user_address & PAGE_MASK;
+		n = (n & ~HPAGE_MASK) >> PAGE_SHIFT;
+		n = HPAGE_SIZE/PAGE_SIZE - n;
+		nr_pages = min(dio->total_pages - dio->curr_page, (int)n);
+	} else
+#endif
+		nr_pages = min(dio->total_pages - dio->curr_page, DIO_PAGES);
+
 	ret = get_user_pages(
 		current,			/* Task for fault acounting */
 		current->mm,			/* whose pages? */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
