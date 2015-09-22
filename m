Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 978476B0255
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:24:10 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so145561476wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:10 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id bp5si48038wjc.7.2015.09.21.23.24.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 23:24:09 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so145561039wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:09 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 02/11] x86/mm/hotplug: Remove pgd_list use from the memory hotplug code
Date: Tue, 22 Sep 2015 08:23:32 +0200
Message-Id: <1442903021-3893-3-git-send-email-mingo@kernel.org>
In-Reply-To: <1442903021-3893-1-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

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
 arch/x86/mm/init_64.c | 38 ++++++++++++++++++++++++++------------
 1 file changed, 26 insertions(+), 12 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 30564e2752d3..7129e7647a76 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -33,6 +33,7 @@
 #include <linux/nmi.h>
 #include <linux/gfp.h>
 #include <linux/kcore.h>
+#include <linux/oom.h>
 
 #include <asm/processor.h>
 #include <asm/bios_ebda.h>
@@ -160,8 +161,8 @@ static int __init nonx32_setup(char *str)
 __setup("noexec32=", nonx32_setup);
 
 /*
- * When memory was added/removed make sure all the processes MM have
- * suitable PGD entries in the local PGD level page.
+ * When memory was added/removed make sure all the process MMs have
+ * matching PGD entries in the local PGD level page as well.
  */
 void sync_global_pgds(unsigned long start, unsigned long end, int removed)
 {
@@ -169,29 +170,40 @@ void sync_global_pgds(unsigned long start, unsigned long end, int removed)
 
 	for (address = start; address <= end; address += PGDIR_SIZE) {
 		const pgd_t *pgd_ref = pgd_offset_k(address);
-		struct page *page;
+		struct task_struct *g;
 
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
 
+		rcu_read_lock(); /* Task list walk */
 		spin_lock(&pgd_lock);
-		list_for_each_entry(page, &pgd_list, lru) {
+
+		for_each_process(g) {
+			struct task_struct *p;
+			struct mm_struct *mm;
 			pgd_t *pgd;
 			spinlock_t *pgt_lock;
 
-			pgd = (pgd_t *)page_address(page) + pgd_index(address);
-			/* the pgt_lock only for Xen */
-			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
+			p = find_lock_task_mm(g);
+			if (!p)
+				continue;
+
+			mm = p->mm;
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
@@ -202,8 +214,10 @@ void sync_global_pgds(unsigned long start, unsigned long end, int removed)
 			}
 
 			spin_unlock(pgt_lock);
+			task_unlock(p);
 		}
 		spin_unlock(&pgd_lock);
+		rcu_read_unlock();
 	}
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
