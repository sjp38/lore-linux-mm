Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 644D1280003
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 05:49:47 -0400 (EDT)
Received: by wgzl5 with SMTP id l5so12725742wgz.3
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:47 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id ec16si7855704wic.86.2015.06.13.02.49.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 02:49:46 -0700 (PDT)
Received: by wgzl5 with SMTP id l5so12725543wgz.3
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:45 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 08/12] x86/mm: Remove pgd_list use from vmalloc_sync_all()
Date: Sat, 13 Jun 2015 11:49:11 +0200
Message-Id: <1434188955-31397-9-git-send-email-mingo@kernel.org>
In-Reply-To: <1434188955-31397-1-git-send-email-mingo@kernel.org>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

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
 arch/x86/mm/fault.c | 28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 50342825f221..366b8232f4b3 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -235,23 +235,35 @@ void vmalloc_sync_all(void)
 	for (address = VMALLOC_START & PMD_MASK;
 	     address >= TASK_SIZE && address < FIXADDR_TOP;
 	     address += PMD_SIZE) {
-		struct page *page;
 
-		spin_lock(&pgd_lock);
-		list_for_each_entry(page, &pgd_list, lru) {
+		struct task_struct *g, *p;
+
+		spin_lock(&pgd_lock); /* Implies rcu_read_lock(): */
+
+		for_each_process_thread(g, p) {
+			struct mm_struct *mm;
 			spinlock_t *pgt_lock;
-			pmd_t *ret;
+			pmd_t *pmd_ret;
 
-			/* the pgt_lock only for Xen */
-			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
+			task_lock(p);
+			mm = p->mm;
+			if (!mm) {
+				task_unlock(p);
+				continue;
+			}
 
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
 	}
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
