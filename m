Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id DE2CC6B025A
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:24:20 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so8075483wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:20 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id p5si1781835wif.44.2015.09.21.23.24.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 23:24:19 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so176873984wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:19 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 08/11] x86/mm/pat/32: Remove pgd_list use from the PAT code
Date: Tue, 22 Sep 2015 08:23:38 +0200
Message-Id: <1442903021-3893-9-git-send-email-mingo@kernel.org>
In-Reply-To: <1442903021-3893-1-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

The 32-bit x86 PAT code uses __set_pmd_pte() to update pmds.

This uses pgd_list currently, but we don't need the global
list as we can walk the task list under RCU.

(This code already holds the pgd_lock.)

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
 arch/x86/mm/pageattr.c | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index b784ed7c9a7e..bc7533801014 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -12,6 +12,7 @@
 #include <linux/pfn.h>
 #include <linux/percpu.h>
 #include <linux/gfp.h>
+#include <linux/oom.h>
 #include <linux/pci.h>
 #include <linux/vmalloc.h>
 
@@ -438,18 +439,36 @@ static void __set_pmd_pte(pte_t *kpte, unsigned long address, pte_t pte)
 	set_pte_atomic(kpte, pte);
 #ifdef CONFIG_X86_32
 	if (!SHARED_KERNEL_PMD) {
-		struct page *page;
+		struct task_struct *g;
 
-		list_for_each_entry(page, &pgd_list, lru) {
+		rcu_read_lock(); /* Task list walk */
+
+		for_each_process(g) {
+			struct task_struct *p;
+			struct mm_struct *mm;
+			spinlock_t *pgt_lock;
 			pgd_t *pgd;
 			pud_t *pud;
 			pmd_t *pmd;
 
-			pgd = (pgd_t *)page_address(page) + pgd_index(address);
+			p = find_lock_task_mm(g);
+			if (!p)
+				continue;
+
+			mm = p->mm;
+			pgt_lock = &mm->page_table_lock;
+			spin_lock(pgt_lock);
+
+			pgd = mm->pgd + pgd_index(address);
 			pud = pud_offset(pgd, address);
 			pmd = pmd_offset(pud, address);
 			set_pte_atomic((pte_t *)pmd, pte);
+
+			spin_unlock(pgt_lock);
+
+			task_unlock(p);
 		}
+		rcu_read_unlock();
 	}
 #endif
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
