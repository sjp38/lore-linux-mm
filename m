Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4DDF86B025A
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:24:19 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so176171515wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:18 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id pb6si1051wjb.129.2015.09.21.23.24.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 23:24:18 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so8074388wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:18 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 07/11] x86/mm: Remove pgd_list use from vmalloc_sync_all()
Date: Tue, 22 Sep 2015 08:23:37 +0200
Message-Id: <1442903021-3893-8-git-send-email-mingo@kernel.org>
In-Reply-To: <1442903021-3893-1-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

The vmalloc() code uses vmalloc_sync_all() to synchronize changes to
the global reference kernel PGD to task PGDs in certain rare cases,
like register_die_notifier().

This use seems to be somewhat questionable, as most other vmalloc
page table fixups are vmalloc_fault() driven, but nevertheless
it's there and it's using the pgd_list.

But we don't need the global list, as we can walk the task list
under RCU.

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
 arch/x86/mm/fault.c | 29 ++++++++++++++++++++++-------
 1 file changed, 22 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index f890f5463ac1..9322d5ad3811 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -14,6 +14,7 @@
 #include <linux/prefetch.h>		/* prefetchw			*/
 #include <linux/context_tracking.h>	/* exception_enter(), ...	*/
 #include <linux/uaccess.h>		/* faulthandler_disabled()	*/
+#include <linux/oom.h>			/* find_lock_task_mm(), ...	*/
 
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
 #include <asm/pgalloc.h>		/* pgd_*(), ...			*/
@@ -237,24 +238,38 @@ void vmalloc_sync_all(void)
 	for (address = VMALLOC_START & PMD_MASK;
 	     address >= TASK_SIZE && address < FIXADDR_TOP;
 	     address += PMD_SIZE) {
-		struct page *page;
 
+		struct task_struct *g;
+
+		rcu_read_lock(); /* Task list walk */
 		spin_lock(&pgd_lock);
-		list_for_each_entry(page, &pgd_list, lru) {
+
+		for_each_process(g) {
+			struct task_struct *p;
+			struct mm_struct *mm;
 			spinlock_t *pgt_lock;
-			pmd_t *ret;
+			pmd_t *pmd_ret;
+
+			p = find_lock_task_mm(g);
+			if (!p)
+				continue;
 
-			/* the pgt_lock only for Xen */
-			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
+			mm = p->mm;
 
+			/* The pgt_lock is only used on Xen: */
+			pgt_lock = &mm->page_table_lock;
 			spin_lock(pgt_lock);
-			ret = vmalloc_sync_one(page_address(page), address);
+			pmd_ret = vmalloc_sync_one(mm->pgd, address);
 			spin_unlock(pgt_lock);
 
-			if (!ret)
+			task_unlock(p);
+
+			if (!pmd_ret)
 				break;
 		}
+
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
