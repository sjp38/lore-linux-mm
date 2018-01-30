Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 818616B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 22:00:14 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id k188so5980435qkc.18
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 19:00:14 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id b3si3832836qtb.395.2018.01.29.19.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jan 2018 19:00:13 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH] Lock mmap_sem when calling migrate_pages() in do_move_pages_to_node()
Date: Mon, 29 Jan 2018 22:00:11 -0500
Message-Id: <20180130030011.4310-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>

From: Zi Yan <zi.yan@cs.rutgers.edu>

migrate_pages() requires at least down_read(mmap_sem) to protect
related page tables and VMAs from changing. Let's do it in
do_page_moves() for both do_move_pages_to_node() and
add_page_for_migration().

Also add this lock requirement in the comment of migrate_pages().

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/migrate.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 5d0dc7b85f90..52d029953c32 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1354,6 +1354,9 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
  * or free list only if ret != 0.
  *
  * Returns the number of pages that were not migrated, or an error code.
+ *
+ * The caller must hold at least down_read(mmap_sem) for to-be-migrated pages
+ * to protect related page tables and VMAs from changing.
  */
 int migrate_pages(struct list_head *from, new_page_t get_new_page,
 		free_page_t put_new_page, unsigned long private,
@@ -1457,6 +1460,12 @@ static int store_status(int __user *status, int start, int value, int nr)
 	return 0;
 }
 
+/*
+ * Migrates the pages from pagelist and put back those not migrated.
+ *
+ * The caller must at least hold down_read(mmap_sem), which is required
+ * for migrate_pages()
+ */
 static int do_move_pages_to_node(struct mm_struct *mm,
 		struct list_head *pagelist, int node)
 {
@@ -1487,7 +1496,6 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 	unsigned int follflags;
 	int err;
 
-	down_read(&mm->mmap_sem);
 	err = -EFAULT;
 	vma = find_vma(mm, addr);
 	if (!vma || addr < vma->vm_start || !vma_migratable(vma))
@@ -1540,7 +1548,6 @@ static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
 	 */
 	put_page(page);
 out:
-	up_read(&mm->mmap_sem);
 	return err;
 }
 
@@ -1561,6 +1568,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 
 	migrate_prep();
 
+	down_read(&mm->mmap_sem);
 	for (i = start = 0; i < nr_pages; i++) {
 		const void __user *p;
 		unsigned long addr;
@@ -1628,6 +1636,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 	if (!err)
 		err = err1;
 out:
+	up_read(&mm->mmap_sem);
 	return err;
 }
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
