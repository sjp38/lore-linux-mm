Date: Thu, 23 Aug 2001 15:05:14 -0400
From: Ben LaHaise <bcrl@touchme.toronto.redhat.com>
Message-Id: <200108231905.f7NJ5E223517@touchme.toronto.redhat.com>
Subject: [PATCH] clear_page_tables
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: alan@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Heylo,

The patch below fixes a lack of locking in clear_page_tables which could
result in kswapd poking at page tables that have been freed.

		-ben

/patches/v2.4.8-ac9-clear_page_tables-lock.diff...
diff -ur /md0/kernels/2.4/v2.4.8-ac9/mm/memory.c vm-v2.4.8-ac9/mm/memory.c
--- /md0/kernels/2.4/v2.4.8-ac9/mm/memory.c	Thu Aug 23 13:48:25 2001
+++ vm-v2.4.8-ac9/mm/memory.c	Thu Aug 23 14:45:46 2001
@@ -129,11 +129,13 @@
 {
 	pgd_t * page_dir = mm->pgd;
 
+	spin_lock(&mm->page_table_lock);
 	page_dir += first;
 	do {
 		free_one_pgd(page_dir);
 		page_dir++;
 	} while (--nr);
+	spin_unlock(&mm->page_table_lock);
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
