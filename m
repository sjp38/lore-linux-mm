Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 50968280003
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 05:49:49 -0400 (EDT)
Received: by wgez8 with SMTP id z8so37698007wge.0
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:49 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id s11si11588485wju.161.2015.06.13.02.49.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 02:49:47 -0700 (PDT)
Received: by wiga1 with SMTP id a1so34790244wig.0
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:47 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 09/12] x86/mm/pat/32: Remove pgd_list use from the PAT code
Date: Sat, 13 Jun 2015 11:49:12 +0200
Message-Id: <1434188955-31397-10-git-send-email-mingo@kernel.org>
In-Reply-To: <1434188955-31397-1-git-send-email-mingo@kernel.org>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

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
 arch/x86/mm/pageattr.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 997fc97e9072..4ff6a1808f1d 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -438,17 +438,31 @@ static void __set_pmd_pte(pte_t *kpte, unsigned long address, pte_t pte)
 	set_pte_atomic(kpte, pte);
 #ifdef CONFIG_X86_32
 	if (!SHARED_KERNEL_PMD) {
-		struct page *page;
+		struct task_struct *g, *p;
 
-		list_for_each_entry(page, &pgd_list, lru) {
+		/* We are holding pgd_lock, which implies rcu_read_lock(): */
+
+		for_each_process_thread(g, p) {
+			struct mm_struct *mm;
+			spinlock_t *pgt_lock;
 			pgd_t *pgd;
 			pud_t *pud;
 			pmd_t *pmd;
 
-			pgd = (pgd_t *)page_address(page) + pgd_index(address);
-			pud = pud_offset(pgd, address);
-			pmd = pmd_offset(pud, address);
-			set_pte_atomic((pte_t *)pmd, pte);
+			task_lock(p);
+			mm = p->mm;
+			if (mm) {
+				pgt_lock = &mm->page_table_lock;
+				spin_lock(pgt_lock);
+
+				pgd = mm->pgd + pgd_index(address);
+				pud = pud_offset(pgd, address);
+				pmd = pmd_offset(pud, address);
+				set_pte_atomic((pte_t *)pmd, pte);
+
+				spin_unlock(pgt_lock);
+			}
+			task_unlock(p);
 		}
 	}
 #endif
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
