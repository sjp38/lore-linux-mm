Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id D4BE16B006E
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 05:49:35 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so34970048wib.1
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:35 -0700 (PDT)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id am6si11647576wjc.37.2015.06.13.02.49.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 02:49:34 -0700 (PDT)
Received: by wgv5 with SMTP id 5so37648548wgv.1
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:34 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 02/12] x86/mm/hotplug: Remove pgd_list use from the memory hotplug code
Date: Sat, 13 Jun 2015 11:49:05 +0200
Message-Id: <1434188955-31397-3-git-send-email-mingo@kernel.org>
In-Reply-To: <1434188955-31397-1-git-send-email-mingo@kernel.org>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

The memory hotplug code uses sync_global_pgds() to synchronize updates
to the global (&init_mm) kernel PGD and the task PGDs. It does this
by iterating over the pgd_list - which list closely tracks task
creation/destruction via fork/clone.

But we want to remove this list, so that it does not have to be
maintained from fork()/exit(), so convert the memory hotplug code
to use the task list to iterate over all pgds in the system.

Also improve the comments a bit, to make this function easier
to understand.

Only lightly tested, as I don't have a memory hotplug setup.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Waiman Long <Waiman.Long@hp.com>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/init_64.c | 38 +++++++++++++++++++++++++-------------
 1 file changed, 25 insertions(+), 13 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 3fba623e3ba5..527d5d4d020c 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -160,8 +160,8 @@ static int __init nonx32_setup(char *str)
 __setup("noexec32=", nonx32_setup);
 
 /*
- * When memory was added/removed make sure all the processes MM have
- * suitable PGD entries in the local PGD level page.
+ * When memory was added/removed make sure all the process MMs have
+ * matching PGD entries in the local PGD level page as well.
  */
 void sync_global_pgds(unsigned long start, unsigned long end, int removed)
 {
@@ -169,29 +169,40 @@ void sync_global_pgds(unsigned long start, unsigned long end, int removed)
 
 	for (address = start; address <= end; address += PGDIR_SIZE) {
 		const pgd_t *pgd_ref = pgd_offset_k(address);
-		struct page *page;
+		struct task_struct *g, *p;
 
 		/*
-		 * When it is called after memory hot remove, pgd_none()
-		 * returns true. In this case (removed == 1), we must clear
-		 * the PGD entries in the local PGD level page.
+		 * When this function is called after memory hot remove,
+		 * pgd_none() already returns true, but only the reference
+		 * kernel PGD has been cleared, not the process PGDs.
+		 *
+		 * So clear the affected entries in every process PGD as well:
 		 */
 		if (pgd_none(*pgd_ref) && !removed)
 			continue;
 
-		spin_lock(&pgd_lock);
-		list_for_each_entry(page, &pgd_list, lru) {
+		spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
+
+		for_each_process_thread(g, p) {
+			struct mm_struct *mm;
 			pgd_t *pgd;
 			spinlock_t *pgt_lock;
 
-			pgd = (pgd_t *)page_address(page) + pgd_index(address);
-			/* the pgt_lock only for Xen */
-			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
+			task_lock(p);
+			mm = p->mm;
+			if (!mm) {
+				task_unlock(p);
+				continue;
+			}
+
+			pgd = mm->pgd;
+
+			/* The pgt_lock is only used by Xen: */
+			pgt_lock = &mm->page_table_lock;
 			spin_lock(pgt_lock);
 
 			if (!pgd_none(*pgd_ref) && !pgd_none(*pgd))
-				BUG_ON(pgd_page_vaddr(*pgd)
-				       != pgd_page_vaddr(*pgd_ref));
+				BUG_ON(pgd_page_vaddr(*pgd) != pgd_page_vaddr(*pgd_ref));
 
 			if (removed) {
 				if (pgd_none(*pgd_ref) && !pgd_none(*pgd))
@@ -202,6 +213,7 @@ void sync_global_pgds(unsigned long start, unsigned long end, int removed)
 			}
 
 			spin_unlock(pgt_lock);
+			task_unlock(p);
 		}
 		spin_unlock(&pgd_lock);
 	}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
