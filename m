Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id B399C6B006E
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 05:49:40 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so35641945wib.1
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:40 -0700 (PDT)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id qo2si11594985wjc.150.2015.06.13.02.49.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 02:49:39 -0700 (PDT)
Received: by wgbhy7 with SMTP id hy7so4474275wgb.2
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:38 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 04/12] x86/mm/hotplug: Simplify sync_global_pgds()
Date: Sat, 13 Jun 2015 11:49:07 +0200
Message-Id: <1434188955-31397-5-git-send-email-mingo@kernel.org>
In-Reply-To: <1434188955-31397-1-git-send-email-mingo@kernel.org>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

Now that the memory hotplug code does not remove PGD entries anymore,
the only users of sync_global_pgds() use it after extending the
PGD.

So remove the 'removed' parameter and simplify the call sites.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Waiman Long <Waiman.Long@hp.com>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/include/asm/pgtable_64.h |  3 +--
 arch/x86/mm/fault.c               |  2 +-
 arch/x86/mm/init_64.c             | 27 ++++++++-------------------
 3 files changed, 10 insertions(+), 22 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 2ee781114d34..f405fc3bb719 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -116,8 +116,7 @@ static inline void native_pgd_clear(pgd_t *pgd)
 	native_set_pgd(pgd, native_make_pgd(0));
 }
 
-extern void sync_global_pgds(unsigned long start, unsigned long end,
-			     int removed);
+extern void sync_global_pgds(unsigned long start, unsigned long end);
 
 /*
  * Conversion functions: convert a page and protection to a page entry,
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 181c53bac3a7..50342825f221 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -349,7 +349,7 @@ static void dump_pagetable(unsigned long address)
 
 void vmalloc_sync_all(void)
 {
-	sync_global_pgds(VMALLOC_START & PGDIR_MASK, VMALLOC_END, 0);
+	sync_global_pgds(VMALLOC_START & PGDIR_MASK, VMALLOC_END);
 }
 
 /*
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 7a988dbad240..dcb2f45caf0e 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -160,10 +160,10 @@ static int __init nonx32_setup(char *str)
 __setup("noexec32=", nonx32_setup);
 
 /*
- * When memory was added/removed make sure all the process MMs have
+ * When memory was added make sure all the process MMs have
  * matching PGD entries in the local PGD level page as well.
  */
-void sync_global_pgds(unsigned long start, unsigned long end, int removed)
+void sync_global_pgds(unsigned long start, unsigned long end)
 {
 	unsigned long address;
 
@@ -171,14 +171,8 @@ void sync_global_pgds(unsigned long start, unsigned long end, int removed)
 		const pgd_t *pgd_ref = pgd_offset_k(address);
 		struct task_struct *g, *p;
 
-		/*
-		 * When this function is called after memory hot remove,
-		 * pgd_none() already returns true, but only the reference
-		 * kernel PGD has been cleared, not the process PGDs.
-		 *
-		 * So clear the affected entries in every process PGD as well:
-		 */
-		if (pgd_none(*pgd_ref) && !removed)
+		/* Only sync (potentially) newly added PGD entries: */
+		if (pgd_none(*pgd_ref))
 			continue;
 
 		spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
@@ -204,13 +198,8 @@ void sync_global_pgds(unsigned long start, unsigned long end, int removed)
 			if (!pgd_none(*pgd_ref) && !pgd_none(*pgd))
 				BUG_ON(pgd_page_vaddr(*pgd) != pgd_page_vaddr(*pgd_ref));
 
-			if (removed) {
-				if (pgd_none(*pgd_ref) && !pgd_none(*pgd))
-					pgd_clear(pgd);
-			} else {
-				if (pgd_none(*pgd))
-					set_pgd(pgd, *pgd_ref);
-			}
+			if (pgd_none(*pgd))
+				set_pgd(pgd, *pgd_ref);
 
 			spin_unlock(pgt_lock);
 			task_unlock(p);
@@ -644,7 +633,7 @@ kernel_physical_mapping_init(unsigned long start,
 	}
 
 	if (pgd_changed)
-		sync_global_pgds(addr, end - 1, 0);
+		sync_global_pgds(addr, end - 1);
 
 	__flush_tlb_all();
 
@@ -1284,7 +1273,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
 	else
 		err = vmemmap_populate_basepages(start, end, node);
 	if (!err)
-		sync_global_pgds(start, end - 1, 0);
+		sync_global_pgds(start, end - 1);
 	return err;
 }
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
