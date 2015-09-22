Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id E64DA6B0257
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:24:12 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so176168694wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:12 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id u4si22416064wij.17.2015.09.21.23.24.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 23:24:11 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so176168366wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:11 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 04/11] x86/mm/hotplug: Simplify sync_global_pgds()
Date: Tue, 22 Sep 2015 08:23:34 +0200
Message-Id: <1442903021-3893-5-git-send-email-mingo@kernel.org>
In-Reply-To: <1442903021-3893-1-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

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
index eef44d9a3f77..f890f5463ac1 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -353,7 +353,7 @@ static void dump_pagetable(unsigned long address)
 
 void vmalloc_sync_all(void)
 {
-	sync_global_pgds(VMALLOC_START & PGDIR_MASK, VMALLOC_END, 0);
+	sync_global_pgds(VMALLOC_START & PGDIR_MASK, VMALLOC_END);
 }
 
 /*
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 60b0cc3f2819..467c4f66ded9 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -161,10 +161,10 @@ static int __init nonx32_setup(char *str)
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
 
@@ -172,14 +172,8 @@ void sync_global_pgds(unsigned long start, unsigned long end, int removed)
 		const pgd_t *pgd_ref = pgd_offset_k(address);
 		struct task_struct *g;
 
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
 
 		rcu_read_lock(); /* Task list walk */
@@ -205,13 +199,8 @@ void sync_global_pgds(unsigned long start, unsigned long end, int removed)
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
@@ -646,7 +635,7 @@ kernel_physical_mapping_init(unsigned long start,
 	}
 
 	if (pgd_changed)
-		sync_global_pgds(addr, end - 1, 0);
+		sync_global_pgds(addr, end - 1);
 
 	__flush_tlb_all();
 
@@ -1286,7 +1275,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
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
